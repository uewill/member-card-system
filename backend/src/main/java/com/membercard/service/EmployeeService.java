package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.entity.User;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 员工服务
 */
@Service
@RequiredArgsConstructor
public class EmployeeService {

    private final UserMapper userMapper;

    /**
     * 创建员工
     */
    public User create(User user) {
        Long tenantId = TenantContextHolder.getTenantId();
        user.setTenantId(tenantId);
        user.setPassword(new BCryptPasswordEncoder().encode("123456"));
        user.setStatus(1);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        userMapper.insert(user);
        // 返回时不带密码
        user.setPassword(null);
        return user;
    }

    /**
     * 更新员工信息
     */
    public User update(User user) {
        user.setUpdatedAt(LocalDateTime.now());
        // 不允许通过此接口修改密码
        user.setPassword(null);
        userMapper.updateById(user);
        User updated = userMapper.selectById(user.getId());
        updated.setPassword(null);
        return updated;
    }

    /**
     * 根据ID获取员工
     */
    public User getById(Long id) {
        User user = userMapper.selectById(id);
        if (user != null) {
            user.setPassword(null);
        }
        return user;
    }

    /**
     * 分页查询员工列表
     */
    public Page<User> page(Integer current, Integer size, Long storeId, String role, String name, Integer status) {
        Page<User> page = new Page<>(current, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (storeId != null) {
            wrapper.eq(User::getStoreId, storeId);
        }
        if (role != null && !role.isEmpty()) {
            wrapper.eq(User::getRole, role);
        }
        if (name != null && !name.isEmpty()) {
            wrapper.like(User::getName, name);
        }
        if (status != null) {
            wrapper.eq(User::getStatus, status);
        }
        wrapper.orderByDesc(User::getCreatedAt);
        Page<User> result = userMapper.selectPage(page, wrapper);
        // 清除密码
        result.getRecords().forEach(u -> u.setPassword(null));
        return result;
    }

    /**
     * 获取所有启用的员工列表
     */
    public List<User> listActive(Long storeId) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getStatus, 1);
        if (storeId != null) {
            wrapper.eq(User::getStoreId, storeId);
        }
        wrapper.orderByAsc(User::getName);
        List<User> list = userMapper.selectList(wrapper);
        list.forEach(u -> u.setPassword(null));
        return list;
    }

    /**
     * 邀请员工（生成邀请信息）
     */
    public Map<String, Object> invite(Map<String, Object> inviteRequest) {
        String phone = (String) inviteRequest.get("phone");
        String role = (String) inviteRequest.get("role");
        Long storeId = inviteRequest.get("storeId") != null ? Long.valueOf(inviteRequest.get("storeId").toString()) : null;

        // 检查手机号是否已存在
        Long tenantId = TenantContextHolder.getTenantId();
        Long count = userMapper.selectCount(
                new LambdaQueryWrapper<User>()
                        .eq(User::getTenantId, tenantId)
                        .eq(User::getPhone, phone));
        if (count > 0) {
            throw new RuntimeException("该手机号已存在");
        }

        // 生成邀请码
        String inviteCode = UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        Map<String, Object> result = new HashMap<>();
        result.put("inviteCode", inviteCode);
        result.put("phone", phone);
        result.put("role", role);
        result.put("storeId", storeId);
        result.put("expireTime", LocalDateTime.now().plusDays(7));
        return result;
    }

    /**
     * 分配角色
     */
    public void assignRole(Long id, String role) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("员工不存在");
        }
        // 验证角色合法性
        if (!isValidRole(role)) {
            throw new RuntimeException("无效的角色: " + role);
        }
        user.setRole(role);
        user.setUpdatedAt(LocalDateTime.now());
        userMapper.updateById(user);
    }

    /**
     * 启用/停用员工
     */
    public void updateStatus(Long id, Integer status) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("员工不存在");
        }
        user.setStatus(status);
        user.setUpdatedAt(LocalDateTime.now());
        userMapper.updateById(user);
    }

    /**
     * 验证角色是否合法
     */
    private boolean isValidRole(String role) {
        return Set.of("TENANT_ADMIN", "STORE_MANAGER", "CASHIER", "SERVICE_STAFF").contains(role);
    }
}
