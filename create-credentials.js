const { PLUGIN_GIT_LOGIN, PLUGIN_GIT_PASSWORD } = process.env;

if (PLUGIN_GIT_LOGIN && PLUGIN_GIT_PASSWORD) {
  console.log(`${encodeURIComponent(PLUGIN_GIT_LOGIN)}:${encodeURIComponent(PLUGIN_GIT_PASSWORD)}`);
} else {
  console.log('Credentials are not set properly. Please set settings git_login and git_password')
}