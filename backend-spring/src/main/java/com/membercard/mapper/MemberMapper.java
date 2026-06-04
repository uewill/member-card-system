package com.membercard.mapper;

import com.membercard.entity.Member;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 会员 Mapper
 */
public interface MemberMapper {

    @Select("SELECT * FROM member WHERE id = #{id} AND tenant_id = #{tenantId}")
    Member findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM member WHERE phone = #{phone} AND tenant_id = #{tenantId}")
    Member findByPhone(@Param("phone") String phone, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM member WHERE tenant_id = #{tenantId}")
    List<Member> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM member WHERE tenant_id = #{tenantId} AND name LIKE CONCAT('%', #{keyword}, '%')")
    List<Member> searchByName(@Param("tenantId") Long tenantId, @Param("keyword") String keyword);

    @Select("SELECT * FROM member WHERE tenant_id = #{tenantId} AND phone LIKE CONCAT('%', #{keyword}, '%')")
    List<Member> searchByPhone(@Param("tenantId") Long tenantId, @Param("keyword") String keyword);

    @Insert("INSERT INTO member (tenant_id, name, phone, birthday, tags_json, source_channel) " +
            "VALUES (#{tenantId}, #{name}, #{phone}, #{birthday}, #{tagsJson}, #{sourceChannel})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Member member);

    @Update("UPDATE member SET name = #{name}, phone = #{phone}, birthday = #{birthday}, " +
            "tags_json = #{tagsJson}, source_channel = #{sourceChannel}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE id = #{id} AND tenant_id = #{tenantId}")
    int update(Member member);

    @Delete("DELETE FROM member WHERE id = #{id} AND tenant_id = #{tenantId}")
    int deleteById(@Param("id") Long id, @Param("tenantId") Long tenantId);
}
