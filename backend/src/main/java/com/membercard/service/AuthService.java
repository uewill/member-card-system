package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.membercard.entity.Tenant;
import com.membercard.entity.User;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.TenantMapper;
import com.membercard.mapper.UserMapper;
import com.membercard.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证服务 - 登录验证、JWT生成
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserMapper userMapper;
    private final TenantMapper tenantMapper;
    private final JwtUtil jwtUtil;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /**
     * 登录
     */
    public Map<String, Object> login(String phone, String password) {
        // 查询用户（登录时不带租户隔离，需要全表查询）
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getPhone, phone);
        User user = userMapper.selectOne(queryWrapper);

        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (user.getStatus() != 1) {
            throw new RuntimeException("账号已被禁用");
        }

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("密码错误");
        }

        // 检查租户状态
        if (user.getTenantId() != null) {
            Tenant tenant = tenantMapper.selectById(user.getTenantId());
            if (tenant == null || tenant.getStatus() != 1) {
                throw new RuntimeException("租户已被停用");
            }
        }

        // 生成JWT Token
        String token = jwtUtil.generateToken(user.getId(), user.getTenantId(), user.getRole());

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userId", user.getId());
        result.put("tenantId", user.getTenantId());
        result.put("role", user.getRole());
        result.put("name", user.getName());
        return result;
    }

    /**
     * 登出
     */
    public void logout(String token) {
        // 可在此处将token加入黑名单（Redis实现）
        // 当前简化实现，仅清除上下文
        TenantContextHolder.clear();
    }

    /**
     * 获取当前用户信息
     */
    public Map<String, Object> getCurrentUserInfo() {
        Long userId = TenantContextHolder.getUserId();
        Long tenantId = TenantContextHolder.getTenantId();
        String role = TenantContextHolder.getUserRole();

        User user = userMapper.selectById(userId);

        Map<String, Object> info = new HashMap<>();
        info.put("userId", userId);
        info.put("tenantId", tenantId);
        info.put("role", role);
        info.put("name", user != null ? user.getName() : "");
        info.put("phone", user != null ? user.getPhone() : "");
        info.put("storeId", user != null ? user.getStoreId() : null);
        return info;
    }
}
