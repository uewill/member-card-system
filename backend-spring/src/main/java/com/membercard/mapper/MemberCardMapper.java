package com.membercard.mapper;

import com.membercard.entity.MemberCard;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 会员卡实例 Mapper
 */
public interface MemberCardMapper {

    @Select("SELECT * FROM member_card WHERE id = #{id} AND tenant_id = #{tenantId}")
    MemberCard findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM member_card WHERE card_no = #{cardNo} AND tenant_id = #{tenantId}")
    MemberCard findByCardNo(@Param("cardNo") String cardNo, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM member_card WHERE member_id = #{memberId} AND tenant_id = #{tenantId}")
    List<MemberCard> findByMemberId(@Param("memberId") Long memberId, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM member_card WHERE member_id = #{memberId} AND tenant_id = #{tenantId} AND status = #{status}")
    List<MemberCard> findByMemberIdAndStatus(@Param("memberId") Long memberId, @Param("tenantId") Long tenantId, @Param("status") String status);

    @Select("SELECT * FROM member_card WHERE tenant_id = #{tenantId}")
    List<MemberCard> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM member_card WHERE tenant_id = #{tenantId} AND status = #{status}")
    List<MemberCard> findByTenantIdAndStatus(@Param("tenantId") Long tenantId, @Param("status") String status);

    @Insert("INSERT INTO member_card (tenant_id, member_id, package_snapshot_json, type, remaining_counts_json, " +
            "principal_balance, bonus_balance, expiry_date, status, card_no) " +
            "VALUES (#{tenantId}, #{memberId}, #{packageSnapshotJson}, #{type}, #{remainingCountsJson}, " +
            "#{principalBalance}, #{bonusBalance}, #{expiryDate}, #{status}, #{cardNo})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(MemberCard memberCard);

    @Update("UPDATE member_card SET remaining_counts_json = #{remainingCountsJson}, " +
            "principal_balance = #{principalBalance}, bonus_balance = #{bonusBalance}, " +
            "status = #{status}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE id = #{id} AND tenant_id = #{tenantId}")
    int update(MemberCard memberCard);

    @Delete("DELETE FROM member_card WHERE id = #{id} AND tenant_id = #{tenantId}")
    int deleteById(@Param("id") Long id, @Param("tenantId") Long tenantId);
}
