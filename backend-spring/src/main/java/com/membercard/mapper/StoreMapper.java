package com.membercard.mapper;

import com.membercard.entity.Store;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 门店 Mapper
 */
public interface StoreMapper {

    @Select("SELECT * FROM store WHERE id = #{id} AND tenant_id = #{tenantId}")
    Store findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM store WHERE tenant_id = #{tenantId}")
    List<Store> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM store WHERE tenant_id = #{tenantId} AND status = #{status}")
    List<Store> findByTenantIdAndStatus(@Param("tenantId") Long tenantId, @Param("status") String status);

    @Insert("INSERT INTO store (tenant_id, name, address, phone, business_hours, status, allowed_card_usage) " +
            "VALUES (#{tenantId}, #{name}, #{address}, #{phone}, #{businessHours}, #{status}, #{allowedCardUsage})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Store store);

    @Update("UPDATE store SET name = #{name}, address = #{address}, phone = #{phone}, " +
            "business_hours = #{businessHours}, status = #{status}, allowed_card_usage = #{allowedCardUsage}, " +
            "updated_at = CURRENT_TIMESTAMP WHERE id = #{id} AND tenant_id = #{tenantId}")
    int update(Store store);

    @Delete("DELETE FROM store WHERE id = #{id} AND tenant_id = #{tenantId}")
    int deleteById(@Param("id") Long id, @Param("tenantId") Long tenantId);
}
