package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.entity.Member;
import com.membercard.service.MemberService;
import javax.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 会员管理控制器
 */
@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    /**
     * 创建会员
     */
    @PostMapping
    public ApiResponse<Member> create(@RequestBody Member member) {
        Member created = memberService.create(member);
        return ApiResponse.success(created);
    }

    /**
     * 更新会员信息
     */
    @PutMapping("/{id}")
    public ApiResponse<Member> update(@PathVariable Long id, @RequestBody Member member) {
        member.setId(id);
        Member updated = memberService.update(member);
        return ApiResponse.success(updated);
    }

    /**
     * 获取会员详情
     */
    @GetMapping("/{id}")
    public ApiResponse<Member> getById(@PathVariable Long id) {
        Member member = memberService.getById(id);
        return ApiResponse.success(member);
    }

    /**
     * 分页查询会员列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<Member>> page(@RequestParam(defaultValue = "1") Integer current,
                                           @RequestParam(defaultValue = "10") Integer size,
                                           @RequestParam(required = false) String phone,
                                           @RequestParam(required = false) String name,
                                           @RequestParam(required = false) String tags,
                                           @RequestParam(required = false) Integer status) {
        Page<Member> page = memberService.page(current, size, phone, name, tags, status);
        return ApiResponse.success(page);
    }

    /**
     * 导出会员列表
     */
    @GetMapping("/export")
    public void export(@RequestParam(required = false) String phone,
                        @RequestParam(required = false) String name,
                        @RequestParam(required = false) String tags,
                        HttpServletResponse response) {
        memberService.export(phone, name, tags, response);
    }

    /**
     * 获取会员统计信息
     */
    @GetMapping("/stats")
    public ApiResponse<Map<String, Object>> stats() {
        Map<String, Object> stats = memberService.getMemberStats();
        return ApiResponse.success(stats);
    }

    /**
     * 根据手机号查询会员
     */
    @GetMapping("/search")
    public ApiResponse<List<Member>> searchByPhone(@RequestParam String phone) {
        List<Member> list = memberService.searchByPhone(phone);
        return ApiResponse.success(list);
    }
}
