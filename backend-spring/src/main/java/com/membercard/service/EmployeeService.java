package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.entity.Employee;
import com.membercard.entity.Store;
import com.membercard.mapper.EmployeeMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 员工服务
 */
@Service
public class EmployeeService {

    private final EmployeeMapper employeeMapper;
    private final PasswordEncoder passwordEncoder;

    public EmployeeService(EmployeeMapper employeeMapper, PasswordEncoder passwordEncoder) {
        this.employeeMapper = employeeMapper;
        this.passwordEncoder = passwordEncoder;
    }

    public Employee findById(Long id) {
        Long tenantId = TenantContext.getTenantId();
        Employee employee = employeeMapper.findById(id, tenantId);
        if (employee == null) {
            throw new BusinessException(404, "员工不存在");
        }
        return employee;
    }

    public List<Employee> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return employeeMapper.findByTenantId(tenantId);
    }

    public List<Employee> findByRole(String role) {
        Long tenantId = TenantContext.getTenantId();
        return employeeMapper.findByTenantIdAndRole(tenantId, role);
    }

    public List<Store> findStoresByEmployeeId(Long employeeId) {
        return employeeMapper.findStoresByEmployeeId(employeeId);
    }

    public Employee create(Employee employee) {
        Long tenantId = TenantContext.getTenantId();
        employee.setTenantId(tenantId);
        employee.setStatus("active");
        // 密码加密
        employee.setPasswordHash(passwordEncoder.encode(employee.getPasswordHash()));
        employeeMapper.insert(employee);
        return employee;
    }

    public Employee update(Employee employee) {
        Long tenantId = TenantContext.getTenantId();
        Employee existing = findById(employee.getId());
        existing.setName(employee.getName());
        existing.setPhone(employee.getPhone());
        existing.setRole(employee.getRole());
        existing.setStatus(employee.getStatus());
        if (employee.getPasswordHash() != null && !employee.getPasswordHash().isEmpty()) {
            existing.setPasswordHash(passwordEncoder.encode(employee.getPasswordHash()));
        }
        employeeMapper.update(existing);
        return existing;
    }

    public void delete(Long id) {
        Long tenantId = TenantContext.getTenantId();
        employeeMapper.deleteById(id, tenantId);
    }

    public void assignStore(Long employeeId, Long storeId) {
        employeeMapper.insertEmployeeStore(employeeId, storeId);
    }
}
