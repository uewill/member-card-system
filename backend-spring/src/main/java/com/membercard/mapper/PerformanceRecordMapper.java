package com.membercard.mapper;

import com.membercard.entity.PerformanceRecord;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 业绩记录 Mapper
 */
public interface PerformanceRecordMapper {

    @Select("SELECT * FROM performance_record WHERE id = #{id} AND tenant_id = #{tenantId}")
    PerformanceRecord findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM performance_record WHERE tenant_id = #{tenantId} AND employee_id = #{employeeId} ORDER BY date DESC")
    List<PerformanceRecord> findByEmployeeId(@Param("tenantId") Long tenantId, @Param("employeeId") Long employeeId);

    @Select("SELECT * FROM performance_record WHERE tenant_id = #{tenantId} AND store_id = #{storeId} ORDER BY date DESC")
    List<PerformanceRecord> findByStoreId(@Param("tenantId") Long tenantId, @Param("storeId") Long storeId);

    @Select("SELECT * FROM performance_record WHERE tenant_id = #{tenantId} AND date = #{date}")
    List<PerformanceRecord> findByDate(@Param("tenantId") Long tenantId, @Param("date") java.time.LocalDate date);

    @Select("SELECT * FROM performance_record WHERE tenant_id = #{tenantId} AND date BETWEEN #{startDate} AND #{endDate}")
    List<PerformanceRecord> findByDateRange(@Param("tenantId") Long tenantId,
                                             @Param("startDate") java.time.LocalDate startDate,
                                             @Param("endDate") java.time.LocalDate endDate);

    @Insert("INSERT INTO performance_record (tenant_id, employee_id, store_id, date, service_count, service_amount, commission) " +
            "VALUES (#{tenantId}, #{employeeId}, #{storeId}, #{date}, #{serviceCount}, #{serviceAmount}, #{commission})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(PerformanceRecord performanceRecord);
}
