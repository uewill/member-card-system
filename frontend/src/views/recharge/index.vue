<template>
  <div class="recharge-page">
    <a-card :bordered="false" title="售卖开卡 / 充值">
      <a-steps :current="currentStep" style="margin-bottom: 24px">
        <a-step title="选择套餐" />
        <a-step title="选择会员" />
        <a-step title="支付确认" />
      </a-steps>

      <!-- Step 1: 选择套餐 -->
      <div v-if="currentStep === 0" class="step-content">
        <a-form :model="form" layout="inline" style="margin-bottom: 16px">
          <a-form-item label="套餐类型">
            <a-select v-model="form.typeFilter" placeholder="全部" allow-clear style="width: 140px" @change="fetchPackages">
              <a-option value="times">次卡</a-option>
              <a-option value="amount">储值卡</a-option>
              <a-option value="period">期限卡</a-option>
            </a-select>
          </a-form-item>
        </a-form>

        <a-row :gutter="16">
          <a-col v-for="pkg in packageList" :key="pkg.id" :span="8" style="margin-bottom: 16px">
            <a-card
              hoverable
              :class="{ 'selected-card': form.packageId === pkg.id }"
              @click="selectPackage(pkg)"
            >
              <template #title>
                <div class="pkg-title">
                  <a-tag :color="typeColorMap[pkg.type]">{{ typeTextMap[pkg.type] }}</a-tag>
                  {{ pkg.name }}
                </div>
              </template>
              <div class="pkg-price">
                <span class="price-value">{{ pkg.salePrice.toFixed(2) }}</span>
                <span class="price-unit">元</span>
              </div>
              <div class="pkg-info">
                <div v-if="pkg.validityDays">有效期：{{ pkg.validityDays }}天</div>
                <div v-if="pkg.allowTransfer">支持转赠</div>
                <div v-if="pkg.allowCombine">支持叠加</div>
              </div>
            </a-card>
          </a-col>
        </a-row>

        <a-button
          type="primary"
          :disabled="!form.packageId"
          @click="currentStep = 1"
        >
          下一步：选择会员
        </a-button>
      </div>

      <!-- Step 2: 选择会员 -->
      <div v-if="currentStep === 1" class="step-content">
        <a-form layout="inline" style="margin-bottom: 16px">
          <a-form-item label="会员手机号">
            <a-input-search
              v-model="memberSearchPhone"
              placeholder="请输入会员手机号"
              search-button
              button-text="查询"
              :loading="memberSearchLoading"
              @search="handleSearchMember"
            />
          </a-form-item>
        </a-form>

        <a-table
          v-if="memberSearchResults.length > 0"
          :columns="memberColumns"
          :data="memberSearchResults"
          :pagination="false"
          size="small"
          :row-selection="{ type: 'radio', showCheckedAll: false }"
          @row-click="handleSelectMember"
          :selected-keys="form.memberId ? [form.memberId] : []"
        >
          <template #tags="{ record }">
            <a-tag v-for="tag in record.tags" :key="tag" size="small">{{ tag }}</a-tag>
          </template>
        </a-table>

        <div style="margin-top: 16px">
          <a-space>
            <a-button @click="currentStep = 0">上一步</a-button>
            <a-button type="primary" :disabled="!form.memberId" @click="currentStep = 2">
              下一步：支付确认
            </a-button>
          </a-space>
        </div>
      </div>

      <!-- Step 3: 支付确认 -->
      <div v-if="currentStep === 2" class="step-content">
        <a-descriptions :column="2" bordered title="订单确认" size="medium">
          <a-descriptions-item label="套餐名称">{{ selectedPackage?.name }}</a-descriptions-item>
          <a-descriptions-item label="套餐类型">{{ typeTextMap[selectedPackage?.type || ''] }}</a-descriptions-item>
          <a-descriptions-item label="会员姓名">{{ selectedMember?.name }}</a-descriptions-item>
          <a-descriptions-item label="会员手机号">{{ selectedMember?.phone }}</a-descriptions-item>
          <a-descriptions-item label="应付金额">
            <span style="color: #f53f3f; font-weight: bold; font-size: 18px">
              {{ selectedPackage?.salePrice.toFixed(2) }} 元
            </span>
          </a-descriptions-item>
          <a-descriptions-item label="支付方式">
            <a-radio-group v-model="form.payMethod">
              <a-radio value="cash">现金</a-radio>
              <a-radio value="wechat">微信</a-radio>
              <a-radio value="alipay">支付宝</a-radio>
              <a-radio value="bank">银行卡</a-radio>
            </a-radio-group>
          </a-descriptions-item>
        </a-descriptions>

        <div style="margin-top: 24px">
          <a-space>
            <a-button @click="currentStep = 1">上一步</a-button>
            <a-button type="primary" :loading="submitLoading" @click="handleSubmit">
              确认支付
            </a-button>
          </a-space>
        </div>
      </div>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import request from '@/api/request';

