package com.membercard.mapper;

import com.membercard.entity.RechargeRule;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 充值赠送规则 Mapper
 */
public interface RechargeRuleMapper {

    @Select("SELECT * FROM recharge_rule WHERE id = #{id} AND tenant_id = #{tenantId}")
    RechargeRule findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM recharge_rule WHERE tenant_id = #{tenantId} AND status = 'enabled' ORDER BY min_amount ASC")
    List<RechargeRule> findEnabledByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM recharge_rule WHERE tenant_id = #{tenantId} ORDER BY min_amount ASC")
    List<RechargeRule> findByTenantId(@Param("tenantId") Long tenantId);

    @Insert("INSERT INTO recharge_rule (tenant_id, min_amount, bonus_amount, bonus_type, bonus_ratio, status) " +
            "VALUES (#{tenantId}, #{minAmount}, #{bonusAmount}, #{bonusType}, #{bonusRatio}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(RechargeRule rechargeRule);

    @Update("UPDATE recharge_rule SET min_amount = #{minAmount}, bonus_amount = #{bonusAmount}, " +
            "bonus_type = #{bonusType}, bonus_ratio = #{bonusRatio}, status = #{status}, " +
            "updated_at = CURRENT_TIMESTAMP WHERE id = #{id} AND tenant_id = #{tenantId}")
    int update(RechargeRule rechargeRule);

    @Delete("DELETE FROM recharge_rule WHERE id = #{id} AND tenant_id = #{tenantId}")
    int deleteById(@Param("id") Long id, @Param("tenantId") Long tenantId);
}
