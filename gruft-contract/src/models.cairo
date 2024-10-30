#[derive(Drop, Serde, Copy, starknet::Store)]
pub enum Days {
    Days7: u64,
    Days14: u64,
    Days21: u64,
    Days30: u64,
}

impl Days {
    pub fn to_seconds(&self) -> u64 {
        match self {
            Days::Days7 => 7 * 24 * 60 * 60,
            Days::Days14 => 14 * 24 * 60 * 60,
            Days::Days21 => 21 * 24 * 60 * 60,
            Days::Days30 => 30 * 24 * 60 * 60,
        }
    }
}

#[derive(Drop, Serde, Copy, starknet::Store)]
pub struct Deposits {
    pub amount: u128,
    pub lock_time: u64,
    pub lock_period: Days,
}
