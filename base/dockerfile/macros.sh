#
# Macro for pulling the current version of a repository
#
# Based on:  https://hub.docker.com/_/node/
#

{% macro git_pull(repository, branch, directory) %}

# If we have an existing repository, but not the right one, we need to start from scratch
GIT_REPOSITORY_EXISTING=$(git --git-dir={{ directory }}/.git remote -v | grep -m 1 origin | awk -F'[ \t]' '{print $2}')
echo "Desired Repository: {{ repository }}"
echo "Existing Repository: $GIT_REPOSITORY_EXISTING"
if [[ -d {{ directory }} ]] ; then
  if [[ {{ repository }} != $GIT_REPOSITORY_EXISTING ]] ; then
    rm -rf {{ directory }}/*
    rm -rf {{ directory }}/.[!.]?*
  fi
fi

# Check whether this is our first time running, such that we need to clone
if [[ ! -d {{ directory }}/.git ]] ; then
  git clone {{ repository }} {{ directory }}
fi

# The presence of a lock means somebody else did not finish
# We need to clear the lock so our git commands can execute
# Saw this when the host disk filled, hopefully should not need this
# But it allows us to recover without needing to explicitly detect
# this situation and delete the container
if [[ -f {{ directory }}/.git/index.lock ]] ; then
  rm -f {{ directory }}/.git/index.lock
fi

# Change into the directory
GIT_PULL_PRIOR_DIRECTORY=$(pwd)
cd {{ directory }}

# Ensure we have the branch we want, but nothing else
# http://grimoire.ca/git/stop-using-git-pull-to-deploy
git fetch --all
git checkout --force origin/{{ branch }}

# Restore our directory
cd $GIT_PULL_PRIOR_DIRECTORY

{% endmacro %}
