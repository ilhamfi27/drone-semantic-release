const {
  PLUGIN_GIT_HOST,
  PLUGIN_GIT_HOST_PROTO,
  PLUGIN_GIT_LOGIN,
  PLUGIN_GIT_PASSWORD,
} = process.env;

if (PLUGIN_GIT_HOST && PLUGIN_GIT_HOST_PROTO) {
  console.log(
    `!f() { echo 'host=${PLUGIN_GIT_HOST}'; echo 'protocol=${PLUGIN_GIT_HOST_PROTO}'; echo 'username=${PLUGIN_GIT_LOGIN}'; echo 'password=${PLUGIN_GIT_PASSWORD}'; }; f`
  );
} else {
  console.log(
    `!f() { echo 'username=${PLUGIN_GIT_LOGIN}'; echo 'password=${PLUGIN_GIT_PASSWORD}'; }; f`
  );
}