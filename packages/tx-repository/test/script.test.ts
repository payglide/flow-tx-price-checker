import * as fs from 'fs'
import { SHA3 } from 'sha3'
import { createLocalRepository } from '../src/'

describe('tx-repository module', () => {
  const repo = createLocalRepository()

  it('Should return the correct cadence script', async () => {
    const transactionsDir = `${__dirname}/../cadence/transactions`
    fs.readdirSync(transactionsDir).forEach(filename => {
      const txCode = fs.readFileSync(`${__dirname}/../cadence/transactions/${filename}`, { encoding: 'utf-8' })
      const sha = new SHA3(256)
      sha.update(txCode)
      const txHash = sha.digest().toString('hex')
      const params = repo.getPriceCheckParams(txHash)
      expect(params.name).toEqual(filename)
    })
  })

  it.each([
    ['chainmonsters.cdc', 'chainmonsters'],
    ['cheeze.cdc', 'cheeze'],
    ['darkcountry.cdc', 'darkcountry'],
    ['irnft.cdc', 'irnft'],
    ['matrixworld.cdc', 'matrixworld'],
    ['motogp_card.cdc', 'motogp'],
    ['motogp_pack.cdc', 'motogp'],
    ['partygoobers.cdc', 'partygoobers'],
    ['rarible.cdc', 'rarible'],
    ['starly.cdc', 'starly'],
    ['topshot.cdc', 'topshot'],
    ['versus.cdc', 'versus'],
    ['darkcountry-sf.cdc', 'storefront'],
    ['evolution.cdc', 'storefront'],
    ['kollektion.cdc', 'storefront'],
    ['mugenart.cdc', 'storefront'],
    ['mynft.cdc', 'storefront'],
    ['ovonft.cdc', 'storefront'],
    ['partygoobers-sf.cdc', 'storefront'],
    ['rarerooms.cdc', 'storefront'],
    ['starly3.cdc', 'storefront'],
    ['sturdyexchange.cdc', 'storefront'],
    ['thefootballclub.cdc', 'storefront'],
    ['zeedz_fiattoken.cdc', 'storefront'],
    ['zeedz_flowtoken.cdc', 'storefront'],
    ['zeedz_fusd.cdc', 'storefront'],
    ['goatedgoats.cdc', 'goatedgoats'],
  ])('Transaction %p should return script: %p', (tx: string, script: string) => {
    const txCode = fs.readFileSync(`${__dirname}/../cadence/transactions/${tx}`, { encoding: 'utf-8' })
    const sha = new SHA3(256)
    sha.update(txCode)
    const txHash = sha.digest().toString('hex')
    const params = repo.getPriceCheckParams(txHash)
    const scriptCode = fs.readFileSync(`${__dirname}/../cadence/scripts/${script}.cdc`, { encoding: 'utf-8' })
    expect(params.script).toEqual(scriptCode)
  })
})
