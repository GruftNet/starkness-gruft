import React, { createContext, useContext, useState, ReactNode } from 'react';

interface VaultContextType {
  balance: number;
  lockTime: string;
  lockPeriod: string;
  activeStatus: boolean;
  lockedAmount: number; // Add the locked amount type
  deposit: (amount: number, time: string, period: string) => void;
  getLockedAmount: () => number; // Add the method to get the locked amount
}

const VaultContext = createContext<VaultContextType | undefined>(undefined);

export const VaultProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [balance, setBalance] = useState<number>(0);
  const [lockTime, setLockTime] = useState<string>('');
  const [lockPeriod, setLockPeriod] = useState<string>('');
  const [activeStatus, setActiveStatus] = useState<boolean>(false);
  const [lockedAmount, setLockedAmount] = useState<number>(0); // State for the locked amount

  const deposit = (amount: number, time: string, period: string) => {
    setBalance(prevBalance => prevBalance + amount);
    setLockedAmount(amount); // Update locked amount when depositing
    setLockTime(time);
    setLockPeriod(period);
    setActiveStatus(true);
  };
  

  const getLockedAmount = () => {
    return lockedAmount; // Return the current locked amount
  };

  return (
    <VaultContext.Provider value={{ balance, lockTime, lockPeriod, activeStatus, lockedAmount, deposit, getLockedAmount }}>
      {children}
    </VaultContext.Provider>
  );
};

export const useVault = () => {
  const context = useContext(VaultContext);
  if (!context) {
    throw new Error('useVault must be used within a VaultProvider');
  }
  return context;
};
