
import CheezeMarket from 0x5a8fb12692f5a446

pub fun main(nftIds: [UInt64]): UFix64 {
    var total = 0
    var i = 0 as UInt64
    while i < UInt64(nftIds.length) {
        let nftId = nftIds[i]
        let price = CheezeMarket.priceFor(tokenID: nftId)
        total = total + price
        i = i + 1
    }
    return total
}
