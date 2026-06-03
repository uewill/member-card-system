package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.membercard.dto.PaymentResult;
import com.membercard.dto.RechargeRequest;
import com.membercard.entity.Member;
import com.membercard.entity.MemberCard;
import com.membercard.entity.PackageTemplate;
import com.membercard.entity.RechargeOrder;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.MemberCardMapper;
import com.membercard.mapper.MemberMapper;
import com.membercard.mapper.PackageTemplateMapper;
import com.membercard.mapper.RechargeOrderMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 充值/购卡服务 - 购卡流程、充值流程、赠送规则引擎
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RechargeService {

    private final RechargeOrderMapper rechargeOrderMapper;
    private final MemberMapper memberMapper;
    private final MemberCardMapper memberCardMapper;
    private final PackageTemplateMapper packageTemplateMapper;
    private final PaymentService paymentService;
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    /**
     * 售卖开卡 / 充值
     */
    @Transactional
    public Map<String, Object> recharge(RechargeRequest request) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 1. 验证会员
        Member member = memberMapper.selectById(request.getMemberId());
        if (member == null) {
            throw new RuntimeException("会员不存在");
        }

        // 2. 生成订单号
        String orderNo = generateOrderNo();

        // 3. 发起支付
        PaymentResult paymentResult = paymentService.pay(
                request.getPaymentMethod(), request.getAmount(), orderNo);

        // 4. 创建充值订单
        RechargeOrder order = new RechargeOrder();
        order.setTenantId(tenantId);
        order.setStoreId(request.getStoreId());
        order.setMemberId(request.getMemberId());
        order.setOrderNo(orderNo);
        order.setOrderType(request.getOrderType());
        order.setAmount(request.getAmount());
        order.setPaymentMethod(request.getPaymentMethod());
        order.setPaymentStatus(paymentResult.getSuccess() ? "SUCCESS" : "FAILED");
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());

        Map<String, Object> result = new HashMap<>();
        result.put("orderNo", orderNo);
        result.put("paymentStatus", order.getPaymentStatus());

        if (!paymentResult.getSuccess()) {
            rechargeOrderMapper.insert(order);
            result.put("errorMessage", paymentResult.getErrorMessage());
            return result;
        }

        if ("PURCHASE".equals(request.getOrderType())) {
            // 购卡流程
            Long cardId = processPurchase(request, order);
            order.setTemplateId(request.getTemplateId());
            order.setCardId(cardId);
            result.put("cardId", cardId);
        } else if ("RECHARGE".equals(request.getOrderType())) {
            // 充值流程
            BigDecimal giftAmount = processRecharge(request, order);
            order.setCardId(request.getCardId());
            order.setGiftAmount(giftAmount);
            result.put("giftAmount", giftAmount);
        }

        rechargeOrderMapper.insert(order);
        return result;
    }

    /**
     * 购卡流程
     */
    private Long processPurchase(RechargeRequest request, RechargeOrder order) {
        // 1. 查询套餐模板
        PackageTemplate template = packageTemplateMapper.selectById(request.getTemplateId());
        if (template == null) {
            throw new RuntimeException("套餐模板不存在");
        }

        // 2. 创建卡实例
        MemberCard card = new MemberCard();
        card.setTenantId(TenantContextHolder.getTenantId());
        card.setMemberId(request.getMemberId());
        card.setTemplateId(template.getId());

        // 模板快照（冻结购买时的模板信息）
        Map<String, Object> snapshot = new HashMap<>();
        snapshot.put("name", template.getName());
        snapshot.put("type", template.getType());
        snapshot.put("config", template.getConfig());
        snapshot.put("salePrice", template.getSalePrice());
        card.setTemplateSnapshot(objectMapper.valueToTree(snapshot).toString());

        // 3. 初始化卡数据
        LocalDate now = LocalDate.now();
        card.setValidFrom(now);

        if (template.getValidityDays() != null) {
            card.setValidTo(now.plusDays(template.getValidityDays()));
        } else if (template.getValidityEndDate() != null) {
            card.setValidTo(template.getValidityEndDate());
        } else {
            card.setValidTo(now.plusYears(1));
        }

        card.setBalancePrincipal(BigDecimal.ZERO);
        card.setBalanceGift(BigDecimal.ZERO);
        card.setStatus("ACTIVE");
        card.setCreatedAt(LocalDateTime.now());
        card.setUpdatedAt(LocalDateTime.now());

        // 4. 根据套餐类型初始化次数/余额
        try {
            Map<String, Object> config = objectMapper.readValue(
                    template.getConfig(), new TypeReference<>() {});
            String type = template.getType();

            if ("COUNT".equals(type) || "MIXED".equals(type)) {
                // 初始化服务项目次数
                Object serviceItemsObj = config.get("serviceItems");
                if (serviceItemsObj instanceof List) {
                    Map<String, Integer> remainingCounts = new HashMap<>();
                    for (Map<String, Object> item : (List<Map<String, Object>>) serviceItemsObj) {
                        String serviceItemId = item.get("serviceItemId").toString();
                        int count = Integer.parseInt(item.get("count").toString());
                        remainingCounts.put(serviceItemId, count);
                    }
                    card.setRemainingCounts(objectMapper.writeValueAsString(remainingCounts));
                }
            }

            if ("VALUE".equals(type)) {
                // 储值卡：售价即为余额
                card.setBalancePrincipal(request.getAmount());
            } else if ("MIXED".equals(type)) {
                // 混合卡：售价中一部分为余额
                Object balanceConfig = config.get("initialBalance");
                if (balanceConfig != null) {
                    BigDecimal initialBalance = new BigDecimal(balanceConfig.toString());
                    card.setBalancePrincipal(initialBalance);
                }
            }
        } catch (Exception e) {
            log.error("解析套餐配置失败", e);
            throw new RuntimeException("套餐配置解析失败");
        }

        memberCardMapper.insert(card);
        return card.getId();
    }

    /**
     * 充值流程
     */
    private BigDecimal processRecharge(RechargeRequest request, RechargeOrder order) {
        // 1. 查询目标卡
        MemberCard card = memberCardMapper.selectById(request.getCardId());
        if (card == null) {
            throw new RuntimeException("目标卡不存在");
        }
        if (!"ACTIVE".equals(card.getStatus())) {
            throw new RuntimeException("目标卡状态异常");
        }

        // 2. 计算赠送金额
        BigDecimal giftAmount = calculateGiftAmount(request.getAmount());

        // 3. 增加余额
        card.setBalancePrincipal(card.getBalancePrincipal().add(request.getAmount()));
        card.setBalanceGift(card.getBalanceGift().add(giftAmount));
        card.setUpdatedAt(LocalDateTime.now());
        memberCardMapper.updateById(card);

        return giftAmount;
    }

    /**
     * 赠送规则引擎 - 根据充值金额计算赠送金额
     */
    public BigDecimal calculateGiftAmount(BigDecimal amount) {
        List<Map<String, Object>> rules = getGiftRulesFromDb();
        BigDecimal giftAmount = BigDecimal.ZERO;

        for (Map<String, Object> rule : rules) {
            BigDecimal minAmount = new BigDecimal(rule.get("min_amount").toString());
            BigDecimal maxAmount = rule.get("max_amount") != null ?
                    new BigDecimal(rule.get("max_amount").toString()) : null;
            BigDecimal gift = new BigDecimal(rule.get("gift_amount").toString());

            if (amount.compareTo(minAmount) >= 0) {
                if (maxAmount == null || amount.compareTo(maxAmount) < 0) {
                    giftAmount = gift;
                }
            }
        }

        return giftAmount;
    }

    /**
     * 获取充值订单详情
     */
    public RechargeOrder getById(Long id) {
        return rechargeOrderMapper.selectById(id);
    }

    /**
     * 分页查询充值订单列表
     */
    public Page<RechargeOrder> page(Integer current, Integer size, Long memberId, String orderType, String paymentStatus) {
        Page<RechargeOrder> page = new Page<>(current, size);
        LambdaQueryWrapper<RechargeOrder> wrapper = new LambdaQueryWrapper<>();
        if (memberId != null) {
            wrapper.eq(RechargeOrder::getMemberId, memberId);
        }
        if (orderType != null && !orderType.isEmpty()) {
            wrapper.eq(RechargeOrder::getOrderType, orderType);
        }
        if (paymentStatus != null && !paymentStatus.isEmpty()) {
            wrapper.eq(RechargeOrder::getPaymentStatus, paymentStatus);
        }
        wrapper.orderByDesc(RechargeOrder::getCreatedAt);
        return rechargeOrderMapper.selectPage(page, wrapper);
    }

    /**
     * 获取赠送规则列表
     */
    public List<Map<String, Object>> getGiftRules() {
        return getGiftRulesFromDb();
    }

    /**
     * 计算赠送金额（对外接口）
     */
    public Map<String, Object> calculateGift(BigDecimal amount) {
        BigDecimal giftAmount = calculateGiftAmount(amount);
        Map<String, Object> result = new HashMap<>();
        result.put("amount", amount);
        result.put("giftAmount", giftAmount);
        result.put("totalAmount", amount.add(giftAmount));
        return result;
    }

    /**
     * 从数据库获取赠送规则
     */
    private List<Map<String, Object>> getGiftRulesFromDb() {
        Long tenantId = TenantContextHolder.getTenantId();
        if (tenantId == null) {
            return Collections.emptyList();
        }
        return jdbcTemplate.queryForList(
                "SELECT id, min_amount, max_amount, gift_amount FROM t_gift_rule WHERE tenant_id = ? AND status = 1 ORDER BY min_amount",
                tenantId);
    }

    /**
     * 生成订单号
     */
    private String generateOrderNo() {
        return "R" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));
    }
}
