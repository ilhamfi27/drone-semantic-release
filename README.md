# drone-semantic-release

[![Build Status](https://drone.kilic.dev/api/badges/cenk1cenk2/drone-semantic-release/status.svg)](https://drone.kilic.dev/cenk1cenk2/drone-semantic-release)
[![Docker Pulls](https://img.shields.io/docker/pulls/cenk1cenk2/drone-semantic-release)](https://hub.docker.com/repository/docker/cenk1cenk2/drone-semantic-release)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/cenk1cenk2/drone-semantic-release)](https://hub.docker.com/repository/docker/cenk1cenk2/drone-semantic-release)
[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/cenk1cenk2/drone-semantic-release)](https://hub.docker.com/repository/docker/cenk1cenk2/drone-semantic-release)
[![GitHub last commit](https://img.shields.io/github/last-commit/cenk1cenk2/drone-semantic-release)](https://github.com/cenk1cenk2/drone-semantic-release)

Drone plugin for making semantic releases based on https://github.com/semantic-release/semantic-release. With some added twists ofc.

<!-- toc -->

- [Custom Release File](#custom-release-file)
- [What it does](#what-it-does)

<!-- tocstop -->

## Usage

See [commit message format](https://github.com/semantic-release/semantic-release#commit-message-format) to use it.

Add the following to the drone configuration

```yml
kind: pipeline
name: default

steps:
  - name: semantic-release
    image: cenk1cenk2/drone-semantic-release
    settings:
      # arguments: -- # semantic release
      semantic_release: true # enable or disable semantic release
      add_apk: # install apk packages for exec step of semantic release
      add_modules: # install node packages if desired
      mode: release # "release" means the actual release and "predict" means to generate the version in dry run to use it e.g. before build
      git_method: gh # set for git authentication with gh (Github), gl (GitLab), bb (BitBucket), cr (Credentials)
      use_local_rc: false # use defaults or a custom rc file true | false
      # arguments: -- # arguments for passing to the semantic-release
      git_user_name: bot # semantic release committer name (git config user.name)
      git_user_email: bot@example.com # semantic release committer email (git config user.email)
      github_token: # semantic release token (for authentication)
        from_secret: github_token
      npm_token: # semantic release token (for authentication)
        from_secret: npm_token
      # arguments: -- # arguments for updating readme on dockerhub, readme_location is set from up
      update_readme_toc: true # update the readme utilizing https://www.npmjs.com/package/markdown-toc
      readme_location: README.md # readme path
      # arguments: -- # arguments for updating readme on dockerhub, readme_location is set from up
      # if you want to push readme to docker hub in this step
      update_docker_readme: false
      docker_username:
        from_secret: docker_username
      docker_password:
        from_secret: docker_password
      docker_repo: cenk1cenk2/some-repository
```

or for BitBucket

```yml
bitbucket_token: # semantic release token (for authentication)
  from_secret: token
```

or for GitLab

```yml
gitlab_token: # semantic release token (for authentication)
  from_secret: token
```

or for any git server (including BitBucket cloud which does not support tokens):

```yml
git_login: bot
git_password:
  from_secret: password
```

## Custom Release File

You can overwrite the default configuration defined in `release.config.js` by adding `release.config.js` or `.releaserc` to your repository. But this can be overwritten by setting `use_local_rc` variable to `true`.

## What it does

Runs on master branch only. Skips any actions below while on other branches.

- automatically creates a semantic version number
- attaches the version number as repo's git tag
- automatically creates, populates and pushes CHANGELOG.md to your master branch
