<template>
  <div class="consume-verify">
    <a-card :bordered="false" title="快速核销">
      <a-steps :current="currentStep" style="margin-bottom: 24px">
        <a-step title="输入手机号" />
        <a-step title="选择服务项目" />
        <a-step title="确认核销" />
      </a-steps>

      <!-- Step 1: 输入手机号 -->
      <div v-if="currentStep === 0" class="step-content">
        <a-form :model="verifyForm" layout="vertical" style="max-width: 400px">
          <a-form-item label="会员手机号" required>
            <a-input-search
              v-model="verifyForm.phone"
              placeholder="请输入会员手机号"
              search-button
              button-text="查询"
              :loading="searchLoading"
              @search="handleSearchMember"
              @press-enter="handleSearchMember"
            />
          </a-form-item>
        </a-form>

        <div v-if="memberInfo" class="member-info">
          <a-descriptions :column="3" bordered size="small" title="会员信息">
            <a-descriptions-item label="姓名">{{ memberInfo.name }}</a-descriptions-item>
            <a-descriptions-item label="手机号">{{ memberInfo.phone }}</a-descriptions-item>
            <a-descriptions-item label="标签">
              <a-tag v-for="tag in memberInfo.tags" :key="tag">{{ tag }}</a-tag>
            </a-descriptions-item>
          </a-descriptions>
          <a-button type="primary" style="margin-top: 16px" @click="currentStep = 1">
            下一步：选择服务项目
          </a-button>
        </div>
      </div>

      <!-- Step 2: 选择服务项目 -->
      <div v-if="currentStep === 1" class="step-content">
        <a-form :model="verifyForm" layout="vertical" style="max-width: 600px">
          <a-form-item label="服务项目" required>
            <a-select
              v-model="verifyForm.serviceItemId"
              placeholder="请选择服务项目"
              :loading="serviceLoading"
              @change="handleServiceChange"
            >
              <a-option v-for="s in serviceList" :key="s.id" :value="s.id">
                {{ s.name }} - {{ s.price.toFixed(2) }}元 / {{ s.duration }}分钟
              </a-option>
            </a-select>
          </a-form-item>
          <a-form-item label="服务员工" required>
            <a-select v-model="verifyForm.serviceStaffId" placeholder="请选择服务员工" :loading="staffLoading">
              <a-option v-for="s in staffList" :key="s.id" :value="s.id">{{ s.name }}</a-option>
            </a-select>
          </a-form-item>
        </a-form>

        <div v-if="availableCards.length > 0" class="card-match">
          <h4>可用卡匹配</h4>
          <a-radio-group v-model="verifyForm.cardId" type="card">
            <a-radio v-for="card in availableCards" :key="card.id" :value="card.id">
              <div class="card-option">
                <div class="card-name">{{ card.cardNo }}</div>
                <div class="card-detail">
                  <a-tag size="small">{{ card.cardType }}</a-tag>
                  <span v-if="card.cardType === '储值卡'">余额: {{ card.balance?.toFixed(2) }}元</span>
                  <span v-else-if="card.cardType === '次卡'">剩余: {{ card.remainCount }}次</span>
                  <span v-else>有效期内</span>
                </div>
              </div>
            </a-radio>
          </a-radio-group>
        </div>
        <div v-else-if="verifyForm.serviceItemId" class="no-card-tip">
          <a-empty description="未匹配到可用卡，将按单次购买计费" />
        </div>

        <div style="margin-top: 16px">
          <a-space>
            <a-button @click="currentStep = 0">上一步</a-button>
            <a-button type="primary" :disabled="!verifyForm.serviceItemId || !verifyForm.serviceStaffId" @click="currentStep = 2">
              下一步：确认核销
            </a-button>
          </a-space>
        </div>
      </div>

      <!-- Step 3: 确认核销 -->
      <div v-if="currentStep === 2" class="step-content">
        <a-descriptions :column="2" bordered title="核销确认" size="medium">
          <a-descriptions-item label="会员姓名">{{ memberInfo?.name }}</a-descriptions-item>
          <a-descriptions-item label="会员手机号">{{ memberInfo?.phone }}</a-descriptions-item>
          <a-descriptions-item label="服务项目">{{ selectedService?.name }}</a-descriptions-item>
          <a-descriptions-item label="服务价格">{{ selectedService?.price.toFixed(2) }} 元</a-descriptions-item>
          <a-descriptions-item label="服务员工">{{ selectedStaff?.name }}</a-descriptions-item>
          <a-descriptions-item label="使用卡">
            <span v-if="selectedCard">{{ selectedCard.cardNo }} ({{ selectedCard.cardType }})</span>
            <a-tag v-else color="orange">单次购买</a-tag>
          </a-descriptions-item>
        </a-descriptions>

        <div style="margin-top: 24px">
          <a-space>
            <a-button @click="currentStep = 1">上一步</a-button>
            <a-button type="primary" :loading="verifyLoading" @click="handleVerify">
              确认核销
            </a-button>
          </a-space>
        </div>
      </div>
    </a-card>

    <!-- 核销结果弹窗 -->
    <a-modal v-model:visible="resultVisible" title="核销成功" :footer="false">
      <a-result status="success" title="核销完成">
        <template #extra>
          <div v-if="verifyResult">
            <a-descriptions :column="1" bordered size="small">
              <a-descriptions-item label="订单号">{{ verifyResult.orderNo }}</a-descriptions-item>
              <a-descriptions-item label="扣减前">{{ verifyResult.deductBefore }}</a-descriptions-item>
              <a-descriptions-item label="扣减后">{{ verifyResult.deductAfter }}</a-descriptions-item>
            </a-descriptions>
          </div>
          <a-button type="primary" style="margin-top: 16px" @click="handleReset">
            继续核销
          </a-button>
        </template>
      </a-result>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { Message } from '@arco-design/web-vue';
