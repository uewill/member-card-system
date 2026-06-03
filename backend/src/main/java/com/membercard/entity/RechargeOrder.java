package com.membercard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 充值/购卡订单实体
 */
@Data
@TableName("t_recharge_order")
public class RechargeOrder {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long tenantId;
    
    private Long storeId;
    
    private Long memberId;
    
    private String orderNo;
    
    private String orderType; // PURCHASE, RECHARGE
    
    private Long templateId;
    
    private Long cardId;
    
    private BigDecimal amount;
    
    private BigDecimal giftAmount;
    
    private String paymentMethod; // WECHAT, ALIPAY, CASH
    
    private String paymentStatus; // PENDING, SUCCESS, FAILED, CLOSED
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}