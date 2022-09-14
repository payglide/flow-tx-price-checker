
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import NFTStorefront from 0x4eb8a10cb9f87357
import FlowToken from 0x1654653399040a61
import RaribleNFT from 0x01ab36aaf654a13e

// Buy RaribleNFT item
//
//   orderId - NFTStorefront listingResourceID
//   storefrontAddress - seller address
//   parts - buyer payments {address:amount}
//
transaction(orderId: UInt64, storefrontAddress: Address, parts: {Address:UFix64}) {
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
    let paymentVault: @FungibleToken.Vault
    let nftCollection: &{NonFungibleToken.Receiver}

    prepare(account: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability(NFTStorefront.StorefrontPublicPath)
            .borrow<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: orderId)
                    ?? panic("No Offer with that ID in Storefront")
        var amount = self.listing.getDetails().salePrice
        for address in parts.keys {
            amount = amount + parts[address]!
        }

        let mainVault = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from account storage")
        self.paymentVault <- mainVault.withdraw(amount: amount)

        if !account.getCapability<&{NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver}>(RaribleNFT.collectionPublicPath).check() {
            if account.borrow<&AnyResource>(from: RaribleNFT.collectionStoragePath) != nil {
                account.unlink(RaribleNFT.collectionPublicPath)
                account.link<&{NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver}>(RaribleNFT.collectionPublicPath, target: RaribleNFT.collectionStoragePath)
            } else {
                let collection <- RaribleNFT.createEmptyCollection() as! @RaribleNFT.Collection
                account.save(<-collection, to: RaribleNFT.collectionStoragePath)
                account.link<&{NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver}>(RaribleNFT.collectionPublicPath, target: RaribleNFT.collectionStoragePath)
            }
        }
        self.nftCollection = account.borrow<&{NonFungibleToken.Receiver}>(from: RaribleNFT.collectionStoragePath)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        for address in parts.keys {
            let receiver = getAccount(address).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            assert(receiver.check(), message: "Cannot borrow FlowToken receiver")
            let part <- self.paymentVault.withdraw(amount: parts[address]!)
            receiver.borrow()!.deposit(from: <- part)
        }

        let item <- self.listing.purchase(payment: <-self.paymentVault)
        self.nftCollection.deposit(token: <-item)
        self.storefront.cleanup(listingResourceID: orderId)
    }
}
	