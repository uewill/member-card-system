<template>
  <div class="dashboard">
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card title="今日营业额" :bordered="false">
          <a-statistic :value="12345" :precision="2" suffix="元" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="今日消费次数" :bordered="false">
          <a-statistic :value="56" suffix="次" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="新增会员" :bordered="false">
          <a-statistic :value="12" suffix="人" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="活跃会员" :bordered="false">
          <a-statistic :value="234" suffix="人" />
        </a-card>
      </a-col>
    </a-row>
    
    <a-card title="快捷操作" :bordered="false" style="margin-top: 16px">
      <a-space>
        <a-button type="primary" @click="$router.push('/consume/verify')">
          快速核销
        </a-button>
        <a-button @click="$router.push('/member/list')">
          会员查询
        </a-button>
        <a-button @click="$router.push('/package/list')">
          售卖开卡
        </a-button>
      </a-space>
    </a-card>
  </div>
</template>

<script setup lang="ts">
</script>

<style scoped>
.dashboard {
  padding: 16px;
}
</style>