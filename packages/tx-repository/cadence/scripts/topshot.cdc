
import DapperOffers from 0xb8ea91944fd51c43

pub fun main(offerId: UInt64, DapperOfferAddress: Address): UFix64 {
    let dapperOffer = getAccount(DapperOfferAddress)
        .getCapability<&DapperOffers.DapperOffer{DapperOffers.DapperOfferPublic}>(
            DapperOffers.DapperOffersPublicPath
        )!
        .borrow()
        ?? panic("Could not borrow DapperOffer from provided address")
    // Get the DapperOffer details
    let offer = dapperOffer.borrowOffer(offerId: offerId)
        ?? panic("No Offer with that ID in DapperOffer")
    let amount = offer.getDetails().offerAmount
    return amount
}
