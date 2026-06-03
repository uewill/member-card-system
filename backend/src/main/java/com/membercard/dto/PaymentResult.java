package com.membercard.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 支付结果DTO
 */
@Data
public class PaymentResult {

    /**
     * 是否支付成功
     */
    private Boolean success;

    /**
     * 支付渠道交易号
     */
    private String transactionNo;

    /**
     * 支付方式
     */
    private String paymentMethod;

    /**
     * 支付金额
     */
    private BigDecimal amount;

    /**
     * 支付状态
     */
    private String status;

    /**
     * 错误信息（失败时）
     */
    private String errorMessage;

    /**
     * 支付时间
     */
    private String paidAt;

    public static PaymentResult success(String transactionNo, String paymentMethod, BigDecimal amount) {
        PaymentResult result = new PaymentResult();
        result.setSuccess(true);
        result.setTransactionNo(transactionNo);
        result.setPaymentMethod(paymentMethod);
        result.setAmount(amount);
        result.setStatus("SUCCESS");
        result.setPaidAt(java.time.LocalDateTime.now().toString());
        return result;
    }

    public static PaymentResult fail(String paymentMethod, String errorMessage) {
        PaymentResult result = new PaymentResult();
        result.setSuccess(false);
        result.setPaymentMethod(paymentMethod);
        result.setStatus("FAILED");
        result.setErrorMessage(errorMessage);
        return result;
    }
}
