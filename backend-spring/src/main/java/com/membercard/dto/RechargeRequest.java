package com.membercard.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

/**
 * 充值请求
 */
@Data
public class RechargeRequest {

    @NotNull(message = "会员ID不能为空")
    private Long memberId;

    @NotNull(message = "充值金额不能为空")
    private BigDecimal amount;

    /** 支付方式 */
    private String paymentMethod;

    /** 门店ID */
    private Long storeId;

    /** 备注 */
    private String remark;
}
