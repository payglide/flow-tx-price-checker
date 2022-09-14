import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import ChainmonstersRewards from 0x93615d25d14fa337
import ChainmonstersMarketplace from 0x64f83c60989ce555

transaction(saleItemID: UInt64, marketCollectionAddress: Address, price: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let rewardsCollection: &ChainmonstersRewards.Collection{NonFungibleToken.Receiver}
    let marketCollection: &ChainmonstersMarketplace.Collection{ChainmonstersMarketplace.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.marketCollection = getAccount(marketCollectionAddress)
            .getCapability(ChainmonstersMarketplace.CollectionPublicPath)
            .borrow<&ChainmonstersMarketplace.Collection{ChainmonstersMarketplace.CollectionPublic}>()
            ?? panic("Could not borrow market collection from market address")

        let saleItem = self.marketCollection.borrowSaleItem(saleItemID: saleItemID)
                    ?? panic("No item with that ID")
        let salePrice = saleItem.salePrice

        assert(salePrice == price, message: "Expected price does not match")

        let mainFUSDVault = signer.borrow<&FungibleToken.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.paymentVault <- mainFUSDVault.withdraw(amount: salePrice)

        self.rewardsCollection = signer.borrow<&ChainmonstersRewards.Collection{NonFungibleToken.Receiver}>(
            from: /storage/ChainmonstersRewardCollection
        ) ?? panic("Cannot borrow rewards collection receiver from acct")
    }

    execute {
        self.marketCollection.purchase(
            saleItemID: saleItemID,
            buyerCollection: self.rewardsCollection,
            buyerPayment: <- self.paymentVault
        )
    }
}