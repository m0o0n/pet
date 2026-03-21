import axios, { type AxiosError } from 'axios'

export const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  headers: { 'Content-Type': 'application/json' },
})

export type ApiFetcherExtraProps = {}

export type ErrorWrapper<TError> =
  | TError
  | { status: 'unknown'; payload: string }

export type ApiFetcherOptions<TBody, THeaders, TQueryParams, TPathParams> = {
  url: string
  method: string
  body?: TBody
  headers?: THeaders
  queryParams?: TQueryParams
  pathParams?: TPathParams
  signal?: AbortSignal
} & ApiFetcherExtraProps

export async function apiFetch<
  TData,
  TError,
  TBody extends {} | FormData | undefined | null,
  THeaders extends {},
  TQueryParams extends {},
  TPathParams extends {},
>({
  url,
  method,
  body,
  headers,
  pathParams,
  queryParams,
  signal,
}: ApiFetcherOptions<
  TBody,
  THeaders,
  TQueryParams,
  TPathParams
>): Promise<TData> {
  try {
    const { data } = await apiClient.request<TData>({
      url: resolveUrl(url, pathParams as Record<string, string>),
      method,
      data: body,
      params: queryParams,
      headers: headers as Record<string, string>,
      signal,
    })
    return data
  } catch (e) {
    const axiosError = e as AxiosError<TError>
    if (axiosError.response) {
      throw axiosError.response.data
    }
    throw {
      status: 'unknown',
      payload: axiosError.message ?? 'Network error',
    } satisfies ErrorWrapper<TError>
  }
}

const resolveUrl = (url: string, pathParams: Record<string, string> = {}) =>
  url.replace(/\{\w*\}/g, (key) => pathParams[key.slice(1, -1)] ?? '')
