use crate::models::{Days, Deposits};
use crate::interfaces::IVault::{IVault};
use crate::interfaces::IERC20::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};
use crate::ownable;
use crate::ownable::{Ownable};


#[starknet::contract]
mod VaultGruft {
    use super::IVault;
use core::num::traits::Zero;
    use super::{Days, Deposits};
    use crate::errors::Errors::{ZERO_AMOUNT, LOCK_PERIOD_NOT_REACHED};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};


    #[storage]
    struct Storage {
        owner: ContractAddress,
        token: IERC20Dispatcher,
        balance: u256,
        total_shares: u256,
        shares: Map<ContractAddress, u256>,
        lock_period: Days,
        owner_details: Map::<ContractAddress, u128>,
        last_deposit_time: Map<ContractAddress, u64>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnershipTransferred,
        Deposit: Deposit,
        Withdraw: Withdraw,
        Lock: Lock,
    }

    const SCALE: u256 = 1_000_000;

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Deposit {
        user: ContractAddress,
        amount: u128,
        shares: u128,
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
        amount: u128,
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


    #[abi(embed_v0)]
    impl IVaultImpl of super::IVault<ContractState> {
        fn deposit(ref self: ContractState, amount: u256) {

            self.assert_only_owner();
            let caller = get_caller_address();
            assert(amount > 0, ZERO_AMOUNT);

            // Transfer tokens from the caller to the vault
            self.token.read().transfer_from(caller, get_contract_address(), amount);

            // Calculate the number of shares to mint
            let shares = (amount * SCALE) / self.total_shares.read();
            self.shares.write(caller, self.shares.read(caller) + shares);
            self.total_shares.write(self.total_shares.read() + shares);

            // Update the last deposit time
            self.last_deposit_time.write(caller, get_block_timestamp());

            // Emit a Deposit event
            self.emit(Event::Deposit(Deposit {
                user: caller,
                amount: amount.try_into().unwrap(),
                shares: shares.try_into().unwrap(),
            }));
        }

        fn lock(ref self: ContractState, amount: u128, period: Days) {
            self.assert_only_owner();
            assert(amount > 50, ZERO_AMOUNT);

            let mut total_amount = amount;
            if amount < 300 {
                let bonus = (amount * 12) / 100;
                total_amount += bonus;
            }
            if amount >= 300 {
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

        fn set_owner_detail(ref self: ContractState, key: ContractAddress, value: u128) {
            self.owner_details.write(key, value);
        }

        fn get_owner_balance(self: @ContractState, key: ContractAddress) -> u128 {
            self.owner_details.read(key)
        }

     

    //     fn withdraw(ref self: ContractState, amount: u256) -> u64  {
    

    //       let owner = get_caller_address();
    //       let last_deposit_time = self.last_deposit_time.read(owner);
    //       let current_time = get_block_timestamp();
    //       let lock_period = self.lock_period.read();
    //       let time_elapsed = current_time - last_deposit_time;

    //       assert(get_block_timestamp() > self.lock_period.read(), LOCK_PERIOD_NOT_REACHED);
    //       // // Check if the lock period has been reached
    //       // assert(current_time >= last_deposit_time + lock_period, LOCK_PERIOD_NOT_REACHED);
      
    //       // // Calculate the withdrawal amount based on the user's shares
    //       let user_shares = self.shares.read(owner);
    //       let total_shares = self.total_shares.read();
    //       let withdrawal_amount = (user_shares * self.balance.read()) / total_shares;
      
    //       // // Ensure the requested withdrawal amount is within the user's available balance
    //       assert(withdrawal_amount >= amount, ZERO_AMOUNT);
      
    //       // // Transfer the withdrawal amount to the user
    //       self.token.read().transfer(owner, withdrawal_amount);
      
    //       // // Update the user's shares and the total shares
    //       self.shares.write(owner, user_shares - (amount * SCALE) / total_shares);
    //       self.total_shares.write(total_shares - (amount * SCALE) / total_shares);
      
    //       // // Emit a Withdraw event
    //       self.emit(Event::Withdraw(Withdraw {
    //           user: owner,
    //           amount,
    //           shares: (amount * SCALE) / total_shares,
    //       }));
    //   }




    fn withdraw(ref self: ContractState, amount: u256) -> u64 {
        let owner = get_caller_address();
        let last_deposit_time = self.last_deposit_time.read(owner);
        let current_time = get_block_timestamp();
        let lock_period = self.lock_period.read();
        let time_elapsed = current_time - last_deposit_time;
        
        // Convert lock_period (Days enum) to seconds and check if enough time has passed
        assert(time_elapsed >= lock_period.to_seconds(), LOCK_PERIOD_NOT_REACHED);

        // Calculate the withdrawal amount based on the user's shares
        let user_shares = self.shares.read(owner);
        let total_shares = self.total_shares.read();
        let withdrawal_amount = (user_shares * self.balance.read()) / total_shares;

        // Ensure the requested withdrawal amount is within the user's available balance
        assert(withdrawal_amount >= amount, ZERO_AMOUNT);

        // Transfer the withdrawal amount to the user
        self.token.read().transfer(owner, withdrawal_amount);

        // Update the user's shares and the total shares
        let shares_to_burn = (amount * SCALE) / total_shares;
        self.shares.write(owner, user_shares - shares_to_burn);
        self.total_shares.write(total_shares - shares_to_burn);

        // Emit a Withdraw event
        self.emit(Event::Withdraw(Withdraw {
            user: owner,
            amount,
            shares: shares_to_burn,
        }));

        // Return the time elapsed since last deposit
        time_elapsed
    }


        fn break_lock(ref self: ContractState, amount: u128) {
            self.assert_only_owner();

            let owner = get_caller_address();

            let last_deposit_time = self.last_deposit_time.read(owner);
            let current_time = get_block_timestamp();
            let lock_period = self.lock_period.read();
    
            // Check if the lock period has been reached
            assert(current_time >= last_deposit_time + lock_period, LOCK_PERIOD_NOT_REACHED);
    
            // Calculate the penalty amount (5% of the requested amount)
            let penalty_amount = (amount * 5) / 100;
    
            // Calculate the withdrawal amount after the penalty
            let withdrawal_amount = amount - penalty_amount;
    
            // Transfer the penalty amount to the vault's balance
            self.balance.write(self.balance.read() + penalty_amount);
    
            // Transfer the withdrawal amount to the user
            self.token.read().transfer(owner, withdrawal_amount);
    
            // Update the user's shares and the total shares
            let user_shares = self.shares.read(owner);
            self.shares.write(owner, user_shares - (withdrawal_amount * SCALE) / self.total_shares.read());
            self.total_shares.write(self.total_shares.read() - (withdrawal_amount * SCALE) / self.total_shares.read());
    
            // Emit a Withdraw event
            self.emit(Event::Withdraw(Withdraw {
                owner,
                amount: withdrawal_amount,
                shares: (withdrawal_amount * SCALE) / self.total_shares.read(),
            }));
        }
    }
}