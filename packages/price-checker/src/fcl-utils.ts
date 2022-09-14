import { SHA3 } from 'sha3'

export const resolveType = (type: string, t: any) => {
  return t[type]
}

export const resolveArg = (value: any, type: string, arg: any, t: any) => {
  return arg(value, resolveType(type, t))
}

export const sha3_256 = (msg: string) => {
  const sha = new SHA3(256)
  sha.update(msg)
  return sha.digest().toString('hex')
}
