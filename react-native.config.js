const project = (() => {
  const fs = require("node:fs");
  const path = require("node:path");
  try {
    const {configureProjects} = require("react-native-test-app");

    return configureProjects({
      android: {
        sourceDir: path.join("example", "android"),
      },
      ios: {
        sourceDir: "example/ios",
      },
    });
  } catch (e) {
    return undefined;
  }
})();

module.exports = {
  dependencies: {
    // Help rn-cli find and autolink this library
    "react-native-tangem-sdk": {
      root: __dirname,
    },
  },
  ...(project ? {project} : undefined),
};
