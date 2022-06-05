const path = require("path");

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    develop: {
      // port: 8545
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    }
  },
  compilers:{
    solc:{
      version: ">=0.7.0 <0.9.0",
      optimizer: {
        enabled: false,
        runs: 200
      },
      evmVersion: "byzantium"
    },
    
  }
};
