<template>
  <div class="marketing-coupon">
    <a-card :bordered="false">
      <a-tabs default-active-key="list">
        <a-tab-pane key="list" title="优惠券列表">
          <div class="search-bar">
            <a-form :model="searchForm" layout="inline">
              <a-form-item label="优惠券名称">
                <a-input v-model="searchForm.name" placeholder="请输入名称" allow-clear />
              </a-form-item>
              <a-form-item label="类型">
                <a-select v-model="searchForm.type" placeholder="全部" allow-clear style="width: 140px">
                  <a-option value="full_reduce">满减券</a-option>
                  <a-option value="discount">折扣券</a-option>
                </a-select>
              </a-form-item>
              <a-form-item label="状态">
                <a-select v-model="searchForm.status" placeholder="全部" allow-clear style="width: 120px">
                  <a-option value="active">进行中</a-option>
                  <a-option value="expired">已过期</a-option>
                  <a-option value="disabled">已停用</a-option>
                </a-select>
              </a-form-item>
              <a-form-item>
                <a-button type="primary" @click="fetchCoupons">查询</a-button>
                <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
                <a-button type="primary" status="success" style="margin-left: 8px" @click="handleCreate">
                  创建优惠券
                </a-button>
              </a-form-item>
            </a-form>
          </div>

          <a-table
            :columns="couponColumns"
            :data="couponData"
            :pagination="couponPagination"
            :loading="couponLoading"
            row-key="id"
            @page-change="handleCouponPageChange"
            @page-size-change="handleCouponPageSizeChange"
          >
            <template #type="{ record }">
              <a-tag :color="record.type === 'full_reduce' ? 'arcoblue' : 'green'">
                {{ record.type === 'full_reduce' ? '满减券' : '折扣券' }}
              </a-tag>
            </template>
            <template #value="{ record }">
              <span v-if="record.type === 'full_reduce'" style="color: #f53f3f; font-weight: bold">
                满{{ record.threshold.toFixed(0) }}减{{ record.value.toFixed(0) }}
              </span>
              <span v-else style="color: #f53f3f; font-weight: bold">
                {{ (record.value / 10).toFixed(1) }}折
              </span>
            </template>
            <template #validity="{ record }">
              {{ record.startDate }} ~ {{ record.endDate }}
            </template>
            <template #status="{ record }">
              <a-tag :color="couponStatusColorMap[record.status]">
                {{ couponStatusTextMap[record.status] }}
              </a-tag>
            </template>
            <template #usage="{ record }">
              {{ record.usedCount }} / {{ record.totalCount }}
            </template>
            <template #operations="{ record }">
              <a-space>
                <a-button type="text" size="small" @click="handleDistribute(record)">发放</a-button>
                <a-button type="text" size="small" @click="handleViewRecords(record)">发放记录</a-button>
                <a-button
                  v-if="record.status === 'active'"
                  type="text" status="warning" size="small"
                  @click="handleDisableCoupon(record)"
                >
                  停用
                </a-button>
              </a-space>
            </template>
          </a-table>
        </a-tab-pane>

        <a-tab-pane key="records" title="发放记录">
          <div v-if="selectedCoupon" class="records-header">
            <a-space>
              <span>当前优惠券：{{ selectedCoupon.name }}</span>
              <a-button size="small" @click="selectedCoupon = null">返回列表</a-button>
            </a-space>
          </div>
          <a-table
            :columns="distributeColumns"
            :data="distributeData"
            :pagination="distributePagination"
            :loading="distributeLoading"
            row-key="id"
            @page-change="handleDistributePageChange"
          >
            <template #status="{ record }">
              <a-tag :color="record.status === 'used' ? 'green' : record.status === 'expired' ? 'gray' : 'arcoblue'">
                {{ distributeStatusTextMap[record.status] }}
              </a-tag>
            </template>
            <template #time="{ record }">
              {{ formatDate(record.distributedAt) }}
            </template>
          </a-table>
        </a-tab-pane>
      </a-tabs>
    </a-card>

    <!-- 创建优惠券弹窗 -->
    <a-modal
      v-model:visible="createVisible"
      title="创建优惠券"
      @ok="handleCreateSubmit"
      :ok-loading="createLoading"
      :width="560"
    >
      <a-form :model="createForm" layout="vertical">
        <a-form-item label="优惠券名称" required>
          <a-input v-model="createForm.name" placeholder="请输入优惠券名称" />
        </a-form-item>
        <a-form-item label="优惠券类型" required>
          <a-radio-group v-model="createForm.type">
            <a-radio value="full_reduce">满减券</a-radio>
            <a-radio value="discount">折扣券</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-row v-if="createForm.type === 'full_reduce'" :gutter="16">
          <a-col :span="12">
            <a-form-item label="满减门槛（元）" required>
              <a-input-number v-model="createForm.threshold" :min="0" :precision="2" style="width: 100%" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="减免金额（元）" required>
              <a-input-number v-model="createForm.value" :min="0" :precision="2" style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
        <a-form-item v-else label="折扣（输入如85表示8.5折）" required>
          <a-input-number v-model="createForm.value" :min="1" :max="99" style="width: 200px" />
        </a-form-item>
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="开始日期" required>
              <a-date-picker v-model="createForm.startDate" style="width: 100%" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="结束日期" required>
              <a-date-picker v-model="createForm.endDate" style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
        <a-form-item label="发放总数" required>
          <a-input-number v-model="createForm.totalCount" :min="1" style="width: 200px" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 发放弹窗 -->
    <a-modal
      v-model:visible="distributeVisible"
      title="发放优惠券"
      @ok="handleDistributeSubmit"
      :ok-loading="distributeSubmitLoading"
    >
      <a-form :model="distributeForm" layout="vertical">
        <a-form-item label="发放方式">
          <a-radio-group v-model="distributeForm.method">
            <a-radio value="specific">指定会员</a-radio>
            <a-radio value="all">全部会员</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item v-if="distributeForm.method === 'specific'" label="会员手机号">
          <a-input v-model="distributeForm.phone" placeholder="请输入会员手机号" />
        </a-form-item>
        <a-form-item label="发放数量">
          <a-input-number v-model="distributeForm.count" :min="1" style="width: 200px" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

