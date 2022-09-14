import NFTStorefront from 0x4eb8a10cb9f87357

pub fun main(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64): UFix64 {
    // Get the storefront reference from the seller
    let storefront = getAccount(storefrontAddress)
        .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
            NFTStorefront.StorefrontPublicPath
        )!.borrow() ?? panic("Could not borrow Storefront from provided address")

    // Get the listing by ID from the storefront
    let listing = storefront.borrowListing(listingResourceID: listingResourceID)
        ?? panic("No Offer with that ID in Storefront")
    let salePrice = listing.getDetails().salePrice
    return salePrice
}