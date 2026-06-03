<template>
  <div class="package-list">
    <a-card :bordered="false">
      <div class="search-bar">
        <a-form :model="searchForm" layout="inline">
          <a-form-item label="套餐名称">
            <a-input v-model="searchForm.name" placeholder="请输入套餐名称" allow-clear />
          </a-form-item>
          <a-form-item label="套餐类型">
            <a-select v-model="searchForm.type" placeholder="全部" allow-clear style="width: 140px">
              <a-option value="times">次卡</a-option>
              <a-option value="amount">储值卡</a-option>
              <a-option value="period">期限卡</a-option>
            </a-select>
          </a-form-item>
          <a-form-item label="状态">
            <a-select v-model="searchForm.status" placeholder="全部" allow-clear style="width: 120px">
              <a-option :value="1">上架</a-option>
              <a-option :value="0">下架</a-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="fetchData">查询</a-button>
            <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
            <a-button type="primary" status="success" style="margin-left: 8px" @click="handleAdd">
              新增套餐
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
        <template #type="{ record }">
          <a-tag :color="typeColorMap[record.type]">{{ typeTextMap[record.type] }}</a-tag>
        </template>
        <template #salePrice="{ record }">
          {{ record.salePrice.toFixed(2) }} 元
        </template>
        <template #validity="{ record }">
          <span v-if="record.validityDays">{{ record.validityDays }}天</span>
          <span v-else-if="record.validityEndDate">{{ record.validityEndDate }}</span>
          <span v-else>-</span>
        </template>
        <template #transfer="{ record }">
          <a-tag :color="record.allowTransfer ? 'green' : 'gray'">
            {{ record.allowTransfer ? '允许' : '不允许' }}
          </a-tag>
        </template>
        <template #combine="{ record }">
          <a-tag :color="record.allowCombine ? 'green' : 'gray'">
            {{ record.allowCombine ? '允许' : '不允许' }}
          </a-tag>
        </template>
        <template #status="{ record }">
          <a-tag :color="record.status === 1 ? 'green' : 'red'">
            {{ record.status === 1 ? '上架' : '下架' }}
          </a-tag>
        </template>
        <template #operations="{ record }">
          <a-space>
            <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
            <a-button type="text" size="small" @click="handleConfig(record)">配置</a-button>
            <a-popconfirm content="确认删除该套餐？" @ok="handleDelete(record)">
              <a-button type="text" status="danger" size="small">删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </a-table>
    </a-card>

    <!-- 新增/编辑弹窗 -->
    <a-modal
      v-model:visible="modalVisible"
      :title="isEdit ? '编辑套餐' : '新增套餐'"
      @ok="handleSubmit"
      :ok-loading="submitLoading"
      :width="600"
    >
      <a-form :model="formData" layout="vertical">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="套餐名称" required>
              <a-input v-model="formData.name" placeholder="请输入套餐名称" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="套餐类型" required>
              <a-select v-model="formData.type" placeholder="请选择类型">
                <a-option value="times">次卡</a-option>
                <a-option value="amount">储值卡</a-option>
                <a-option value="period">期限卡</a-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="售价（元）" required>
              <a-input-number v-model="formData.salePrice" :min="0" :precision="2" style="width: 100%" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="有效期（天）">
              <a-input-number v-model="formData.validityDays" :min="0" style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="允许转赠">
              <a-switch v-model="formData.allowTransfer" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="允许叠加">
              <a-switch v-model="formData.allowCombine" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>

    <!-- 配置编辑器弹窗 -->
    <a-modal
      v-model:visible="configVisible"
      title="套餐配置编辑器"
      @ok="handleSaveConfig"
      :ok-loading="configLoading"
      :width="700"
    >
      <div v-if="formData.type === 'times'" class="config-editor">
        <h4>包含服务项目</h4>
        <a-table :columns="configColumns" :data="configData" :pagination="false" size="small">
          <template #serviceItemId="{ record }">
            <a-select v-model="record.serviceItemId" placeholder="选择服务项目" style="width: 100%">
              <a-option v-for="s in serviceList" :key="s.id" :value="s.id">{{ s.name }}</a-option>
            </a-select>
          </template>
          <template #count="{ record }">
            <a-input-number v-model="record.count" :min="1" size="small" style="width: 80px" />
          </template>
          <template #actions="{ index }">
            <a-button type="text" status="danger" size="small" @click="removeConfigItem(index)">
              删除
            </a-button>
          </template>
        </a-table>
        <a-button type="dashed" long style="margin-top: 8px" @click="addConfigItem">
          + 添加服务项目
        </a-button>
      </div>
      <div v-else-if="formData.type === 'amount'" class="config-editor">
        <a-form layout="vertical">
          <a-form-item label="储值金额（元）">
            <a-input-number v-model="configAmount" :min="0" :precision="2" style="width: 200px" />
          </a-form-item>
          <a-form-item label="赠送金额（元）">
            <a-input-number v-model="configBonus" :min="0" :precision="2" style="width: 200px" />
          </a-form-item>
        </a-form>
      </div>
      <div v-else class="config-editor">
        <a-form layout="vertical">
          <a-form-item label="期限卡包含的服务项目（不限次数）">
            <a-select v-model="configPeriodServices" multiple placeholder="选择服务项目" style="width: 100%">
              <a-option v-for="s in serviceList" :key="s.id" :value="s.id">{{ s.name }}</a-option>
            </a-select>
          </a-form-item>
        </a-form>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import { packageApi, serviceApi } from '@/api';