const couponLoading = ref(false);
const distributeLoading = ref(false);
const createLoading = ref(false);
const distributeSubmitLoading = ref(false);
const couponData = ref<any[]>([]);
const distributeData = ref<any[]>([]);
const selectedCoupon = ref<any>(null);
const createVisible = ref(false);
const distributeVisible = ref(false);

const searchForm = reactive({
  name: '',
  type: undefined as string | undefined,
  status: undefined as string | undefined,
});

const createForm = reactive({
  name: '',
  type: 'full_reduce',
  threshold: 100,
  value: 20,
  startDate: '',
  endDate: '',
  totalCount: 100,
});

const distributeForm = reactive({
  method: 'specific',
  phone: '',
  count: 1,
});

const couponPagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

const distributePagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showTotal: true,
  showPageSize: true,
});

const couponStatusTextMap: Record<string, string> = {
  active: '进行中',
  expired: '已过期',
  disabled: '已停用',
};

const couponStatusColorMap: Record<string, string> = {
  active: 'green',
  expired: 'gray',
  disabled: 'red',
};

const distributeStatusTextMap: Record<string, string> = {
  unused: '未使用',
  used: '已使用',
  expired: '已过期',
};

const couponColumns = [
  { title: 'ID', dataIndex: 'id', width: 80 },
  { title: '名称', dataIndex: 'name', width: 160 },
  { title: '类型', dataIndex: 'type', slotName: 'type', width: 100 },
  { title: '优惠内容', slotName: 'value', width: 140 },
  { title: '有效期', slotName: 'validity', width: 220 },
  { title: '使用情况', slotName: 'usage', width: 100 },
  { title: '状态', dataIndex: 'status', slotName: 'status', width: 80 },
  { title: '操作', slotName: 'operations', width: 200, fixed: 'right' },
];

