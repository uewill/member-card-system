package com.membercard.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 消费结果DTO
 */
@Data
public class ConsumeResult {

    /**
     * 消费订单ID
     */
    private Long orderId;

    /**
     * 订单号
     */
    private String orderNo;

    /**
     * 总金额
     */
    private BigDecimal totalAmount;

    /**
     * 实付金额
     */
    private BigDecimal paidAmount;

    /**
     * 现金补齐金额
     */
    private BigDecimal cashAmount;

    /**
     * 消费明细列表
     */
    private java.util.List<ConsumeDetailResult> details;

    /**
     * 消费状态
     */
    private String status;

    @Data
    public static class ConsumeDetailResult {
        /**
         * 服务项目ID
         */
        private Long serviceItemId;

        /**
         * 服务项目名称
         */
        private String serviceItemName;

        /**
         * 卡实例ID
         */
        private Long cardId;

        /**
         * 扣减类型: COUNT, VALUE
         */
        private String deductType;

        /**
         * 扣减前数值
         */
        private String deductBefore;

        /**
         * 扣减后数值
         */
        private String deductAfter;

        /**
         * 扣减金额
         */
        private BigDecimal deductAmount;
    }
}
