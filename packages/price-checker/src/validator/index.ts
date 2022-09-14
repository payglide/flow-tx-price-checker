import { sha3_256 } from '../fcl-utils'
import { ok, err, Result } from 'neverthrow'
import { PaymentAmountResolver, Transaction, PaymentAmount, ValidatorError, TxRepository } from '../types'
import { ScriptExecutionResolver, ArgumentBasedResolver } from '..'

export function createDefaultPriceChecker(repository: TxRepository, flowAccessNodeApi: string): PaymentAmountValidator {
  const validator = new PaymentAmountValidator(repository)
  validator.registerResolver('scriptExecution', new ScriptExecutionResolver(flowAccessNodeApi))
  validator.registerResolver('argumentBased', new ArgumentBasedResolver())
  return validator
}

export class PaymentAmountValidator {
  private resolverRegistry: Map<string, PaymentAmountResolver>
  private repository: TxRepository

  constructor(repository: TxRepository) {
    this.resolverRegistry = new Map()
    this.repository = repository
  }

  registerResolver(key: string, resolver: PaymentAmountResolver) {
    this.resolverRegistry.set(key, resolver)
  }

  get(key: string): PaymentAmountResolver | undefined {
    return this.resolverRegistry.get(key)
  }

  async validate(transaction: Transaction): Promise<Result<PaymentAmount, ValidatorError>> {
    const transactionHash = sha3_256(transaction.code)
    try {
      const params = this.repository.getPriceCheckParams(transactionHash)
      if (params) {
        const resolver = this.resolverRegistry.get(params.validationStrategy)
        if (resolver) {
          return ok(await resolver.resolve(transaction, params))
        }
        return err({
          type: 'NO_MATCHING_RESOLVER',
          transactionHash,
        })
      }
      return err({
        type: 'NO_MATCHING_TRANSACTION',
        transactionHash,
      })
    } catch (e) {
      return err({
        error: e,
        type: 'ERROR_WHILE_EXECUTION',
        transactionHash,
      })
    }
  }
}
