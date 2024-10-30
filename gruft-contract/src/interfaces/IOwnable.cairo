use starknet::ContractAddress;
#[starknet::interface]
pub trait IOwnable<TContractState> {
    fn owner(self: @TContractState) -> ContractAddress;
    fn is_owner(self: @TContractState) -> bool;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn renounce_ownership(ref self: TContractState);
}
