import { PaymentAmount, PaymentAmountResolver, Transaction, Argument, PriceCheckParams } from '../types'

export class ArgumentBasedResolver implements PaymentAmountResolver {
  async resolve(transaction: Transaction, params: PriceCheckParams): Promise<PaymentAmount> {
    const firstArg: Argument = transaction.arguments[params.argumentIndices[0]]
    return {
      transactionHash: params.hash,
      amount: firstArg.value,
      currency: params.currency,
    }
  }
}
