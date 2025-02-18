const path = require("path");
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const parent_dir = path.resolve(__dirname, '../');

const config = {
  resolver: {
    extraNodeModules: {
      'react-native-tangem-sdk': parent_dir,
    },
  },
  watchFolders: [
    parent_dir,
  ],
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);

