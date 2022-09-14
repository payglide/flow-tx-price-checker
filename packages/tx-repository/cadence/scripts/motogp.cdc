
import MotoGPNFTStorefront from 0xa49cc0ee46c54bfb

pub fun main(saleOfferResourceID: UInt64, storefrontAddress: Address): UFix64 {
    let storefront = getAccount(storefrontAddress)
    .getCapability<&MotoGPNFTStorefront.Storefront{MotoGPNFTStorefront.StorefrontPublic}>(MotoGPNFTStorefront.StorefrontPublicPath)!.borrow()
    ?? panic("Could not borrow Storefront from provided address")

    let saleOffer = storefront.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID) ?? panic("No Offer with that ID in Storefront")

    var price:UFix64 = saleOffer.getDetails().salePrice
    return price
}
