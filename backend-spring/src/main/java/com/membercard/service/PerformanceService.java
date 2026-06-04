package com.membercard.service;

import com.membercard.common.TenantContext;
import com.membercard.entity.PerformanceRecord;
import com.membercard.mapper.PerformanceRecordMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * 业绩服务
 */
@Service
public class PerformanceService {

    private final PerformanceRecordMapper performanceRecordMapper;

    public PerformanceService(PerformanceRecordMapper performanceRecordMapper) {
        this.performanceRecordMapper = performanceRecordMapper;
    }

    public List<PerformanceRecord> findByEmployeeId(Long employeeId) {
        Long tenantId = TenantContext.getTenantId();
        return performanceRecordMapper.findByEmployeeId(tenantId, employeeId);
    }

    public List<PerformanceRecord> findByStoreId(Long storeId) {
        Long tenantId = TenantContext.getTenantId();
        return performanceRecordMapper.findByStoreId(tenantId, storeId);
    }

    public List<PerformanceRecord> findByDate(LocalDate date) {
        Long tenantId = TenantContext.getTenantId();
        return performanceRecordMapper.findByDate(tenantId, date);
    }

    public List<PerformanceRecord> findByDateRange(LocalDate startDate, LocalDate endDate) {
        Long tenantId = TenantContext.getTenantId();
        return performanceRecordMapper.findByDateRange(tenantId, startDate, endDate);
    }

    /**
     * 记录业绩
     */
    @Transactional
    public PerformanceRecord record(Long employeeId, Long storeId, LocalDate date,
                                     int serviceCount, BigDecimal serviceAmount, BigDecimal commission) {
        Long tenantId = TenantContext.getTenantId();
        PerformanceRecord record = PerformanceRecord.builder()
                .tenantId(tenantId)
                .employeeId(employeeId)
                .storeId(storeId)
                .date(date)
                .serviceCount(serviceCount)
                .serviceAmount(serviceAmount)
                .commission(commission)
                .build();
        performanceRecordMapper.insert(record);
        return record;
    }
}
