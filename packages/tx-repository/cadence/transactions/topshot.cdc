import TopShot from 0x0b2a3299cc857e29
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import Offers from 0xb8ea91944fd51c43
import DapperOffers from 0xb8ea91944fd51c43
import DapperUtilityCoin from 0xead892083b3e2c6c
import TopShotMarketV3 from 0xc1e4f4f4c4257510
import Market from 0xc1e4f4f4c4257510

transaction(offerId: UInt64, DapperOfferAddress: Address) {
    let dapperOffer: &DapperOffers.DapperOffer{DapperOffers.DapperOfferPublic}
    let offer: &Offers.Offer{Offers.OfferPublic}
    let receiverCapability: Capability<&{FungibleToken.Receiver}>
    prepare(signer: AuthAccount) {
        var emptyNFTResource = true
        // Get the DapperOffers resource
        self.dapperOffer = getAccount(DapperOfferAddress)
            .getCapability<&DapperOffers.DapperOffer{DapperOffers.DapperOfferPublic}>(
                DapperOffers.DapperOffersPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow DapperOffer from provided address")
        // Set the fungible token receiver capabillity
        self.receiverCapability = signer.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(self.receiverCapability.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin receiver")
        // Get the DapperOffer details
        self.offer = self.dapperOffer.borrowOffer(offerId: offerId)
            ?? panic("No Offer with that ID in DapperOffer")
        let nftId = self.offer.getDetails().nftId
        // Cancel any listings that exist for this offer
        if let saleV3Ref = signer.borrow<&TopShotMarketV3.SaleCollection>(from: TopShotMarketV3.marketStoragePath) {
            if saleV3Ref!.getPrice(tokenID: nftId) != nil {
                saleV3Ref.cancelSale(tokenID: nftId)
            }
        } else if let saleV1Ref = signer.borrow<&Market.SaleCollection>(from: /storage/topshotSaleCollection) {
            if saleV1Ref!.getPrice(tokenID: nftId) != nil {
                emptyNFTResource = false
                self.offer.accept(
                    item: <-saleV1Ref!.withdraw(tokenID: nftId),
                    receiverCapability: self.receiverCapability
                )!
            }
        }

        if emptyNFTResource == true {
            // Get the NFT ressource and widthdraw the NFT from the signers account
            let nftCollection = signer.borrow<&TopShot.Collection>(from: /storage/MomentCollection)
                ?? panic("Cannot borrow NFT collection receiver from account")

            self.offer.accept(
                item: <-nftCollection.withdraw(withdrawID: nftId),
                receiverCapability: self.receiverCapability
            )!
        }
    }
    execute {
        self.dapperOffer.cleanup(offerId: offerId)
    }
}
