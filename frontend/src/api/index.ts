import request from './request';
import type { ApiResponse, PageParams, PageResult } from './types';

// 会员相关 API
export interface Member {
  id: number;
  tenantId: number;
  phone: string;
  name: string;
  birthday: string;
  tags: string[];
  sourceChannel: string;
  status: number;
  createdAt: string;
}

export interface MemberQuery extends PageParams {
  phone?: string;
  name?: string;
  tags?: string;
}

export const memberApi = {
  list: (params: MemberQuery) =>
    request.get<ApiResponse<PageResult<Member>>>('/member/list', { params }),
  
  get: (id: number) =>
    request.get<ApiResponse<Member>>(`/member/${id}`),
  
  create: (data: Partial<Member>) =>
    request.post<ApiResponse<Member>>('/member', data),
  
  update: (id: number, data: Partial<Member>) =>
    request.put<ApiResponse<Member>>(`/member/${id}`, data),
  
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/member/${id}`),
  
  getCards: (id: number) =>
    request.get<ApiResponse<any[]>>(`/member/${id}/cards`),
};

// 服务项目相关 API
export interface ServiceItem {
  id: number;
  tenantId: number;
  category: string;
  name: string;
  price: number;
  duration: number;
  canSinglePurchase: boolean;
  status: number;
}

export const serviceApi = {
  list: (params: PageParams) =>
    request.get<ApiResponse<PageResult<ServiceItem>>>('/service/list', { params }),
  
  create: (data: Partial<ServiceItem>) =>
    request.post<ApiResponse<ServiceItem>>('/service', data),
  
  update: (id: number, data: Partial<ServiceItem>) =>
    request.put<ApiResponse<ServiceItem>>(`/service/${id}`, data),
  
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/service/${id}`),
};

// 套餐相关 API
export interface PackageTemplate {
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

export const packageApi = {
  list: (params: PageParams) =>
    request.get<ApiResponse<PageResult<PackageTemplate>>>('/package/list', { params }),
  
  create: (data: Partial<PackageTemplate>) =>
    request.post<ApiResponse<PackageTemplate>>('/package', data),
  
  update: (id: number, data: Partial<PackageTemplate>) =>
    request.put<ApiResponse<PackageTemplate>>(`/package/${id}`, data),
  
  delete: (id: number) =>
    request.delete<ApiResponse<void>>(`/package/${id}`),
};

// 消费核销相关 API
export interface ConsumeRequest {
  memberId: number;
  serviceItemId: number;
  serviceStaffId: number;
  cardId?: number;
}

export interface ConsumeResult {
  orderId: number;
  orderNo: string;
  cardUsed: any;
  deductBefore: string;
  deductAfter: string;
}

export const consumeApi = {
  // 快速核销
  verify: (data: ConsumeRequest) =>
    request.post<ApiResponse<ConsumeResult>>('/consume/verify', data),
  
  // 获取会员可用卡列表
  getAvailableCards: (memberId: number, serviceItemId: number) =>
    request.get<ApiResponse<any[]>>(`/consume/available-cards`, {
      params: { memberId, serviceItemId },
    }),
  
  // 消费记录
  records: (params: PageParams & { memberId?: number }) =>
    request.get<ApiResponse<PageResult<any>>>('/consume/records', { params }),
  
  // 撤销消费
  cancel: (orderId: number) =>
    request.post<ApiResponse<void>>(`/consume/${orderId}/cancel`),
};

// 登录相关 API
export interface LoginRequest {
  phone: string;
  password: string;
}

export interface LoginResult {
  token: string;
  user: {
    id: number;
    name: string;
    role: string;
    tenantId: number;
  };
}

export const authApi = {
  login: (data: LoginRequest) =>
    request.post<ApiResponse<LoginResult>>('/auth/login', data),
  
  logout: () =>
    request.post<ApiResponse<void>>('/auth/logout'),
};