import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FlowToken from 0x1654653399040a61
import TheFabricantS1ItemNFT from 0x9e03b1f871b3513
import TheFabricantMarketplace from 0x9e03b1f871b3513

transaction(sellerAddress: Address, listingID: String, amount: UFix64) {
  // reference to the buyer''s NFT collection where they
  // will store the bought NFT
  let itemNFTCollection: &TheFabricantS1ItemNFT.Collection{NonFungibleToken.Receiver}
  // Vault that will hold the tokens that will be used to buy the NFT
  let temporaryVault: @FungibleToken.Vault
  prepare(acct: AuthAccount) {

      // initialize S1ItemNFT
      if !acct.getCapability<&{TheFabricantS1ItemNFT.ItemCollectionPublic}>(TheFabricantS1ItemNFT.CollectionPublicPath).check() {
        if acct.type(at: TheFabricantS1ItemNFT.CollectionStoragePath) == nil {
              let collection <- TheFabricantS1ItemNFT.createEmptyCollection() as! @TheFabricantS1ItemNFT.Collection
              acct.save(<-collection, to: TheFabricantS1ItemNFT.CollectionStoragePath)
          }
          acct.unlink(TheFabricantS1ItemNFT.CollectionPublicPath)
          acct.link<&{TheFabricantS1ItemNFT.ItemCollectionPublic}>(TheFabricantS1ItemNFT.CollectionPublicPath, target: TheFabricantS1ItemNFT.CollectionStoragePath)
      }

      self.itemNFTCollection = acct.borrow<&TheFabricantS1ItemNFT.Collection{NonFungibleToken.Receiver}>(from: TheFabricantS1ItemNFT.CollectionStoragePath)
          ?? panic("could not borrow owner''s nft collection reference")
      
      let vaultRef = acct.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
          ?? panic("Could not borrow owner''s Vault reference")

      // withdraw tokens from the buyer''s Vault
      self.temporaryVault <- vaultRef.withdraw(amount: amount)
  }

  execute {
      // get the read-only acct storage of the seller
      let seller = getAccount(sellerAddress)

      let listingRef= seller.getCapability(TheFabricantMarketplace.ListingsPublicPath).borrow<&{TheFabricantMarketplace.ListingsPublic}>()
                       ?? panic("Could not borrow seller''s listings reference")

      listingRef.purchaseListing(listingID: listingID, recipientCap: self.itemNFTCollection, payment: <- self.temporaryVault)
  }
}