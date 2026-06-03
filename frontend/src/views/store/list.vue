<template>
  <div class="store-list">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="门店名称">
            <a-input v-model="searchForm.name" placeholder="请输入门店名称" allow-clear />
          </a-form-item>
          <a-form-item label="状态">
            <a-select v-model="searchForm.status" placeholder="全部" allow-clear style="width: 120px">
              <a-option :value="1">启用</a-option>
              <a-option :value="0">停用</a-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="fetchData">查询</a-button>
            <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
            <a-button type="primary" status="success" style="margin-left: 8px" @click="handleAdd">
              新增门店
            </a-button>
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
          <a-tag :color="record.status === 1 ? 'green' : 'red'">
            {{ record.status === 1 ? '启用' : '停用' }}
          </a-tag>
        </template>
        <template #createdAt="{ record }">
          {{ formatDate(record.createdAt) }}
        </template>
        <template #operations="{ record }">
          <a-space>
            <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
            <a-button
              v-if="record.status === 1"
              type="text" status="warning" size="small"
              @click="handleToggleStatus(record, 0)"
            >
              停用
            </a-button>
            <a-button
              v-if="record.status === 0"
              type="text" status="success" size="small"
              @click="handleToggleStatus(record, 1)"
            >
              启用
            </a-button>
            <a-popconfirm content="确认删除该门店？" @ok="handleDelete(record)">
              <a-button type="text" status="danger" size="small">删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:visible="modalVisible"
      :title="isEdit ? '编辑门店' : '新增门店'"
      @ok="handleSubmit"
      :ok-loading="submitLoading"
    >
      <a-form :model="formData" layout="vertical">
        <a-form-item label="门店名称" required>
          <a-input v-model="formData.name" placeholder="请输入门店名称" />
        </a-form-item>
        <a-form-item label="联系电话">
          <a-input v-model="formData.phone" placeholder="请输入联系电话" />
        </a-form-item>
        <a-form-item label="门店地址">
          <a-textarea v-model="formData.address" placeholder="请输入门店地址" />
        </a-form-item>
        <a-form-item label="营业时间">
          <a-input v-model="formData.businessHours" placeholder="如：09:00-21:00" />
        </a-form-item>
        <a-form-item label="负责人">
          <a-input v-model="formData.manager" placeholder="请输入负责人姓名" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

interface StoreRecord {
  id: number;
  name: string;
  phone: string;
  address: string;
  businessHours: string;
  manager: string;
  status: number;
  createdAt: string;
}

const loading = ref(false);
const submitLoading = ref(false);
const tableData = ref<StoreRecord[]>([]);
const modalVisible = ref(false);
const isEdit = ref(false);
const editId = ref<number | null>(null);

const searchForm = reactive({
  name: '',
  status: undefined as number | undefined,
});

const formData = reactive({
  name: '',
  phone: '',
  address: '',
  businessHours: '',
  manager: '',
});

const pagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

const columns = [
  { title: 'ID', dataIndex: 'id', width: 80 },
  { title: '门店名称', dataIndex: 'name', width: 160 },
  { title: '联系电话', dataIndex: 'phone', width: 140 },
  { title: '地址', dataIndex: 'address', ellipsis: true },
  { title: '营业时间', dataIndex: 'businessHours', width: 140 },
  { title: '负责人', dataIndex: 'manager', width: 100 },
  { title: '状态', dataIndex: 'status', width: 80, slotName: 'status' },
  { title: '创建时间', dataIndex: 'createdAt', width: 180, slotName: 'createdAt' },
  { title: '操作', slotName: 'operations', width: 200, fixed: 'right' },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await request.get('/store/list', {
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
    Message.error(error.message || '获取门店列表失败');
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

const resetForm = () => {
  formData.name = '';
  formData.phone = '';
  formData.address = '';
  formData.businessHours = '';
  formData.manager = '';
};

const handleAdd = () => {
  isEdit.value = false;
  editId.value = null;
  resetForm();
  modalVisible.value = true;
};

const handleEdit = (record: StoreRecord) => {
  isEdit.value = true;
  editId.value = record.id;
  Object.assign(formData, {
    name: record.name,
    phone: record.phone,
    address: record.address,
    businessHours: record.businessHours,
    manager: record.manager,
  });
  modalVisible.value = true;
};

const handleSubmit = async () => {
  if (!formData.name.trim()) {
    Message.warning('请输入门店名称');
    return;
  }
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await request.put(`/store/${editId.value}`, formData);
      Message.success('编辑成功');
    } else {
      await request.post('/store', formData);
      Message.success('新增成功');
    }
    modalVisible.value = false;
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '操作失败');
  } finally {
    submitLoading.value = false;
  }
};

const handleToggleStatus = async (record: StoreRecord, status: number) => {
  try {
    await request.post(`/store/${record.id}/toggle-status`, { status });
    Message.success(status === 1 ? '已启用' : '已停用');
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '操作失败');
  }
};

const handleDelete = async (record: StoreRecord) => {
  try {
    await request.delete(`/store/${record.id}`);
    Message.success('删除成功');
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '删除失败');
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.store-list {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}
</style>
