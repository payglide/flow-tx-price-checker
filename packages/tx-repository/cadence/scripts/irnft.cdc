
import IrNFT from 0x276a7cc9316712af

pub fun main(dropID: UInt32): UFix64 {
  self.drop = IrNFT.getDropData(id: dropID)
  let dropPrice = self.drop.price
  return dropPrice
}
