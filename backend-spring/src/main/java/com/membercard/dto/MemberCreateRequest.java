package com.membercard.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.List;

/**
 * 会员创建请求
 */
@Data
public class MemberCreateRequest {

    @NotBlank(message = "会员姓名不能为空")
    private String name;

    @NotBlank(message = "手机号不能为空")
    private String phone;

    private LocalDate birthday;

    /** 标签列表 */
    private List<String> tags;

    /** 来源渠道 */
    private String sourceChannel;
}
