<template>
  <div class="marketing-points">
    <a-card :bordered="false">
      <a-tabs default-active-key="rules">
        <a-tab-pane key="rules" title="积分规则配置">
          <a-card :bordered="false" title="积分获取规则">
            <a-form :model="rulesForm" layout="vertical" style="max-width: 500px">
              <a-form-item label="消费送积分比例（每消费1元送X积分）">
                <a-input-number v-model="rulesForm.earnRatio" :min="0" :precision="1" style="width: 200px" />
              </a-form-item>
              <a-form-item label="新注册送积分">
                <a-input-number v-model="rulesForm.registerBonus" :min="0" style="width: 200px" />
              </a-form-item>
              <a-form-item label="签到送积分">
                <a-input-number v-model="rulesForm.checkinBonus" :min="0" style="width: 200px" />
              </a-form-item>
              <a-form-item label="评价送积分">
                <a-input-number v-model="rulesForm.reviewBonus" :min="0" style="width: 200px" />
              </a-form-item>
              <a-form-item>
                <a-button type="primary" :loading="saveRulesLoading" @click="handleSaveRules">
                  保存规则
                </a-button>
              </a-form-item>
            </a-form>
          </a-card>

          <a-card :bordered="false" title="积分兑换规则" style="margin-top: 16px">
            <a-form :model="exchangeForm" layout="vertical" style="max-width: 500px">
              <a-form-item label="积分抵扣比例（X积分=1元）">
                <a-input-number v-model="exchangeForm.deductRatio" :min="0" :precision="1" style="width: 200px" />
              </a-form-item>
              <a-form-item label="单笔最高抵扣比例（%）">
                <a-input-number v-model="exchangeForm.maxDeductPercent" :min="0" :max="100" style="width: 200px" />
              </a-form-item>
              <a-form-item>
                <a-button type="primary" :loading="saveExchangeLoading" @click="handleSaveExchange">
                  保存规则
                </a-button>
              </a-form-item>
            </a-form>
          </a-card>
        </a-tab-pane>

        <a-tab-pane key="records" title="积分记录">
          <div class="search-bar">
            <a-form :model="recordSearch" layout="inline">
              <a-form-item label="会员手机号">
                <a-input v-model="recordSearch.phone" placeholder="请输入手机号" allow-clear />
              </a-form-item>
              <a-form-item label="变动类型">
                <a-select v-model="recordSearch.type" placeholder="全部" allow-clear style="width: 120px">
                  <a-option value="earn">获取</a-option>
                  <a-option value="deduct">扣减</a-option>
                  <a-option value="expire">过期</a-option>
                </a-select>
              </a-form-item>
              <a-form-item>
                <a-button type="primary" @click="fetchRecords">查询</a-button>
                <a-button style="margin-left: 8px" @click="resetRecordSearch">重置</a-button>
              </a-form-item>
            </a-form>
          </div>

          <a-table
            :columns="recordColumns"
            :data="recordData"
            :pagination="recordPagination"
            :loading="recordLoading"
            row-key="id"
            @page-change="handleRecordPageChange"
            @page-size-change="handleRecordPageSizeChange"
          >
            <template #type="{ record }">
              <a-tag :color="recordTypeColorMap[record.type]">{{ recordTypeTextMap[record.type] }}</a-tag>
            </template>
            <template #change="{ record }">
              <span :style="{ color: record.change > 0 ? '#00b42a' : '#f53f3f', fontWeight: 'bold' }">
                {{ record.change > 0 ? '+' : '' }}{{ record.change }}
              </span>
            </template>
            <template #time="{ record }">
              {{ formatDate(record.createdAt) }}
            </template>
          </a-table>
        </a-tab-pane>
      </a-tabs>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

const saveRulesLoading = ref(false);
const saveExchangeLoading = ref(false);
const recordLoading = ref(false);

const rulesForm = reactive({
  earnRatio: 1,
  registerBonus: 100,
  checkinBonus: 5,
  reviewBonus: 10,
});

const exchangeForm = reactive({
  deductRatio: 100,
  maxDeductPercent: 50,
});

const recordSearch = reactive({
  phone: '',
  type: undefined as string | undefined,
});

const recordData = ref<any[]>([]);

const recordPagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

const recordTypeTextMap: Record<string, string> = {
  earn: '获取',
  deduct: '扣减',
  expire: '过期',
};

const recordTypeColorMap: Record<string, string> = {
  earn: 'green',
  deduct: 'red',
  expire: 'gray',
};

const recordColumns = [
  { title: 'ID', dataIndex: 'id', width: 80 },
  { title: '会员姓名', dataIndex: 'memberName', width: 100 },
  { title: '手机号', dataIndex: 'memberPhone', width: 140 },
  { title: '变动类型', dataIndex: 'type', slotName: 'type', width: 80 },
  { title: '积分变动', dataIndex: 'change', slotName: 'change', width: 100 },
  { title: '变动后余额', dataIndex: 'balanceAfter', width: 120 },
  { title: '描述', dataIndex: 'description', ellipsis: true },
  { title: '时间', dataIndex: 'createdAt', slotName: 'time', width: 180 },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const handleSaveRules = async () => {
  saveRulesLoading.value = true;
  try {
    await request.post('/marketing/points/rules', rulesForm);
    Message.success('积分获取规则保存成功');
  } catch (error: any) {
    Message.error(error.message || '保存失败');
  } finally {
    saveRulesLoading.value = false;
  }
};

const handleSaveExchange = async () => {
  saveExchangeLoading.value = true;
  try {
    await request.post('/marketing/points/exchange-rules', exchangeForm);
    Message.success('积分兑换规则保存成功');
  } catch (error: any) {
    Message.error(error.message || '保存失败');
  } finally {
    saveExchangeLoading.value = false;
  }
};

const fetchRecords = async () => {
  recordLoading.value = true;
  try {
    const res = await request.get('/marketing/points/records', {
      params: {
        page: recordPagination.current,
        size: recordPagination.pageSize,
        phone: recordSearch.phone || undefined,
        type: recordSearch.type,
      },
    });
    const { list, total } = res.data.data;
    recordData.value = list;
    recordPagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取积分记录失败');
  } finally {
    recordLoading.value = false;
  }
};

const resetRecordSearch = () => {
  recordSearch.phone = '';
  recordSearch.type = undefined;
  recordPagination.current = 1;
  fetchRecords();
};

const handleRecordPageChange = (page: number) => {
  recordPagination.current = page;
  fetchRecords();
};

const handleRecordPageSizeChange = (size: number) => {
  recordPagination.pageSize = size;
  recordPagination.current = 1;
  fetchRecords();
};

const fetchRules = async () => {
  try {
    const res = await request.get('/marketing/points/rules');
    const data = res.data.data;
    if (data) {
      Object.assign(rulesForm, data.earnRules || {});
      Object.assign(exchangeForm, data.exchangeRules || {});
    }
  } catch (error: any) {
    // silently fail - use defaults
  }
};

onMounted(() => {
  fetchRules();
  fetchRecords();
});
</script>

<style scoped>
.marketing-points {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}
</style>
