package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * 员工实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Employee {
    private Long id;
    private Long tenantId;
    private String name;
    private String phone;
    private String passwordHash;
    /** store_manager/cashier/service_staff */
    private String role;
    /** active/resigned */
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
