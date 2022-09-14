import NFTStorefront from 0x4eb8a10cb9f87357

pub fun main(listingResourceID: UInt64, storefrontAddress: Address, buyPrice: UFix64): UFix64  {
    self.storefront = getAccount(storefrontAddress)
        .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
        .borrow()
        ?? panic("Could not borrow Storefront from provided address")

    self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
        ?? panic("No Offer with that ID in Storefront")
    let price = self.listing.getDetails().salePrice

    assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")
    return price
}