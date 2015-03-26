#!/bin/bash
set -E

# Get path to git and check if it's available
GIT=$(which git)
if [ -z $GIT ]; then
  echo "cannot find git"
  exit 2
fi

# get new branch name
if [ $# -eq 0 ] || [ $# -gt 3 ]; then
  echo "Usage $0 new_branch_name [base_branch] [--push]"
  echo "If base_branch is not given origin/develop is used"
  exit 3
fi
NEW_BRANCH=$1
shift

# read aditional arguments
while [ $# -gt 0 ]; do
  case $1 in
    ("--push")
       PUSH=1
       ;;
   (*)
      BASE_BRANCH=$1
      ;;
  esac
  shift
done

# set BASE_BRANCH to default if not set before.
if [ -z $BASE_BRANCH ]; then
  BASE_BRANCH='origin/develop'
fi

# get head from base branch
HEAD=$($GIT show-ref  --head  --hash $BASE_BRANCH | tail -n 1)
if [ -z $HEAD ];  then
  echo "Cannot find head for $(BASE_BRANCH)"
  exit 1
fi

# create local branch
$GIT branch $NEW_BRANCH $HEAD
# change is new branch
$GIT checkout $NEW_BRANCH

if [ -n "$PUSH" ] && [ "$PUSH" -eq "1" ]; then
  $GIT push  origin $NEW_BRANCH
fi
