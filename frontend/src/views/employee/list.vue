<template>
  <div class="employee-list">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="员工姓名">
            <a-input v-model="searchForm.name" placeholder="请输入姓名" allow-clear />
          </a-form-item>
          <a-form-item label="手机号">
            <a-input v-model="searchForm.phone" placeholder="请输入手机号" allow-clear />
          </a-form-item>
          <a-form-item label="角色">
            <a-select v-model="searchForm.role" placeholder="全部" allow-clear style="width: 140px">
              <a-option value="admin">管理员</a-option>
              <a-option value="manager">店长</a-option>
              <a-option value="staff">员工</a-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="fetchData">查询</a-button>
            <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
            <a-button type="primary" status="success" style="margin-left: 8px" @click="handleAdd">
              新增员工
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
        <template #role="{ record }">
          <a-tag :color="roleColorMap[record.role]">{{ roleTextMap[record.role] }}</a-tag>
        </template>
        <template #stores="{ record }">
          <a-tag v-for="store in record.stores" :key="store.id" style="margin: 2px">
            {{ store.name }}
          </a-tag>
        </template>
        <template #status="{ record }">
          <a-tag :color="record.status === 1 ? 'green' : 'red'">
            {{ record.status === 1 ? '在职' : '离职' }}
          </a-tag>
        </template>
        <template #operations="{ record }">
          <a-space>
            <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
            <a-button type="text" size="small" @click="handleInvite(record)">邀请</a-button>
            <a-popconfirm content="确认删除该员工？" @ok="handleDelete(record)">
              <a-button type="text" status="danger" size="small">删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:visible="modalVisible"
      :title="isEdit ? '编辑员工' : '新增员工'"
      @ok="handleSubmit"
      :ok-loading="submitLoading"
      :width="560"
    >
      <a-form :model="formData" layout="vertical">
        <a-form-item label="姓名" required>
          <a-input v-model="formData.name" placeholder="请输入员工姓名" />
        </a-form-item>
        <a-form-item label="手机号" required>
          <a-input v-model="formData.phone" placeholder="请输入手机号" />
        </a-form-item>
        <a-form-item label="角色" required>
          <a-select v-model="formData.role" placeholder="请选择角色">
            <a-option value="admin">管理员</a-option>
            <a-option value="manager">店长</a-option>
            <a-option value="staff">员工</a-option>
          </a-select>
        </a-form-item>
        <a-form-item label="绑定门店">
          <a-select
            v-model="formData.storeIds"
            placeholder="请选择门店"
            multiple
            :loading="storeLoading"
          >
            <a-option v-for="store in storeList" :key="store.id" :value="store.id">
              {{ store.name }}
            </a-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

interface EmployeeRecord {
  id: number;
  name: string;
  phone: string;
  role: string;
  stores: { id: number; name: string }[];
  status: number;
  createdAt: string;
}

const loading = ref(false);
const submitLoading = ref(false);
const storeLoading = ref(false);
const tableData = ref<EmployeeRecord[]>([]);
const storeList = ref<{ id: number; name: string }[]>([]);
const modalVisible = ref(false);
const isEdit = ref(false);
const editId = ref<number | null>(null);

const searchForm = reactive({
  name: '',
  phone: '',
  role: undefined as string | undefined,
});

const formData = reactive({
  name: '',
  phone: '',
  role: '',
  storeIds: [] as number[],
});

const pagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

const roleTextMap: Record<string, string> = {
  admin: '管理员',
  manager: '店长',
  staff: '员工',
};

const roleColorMap: Record<string, string> = {
  admin: 'red',
  manager: 'orange',
  staff: 'blue',
};

const columns = [
  { title: 'ID', dataIndex: 'id', width: 80 },
  { title: '姓名', dataIndex: 'name', width: 120 },
  { title: '手机号', dataIndex: 'phone', width: 140 },
  { title: '角色', dataIndex: 'role', width: 100, slotName: 'role' },
  { title: '绑定门店', dataIndex: 'stores', slotName: 'stores', width: 200 },
  { title: '状态', dataIndex: 'status', width: 80, slotName: 'status' },
  { title: '操作', slotName: 'operations', width: 180, fixed: 'right' },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await request.get('/employee/list', {
      params: {
        page: pagination.current,
        size: pagination.pageSize,
        name: searchForm.name || undefined,
        phone: searchForm.phone || undefined,
        role: searchForm.role,
      },
    });
    const { list, total } = res.data.data;
    tableData.value = list;
    pagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取员工列表失败');
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
  searchForm.name = '';
  searchForm.phone = '';
  searchForm.role = undefined;
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
  formData.role = '';
  formData.storeIds = [];
};

const handleAdd = () => {
  isEdit.value = false;
  editId.value = null;
  resetForm();
  modalVisible.value = true;
};

const handleEdit = (record: EmployeeRecord) => {
  isEdit.value = true;
  editId.value = record.id;
  Object.assign(formData, {
    name: record.name,
    phone: record.phone,
    role: record.role,
    storeIds: record.stores.map((s) => s.id),
  });
  modalVisible.value = true;
};

const handleSubmit = async () => {
  if (!formData.name.trim() || !formData.phone.trim() || !formData.role) {
    Message.warning('请填写必填项');
    return;
  }
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await request.put(`/employee/${editId.value}`, formData);
      Message.success('编辑成功');
    } else {
      await request.post('/employee', formData);
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

const handleInvite = async (record: EmployeeRecord) => {
  try {
    await request.post(`/employee/${record.id}/invite`);
    Message.success(`已向 ${record.name} 发送邀请`);
  } catch (error: any) {
    Message.error(error.message || '发送邀请失败');
  }
};

const handleDelete = async (record: EmployeeRecord) => {
  try {
    await request.delete(`/employee/${record.id}`);
    Message.success('删除成功');
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '删除失败');
  }
};

onMounted(() => {
  fetchData();
  fetchStores();
});
</script>

<style scoped>
.employee-list {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}
</style>
