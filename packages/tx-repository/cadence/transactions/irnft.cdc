
  import NonFungibleToken from 0x1d7e57aa55817448
  import FungibleToken from 0xf233dcee88fe0abe
  import IrNFT, IrVoucher from 0x276a7cc9316712af
  import FUSD from 0x3c5959b568896393

  transaction(dropID: UInt32) {

    let drop: IrNFT.IrDropData
    let voucherReceiver: &IrVoucher.Collection{NonFungibleToken.CollectionPublic}
    let paymentVault: @FungibleToken.Vault

    prepare(acct: AuthAccount) {
      // Find the Drop
      self.drop = IrNFT.getDropData(id: dropID)

      // Get the Voucher Collection (to deposit purchased voucher)
      self.voucherReceiver = acct
        .borrow<&IrVoucher.Collection{NonFungibleToken.CollectionPublic}>(
          from: IrVoucher.CollectionStoragePath
        ) ?? panic("Could not borrow receiver reference")

      let dropPrice = self.drop.price

      // Get the FUSD Vault to withdraw the Price from
      let fusdVault = acct.borrow<&FUSD.Vault>(
        from: /storage/fusdVault
      ) ?? panic("Could not borrow FUSD vault")
      
      // Get the required FUSD amount for this Drop
      self.paymentVault <- fusdVault.withdraw(
        amount: self.drop.price
      )
    }

    execute {
      self.drop.purchaseVoucher(
        recipient: self.voucherReceiver,
        paymentVault: <- self.paymentVault
      )
    }

  }