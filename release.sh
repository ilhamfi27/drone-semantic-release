#!/bin/sh

export MODE=$PLUGIN_MODE

if [ -z $PLUGIN_GIT_METHOD ]; then
  echo "Variable git_method must be set in settings."
  exit 1
fi

export GIT_AUTHOR_NAME=$PLUGIN_GIT_USER_NAME
export GIT_AUTHOR_EMAIL=$PLUGIN_GIT_USER_EMAIL
export GIT_COMMITTER_NAME=$PLUGIN_GIT_USER_NAME
export GIT_COMMITTER_EMAIL=$PLUGIN_GIT_USER_EMAIL
export NPM_TOKEN=$PLUGIN_NPM_TOKEN

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

if [ ! -f .releaserc ] || [ "$PLUGIN_USE_LOCAL_RC" = "true" ]; then
  echo ".releaserc not found using defaults"
  cp /semantic-release/.releaserc.json .releaserc
fi

if [ "$MODE" = "predict" ]; then
  echo 'Running semantic release in dry mode...'
  MOCK_RUN=$(semantic-release -d $PLUGIN_ARGUMENTS || exit 1)
  echo $MOCK_RUN | grep 'Published release' | sed -E 's/.*([0-9]+.[0-9]+.[0-9]+)/\1/'
  echo $MOCK_RUN | grep 'no relevant changes'
else
  semantic-release $PLUGIN_ARGUMENTS || exit 1
fi
