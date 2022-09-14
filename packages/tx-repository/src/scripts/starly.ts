export const StarlyCard = {
  checkPrice: `
import StarlyCardMarket from 0x5b82f21c0edf76e3

pub fun main(itemID: UInt64, marketCollectionAddress: Address): UFix64 {
  let marketCollection = getAccount(marketCollectionAddress)
    .getCapability<&StarlyCardMarket.Collection{StarlyCardMarket.CollectionPublic}>(
      StarlyCardMarket.CollectionPublicPath
    )!
    .borrow()
    ?? panic("Could not borrow market collection from market address")

  let saleItem = marketCollection.borrowSaleItem(itemID: itemID)
              ?? panic("No item with that ID")
  let price = saleItem.price
  return price
}
`,
}
