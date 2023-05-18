@echo off
cd ..
cd src.deploy

echo ############################################################
echo #### Mounting remidx at
echo #### %cd%
echo ############################################################
start /b remixd
start brave "https://remix.ethereum.org/#lang=en&optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.18+commit.87f61d96.js"