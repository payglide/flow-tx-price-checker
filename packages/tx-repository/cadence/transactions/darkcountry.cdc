import NonFungibleToken from 0x1d7e57aa55817448 
    import DarkCountry from 0xc8c340cebd11f690 
    import DarkCountryMarket from 0xc8c340cebd11f690 
    import FungibleToken from 0xf233dcee88fe0abe 
    import FlowToken from 0x1654653399040a61 
    
    transaction(saleItemID: UInt64, marketCollectionAddress: Address) {
        let paymentVault: @FungibleToken.Vault
        let darkCountryCollection: &DarkCountry.Collection{NonFungibleToken.Receiver}
        let marketCollection: &DarkCountryMarket.Collection{DarkCountryMarket.CollectionPublic}
    
        prepare(signer: AuthAccount) {
        
            // if the account doesn''t already have a collection
            if signer.borrow<&DarkCountry.Collection>(from: DarkCountry.CollectionStoragePath) == nil {
    
                // create a new empty collection
                let collection <- DarkCountry.createEmptyCollection()
    
                // save it to the account
                signer.save(<-collection, to: DarkCountry.CollectionStoragePath)
    
                // create a public capability for the collection
                signer.link<&DarkCountry.Collection{NonFungibleToken.CollectionPublic, DarkCountry.DarkCountryCollectionPublic}>(DarkCountry.CollectionPublicPath, target: DarkCountry.CollectionStoragePath)
            }
            
            // if the account doesn''t already have a collection
            if signer.borrow<&DarkCountryMarket.Collection>(from: DarkCountryMarket.CollectionStoragePath) == nil {
    
                // create a new empty collection
                let collection <- DarkCountryMarket.createEmptyCollection() as! @DarkCountryMarket.Collection
    
                // save it to the account
                signer.save(<-collection, to: DarkCountryMarket.CollectionStoragePath)
    
                // create a public capability for the collection
                signer.link<&DarkCountryMarket.Collection{DarkCountryMarket.CollectionPublic}>(DarkCountryMarket.CollectionPublicPath, target: DarkCountryMarket.CollectionStoragePath)
            }
            
            self.marketCollection = getAccount(marketCollectionAddress)
                .getCapability<&DarkCountryMarket.Collection{DarkCountryMarket.CollectionPublic}>(
                    DarkCountryMarket.CollectionPublicPath
                )!
                .borrow()
                ?? panic("Could not borrow market collection from market address")

            let saleItem = self.marketCollection.borrowSaleItem(itemID: saleItemID)
                ?? panic("No item with that ID")
            let price = saleItem.price
                
            let mainFlowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ?? panic("Cannot borrow FlowToken vault from acct storage")
            
            self.paymentVault <- mainFlowTokenVault.withdraw(amount: price)
    
            self.darkCountryCollection = signer.borrow<&DarkCountry.Collection{NonFungibleToken.Receiver}>(
                from: DarkCountry.CollectionStoragePath
            ) ?? panic("Cannot borrow DarkCountry collection receiver from acct")
        }
    
        execute {
            self.marketCollection.purchase(
                itemID: saleItemID,
                buyerCollection: self.darkCountryCollection,
                buyerPayment: <- self.paymentVault
            )
        }
    }