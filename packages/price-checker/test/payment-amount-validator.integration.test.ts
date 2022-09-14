import { createDefaultPriceChecker, TxRepository, PriceCheckParams } from '../src'
import { Transaction, Argument } from '../src/types'

const returnWhatPassedIn = `
pub fun main(amount: UInt64): UInt64 {
    return amount
}
`

const testArgument: Argument = {
  value: '42',
  type: 'UInt64',
}

const testTransaction: Transaction = {
  code: 'tx code',
  arguments: [testArgument],
}

class MockRepo implements TxRepository {
  getPriceCheckParams(hash: string): PriceCheckParams {
    return {
      name: 'test',
      hash,
      validationStrategy: 'scriptExecution',
      script: returnWhatPassedIn,
      argumentIndices: [0],
      currency: 'FUSD',
    }
  }
}

describe('payment validator', () => {
  it('Should return the correct price and currency', async () => {
    const testSubject = createDefaultPriceChecker(new MockRepo(), 'https://rest-testnet.onflow.org')
    const result = await testSubject.validate(testTransaction)
    const expected = {
      value: {
        amount: '42',
        currency: 'FUSD',
        transactionHash: '12fc3ba265ec93dece6a4c24b4ed2845f1551940afe19e4bb47ecae2d9d2554a',
      },
    }
    expect(result).toEqual(expected)
  })
})
