import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { motion } from 'framer-motion'; 
import BottomNav from './Navbar';
import Logo from "../assets/Logo.png";
import { useVault } from './VaultContext';

const DashBoard: React.FC = () => {
  const { balance, lockPeriod, activeStatus, deposit, getLockedAmount } = useVault(); 
  const location = useLocation();
  const { username } = location.state as { username: string } || { username: '' };
  const [message, setMessage] = useState<string>('');
  const [transactionHistory, setTransactionHistory] = useState([
    { id: 1, type: 'Deposit', amount: '+ $500', className: 'text-green-500' },
    { id: 2, type: 'Withdraw', amount: '- $200', className: 'text-red-500' },
    { id: 3, type: 'Withdraw', amount: '- $300', className: 'text-red-500' },
  ]);

  const lockedAmount = getLockedAmount(); // Assuming this function returns the current locked amount

  const handleBreakLock = () => {
    if (activeStatus) {
      setMessage(`Amount sent to wallet: ${lockedAmount.toLocaleString()}`); // Show locked amount in the message

      // Add transaction history entry
      const newTransaction = {
        id: transactionHistory.length + 1,
        type: 'Break Lock',
        amount: `- ${lockedAmount.toLocaleString()}`,
        className: 'text-red-500',
      };
      setTransactionHistory([...transactionHistory, newTransaction]);

      // Reset locked amount logic if needed
      deposit(0, '', ''); // Assuming this will reset locked status in your context as well
    } else {
      setMessage('No active lock to break.');
    }
  };

  return (
    <motion.div 
      className={`min-h-screen flex flex-col items-center ${activeStatus ? 'bg-[#e5e5e5]' : 'bg-white'}`} 
      
    >
      {/* Header */}
      <motion.header
        className="w-full flex pl-20 items-center bg-[black] text-white  uppercase text-xl font-bold"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1.5 }}
      >
        <div className="relative inline-flex items-center">
          <motion.div
            className="absolute inset-0 bg-blue-500 rounded-full opacity-50 blur-md"
            animate={{ scale: [1, 1.1, 1] }} // Beating effect
            transition={{ duration: 1.5, repeat: Infinity }} // Repeat infinitely
          />
          <img src={Logo} className="relative h-[70px] w-[70px] z-10" alt="Image" />
        </div>
        {username ? `${username}'s gruft Vault ` : ' gruft Vault '}
      </motion.header>

      {/* Vault Balance */}
      <motion.div
        className="mt-6 p-4 w-11/12 bg-[#1E1E3E] rounded-xl shadow-md text-center"
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 1.5 }}
      >
        <h2 className="text-lg text-white">Vault Balance: ${balance.toLocaleString()}</h2>
        <h2 className="text-lg text-white">Locked Amount: ${lockedAmount.toLocaleString()}</h2>
        {activeStatus && (
          <div className="mt-4">
            <p className="text-white">Lock Period: {lockPeriod}</p>
            <p className="text-white">Status: {activeStatus ? 'Active' : 'Inactive'}</p>
          </div>
        )}
      </motion.div>

      {/* Action Buttons */}
      <div className="flex flex-col">
        <div className="grid grid-cols-2 justify-around mt-6 gap-5">
          <Link to="/Deposit">
            <motion.button
              className="bg-[#0a100d] text-white rounded-lg shadow-lg w-[100%] h-[40px] mx-2"
              whileHover={{ scale: 1.05 }} 
              whileTap={{ scale: 0.95 }} 
            >
              Lock
            </motion.button>
          </Link>

          <Link to="/Withdraw">
            <motion.button
              className="bg-[#0a100d] text-white rounded-lg shadow-lg w-[100%] h-[40px] mx-2"
              whileHover={{ scale: 1.05 }} 
              whileTap={{ scale: 0.95 }} 
            >
              Withdraw
            </motion.button>
          </Link>
        </div>

        {/* Additional Action Buttons */}
        <div className="grid grid-cols-2 justify-around mt-6 gap-5">
          <motion.button
            className="bg-[#0a100d] text-white p-2 rounded-lg shadow-lg w-[100%] h-[40px] mx-2"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={handleBreakLock}
          >
            Break Lock
          </motion.button>
          <motion.button
            className="bg-[#0a100d] text-white p-2 rounded-lg shadow-lg w-[100%] h-[40px] mx-2"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Add to lock
          </motion.button>
        </div>
      </div>

      {/* Message Display */}
      {message && <p className="mt-4 text-green-600">{message}</p>}

      {/* Transaction History */}

      <div className='relative top-10'>
      <h3 className="text-black  mb-4 font-bold text-xl ">Transaction History</h3>
      </div>
      <motion.div
        className="mt-6 w-[90%] h-[160px] bg-[#1E1E3E] rounded-xl shadow-md p-4 overflow-scroll"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1.5 }}
      >

        <ul>
          {transactionHistory.slice().reverse().map(transaction => (
            <li key={transaction.id} className="flex justify-between py-2">
              <span className="text-white">{transaction.type}</span>
              <span className={transaction.className}>{transaction.amount}</span>
            </li>
          ))}
        </ul>
      </motion.div>

      <div className='pt-10'>
        <BottomNav />
      </div>
    </motion.div>
  );
};

export default DashBoard;
