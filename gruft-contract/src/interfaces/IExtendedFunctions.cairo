use core::starknet::ContractAddress;

#[starknet::interface]
pub trait IExtendedFunctions<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, amount: u256);
    fn increase_allowance(ref self: TContractState, spender: ContractAddress, added_value: u256) -> bool;
    fn decrease_allowance(ref self: TContractState, spender: ContractAddress, subtracted_value: u256) -> bool;
}