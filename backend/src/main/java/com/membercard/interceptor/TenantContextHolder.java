package com.membercard.interceptor;

import com.membercard.entity.User;
import com.membercard.util.JwtUtil;
import javax.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 租户上下文持有者 - 使用 ThreadLocal 存储当前请求的租户 ID
 */
@Slf4j
public class TenantContextHolder {

    private static final ThreadLocal<Long> TENANT_ID = new ThreadLocal<>();
    private static final ThreadLocal<Long> USER_ID = new ThreadLocal<>();
    private static final ThreadLocal<String> USER_ROLE = new ThreadLocal<>();

    /**
     * 设置当前租户 ID
     */
    public static void setTenantId(Long tenantId) {
        TENANT_ID.set(tenantId);
        log.debug("设置租户ID: {}", tenantId);
    }

    /**
     * 获取当前租户 ID
     */
    public static Long getTenantId() {
        return TENANT_ID.get();
    }

    /**
     * 设置当前用户 ID
     */
    public static void setUserId(Long userId) {
        USER_ID.set(userId);
    }

    /**
     * 获取当前用户 ID
     */
    public static Long getUserId() {
        return USER_ID.get();
    }

    /**
     * 设置当前用户角色
     */
    public static void setUserRole(String role) {
        USER_ROLE.set(role);
    }

    /**
     * 获取当前用户角色
     */
    public static String getUserRole() {
        return USER_ROLE.get();
    }

    /**
     * 清除所有上下文信息
     */
    public static void clear() {
        TENANT_ID.remove();
        USER_ID.remove();
        USER_ROLE.remove();
        log.debug("清除租户上下文");
    }

    /**
     * 是否为平台管理员（无租户限制）
     */
    public static boolean isPlatformAdmin() {
        String role = getUserRole();
        return "PLATFORM_ADMIN".equals(role);
    }
}