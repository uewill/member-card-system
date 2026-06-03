package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.entity.Member;
import com.membercard.entity.MemberCard;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.MemberCardMapper;
import com.membercard.mapper.MemberMapper;
import javax.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 会员服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberMapper memberMapper;
    private final MemberCardMapper memberCardMapper;

    /**
     * 创建会员
     */
    public Member create(Member member) {
        Long tenantId = TenantContextHolder.getTenantId();
        member.setTenantId(tenantId);
        member.setStatus(1);
        member.setCreatedAt(LocalDateTime.now());
        member.setUpdatedAt(LocalDateTime.now());
        memberMapper.insert(member);
        return member;
    }

    /**
     * 更新会员信息
     */
    public Member update(Member member) {
        member.setUpdatedAt(LocalDateTime.now());
        memberMapper.updateById(member);
        return memberMapper.selectById(member.getId());
    }

    /**
     * 根据ID获取会员
     */
    public Member getById(Long id) {
        return memberMapper.selectById(id);
    }

    /**
     * 分页查询会员列表
     */
    public Page<Member> page(Integer current, Integer size, String phone, String name, String tags, Integer status) {
        Page<Member> page = new Page<>(current, size);
        LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
        if (phone != null && !phone.isEmpty()) {
            wrapper.like(Member::getPhone, phone);
        }
        if (name != null && !name.isEmpty()) {
            wrapper.like(Member::getName, name);
        }
        if (tags != null && !tags.isEmpty()) {
            wrapper.like(Member::getTags, tags);
        }
        if (status != null) {
            wrapper.eq(Member::getStatus, status);
        }
        wrapper.orderByDesc(Member::getCreatedAt);
        return memberMapper.selectPage(page, wrapper);
    }

    /**
     * 根据手机号搜索会员
     */
    public List<Member> searchByPhone(String phone) {
        return memberMapper.selectList(
                new LambdaQueryWrapper<Member>()
                        .like(Member::getPhone, phone)
                        .orderByDesc(Member::getCreatedAt));
    }

    /**
     * 导出会员列表为Excel
     */
    public void export(String phone, String name, String tags, HttpServletResponse response) {
        LambdaQueryWrapper<Member> wrapper = new LambdaQueryWrapper<>();
        if (phone != null && !phone.isEmpty()) {
            wrapper.like(Member::getPhone, phone);
        }
        if (name != null && !name.isEmpty()) {
            wrapper.like(Member::getName, name);
        }
        if (tags != null && !tags.isEmpty()) {
            wrapper.like(Member::getTags, tags);
        }
        wrapper.orderByDesc(Member::getCreatedAt);
        List<Member> members = memberMapper.selectList(wrapper);

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("会员列表");
            // 创建表头
            Row headerRow = sheet.createRow(0);
            String[] headers = {"手机号", "姓名", "生日", "标签", "来源渠道", "状态", "注册时间"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
            }

            // 填充数据
            int rowNum = 1;
            for (Member member : members) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(member.getPhone() != null ? member.getPhone() : "");
                row.createCell(1).setCellValue(member.getName() != null ? member.getName() : "");
                row.createCell(2).setCellValue(member.getBirthday() != null ? member.getBirthday().toString() : "");
                row.createCell(3).setCellValue(member.getTags() != null ? member.getTags() : "");
                row.createCell(4).setCellValue(member.getSourceChannel() != null ? member.getSourceChannel() : "");
                row.createCell(5).setCellValue(member.getStatus() != null ? (member.getStatus() == 1 ? "正常" : "停用") : "");
                row.createCell(6).setCellValue(member.getCreatedAt() != null ? member.getCreatedAt().toString() : "");
            }

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition",
                    "attachment;filename=" + URLEncoder.encode("会员列表.xlsx", StandardCharsets.UTF_8));
            workbook.write(response.getOutputStream());
        } catch (IOException e) {
            log.error("导出会员列表失败", e);
            throw new RuntimeException("导出失败: " + e.getMessage());
        }
    }

    /**
     * 获取会员统计信息
     */
    public Map<String, Object> getMemberStats() {
        Map<String, Object> stats = new HashMap<>();
        long totalMembers = memberMapper.selectCount(null);
        long activeMembers = memberMapper.selectCount(
                new LambdaQueryWrapper<Member>().eq(Member::getStatus, 1));
        long activeCards = memberCardMapper.selectCount(
                new LambdaQueryWrapper<MemberCard>().eq(MemberCard::getStatus, "ACTIVE"));
        stats.put("totalMembers", totalMembers);
        stats.put("activeMembers", activeMembers);
        stats.put("inactiveMembers", totalMembers - activeMembers);
        stats.put("activeCards", activeCards);
        return stats;
    }
}
