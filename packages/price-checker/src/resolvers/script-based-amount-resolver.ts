import { PaymentAmount, PaymentAmountResolver, Transaction, Argument, PriceCheckParams } from '../types'
import * as fcl from '@onflow/fcl'
import { resolveArg } from '../fcl-utils'

export class ScriptBasedAmountResolver implements PaymentAmountResolver {
  constructor(accessNodeApi: string) {
    fcl.config().put('accessNode.api', accessNodeApi)
  }

  async resolve(transaction: Transaction, params: PriceCheckParams): Promise<PaymentAmount> {
    const scriptArgs: Argument[] = params.argumentIndices.map((value: number) => transaction.arguments[value])

    const fclArgs = (arg: any, t: any) => scriptArgs.map(({ value, type }) => resolveArg(value, type, arg, t))

    const result = await fcl.query({
      cadence: params.script,
      args: fclArgs,
    })

    return {
      transactionHash: params.hash,
      amount: result,
      currency: params.currency,
    }
  }
}
