#!/bin/bash

TEST_SOURCE_REPO_URL=file:///tmp/bin_repo
TEST_SOURCE_REPO_PATH=/tmp/bin_repo

TEST_DST_REPO_PATH=/tmp/dst_repo_full
TEST_DST_DEPTH_REPO_PATH=/tmp/dst_repo_depth
TEST_DST_PULL_REPO_PATH=/tmp/dst_repo_pull

for D in ${TEST_SOURCE_REPO_PATH} ${TEST_DST_REPO_PATH} ${TEST_DST_DEPTH_REPO_PATH} ${TEST_DST_PULL_REPO_PATH}
do
    test -d "${D}" && rm -rf "${D}"
done

mkdir -p "${TEST_SOURCE_REPO_PATH}" && cd "${TEST_SOURCE_REPO_PATH}" 
git init
git config user.email "you@example.com"
git config user.name "Your Name"

git clone "${TEST_SOURCE_REPO_URL}" ${TEST_DST_PULL_REPO_PATH}


SIZE=100MiB
for((i=0; i < 3; ++i))
do
    echo -e "\n######Run No. $i"
    echo -e "\n######\n# making random file size:${SIZE}\n"
    dd if=/dev/urandom of=random_file.bin bs=${SIZE} count=1
    echo -e "\n######\n"
    
    REPO_SIZE=$(du .git -sh | awk '{ print $1 }')
    
    echo -e "\n######\n# commiting file to a ${REPO_SIZE} repo \n"
    time (git add random_file.bin && git commit -m "commit$i" )
    echo -e "\n######\n"

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
    
    echo -e "\n######\n# pull, only last revision\n"
    time git --git-dir=${TEST_DST_PULL_REPO_PATH}/.git --work-tree=${TEST_DST_PULL_REPO_PATH} pull "${TEST_SOURCE_REPO_URL}"
    echo -e "\n######\n"
done
