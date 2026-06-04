package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.dto.MemberCreateRequest;
import com.membercard.entity.Member;
import com.membercard.mapper.MemberMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 会员服务
 */
@Service
public class MemberService {

    private final MemberMapper memberMapper;
    private final ObjectMapper objectMapper;

    public MemberService(MemberMapper memberMapper, ObjectMapper objectMapper) {
        this.memberMapper = memberMapper;
        this.objectMapper = objectMapper;
    }

    public Member findById(Long id) {
        Long tenantId = TenantContext.getTenantId();
        Member member = memberMapper.findById(id, tenantId);
        if (member == null) {
            throw new BusinessException(404, "会员不存在");
        }
        return member;
    }

    public List<Member> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return memberMapper.findByTenantId(tenantId);
    }

    public Member findByPhone(String phone) {
        Long tenantId = TenantContext.getTenantId();
        return memberMapper.findByPhone(phone, tenantId);
    }

    public List<Member> search(String keyword) {
        Long tenantId = TenantContext.getTenantId();
        return memberMapper.searchByName(tenantId, keyword);
    }

    public Member create(MemberCreateRequest request) {
        Long tenantId = TenantContext.getTenantId();

        // 检查手机号是否已存在
        Member existing = memberMapper.findByPhone(request.getPhone(), tenantId);
        if (existing != null) {
            throw new BusinessException(400, "该手机号已注册");
        }

        Member member = new Member();
        member.setTenantId(tenantId);
        member.setName(request.getName());
        member.setPhone(request.getPhone());
        member.setBirthday(request.getBirthday());
        member.setSourceChannel(request.getSourceChannel());

        // 转换 tags 列表为 JSON
        try {
            if (request.getTags() != null && !request.getTags().isEmpty()) {
                member.setTagsJson(objectMapper.writeValueAsString(request.getTags()));
            }
        } catch (Exception e) {
            throw new BusinessException(500, "标签格式错误");
        }

        memberMapper.insert(member);
        return member;
    }

    public Member update(Member member) {
        Long tenantId = TenantContext.getTenantId();
        Member existing = findById(member.getId());
        existing.setName(member.getName());
        existing.setPhone(member.getPhone());
        existing.setBirthday(member.getBirthday());
        existing.setTagsJson(member.getTagsJson());
        existing.setSourceChannel(member.getSourceChannel());
        memberMapper.update(existing);
        return existing;
    }

    public void delete(Long id) {
        Long tenantId = TenantContext.getTenantId();
        memberMapper.deleteById(id, tenantId);
    }
}
