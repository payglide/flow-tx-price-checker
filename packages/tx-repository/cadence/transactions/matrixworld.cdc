import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import NFTStorefront from 0x4eb8a10cb9f87357
import FlowToken from 0x1654653399040a61
import MatrixWorldVoucher from 0x0d77ec47bbad8ef6

// Buy MatrixWorldVoucher item
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

        if !account.getCapability<&{MatrixWorldVoucher.MatrixWorldVoucherCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver}>(MatrixWorldVoucher.CollectionPublicPath).check() {
            if account.borrow<&AnyResource>(from: MatrixWorldVoucher.CollectionStoragePath) != nil {
                account.unlink(MatrixWorldVoucher.CollectionPublicPath)
                account.link<&{MatrixWorldVoucher.MatrixWorldVoucherCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver}>(MatrixWorldVoucher.CollectionPublicPath, target: MatrixWorldVoucher.CollectionStoragePath)
            } else {
                let collection <- MatrixWorldVoucher.createEmptyCollection() as! @MatrixWorldVoucher.Collection
                account.save(<-collection, to: MatrixWorldVoucher.CollectionStoragePath)
                account.link<&{MatrixWorldVoucher.MatrixWorldVoucherCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver}>(MatrixWorldVoucher.CollectionPublicPath, target: MatrixWorldVoucher.CollectionStoragePath)
            }
        }
        self.nftCollection = account.borrow<&{NonFungibleToken.Receiver}>(from: MatrixWorldVoucher.CollectionStoragePath)
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