const distributeColumns = [
  { title: 'ID', dataIndex: 'id', width: 80 },
  { title: '会员姓名', dataIndex: 'memberName', width: 100 },
  { title: '手机号', dataIndex: 'memberPhone', width: 140 },
  { title: '状态', dataIndex: 'status', slotName: 'status', width: 80 },
  { title: '发放时间', dataIndex: 'distributedAt', slotName: 'time', width: 180 },
  { title: '使用时间', dataIndex: 'usedAt', width: 180 },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchCoupons = async () => {
  couponLoading.value = true;
  try {
    const res = await request.get('/marketing/coupon/list', {
      params: {
        page: couponPagination.current,
        size: couponPagination.pageSize,
        name: searchForm.name || undefined,
        type: searchForm.type,
        status: searchForm.status,
      },
    });
    const { list, total } = res.data.data;
    couponData.value = list;
    couponPagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取优惠券列表失败');
  } finally {
    couponLoading.value = false;
  }
};

const resetSearch = () => {
  searchForm.name = '';
  searchForm.type = undefined;
  searchForm.status = undefined;
  couponPagination.current = 1;
  fetchCoupons();
};

const handleCouponPageChange = (page: number) => {
  couponPagination.current = page;
  fetchCoupons();
};

const handleCouponPageSizeChange = (size: number) => {
  couponPagination.pageSize = size;
  couponPagination.current = 1;
  fetchCoupons();
};

const handleCreate = () => {
  createForm.name = '';
  createForm.type = 'full_reduce';
  createForm.threshold = 100;
  createForm.value = 20;
  createForm.startDate = '';
  createForm.endDate = '';
  createForm.totalCount = 100;
  createVisible.value = true;
};

const handleCreateSubmit = async () => {
  if (!createForm.name.trim()) {
    Message.warning('请输入优惠券名称');
    return;
  }
  createLoading.value = true;
  try {
    await request.post('/marketing/coupon', createForm);
    Message.success('创建成功');
    createVisible.value = false;
    fetchCoupons();
  } catch (error: any) {
    Message.error(error.message || '创建失败');
  } finally {
    createLoading.value = false;
  }
};

const handleDistribute = (record: any) => {
  selectedCoupon.value = record;
  distributeForm.method = 'specific';
  distributeForm.phone = '';
  distributeForm.count = 1;
  distributeVisible.value = true;
};

const handleDistributeSubmit = async () => {
  distributeSubmitLoading.value = true;
  try {
    await request.post(`/marketing/coupon/${selectedCoupon.value.id}/distribute`, distributeForm);
    Message.success('发放成功');
    distributeVisible.value = false;
    fetchCoupons();
  } catch (error: any) {
    Message.error(error.message || '发放失败');
  } finally {
    distributeSubmitLoading.value = false;
  }
};

const handleViewRecords = async (record: any) => {
  selectedCoupon.value = record;
  distributePagination.current = 1;
  await fetchDistributeRecords();
};

const fetchDistributeRecords = async () => {
  if (!selectedCoupon.value) return;
  distributeLoading.value = true;
  try {
    const res = await request.get(`/marketing/coupon/${selectedCoupon.value.id}/records`, {
      params: {
        page: distributePagination.current,
        size: distributePagination.pageSize,
      },
    });
    const { list, total } = res.data.data;
    distributeData.value = list;
    distributePagination.total = total;
  } catch (error: any) {
    Message.error(error.message || '获取发放记录失败');
  } finally {
    distributeLoading.value = false;
  }
};

const handleDistributePageChange = (page: number) => {
  distributePagination.current = page;
  fetchDistributeRecords();
};

const handleDisableCoupon = async (record: any) => {
  try {
    await request.post(`/marketing/coupon/${record.id}/disable`);
    Message.success('已停用');
    fetchCoupons();
  } catch (error: any) {
    Message.error(error.message || '操作失败');
  }
};

onMounted(() => {
  fetchCoupons();
});
</script>

<style scoped>
.marketing-coupon {
  padding: 16px;
}

.search-bar {
  margin-bottom: 16px;
}

.records-header {
  margin-bottom: 16px;
  padding: 8px 0;
}
</style>
