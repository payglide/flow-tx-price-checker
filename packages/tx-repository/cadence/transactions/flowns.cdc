import Flowns from 0x233eb012d34b0070
import Domains from 0x233eb012d34b0070
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448

transaction(domainId: UInt64, name: String, duration: UFix64, amount: UFix64, refer: Address) {
  let collectionCap: Capability<&{NonFungibleToken.Receiver}>
  let vault: @FungibleToken.Vault
  prepare(account: AuthAccount) {
    if account.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath).check() == false {
      if account.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath) !=nil {
        account.unlink(Domains.CollectionPublicPath)
        account.link<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
      } else {
        account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
        account.link<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
      }
    }
    self.collectionCap = account.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
    let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
          ?? panic("Could not borrow owner''s Vault reference")
    self.vault <- vaultRef.withdraw(amount: amount)
  }

  execute {
    Flowns.registerDomain(domainId: domainId, name: name, duration: duration, feeTokens: <- self.vault, receiver: self.collectionCap, refer: refer)
  }
}