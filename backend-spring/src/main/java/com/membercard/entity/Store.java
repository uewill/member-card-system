package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * 门店实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Store {
    private Long id;
    private Long tenantId;
    private String name;
    private String address;
    private String phone;
    private String businessHours;
    /** enabled/disabled */
    private String status;
    /** 允许使用的卡类型JSON */
    private String allowedCardUsage;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