import { consumeApi } from '@/api';
import request from '@/api/request';

const currentStep = ref(0);
const searchLoading = ref(false);
const serviceLoading = ref(false);
const staffLoading = ref(false);
const verifyLoading = ref(false);
const resultVisible = ref(false);

const memberInfo = ref<any>(null);
const serviceList = ref<any[]>([]);
const staffList = ref<any[]>([]);
const availableCards = ref<any[]>([]);
const verifyResult = ref<any>(null);

const verifyForm = reactive({
  phone: '',
  serviceItemId: undefined as number | undefined,
  serviceStaffId: undefined as number | undefined,
  cardId: undefined as number | undefined,
});

const selectedService = computed(() =>
  serviceList.value.find((s) => s.id === verifyForm.serviceItemId)
);

const selectedStaff = computed(() =>
  staffList.value.find((s) => s.id === verifyForm.serviceStaffId)
);

const selectedCard = computed(() =>
  availableCards.value.find((c) => c.id === verifyForm.cardId)
);

const handleSearchMember = async () => {
  if (!verifyForm.phone.trim()) {
    Message.warning('请输入手机号');
    return;
  }
  searchLoading.value = true;
  try {
    const res = await request.get('/member/search', {
      params: { phone: verifyForm.phone },
    });
    memberInfo.value = res.data.data;
    if (!memberInfo.value) {
      Message.warning('未找到该会员');
    }
  } catch (error: any) {
    Message.error(error.message || '查询会员失败');
  } finally {
    searchLoading.value = false;
  }
};

const fetchServices = async () => {
  serviceLoading.value = true;
  try {
    const res = await request.get('/service/list', {
      params: { page: 1, size: 100, status: 1 },
    });
    serviceList.value = res.data.data.list || [];
  } catch (error: any) {
    Message.error(error.message || '获取服务项目失败');
  } finally {
    serviceLoading.value = false;
  }
};

const fetchStaffs = async () => {
  staffLoading.value = true;
  try {
    const res = await request.get('/employee/list', {
      params: { page: 1, size: 100, status: 1 },
    });
    staffList.value = res.data.data.list || [];
  } catch (error: any) {
    Message.error(error.message || '获取员工列表失败');
  } finally {
    staffLoading.value = false;
  }
};

const handleServiceChange = async (serviceItemId: number) => {
  verifyForm.cardId = undefined;
  availableCards.value = [];
  if (!memberInfo.value || !serviceItemId) return;
  try {
    const res = await consumeApi.getAvailableCards(memberInfo.value.id, serviceItemId);
    availableCards.value = res.data.data || [];
  } catch (error: any) {
    Message.error(error.message || '获取可用卡失败');
  }
};

const handleVerify = async () => {
  verifyLoading.value = true;
  try {
    const res = await consumeApi.verify({
      memberId: memberInfo.value.id,
      serviceItemId: verifyForm.serviceItemId!,
      serviceStaffId: verifyForm.serviceStaffId!,
      cardId: verifyForm.cardId,
    });
    verifyResult.value = res.data.data;
    resultVisible.value = true;
  } catch (error: any) {
    Message.error(error.message || '核销失败');
  } finally {
    verifyLoading.value = false;
  }
};

const handleReset = () => {
  currentStep.value = 0;
  memberInfo.value = null;
  verifyForm.phone = '';
  verifyForm.serviceItemId = undefined;
  verifyForm.serviceStaffId = undefined;
  verifyForm.cardId = undefined;
  availableCards.value = [];
  verifyResult.value = null;
  resultVisible.value = false;
};

onMounted(() => {
  fetchServices();
  fetchStaffs();
});
</script>

<style scoped>
.consume-verify {
  padding: 16px;
}

.step-content {
  padding: 16px 0;
}

.member-info {
  margin-top: 16px;
}

.card-match {
  margin-top: 16px;
}

.card-match h4 {
  margin-bottom: 12px;
}

.card-option {
  padding: 4px 0;
}

.card-name {
  font-weight: bold;
  margin-bottom: 4px;
}

.card-detail {
  color: var(--color-text-2);
  font-size: 12px;
}

.no-card-tip {
  margin-top: 16px;
}
</style>
