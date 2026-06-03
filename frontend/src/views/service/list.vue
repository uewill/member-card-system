<template>
  <div class="service-list">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="项目名称">
            <a-input v-model="searchForm.name" placeholder="请输入项目名称" allow-clear />
          </a-form-item>
          <a-form-item label="分类">
            <a-select v-model="searchForm.category" placeholder="全部" allow-clear style="width: 140px">
              <a-option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</a-option>
            </a-select>
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
              新增项目
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
        <template #category="{ record }">
          <a-tag color="arcoblue">{{ record.category }}</a-tag>
        </template>
        <template #price="{ record }">
          {{ record.price.toFixed(2) }} 元
        </template>
        <template #duration="{ record }">
          {{ record.duration }} 分钟
        </template>
        <template #canSinglePurchase="{ record }">
          <a-tag :color="record.canSinglePurchase ? 'green' : 'gray'">
            {{ record.canSinglePurchase ? '支持' : '不支持' }}
          </a-tag>
        </template>
        <template #status="{ record }">
          <a-tag :color="record.status === 1 ? 'green' : 'red'">
            {{ record.status === 1 ? '启用' : '停用' }}
          </a-tag>
        </template>
        <template #operations="{ record }">
          <a-space>
            <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
            <a-popconfirm content="确认删除该项目？" @ok="handleDelete(record)">
              <a-button type="text" status="danger" size="small">删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:visible="modalVisible"
      :title="isEdit ? '编辑服务项目' : '新增服务项目'"
      @ok="handleSubmit"
      :ok-loading="submitLoading"
    >
      <a-form :model="formData" layout="vertical">
        <a-form-item label="项目名称" required>
          <a-input v-model="formData.name" placeholder="请输入项目名称" />
        </a-form-item>
        <a-form-item label="分类" required>
          <a-select v-model="formData.category" placeholder="请选择分类" allow-create>
            <a-option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</a-option>
          </a-select>
        </a-form-item>
        <a-form-item label="价格（元）" required>
          <a-input-number v-model="formData.price" :min="0" :precision="2" placeholder="请输入价格" style="width: 100%" />
        </a-form-item>
        <a-form-item label="时长（分钟）" required>
          <a-input-number v-model="formData.duration" :min="0" placeholder="请输入服务时长" style="width: 100%" />
        </a-form-item>
        <a-form-item label="支持单次购买">
          <a-switch v-model="formData.canSinglePurchase" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import { serviceApi } from '@/api';

interface ServiceRecord {
  id: number;
  tenantId: number;
  category: string;
  name: string;
  price: number;
  duration: number;
  canSinglePurchase: boolean;
  status: number;
}

const loading = ref(false);
const submitLoading = ref(false);
const tableData = ref<ServiceRecord[]>([]);
const modalVisible = ref(false);
const isEdit = ref(false);
const editId = ref<number | null>(null);

const categories = ['美容', '美发', '美甲', '养生', '其他'];

const searchForm = reactive({
  name: '',
  category: undefined as string | undefined,
  status: undefined as number | undefined,
});

const formData = reactive({
  name: '',
  category: '',
  price: 0,
  duration: 0,
  canSinglePurchase: true,
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
  { title: '项目名称', dataIndex: 'name', width: 160 },
  { title: '分类', dataIndex: 'category', width: 100, slotName: 'category' },
  { title: '价格', dataIndex: 'price', width: 100, slotName: 'price' },
  { title: '时长', dataIndex: 'duration', width: 100, slotName: 'duration' },
  { title: '单次购买', dataIndex: 'canSinglePurchase', width: 100, slotName: 'canSinglePurchase' },
  { title: '状态', dataIndex: 'status', width: 80, slotName: 'status' },
  { title: '操作', slotName: 'operations', width: 140, fixed: 'right' },
];

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await serviceApi.list({
      page: pagination.current,
      size: pagination.pageSize,
    });
    const { list, total } = res.data.data;
    tableData.value = list;
    pagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取服务项目列表失败');
  } finally {
    loading.value = false;
  }
};

const resetSearch = () => {
  searchForm.name = '';
  searchForm.category = undefined;
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
  formData.category = '';
  formData.price = 0;
  formData.duration = 0;
  formData.canSinglePurchase = true;
};

const handleAdd = () => {
  isEdit.value = false;
  editId.value = null;
  resetForm();
  modalVisible.value = true;
};

const handleEdit = (record: ServiceRecord) => {
  isEdit.value = true;
  editId.value = record.id;
  Object.assign(formData, {
    name: record.name,
    category: record.category,
    price: record.price,
    duration: record.duration,
    canSinglePurchase: record.canSinglePurchase,
  });
  modalVisible.value = true;
};

const handleSubmit = async () => {
  if (!formData.name.trim() || !formData.category) {
    Message.warning('请填写必填项');
    return;
  }
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await serviceApi.update(editId.value!, formData);
      Message.success('编辑成功');
    } else {
      await serviceApi.create(formData);
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

const handleDelete = async (record: ServiceRecord) => {
  try {
    await serviceApi.delete(record.id);
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
.service-list {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}
</style>
