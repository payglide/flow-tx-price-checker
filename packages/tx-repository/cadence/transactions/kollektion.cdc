import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import NFTStorefront from 0x4eb8a10cb9f87357
import FlowToken from 0x1654653399040a61
import KlktnNFT from 0xabd6e80be7e9682c

transaction(listingResourceID: UInt64, storefrontAddress: Address, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let nftCollection: &KlktnNFT.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        if signer.borrow<&KlktnNFT.Collection>(from: KlktnNFT.CollectionStoragePath) == nil {
            signer.save(<-KlktnNFT.createEmptyCollection(), to: KlktnNFT.CollectionStoragePath)
            signer.link<&KlktnNFT.Collection{NonFungibleToken.CollectionPublic, KlktnNFT.KlktnNFTCollectionPublic}>(KlktnNFT.CollectionPublicPath, target: KlktnNFT.CollectionStoragePath)
        }

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from signer storage")
        self.paymentVault <- flowTokenVault.withdraw(amount: price)

        self.nftCollection = signer.borrow<&KlktnNFT.Collection{NonFungibleToken.Receiver}>(from: KlktnNFT.CollectionStoragePath)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)
        self.nftCollection.deposit(token: <-item)
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }
}