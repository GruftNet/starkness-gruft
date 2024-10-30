
use crate::models::{Days};
use core::starknet::ContractAddress;

#[starknet::interface]
pub trait IVault<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn lock(ref self: TContractState, amount: u128, period: Days);
    fn break_lock(ref self: TContractState, amount: u128);
    fn get_owner_balance(self: @TContractState, key: ContractAddress) -> u128;
    fn withdraw(ref self: TContractState, amount: u256) -> u64;
    fn set_owner_detail(ref self: TContractState, key: ContractAddress, value: u128);
    // fn processing_withdraw(ref self: TContractState, amount: u128);
}