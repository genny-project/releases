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

  echo '#                         (0%)\r'
  git_project genny-main
  echo '#                         (2%)\r'
  git_project keisha
  echo '#                         (4%)\r'
  git_project bridge
  echo '#                         (6%)\r'
  git_project messages
  echo '##                        (8%)\r'
  git_project payments
  echo '##                        (10%)\r'
  git_project rulesservice
  echo '##                        (12%)\r'
  git_project social
  echo '##                        (14%)\r'
  git_project gennyql
  echo '##                        (16%)\r'
  git_project genny-verticle
  echo '##                        (18%)\r'
  git_project keycloak
  echo '###                       (20%)\r'
  git_project keycloak-themes
  echo '###                       (22%)\r'
  git_project kie-client
  echo '###                       (24%)\r'
  git_project qwanda
  echo '###                       (26%)\r'
  git_project qwanda-utils
  echo '###                       (28%)\r'
  git_project genny-verticle-rules
  echo '#####                     (30%)\r'
  git_project genny-rules
  echo '#####                     (32%)\r'
  git_project qwanda-services
  echo '#####                     (34%)\r'
  git_project wildfly-qwanda-service
  echo '#####                     (36%)\r'
  git_project wildfly-rulesservice
  echo '######                    (38%)\r'
  git_project alyson-v2
  echo '#######                   (40%)\r'
  git_project alyson-v3
  echo '########                  (42%)\r'
  git_project qwanda-ql
  echo '#########                 (44%)\r'
  git_project uppy
  echo '##########                (46%)\r'
  git_project in-app-calling
  echo '###########               (48%)\r'
  git_project prj_genny
  echo '############              (49%)\r'
  git_project layouts
  echo '############              (50%)\r'
}

# function help to build a project
function build_project {
  # first argument is the project to build
  project=$1

  # second argument is a boolean defining whether or not we need to build the docker image too
  build_docker=$2

  # we change the directory to the project we want to build and build it
  cd ./${project}
  ./build.sh

  # if the boolean is true, we build the docker image
  if [ "$build_docker" = true ] ; then
    ./build-docker.sh
  fi

  cd ../
}

# function help to build all the required projects
function build_genny {

  build_project qwanda false
  echo '##############            (55%)\r'

  build_project qwanda-utils false
  echo '################          (60%)\r'

  build_project qwanda-services false
  echo '##################        (65%)\r'

  build_project genny-verticle-rules false
  echo '###################       (70%)\r'

  build_project wildfly-qwanda-service true
  echo '####################      (75%)\r'

  build_project genny-rules false
  echo '#####################     (80%)\r'

  echo "This next step could take a while. Please wait." # bridge takes a long time to build

  build_project bridge true
  echo '######################    (85%)\r'

  build_project messages true
  echo '#######################   (90%)\r'

  build_project rulesservice true
  echo '##########################(100%)\r'
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
