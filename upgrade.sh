#!/bin/bash

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
    $(cd ./${project} > /dev/null 2>&1 && git add . > /dev/null 2>&1)
    $(cd ./${project} > /dev/null 2>&1 && git stash > /dev/null 2>&1 ) # we stash all the current changes (maven does funny things)
    $(cd ./${project} > /dev/null 2>&1 && git pull  > /dev/null 2>&1) # we update the repo
  else
    # otherwise we clone it
    git clone https://github.com/genny-project/${project}  > /dev/null 2>&1
  fi

  # we checkout the right tag matching the genny version
  $(cd ./${project} > /dev/null 2>&1 && git checkout tags/${genny_version} -b ${genny_version}  > /dev/null 2>&1 ) # we update the repo
}

# function help to git pull all the required projects
function git_projects {

  echo -ne '#                         (0%)\r'
  git_project genny-main
  echo -ne '#                         (2%)\r'
  git_project keisha
  echo -ne '#                         (4%)\r'
  git_project bridge
  echo -ne '#                         (6%)\r'
  git_project messages
  echo -ne '##                        (8%)\r'
  git_project payments
  echo -ne '##                        (10%)\r'
  git_project rulesservice
  echo -ne '##                        (12%)\r'
  git_project social
  echo -ne '##                        (14%)\r'
  git_project gennyql
  echo -ne '##                        (16%)\r'
  git_project genny-verticle
  echo -ne '##                        (18%)\r'
  git_project keycloak
  echo -ne '###                       (20%)\r'
  git_project keycloak-themes
  echo -ne '###                       (22%)\r'
  git_project kie-client
  echo -ne '###                       (24%)\r'
  git_project qwanda
  echo -ne '###                       (26%)\r'
  git_project qwanda-utils
  echo -ne '###                       (28%)\r'
  git_project genny-verticle-rules
  echo -ne '#####                     (30%)\r'
  git_project genny-rules
  echo -ne '#####                     (32%)\r'
  git_project qwanda-services
  echo -ne '#####                     (34%)\r'
  git_project wildfly-qwanda-service
  echo -ne '#####                     (36%)\r'
  git_project wildfly-rulesservice
  echo -ne '######                    (38%)\r'
  git_project alyson-v2
  echo -ne '#######                   (40%)\r'
  git_project alyson-v3
  echo -ne '########                  (42%)\r'
  git_project qwanda-ql
  echo -ne '#########                 (44%)\r'
  git_project uppy
  echo -ne '##########                (46%)\r'
  git_project in-app-calling
  echo -ne '###########               (48%)\r'
  git_project prj_genny
  echo -ne '############              (49%)\r'
  git_project layouts
  echo -ne '############              (50%)\r'
}

# function help to build a project
function build_project {

  # first argument is the project to build
  project=$1

  # second argument is a boolean defining whether or not we need to build the docker image too
  build_docker=$2

  # we change the directory to the project we want to build and build it
  $(cd ./${project} > /dev/null 2>&1 && ./build.sh > /dev/null 2>&1 )

  # if the boolean is true, we build the docker image
  if [ "$build_docker" = true ] ; then
    $(cd ./${project} > /dev/null 2>&1 && ./build-docker.sh  > /dev/null 2>&1 )
  fi
}

# function help to build all the required projects
function build_genny {

  build_project qwanda false
  echo -ne '##############            (55%)\r'

  build_project qwanda-utils false
  echo -ne '################          (60%)\r'

  build_project qwanda-services false
  echo -ne '##################        (65%)\r'

  build_project genny-verticle-rules false
  echo -ne '###################       (70%)\r'

  build_project wildfly-qwanda-service true
  echo -ne '####################      (75%)\r'

  build_project genny-rules false
  echo -ne '#####################     (80%)\r'

  echo "This next step could take a while. Please wait." # bridge takes a long time to build

  build_project bridge true
  echo -ne '######################    (85%)\r'

  build_project messages true
  echo -ne '#######################   (90%)\r'

  build_project rulesservice true
  echo -ne '##########################(100%)\r'
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
