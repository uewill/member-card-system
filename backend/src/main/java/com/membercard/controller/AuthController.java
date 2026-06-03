package com.membercard.controller;

import com.membercard.dto.ApiResponse;
import com.membercard.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * 认证控制器 - 登录/登出接口
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * 登录接口
     */
    @PostMapping("/login")
    public ApiResponse<Map<String, Object>> login(@RequestBody Map<String, String> loginRequest) {
        String phone = loginRequest.get("phone");
        String password = loginRequest.get("password");
        Map<String, Object> result = authService.login(phone, password);
        return ApiResponse.success(result);
    }

    /**
     * 登出接口
     */
    @PostMapping("/logout")
    public ApiResponse<Void> logout(HttpServletRequest request) {
        String token = extractToken(request);
        authService.logout(token);
        return ApiResponse.success();
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/info")
    public ApiResponse<Map<String, Object>> getCurrentUser() {
        Map<String, Object> userInfo = authService.getCurrentUserInfo();
        return ApiResponse.success(userInfo);
    }

    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
