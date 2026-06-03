<template>
  <a-layout class="layout">
    <a-layout-sider :width="220" collapsible>
      <div class="logo">会员管理系统</div>
      <a-menu :selected-keys="[currentKey]" @menu-item-click="handleMenuClick">
        <a-menu-item key="dashboard">
          <template #icon><icon-home /></template>
          首页
        </a-menu-item>
        <a-menu-item key="platform-stats">
          <template #icon><icon-dashboard /></template>
          平台运营监控
        </a-menu-item>
        <a-sub-menu key="tenant">
          <template #icon><icon-user-group /></template>
          <template #title>租户管理</template>
          <a-menu-item key="tenant-list">租户列表</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="store">
          <template #icon><icon-location /></template>
          <template #title>门店管理</template>
          <a-menu-item key="store-list">门店列表</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="employee">
          <template #icon><icon-user /></template>
          <template #title>员工管理</template>
          <a-menu-item key="employee-list">员工列表</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="service">
          <template #icon><icon-apps /></template>
          <template #title>服务项目</template>
          <a-menu-item key="service-list">项目列表</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="package">
          <template #icon><icon-tag /></template>
          <template #title>套餐管理</template>
          <a-menu-item key="package-list">套餐列表</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="member">
          <template #icon><icon-heart /></template>
          <template #title>会员管理</template>
          <a-menu-item key="member-list">会员列表</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="consume">
          <template #icon><icon-check-circle /></template>
          <template #title>消费核销</template>
          <a-menu-item key="consume-verify">快速核销</a-menu-item>
          <a-menu-item key="consume-records">消费记录</a-menu-item>
        </a-sub-menu>
        <a-menu-item key="recharge">
          <template #icon><icon-credit-card /></template>
          售卖开卡/充值
        </a-menu-item>
        <a-menu-item key="performance">
          <template #icon><icon-bar-chart /></template>
          业绩统计
        </a-menu-item>
        <a-sub-menu key="report">
          <template #icon><icon-line-chart /></template>
          <template #title>报表中心</template>
          <a-menu-item key="report-daily">营业日报</a-menu-item>
          <a-menu-item key="report-package">套餐分析</a-menu-item>
          <a-menu-item key="report-member">会员分析</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="marketing">
          <template #icon><icon-gift /></template>
          <template #title>营销工具</template>
          <a-menu-item key="marketing-points">积分管理</a-menu-item>
          <a-menu-item key="marketing-coupon">优惠券管理</a-menu-item>
        </a-sub-menu>
      </a-menu>
    </a-layout-sider>
    <a-layout>
      <a-layout-header class="header">
        <a-space>
          <span>{{ user?.name }}</span>
          <a-button size="small" @click="handleLogout">退出</a-button>
        </a-space>
      </a-layout-header>
      <a-layout-content class="content">
        <router-view />
      </a-layout-content>
    </a-layout>
  </a-layout>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { Message } from '@arco-design/web-vue';
import {
  IconHome,
  IconDashboard,
  IconUserGroup,
  IconLocation,
  IconUser,
  IconApps,
  IconTag,
  IconHeart,
  IconCheckCircle,
  IconCreditCard,
  IconBarChart,
  IconLineChart,
  IconGift,
} from '@arco-design/web-vue/es/icon';

const router = useRouter();
const route = useRoute();

const user = computed(() => {
  const userStr = localStorage.getItem('user');
  return userStr ? JSON.parse(userStr) : null;
});

const currentKey = computed(() => {
  const path = route.path;
  if (path === '/dashboard') return 'dashboard';
  if (path.startsWith('/platform-stats')) return 'platform-stats';
  if (path.startsWith('/tenant')) return 'tenant-list';
  if (path.startsWith('/store')) return 'store-list';
  if (path.startsWith('/employee')) return 'employee-list';
  if (path.startsWith('/service')) return 'service-list';
  if (path.startsWith('/package')) return 'package-list';
  if (path.startsWith('/member')) return 'member-list';
  if (path.startsWith('/consume/verify')) return 'consume-verify';
  if (path.startsWith('/consume/records')) return 'consume-records';
  if (path.startsWith('/recharge')) return 'recharge';
  if (path.startsWith('/performance')) return 'performance';
  if (path.startsWith('/report/daily')) return 'report-daily';
  if (path.startsWith('/report/package')) return 'report-package';
  if (path.startsWith('/report/member')) return 'report-member';
  if (path.startsWith('/marketing/points')) return 'marketing-points';
  if (path.startsWith('/marketing/coupon')) return 'marketing-coupon';
  return 'dashboard';
});

const handleMenuClick = (key: string) => {
  const pathMap: Record<string, string> = {
    'dashboard': '/dashboard',
    'platform-stats': '/platform-stats',
    'tenant-list': '/tenant/list',
    'store-list': '/store/list',
    'employee-list': '/employee/list',
    'service-list': '/service/list',
    'package-list': '/package/list',
    'member-list': '/member/list',
    'consume-verify': '/consume/verify',
    'consume-records': '/consume/records',
    'recharge': '/recharge',
    'performance': '/performance',
    'report-daily': '/report/daily',
    'report-package': '/report/package',
    'report-member': '/report/member',
    'marketing-points': '/marketing/points',
    'marketing-coupon': '/marketing/coupon',
  };
  router.push(pathMap[key] || '/dashboard');
};

const handleLogout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  Message.success('已退出登录');
  router.push('/login');
};
</script>

<style scoped>
.layout {
  height: 100vh;
}

.logo {
  height: 40px;
  line-height: 40px;
  text-align: center;
  font-size: 16px;
  font-weight: bold;
  color: #fff;
  background: #165dff;
}

.header {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding-right: 16px;
  background: #fff;
  border-bottom: 1px solid #e5e6eb;
}

.content {
  padding: 16px;
  background: #f7f8fa;
}
</style>