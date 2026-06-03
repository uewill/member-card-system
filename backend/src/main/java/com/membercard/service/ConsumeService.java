package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.membercard.dto.CardMatchResult;
import com.membercard.dto.ConsumeRequest;
import com.membercard.dto.ConsumeResult;
import com.membercard.entity.*;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 消费核销核心服务
 * 纯次数卡/储值卡/混合卡扣减、多卡组合支付、并发控制
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ConsumeService {

    private final ConsumeOrderMapper consumeOrderMapper;
    private final ConsumeDetailMapper consumeDetailMapper;
    private final MemberCardMapper memberCardMapper;
    private final MemberMapper memberMapper;
    private final ServiceItemMapper serviceItemMapper;
    private final CardService cardService;
    private final ObjectMapper objectMapper;

    /**
     * 快速核销（自动匹配最优卡）
     */
    @Transactional
    public ConsumeResult quickConsume(ConsumeRequest request) {
        // 1. 验证会员
        Member member = memberMapper.selectById(request.getMemberId());
        if (member == null) {
            throw new RuntimeException("会员不存在");
        }

        // 2. 验证服务项目
        ServiceItem serviceItem = serviceItemMapper.selectById(request.getServiceItemId());
        if (serviceItem == null) {
            throw new RuntimeException("服务项目不存在");
        }

        // 3. 自动匹配最优卡
        List<CardMatchResult> matchResults = cardService.matchCards(request.getMemberId(), request.getServiceItemId());
        if (matchResults.isEmpty()) {
            throw new RuntimeException("没有可用的卡进行核销");
        }

        // 4. 使用最优卡进行扣减
        CardMatchResult bestCard = matchResults.get(0);
        request.setCardId(bestCard.getCardId());
        return consumeWithCard(request);
    }

    /**
     * 指定卡核销
     */
    @Transactional
    public ConsumeResult consumeWithCard(ConsumeRequest request) {
        Long tenantId = TenantContextHolder.getTenantId();
        Long userId = TenantContextHolder.getUserId();

        // 1. 验证会员
        Member member = memberMapper.selectById(request.getMemberId());
        if (member == null) {
            throw new RuntimeException("会员不存在");
        }

        // 2. 验证服务项目
        ServiceItem serviceItem = serviceItemMapper.selectById(request.getServiceItemId());
        if (serviceItem == null) {
            throw new RuntimeException("服务项目不存在");
        }

        // 3. 验证卡实例
        MemberCard card = memberCardMapper.selectById(request.getCardId());
        if (card == null) {
            throw new RuntimeException("卡实例不存在");
        }
        if (!"ACTIVE".equals(card.getStatus())) {
            throw new RuntimeException("卡实例状态异常: " + card.getStatus());
        }
        if (card.getValidTo().isBefore(LocalDate.now())) {
            throw new RuntimeException("卡实例已过期");
        }

        // 4. 生成消费订单
        String orderNo = generateOrderNo();
        ConsumeOrder order = new ConsumeOrder();
        order.setTenantId(tenantId);
        order.setStoreId(request.getStoreId());
        order.setMemberId(request.getMemberId());
        order.setOrderNo(orderNo);
        order.setTotalAmount(serviceItem.getPrice());
        order.setStatus("COMPLETED");
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());

        // 5. 执行扣减
        BigDecimal paidAmount = BigDecimal.ZERO;
        ConsumeResult.ConsumeDetailResult detailResult = new ConsumeResult.ConsumeDetailResult();
        detailResult.setServiceItemId(serviceItem.getId());
        detailResult.setServiceItemName(serviceItem.getName());
        detailResult.setCardId(card.getId());

        try {
            Map<String, Object> snapshot = objectMapper.readValue(
                    card.getTemplateSnapshot(), new TypeReference<>() {});
            String cardType = (String) snapshot.get("type");

            if ("COUNT".equals(cardType)) {
                // 纯次数卡扣减
                paidAmount = deductCount(card, serviceItem, detailResult);
            } else if ("VALUE".equals(cardType)) {
                // 纯储值卡扣减
                paidAmount = deductValue(card, serviceItem, detailResult);
            } else if ("MIXED".equals(cardType)) {
                // 混合卡：优先扣次数，次数不足用余额补
                int remainingCount = getRemainingCountForService(card.getRemainingCounts(), serviceItem.getId());
                if (remainingCount > 0) {
                    paidAmount = deductCount(card, serviceItem, detailResult);
                } else {
                    paidAmount = deductValue(card, serviceItem, detailResult);
                }
            }

            order.setPaidAmount(paidAmount);
            consumeOrderMapper.insert(order);

            // 6. 保存消费明细
            ConsumeDetail detail = new ConsumeDetail();
            detail.setTenantId(tenantId);
            detail.setOrderId(order.getId());
            detail.setServiceItemId(serviceItem.getId());
            detail.setServiceItemName(serviceItem.getName());
            detail.setServiceStaffId(request.getServiceStaffId());
            detail.setServiceStaffName(request.getServiceStaffName());
            detail.setPerformanceRatio(request.getPerformanceRatio() != null ?
                    request.getPerformanceRatio() : new BigDecimal("1.00"));
            detail.setCardId(card.getId());
            detail.setDeductType(detailResult.getDeductType());
            detail.setDeductBefore(detailResult.getDeductBefore());
            detail.setDeductAfter(detailResult.getDeductAfter());
            detail.setDeductAmount(detailResult.getDeductAmount());
            detail.setCreatedAt(LocalDateTime.now());
            consumeDetailMapper.insert(detail);

        } catch (Exception e) {
            log.error("消费核销失败: orderNo={}", orderNo, e);
            throw new RuntimeException("消费核销失败: " + e.getMessage());
        }

        // 7. 构建返回结果
        ConsumeResult result = new ConsumeResult();
        result.setOrderId(order.getId());
        result.setOrderNo(orderNo);
        result.setTotalAmount(order.getTotalAmount());
        result.setPaidAmount(paidAmount);
        result.setCashAmount(BigDecimal.ZERO);
        result.setStatus("COMPLETED");
        result.setDetails(List.of(detailResult));

        return result;
    }

    /**
     * 多卡组合支付核销
     */
    @Transactional
    public ConsumeResult combineConsume(ConsumeRequest request) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 1. 验证会员
        Member member = memberMapper.selectById(request.getMemberId());
        if (member == null) {
            throw new RuntimeException("会员不存在");
        }

        // 2. 验证服务项目
        ServiceItem serviceItem = serviceItemMapper.selectById(request.getServiceItemId());
        if (serviceItem == null) {
            throw new RuntimeException("服务项目不存在");
        }

        // 3. 解析多卡组合支付明细
        List<Map<String, Object>> paymentItems;
        try {
            paymentItems = objectMapper.readValue(request.getPaymentItems(), new TypeReference<>() {});
        } catch (Exception e) {
            throw new RuntimeException("支付明细格式错误");
        }

        // 4. 生成消费订单
        String orderNo = generateOrderNo();
        ConsumeOrder order = new ConsumeOrder();
        order.setTenantId(tenantId);
        order.setStoreId(request.getStoreId());
        order.setMemberId(request.getMemberId());
        order.setOrderNo(orderNo);
        order.setTotalAmount(serviceItem.getPrice());
        order.setPaymentDetail(request.getPaymentItems());
        order.setStatus("COMPLETED");
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());

        BigDecimal totalPaid = BigDecimal.ZERO;
        BigDecimal cashAmount = BigDecimal.ZERO;
        List<ConsumeResult.ConsumeDetailResult> detailResults = new ArrayList<>();

        // 5. 依次处理每张卡的扣减
        for (Map<String, Object> item : paymentItems) {
            String deductType = (String) item.get("deductType");

            if ("CASH".equals(deductType)) {
                // 现金补齐
                cashAmount = cashAmount.add(new BigDecimal(item.get("deductAmount").toString()));
                continue;
            }

            Long cardId = Long.valueOf(item.get("cardId").toString());
            MemberCard card = memberCardMapper.selectById(cardId);
            if (card == null || !"ACTIVE".equals(card.getStatus())) {
                throw new RuntimeException("卡实例不可用: cardId=" + cardId);
            }

            ConsumeResult.ConsumeDetailResult detailResult = new ConsumeResult.ConsumeDetailResult();
            detailResult.setServiceItemId(serviceItem.getId());
            detailResult.setServiceItemName(serviceItem.getName());
            detailResult.setCardId(cardId);
            detailResult.setDeductType(deductType);

            BigDecimal deductAmount;
            if ("COUNT".equals(deductType)) {
                deductAmount = deductCount(card, serviceItem, detailResult);
            } else if ("VALUE".equals(deductType)) {
                BigDecimal amount = new BigDecimal(item.get("deductAmount").toString());
                deductAmount = deductValueAmount(card, amount, detailResult);
            } else {
                throw new RuntimeException("不支持的扣减类型: " + deductType);
            }

            totalPaid = totalPaid.add(deductAmount);

            // 保存消费明细
            ConsumeDetail detail = new ConsumeDetail();
            detail.setTenantId(tenantId);
            detail.setOrderId(order.getId());
            detail.setServiceItemId(serviceItem.getId());
            detail.setServiceItemName(serviceItem.getName());
            detail.setServiceStaffId(request.getServiceStaffId());
            detail.setServiceStaffName(request.getServiceStaffName());
            detail.setPerformanceRatio(request.getPerformanceRatio() != null ?
                    request.getPerformanceRatio() : new BigDecimal("1.00"));
            detail.setCardId(cardId);
            detail.setDeductType(detailResult.getDeductType());
            detail.setDeductBefore(detailResult.getDeductBefore());
            detail.setDeductAfter(detailResult.getDeductAfter());
            detail.setDeductAmount(detailResult.getDeductAmount());
            detail.setCreatedAt(LocalDateTime.now());
            consumeDetailMapper.insert(detail);

            detailResults.add(detailResult);
        }

        totalPaid = totalPaid.add(cashAmount);
        order.setPaidAmount(totalPaid);
        consumeOrderMapper.insert(order);

        // 6. 构建返回结果
        ConsumeResult result = new ConsumeResult();
        result.setOrderId(order.getId());
        result.setOrderNo(orderNo);
        result.setTotalAmount(order.getTotalAmount());
        result.setPaidAmount(totalPaid);
        result.setCashAmount(cashAmount);
        result.setStatus("COMPLETED");
        result.setDetails(detailResults);

        return result;
    }

    /**
     * 撤销核销
     */
    @Transactional
    public void cancelConsume(String orderNo) {
        // 1. 查询订单
        ConsumeOrder order = consumeOrderMapper.selectOne(
                new LambdaQueryWrapper<ConsumeOrder>().eq(ConsumeOrder::getOrderNo, orderNo));
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        if ("CANCELLED".equals(order.getStatus())) {
            throw new RuntimeException("订单已撤销");
        }

        // 2. 查询消费明细
        List<ConsumeDetail> details = consumeDetailMapper.selectList(
                new LambdaQueryWrapper<ConsumeDetail>().eq(ConsumeDetail::getOrderId, order.getId()));

        // 3. 逐条回滚扣减
        for (ConsumeDetail detail : details) {
            if (detail.getCardId() != null) {
                MemberCard card = memberCardMapper.selectById(detail.getCardId());
                if (card != null) {
                    rollbackDeduction(card, detail);
                    memberCardMapper.updateById(card);
                }
            }
        }

        // 4. 更新订单状态
        order.setStatus("CANCELLED");
        order.setUpdatedAt(LocalDateTime.now());
        consumeOrderMapper.updateById(order);
    }

    /**
     * 获取核销记录详情
     */
    public Map<String, Object> getOrderDetail(String orderNo) {
        ConsumeOrder order = consumeOrderMapper.selectOne(
                new LambdaQueryWrapper<ConsumeOrder>().eq(ConsumeOrder::getOrderNo, orderNo));
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        List<ConsumeDetail> details = consumeDetailMapper.selectList(
                new LambdaQueryWrapper<ConsumeDetail>().eq(ConsumeDetail::getOrderId, order.getId()));

        Map<String, Object> result = new HashMap<>();
        result.put("order", order);
        result.put("details", details);
        return result;
    }

    // ==================== 私有方法 ====================

    /**
     * 纯次数卡扣减
     */
    private BigDecimal deductCount(MemberCard card, ServiceItem serviceItem,
                                   ConsumeResult.ConsumeDetailResult detailResult) {
        try {
            Map<String, Object> counts = new HashMap<>();
            if (card.getRemainingCounts() != null && !card.getRemainingCounts().isEmpty()) {
                counts = objectMapper.readValue(card.getRemainingCounts(), new TypeReference<>() {});
            }

            String serviceItemIdStr = serviceItem.getId().toString();
            int currentCount = counts.containsKey(serviceItemIdStr) ?
                    Integer.parseInt(counts.get(serviceItemIdStr).toString()) : 0;

            if (currentCount <= 0) {
                throw new RuntimeException("该服务项目剩余次数不足");
            }

            detailResult.setDeductBefore(String.valueOf(currentCount));
            counts.put(serviceItemIdStr, currentCount - 1);
            detailResult.setDeductAfter(String.valueOf(currentCount - 1));
            detailResult.setDeductType("COUNT");
            detailResult.setDeductAmount(BigDecimal.ZERO); // 次数卡扣减金额为0

            card.setRemainingCounts(objectMapper.writeValueAsString(counts));
            memberCardMapper.updateById(card);

            // 检查是否所有次数用完
            checkCardUsedUp(card, counts);

            return BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("次数扣减失败: " + e.getMessage());
        }
    }

    /**
     * 纯储值卡扣减
     */
    private BigDecimal deductValue(MemberCard card, ServiceItem serviceItem,
                                   ConsumeResult.ConsumeDetailResult detailResult) {
        BigDecimal price = serviceItem.getPrice();
        return deductValueAmount(card, price, detailResult);
    }

    /**
     * 按金额扣减储值卡
     */
    private BigDecimal deductValueAmount(MemberCard card, BigDecimal amount,
                                          ConsumeResult.ConsumeDetailResult detailResult) {
        BigDecimal totalBalance = card.getBalancePrincipal().add(card.getBalanceGift());
        if (totalBalance.compareTo(amount) < 0) {
            throw new RuntimeException("余额不足，当前总余额: " + totalBalance);
        }

        detailResult.setDeductBefore(totalBalance.toString());

        // 先扣本金，再扣赠送
        BigDecimal remaining = amount;
        if (card.getBalancePrincipal().compareTo(remaining) >= 0) {
            card.setBalancePrincipal(card.getBalancePrincipal().subtract(remaining));
            remaining = BigDecimal.ZERO;
        } else {
            remaining = remaining.subtract(card.getBalancePrincipal());
            card.setBalancePrincipal(BigDecimal.ZERO);
        }
        if (remaining.compareTo(BigDecimal.ZERO) > 0) {
            card.setBalanceGift(card.getBalanceGift().subtract(remaining));
        }

        BigDecimal newTotalBalance = card.getBalancePrincipal().add(card.getBalanceGift());
        detailResult.setDeductAfter(newTotalBalance.toString());
        detailResult.setDeductType("VALUE");
        detailResult.setDeductAmount(amount);

        memberCardMapper.updateById(card);

        // 检查余额是否用完
        if (newTotalBalance.compareTo(BigDecimal.ZERO) == 0) {
            card.setStatus("USED_UP");
            memberCardMapper.updateById(card);
        }

        return amount;
    }

    /**
     * 回滚扣减
     */
    private void rollbackDeduction(MemberCard card, ConsumeDetail detail) {
        try {
            if ("COUNT".equals(detail.getDeductType())) {
                // 回滚次数
                Map<String, Object> counts = new HashMap<>();
                if (card.getRemainingCounts() != null && !card.getRemainingCounts().isEmpty()) {
                    counts = objectMapper.readValue(card.getRemainingCounts(), new TypeReference<>() {});
                }

                // 从扣减前快照恢复
                int beforeCount = Integer.parseInt(detail.getDeductBefore());
                counts.put(detail.getServiceItemId().toString(), beforeCount);
                card.setRemainingCounts(objectMapper.writeValueAsString(counts));

                if ("USED_UP".equals(card.getStatus())) {
                    card.setStatus("ACTIVE");
                }
            } else if ("VALUE".equals(detail.getDeductType())) {
                // 回滚金额
                BigDecimal deductAmount = detail.getDeductAmount();
                // 优先恢复本金
                card.setBalancePrincipal(card.getBalancePrincipal().add(deductAmount));

                if ("USED_UP".equals(card.getStatus())) {
                    card.setStatus("ACTIVE");
                }
            }
        } catch (Exception e) {
            log.error("回滚扣减失败: cardId={}, detailId={}", card.getId(), detail.getId(), e);
        }
    }

    /**
     * 检查卡是否所有次数用完
     */
    private void checkCardUsedUp(MemberCard card, Map<String, Object> counts) {
        boolean allUsedUp = true;
        for (Object value : counts.values()) {
            if (Integer.parseInt(value.toString()) > 0) {
                allUsedUp = false;
                break;
            }
        }
        if (allUsedUp && card.getBalancePrincipal().add(card.getBalanceGift()).compareTo(BigDecimal.ZERO) == 0) {
            card.setStatus("USED_UP");
            memberCardMapper.updateById(card);
        }
    }

    /**
     * 从 remainingCounts JSON 中获取指定服务项目的剩余次数
     */
    private int getRemainingCountForService(String remainingCountsJson, Long serviceItemId) {
        if (remainingCountsJson == null || remainingCountsJson.isEmpty()) {
            return 0;
        }
        try {
            Map<String, Object> counts = objectMapper.readValue(remainingCountsJson, new TypeReference<>() {});
            Object countObj = counts.get(serviceItemId.toString());
            if (countObj != null) {
                return Integer.parseInt(countObj.toString());
            }
        } catch (Exception e) {
            log.error("解析剩余次数JSON失败", e);
        }
        return 0;
    }

    /**
     * 生成订单号
     */
    private String generateOrderNo() {
        return "C" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));
    }
}
