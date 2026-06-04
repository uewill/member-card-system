package com.membercard.mapper;

import com.membercard.entity.ConsumeDetail;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 消费明细 Mapper
 */
public interface ConsumeDetailMapper {

    @Select("SELECT * FROM consume_detail WHERE id = #{id} AND tenant_id = #{tenantId}")
    ConsumeDetail findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM consume_detail WHERE order_id = #{orderId} AND tenant_id = #{tenantId}")
    List<ConsumeDetail> findByOrderId(@Param("orderId") Long orderId, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM consume_detail WHERE tenant_id = #{tenantId} AND card_id = #{cardId}")
    List<ConsumeDetail> findByCardId(@Param("tenantId") Long tenantId, @Param("cardId") Long cardId);

    @Insert("INSERT INTO consume_detail (tenant_id, order_id, service_item_id, card_id, deduction_type, " +
            "deduction_count, deduction_amount, before_snapshot_json, after_snapshot_json, employee_ratio_json) " +
            "VALUES (#{tenantId}, #{orderId}, #{serviceItemId}, #{cardId}, #{deductionType}, " +
            "#{deductionCount}, #{deductionAmount}, #{beforeSnapshotJson}, #{afterSnapshotJson}, #{employeeRatioJson})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(ConsumeDetail consumeDetail);
}
