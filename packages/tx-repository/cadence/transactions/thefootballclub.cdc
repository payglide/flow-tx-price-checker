import FUSD from 0x3c5959b568896393
import NonFungibleToken from 0x1d7e57aa55817448
import TFCItems from 0x81e95660ab5308e1
import NFTStorefront from 0x4eb8a10cb9f87357
import FungibleToken from 0xf233dcee88fe0abe

/*
    This transaction is used to buy a TFCItem for FUSD
 */
transaction(storefrontAddress: Address, listingResourceID: UInt64, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let TFCItemsCollection: &TFCItems.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(acct: AuthAccount) {
        if acct.borrow<&TFCItems.Collection>(from: TFCItems.CollectionStoragePath) == nil {
            acct.save(<-TFCItems.createEmptyCollection(), to: TFCItems.CollectionStoragePath)
            acct.unlink(TFCItems.CollectionPublicPath)
            acct.link<&TFCItems.Collection{NonFungibleToken.CollectionPublic, TFCItems.TFCItemsCollectionPublic}>(TFCItems.CollectionPublicPath, target: TFCItems.CollectionStoragePath)
        }
        
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
                    ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let mainFlowVault = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.paymentVault <- mainFlowVault.withdraw(amount: price)

        self.TFCItemsCollection = acct.borrow<&TFCItems.Collection{NonFungibleToken.Receiver}>(
            from: TFCItems.CollectionStoragePath
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.TFCItemsCollection.deposit(token: <-item)
        
        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }
}