<template>
  <div class="member-list">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="手机号">
            <a-input v-model="searchForm.phone" placeholder="请输入手机号" allow-clear />
          </a-form-item>
          <a-form-item label="姓名">
            <a-input v-model="searchForm.name" placeholder="请输入姓名" allow-clear />
          </a-form-item>
          <a-form-item label="标签">
            <a-select v-model="searchForm.tags" placeholder="全部" allow-clear style="width: 140px" multiple>
              <a-option value="VIP">VIP</a-option>
              <a-option value="新客">新客</a-option>
              <a-option value="活跃">活跃</a-option>
              <a-option value="沉睡">沉睡</a-option>
              <a-option value="流失">流失</a-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="fetchData">查询</a-button>
            <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
            <a-button type="primary" status="success" style="margin-left: 8px" @click="handleAdd">
              新增会员
            </a-button>
            <a-button style="margin-left: 8px" @click="handleExport">
              <template #icon><icon-download /></template>
              导出
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
        <template #tags="{ record }">
          <a-tag v-for="tag in record.tags" :key="tag" color="arcoblue" style="margin: 2px">
            {{ tag }}
          </a-tag>
          <span v-if="!record.tags || record.tags.length === 0">-</span>
        </template>
        <template #status="{ record }">
          <a-tag :color="record.status === 1 ? 'green' : 'red'">
            {{ record.status === 1 ? '正常' : '冻结' }}
          </a-tag>
        </template>
        <template #createdAt="{ record }">
          {{ formatDate(record.createdAt) }}
        </template>
        <template #operations="{ record }">
          <a-space>
            <a-button type="text" size="small" @click="handleDetail(record)">详情</a-button>
            <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
            <a-popconfirm content="确认删除该会员？" @ok="handleDelete(record)">
              <a-button type="text" status="danger" size="small">删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:visible="modalVisible"
      :title="isEdit ? '编辑会员' : '新增会员'"
      @ok="handleSubmit"
      :ok-loading="submitLoading"
    >
      <a-form :model="formData" layout="vertical">
        <a-form-item label="姓名" required>
          <a-input v-model="formData.name" placeholder="请输入姓名" />
        </a-form-item>
        <a-form-item label="手机号" required>
          <a-input v-model="formData.phone" placeholder="请输入手机号" />
        </a-form-item>
        <a-form-item label="生日">
          <a-date-picker v-model="formData.birthday" style="width: 100%" />
        </a-form-item>
        <a-form-item label="来源渠道">
          <a-select v-model="formData.sourceChannel" placeholder="请选择来源渠道">
            <a-option value="walk_in">到店</a-option>
            <a-option value="referral">转介绍</a-option>
            <a-option value="online">线上</a-option>
            <a-option value="activity">活动</a-option>
          </a-select>
        </a-form-item>
        <a-form-item label="标签">
          <a-select v-model="formData.tags" placeholder="请选择标签" multiple allow-create>
            <a-option value="VIP">VIP</a-option>
            <a-option value="新客">新客</a-option>
            <a-option value="活跃">活跃</a-option>
            <a-option value="沉睡">沉睡</a-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { Message } from '@arco-design/web-vue';
import { IconDownload } from '@arco-design/web-vue/es/icon';
import { memberApi } from '@/api';

const router = useRouter();
const loading = ref(false);
const submitLoading = ref(false);
const tableData = ref<any[]>([]);
const modalVisible = ref(false);
const isEdit = ref(false);
const editId = ref<number | null>(null);

const searchForm = reactive({
  phone: '',
  name: '',
  tags: [] as string[],
});

const formData = reactive({
  name: '',
  phone: '',
  birthday: '',
  sourceChannel: '',
  tags: [] as string[],
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
  { title: '姓名', dataIndex: 'name', width: 120 },
  { title: '手机号', dataIndex: 'phone', width: 140 },
  { title: '生日', dataIndex: 'birthday', width: 120 },
  { title: '标签', dataIndex: 'tags', slotName: 'tags', width: 180 },
  { title: '来源渠道', dataIndex: 'sourceChannel', width: 100 },
  { title: '状态', dataIndex: 'status', width: 80, slotName: 'status' },
  { title: '创建时间', dataIndex: 'createdAt', width: 180, slotName: 'createdAt' },
  { title: '操作', slotName: 'operations', width: 180, fixed: 'right' },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await memberApi.list({
      page: pagination.current,
      size: pagination.pageSize,
      phone: searchForm.phone || undefined,
      name: searchForm.name || undefined,
      tags: searchForm.tags.join(',') || undefined,
    });
    const { list, total } = res.data.data;
    tableData.value = list;
    pagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取会员列表失败');
  } finally {
    loading.value = false;
  }
};

const resetSearch = () => {
  searchForm.phone = '';
  searchForm.name = '';
  searchForm.tags = [];
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
  formData.birthday = '';
  formData.sourceChannel = '';
  formData.tags = [];
};

const handleAdd = () => {
  isEdit.value = false;
  editId.value = null;
  resetForm();
  modalVisible.value = true;
};

const handleEdit = (record: any) => {
  isEdit.value = true;
  editId.value = record.id;
  Object.assign(formData, {
    name: record.name,
    phone: record.phone,
    birthday: record.birthday,
    sourceChannel: record.sourceChannel,
    tags: record.tags || [],
  });
  modalVisible.value = true;
};

const handleSubmit = async () => {
  if (!formData.name.trim() || !formData.phone.trim()) {
    Message.warning('请填写必填项');
    return;
  }
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await memberApi.update(editId.value!, formData);
      Message.success('编辑成功');
    } else {
      await memberApi.create(formData);
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

const handleDetail = (record: any) => {
  router.push(`/member/detail/${record.id}`);
};

const handleDelete = async (record: any) => {
  try {
    await memberApi.delete(record.id);
    Message.success('删除成功');
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '删除失败');
  }
};

const handleExport = async () => {
  try {
    const res = await import('@/api/request').then((m) =>
      m.default.get('/member/export', {
        params: {
          phone: searchForm.phone || undefined,
          name: searchForm.name || undefined,
          tags: searchForm.tags.join(',') || undefined,
        },
        responseType: 'blob',
      })
    );
    const blob = new Blob([res.data as any], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `会员列表_${new Date().toISOString().slice(0, 10)}.xlsx`;
    link.click();
    window.URL.revokeObjectURL(url);
    Message.success('导出成功');
  } catch (error: any) {
    Message.error(error.message || '导出失败');
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.member-list {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}
</style>
