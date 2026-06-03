import { createRouter, createWebHistory } from 'vue-router';
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    name: 'Root',
    component: () => import('@/layouts/default.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '首页', icon: 'icon-home' },
      },
      {
        path: 'platform-stats',
        name: 'PlatformStats',
        component: () => import('@/views/platform-stats/index.vue'),
        meta: { title: '平台运营监控', icon: 'icon-dashboard' },
      },
      {
        path: 'tenant',
        name: 'Tenant',
        meta: { title: '租户管理', icon: 'icon-user-group' },
        children: [
          {
            path: 'list',
            name: 'TenantList',
            component: () => import('@/views/tenant/list.vue'),
            meta: { title: '租户列表' },
          },
        ],
      },
      {
        path: 'store',
        name: 'Store',
        meta: { title: '门店管理', icon: 'icon-location' },
        children: [
          {
            path: 'list',
            name: 'StoreList',
            component: () => import('@/views/store/list.vue'),
            meta: { title: '门店列表' },
          },
        ],
      },
      {
        path: 'employee',
        name: 'Employee',
        meta: { title: '员工管理', icon: 'icon-user' },
        children: [
          {
            path: 'list',
            name: 'EmployeeList',
            component: () => import('@/views/employee/list.vue'),
            meta: { title: '员工列表' },
          },
        ],
      },
      {
        path: 'service',
        name: 'Service',
        meta: { title: '服务项目', icon: 'icon-apps' },
        children: [
          {
            path: 'list',
            name: 'ServiceList',
            component: () => import('@/views/service/list.vue'),
            meta: { title: '项目列表' },
          },
        ],
      },
      {
        path: 'package',
        name: 'Package',
        meta: { title: '套餐管理', icon: 'icon-tag' },
        children: [
          {
            path: 'list',
            name: 'PackageList',
            component: () => import('@/views/package/list.vue'),
            meta: { title: '套餐列表' },
          },
        ],
      },
      {
        path: 'member',
        name: 'Member',
        meta: { title: '会员管理', icon: 'icon-heart' },
        children: [
          {
            path: 'list',
            name: 'MemberList',
            component: () => import('@/views/member/list.vue'),
            meta: { title: '会员列表' },
          },
          {
            path: 'detail/:id',
            name: 'MemberDetail',
            component: () => import('@/views/member/detail.vue'),
            meta: { title: '会员详情', hideInMenu: true },
          },
        ],
      },
      {
        path: 'card',
        name: 'Card',
        meta: { title: '卡实例管理', icon: 'icon-credit-card' },
        children: [
          {
            path: 'list',
            name: 'CardList',
            component: () => import('@/views/card/list.vue'),
            meta: { title: '卡列表' },
          },
        ],
      },
      {
        path: 'consume',
        name: 'Consume',
        meta: { title: '消费核销', icon: 'icon-check-circle' },
        children: [
          {
            path: 'verify',
            name: 'ConsumeVerify',
            component: () => import('@/views/consume/verify.vue'),
            meta: { title: '快速核销' },
          },
          {
            path: 'records',
            name: 'ConsumeRecords',
            component: () => import('@/views/consume/records.vue'),
            meta: { title: '消费记录' },
          },
        ],
      },
      {
        path: 'recharge',
        name: 'Recharge',
        component: () => import('@/views/recharge/index.vue'),
        meta: { title: '售卖开卡/充值', icon: 'icon-credit-card' },
      },
      {
        path: 'performance',
        name: 'Performance',
        component: () => import('@/views/performance/index.vue'),
        meta: { title: '业绩统计', icon: 'icon-bar-chart' },
      },
      {
        path: 'report',
        name: 'Report',
        meta: { title: '报表中心', icon: 'icon-line-chart' },
        children: [
          {
            path: 'daily',
            name: 'ReportDaily',
            component: () => import('@/views/report/daily.vue'),
            meta: { title: '营业日报' },
          },
          {
            path: 'package',
            name: 'ReportPackage',
            component: () => import('@/views/report/package.vue'),
            meta: { title: '套餐分析' },
          },
          {
            path: 'member',
            name: 'ReportMember',
            component: () => import('@/views/report/member.vue'),
            meta: { title: '会员分析' },
          },
        ],
      },
      {
        path: 'marketing',
        name: 'Marketing',
        meta: { title: '营销工具', icon: 'icon-gift' },
        children: [
          {
            path: 'points',
            name: 'MarketingPoints',
            component: () => import('@/views/marketing/points.vue'),
            meta: { title: '积分管理' },
          },
          {
            path: 'coupon',
            name: 'MarketingCoupon',
            component: () => import('@/views/marketing/coupon.vue'),
            meta: { title: '优惠券管理' },
          },
        ],
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// 路由守卫
router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('token');
  
  if (to.meta.requiresAuth === false) {
    next();
  } else if (!token) {
    next('/login');
  } else {
    next();
  }
});

export default router;