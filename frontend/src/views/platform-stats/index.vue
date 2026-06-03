<template>
  <div class="platform-stats">
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="总租户数" :value="stats.totalTenants" :value-style="{ color: '#165dff' }">
            <template #prefix><icon-user-group /></template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="活跃租户" :value="stats.activeTenants" :value-style="{ color: '#00b42a' }">
            <template #prefix><icon-check-circle /></template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="待审批租户" :value="stats.pendingTenants" :value-style="{ color: '#ff7d00' }">
            <template #prefix><icon-clock-circle /></template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="已停用租户" :value="stats.disabledTenants" :value-style="{ color: '#f53f3f' }">
            <template #prefix><icon-close-circle /></template>
          </a-statistic>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px">
      <a-col :span="8">
        <a-card :bordered="false" title="交易流水汇总">
          <a-statistic title="本月交易总额" :value="stats.monthlyAmount" :precision="2" suffix="元" />
          <a-divider />
          <a-statistic title="本月交易笔数" :value="stats.monthlyOrders" suffix="笔" />
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card :bordered="false" title="活跃度统计">
          <a-statistic title="日活跃租户" :value="stats.dailyActive" />
          <a-divider />
          <a-statistic title="周活跃租户" :value="stats.weeklyActive" />
          <a-divider />
          <a-statistic title="月活跃租户" :value="stats.monthlyActive" />
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card :bordered="false" title="平台概况">
          <a-statistic title="总会员数" :value="stats.totalMembers" />
          <a-divider />
          <a-statistic title="总门店数" :value="stats.totalStores" />
          <a-divider />
          <a-statistic title="总员工数" :value="stats.totalEmployees" />
        </a-card>
      </a-col>
    </a-row>

    <a-card :bordered="false" title="最近操作日志" style="margin-top: 16px">
      <a-table :columns="logColumns" :data="logData" :pagination="false" size="small">
        <template #time="{ record }">
          {{ formatDate(record.createdAt) }}
        </template>
        <template #type="{ record }">
          <a-tag :color="record.type === 'approve' ? 'green' : record.type === 'reject' ? 'red' : 'blue'">
            {{ logTypeMap[record.type] || record.type }}
          </a-tag>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import {
  IconUserGroup,
  IconCheckCircle,
  IconClockCircle,
  IconCloseCircle,
} from '@arco-design/web-vue/es/icon';
import request from '@/api/request';

const stats = reactive({
  totalTenants: 0,
  activeTenants: 0,
  pendingTenants: 0,
  disabledTenants: 0,
  monthlyAmount: 0,
  monthlyOrders: 0,
  dailyActive: 0,
  weeklyActive: 0,
  monthlyActive: 0,
  totalMembers: 0,
  totalStores: 0,
  totalEmployees: 0,
});

const logData = ref<any[]>([]);

const logTypeMap: Record<string, string> = {
  approve: '审批通过',
  reject: '审批驳回',
  register: '新注册',
  disable: '停用',
  enable: '启用',
};

const logColumns = [
  { title: '时间', dataIndex: 'createdAt', slotName: 'time', width: 180 },
  { title: '类型', dataIndex: 'type', slotName: 'type', width: 120 },
  { title: '租户名称', dataIndex: 'tenantName', width: 180 },
  { title: '操作人', dataIndex: 'operator', width: 120 },
  { title: '描述', dataIndex: 'description', ellipsis: true },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchStats = async () => {
  try {
    const res = await request.get('/platform/stats');
    Object.assign(stats, res.data.data);
  } catch (error: any) {
    Message.error(error.message || '获取统计数据失败');
  }
};

const fetchLogs = async () => {
  try {
    const res = await request.get('/platform/logs', {
      params: { page: 1, size: 10 },
    });
    logData.value = res.data.data.list || [];
  } catch (error: any) {
    Message.error(error.message || '获取日志失败');
  }
};

onMounted(() => {
  fetchStats();
  fetchLogs();
});
</script>

<style scoped>
.platform-stats {
  padding: 16px;
}
</style>
