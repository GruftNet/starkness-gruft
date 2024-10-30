import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const Withdrawal: React.FC = () => {
  const navigate = useNavigate();
  const [assetType, setAssetType] = useState<string>('Ethereum');
  const [amount, setAmount] = useState<number | string>('');
  const [message, setMessage] = useState<string>('');

  const handleWithdrawal = async () => {
    if (!amount || isNaN(Number(amount)) || Number(amount) <= 0) {
      setMessage('Please enter a valid amount.');
      return;
    }

    console.log(`Withdrawing ${amount} ${assetType}...`);
    setMessage(`Successfully withdrew ${amount} ${assetType}!`);
    
    setAmount('');
  };

  const handleReturn = () => {
    navigate('/dashboard');
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#1E1E3E] text-white  p-6">
      <div className="bg-black rounded-lg shadow-md p-8 w-full max-w-md">
        <h1 className="text-2xl font-bold mb-4">Withdraw Assets</h1>
        <div className="mb-4">
          <label htmlFor="assetType" className="block text-sm font-medium text-white ">Select Asset Type:</label>
          <select
            id="assetType"
            value={assetType}
            onChange={(e) => setAssetType(e.target.value)}
            className="mt-1 block w-full border border-gray-300 text-black rounded-md p-2 focus:outline-none focus:ring focus:ring-blue-500"
          >
            <option value="Ethereum">Ethereum</option>
            <option value="Bitcoin">Bitcoin</option>
            {/* Add more asset options as needed */}
          </select>
        </div>
        <div className="mb-4">
          <label htmlFor="amount" className="block text-sm font-medium text-white">Amount:</label>
          <input
            type="number"
            id="amount"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="Enter amount"
            className="mt-1 block w-full border border-gray-300 text-black rounded-md p-2 focus:outline-none focus:ring focus:ring-blue-500"
          />
        </div>
        <button onClick={handleWithdrawal} className="w-full bg-blue-600 text-white font-semibold py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring focus:ring-blue-300">
          Withdraw
        </button>
        {message && <p className="mt-2 text-green-600">{message}</p>}

        <button onClick={handleReturn} className="mt-4 w-full bg-gray-300 text-gray-700 font-semibold py-2 rounded-md hover:bg-gray-400 focus:outline-none focus:ring focus:ring-gray-300">
          Return to Dashboard
        </button>
      </div>
    </div>
  );
};

export default Withdrawal;
