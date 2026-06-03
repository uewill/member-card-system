export interface ApiResponse<T = any> {
  code: number;
  message: string;
  data: T;
}

export interface PageParams {
  page: number;
  size: number;
}

export interface PageResult<T> {
  list: T[];
  total: number;
  page: number;
  size: number;
}