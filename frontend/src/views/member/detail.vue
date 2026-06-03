<template>
  <div class="member-detail">
    <a-page-header title="会员详情" @back="$router.back()">
      <template #extra>
        <a-button type="primary" @click="handleEdit">编辑信息</a-button>
      </template>
    </a-page-header>

    <a-row :gutter="16">
      <a-col :span="8">
        <a-card :bordered="false" title="基本信息">
          <a-descriptions :column="1" bordered size="small">
            <a-descriptions-item label="姓名">{{ memberInfo.name || '-' }}</a-descriptions-item>
            <a-descriptions-item label="手机号">{{ memberInfo.phone || '-' }}</a-descriptions-item>
            <a-descriptions-item label="生日">{{ memberInfo.birthday || '-' }}</a-descriptions-item>
            <a-descriptions-item label="来源渠道">{{ channelTextMap[memberInfo.sourceChannel] || memberInfo.sourceChannel || '-' }}</a-descriptions-item>
            <a-descriptions-item label="状态">
              <a-tag :color="memberInfo.status === 1 ? 'green' : 'red'">
                {{ memberInfo.status === 1 ? '正常' : '冻结' }}
              </a-tag>
            </a-descriptions-item>
            <a-descriptions-item label="标签">
              <a-tag v-for="tag in memberInfo.tags" :key="tag" color="arcoblue" style="margin: 2px">
                {{ tag }}
              </a-tag>
              <span v-if="!memberInfo.tags || memberInfo.tags.length === 0">-</span>
            </a-descriptions-item>
            <a-descriptions-item label="注册时间">{{ formatDate(memberInfo.createdAt) }}</a-descriptions-item>
          </a-descriptions>
        </a-card>
      </a-col>
      <a-col :span="16">
        <a-card :bordered="false">
          <a-tabs default-active-key="cards">
            <a-tab-pane key="cards" title="卡实例列表">
              <a-table
                :columns="cardColumns"
                :data="cardList"
                :loading="cardLoading"
                :pagination="false"
                size="small"
              >
                <template #cardType="{ record }">
                  <a-tag :color="cardTypeColorMap[record.cardType]">{{ record.cardType }}</a-tag>
                </template>
                <template #status="{ record }">
                  <a-tag :color="cardStatusColorMap[record.status]">{{ cardStatusTextMap[record.status] }}</a-tag>
                </template>
                <template #balance="{ record }">
                  <span v-if="record.cardType === '储值卡'">{{ record.balance?.toFixed(2) }} 元</span>
                  <span v-else-if="record.cardType === '次卡'">剩余 {{ record.remainCount }} 次</span>
                  <span v-else>-</span>
                </template>
                <template #validity="{ record }">
                  {{ record.validityEndDate || `${record.validityDays}天` }}
                </template>
              </a-table>
            </a-tab-pane>
            <a-tab-pane key="logs" title="操作日志">
              <a-table
                :columns="logColumns"
                :data="logList"
                :loading="logLoading"
                :pagination="logPagination"
                size="small"
                @page-change="handleLogPageChange"
              >
                <template #time="{ record }">
                  {{ formatDate(record.createdAt) }}
                </template>
                <template #type="{ record }">
                  <a-tag :color="logTypeColorMap[record.type] || 'blue'">{{ record.type }}</a-tag>
                </template>
              </a-table>
            </a-tab-pane>
          </a-tabs>
        </a-card>
      </a-col>
    </a-row>

    <a-modal v-model:visible="editVisible" title="编辑会员信息" @ok="handleSaveEdit" :ok-loading="editLoading">
      <a-form :model="editForm" layout="vertical">
        <a-form-item label="姓名" required>
          <a-input v-model="editForm.name" />
        </a-form-item>
        <a-form-item label="手机号" required>
          <a-input v-model="editForm.phone" />
        </a-form-item>
        <a-form-item label="生日">
          <a-date-picker v-model="editForm.birthday" style="width: 100%" />
        </a-form-item>
        <a-form-item label="标签">
          <a-select v-model="editForm.tags" multiple allow-create placeholder="请选择标签">
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
import { useRoute } from 'vue-router';
import { Message } from '@arco-design/web-vue';
import { memberApi } from '@/api';

