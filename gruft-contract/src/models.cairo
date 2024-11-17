#[derive(Drop, Serde, Copy, starknet::Store)]
pub enum Days {
    Days7: u64,
    Days14: u64,
    Days21: u64,
    Days30: u64,
}

#[derive(Drop, Serde, Copy, starknet::Store)]
pub struct Deposits {
    pub amount: u256,
    pub lock_time: u256,
    pub lock_period: Days,
}

impl DaysIntoU64 of Into<Days, u64> {
    fn into(self: Days) -> u64 {
        match self {
            Days::Days7 => 7 * 24 * 60 * 60,    // Convert to seconds
            Days::Days14 => 14 * 24 * 60 * 60,
            Days::Days21 => 21 * 24 * 60 * 60,
            Days::Days30 => 30 * 24 * 60 * 60,
        }
    }
}
