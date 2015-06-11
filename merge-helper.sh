#!/bin/bash
set -e

GIT=$(which git)
if [ -z $GIT ]; then
  echo "cannot find git"
  exit 127
fi


if [ $# -ge 3 ]; then
  echo "Usage $0 [--rebase] [targetname]"
  ecgi  "use --rebase for a rebase instead of a merge"
  echo "if no targetname is given 'develop' is used."
  exit 1
fi


# read aditional arguments
while [ $# -gt 0 ]; do
  case $1 in
    ("--rebase")
       REBASE=1
       ;;
   (*)
      TARGET=$1
      ;;
  esac
  shift
done

if [ -z $TARGET ]; then
  TARGET=develop
fi

# get current branch incl. heads
CURRENT_BRANCH=$(git symbolic-ref -q HEAD)
# remove heads
CURRENT_BRANCH=${CURRENT_BRANCH##refs/heads/}

if [ -z $CURRENT_BRANCH ]; then
  echo "unable to fetch current branch"
  exit 1
fi

git checkout $TARGET

if [ -n "$REBASE" ] && [ "$REBASE" -eq "1" ]; then
  $GIT pull -r 
  $GIT rebase $CURRENT_BRANCH
else
  $GIT pull
