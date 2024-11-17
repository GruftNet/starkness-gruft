use crate::models::{Days, Deposits};
use crate::interfaces::IVault::IVault;
use crate::interfaces::IERC20::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};
use crate::ownable::Ownable;

#[starknet::contract]
mod VaultGruft {
    use super::{Days, Deposits, IVault};
    use crate::errors::Errors::{ZERO_AMOUNT, LOCK_PERIOD_NOT_REACHED};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};
    use crate::ownable::Ownable::OwnershipTransferred;

    const SCALE: u256 = 1_000_000;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        token: IERC20Dispatcher,
        balance: u256,
        total_shares: u256,
        shares: Map<ContractAddress, u256>,
        lock_period: Days,
        owner_details: Map::<ContractAddress, u256>,
        last_deposit_time: Map<ContractAddress, u64>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Deposit: Deposit,
        Withdraw: Withdraw,
        Lock: Lock,
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct Deposit {
        user: ContractAddress,
        amount: u256,
        shares: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Withdraw {
        user: ContractAddress,
        amount: u256,
        shares: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Lock {
        user: ContractAddress,
        amount: u256,
        days: Days,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        initial_owner: ContractAddress,
        token_address: ContractAddress,
    ) {
        self.owner.write(initial_owner);
        self.token.write(IERC20Dispatcher { contract_address: token_address });
        self.total_shares.write(0);
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn assert_only_owner(self: @ContractState) {
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
        }
    }

    #[abi(embed_v0)]
    impl IVaultImpl of super::IVault<ContractState> {
        fn deposit(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();
            assert(amount > 0, ZERO_AMOUNT);

            // Transfer tokens from the caller to the vault
            self.token.read().transfer_from(caller, get_contract_address(), amount);

            // Calculate shares to mint
            let total_shares = self.total_shares.read();
            let shares = if total_shares == 0 {
                amount * SCALE
            } else {
                (amount * SCALE) / total_shares
            };

            // Update state
            self.shares.write(caller, self.shares.read(caller) + shares);
            self.total_shares.write(total_shares + shares);
            self.last_deposit_time.write(caller, get_block_timestamp());

            // Emit event
            self.emit(Event::Deposit(Deposit { 
                user: caller, 
                amount, 
                shares 
            }));
        }

        fn withdraw(ref self: ContractState, amount: u256) -> u256 {
            let owner = get_caller_address();
            let last_deposit_time = self.last_deposit_time.read(owner);
            let current_time: u64 = get_block_timestamp();
            let time_elapsed: u64 = current_time - last_deposit_time;
            
            // Calculate withdrawal
            let user_shares = self.shares.read(owner);
            let total_shares = self.total_shares.read();
            let withdrawal_amount = (user_shares * self.balance.read()) / total_shares;

            assert(withdrawal_amount >= amount, ZERO_AMOUNT);

            // Transfer tokens
            self.token.read().transfer(owner, withdrawal_amount);

            // Update shares
            let shares_to_burn = (amount * SCALE) / total_shares;
            self.shares.write(owner, user_shares - shares_to_burn);
            self.total_shares.write(total_shares - shares_to_burn);

            // Emit event
            self.emit(Event::Withdraw(Withdraw { 
                user: owner, 
                amount, 
                shares: shares_to_burn 
            }));

            withdrawal_amount
        }

        fn lock(ref self: ContractState, amount: u256, period: Days) {
            assert(amount > 50, ZERO_AMOUNT);

            let mut total_amount = amount;
            if amount < 300 {
                let bonus = (amount * 12) / 100;
                total_amount += bonus;
            } else {
                let bonus = (amount * 15) / 100;
                total_amount += bonus;
            }

            let current_balance = self.balance.read();
            self.balance.write(current_balance + total_amount);
            self.lock_period.write(period);

            self.emit(Event::Lock(Lock {
                user: get_caller_address(),
                amount,
                days: period,
            }));
        }

        fn break_lock(ref self: ContractState, amount: u256) {
            let user = get_caller_address();
            let last_deposit_time = self.last_deposit_time.read(user);
            let current_time: u64 = get_block_timestamp();
            let lock_period = self.lock_period.read();
            
            // Convert lock_period to seconds and check time
            let lock_duration: u64 = lock_period.into();
            let lock_end_time = last_deposit_time + lock_duration;
            assert(current_time >= lock_end_time, LOCK_PERIOD_NOT_REACHED);

            // Calculate penalty
            let penalty_amount = (amount * 5) / 100;
            let withdrawal_amount = amount - penalty_amount;

            // Update balances
            self.balance.write(self.balance.read() + penalty_amount);
            self.token.read().transfer(user, withdrawal_amount);

            // Update shares
            let shares_to_burn = (withdrawal_amount * SCALE) / self.total_shares.read();
            self.shares.write(user, self.shares.read(user) - shares_to_burn);
            self.total_shares.write(self.total_shares.read() - shares_to_burn);

            self.emit(Event::Withdraw(Withdraw {
                user,
                amount: withdrawal_amount,
                shares: shares_to_burn,
            }));
        }

        fn set_owner_detail(ref self: ContractState, key: ContractAddress, value: u256) {
            self.assert_only_owner();
            self.owner_details.write(key, value);
        }

        fn get_owner_balance(self: @ContractState, key: ContractAddress) -> u256 {
            self.owner_details.read(key)
        }
    }
}