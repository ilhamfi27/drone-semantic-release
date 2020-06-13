FROM node:14-alpine

ADD . /semantic-release/

RUN yarn global add semantic-release @semantic-release/changelog @semantic-release/exec @semantic-release/git \
  && yarn global add markdown-toc \
  && apk update && apk add --no-cache --no-progress git && apk add --no-cache --no-progress bash \
  && apk add --no-cache --no-progress curl jq \
  && chmod +x /semantic-release/release.sh \
  && chmod +x /semantic-release/scripts/*.sh

CMD ["/semantic-release/release.sh"]