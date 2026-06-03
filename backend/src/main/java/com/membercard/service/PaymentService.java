package com.membercard.service;

import com.membercard.dto.PaymentResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * 支付服务 - 微信/支付宝模拟接口
 */
@Slf4j
@Service
public class PaymentService {

    /**
     * 发起支付（模拟微信/支付宝/现金支付）
     */
    public PaymentResult pay(String paymentMethod, BigDecimal amount, String orderNo) {
        log.info("发起支付: method={}, amount={}, orderNo={}", paymentMethod, amount, orderNo);

        try {
            switch (paymentMethod) {
                case "WECHAT":
                    return simulateWechatPay(amount, orderNo);
                case "ALIPAY":
                    return simulateAlipay(amount, orderNo);
                case "CASH":
                    return simulateCashPay(amount, orderNo);
                default:
                    return PaymentResult.fail(paymentMethod, "不支持的支付方式: " + paymentMethod);
            }
        } catch (Exception e) {
            log.error("支付失败: method={}, orderNo={}", paymentMethod, orderNo, e);
            return PaymentResult.fail(paymentMethod, "支付异常: " + e.getMessage());
        }
    }

    /**
     * 模拟微信支付
     */
    private PaymentResult simulateWechatPay(BigDecimal amount, String orderNo) {
        // 模拟支付处理延迟
        simulateDelay(100);

        String transactionNo = "WX" + UUID.randomUUID().toString().replace("-", "").substring(0, 28);
        log.info("微信支付成功: transactionNo={}, amount={}", transactionNo, amount);
        return PaymentResult.success(transactionNo, "WECHAT", amount);
    }

    /**
     * 模拟支付宝支付
     */
    private PaymentResult simulateAlipay(BigDecimal amount, String orderNo) {
        simulateDelay(100);

        String transactionNo = "ALI" + UUID.randomUUID().toString().replace("-", "").substring(0, 28);
        log.info("支付宝支付成功: transactionNo={}, amount={}", transactionNo, amount);
        return PaymentResult.success(transactionNo, "ALIPAY", amount);
    }

    /**
     * 模拟现金支付
     */
    private PaymentResult simulateCashPay(BigDecimal amount, String orderNo) {
        String transactionNo = "CASH" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new java.util.Random().nextInt(10000));
        log.info("现金支付成功: transactionNo={}, amount={}", transactionNo, amount);
        return PaymentResult.success(transactionNo, "CASH", amount);
    }

    /**
     * 模拟支付处理延迟
     */
    private void simulateDelay(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    /**
     * 查询支付状态（模拟）
     */
    public PaymentResult queryPaymentStatus(String transactionNo) {
        // 模拟查询：直接返回成功
        PaymentResult result = new PaymentResult();
        result.setSuccess(true);
        result.setTransactionNo(transactionNo);
        result.setStatus("SUCCESS");
        return result;
    }

    /**
     * 退款（模拟）
     */
    public PaymentResult refund(String transactionNo, BigDecimal amount) {
        log.info("发起退款: transactionNo={}, amount={}", transactionNo, amount);
        simulateDelay(100);

        String refundNo = "REF" + UUID.randomUUID().toString().replace("-", "").substring(0, 28);
        PaymentResult result = new PaymentResult();
        result.setSuccess(true);
        result.setTransactionNo(refundNo);
        result.setAmount(amount);
        result.setStatus("REFUNDED");
        return result;
    }
}
