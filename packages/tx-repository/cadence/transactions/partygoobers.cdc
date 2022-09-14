
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FlowToken from 0x1654653399040a61
import GooberXContract from 0x34f2bf4a80bb0f69
import NFTStorefront from 0x4eb8a10cb9f87357

transaction(listingResourceID: UInt64, storefrontAddress: Address) {

    let paymentVault: @FungibleToken.Vault
    let gooberCollection: &GooberXContract.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(account: AuthAccount) {

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
                    ?? panic("No Offer with that ID in Storefront")

        let price = self.listing.getDetails().salePrice

        let mainFlowVault = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow Flow vault from account storage")
        
        self.paymentVault <- mainFlowVault.withdraw(amount: price)

        // check if buyer has already a Goober collection, if not create one
        if account.borrow<&GooberXContract.Collection>(from: GooberXContract.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- GooberXContract.createEmptyCollection()
            // save it to the account
            account.save(<-collection, to: GooberXContract.CollectionStoragePath)
            // create a public capability for the collection
            account.link<&GooberXContract.Collection{NonFungibleToken.CollectionPublic, GooberXContract.GooberCollectionPublic}>(GooberXContract.CollectionPublicPath, target: GooberXContract.CollectionStoragePath)
        }
        self.gooberCollection = account.borrow<&GooberXContract.Collection{NonFungibleToken.Receiver}>(
            from: GooberXContract.CollectionStoragePath
        ) ?? panic("Cannot borrow Gooberz collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.gooberCollection.deposit(token: <-item)
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }
}