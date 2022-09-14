export interface PaymentAmountResolver {
  resolve(transaction: Transaction, params: any): Promise<PaymentAmount>
}

export interface Transaction {
  code: string
  arguments: Argument[]
}

export interface Argument {
  value: any
  type: string
}

export interface PaymentAmount {
  transactionHash: string
  amount: any
  currency: string
}

export interface ValidatorError {
  error?: any
  type: ValidationErrorTypes
  transactionHash: string
}

export type ValidationErrorTypes = 'NO_MATCHING_RESOLVER' | 'NO_MATCHING_TRANSACTION' | 'ERROR_WHILE_EXECUTION'

export type GetPriceCheckParams = (hash: string) => PriceCheckParams

export interface PriceCheckParams {
  name: string
  hash: string
  validationStrategy: string
  script: string
  argumentIndices: number[]
  currency: string
}

export interface TxRepository {
  getPriceCheckParams: GetPriceCheckParams
}
