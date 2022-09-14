export const Rarible = {
  checkPrice: `
import NFTStorefront from 0x4eb8a10cb9f87357

pub fun main(orderId: UInt64, storefrontAddress: Address, parts: {Address:UFix64}): UFix64 {
    let storefront = getAccount(storefrontAddress)
        .getCapability(NFTStorefront.StorefrontPublicPath)
        .borrow<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>()
        ?? panic("Could not borrow Storefront from provided address")

    let listing = storefront.borrowListing(listingResourceID: orderId)
                ?? panic("No Offer with that ID in Storefront")
    var amount = listing.getDetails().salePrice
    for address in parts.keys {
        amount = amount + parts[address]!
    }
    return amount
}
`,
}