const route = useRoute();
const memberId = Number(route.params.id);

const memberInfo = ref<any>({});
const cardList = ref<any[]>([]);
const logList = ref<any[]>([]);
const cardLoading = ref(false);
const logLoading = ref(false);
const editVisible = ref(false);
const editLoading = ref(false);

const editForm = reactive({
  name: '',
  phone: '',
  birthday: '',
  tags: [] as string[],
});

const channelTextMap: Record<string, string> = {
  walk_in: '到店',
  referral: '转介绍',
  online: '线上',
  activity: '活动',
};

const cardTypeColorMap: Record<string, string> = {
  '次卡': 'arcoblue',
  '储值卡': 'green',
  '期限卡': 'purple',
};

const cardStatusTextMap: Record<string, string> = {
  active: '有效',
  expired: '已过期',
  used_up: '已用完',
  frozen: '已冻结',
};

const cardStatusColorMap: Record<string, string> = {
  active: 'green',
  expired: 'gray',
  used_up: 'orange',
  frozen: 'red',
};

const logTypeColorMap: Record<string, string> = {
  '消费': 'blue',
  '充值': 'green',
  '开卡': 'purple',
  '调整': 'orange',
};

const logPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const cardColumns = [
  { title: '卡号', dataIndex: 'cardNo', width: 160 },
  { title: '卡类型', dataIndex: 'cardType', width: 100, slotName: 'cardType' },
  { title: '套餐名称', dataIndex: 'packageName', width: 140 },
  { title: '余额/次数', width: 120, slotName: 'balance' },
  { title: '有效期', dataIndex: 'validityEndDate', width: 120, slotName: 'validity' },
  { title: '状态', dataIndex: 'status', width: 80, slotName: 'status' },
];

const logColumns = [
  { title: '时间', dataIndex: 'createdAt', width: 180, slotName: 'time' },
  { title: '类型', dataIndex: 'type', width: 80, slotName: 'type' },
  { title: '描述', dataIndex: 'description', ellipsis: true },
  { title: '操作人', dataIndex: 'operator', width: 100 },
  { title: '金额/次数', dataIndex: 'amount', width: 120 },
];

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('zh-CN');
};

const fetchMemberInfo = async () => {
  try {
    const res = await memberApi.get(memberId);
    memberInfo.value = res.data.data;
  } catch (error: any) {
    Message.error(error.message || '获取会员信息失败');
  }
};

const fetchCards = async () => {
  cardLoading.value = true;
  try {
    const res = await memberApi.getCards(memberId);
    cardList.value = res.data.data || [];
  } catch (error: any) {
    Message.error(error.message || '获取卡实例失败');
  } finally {
    cardLoading.value = false;
  }
};

const fetchLogs = async () => {
  logLoading.value = true;
  try {
    const res = await import('@/api/request').then((m) =>
      m.default.get(`/member/${memberId}/logs`, {
        params: { page: logPagination.current, size: logPagination.pageSize },
      })
    );
    logList.value = res.data.data.list || [];
    logPagination.total = res.data.data.total || 0;
  } catch (error: any) {
    Message.error(error.message || '获取操作日志失败');
  } finally {
    logLoading.value = false;
  }
};

const handleLogPageChange = (page: number) => {
  logPagination.current = page;
  fetchLogs();
};

const handleEdit = () => {
  Object.assign(editForm, {
    name: memberInfo.value.name,
    phone: memberInfo.value.phone,
    birthday: memberInfo.value.birthday,
    tags: memberInfo.value.tags || [],
  });
  editVisible.value = true;
};

const handleSaveEdit = async () => {
  if (!editForm.name.trim() || !editForm.phone.trim()) {
    Message.warning('请填写必填项');
    return;
  }
  editLoading.value = true;
  try {
    await memberApi.update(memberId, editForm);
    Message.success('编辑成功');
    editVisible.value = false;
    fetchMemberInfo();
  } catch (error: any) {
    Message.error(error.message || '编辑失败');
  } finally {
    editLoading.value = false;
  }
};

onMounted(() => {
  fetchMemberInfo();
  fetchCards();
  fetchLogs();
});
</script>

<style scoped>
.member-detail {
  padding: 16px;
}
</style>
