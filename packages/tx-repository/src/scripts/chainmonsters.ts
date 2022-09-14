export const Chainmonsters = {
  checkPrice: `
import ChainmonstersMarketplace from 0x64f83c60989ce555

pub fun main(saleItemID: UInt64, marketCollectionAddress: Address, price: UFix64): UFix64 {
    let marketCollection = getAccount(marketCollectionAddress)
        .getCapability(ChainmonstersMarketplace.CollectionPublicPath)
        .borrow<&ChainmonstersMarketplace.Collection{ChainmonstersMarketplace.CollectionPublic}>()
        ?? panic("Could not borrow market collection from market address")

    let saleItem = self.marketCollection.borrowSaleItem(saleItemID: saleItemID)
                ?? panic("No item with that ID")
    let salePrice = saleItem.salePrice

    assert(salePrice == price, message: "Expected price does not match")
    return price
}
`,
}
