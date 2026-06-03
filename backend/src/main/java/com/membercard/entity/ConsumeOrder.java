package com.membercard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 消费订单实体
 */
@Data
@TableName("t_consume_order")
public class ConsumeOrder {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long tenantId;
    
    private Long storeId;
    
    private Long memberId;
    
    private String orderNo;
    
    private BigDecimal totalAmount;
    
    private BigDecimal paidAmount;
    
    private String paymentDetail; // JSON 格式
    
    private String status; // COMPLETED, CANCELLED
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}