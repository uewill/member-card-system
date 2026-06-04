package com.membercard.mapper;

import com.membercard.entity.Tenant;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 租户 Mapper
 */
public interface TenantMapper {

    @Select("SELECT * FROM tenant WHERE id = #{id}")
    Tenant findById(@Param("id") Long id);

    @Select("SELECT * FROM tenant WHERE admin_phone = #{phone}")
    Tenant findByPhone(@Param("phone") String phone);

    @Select("SELECT * FROM tenant")
    List<Tenant> findAll();

    @Select("SELECT * FROM tenant WHERE status = #{status}")
    List<Tenant> findByStatus(@Param("status") String status);

    @Insert("INSERT INTO tenant (company_name, industry_tag, admin_contact, admin_phone, status, payment_methods, points_enabled, version_limit) " +
            "VALUES (#{companyName}, #{industryTag}, #{adminContact}, #{adminPhone}, #{status}, #{paymentMethods}, #{pointsEnabled}, #{versionLimit})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Tenant tenant);

    @Update("UPDATE tenant SET company_name = #{companyName}, industry_tag = #{industryTag}, " +
            "admin_contact = #{adminContact}, admin_phone = #{adminPhone}, status = #{status}, " +
            "payment_methods = #{paymentMethods}, points_enabled = #{pointsEnabled}, " +
            "version_limit = #{versionLimit}, updated_at = CURRENT_TIMESTAMP WHERE id = #{id}")
    int update(Tenant tenant);

    @Delete("DELETE FROM tenant WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
