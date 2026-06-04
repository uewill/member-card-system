package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.dto.MemberCreateRequest;
import com.membercard.entity.Member;
import com.membercard.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

/**
 * 会员管理控制器
 */
@RestController
@RequestMapping("/api/v1/members")
@Tag(name = "会员管理", description = "会员增删改查接口")
public class MemberController {

    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @GetMapping
    @Operation(summary = "获取所有会员")
    public ApiResponse<List<Member>> findAll() {
        return ApiResponse.success(memberService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取会员详情")
    public ApiResponse<Member> findById(@PathVariable Long id) {
        return ApiResponse.success(memberService.findById(id));
    }

    @GetMapping("/phone/{phone}")
    @Operation(summary = "按手机号查找会员")
    public ApiResponse<Member> findByPhone(@PathVariable String phone) {
        return ApiResponse.success(memberService.findByPhone(phone));
    }

    @GetMapping("/search")
    @Operation(summary = "搜索会员（姓名/手机号）")
    public ApiResponse<List<Member>> search(@RequestParam String keyword) {
        return ApiResponse.success(memberService.search(keyword));
    }

    @PostMapping
    @Operation(summary = "创建会员")
    public ApiResponse<Member> create(@Valid @RequestBody MemberCreateRequest request) {
        return ApiResponse.success(memberService.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新会员信息")
    public ApiResponse<Member> update(@PathVariable Long id, @RequestBody Member member) {
        member.setId(id);
        return ApiResponse.success(memberService.update(member));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除会员")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        memberService.delete(id);
        return ApiResponse.success();
    }
}
