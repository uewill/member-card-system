package com.membercard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 会员卡实例实体
 */
@Data
@TableName("t_member_card")
public class MemberCard {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long tenantId;
    
    private Long memberId;
    
    private Long templateId;
    
    private String templateSnapshot; // JSON 格式
    
    private String remainingCounts; // JSON 格式
    
    private BigDecimal balancePrincipal;
    
    private BigDecimal balanceGift;
    
    private LocalDate validFrom;
    
    private LocalDate validTo;
    
    private String status; // ACTIVE, EXPIRED, USED_UP, FROZEN, TRANSFERRED
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}