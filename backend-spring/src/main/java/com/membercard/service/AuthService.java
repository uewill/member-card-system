package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.dto.LoginRequest;
import com.membercard.dto.LoginResponse;
import com.membercard.entity.Employee;
import com.membercard.entity.Tenant;
import com.membercard.mapper.EmployeeMapper;
import com.membercard.mapper.TenantMapper;
import com.membercard.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * 认证服务
 */
@Service
public class AuthService {

    private final EmployeeMapper employeeMapper;
    private final TenantMapper tenantMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(EmployeeMapper employeeMapper, TenantMapper tenantMapper,
                       PasswordEncoder passwordEncoder, JwtTokenProvider jwtTokenProvider) {
        this.employeeMapper = employeeMapper;
        this.tenantMapper = tenantMapper;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    /**
     * 员工登录
     */
    public LoginResponse login(LoginRequest request) {
        // 查找员工（先查默认租户，后续可扩展多租户登录）
        Long defaultTenantId = 1L;
        Employee employee = employeeMapper.findByPhone(request.getPhone(), defaultTenantId);
        if (employee == null) {
            throw new BusinessException(401, "手机号或密码错误");
        }

        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), employee.getPasswordHash())) {
            throw new BusinessException(401, "手机号或密码错误");
        }

        // 检查员工状态
        if (!"active".equals(employee.getStatus())) {
            throw new BusinessException(403, "账号已被禁用，请联系管理员");
        }

        // 生成 JWT Token
        String token = jwtTokenProvider.generateToken(employee.getId(), employee.getTenantId(), employee.getRole());

        return LoginResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .userId(employee.getId())
                .tenantId(employee.getTenantId())
                .role(employee.getRole())
                .name(employee.getName())
                .build();
    }
}
