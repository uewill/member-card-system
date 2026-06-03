package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.membercard.dto.CardMatchResult;
import com.membercard.entity.MemberCard;
import com.membercard.entity.PackageTemplate;
import com.membercard.entity.ServiceItem;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.MemberCardMapper;
import com.membercard.mapper.PackageTemplateMapper;
import com.membercard.mapper.ServiceItemMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 卡实例服务 - 卡实例生成、状态管理、最优卡匹配算法
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CardService {

    private final MemberCardMapper memberCardMapper;
    private final PackageTemplateMapper packageTemplateMapper;
    private final ServiceItemMapper serviceItemMapper;
    private final ObjectMapper objectMapper;

    /**
     * 根据ID获取卡实例
     */
    public MemberCard getById(Long id) {
        return memberCardMapper.selectById(id);
    }

    /**
     * 分页查询会员的卡实例列表
     */
    public Page<MemberCard> page(Long memberId, Integer current, Integer size, String status) {
        Page<MemberCard> page = new Page<>(current, size);
        LambdaQueryWrapper<MemberCard> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MemberCard::getMemberId, memberId);
        if (status != null && !status.isEmpty()) {
            wrapper.eq(MemberCard::getStatus, status);
        }
        wrapper.orderByDesc(MemberCard::getCreatedAt);
        return memberCardMapper.selectPage(page, wrapper);
    }

    /**
     * 获取会员的所有有效卡列表
     */
    public List<MemberCard> listActiveCards(Long memberId) {
        return memberCardMapper.selectList(
                new LambdaQueryWrapper<MemberCard>()
                        .eq(MemberCard::getMemberId, memberId)
                        .eq(MemberCard::getStatus, "ACTIVE")
                        .ge(MemberCard::getValidTo, LocalDate.now())
                        .orderByAsc(MemberCard::getValidTo));
    }

    /**
     * 冻结/解冻卡实例
     */
    public void freeze(Long id, String action) {
        MemberCard card = memberCardMapper.selectById(id);
        if (card == null) {
            throw new RuntimeException("卡实例不存在");
        }
        if ("freeze".equals(action)) {
            card.setStatus("FROZEN");
        } else if ("unfreeze".equals(action)) {
            card.setStatus("ACTIVE");
        } else {
            throw new RuntimeException("无效操作: " + action);
        }
        memberCardMapper.updateById(card);
    }

    /**
     * 最优卡匹配算法
     * 根据会员ID+服务项目检索有效卡 -> 按先到期优先排序 -> 依次扣减
     */
    public List<CardMatchResult> matchCards(Long memberId, Long serviceItemId) {
        // 1. 查询服务项目信息
        ServiceItem serviceItem = serviceItemMapper.selectById(serviceItemId);
        if (serviceItem == null) {
            throw new RuntimeException("服务项目不存在");
        }

        // 2. 查询会员所有有效卡
        List<MemberCard> activeCards = listActiveCards(memberId);
        if (activeCards.isEmpty()) {
            return Collections.emptyList();
        }

        // 3. 遍历每张卡，判断是否适用该服务项目
        List<CardMatchResult> results = new ArrayList<>();
        LocalDate now = LocalDate.now();

        for (MemberCard card : activeCards) {
            CardMatchResult matchResult = evaluateCard(card, serviceItem, now);
            if (matchResult.getApplicable()) {
                results.add(matchResult);
            }
        }

        // 4. 按优先级排序（先到期优先，即 validTo 越小越优先）
        results.sort(Comparator.comparingInt(CardMatchResult::getPriorityScore));

        return results;
    }

    /**
     * 评估单张卡是否适用于指定服务项目
     */
    private CardMatchResult evaluateCard(MemberCard card, ServiceItem serviceItem, LocalDate now) {
        CardMatchResult result = new CardMatchResult();
        result.setCardId(card.getId());
        result.setTemplateId(card.getTemplateId());
        result.setRemainingPrincipal(card.getBalancePrincipal());
        result.setRemainingGift(card.getBalanceGift());
        result.setRemainingTotalBalance(
                card.getBalancePrincipal().add(card.getBalanceGift()));
        result.setValidTo(card.getValidTo());

        try {
            // 解析模板快照
            Map<String, Object> snapshot = objectMapper.readValue(
                    card.getTemplateSnapshot(), new TypeReference<>() {});
            result.setTemplateName((String) snapshot.get("name"));
            result.setCardType((String) snapshot.get("type"));

            // 解析套餐配置，检查是否包含该服务项目
            String configJson = (String) snapshot.get("config");
            if (configJson != null) {
                Map<String, Object> config = objectMapper.readValue(configJson, new TypeReference<>() {});
                Object serviceItemsObj = config.get("serviceItems");
                if (serviceItemsObj instanceof List) {
                    List<Map<String, Object>> items = (List<Map<String, Object>>) serviceItemsObj;
                    for (Map<String, Object> item : items) {
                        if (serviceItem.getId().toString().equals(item.get("serviceItemId").toString())) {
                            result.setApplicable(true);
                            result.setDeductAmountPerUse(new BigDecimal(item.get("deductAmountPerUse").toString()));

                            // 判断扣减类型
                            String cardType = result.getCardType();
                            if ("COUNT".equals(cardType)) {
                                result.setSuggestedDeductType("COUNT");
                                // 从 remainingCounts 中获取该服务项目的剩余次数
                                int remainingCount = getRemainingCountForService(card.getRemainingCounts(),
                                        serviceItem.getId());
                                result.setRemainingCount(remainingCount);
                            } else if ("VALUE".equals(cardType)) {
                                result.setSuggestedDeductType("VALUE");
                            } else if ("MIXED".equals(cardType)) {
                                // 混合卡优先扣次数
                                int remainingCount = getRemainingCountForService(card.getRemainingCounts(),
                                        serviceItem.getId());
                                if (remainingCount > 0) {
                                    result.setSuggestedDeductType("COUNT");
                                    result.setRemainingCount(remainingCount);
                                } else {
                                    result.setSuggestedDeductType("VALUE");
                                }
                            }
                            break;
                        }
                    }
                }
            }

            if (!result.getApplicable()) {
                // 如果没有找到匹配的服务项目，检查是否为通用储值卡
                if ("VALUE".equals(result.getCardType()) || "MIXED".equals(result.getCardType())) {
                    result.setApplicable(true);
                    result.setSuggestedDeductType("VALUE");
                    result.setDeductAmountPerUse(serviceItem.getPrice());
                }
            }

        } catch (Exception e) {
            log.error("解析卡模板快照失败: cardId={}", card.getId(), e);
            result.setApplicable(false);
        }

        // 计算优先级分数（到期天数越少越优先）
        long daysToExpire = java.time.temporal.ChronoUnit.DAYS.between(now, card.getValidTo());
        result.setPriorityScore((int) Math.max(0, daysToExpire));

        return result;
    }

    /**
     * 从 remainingCounts JSON 中获取指定服务项目的剩余次数
     */
    private int getRemainingCountForService(String remainingCountsJson, Long serviceItemId) {
        if (remainingCountsJson == null || remainingCountsJson.isEmpty()) {
            return 0;
        }
        try {
            Map<String, Object> counts = objectMapper.readValue(remainingCountsJson, new TypeReference<>() {});
            Object countObj = counts.get(serviceItemId.toString());
            if (countObj != null) {
                return Integer.parseInt(countObj.toString());
            }
        } catch (Exception e) {
            log.error("解析剩余次数JSON失败", e);
        }
        return 0;
    }

    /**
     * 获取卡实例统计
     */
    public Map<String, Object> getCardStats() {
        Map<String, Object> stats = new HashMap<>();
        long totalCards = memberCardMapper.selectCount(null);
        long activeCards = memberCardMapper.selectCount(
                new LambdaQueryWrapper<MemberCard>().eq(MemberCard::getStatus, "ACTIVE"));
        long frozenCards = memberCardMapper.selectCount(
                new LambdaQueryWrapper<MemberCard>().eq(MemberCard::getStatus, "FROZEN"));
        long expiredCards = memberCardMapper.selectCount(
                new LambdaQueryWrapper<MemberCard>().eq(MemberCard::getStatus, "EXPIRED"));
        stats.put("totalCards", totalCards);
        stats.put("activeCards", activeCards);
        stats.put("frozenCards", frozenCards);
        stats.put("expiredCards", expiredCards);
        return stats;
    }
}
