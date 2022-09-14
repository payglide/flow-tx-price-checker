import CheezeNFT from 0x5a8fb12692f5a446
import NonFungibleToken from 0x1d7e57aa55817448
import CheezeMarket from 0x5a8fb12692f5a446
import FUSD from 0x3c5959b568896393



transaction(nftIds: [UInt64]) {
    let nftCollection: &CheezeNFT.Collection
    let vault: &FUSD.Vault

    prepare(signer: AuthAccount) {
        self.nftCollection = signer.borrow<&CheezeNFT.Collection>(from: /storage/NFTCollection)!
        self.vault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!
    }

    execute {
        var i = 0 as UInt64
        while i < UInt64(nftIds.length) {
            let nftId = nftIds[i]
            let price = CheezeMarket.priceFor(tokenID: nftId)
            let payment <- self.vault.withdraw(amount: price) as! @FUSD.Vault
            let token <- CheezeMarket.buy(
                tokenID: nftId,
                payment: <-payment
            )
            self.nftCollection.deposit(token: <-token)
            i = i + 1
        }
    }
}