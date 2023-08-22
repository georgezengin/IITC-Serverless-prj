#!/bin/bash
echo '=========================================================================='
echo '====== install nodejs & npm ==================================='
echo '=========================================================================='
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts
nvm install 16
node -e "console.log('Running Node.js ' + process.version)"
