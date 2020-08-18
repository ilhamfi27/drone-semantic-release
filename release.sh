#!/bin/bash

export SEMANTIC_RELEASE=${PLUGIN_SEMANTIC_RELEASE:-true}
export GIT_LOGIN=${PLUGIN_GIT_LOGIN:-$PLUGIN_GIT_USER_EMAIL}
export PLUGIN_GIT_USER_NAME=${PLUGIN_GIT_USER_NAME:-"semantic-release"}
export GIT_AUTHOR_NAME=$PLUGIN_GIT_USER_NAME
export GIT_AUTHOR_EMAIL=$PLUGIN_GIT_USER_EMAIL
export GIT_COMMITTER_NAME=$PLUGIN_GIT_USER_NAME
export GIT_COMMITTER_EMAIL=$PLUGIN_GIT_USER_EMAIL
export NPM_TOKEN=$PLUGIN_NPM_TOKEN
export NPM_USERNAME=$PLUGIN_NPM_USERNAME
export NPM_PASSWORD=$PLUGIN_NPM_PASSWORD
export NPM_EMAIL=$PLUGIN_NPM_EMAIL
export UPDATE_README_TOC=$PLUGIN_UPDATE_README_TOC
export README_LOCATION=${PLUGIN_README_LOCATION:-"README.md"}
export ADD_MODULES=$PLUGIN_ADD_MODULES
export ADD_APK=$PLUGIN_ADD_APK
export UPDATE_DOCKER_README=$PLUGIN_UPDATE_DOCKER_README

create_git_credentials() {
  # check git method elsewise it was causing problems
  if [ -z $PLUGIN_GIT_METHOD ]; then
    echo "Variable git_method must be set in settings."
    exit 1
  fi

  # create credentials for login
  if [ "$PLUGIN_GIT_METHOD" == "gh" ]; then
    export GH_TOKEN=$PLUGIN_GITHUB_TOKEN
    export GIT_PASSWORD=$PLUGIN_GITHUB_TOKEN
  elif [ "$PLUGIN_GIT_METHOD" == "gl" ]; then
    export GL_TOKEN=$PLUGIN_GITLAB_TOKEN
    export GIT_PASSWORD=$PLUGIN_GITLAB_TOKEN
  elif [ "$PLUGIN_GIT_METHOD" == "bb" ]; then
    export BB_TOKEN=$PLUGIN_BITBUCKET_TOKEN
    export GIT_PASSWORD=$PLUGIN_BITBUCKET_TOKEN
  elif [ "$PLUGIN_GIT_METHOD" == "cr" ]; then
    export GIT_CREDENTIALS=$(node /semantic-release/create-credentials.js)
  else
    echo "Variable git_method must be one of the following: gh (Github), gl (GitLab), bb (BitBucket), cr (Credentials)"
    exit 1
  fi

  # define the user
  if [ -z "$PLUGIN_GIT_USER_NAME" ]; then
    echo "GIT Username not defined! Please set git_user_name in Drone plugin settings."
    exit 127
  elif [ -z "$PLUGIN_GIT_USER_EMAIL" ]; then
    echo "GIT E-Mail not defined! Please set git_user_email in Drone plugin settings."
    exit 127
  fi

  # Set git variables
  git config --global user.name "$GIT_COMMITTER_NAME"
  git config --global user.email "$GIT_COMMITTER_EMAIL"
  git config --global credential.helper store

  # login with credentials
  git config --global credential.helper "!f() { echo 'username=${GIT_LOGIN}'; echo 'password=${GIT_PASSWORD}'; }; f"
}

update_readme_toc() {
  if [[ $UPDATE_README_TOC == "true" ]]; then

    README_LOCATION=($(echo $README_LOCATION))

    for i in ${README_LOCATION}; do
      echo "Updating TOC README@${i}"
      markdown-toc /drone/src/${i} --bullets="-" -i
    done

  fi
}

# this is the semantic release part
if [ ! -z $SEMANTIC_RELEASE ] && [ "$SEMANTIC_RELEASE" = "true" ]; then

  export MODE=$PLUGIN_MODE

  echo "Enabled semantic-release in $MODE mode."

  create_git_credentials

  # add semantic-release modules if defined
  if [ ! -z "$ADD_APK" ]; then
    for i in "${ADD_APK[@]}"; do
      echo "Installing APK package $i..."
      apk add --no-cache --no-progress $i
    done
  fi

  if [ ! -z "$ADD_MODULES" ]; then
    for i in "${ADD_MODULES[@]}"; do
      echo "Installing node module $i..."
      yarn global add $i
    done
  fi

  # copy git config if given
  if [ ! -f release.config.js ] && [ ! -f .releaserc ] && [ "$PLUGIN_USE_LOCAL_RC" != "true" ]; then
    echo "release.config.js || .releaserc not found using defaults"
    cp /semantic-release/release-config/npm.js release.config.js
  fi

  if [ "$MODE" = "predict" ]; then
    echo 'Running semantic release in dry mode...'
    ${PLUGIN_OVERRIDE:-semantic-release -d $PLUGIN_ARGUMENTS} || exit 1
  else
    update_readme_toc

    ${PLUGIN_OVERRIDE:-semantic-release $PLUGIN_ARGUMENTS} || exit 1
  fi

  rm release.config.js
fi

# handle readme toc update explicitly if semantic-release is disabled
if [ -z $SEMANTIC_RELEASE ] || [ "$SEMANTIC_RELEASE" = "false" ] && [ "$UPDATE_README_TOC" == "true" ]; then

  create_git_credentials

  update_readme_toc

  (cd /drone/src/ && git add ${README_LOCATION} && git commit -m "chore(release): update readme toc [skip ci]" && git push -u origin $DRONE_REPO_BRANCH)

fi

# handle dockerhub readme update
if [ ! -z "$UPDATE_DOCKER_README" ] && [ "$UPDATE_DOCKER_README" != "false" ]; then
  [ "$UPDATE_DOCKER_README" == "true" ] && $UPDATE_DOCKER_README="README.md"
  exec /semantic-release/scripts/update-docker-readme.sh
fi
