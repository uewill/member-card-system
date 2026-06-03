<template>
  <div class="report-member">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="时间范围">
            <a-range-picker v-model="searchForm.dateRange" style="width: 260px" />
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
            <a-statistic title="总会员数" :value="summary.totalMembers" :value-style="{ color: '#165dff' }" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="本期新增" :value="summary.newMembers" :value-style="{ color: '#00b42a' }" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="活跃会员" :value="summary.activeMembers" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="false">
            <a-statistic title="流失预警" :value="summary.churnRisk" :value-style="{ color: '#f53f3f' }" />
          </a-card>
        </a-col>
      </a-row>

      <a-tabs default-active-key="trend">
        <a-tab-pane key="trend" title="新增趋势">
          <a-card :bordered="false">
            <div class="trend-chart">
              <div
                v-for="(item, index) in trendData"
                :key="index"
                class="trend-bar"
                :style="{ height: `${(item.count / maxTrend) * 200}px` }"
              >
                <div class="bar-value">{{ item.count }}</div>
                <div class="bar-label">{{ item.label }}</div>
              </div>
            </div>
          </a-card>
        </a-tab-pane>

        <a-tab-pane key="active" title="活跃统计">
          <a-card :bordered="false">
            <a-table :columns="activeColumns" :data="activeData" :pagination="false" size="small">
              <template #level="{ record }">
                <a-tag :color="activeLevelColorMap[record.level]">{{ record.level }}</a-tag>
              </template>
              <template #percentage="{ record }">
                <a-progress :percent="record.percentage / 100" :show-text="true" size="small" />
              </template>
            </a-table>
          </a-card>
        </a-tab-pane>

        <a-tab-pane key="churn" title="流失预警">
          <a-card :bordered="false">
            <a-table :columns="churnColumns" :data="churnData" :pagination="churnPagination" size="small" @page-change="handleChurnPageChange">
              <template #riskLevel="{ record }">
                <a-tag :color="record.riskLevel === 'high' ? 'red' : record.riskLevel === 'medium' ? 'orange' : 'gold'">
                  {{ riskTextMap[record.riskLevel] }}
                </a-tag>
              </template>
              <template #lastConsume="{ record }">
                {{ formatDate(record.lastConsumeAt) }}
              </template>
            </a-table>
          </a-card>
        </a-tab-pane>
      </a-tabs>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

const searchForm = reactive({
  dateRange: undefined as string[] | undefined,
});

const summary = reactive({
  totalMembers: 0,
  newMembers: 0,
  activeMembers: 0,
  churnRisk: 0,
});

const trendData = ref<{ label: string; count: number }[]>([]);
const activeData = ref<any[]>([]);
const churnData = ref<any[]>([]);

const churnPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const maxTrend = computed(() => Math.max(...trendData.value.map((d) => d.count), 1));

const activeLevelColorMap: Record<string, string> = {
  '高活跃': 'green',
  '中活跃': 'arcoblue',
  '低活跃': 'orange',
  '沉睡': 'gray',
};

const riskTextMap: Record<string, string> = {
  high: '高风险',
  medium: '中风险',
  low: '低风险',
};

const activeColumns = [
  { title: '活跃等级', dataIndex: 'level', slotName: 'level', width: 100 },
  { title: '会员数', dataIndex: 'count', width: 100 },
  { title: '占比', dataIndex: 'percentage', slotName: 'percentage', width: 200 },
];

const churnColumns = [
  { title: '会员姓名', dataIndex: 'name', width: 100 },
  { title: '手机号', dataIndex: 'phone', width: 140 },
  { title: '风险等级', dataIndex: 'riskLevel', slotName: 'riskLevel', width: 100 },
  { title: '最后消费时间', dataIndex: 'lastConsumeAt', slotName: 'lastConsume', width: 180 },
  { title: '累计消费金额', dataIndex: 'totalAmount', width: 120 },
  { title: '持有卡数', dataIndex: 'cardCount', width: 80 },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchData = async () => {
  try {
    const params: any = {};
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      params.startDate = searchForm.dateRange[0];
      params.endDate = searchForm.dateRange[1];
    }
    const res = await request.get('/report/member', { params });
    const data = res.data.data;
    Object.assign(summary, data.summary || {});
    trendData.value = data.trendData || [];
    activeData.value = data.activeData || [];
    churnData.value = data.churnData?.list || [];
    churnPagination.total = data.churnData?.total || 0;
  } catch (error: any) {
    Message.error(error.message || '获取会员分析数据失败');
  }
};

const handleChurnPageChange = (page: number) => {
  churnPagination.current = page;
  fetchData();
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.report-member {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
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
  background: linear-gradient(180deg, #722ed1 0%, #b37feb 100%);
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
