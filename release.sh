#!/bin/bash

export SEMANTIC_RELEASE=${PLUGIN_SEMANTIC_RELEASE:-true}
export GIT_AUTHOR_NAME=$PLUGIN_GIT_USER_NAME
export GIT_AUTHOR_EMAIL=$PLUGIN_GIT_USER_EMAIL
export GIT_COMMITTER_NAME=$PLUGIN_GIT_USER_NAME
export GIT_COMMITTER_EMAIL=$PLUGIN_GIT_USER_EMAIL
export NPM_TOKEN=$PLUGIN_NPM_TOKEN
export UPDATE_README_TOC=$PLUGIN_UPDATE_README_TOC
export README_LOCATION=${README_LOCATION:-README.md}
export ADD_MODULES=$PLUGIN_ADD_MODULES
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
  elif [ "$PLUGIN_GIT_METHOD" == "gl" ]; then
    export GL_TOKEN=$PLUGIN_GITLAB_TOKEN
  elif [ "$PLUGIN_GIT_METHOD" == "bb" ]; then
    export BB_TOKEN=$PLUGIN_BITBUCKET_TOKEN
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
}

# this is the semantic release part
if [ ! -z $SEMANTIC_RELEASE ] && [ "$SEMANTIC_RELEASE" = "true" ]; then

  export MODE=$PLUGIN_MODE

  echo "Enabled semantic-release in $MODE mode."

  create_git_credentials

  # add semantic-release modules if defined
  if [ ! -z "$ADD_MODULES" ]; then
    for i in "${ADD_MODULES[@]}"; do
      yarn global add "$i"
    done
  fi

  # copy git config if given
  if [ ! -f release.config.js ] && [ ! -f .releaserc ] && [ "$PLUGIN_USE_LOCAL_RC" != "true" ]; then
    echo "release.config.js || .releaserc not found using defaults"
    cp /semantic-release/release.config.js release.config.js
  fi

  if [ "$MODE" = "predict" ]; then
    echo 'Running semantic release in dry mode...'
    semantic-release -d || exit 1
  else
    # handle readme update with semantic_release if semantic release is on
    [ $UPDATE_README_TOC = 'true' ] && echo "Updating README@${README_LOCATION}" && markdown-toc /drone/src/${README_LOCATION} --bullets="-" -i --no-firsth1

    semantic-release $PLUGIN_ARGUMENTS || exit 1
  fi

fi

# handle readme toc update explicitly if semantic-release is disabled
if [ -z $SEMANTIC_RELEASE ] || [ "$SEMANTIC_RELEASE" = "false" ]; then
  create_git_credentials
  [ $UPDATE_README_TOC = 'true' ] && echo "Updating README@${README_LOCATION}" && markdown-toc /drone/src/${README_LOCATION} --bullets="-" -i --no-firsth1
  (cd /drone/src/ && git add ${README_LOCATION}) && git commit -m "chore(release): update readme toc [skip ci]" && git push
fi

# Handle dockerhub readme update
if [ ! -z "$UPDATE_DOCKER_README" ] && [ "$UPDATE_DOCKER_README" == "true" ]; then
  "Updating DockerHUB README@${README_LOCATION}"
  exec ./update-docker-readme.sh
fi
