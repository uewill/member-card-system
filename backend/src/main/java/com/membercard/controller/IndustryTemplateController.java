package com.membercard.controller;

import com.membercard.dto.ApiResponse;
import com.membercard.service.IndustryTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 行业模板接口 - 查询模板列表、获取模板详情、复制模板到租户
 */
@RestController
@RequestMapping("/api/industry-template")
@RequiredArgsConstructor
public class IndustryTemplateController {

    private final IndustryTemplateService industryTemplateService;

    /**
     * 查询所有行业模板列表
     * 返回行业标识列表，供租户注册时选择
     *
     * GET /api/industry-template/industries
     */
    @GetMapping("/industries")
    public ApiResponse<List<Map<String, Object>>> listIndustries() {
        List<Map<String, Object>> industries = industryTemplateService.listIndustries();
        return ApiResponse.success(industries);
    }

    /**
     * 获取指定行业的模板详情
     * 包含服务项目列表和推荐套餐模板
     *
     * GET /api/industry-template/{industry}
     *
     * @param industry 行业标识（HAIRCUT/BEAUTY/FITNESS/CAR_WASH/EDUCATION）
     */
    @GetMapping("/{industry}")
    public ApiResponse<Map<String, Object>> getTemplate(@PathVariable String industry) {
        Map<String, Object> template = industryTemplateService.getTemplateByIndustry(industry);
        return ApiResponse.success(template);
    }

    /**
     * 复制行业模板到指定租户
     * 将行业模板中的服务项目和套餐模板复制到目标租户下
     * 通常在租户注册/初始化时调用
     *
     * POST /api/industry-template/copy
     *
     * 请求体:
     * {
     *   "tenantId": 1,
     *   "industry": "HAIRCUT"
     * }
     */
    @PostMapping("/copy")
    public ApiResponse<Map<String, Object>> copyToTenant(@RequestBody Map<String, Object> request) {
        Long tenantId = Long.valueOf(request.get("tenantId").toString());
        String industry = (String) request.get("industry");

        Map<String, Object> result = industryTemplateService.copyTemplateToTenant(tenantId, industry);
        return ApiResponse.success(result);
    }
}
