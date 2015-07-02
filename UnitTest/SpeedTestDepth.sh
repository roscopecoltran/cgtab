#!/bin/bash

set -x
LOGFILE=$1

TEST_SOURCE_REPO_URL=file:///tmp/bin_repo
TEST_SOURCE_REPO_PATH=/tmp/bin_repo

TEST_DST_REPO_PATH=/tmp/dst_repo_full
TEST_DST_DEPTH_REPO_PATH=/tmp/dst_repo_depth
TEST_DST_PULL_REPO_PATH=/tmp/dst_repo_pull
TEST_DST_PULL_DEPTH_REPO_PATH=/tmp/dst_repo_pull_depth

for D in ${TEST_SOURCE_REPO_PATH} ${TEST_DST_REPO_PATH} ${TEST_DST_DEPTH_REPO_PATH} ${TEST_DST_PULL_REPO_PATH} ${TEST_DST_PULL_DEPTH_REPO_PATH}
do
    test -d "${D}" && rm -rf "${D}"
done

mkdir -p "${TEST_SOURCE_REPO_PATH}" && cd "${TEST_SOURCE_REPO_PATH}" 
git init
git config user.email "you@example.com"
git config user.name "Your Name"

git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_PULL_REPO_PATH}"
git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_PULL_DEPTH_REPO_PATH}"

#/usr/bin/time -f "%U" --append -o test.log ls ; truncate -s -1 test.log

TIMECMD=/usr/bin/time
TIMEOPT="-f \"%U\" --append -o ${LOGFILE}"
echo "Run;File Size;Repo Size Before;Add Time;Commit Time;Repo Size After" > ${LOGFILE}
SIZE=1000MiB
for((i=0; i < 3; ++i))
do
    dd if=/dev/urandom of=random_file.bin bs=${SIZE} count=1    
    REPO_SIZE_BEFORE=$(du .git -sh | awk '{ print $1 }')
    
    echo -n "${i};${SIZE};${REPO_SIZE_BEFORE}" >> ${LOGFILE}
    ${TIMECMD} ${TIMEOPT} git add random_file.bin
    truncate -s -1 ${LOGFILE}
    
    ${TIMECMD} ${TIMEOPT} git commit -m "commit$i"
    truncate -s -1 ${LOGFILE}
    
    REPO_SIZE_AFTER=$(du .git -sh | awk '{ print $1 }')
    echo -n "${REPO_SIZE_AFTER}" >> ${LOGFILE}

    for D in ${TEST_DST_REPO_PATH} ${TEST_DST_DEPTH_REPO_PATH}
    do
        test -d "${D}" && rm -rf "${D}"
    done
    
    echo -e "\n######\n# normal clone full repo\n"
    time git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_REPO_PATH}"
    echo -e "\n######\n"

    echo -e "\n######\n# depth 1 clone, only last revision\n"
    time git clone --depth 1 "${TEST_SOURCE_REPO_URL}" "${TEST_DST_DEPTH_REPO_PATH}"
    echo -e "\n######\n"

    echo -e "\n######\n# depth 1 clone, make unshallow\n"
    time git --git-dir="${TEST_DST_DEPTH_REPO_PATH}/.git" --work-tree="${TEST_DST_DEPTH_REPO_PATH}" pull --unshallow "${TEST_SOURCE_REPO_URL}" 
    echo -e "\n######\n"

    
    echo -e "\n######\n# normal pull\n"
    time git --git-dir="${TEST_DST_PULL_REPO_PATH}/.git" --work-tree="${TEST_DST_PULL_REPO_PATH}" pull "${TEST_SOURCE_REPO_URL}"
    echo -e "\n######\n"

    echo -e "\n######\n# pull, only last revision\n"
    git --git-dir="${TEST_DST_PULL_DEPTH_REPO_PATH}/.git" --work-tree="${TEST_DST_PULL_DEPTH_REPO_PATH}" config user.email "you@example.com"
    git --git-dir="${TEST_DST_PULL_DEPTH_REPO_PATH}/.git" --work-tree="${TEST_DST_PULL_DEPTH_REPO_PATH}" config user.name "Your Name"
    time git --git-dir="${TEST_DST_PULL_DEPTH_REPO_PATH}/.git" --work-tree="${TEST_DST_PULL_DEPTH_REPO_PATH}" pull --depth 1 "${TEST_SOURCE_REPO_URL}"
    echo -e "\n######\n"
done
