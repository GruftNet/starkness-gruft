pub mod Errors {
    pub const ZERO_ADDRESS_ERROR: felt252 = 'ERC20: zero address';
    pub const INSUFFICIENT_BALANCE: felt252 = 'ERC20: insufficient balance';
    pub const INSUFFICIENT_ALLOWANCE: felt252 = 'ERC20: insufficient allowance';
    pub const MINT_TO_ZERO: felt252 = 'ERC20: mint to zero address';
    pub const BURN_FROM_ZERO: felt252 = 'ERC20: burn from zero';
    pub const BURN_EXCEEDS_SUPPLY: felt252 = 'ERC20: burn exceeds supply';
    pub const ONLY_OWNER: felt252 = 'ERC20: only owner can mint';
    pub const DECREASE_ALLOWANCE_BELOW_ZERO: felt252 = 'ERC20: decreased below zero';
    pub const ZERO_AMOUNT: felt252 = 'ZERO AMOUNT!';
    pub const LOW_STAKE_TIME: felt252 = 'LOW STAKE TIME!';
    pub const TIME_NOT_REACHED: felt252 = 'TIME NOT REACHED!';
    pub const ZERO_ADDRESS: felt252 = 'ZERO ADDRESS';
    pub const NO_BONUS: felt252 = 'ZERO BONUS';
    pub const LOCK_PERIOD_NOT_REACHED: felt252 = 'LOCK_PERIOD_NOT_REACHED';
}


