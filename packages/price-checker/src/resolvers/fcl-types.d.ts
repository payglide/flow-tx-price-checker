declare module '@onflow/fcl' {
  export function config(options?: ConfigurationOptions): Configuration

  export interface ConfigurationOptions {
    'accessNode.api': string
  }

  export interface Configuration {
    put(key: keyof ConfigurationOptions | string, value: string | number): Configuration
    get(key: string, fallback?: string | number): Promise<string | number | undefined>
  }

  export function query(options: QueryOptions): Promise<object>

  export type ArgumentFunction = (
    arg: (value: CadenceArg, xform: FType) => ArgumentObject,
    t: FType,
  ) => ArgumentObject[]

  export interface QueryOptions {
    cadence: string
    args?: ArgumentFunction
    limit?: number
  }

  export interface ArgumentObject {
    value: CadenceArg
    xform: FType
  }

  interface CadenceDictionary {
    key: string | number | boolean
    value: string | number | boolean
  }

  interface CadencePath {
    domain: string
    identifier: string
  }

  export type Address = string

  type CadenceArg = number | string | boolean | Address | string[] | number[] | CadenceDictionary[] | CadencePath

  export type FType = any
}
