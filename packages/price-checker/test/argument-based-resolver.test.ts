import { ArgumentBasedResolver, PriceCheckParams } from '../src'
import { Transaction, Argument } from '../src/types'

describe('argument based resolver', () => {
  const testArgument: Argument = {
    value: '42',
    type: 'UInt64',
  }

  const testTransaction: Transaction = {
    code: 'tx code',
    arguments: [testArgument],
  }

  const testParams: PriceCheckParams = {
    name: 'the name',
    hash: 'the hash',
    validationStrategy: 'argumentBased',
    script: '',
    argumentIndices: [0],
    currency: 'the currency',
  }

  it('Should return the argumet defined first in the price check params', async () => {
    const testSubject = new ArgumentBasedResolver()
    const result = await testSubject.resolve(testTransaction, testParams)
    expect(result).toEqual({ amount: '42', currency: 'the currency', transactionHash: 'the hash' })
  })
})
