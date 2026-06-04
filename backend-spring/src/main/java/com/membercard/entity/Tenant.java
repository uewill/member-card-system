package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * 租户实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Tenant {
    private Long id;
    private String companyName;
    private String industryTag;
    private String adminContact;
    private String adminPhone;
    /** pending/approved/rejected/disabled */
    private String status;
    /** 支持的支付方式JSON */
    private String paymentMethods;
    /** 是否启用积分 */
    private Integer pointsEnabled;
    /** 版本限制 */
    private Integer versionLimit;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
