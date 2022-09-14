export const Versus = {
  checkPrice: `
import Versus from 0xd796ff17107bbff6

pub fun main(address: Address, dropId: UInt64, auctionId: UInt64, bidAmount: UFix64): UFix64 {
    let seller = getAccount(marketplace)
    let versusCap = seller.getCapability<&{Versus.PublicDrop}>(Versus.CollectionPublicPath)
    let currentBid = versusCap.borrow()!.currentBidForUser(dropId: dropId, auctionId: auctionId, address: account.address)
    let amount = bidAmount - currentBid
    return amount
}
`,
}
