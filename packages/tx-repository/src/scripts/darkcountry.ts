export const DarkCountry = {
  checkPrice: `
import DarkCountryMarket from 0xc8c340cebd11f690

pub fun main(saleItemID: UInt64, marketCollectionAddress: Address): UFix64 {

    self.marketCollection = getAccount(marketCollectionAddress)
        .getCapability<&DarkCountryMarket.Collection{DarkCountryMarket.CollectionPublic}>(
            DarkCountryMarket.CollectionPublicPath
        )!
        .borrow()
        ?? panic("Could not borrow market collection from market address")

    let saleItem = self.marketCollection.borrowSaleItem(itemID: saleItemID)
        ?? panic("No item with that ID")
    let price = saleItem.price
    return price
}
`,
}
