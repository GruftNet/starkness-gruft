use starknet::ContractAddress;
use crate::interfaces::IOwnable::IOwnableTrait;

#[starknet::contract]
pub mod Ownable {
    use starknet::{ContractAddress, get_caller_address};
    use core::num::traits::Zero;
    use crate::interfaces::IOwnable::IOwnableTrait;

    #[storage]
    struct Storage {
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    pub struct OwnershipTransferred {
        pub previous_owner: ContractAddress,
        pub new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self._transfer_ownership(get_caller_address());
    }

    #[generate_trait]
    impl Internal of InternalTrait {
        fn _transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let previous_owner = self.owner.read();
            self.owner.write(new_owner);
            self.emit(Event::OwnershipTransferred(OwnershipTransferred { previous_owner, new_owner }));
        }

        fn assert_only_owner(self: @ContractState) {
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
        }
    }

    #[abi(embed_v0)]
    impl OwnableImpl of IOwnableTrait<ContractState> {
        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.assert_only_owner();
            assert(!new_owner.is_zero(), 'New owner is zero address');
            self._transfer_ownership(new_owner);
        }

        fn renounce_ownership(ref self: ContractState) {
            self.assert_only_owner();
            let zero_address = starknet::contract_address_const::<0>();
            self._transfer_ownership(zero_address);
        }
    }
}

