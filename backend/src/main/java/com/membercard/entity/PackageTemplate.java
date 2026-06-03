package com.membercard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 次卡套餐模板实体
 */
@Data
@TableName("t_package_template")
public class PackageTemplate {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long tenantId;
    
    private String name;
    
    private String type; // COUNT, VALUE, MIXED
    
    private String config; // JSON 格式
    
    private BigDecimal salePrice;
    
    private Integer validityDays;
    
    private LocalDate validityEndDate;
    
    private Integer allowTransfer;
    
    private Integer allowCombine;
    
    private Integer status;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}