package com.membercard.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

/**
 * 消费请求
 */
@Data
public class ConsumeRequest {

    @NotNull(message = "门店ID不能为空")
    private Long storeId;

    @NotNull(message = "会员ID不能为空")
    private Long memberId;

    /** 操作员工ID */
    private Long employeeId;

    /** 消费明细列表 */
    private List<ConsumeItemRequest> items;

    /** 支付方式列表 */
    private List<String> paymentMethods;

    @Data
    public static class ConsumeItemRequest {
        /** 服务项目ID */
        private Long serviceItemId;

        /** 使用的卡ID */
        private Long cardId;

        /** 扣减类型: count/balance */
        private String deductionType;

        /** 扣减次数 */
        private Integer deductionCount;

        /** 扣减金额 */
        private BigDecimal deductionAmount;

        /** 员工业绩分配 [{"employeeId":1,"ratio":1.0}] */
        private List<EmployeeRatio> employeeRatios;
    }

    @Data
    public static class EmployeeRatio {
        private Long employeeId;
        private BigDecimal ratio;
    }
}
