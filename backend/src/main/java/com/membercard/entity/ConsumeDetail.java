package com.membercard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 消费明细实体
 */
@Data
@TableName("t_consume_detail")
public class ConsumeDetail {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long tenantId;
    
    private Long orderId;
    
    private Long serviceItemId;
    
    private String serviceItemName;
    
    private Long serviceStaffId;
    
    private String serviceStaffName;
    
    private BigDecimal performanceRatio;
    
    private Long cardId;
    
    private String deductType; // COUNT, VALUE
    
    private String deductBefore;
    
    private String deductAfter;
    
    private BigDecimal deductAmount;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}