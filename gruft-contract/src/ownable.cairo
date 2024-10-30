use starknet::ContractAddress;
use starknet_vault::interfaces::IOwnable::IOwnable;

#[starknet::contract]
pub mod Ownable {
    use super::ContractAddress;
    use starknet::{get_caller_address, contract_address_const};
    use core::num::traits::Zero;


    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[storage]
    struct Storage {
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let deployer = get_caller_address();
        self._transfer_ownership(deployer);
    }

    #[abi(embed_v0)]
    impl OwnableImpl of super::IOwnable<ContractState> {
        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn is_owner(self: @ContractState) -> bool {
            get_caller_address() == self.owner.read()
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
            assert(!new_owner.is_zero(), 'New owner is the zero address');
            self._transfer_ownership(new_owner);
        }

        fn renounce_ownership(ref self: ContractState) {
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
            self._transfer_ownership(contract_address_const::<0>());
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let previous_owner = self.owner.read();
            self.owner.write(new_owner);
            
            // Emit ownership transfer event
            self.emit(Event::OwnershipTransferred(
                OwnershipTransferred { 
                    previous_owner,
                    new_owner,
                }
            ));
        }

        fn assert_only_owner(self: @ContractState) {
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
        }
    }
}

