package com.membercard.dto;

import javax.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 消费核销请求DTO
 */
@Data
public class ConsumeRequest {

    @NotNull(message = "会员ID不能为空")
    private Long memberId;

    @NotNull(message = "服务项目ID不能为空")
    private Long serviceItemId;

    /**
     * 指定使用的卡实例ID（可选，不传则自动匹配最优卡）
     */
    private Long cardId;

    /**
     * 服务人员ID（可选）
     */
    private Long serviceStaffId;

    /**
     * 服务人员姓名（可选，用于快照）
     */
    private String serviceStaffName;

    /**
     * 业绩分摊比例（可选，默认1.00）
     */
    private BigDecimal performanceRatio;

    /**
     * 门店ID
     */
    @NotNull(message = "门店ID不能为空")
    private Long storeId;

    /**
     * 多卡组合支付明细（JSON格式）
     * 格式示例: [{"cardId": 1, "deductType": "COUNT", "deductAmount": 1}, {"cardId": 2, "deductType": "VALUE", "deductAmount": 50.00}]
     * 最后一项可以是现金补齐: [{"cardId": 1, "deductType": "VALUE", "deductAmount": 80.00}, {"deductType": "CASH", "deductAmount": 20.00}]
     */
    private String paymentItems;
}
