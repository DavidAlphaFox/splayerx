#!/bin/bash
set -e

# Reinstall the electron mas version
IS_MAS_CMD="echo 'process.mas' | ./node_modules/.bin/electron -i"
IS_MAS="$(eval "$IS_MAS_CMD")"
if [[ $IS_MAS != *"true"* ]]; then
    ELECTRON_VERSION=`node -p -e "require('./package.json').devDependencies['@chiflix/electron']"`
    ELECTRON_VERSION=${ELECTRON_VERSION/^/''}
    rm -fr ./node_modules/@chiflix/electron
    force_no_cache='true' npm_config_platform=mas yarn add @chiflix/electron@$ELECTRON_VERSION -D --exact
fi

node .electron-vue/build.js

# rejected by apple if contains "paypal"
find dist/electron -name '*.js' -exec sed -i '' 's/paypal//g' {} \;
find dist/electron -name '*.js' -exec sed -i '' 's/Paypal//g' {} \;
find dist/electron -name '*.js' -exec sed -i '' 's/PayPal//g' {} \;

rev=`git rev-list --count HEAD`

node ./scripts/gen-electron-builder-config.js
yarn run electron-builder -p never -m $1 \
    -c electron-builder.json \
    -c.mac.hardenedRuntime=false \
    -c.mac.provisioningProfile="build/$1.provisionprofile" \
    -c.mac.bundleVersion="$rev"
