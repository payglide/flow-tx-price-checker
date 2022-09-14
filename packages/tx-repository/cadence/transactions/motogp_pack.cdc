import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import REVV from 0xd01e482eb680ec9f
import MotoGPCard from 0xa49cc0ee46c54bfb
import MotoGPPack from 0xa49cc0ee46c54bfb
import MotoGPNFTStorefront from 0xa49cc0ee46c54bfb

transaction(saleOfferResourceID: UInt64, storefrontAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let packCollection: &MotoGPPack.Collection{NonFungibleToken.CollectionPublic}
    let storefront: &MotoGPNFTStorefront.Storefront{MotoGPNFTStorefront.StorefrontPublic}
    let saleOffer: &MotoGPNFTStorefront.SaleOffer{MotoGPNFTStorefront.SaleOfferPublic}

    prepare(acct: AuthAccount) {

        // If the account doesn''t already have a Card Collection
        if acct.borrow<&MotoGPCard.Collection>(from: /storage/motogpCardCollection) == nil {
            let cardCollection <- MotoGPCard.createEmptyCollection()
            acct.save(<-cardCollection, to: /storage/motogpCardCollection)
            acct.link<&MotoGPCard.Collection{MotoGPCard.ICardCollectionPublic}>(/public/motogpCardCollection, target: /storage/motogpCardCollection)
        }

        // If the account doesn''t already have a Pack Collection
        if acct.borrow<&MotoGPPack.Collection>(from: /storage/motogpPackCollection) == nil {
            let packCollection <- MotoGPPack.createEmptyCollection()
            acct.save(<-packCollection, to: /storage/motogpPackCollection)
            acct.link<&MotoGPPack.Collection{MotoGPPack.IPackCollectionPublic, MotoGPPack.IPackCollectionAdminAccessible}>(/public/motogpPackCollection, target: /storage/motogpPackCollection)
        }

        self.storefront = getAccount(storefrontAddress)
        .getCapability<&MotoGPNFTStorefront.Storefront{MotoGPNFTStorefront.StorefrontPublic}>(MotoGPNFTStorefront.StorefrontPublicPath)!.borrow()
        ?? panic("Could not borrow Storefront from provided address")

        self.saleOffer = self.storefront.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID) ?? panic("No Offer with that ID in Storefront")

        var price:UFix64 = self.saleOffer.getDetails().salePrice

        let revvVault = acct.borrow<&REVV.Vault>(from: REVV.RevvVaultStoragePath) ?? panic("Cannot borrow REVV vault from acct storage")

        self.paymentVault <- revvVault.withdraw(amount: price)

        self.packCollection = acct.borrow<&MotoGPPack.Collection{NonFungibleToken.CollectionPublic}>(from: /storage/motogpPackCollection)
        ?? panic("Cannot borrow NFT collection receiver from account")
        
    }

    execute {
        
        // pay
        let pack <- self.saleOffer.accept(
            payment: <-self.paymentVault
        )

        // transfer pack
        self.packCollection.deposit(token: <- pack)

        // remove saleOffer
        self.storefront.cleanup(saleOfferResourceID: saleOfferResourceID) 
        
    }
}