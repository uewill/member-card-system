package com.membercard.mapper;

import com.membercard.entity.PaymentRecord;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 支付记录 Mapper
 */
public interface PaymentRecordMapper {

    @Select("SELECT * FROM payment_record WHERE id = #{id} AND tenant_id = #{tenantId}")
    PaymentRecord findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM payment_record WHERE tenant_id = #{tenantId} ORDER BY created_at DESC")
    List<PaymentRecord> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM payment_record WHERE tenant_id = #{tenantId} AND store_id = #{storeId} ORDER BY created_at DESC")
    List<PaymentRecord> findByStoreId(@Param("tenantId") Long tenantId, @Param("storeId") Long storeId);

    @Select("SELECT * FROM payment_record WHERE tenant_id = #{tenantId} AND type = #{type} ORDER BY created_at DESC")
    List<PaymentRecord> findByType(@Param("tenantId") Long tenantId, @Param("type") String type);

    @Select("SELECT * FROM payment_record WHERE tenant_id = #{tenantId} AND order_id = #{orderId}")
    List<PaymentRecord> findByOrderId(@Param("tenantId") Long tenantId, @Param("orderId") Long orderId);

    @Insert("INSERT INTO payment_record (tenant_id, store_id, order_id, type, payment_method, amount, " +
            "card_deductions_json, cash_amount) " +
            "VALUES (#{tenantId}, #{storeId}, #{orderId}, #{type}, #{paymentMethod}, #{amount}, " +
            "#{cardDeductionsJson}, #{cashAmount})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(PaymentRecord paymentRecord);
}
