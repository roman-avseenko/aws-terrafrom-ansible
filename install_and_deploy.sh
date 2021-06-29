#!/bin/bash

if ! pipenv --version; then
  echo "pipenv is not installed"
  exit 1
else
  pipenv install
  pipenv run install
  pipenv run init
  pipenv run deploy
  pipenv run provision
fi
