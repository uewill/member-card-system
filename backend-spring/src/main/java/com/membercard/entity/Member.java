package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 会员实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Member {
    private Long id;
    private Long tenantId;
    private String name;
    private String phone;
    private LocalDate birthday;
    /** 标签JSON */
    private String tagsJson;
    /** 来源渠道 */
    private String sourceChannel;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
