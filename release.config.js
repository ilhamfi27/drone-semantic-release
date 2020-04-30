module.exports = {
  "branches": [
    "master",
    {
      "name": "alpha",
      "prerelease": true
    },
    {
      "name": "beta",
      "prerelease": true
    },
    {
      "name": "rc",
      "prerelease": true
    }
  ],
  "verifyConditions": [
    "@semantic-release/changelog",
    "@semantic-release/git"
  ],
  "prepare": [
    "@semantic-release/changelog",
    {
      "path": "@semantic-release/exec",
      "cmd": "[ $UPDATE_README = 'true' ] && markdown-toc /drone/src/${README_LOCATION:-README.md} -i --no-firsth1"
    },
    {
      "path": "@semantic-release/git",
      "assets": [
        "CHANGELOG.md",
        `${process.env.README_LOCATION} ? ${process.env.README_LOCATION} : README.md`,
        "yarn.lock",
        "npm-shrinkwrap.json"
      ],
      "message": "chore(release): <%= nextRelease.version %> - <%= new Date().toISOString().slice(0,10).replace(/-/g,'') %> [skip ci]\n\n<%= nextRelease.notes %>"
    }
  ]
}