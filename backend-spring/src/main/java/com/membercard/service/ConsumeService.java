package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.dto.ConsumeRequest;
import com.membercard.entity.*;
import com.membercard.mapper.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * 消费服务
 */
@Service
public class ConsumeService {

    private final ConsumeOrderMapper consumeOrderMapper;
    private final ConsumeDetailMapper consumeDetailMapper;
    private final MemberCardMapper memberCardMapper;
    private final ServiceItemMapper serviceItemMapper;
    private final MemberMapper memberMapper;
    private final ObjectMapper objectMapper;

    public ConsumeService(ConsumeOrderMapper consumeOrderMapper, ConsumeDetailMapper consumeDetailMapper,
                           MemberCardMapper memberCardMapper, ServiceItemMapper serviceItemMapper,
                           MemberMapper memberMapper, ObjectMapper objectMapper) {
        this.consumeOrderMapper = consumeOrderMapper;
        this.consumeDetailMapper = consumeDetailMapper;
        this.memberCardMapper = memberCardMapper;
        this.serviceItemMapper = serviceItemMapper;
        this.memberMapper = memberMapper;
        this.objectMapper = objectMapper;
    }

    public ConsumeOrder findById(Long id) {
        Long tenantId = TenantContext.getTenantId();
        ConsumeOrder order = consumeOrderMapper.findById(id, tenantId);
        if (order == null) {
            throw new BusinessException(404, "消费订单不存在");
        }
        return order;
    }

    public List<ConsumeOrder> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return consumeOrderMapper.findByTenantId(tenantId);
    }

    public List<ConsumeOrder> findByMemberId(Long memberId) {
        Long tenantId = TenantContext.getTenantId();
        return consumeOrderMapper.findByMemberId(tenantId, memberId);
    }

    public List<ConsumeDetail> findDetailsByOrderId(Long orderId) {
        Long tenantId = TenantContext.getTenantId();
        return consumeDetailMapper.findByOrderId(orderId, tenantId);
    }

    /**
     * 创建消费订单
     */
    @Transactional
    public ConsumeOrder createOrder(ConsumeRequest request) {
        Long tenantId = TenantContext.getTenantId();

        // 验证会员
        Member member = memberMapper.findById(request.getMemberId(), tenantId);
        if (member == null) {
            throw new BusinessException(404, "会员不存在");
        }

        // 计算总金额
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal cardDeductionTotal = BigDecimal.ZERO;

        // 创建订单
        ConsumeOrder order = new ConsumeOrder();
        order.setTenantId(tenantId);
        order.setStoreId(request.getStoreId());
        order.setMemberId(request.getMemberId());
        order.setEmployeeId(request.getEmployeeId());
        order.setStatus("normal");

        try {
            // 处理消费明细
            for (ConsumeRequest.ConsumeItemRequest item : request.getItems()) {
                ServiceItem serviceItem = serviceItemMapper.findById(item.getServiceItemId(), tenantId);
                if (serviceItem == null) {
                    throw new BusinessException(404, "服务项目不存在: " + item.getServiceItemId());
                }

                totalAmount = totalAmount.add(serviceItem.getPrice());

                // 处理卡扣减
                if (item.getCardId() != null) {
                    MemberCard card = memberCardMapper.findById(item.getCardId(), tenantId);
                    if (card == null) {
                        throw new BusinessException(404, "会员卡不存在: " + item.getCardId());
                    }
                    if (!"active".equals(card.getStatus())) {
                        throw new BusinessException(400, "会员卡状态异常，无法使用");
                    }

                    String beforeSnapshot = card.getRemainingCountsJson();

                    if ("count".equals(item.getDeductionType())) {
                        // 次卡扣减
                        card.setRemainingCountsJson(updateCount(card.getRemainingCountsJson(),
                                item.getServiceItemId(), -item.getDeductionCount()));
                    } else if ("balance".equals(item.getDeductionBalance())) {
                        // 储值卡扣减
                        card.setPrincipalBalance(card.getPrincipalBalance().subtract(item.getDeductionAmount()));
                        cardDeductionTotal = cardDeductionTotal.add(item.getDeductionAmount());
                    }

                    String afterSnapshot = card.getRemainingCountsJson();
                    memberCardMapper.update(card);

                    // 创建消费明细
                    ConsumeDetail detail = new ConsumeDetail();
                    detail.setTenantId(tenantId);
                    detail.setOrderId(order.getId());
                    detail.setServiceItemId(item.getServiceItemId());
                    detail.setCardId(item.getCardId());
                    detail.setDeductionType(item.getDeductionType());
                    detail.setDeductionCount(item.getDeductionCount());
                    detail.setDeductionAmount(item.getDeductionAmount());
                    detail.setBeforeSnapshotJson(beforeSnapshot);
                    detail.setAfterSnapshotJson(afterSnapshot);
                    detail.setEmployeeRatioJson(objectMapper.writeValueAsString(item.getEmployeeRatios()));
                    consumeDetailMapper.insert(detail);
                }
            }
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw new BusinessException(500, "创建消费订单失败: " + e.getMessage());
        }

        // 设置订单金额
        order.setTotalAmount(totalAmount);
        order.setActualPaid(totalAmount.subtract(cardDeductionTotal));

        try {
            order.setPaymentMethodsJson(objectMapper.writeValueAsString(request.getPaymentMethods()));
        } catch (Exception e) {
            order.setPaymentMethodsJson("[]");
        }

        consumeOrderMapper.insert(order);
        return order;
    }

    /**
     * 取消订单
     */
    @Transactional
    public void cancelOrder(Long orderId) {
        Long tenantId = TenantContext.getTenantId();
        consumeOrderMapper.updateStatus(orderId, tenantId, "cancelled");
    }

    private String updateCount(String countsJson, Long serviceItemId, int delta) {
        // 简化的次数更新逻辑
        return countsJson; // 实际实现需要解析JSON并更新
    }
}
