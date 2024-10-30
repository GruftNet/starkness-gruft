import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import './Body.css'; // Ensure this CSS file is created for styling
import Logo from "../assets/Logo.png"

const Body: React.FC = () => {
  const navigate = useNavigate();

  const handleConnectWallet = async () => {
    
      console.error("Error connecting wallet:");
    navigate("/Dashboard")
  };
  

  const handleLearnMore = () => {
    navigate('/'); // Navigate to a page with more information
  };

  return (
    <div className="welcome-container">
         <div className="relative inline-flex items-center">
  <motion.div
    className="absolute inset-0 bg-blue-500 rounded-full opacity-50 blur-md"
    animate={{ scale: [1, 1.1, 1] }} // Beating effect
    transition={{ duration: 1.5, repeat: Infinity }} // Repeat infinitely
  />
  <img src={Logo} className="relative h-[100px] w-[100px] z-10 object-cover" alt="Image" />
</div>
      <motion.h1 
        initial={{ opacity: 0, translateY: -20 }} 
        animate={{ opacity: 1, translateY: 0 }} 
        transition={{ duration: 0.6 }}
        className=' capitalize font-bold'
      >
        Welcome to gruft Vault!
      </motion.h1>

      <motion.p 
        initial={{ opacity: 0, translateY: -20 }} 
        animate={{ opacity: 1, translateY: 0 }} 
        transition={{ duration: 0.6, delay: 0.2 }}
        className=' text-lg font-medium'
      >
        Securely store and manage your digital assets with our decentralized vault.
        Experience the power of Web3 and take control of your financial future.
      </motion.p>

      <motion.div 
        className="button-container"
        initial={{ opacity: 0, translateY: 20 }} 
        animate={{ opacity: 1, translateY: 0 }} 
        transition={{ duration: 0.6, delay: 0.4 }}
      >
        <motion.button 
          onClick={handleConnectWallet} 
          className="welcome-btn"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Connect Wallet
        </motion.button>

        <motion.button 
          onClick={handleLearnMore} 
          className="welcome-btn"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Learn More
        </motion.button>
      </motion.div>
    </div>
  );
};

export default Body;
