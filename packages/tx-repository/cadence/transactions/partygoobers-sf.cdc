import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import NFTStorefront from 0x4eb8a10cb9f87357
import Marketplace from 0xdc5127882cacf8d9
import FlowToken from 0x1654653399040a61
import GooberXContract from 0x34f2bf4a80bb0f69

transaction(listingResourceID: UInt64, storefrontAddress: Address, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let nftCollection: &{NonFungibleToken.Receiver}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&GooberXContract.Collection>(from: GooberXContract.CollectionStoragePath) == nil {
            signer.save(<- GooberXContract.createEmptyCollection(), to: GooberXContract.CollectionStoragePath)
            signer.link<&{NonFungibleToken.CollectionPublic, GooberXContract.GooberCollectionPublic}>(
			    GooberXContract.CollectionPublicPath,
			    target: GooberXContract.CollectionStoragePath
		    )
        }

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let targetTokenVault = signer.borrow<&{FungibleToken.Provider}>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow target token vault from signer storage")
        self.paymentVault <- targetTokenVault.withdraw(amount: price)

        self.nftCollection = signer.borrow<&{NonFungibleToken.Receiver}>(from: GooberXContract.CollectionStoragePath)
                    ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)
        self.nftCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}