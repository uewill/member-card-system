package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.membercard.entity.PackageTemplate;
import com.membercard.entity.ServiceItem;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.PackageTemplateMapper;
import com.membercard.mapper.ServiceItemMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 行业模板服务 - 查询行业模板、复制模板到新租户
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class IndustryTemplateService {

    private final IndustryTemplateMapper industryTemplateMapper;
    private final ServiceItemMapper serviceItemMapper;
    private final PackageTemplateMapper packageTemplateMapper;

    /**
     * 查询所有行业模板列表
     *
     * @return 行业模板列表（仅包含行业名称，不含详细数据）
     */
    public List<Map<String, Object>> listIndustries() {
        return industryTemplateMapper.selectIndustryList();
    }

    /**
     * 查询指定行业的模板详情
     *
     * @param industry 行业标识（如 HAIRCUT, BEAUTY, FITNESS, CAR_WASH, EDUCATION）
     * @return 模板详情（包含服务项目和套餐模板）
     */
    public Map<String, Object> getTemplateByIndustry(String industry) {
        Map<String, Object> template = industryTemplateMapper.selectByIndustry(industry);
        if (template == null) {
            throw new RuntimeException("行业模板不存在: " + industry);
        }
        return template;
    }

    /**
     * 复制行业模板到新租户
     * 将模板中的服务项目和套餐模板复制到指定租户下
     *
     * @param tenantId  目标租户ID
     * @param industry  行业标识
     * @return 复制结果（服务项目数量、套餐模板数量）
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> copyTemplateToTenant(Long tenantId, String industry) {
        log.info("开始复制行业模板到租户: tenantId={}, industry={}", tenantId, industry);

        // 1. 查询行业模板
        Map<String, Object> template = getTemplateByIndustry(industry);

        // 2. 解析并复制服务项目
        String serviceItemsJson = (String) template.get("service_items");
        List<Map<String, Object>> serviceItems = parseJsonArray(serviceItemsJson);
        int serviceItemCount = 0;

        for (Map<String, Object> item : serviceItems) {
            ServiceItem serviceItem = new ServiceItem();
            serviceItem.setTenantId(tenantId);
            serviceItem.setCategory((String) item.get("category"));
            serviceItem.setName((String) item.get("name"));
            serviceItem.setPrice(new BigDecimal(item.get("price").toString()));
            serviceItem.setDuration(((Number) item.get("duration")).intValue());
            serviceItem.setCanSinglePurchase(((Number) item.get("canSinglePurchase")).intValue());
            serviceItem.setStatus(1);

            serviceItemMapper.insert(serviceItem);
            serviceItemCount++;
        }

        // 3. 解析并复制套餐模板
        String packageTemplatesJson = (String) template.get("package_templates");
        List<Map<String, Object>> packageTemplates = parseJsonArray(packageTemplatesJson);
        int packageTemplateCount = 0;

        for (Map<String, Object> pkg : packageTemplates) {
            PackageTemplate packageTemplate = new PackageTemplate();
            packageTemplate.setTenantId(tenantId);
            packageTemplate.setName((String) pkg.get("name"));
            packageTemplate.setType((String) pkg.get("type"));
            packageTemplate.setSalePrice(new BigDecimal(pkg.get("salePrice").toString()));
            packageTemplate.setValidityDays(((Number) pkg.get("validityDays")).intValue());
            packageTemplate.setAllowTransfer(((Number) pkg.get("allowTransfer")).intValue());
            packageTemplate.setAllowCombine(((Number) pkg.get("allowCombine")).intValue());
            packageTemplate.setStatus(1);

            // config 保持 JSON 格式
            packageTemplate.setConfig(pkg.get("config").toString());

            packageTemplateMapper.insert(packageTemplate);
            packageTemplateCount++;
        }

        log.info("模板复制完成: tenantId={}, industry={}, serviceItems={}, packages={}",
                tenantId, industry, serviceItemCount, packageTemplateCount);

        return Map.of(
                "tenantId", tenantId,
                "industry", industry,
                "serviceItemCount", serviceItemCount,
                "packageTemplateCount", packageTemplateCount
        );
    }

    /**
     * 解析 JSON 数组字符串为 List<Map>
     * 简化实现，实际项目中建议使用 Jackson 或 Fastjson
     */
    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> parseJsonArray(String json) {
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            return mapper.readValue(json, List.class);
        } catch (Exception e) {
            log.error("解析 JSON 失败: {}", json, e);
            throw new RuntimeException("解析模板数据失败");
        }
    }
}
