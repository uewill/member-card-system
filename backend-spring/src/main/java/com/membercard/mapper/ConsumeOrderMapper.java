package com.membercard.mapper;

import com.membercard.entity.ConsumeOrder;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 消费订单 Mapper
 */
public interface ConsumeOrderMapper {

    @Select("SELECT * FROM consume_order WHERE id = #{id} AND tenant_id = #{tenantId}")
    ConsumeOrder findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM consume_order WHERE tenant_id = #{tenantId} ORDER BY created_at DESC")
    List<ConsumeOrder> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM consume_order WHERE tenant_id = #{tenantId} AND member_id = #{memberId} ORDER BY created_at DESC")
    List<ConsumeOrder> findByMemberId(@Param("tenantId") Long tenantId, @Param("memberId") Long memberId);

    @Select("SELECT * FROM consume_order WHERE tenant_id = #{tenantId} AND store_id = #{storeId} ORDER BY created_at DESC")
    List<ConsumeOrder> findByStoreId(@Param("tenantId") Long tenantId, @Param("storeId") Long storeId);

    @Select("SELECT * FROM consume_order WHERE tenant_id = #{tenantId} AND status = #{status} ORDER BY created_at DESC")
    List<ConsumeOrder> findByTenantIdAndStatus(@Param("tenantId") Long tenantId, @Param("status") String status);

    @Insert("INSERT INTO consume_order (tenant_id, store_id, member_id, total_amount, actual_paid, " +
            "payment_methods_json, employee_id, status) " +
            "VALUES (#{tenantId}, #{storeId}, #{memberId}, #{totalAmount}, #{actualPaid}, " +
            "#{paymentMethodsJson}, #{employeeId}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(ConsumeOrder consumeOrder);

    @Update("UPDATE consume_order SET status = #{status}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE id = #{id} AND tenant_id = #{tenantId}")
    int updateStatus(@Param("id") Long id, @Param("tenantId") Long tenantId, @Param("status") String status);
}
