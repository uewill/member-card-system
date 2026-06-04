package com.membercard.mapper;

import com.membercard.entity.PackageTemplate;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 套餐模板 Mapper
 */
public interface PackageTemplateMapper {

    @Select("SELECT * FROM package_template WHERE id = #{id} AND tenant_id = #{tenantId}")
    PackageTemplate findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM package_template WHERE tenant_id = #{tenantId}")
    List<PackageTemplate> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM package_template WHERE tenant_id = #{tenantId} AND status = #{status}")
    List<PackageTemplate> findByTenantIdAndStatus(@Param("tenantId") Long tenantId, @Param("status") String status);

    @Select("SELECT * FROM package_template WHERE tenant_id = #{tenantId} AND type = #{type}")
    List<PackageTemplate> findByTenantIdAndType(@Param("tenantId") Long tenantId, @Param("type") String type);

    @Insert("INSERT INTO package_template (tenant_id, name, type, service_items_json, service_counts_json, " +
            "principal_amount, bonus_amount, selling_price, validity_type, validity_days, expiry_date, " +
            "allow_transfer, allow_discount_combo, status) " +
            "VALUES (#{tenantId}, #{name}, #{type}, #{serviceItemsJson}, #{serviceCountsJson}, " +
            "#{principalAmount}, #{bonusAmount}, #{sellingPrice}, #{validityType}, #{validityDays}, #{expiryDate}, " +
            "#{allowTransfer}, #{allowDiscountCombo}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(PackageTemplate packageTemplate);

    @Update("UPDATE package_template SET name = #{name}, type = #{type}, service_items_json = #{serviceItemsJson}, " +
            "service_counts_json = #{serviceCountsJson}, principal_amount = #{principalAmount}, " +
            "bonus_amount = #{bonusAmount}, selling_price = #{sellingPrice}, validity_type = #{validityType}, " +
            "validity_days = #{validityDays}, expiry_date = #{expiryDate}, allow_transfer = #{allowTransfer}, " +
            "allow_discount_combo = #{allowDiscountCombo}, status = #{status}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE id = #{id} AND tenant_id = #{tenantId}")
    int update(PackageTemplate packageTemplate);

    @Delete("DELETE FROM package_template WHERE id = #{id} AND tenant_id = #{tenantId}")
    int deleteById(@Param("id") Long id, @Param("tenantId") Long tenantId);
}
