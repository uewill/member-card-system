package com.membercard.mapper;

import com.membercard.entity.Employee;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 员工 Mapper
 */
public interface EmployeeMapper {

    @Select("SELECT * FROM employee WHERE id = #{id} AND tenant_id = #{tenantId}")
    Employee findById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM employee WHERE phone = #{phone} AND tenant_id = #{tenantId}")
    Employee findByPhone(@Param("phone") String phone, @Param("tenantId") Long tenantId);

    @Select("SELECT * FROM employee WHERE tenant_id = #{tenantId}")
    List<Employee> findByTenantId(@Param("tenantId") Long tenantId);

    @Select("SELECT * FROM employee WHERE tenant_id = #{tenantId} AND status = #{status}")
    List<Employee> findByTenantIdAndStatus(@Param("tenantId") Long tenantId, @Param("status") String status);

    @Select("SELECT * FROM employee WHERE tenant_id = #{tenantId} AND role = #{role}")
    List<Employee> findByTenantIdAndRole(@Param("tenantId") Long tenantId, @Param("role") String role);

    @Insert("INSERT INTO employee (tenant_id, name, phone, password_hash, role, status) " +
            "VALUES (#{tenantId}, #{name}, #{phone}, #{passwordHash}, #{role}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Employee employee);

    @Update("UPDATE employee SET name = #{name}, phone = #{phone}, password_hash = #{passwordHash}, " +
            "role = #{role}, status = #{status}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE id = #{id} AND tenant_id = #{tenantId}")
    int update(Employee employee);

    @Delete("DELETE FROM employee WHERE id = #{id} AND tenant_id = #{tenantId}")
    int deleteById(@Param("id") Long id, @Param("tenantId") Long tenantId);

    @Select("SELECT s.* FROM store s " +
            "INNER JOIN employee_store es ON s.id = es.store_id " +
            "WHERE es.employee_id = #{employeeId}")
    List<Store> findStoresByEmployeeId(@Param("employeeId") Long employeeId);

    @Insert("INSERT INTO employee_store (employee_id, store_id) VALUES (#{employeeId}, #{storeId})")
    int insertEmployeeStore(@Param("employeeId") Long employeeId, @Param("storeId") Long storeId);
}
