package com.membercard.dto;

import javax.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 充值/购卡请求DTO
 */
@Data
public class RechargeRequest {

    @NotNull(message = "会员ID不能为空")
    private Long memberId;

    @NotNull(message = "门店ID不能为空")
    private Long storeId;

    /**
     * 订单类型: PURCHASE(购卡), RECHARGE(充值)
     */
    @NotNull(message = "订单类型不能为空")
    private String orderType;

    /**
     * 套餐模板ID（购卡时必传）
     */
    private Long templateId;

    /**
     * 充值目标卡ID（充值时必传）
     */
    private Long cardId;

    /**
     * 支付金额
     */
    @NotNull(message = "支付金额不能为空")
    private BigDecimal amount;

    /**
     * 支付方式: WECHAT, ALIPAY, CASH
     */
    @NotNull(message = "支付方式不能为空")
    private String paymentMethod;
}
