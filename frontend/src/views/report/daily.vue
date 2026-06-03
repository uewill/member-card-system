<template>
  <div class="report-daily">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="日期">
            <a-date-picker v-model="searchForm.date" style="width: 160px" @change="fetchData" />
          </a-form-item>
          <a-form-item label="门店">
            <a-select v-model="searchForm.storeId" placeholder="全部门店" allow-clear style="width: 160px" :loading="storeLoading">
              <a-option v-for="s in storeList" :key="s.id" :value="s.id">{{ s.name }}</a-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="fetchData">查询</a-button>
          </a-form-item>
        </a-form>
      </div>

      <!-- 汇总卡片 -->
      <a-row :gutter="16" style="margin-bottom: 16px">
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="营业额" :value="summary.totalAmount" :precision="2" prefix="¥" :value-style="{ color: '#165dff' }" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="消费笔数" :value="summary.totalOrders" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="客单价" :value="summary.avgAmount" :precision="2" prefix="¥" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="新开卡数" :value="summary.newCards" :value-style="{ color: '#00b42a' }" />
          </a-card>
        </a-col>
      </a-row>

      <!-- 按门店汇总表格 -->
      <a-card :bordered="false" title="按门店汇总" style="margin-bottom: 16px">
        <a-table :columns="storeColumns" :data="storeData" :pagination="false" size="small">
          <template #amount="{ record }">
            <span style="font-weight: bold">{{ record.amount.toFixed(2) }} 元</span>
          </template>
          <template #percentage="{ record }">
            <a-progress :percent="record.percentage" :show-text="true" size="small" />
          </template>
        </a-table>
      </a-card>

      <a-row :gutter="16">
        <!-- 支付方式占比 -->
        <a-col :span="12">
          <a-card :bordered="false" title="支付方式占比">
            <div class="pay-method-chart">
              <div v-for="item in payMethodData" :key="item.method" class="pay-method-item">
                <div class="method-label">
                  <span>{{ payMethodTextMap[item.method] || item.method }}</span>
                  <span class="method-amount">{{ item.amount.toFixed(2) }} 元 ({{ item.percentage }}%)</span>
                </div>
                <a-progress :percent="item.percentage / 100" :show-text="false" size="small" />
              </div>
            </div>
          </a-card>
        </a-col>

        <!-- 服务项目消费排行 -->
        <a-col :span="12">
          <a-card :bordered="false" title="服务项目消费排行">
            <a-table :columns="serviceRankColumns" :data="serviceRankData" :pagination="false" size="small">
              <template #index="{ rowIndex }">
                <a-tag :color="rowIndex < 3 ? 'gold' : 'gray'" size="small">{{ rowIndex + 1 }}</a-tag>
              </template>
            </a-table>
          </a-card>
        </a-col>
      </a-row>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

const storeLoading = ref(false);
const storeList = ref<any[]>([]);

const searchForm = reactive({
  date: '',
  storeId: undefined as number | undefined,
});

const summary = reactive({
  totalAmount: 0,
  totalOrders: 0,
  avgAmount: 0,
  newCards: 0,
});

const storeData = ref<any[]>([]);
const payMethodData = ref<any[]>([]);
const serviceRankData = ref<any[]>([]);

const payMethodTextMap: Record<string, string> = {
  cash: '现金',
  wechat: '微信',
  alipay: '支付宝',
  bank: '银行卡',
  card: '卡扣',
};

const storeColumns = [
  { title: '门店名称', dataIndex: 'storeName', width: 160 },
  { title: '消费笔数', dataIndex: 'orders', width: 100 },
  { title: '营业额', dataIndex: 'amount', slotName: 'amount', width: 120 },
  { title: '占比', dataIndex: 'percentage', slotName: 'percentage', width: 200 },
];

const serviceRankColumns = [
  { title: '排名', slotName: 'index', width: 60 },
  { title: '服务项目', dataIndex: 'serviceName', width: 140 },
  { title: '消费次数', dataIndex: 'count', width: 100 },
  { title: '消费金额', dataIndex: 'amount', width: 120 },
];

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
    const res = await request.get('/report/daily', {
      params: {
        date: searchForm.date || undefined,
        storeId: searchForm.storeId,
      },
    });
    const data = res.data.data;
    Object.assign(summary, data.summary || {});
    storeData.value = data.storeData || [];
    payMethodData.value = data.payMethodData || [];
    serviceRankData.value = data.serviceRankData || [];
  } catch (error: any) {
    Message.error(error.message || '获取营业日报失败');
  }
};

onMounted(() => {
  fetchStores();
  fetchData();
});
</script>

<style scoped>
.report-daily {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}

.pay-method-chart {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.pay-method-item {
  padding: 4px 0;
}

.method-label {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 13px;
}

.method-amount {
  color: var(--color-text-2);
}
</style>
