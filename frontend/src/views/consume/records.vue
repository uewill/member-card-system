<template>
  <div class="consume-records">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="日期范围">
            <a-range-picker v-model="searchForm.dateRange" style="width: 260px" />
          </a-form-item>
          <a-form-item label="门店">
            <a-select v-model="searchForm.storeId" placeholder="全部" allow-clear style="width: 160px" :loading="storeLoading">
              <a-option v-for="store in storeList" :key="store.id" :value="store.id">
                {{ store.name }}
              </a-option>
            </a-select>
          </a-form-item>
          <a-form-item label="会员手机号">
            <a-input v-model="searchForm.memberPhone" placeholder="请输入手机号" allow-clear />
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="fetchData">查询</a-button>
            <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
          </a-form-item>
        </a-form>
      </div>

      <a-table
        :columns="columns"
        :data="tableData"
        :pagination="pagination"
        :loading="loading"
        row-key="id"
        @page-change="handlePageChange"
        @page-size-change="handlePageSizeChange"
      >
        <template #orderNo="{ record }">
          <a-link @click="handleViewDetail(record)">{{ record.orderNo }}</a-link>
        </template>
        <template #time="{ record }">
          {{ formatDate(record.createdAt) }}
        </template>
        <template #amount="{ record }">
          <span style="color: #f53f3f; font-weight: bold">{{ record.amount?.toFixed(2) }} 元</span>
        </template>
        <template #payMethod="{ record }">
          <a-tag>{{ payMethodTextMap[record.payMethod] || record.payMethod || '-' }}</a-tag>
        </template>
        <template #status="{ record }">
          <a-tag :color="record.status === 'completed' ? 'green' : record.status === 'cancelled' ? 'red' : 'orange'">
            {{ statusTextMap[record.status] || record.status }}
          </a-tag>
        </template>
        <template #operations="{ record }">
          <a-space>
            <a-button type="text" size="small" @click="handleViewDetail(record)">详情</a-button>
            <a-popconfirm
              v-if="record.status === 'completed'"
              content="确认撤销该消费记录？撤销后将退还相应权益。"
              @ok="handleCancel(record)"
            >
              <a-button type="text" status="danger" size="small">撤销</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </a-table>
    </a-card>

    <!-- 详情弹窗 -->
    <a-modal v-model:visible="detailVisible" title="消费详情" :footer="false" :width="560">
      <a-descriptions v-if="currentRecord" :column="2" bordered size="small">
        <a-descriptions-item label="订单号">{{ currentRecord.orderNo }}</a-descriptions-item>
        <a-descriptions-item label="状态">
          <a-tag :color="currentRecord.status === 'completed' ? 'green' : 'red'">
            {{ statusTextMap[currentRecord.status] }}
          </a-tag>
        </a-descriptions-item>
        <a-descriptions-item label="会员姓名">{{ currentRecord.memberName }}</a-descriptions-item>
        <a-descriptions-item label="会员手机号">{{ currentRecord.memberPhone }}</a-descriptions-item>
        <a-descriptions-item label="服务项目">{{ currentRecord.serviceName }}</a-descriptions-item>
        <a-descriptions-item label="服务员工">{{ currentRecord.staffName }}</a-descriptions-item>
        <a-descriptions-item label="门店">{{ currentRecord.storeName }}</a-descriptions-item>
        <a-descriptions-item label="金额">{{ currentRecord.amount?.toFixed(2) }} 元</a-descriptions-item>
        <a-descriptions-item label="支付方式">{{ payMethodTextMap[currentRecord.payMethod] || '-' }}</a-descriptions-item>
        <a-descriptions-item label="使用卡">{{ currentRecord.cardNo || '单次购买' }}</a-descriptions-item>
        <a-descriptions-item label="消费时间" :span="2">{{ formatDate(currentRecord.createdAt) }}</a-descriptions-item>
      </a-descriptions>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import { consumeApi } from '@/api';
import request from '@/api/request';

const loading = ref(false);
const storeLoading = ref(false);
const tableData = ref<any[]>([]);
const storeList = ref<any[]>([]);
const detailVisible = ref(false);
const currentRecord = ref<any>(null);

const searchForm = reactive({
  dateRange: undefined as string[] | undefined,
  storeId: undefined as number | undefined,
  memberPhone: '',
});

const pagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

const statusTextMap: Record<string, string> = {
  completed: '已完成',
  cancelled: '已撤销',
  pending: '进行中',
};

const payMethodTextMap: Record<string, string> = {
  card: '卡扣',
  cash: '现金',
  wechat: '微信',
  alipay: '支付宝',
  bank: '银行卡',
};

const columns = [
  { title: '订单号', dataIndex: 'orderNo', width: 180, slotName: 'orderNo' },
  { title: '会员姓名', dataIndex: 'memberName', width: 100 },
  { title: '手机号', dataIndex: 'memberPhone', width: 130 },
  { title: '服务项目', dataIndex: 'serviceName', width: 120 },
  { title: '服务员工', dataIndex: 'staffName', width: 100 },
  { title: '门店', dataIndex: 'storeName', width: 120 },
  { title: '金额', dataIndex: 'amount', width: 100, slotName: 'amount' },
  { title: '支付方式', dataIndex: 'payMethod', width: 100, slotName: 'payMethod' },
  { title: '状态', dataIndex: 'status', width: 80, slotName: 'status' },
  { title: '消费时间', dataIndex: 'createdAt', width: 180, slotName: 'time' },
  { title: '操作', slotName: 'operations', width: 140, fixed: 'right' },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchData = async () => {
  loading.value = true;
  try {
    const params: any = {
      page: pagination.current,
      size: pagination.pageSize,
      storeId: searchForm.storeId,
      memberPhone: searchForm.memberPhone || undefined,
    };
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      params.startDate = searchForm.dateRange[0];
      params.endDate = searchForm.dateRange[1];
    }
    const res = await consumeApi.records(params);
    const { list, total } = res.data.data;
    tableData.value = list;
    pagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取消费记录失败');
  } finally {
    loading.value = false;
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

const resetSearch = () => {
  searchForm.dateRange = undefined;
  searchForm.storeId = undefined;
  searchForm.memberPhone = '';
  pagination.current = 1;
  fetchData();
};

const handlePageChange = (page: number) => {
  pagination.current = page;
  fetchData();
};

const handlePageSizeChange = (size: number) => {
  pagination.pageSize = size;
  pagination.current = 1;
  fetchData();
};

const handleViewDetail = (record: any) => {
  currentRecord.value = record;
  detailVisible.value = true;
};

const handleCancel = async (record: any) => {
  try {
    await consumeApi.cancel(record.id);
    Message.success('撤销成功');
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '撤销失败');
  }
};

onMounted(() => {
  fetchData();
  fetchStores();
});
</script>

<style scoped>
.consume-records {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}
</style>