const currentStep = ref(0);
const memberSearchPhone = ref('');
const memberSearchLoading = ref(false);
const submitLoading = ref(false);
const packageList = ref<any[]>([]);
const memberSearchResults = ref<any[]>([]);

const form = reactive({
  packageId: undefined as number | undefined,
  memberId: undefined as number | undefined,
  payMethod: 'cash',
  typeFilter: undefined as string | undefined,
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

const memberColumns = [
  { title: '姓名', dataIndex: 'name', width: 100 },
  { title: '手机号', dataIndex: 'phone', width: 140 },
  { title: '标签', dataIndex: 'tags', slotName: 'tags', width: 180 },
];

const selectedPackage = computed(() =>
  packageList.value.find((p) => p.id === form.packageId)
);

const selectedMember = computed(() =>
  memberSearchResults.value.find((m) => m.id === form.memberId)
);

const fetchPackages = async () => {
  try {
    const res = await request.get('/package/list', {
      params: {
        page: 1,
        size: 100,
        status: 1,
        type: form.typeFilter,
      },
    });
    packageList.value = res.data.data.list || [];
  } catch (error: any) {
    Message.error(error.message || '获取套餐列表失败');
  }
};

const selectPackage = (pkg: any) => {
  form.packageId = pkg.id;
};

const handleSearchMember = async () => {
  if (!memberSearchPhone.value.trim()) {
    Message.warning('请输入手机号');
    return;
  }
  memberSearchLoading.value = true;
  try {
    const res = await request.get('/member/list', {
      params: { page: 1, size: 20, phone: memberSearchPhone.value },
    });
    memberSearchResults.value = res.data.data.list || [];
    if (memberSearchResults.value.length === 0) {
      Message.warning('未找到匹配的会员');
    }
  } catch (error: any) {
    Message.error(error.message || '查询会员失败');
  } finally {
    memberSearchLoading.value = false;
  }
};

const handleSelectMember = (record: any) => {
  form.memberId = record.id;
};

const handleSubmit = async () => {
  submitLoading.value = true;
  try {
    await request.post('/recharge', {
      packageId: form.packageId,
      memberId: form.memberId,
      payMethod: form.payMethod,
    });
    Message.success('开卡/充值成功');
    handleReset();
  } catch (error: any) {
    Message.error(error.message || '操作失败');
  } finally {
    submitLoading.value = false;
  }
};

const handleReset = () => {
  currentStep.value = 0;
  form.packageId = undefined;
  form.memberId = undefined;
  form.payMethod = 'cash';
  memberSearchPhone.value = '';
  memberSearchResults.value = [];
};

onMounted(() => {
  fetchPackages();
});
</script>

<style scoped>
.recharge-page {
  padding: 16px;
}

.step-content {
  padding: 16px 0;
}

.selected-card {
  border-color: #165dff;
  box-shadow: 0 0 0 1px #165dff;
}

.pkg-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pkg-price {
  text-align: center;
  padding: 16px 0;
}

.price-value {
  font-size: 28px;
  font-weight: bold;
  color: #f53f3f;
}

.price-unit {
  font-size: 14px;
  color: var(--color-text-2);
}

.pkg-info {
  color: var(--color-text-2);
  font-size: 13px;
  line-height: 1.8;
}
</style>