interface PackageRecord {
  id: number;
  tenantId: number;
  name: string;
  type: string;
  config: any;
  salePrice: number;
  validityDays: number;
  validityEndDate: string;
  allowTransfer: boolean;
  allowCombine: boolean;
  status: number;
}

const loading = ref(false);
const submitLoading = ref(false);
const configLoading = ref(false);
const tableData = ref<PackageRecord[]>([]);
const serviceList = ref<any[]>([]);
const modalVisible = ref(false);
const configVisible = ref(false);
const isEdit = ref(false);
const editId = ref<number | null>(null);

const searchForm = reactive({
  name: '',
  type: undefined as string | undefined,
  status: undefined as number | undefined,
});

const formData = reactive({
  name: '',
  type: 'times',
  salePrice: 0,
  validityDays: 365,
  allowTransfer: false,
  allowCombine: false,
  config: null as any,
});

const configData = ref<{ serviceItemId: number; count: number }[]>([]);
const configAmount = ref(0);
const configBonus = ref(0);
const configPeriodServices = ref<number[]>([]);

const pagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

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

const columns = [
  { title: 'ID', dataIndex: 'id', width: 80 },
  { title: '套餐名称', dataIndex: 'name', width: 160 },
  { title: '类型', dataIndex: 'type', width: 100, slotName: 'type' },
  { title: '售价', dataIndex: 'salePrice', width: 100, slotName: 'salePrice' },
  { title: '有效期', width: 100, slotName: 'validity' },
  { title: '转赠', dataIndex: 'allowTransfer', width: 80, slotName: 'transfer' },
  { title: '叠加', dataIndex: 'allowCombine', width: 80, slotName: 'combine' },
  { title: '状态', dataIndex: 'status', width: 80, slotName: 'status' },
  { title: '操作', slotName: 'operations', width: 200, fixed: 'right' },
];

const configColumns = [
  { title: '服务项目', dataIndex: 'serviceItemId', slotName: 'serviceItemId' },
  { title: '次数', dataIndex: 'count', slotName: 'count', width: 100 },
  { title: '操作', slotName: 'actions', width: 80 },
];

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await packageApi.list({
      page: pagination.current,
      size: pagination.pageSize,
    });
    const { list, total } = res.data.data;
    tableData.value = list;
    pagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取套餐列表失败');
  } finally {
    loading.value = false;
  }
};

const fetchServices = async () => {
  try {
    const res = await serviceApi.list({ page: 1, size: 100 });
    serviceList.value = res.data.data.list || [];
  } catch (error: any) {
    Message.error(error.message || '获取服务列表失败');
  }
};

const resetSearch = () => {
  searchForm.name = '';
  searchForm.type = undefined;
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
  formData.type = 'times';
  formData.salePrice = 0;
  formData.validityDays = 365;
  formData.allowTransfer = false;
  formData.allowCombine = false;
  formData.config = null;
};

const handleAdd = () => {
  isEdit.value = false;
  editId.value = null;
  resetForm();
  modalVisible.value = true;
};

const handleEdit = (record: PackageRecord) => {
  isEdit.value = true;
  editId.value = record.id;
  Object.assign(formData, {
    name: record.name,
    type: record.type,
    salePrice: record.salePrice,
    validityDays: record.validityDays,
    allowTransfer: record.allowTransfer,
    allowCombine: record.allowCombine,
    config: record.config,
  });
  modalVisible.value = true;
};

const handleSubmit = async () => {
  if (!formData.name.trim()) {
    Message.warning('请输入套餐名称');
    return;
  }
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await packageApi.update(editId.value!, formData);
      Message.success('编辑成功');
    } else {
      await packageApi.create(formData);
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

const handleConfig = (record: PackageRecord) => {
  Object.assign(formData, {
    name: record.name,
    type: record.type,
    config: record.config,
  });
  if (record.type === 'times') {
    configData.value = record.config?.items || [{ serviceItemId: undefined, count: 1 }];
  } else if (record.type === 'amount') {
    configAmount.value = record.config?.amount || 0;
    configBonus.value = record.config?.bonus || 0;
  } else {
    configPeriodServices.value = record.config?.serviceIds || [];
  }
  configVisible.value = true;
};

const addConfigItem = () => {
  configData.value.push({ serviceItemId: undefined as any, count: 1 });
};

const removeConfigItem = (index: number) => {
  configData.value.splice(index, 1);
};

const handleSaveConfig = async () => {
  let config: any = {};
  if (formData.type === 'times') {
    config = { items: configData.value };
  } else if (formData.type === 'amount') {
    config = { amount: configAmount.value, bonus: configBonus.value };
  } else {
    config = { serviceIds: configPeriodServices.value };
  }
  configLoading.value = true;
  try {
    await packageApi.update(editId.value!, { config });
    Message.success('配置保存成功');
    configVisible.value = false;
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '保存配置失败');
  } finally {
    configLoading.value = false;
  }
};

const handleDelete = async (record: PackageRecord) => {
  try {
    await packageApi.delete(record.id);
    Message.success('删除成功');
    fetchData();
  } catch (error: any) {
    Message.error(error.message || '删除失败');
  }
};

onMounted(() => {
  fetchData();
  fetchServices();
});
</script>

<style scoped>
.package-list {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}

.config-editor {
  padding: 8px 0;
}

.config-editor h4 {
  margin-bottom: 12px;
  color: var(--color-text-1);
}
</style>
