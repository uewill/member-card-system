package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.dto.RechargeRequest;
import com.membercard.entity.*;
import com.membercard.mapper.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * 支付服务
 */
@Service
public class PaymentService {

    private final PaymentRecordMapper paymentRecordMapper;
    private final RechargeRuleMapper rechargeRuleMapper;
    private final MemberCardMapper memberCardMapper;
    private final MemberMapper memberMapper;

    public PaymentService(PaymentRecordMapper paymentRecordMapper, RechargeRuleMapper rechargeRuleMapper,
                          MemberCardMapper memberCardMapper, MemberMapper memberMapper) {
        this.paymentRecordMapper = paymentRecordMapper;
        this.rechargeRuleMapper = rechargeRuleMapper;
        this.memberCardMapper = memberCardMapper;
        this.memberMapper = memberMapper;
    }

    public List<PaymentRecord> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return paymentRecordMapper.findByTenantId(tenantId);
    }

    public List<PaymentRecord> findByStoreId(Long storeId) {
        Long tenantId = TenantContext.getTenantId();
        return paymentRecordMapper.findByStoreId(tenantId, storeId);
    }

    public List<PaymentRecord> findByType(String type) {
        Long tenantId = TenantContext.getTenantId();
        return paymentRecordMapper.findByType(tenantId, type);
    }

    /**
     * 充值（含赠送规则计算）
     */
    @Transactional
    public PaymentRecord recharge(RechargeRequest request) {
        Long tenantId = TenantContext.getTenantId();

        // 验证会员
        Member member = memberMapper.findById(request.getMemberId(), tenantId);
        if (member == null) {
            throw new BusinessException(404, "会员不存在");
        }

        // 查找适用的充值赠送规则
        List<RechargeRule> rules = rechargeRuleMapper.findEnabledByTenantId(tenantId);
        BigDecimal bonusAmount = BigDecimal.ZERO;
        for (RechargeRule rule : rules) {
            if (request.getAmount().compareTo(rule.getMinAmount()) >= 0) {
                if ("fixed".equals(rule.getBonusType())) {
                    bonusAmount = rule.getBonusAmount();
                } else if ("ratio".equals(rule.getBonusRatio())) {
                    bonusAmount = request.getAmount().multiply(rule.getBonusRatio())
                            .divide(BigDecimal.valueOf(100), 2, BigDecimal.ROUND_HALF_UP);
                }
            }
        }

        // 查找会员的储值卡
        List<MemberCard> cards = memberCardMapper.findByMemberIdAndStatus(
                request.getMemberId(), tenantId, "active");
        MemberCard valueCard = cards.stream()
                .filter(c -> "value_card".equals(c.getType()) || "hybrid_card".equals(c.getType()))
                .findFirst()
                .orElse(null);

        if (valueCard != null) {
            valueCard.setPrincipalBalance(valueCard.getPrincipalBalance().add(request.getAmount()));
            valueCard.setBonusBalance(valueCard.getBonusBalance().add(bonusAmount));
            memberCardMapper.update(valueCard);
        }

        // 创建支付记录
        PaymentRecord record = new PaymentRecord();
        record.setTenantId(tenantId);
        record.setStoreId(request.getStoreId());
        record.setType("recharge");
        record.setPaymentMethod(request.getPaymentMethod());
        record.setAmount(request.getAmount());
        record.setCashAmount(request.getAmount());
        paymentRecordMapper.insert(record);

        return record;
    }

    /**
     * 记录售卡支付
     */
    public PaymentRecord recordSellCardPayment(Long storeId, String paymentMethod, BigDecimal amount) {
        Long tenantId = TenantContext.getTenantId();
        PaymentRecord record = new PaymentRecord();
        record.setTenantId(tenantId);
        record.setStoreId(storeId);
        record.setType("sell_card");
        record.setPaymentMethod(paymentMethod);
        record.setAmount(amount);
        record.setCashAmount(amount);
        paymentRecordMapper.insert(record);
        return record;
    }
}
