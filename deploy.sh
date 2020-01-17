#!/bin/bash
set -e
set -x

cd $(dirname $0)
bundle update
# rake
trap 'git reset HEAD~1 && rm bonus.key && git checkout -- .gitignore' EXIT
cp /code/home/assets/lazylead/bonus.key .
sed -i -s 's|Gemfile.lock||g' .gitignore
git add bonus.key
git add Gemfile.lock
git add .gitignore
git commit -m 'configs for heroku'
git push heroku master -f

