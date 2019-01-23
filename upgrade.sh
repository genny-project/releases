#!/bin/bash

alias	mvn='mvn --quiet'

# first parameter is the version of genny to checkout.
# we check the user has passed at least 1 argument

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters";
    exit;
fi

# we define the version of genny we want to use
genny_version=$1

# function help to git pull a project and void the ouput to null.
function git_project {

  # project name is the first argument passed to this function
  project=$1

  echo "Cloning $project";

  # if the project has already been cloned, we update it
  if [ -d $project ]; then
    cd ./${project}
    git add .
    git stash # we stash all the current changes (maven does funny things)
    git pull # we update the repo
    cd ../
  else
    # otherwise we clone it
    git clone https://github.com/genny-project/${project}
  fi

  # we checkout the right tag matching the genny version
  cd ./${project}
  git checkout tags/${genny_version} -b ${genny_version} # we update the repo
  cd ../
}

# function help to git pull all the required projects
function git_projects {

  git_project genny-main
  git_project keisha
  git_project bridge
  git_project messages
  git_project payments
  git_project rulesservice
  git_project social
  git_project gennyql
  git_project genny-verticle
  git_project keycloak
  git_project keycloak-themes
  git_project kie-client
  git_project qwanda
  git_project qwanda-utils
  git_project genny-verticle-rules
  git_project genny-rules
  git_project qwanda-services
  git_project wildfly-qwanda-service
  git_project wildfly-rulesservice
  git_project alyson-v2
  git_project alyson-v3
  git_project qwanda-ql
  git_project uppy
  git_project in-app-calling
  git_project prj_genny
  git_project layouts
}

# function help to build a project
function build_project {
  # first argument is the project to build
  project=$1

  echo "Building $project"

  # second argument is a boolean defining whether or not we need to build the docker image too
  build_docker=$2

  # we change the directory to the project we want to build and build it
  cd ./${project}
  ./build.sh >/dev/null

  # if the boolean is true, we build the docker image
  if [ "$build_docker" = true ] ; then
    ./build-docker.sh
  fi

  cd ../
}

# function help to build all the required projects
function build_genny {
  echo "Building Genny"
  build_project qwanda false
  build_project qwanda-utils false
  build_project qwanda-services false
  build_project genny-verticle-rules false
  build_project wildfly-qwanda-service true
  build_project genny-rules false
  build_project bridge true
  build_project messages true
  build_project rulesservice true
}

echo "Upgrading Genny to version ${genny_version}. Please wait, this could take up to 30 minutes..."

# git update all the projects
git_projects

# build the new version of genny
build_genny

# TODO: define the success event
echo "Success."

#exit
exit;
