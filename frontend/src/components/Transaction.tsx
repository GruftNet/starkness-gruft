import React, { useEffect, useState } from 'react';
import './Transaction.css'; // Ensure this CSS file is created for styling

interface Transaction {
  id: number;
  type: string;
  amount: number;
  asset: string;
  date: string;
}

const TransactionHistory: React.FC = () => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchTransactions();
  }, []);

  const fetchTransactions = async () => {
    try {
      // Simulate fetching data from an API
      const fetchedTransactions: Transaction[] = [
        { id: 1, type: 'Deposit', amount: 1.0, asset: 'Ethereum', date: '2023-10-01' },
        { id: 2, type: 'Withdrawal', amount: 0.5, asset: 'Bitcoin', date: '2023-10-02' },
        { id: 3, type: 'Deposit', amount: 2.0, asset: 'Ethereum', date: '2023-10-03' },
        { id: 4, type: 'Withdrawal', amount: 0.3, asset: 'Ethereum', date: '2023-10-04' },
      ];
      setTransactions(fetchedTransactions);
    } catch (err) {
      setError('Failed to fetch transactions');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  return (
    <div className="transaction-history-container">
      <h1>Transaction History</h1>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Type</th>
            <th>Asset</th>
            <th>Amount</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {transactions.map((transaction) => (
            <tr key={transaction.id}>
              <td>{transaction.id}</td>
              <td>{transaction.type}</td>
              <td>{transaction.asset}</td>
              <td>{transaction.amount}</td>
              <td>{transaction.date}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default TransactionHistory;