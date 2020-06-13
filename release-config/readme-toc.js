module.exports = {
  "plugins": [
    "@semantic-release/git"
  ],
  "verifyConditions": [
    "@semantic-release/git"
  ],
  "prepare": [
    {
      "path": "@semantic-release/git",
      "assets": [
        process.env.README_LOCATION ? process.env.README_LOCATION : 'README.md' ,
      ],
      "message": "chore(release): update readme toc [skip ci]"
    }
  ]
}