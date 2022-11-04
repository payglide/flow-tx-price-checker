
  import FindMarketSale from 0x097bafa4e0b48eef
  import FindMarket from 0x097bafa4e0b48eef
  import FTRegistry from 0x097bafa4e0b48eef
  import FIND from 0x097bafa4e0b48eef

  pub struct PaymentDetails {
      pub let currency : String
      pub let amount : UFix64
      init(currency : String, amount: UFix64) {
          self.currency = currency
          self.amount = amount
      }
  }

  pub fun main(marketplace: Address, user: String, id: UInt64, amount: UFix64): PaymentDetails {
    let resolveAddress = FIND.resolve(user)
    if resolveAddress == nil {
        panic("The address input is not a valid name nor address. Input : ".concat(user))
    }
    let address = resolveAddress!
    let marketOption = FindMarket.getMarketOptionFromType(Type<@FindMarketSale.SaleItemCollection>())
    let item = FindMarket.assertOperationValid(tenant: marketplace, address: address, marketOption: marketOption, id: id)
    let ft = FTRegistry.getFTInfoByTypeIdentifier(item.getFtType().identifier) ?? panic("This FT is not supported by the Find Market yet. Type : ".concat(item.getFtType().identifier))
    let paymentDetails = PaymentDetails(currency: tf.alias, amount: amount)
    return paymentDetails
  }
