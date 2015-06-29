#!/bin/bash

TEST_SOURCE_REPO_URL=file:///tmp/bin_repo
TEST_SOURCE_REPO_PATH=/tmp/bin_repo

TEST_DST_REPO_PATH=/tmp/dst_repo
TEST_DSTDEPTH_REPO_PATH=/tmp/dst_repo_depth

for D in ${TEST_SOURCE_REPO_PATH} ${TEST_DST_REPO_PATH} ${TEST_DSTDEPTH_REPO_PATH}
do
    test -d "${D}" && rm -rf "${D}"
done

mkdir -p "${TEST_SOURCE_REPO_PATH}" && cd "${TEST_SOURCE_REPO_PATH}" 
git init
git config user.email "you@example.com"
git config user.name "Your Name"

dd if=/dev/urandom of=random_file.bin bs=1G count=1
time git add random_file.bin
time git commit -m 'commit0'

echo "Normal Clone, Working dir 1 GiB, repo 1 GiB"
time git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_REPO_PATH}"

echo "Depth 1 Clone, Working dir 1 GiB, repo 1 GiB"
time git clone --depth 1 "${TEST_SOURCE_REPO_URL}" "${TEST_DSTDEPTH_REPO_PATH}"

dd if=/dev/urandom of=random_file.bin bs=1G count=1
time git add random_file.bin
time git commit -m 'commit1'

echo "Normal Clone, Working dir 1 GiB, repo 2 GiB"
rm -rf "${TEST_DST_REPO_PATH}"
time git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_REPO_PATH}"

rm -rf "${TEST_DSTDEPTH_REPO_PATH}"
echo "Depth 1 Clone, Working dir 1 GiB, repo 2 GiB"
time git clone --depth 1 "${TEST_SOURCE_REPO_URL}" "${TEST_DSTDEPTH_REPO_PATH}"

dd if=/dev/urandom of=random_file.bin bs=1G count=1
time git add random_file.bin
time git commit -m 'commit2'

echo "Normal Clone, Working dir 1 GiB, repo 3 GiB"
rm -rf "${TEST_DST_REPO_PATH}"
time git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_REPO_PATH}"

rm -rf "${TEST_DSTDEPTH_REPO_PATH}"
echo "Depth 1 Clone, Working dir 1 GiB, repo 3 GiB"
time git clone --depth 1 "${TEST_SOURCE_REPO_URL}" "${TEST_DSTDEPTH_REPO_PATH}"