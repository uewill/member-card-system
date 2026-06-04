package com.membercard.mapper;

import com.membercard.entity.ServiceItem;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 服务项目 Mapper
 */
public interface ServiceItemMapper {

    @Select("SELECT * FROM service_item WHERE id = #{id} AND tenant_id = #{tenantId}")
    ServiceItem findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM service_item WHERE tenant_id = #{tenantId}")
    List<ServiceItem> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM service_item WHERE tenant_id = #{tenantId} AND status = #{status}")
    List<ServiceItem> findByTenantIdAndStatus(@Param("tenantId") Long tenantId, @Param("status") String status);

    @Select("SELECT * FROM service_item WHERE tenant_id = #{tenantId} AND category = #{category}")
    List<ServiceItem> findByTenantIdAndCategory(@Param("tenantId") Long tenantId, @Param("category") String category);

    @Insert("INSERT INTO service_item (tenant_id, name, category, price, duration, purchasable_alone, status) " +
            "VALUES (#{tenantId}, #{name}, #{category}, #{price}, #{duration}, #{purchasableAlone}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(ServiceItem serviceItem);

    @Update("UPDATE service_item SET name = #{name}, category = #{category}, price = #{price}, " +
            "duration = #{duration}, purchasable_alone = #{purchasableAlone}, status = #{status}, " +
            "updated_at = CURRENT_TIMESTAMP WHERE id = #{id} AND tenant_id = #{tenantId}")
    int update(ServiceItem serviceItem);

    @Delete("DELETE FROM service_item WHERE id = #{id} AND tenant_id = #{tenantId}")
    int deleteById(@Param("id") Long id, @Param("tenantId") Long tenantId);
}
