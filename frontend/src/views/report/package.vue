<template>
  <div class="report-package">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="时间范围">
            <a-range-picker v-model="searchForm.dateRange" style="width: 260px" />
          </a-form-item>
          <a-form-item label="套餐类型">
            <a-select v-model="searchForm.type" placeholder="全部" allow-clear style="width: 140px">
              <a-option value="times">次卡</a-option>
              <a-option value="amount">储值卡</a-option>
              <a-option value="period">期限卡</a-option>
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
            <a-statistic title="总销量" :value="summary.totalSales" :value-style="{ color: '#165dff' }" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="总销售额" :value="summary.totalRevenue" :precision="2" prefix="¥" :value-style="{ color: '#00b42a' }" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="同比" :value="summary.yoyGrowth" :precision="1" suffix="%" :value-style="{ color: summary.yoyGrowth >= 0 ? '#00b42a' : '#f53f3f' }">
              <template #prefix>
                <icon-arrow-rise v-if="summary.yoyGrowth >= 0" />
                <icon-arrow-fall v-else />
              </template>
            </a-statistic>
            <div class="stat-label">较去年同期</div>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="环比" :value="summary.momGrowth" :precision="1" suffix="%" :value-style="{ color: summary.momGrowth >= 0 ? '#00b42a' : '#f53f3f' }">
              <template #prefix>
                <icon-arrow-rise v-if="summary.momGrowth >= 0" />
                <icon-arrow-fall v-else />
              </template>
            </a-statistic>
            <div class="stat-label">较上月同期</div>
          </a-card>
        </a-col>
      </a-row>

      <!-- 销量排行 -->
      <a-card :bordered="false" title="套餐销量排行" style="margin-bottom: 16px">
        <a-table :columns="rankColumns" :data="rankData" :pagination="false" size="small">
          <template #index="{ rowIndex }">
            <a-tag :color="rowIndex < 3 ? 'gold' : 'gray'" size="small">{{ rowIndex + 1 }}</a-tag>
          </template>
          <template #type="{ record }">
            <a-tag :color="typeColorMap[record.type]">{{ typeTextMap[record.type] }}</a-tag>
          </template>
          <template #revenue="{ record }">
            <span style="font-weight: bold">{{ record.revenue.toFixed(2) }} 元</span>
          </template>
          <template #yoy="{ record }">
            <span :style="{ color: record.yoy >= 0 ? '#00b42a' : '#f53f3f' }">
              {{ record.yoy >= 0 ? '+' : '' }}{{ record.yoy }}%
            </span>
          </template>
          <template #mom="{ record }">
            <span :style="{ color: record.mom >= 0 ? '#00b42a' : '#f53f3f' }">
              {{ record.mom >= 0 ? '+' : '' }}{{ record.mom }}%
            </span>
          </template>
        </a-table>
      </a-card>

      <!-- 趋势图 -->
      <a-card :bordered="false" title="售卖趋势">
        <div class="trend-chart">
          <div
            v-for="(item, index) in trendData"
            :key="index"
            class="trend-bar"
            :style="{ height: `${(item.sales / maxSales) * 200}px` }"
          >
            <div class="bar-value">{{ item.sales }}</div>
            <div class="bar-label">{{ item.label }}</div>
          </div>
        </div>
      </a-card>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import { IconArrowRise, IconArrowFall } from '@arco-design/web-vue/es/icon';
import request from '@/api/request';

const searchForm = reactive({
  dateRange: undefined as string[] | undefined,
  type: undefined as string | undefined,
});

const summary = reactive({
  totalSales: 0,
  totalRevenue: 0,
  yoyGrowth: 0,
  momGrowth: 0,
});

const rankData = ref<any[]>([]);
const trendData = ref<{ label: string; sales: number }[]>([]);

const maxSales = computed(() => Math.max(...trendData.value.map((d) => d.sales), 1));

const typeTextMap: Record<string, string> = {
  times: '次卡',
  amount: '储值卡',
  period: '期限卡',
};

const typeColorMap: Record<string, string> = {
  times: 'arcoblue',
  amount: 'green',
  period: 'purple',
};

const rankColumns = [
  { title: '排名', slotName: 'index', width: 60 },
  { title: '套餐名称', dataIndex: 'name', width: 160 },
  { title: '类型', dataIndex: 'type', slotName: 'type', width: 80 },
  { title: '销量', dataIndex: 'sales', width: 80 },
  { title: '销售额', dataIndex: 'revenue', slotName: 'revenue', width: 120 },
  { title: '同比', dataIndex: 'yoy', slotName: 'yoy', width: 80 },
  { title: '环比', dataIndex: 'mom', slotName: 'mom', width: 80 },
];

const fetchData = async () => {
  try {
    const params: any = {
      type: searchForm.type,
    };
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      params.startDate = searchForm.dateRange[0];
      params.endDate = searchForm.dateRange[1];
    }
    const res = await request.get('/report/package', { params });
    const data = res.data.data;
    Object.assign(summary, data.summary || {});
    rankData.value = data.rankData || [];
    trendData.value = data.trendData || [];
  } catch (error: any) {
    Message.error(error.message || '获取套餐分析数据失败');
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.report-package {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}

.stat-label {
  font-size: 12px;
  color: var(--color-text-3);
  margin-top: 4px;
}

.trend-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-around;
  height: 260px;
  padding: 20px 0;
  border-bottom: 1px solid var(--color-border);
}

.trend-bar {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  width: 36px;
  background: linear-gradient(180deg, #165dff 0%, #73a8ff 100%);
  border-radius: 4px 4px 0 0;
  min-height: 2px;
  transition: height 0.3s;
}

.bar-value {
  margin-bottom: 4px;
  font-size: 12px;
  color: #fff;
  font-weight: bold;
}

.bar-label {
  margin-top: 8px;
  font-size: 12px;
  color: var(--color-text-2);
  white-space: nowrap;
}
</style>
