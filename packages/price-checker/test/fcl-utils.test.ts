import { resolveArg, sha3_256 } from '../src/fcl-utils'

describe('fc-utils module', () => {
  it('Should resolve args', async () => {
    const value = '42'
    const type = 'UInt64'
    const t = {
      UInt64: {
        label: 'UInt64',
      },
    }
    const arg = (value: string, resolvedType: any) => {
      return `${value} ${resolvedType.label}`
    }
    const res = resolveArg(value, type, arg, t)
    expect(res).toEqual('42 UInt64')
  })

  it('Should return sha3 256 hash', async () => {
    const testHash = sha3_256('')
    expect(testHash).toEqual('a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a')
  })
})
