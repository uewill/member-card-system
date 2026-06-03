<template>
  <div class="performance-page">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="员工">
            <a-select
              v-model="searchForm.employeeId"
              placeholder="全部员工"
              allow-clear
              style="width: 160px"
              :loading="employeeLoading"
            >
              <a-option v-for="e in employeeList" :key="e.id" :value="e.id">{{ e.name }}</a-option>
            </a-select>
          </a-form-item>
          <a-form-item label="门店">
            <a-select v-model="searchForm.storeId" placeholder="全部门店" allow-clear style="width: 160px" :loading="storeLoading">
              <a-option v-for="s in storeList" :key="s.id" :value="s.id">{{ s.name }}</a-option>
            </a-select>
          </a-form-item>
          <a-form-item label="维度">
            <a-radio-group v-model="searchForm.dimension" type="button" @change="fetchData">
              <a-radio value="day">日</a-radio>
              <a-radio value="week">周</a-radio>
              <a-radio value="month">月</a-radio>
            </a-radio-group>
          </a-form-item>
          <a-form-item label="日期">
            <a-date-picker v-model="searchForm.date" style="width: 160px" @change="fetchData" />
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="fetchData">查询</a-button>
          </a-form-item>
        </a-form>
      </div>

      <!-- 统计卡片 -->
      <a-row :gutter="16" style="margin-bottom: 16px">
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="服务单数" :value="performanceData.totalOrders" :value-style="{ color: '#165dff' }" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="服务金额" :value="performanceData.totalAmount" :precision="2" prefix="¥" :value-style="{ color: '#00b42a' }" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="客单价" :value="performanceData.avgAmount" :precision="2" prefix="¥" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="新增会员" :value="performanceData.newMembers" :value-style="{ color: '#ff7d00' }" />
          </a-card>
        </a-col>
      </a-row>

      <!-- 图表区域 -->
      <a-row :gutter="16">
        <a-col :span="12">
          <a-card :bordered="false" title="服务单数趋势">
            <div class="chart-placeholder">
              <div
                v-for="(item, index) in chartData"
                :key="index"
                class="chart-bar"
                :style="{ height: `${(item.orders / maxOrders) * 200}px` }"
              >
                <div class="bar-label">{{ item.label }}</div>
                <div class="bar-value">{{ item.orders }}</div>
              </div>
            </div>
          </a-card>
        </a-col>
        <a-col :span="12">
          <a-card :bordered="false" title="服务金额趋势">
            <div class="chart-placeholder">
              <div
                v-for="(item, index) in chartData"
                :key="index"
                class="chart-bar amount-bar"
                :style="{ height: `${(item.amount / maxAmount) * 200}px` }"
              >
                <div class="bar-label">{{ item.label }}</div>
                <div class="bar-value">{{ item.amount.toFixed(0) }}</div>
              </div>
            </div>
          </a-card>
        </a-col>
      </a-row>

      <!-- 员工业绩排行 -->
      <a-card :bordered="false" title="员工业绩排行" style="margin-top: 16px">
        <a-table :columns="rankColumns" :data="rankData" :pagination="false" size="small">
          <template #index="{ rowIndex }">
            <a-tag :color="rowIndex < 3 ? 'gold' : 'gray'" size="small">{{ rowIndex + 1 }}</a-tag>
          </template>
          <template #amount="{ record }">
            <span style="color: #f53f3f; font-weight: bold">{{ record.amount.toFixed(2) }} 元</span>
          </template>
        </a-table>
      </a-card>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

const employeeLoading = ref(false);
const storeLoading = ref(false);
const employeeList = ref<any[]>([]);
const storeList = ref<any[]>([]);

const searchForm = reactive({
  employeeId: undefined as number | undefined,
  storeId: undefined as number | undefined,
  dimension: 'day',
  date: '',
});

const performanceData = reactive({
  totalOrders: 0,
  totalAmount: 0,
  avgAmount: 0,
  newMembers: 0,
});

const chartData = ref<{ label: string; orders: number; amount: number }[]>([]);
const rankData = ref<any[]>([]);

const maxOrders = computed(() => Math.max(...chartData.value.map((d) => d.orders), 1));
const maxAmount = computed(() => Math.max(...chartData.value.map((d) => d.amount), 1));

const rankColumns = [
  { title: '排名', slotName: 'index', width: 80 },
  { title: '员工姓名', dataIndex: 'name', width: 120 },
  { title: '服务单数', dataIndex: 'orders', width: 100 },
  { title: '服务金额', dataIndex: 'amount', slotName: 'amount', width: 120 },
  { title: '客单价', dataIndex: 'avgAmount', width: 100 },
];

const fetchEmployees = async () => {
  employeeLoading.value = true;
  try {
    const res = await request.get('/employee/list', {
      params: { page: 1, size: 100, status: 1 },
    });
    employeeList.value = res.data.data.list || [];
  } catch (error: any) {
    Message.error(error.message || '获取员工列表失败');
  } finally {
    employeeLoading.value = false;
  }
};

const fetchStores = async () => {
  storeLoading.value = true;
  try {
    const res = await request.get('/store/list', {
      params: { page: 1, size: 100, status: 1 },
    });
    storeList.value = res.data.data.list || [];
  } catch (error: any) {
    Message.error(error.message || '获取门店列表失败');
  } finally {
    storeLoading.value = false;
  }
};

const fetchData = async () => {
  try {
    const res = await request.get('/performance/stats', {
      params: {
        employeeId: searchForm.employeeId,
        storeId: searchForm.storeId,
        dimension: searchForm.dimension,
        date: searchForm.date || undefined,
      },
    });
    const data = res.data.data;
    Object.assign(performanceData, {
      totalOrders: data.totalOrders || 0,
      totalAmount: data.totalAmount || 0,
      avgAmount: data.avgAmount || 0,
      newMembers: data.newMembers || 0,
    });
    chartData.value = data.chartData || [];
    rankData.value = data.rankData || [];
  } catch (error: any) {
    Message.error(error.message || '获取业绩数据失败');
  }
};

onMounted(() => {
  fetchEmployees();
  fetchStores();
  fetchData();
});
</script>

<style scoped>
.performance-page {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}

.chart-placeholder {
  display: flex;
  align-items: flex-end;
  justify-content: space-around;
  height: 240px;
  padding: 20px 0;
  border-bottom: 1px solid var(--color-border);
}

.chart-bar {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  width: 40px;
  background: #165dff;
  border-radius: 4px 4px 0 0;
  min-height: 2px;
  transition: height 0.3s;
}

.amount-bar {
  background: #00b42a;
}

.bar-label {
  position: absolute;
  bottom: -24px;
  font-size: 12px;
  color: var(--color-text-2);
  white-space: nowrap;
}

.bar-value {
  margin-bottom: 4px;
  font-size: 12px;
  color: #fff;
  font-weight: bold;
}
</style>
