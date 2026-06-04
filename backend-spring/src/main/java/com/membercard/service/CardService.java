package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.entity.MemberCard;
import com.membercard.entity.PackageTemplate;
import com.membercard.mapper.MemberCardMapper;
import com.membercard.mapper.PackageTemplateMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * 会员卡服务
 */
@Service
public class CardService {

    private final MemberCardMapper memberCardMapper;
    private final PackageTemplateMapper packageTemplateMapper;
    private final ObjectMapper objectMapper;

    public CardService(MemberCardMapper memberCardMapper, PackageTemplateMapper packageTemplateMapper,
                       ObjectMapper objectMapper) {
        this.memberCardMapper = memberCardMapper;
        this.packageTemplateMapper = packageTemplateMapper;
        this.objectMapper = objectMapper;
    }

    public MemberCard findById(Long id) {
        Long tenantId = TenantContext.getTenantId();
        MemberCard card = memberCardMapper.findById(id, tenantId);
        if (card == null) {
            throw new BusinessException(404, "会员卡不存在");
        }
        return card;
    }

    public List<MemberCard> findByMemberId(Long memberId) {
        Long tenantId = TenantContext.getTenantId();
        return memberCardMapper.findByMemberId(memberId, tenantId);
    }

    public List<MemberCard> findActiveByMemberId(Long memberId) {
        Long tenantId = TenantContext.getTenantId();
        return memberCardMapper.findByMemberIdAndStatus(memberId, tenantId, "active");
    }

    public List<MemberCard> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return memberCardMapper.findByTenantId(tenantId);
    }

    /**
     * 售卡：根据套餐模板创建会员卡实例
     */
    @Transactional
    public MemberCard sellCard(Long memberId, Long packageId) {
        Long tenantId = TenantContext.getTenantId();

        // 查找套餐模板
        PackageTemplate pkg = packageTemplateMapper.findById(packageId, tenantId);
        if (pkg == null) {
            throw new BusinessException(404, "套餐不存在");
        }

        // 创建会员卡实例
        MemberCard card = new MemberCard();
        card.setTenantId(tenantId);
        card.setMemberId(memberId);
        card.setType(pkg.getType());
        card.setRemainingCountsJson(pkg.getServiceCountsJson());
        card.setPrincipalBalance(pkg.getPrincipalAmount());
        card.setBonusBalance(pkg.getBonusAmount());
        card.setStatus("active");

        // 计算到期日
        if ("days".equals(pkg.getValidityType()) && pkg.getValidityDays() != null) {
            card.setExpiryDate(LocalDate.now().plusDays(pkg.getValidityDays()));
        } else if ("fixed_date".equals(pkg.getValidityType())) {
            card.setExpiryDate(pkg.getExpiryDate());
        }

        // 生成卡号
        card.setCardNo(generateCardNo());

        // 保存套餐快照
        try {
            String snapshot = objectMapper.writeValueAsString(pkg);
            card.setPackageSnapshotJson(snapshot);
        } catch (Exception e) {
            throw new BusinessException(500, "套餐快照生成失败");
        }

        memberCardMapper.insert(card);
        return card;
    }

    /**
     * 充值：为储值卡充值
     */
    @Transactional
    public MemberCard recharge(Long cardId, java.math.BigDecimal amount) {
        Long tenantId = TenantContext.getTenantId();
        MemberCard card = memberCardMapper.findById(cardId, tenantId);
        if (card == null) {
            throw new BusinessException(404, "会员卡不存在");
        }
        if (!"active".equals(card.getStatus())) {
            throw new BusinessException(400, "会员卡状态异常，无法充值");
        }

        card.setPrincipalBalance(card.getPrincipalBalance().add(amount));
        memberCardMapper.update(card);
        return card;
    }

    /**
     * 冻结会员卡
     */
    public void freeze(Long cardId) {
        Long tenantId = TenantContext.getTenantId();
        MemberCard card = memberCardMapper.findById(cardId, tenantId);
        if (card == null) {
            throw new BusinessException(404, "会员卡不存在");
        }
        card.setStatus("frozen");
        memberCardMapper.update(card);
    }

    /**
     * 解冻会员卡
     */
    public void unfreeze(Long cardId) {
        Long tenantId = TenantContext.getTenantId();
        MemberCard card = memberCardMapper.findById(cardId, tenantId);
        if (card == null) {
            throw new BusinessException(404, "会员卡不存在");
        }
        card.setStatus("active");
        memberCardMapper.update(card);
    }

    private String generateCardNo() {
        return "MC" + System.currentTimeMillis() + String.format("%04d", (int)(Math.random() * 10000));
    }
}
