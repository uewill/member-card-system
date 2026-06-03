<template>
  <div class="tenant-list">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="租户名称">
            <a-input v-model="searchForm.name" placeholder="请输入租户名称" allow-clear />
          </a-form-item>
          <a-form-item label="状态">
            <a-select v-model="searchForm.status" placeholder="全部" allow-clear style="width: 120px">
              <a-option :value="0">待审批</a-option>
              <a-option :value="1">正常</a-option>
              <a-option :value="2">已停用</a-option>
              <a-option :value="3">已驳回</a-option>
            </a-select>
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
        <template #status="{ record }">
          <a-tag :color="statusColorMap[record.status]">{{ statusTextMap[record.status] }}</a-tag>
        </template>
        <template #createdAt="{ record }">
          {{ formatDate(record.createdAt) }}
        </template>
        <template #operations="{ record }">
          <a-space>
            <a-button
              v-if="record.status === 0"
              type="primary"
              size="small"
              @click="handleApprove(record)"
            >
              通过
            </a-button>
            <a-button
              v-if="record.status === 0"
              status="danger"
              size="small"
              @click="handleReject(record)"
            >
              驳回
            </a-button>
            <a-button
              v-if="record.status === 1"
              status="warning"
              size="small"
              @click="handleDisable(record)"
            >
              停用
            </a-button>
            <a-button
              v-if="record.status === 2"
              type="primary"
              size="small"
              @click="handleEnable(record)"
            >
              启用
            </a-button>
          </a-space>
        </template>
      </a-table>
    </a-card>

    <a-modal v-model:visible="rejectVisible" title="驳回原因" @ok="confirmReject">
      <a-textarea v-model="rejectReason" placeholder="请输入驳回原因" :max-length="200" />
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message, Modal } from '@arco-design/web-vue';
import request from '@/api/request';

interface TenantRecord {
  id: number;
  name: string;
  contactName: string;
  contactPhone: string;
  status: number;
  createdAt: string;
}

const loading = ref(false);
const tableData = ref<TenantRecord[]>([]);
const rejectVisible = ref(false);
const rejectReason = ref('');
const currentRecord = ref<TenantRecord | null>(null);

const searchForm = reactive({
  name: '',
  status: undefined as number | undefined,
});

const pagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

const statusTextMap: Record<number, string> = {
  0: '待审批',
  1: '正常',
  2: '已停用',
  3: '已驳回',
};

const statusColorMap: Record<number, string> = {
  0: 'orange',
  1: 'green',
  2: 'red',
  3: 'gray',
};

const columns = [
  { title: 'ID', dataIndex: 'id', width: 80 },
  { title: '租户名称', dataIndex: 'name', width: 180 },
  { title: '联系人', dataIndex: 'contactName', width: 120 },
  { title: '联系电话', dataIndex: 'contactPhone', width: 140 },
  { title: '状态', dataIndex: 'status', width: 100, slotName: 'status' },
  { title: '创建时间', dataIndex: 'createdAt', width: 180, slotName: 'createdAt' },
  { title: '操作', slotName: 'operations', width: 220, fixed: 'right' },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await request.get('/tenant/list', {
      params: {
        page: pagination.current,
        size: pagination.pageSize,
        name: searchForm.name || undefined,
        status: searchForm.status,
      },
    });
    const { list, total } = res.data.data;
    tableData.value = list;
    pagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取租户列表失败');
  } finally {
    loading.value = false;
  }
};

const resetSearch = () => {
  searchForm.name = '';
  searchForm.status = undefined;
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

const handleApprove = (record: TenantRecord) => {
  Modal.confirm({
    title: '确认审批',
    content: `确认通过租户「${record.name}」的申请？`,
    onOk: async () => {
      try {
        await request.post(`/tenant/${record.id}/approve`);
        Message.success('审批通过');
        fetchData();
      } catch (error: any) {
        Message.error(error.message || '操作失败');
      }
    },
  });
};

const handleReject = (record: TenantRecord) => {
  currentRecord.value = record;
  rejectReason.value = '';
  rejectVisible.value = true;
};

const confirmReject = async () => {
  if (!rejectReason.value.trim()) {
    Message.warning('请输入驳回原因');
    return;
  }
  try {
    await request.post(`/tenant/${currentRecord.value!.id}/reject`, {
      reason: rejectReason.value,
    });
    Message.success('已驳回');
    rejectVisible.value = false;
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '操作失败');
  }
};

const handleDisable = (record: TenantRecord) => {
  Modal.confirm({
    title: '确认停用',
    content: `确认停用租户「${record.name}」？停用后该租户将无法使用系统。`,
    onOk: async () => {
      try {
        await request.post(`/tenant/${record.id}/disable`);
        Message.success('已停用');
        fetchData();
      } catch (error: any) {
        Message.error(error.message || '操作失败');
      }
    },
  });
};

const handleEnable = (record: TenantRecord) => {
  Modal.confirm({
    title: '确认启用',
    content: `确认启用租户「${record.name}」？`,
    onOk: async () => {
      try {
        await request.post(`/tenant/${record.id}/enable`);
        Message.success('已启用');
        fetchData();
      } catch (error: any) {
        Message.error(error.message || '操作失败');
      }
    },
  });
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.tenant-list {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}
</style>
