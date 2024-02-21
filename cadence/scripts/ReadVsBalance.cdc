import FungibleToken from 0x05
import Vstoken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &Vstoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Vstoken.CollectionPublic}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&Vstoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Vstoken.CollectionPublic}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- Vstoken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&Vstoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Vstoken.CollectionPublic}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &Vstoken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&Vstoken.Vault{FungibleToken.Balance}>()
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &Vstoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Vstoken.CollectionPublic} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&Vstoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Vstoken.CollectionPublic}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if Vstoken.vaults.contains(checkVault.uuid) {
            log(publicVault?.balance)
            log("This is a Atoken vault")
        } else {
            log("This is not a Atoken vault")
        }
    }
}
