import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import RareRooms_NFT from 0x329feb3ab062d289
import FlowToken from 0x1654653399040a61
import NFTStorefront from 0x4eb8a10cb9f87357

transaction(listingResourceID: UInt64, storefrontAddress: Address, expectedPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let RareRooms_NFTCollection: &RareRooms_NFT.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
    let price: UFix64
    let mainFlowTokenVault: &FlowToken.Vault

    prepare(buyer: AuthAccount) {
        // Initialize the buyer''s collection if they do not already have one
        if buyer.borrow<&RareRooms_NFT.Collection>(from: RareRooms_NFT.CollectionStoragePath) == nil {

            // Create a new empty collection and save it to the account
            buyer.save(<-RareRooms_NFT.createEmptyCollection(), to: RareRooms_NFT.CollectionStoragePath)

            // Create a public capability to the RareRooms_NFT collection
            // that exposes the Collection interface
            buyer.link<&RareRooms_NFT.Collection{NonFungibleToken.CollectionPublic,RareRooms_NFT.RareRooms_NFTCollectionPublic}>(
                RareRooms_NFT.CollectionPublicPath,
                target: RareRooms_NFT.CollectionStoragePath
            )
        }

        // Get the storefront reference from the seller
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        // Get the listing by ID from the storefront
        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
                    ?? panic("No Offer with that ID in Storefront")
        self.price = self.listing.getDetails().salePrice

        // Withdraw mainFlowTokenVault from buyer''s account
        self.mainFlowTokenVault = buyer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from account storage")
        self.paymentVault <- self.mainFlowTokenVault.withdraw(amount: self.price)

        // Get the collection from the buyer so the NFT can be deposited into it
        self.RareRooms_NFTCollection = buyer.borrow<&RareRooms_NFT.Collection{NonFungibleToken.Receiver}>(
            from: RareRooms_NFT.CollectionStoragePath
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    // Check that the price is right
    pre {
        self.price == expectedPrice: "unexpected price"
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.RareRooms_NFTCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }
}