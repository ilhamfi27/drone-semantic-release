FROM node:12-alpine

ADD release.sh create-credentials.js release.config.js /semantic-release/

RUN yarn global add semantic-release @semantic-release/changelog @semantic-release/exec @semantic-release/git \
  && yarn global add markdown-toc \
  && apk update && apk add git && apk add bash \
  && chmod +x /semantic-release/release.sh

CMD ["/semantic-release/release.sh"]