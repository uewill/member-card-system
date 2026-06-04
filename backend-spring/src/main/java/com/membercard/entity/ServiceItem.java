package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * 服务项目实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ServiceItem {
    private Long id;
    private Long tenantId;
    private String name;
    private String category;
    private java.math.BigDecimal price;
    /** 时长(分钟) */
    private Integer duration;
    /** 是否可单独购买 */
    private Integer purchasableAlone;
    /** enabled/disabled */
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
