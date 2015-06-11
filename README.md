## helpfullscipts

## git-new-feature.sh ##
  This script is used to wrap the commands needed to create a new feature branch like it is suggested in  http://nvie.com/posts/a-successful-git-branching-model/ it tries to get the head of the develop branch or a specified branch independed from the actual used branch and activates the new one after it. if requested the new branch will be pushed to origin imidiatly.

## merge-helper.sh ##
 This script encapsulates some git calls and avoids typing the current branch name. 
 
 The current branch will be merged (rebased) into the given one, after it's pulled.
