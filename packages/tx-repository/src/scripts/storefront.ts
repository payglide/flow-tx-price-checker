export const Storefront = {
  checkPrice: `
import NFTStorefront from 0x4eb8a10cb9f87357

pub fun main(storefrontAddress: Address, listingResourceID: UInt64, buyPrice: UFix64): UFix64 {
    let storefront = getAccount(storefrontAddress)
        .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
            NFTStorefront.StorefrontPublicPath
        )!
        .borrow()
        ?? panic("Could not borrow Storefront from provided address")

    let listing = storefront.borrowListing(listingResourceID: listingResourceID)
                ?? panic("No Offer with that ID in Storefront")
    let price = listing.getDetails().salePrice

    assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")
    return price
}
`,
}
