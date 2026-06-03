package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 优惠券管理控制器
 */
@RestController
@RequestMapping("/api/coupon")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;

    /**
     * 创建优惠券
     */
    @PostMapping
    public ApiResponse<Void> create(@RequestBody Map<String, Object> coupon) {
        couponService.create(coupon);
        return ApiResponse.success();
    }

    /**
     * 更新优惠券
     */
    @PutMapping("/{id}")
    public ApiResponse<Void> update(@PathVariable Long id, @RequestBody Map<String, Object> coupon) {
        couponService.update(id, coupon);
        return ApiResponse.success();
    }

    /**
     * 获取优惠券详情
     */
    @GetMapping("/{id}")
    public ApiResponse<Map<String, Object>> getById(@PathVariable Long id) {
        Map<String, Object> coupon = couponService.getById(id);
        return ApiResponse.success(coupon);
    }

    /**
     * 分页查询优惠券列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<Map<String, Object>>> page(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) Integer status) {
        Page<Map<String, Object>> page = couponService.page(current, size, type, status);
        return ApiResponse.success(page);
    }

    /**
     * 发放优惠券给会员
     */
    @PostMapping("/distribute")
    public ApiResponse<Void> distribute(@RequestBody Map<String, Object> request) {
        Long couponId = Long.valueOf(request.get("couponId").toString());
        @SuppressWarnings("unchecked")
        List<Long> memberIds = (List<Long>) request.get("memberIds");
        couponService.distribute(couponId, memberIds);
        return ApiResponse.success();
    }

    /**
     * 查询会员的优惠券列表
     */
    @GetMapping("/member/{memberId}")
    public ApiResponse<List<Map<String, Object>>> memberCoupons(@PathVariable Long memberId) {
        List<Map<String, Object>> coupons = couponService.getMemberCoupons(memberId);
        return ApiResponse.success(coupons);
    }

    /**
     * 启用/停用优惠券
     */
    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        couponService.updateStatus(id, status);
        return ApiResponse.success();
    }
}
