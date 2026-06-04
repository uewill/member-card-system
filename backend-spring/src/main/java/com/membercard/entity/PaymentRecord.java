package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 支付记录实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRecord {
    private Long id;
    private Long tenantId;
    private Long storeId;
    /** 关联订单ID */
    private Long orderId;
    /** sell_card/recharge/consume_diff */
    private String type;
    /** wechat/alipay/cash/card_deduction */
    private String paymentMethod;
    /** 金额 */
    private BigDecimal amount;
    /** 卡扣减明细JSON */
    private String cardDeductionsJson;
    /** 现金金额 */
    private BigDecimal cashAmount;
    private LocalDateTime createdAt;
}
