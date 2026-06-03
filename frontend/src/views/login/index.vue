<template>
  <div class="login-container">
    <a-card class="login-card" :bordered="false">
      <template #title>
        <div class="login-title">会员管理系统</div>
      </template>
      <a-form :model="form" @submit="handleLogin">
        <a-form-item field="phone" label="手机号" :rules="[{ required: true, message: '请输入手机号' }]">
          <a-input v-model="form.phone" placeholder="请输入手机号" />
        </a-form-item>
        <a-form-item field="password" label="密码" :rules="[{ required: true, message: '请输入密码' }]">
          <a-input-password v-model="form.password" placeholder="请输入密码" />
        </a-form-item>
        <a-form-item>
          <a-button type="primary" html-type="submit" long :loading="loading">
            登录
          </a-button>
        </a-form-item>
      </a-form>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { Message } from '@arco-design/web-vue';
import { authApi } from '@/api';

const router = useRouter();
const loading = ref(false);
const form = ref({
  phone: '',
  password: '',
});

const handleLogin = async () => {
  loading.value = true;
  try {
    const res = await authApi.login(form.value);
    const { token, user } = res.data.data;
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(user));
    Message.success('登录成功');
    router.push('/dashboard');
  } catch (error: any) {
    Message.error(error.message || '登录失败');
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  width: 100%;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
  width: 400px;
}

.login-title {
  text-align: center;
  font-size: 24px;
  font-weight: bold;
}
</style>