import type { ApiResponse } from '../types';

/**
 * Simulated API Client.
 * Automatically adds artificial network delay to mock real backend communication.
 * In a real production setup, replace `mockRequest` with `fetch()` or `axios.request()`.
 */
export async function mockRequest<T>(data: T, delayMs: number = 400, shouldFail: boolean = false, failureMessage: string = 'حدث خطأ في الخادم'): Promise<ApiResponse<T>> {
  await new Promise(resolve => setTimeout(resolve, delayMs));

  if (shouldFail) {
    return {
      success: false,
      message: failureMessage,
      errorCode: 'ERR_SERVER_FAIL',
    };
  }

  return {
    success: true,
    data,
    message: 'تمت العملية بنجاح',
  };
}
