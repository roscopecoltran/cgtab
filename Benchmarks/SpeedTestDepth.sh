#!/bin/bash
LOGFILE=$(readlink -f "$1")
NRUNS=10
SIZE=10MiB
NFILES=20


TEST_SOURCE_REPO_URL=file:///tmp/bin_repo
TEST_SOURCE_REPO_PATH=/tmp/bin_repo

TEST_DST_REPO_PATH=/tmp/dst_repo_full
TEST_DST_DEPTH_REPO_PATH=/tmp/dst_repo_depth
TEST_DST_PULL_REPO_PATH=/tmp/dst_repo_pull
TEST_DST_PUSH_REPO_PATH=/tmp/dst_repo_push
TEST_DST_PUSH_REPO_URL=file:///tmp/dst_repo_push
TEST_RSYNC_FULL_COPY_PATH=/tmp/dst_repo_rsyncfull
TEST_RSYNC_UPDATE_PATH=/tmp/dst_repo_rsyncupdate

for D in ${TEST_SOURCE_REPO_PATH} ${TEST_DST_REPO_PATH} ${TEST_DST_DEPTH_REPO_PATH} ${TEST_DST_PULL_REPO_PATH} ${TEST_DST_PUSH_REPO_PATH} ${TEST_RSYNC_FULL_COPY_PATH} ${TEST_RSYNC_UPDATE_PATH}
do
    test -d "${D}" && rm -rf "${D}"
done

mkdir -p "${TEST_SOURCE_REPO_PATH}" && cd "${TEST_SOURCE_REPO_PATH}" 
git init
git config user.email "you@example.com"
git config user.name "Your Name"
cat > .gitattributes <<EOF
*  binary -delta
EOF
git add .gitattributes
git commit -m "turn of deltha compression"
git config core.compression 0
git config core.loosecompression 0

git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_PULL_REPO_PATH}"
git init --bare "${TEST_DST_PUSH_REPO_PATH}"

rsync -r --exclude=".git/*" -–update –delete "${TEST_SOURCE_REPO_PATH}/"* "${TEST_RSYNC_UPDATE_PATH}/"


DROPCACHECMD=sync && echo 3 > /proc/sys/vm/drop_caches
TIMECMD=/usr/bin/time
TIMEOPT="-f %U; --append -o ${LOGFILE}"
echo "Run;File Size; File Count;Repo Size Before;Add Time;Commit Time;Repo Size After;" \
    "Push Time; Full Clone Time;Depth 1 Clone Time;Unshallow Depth 1 Clone Time;"\
    "Normal Pull Time;rsync update; rsync full"> ${LOGFILE}

for((i=0; i < $NRUNS; ++i))
do
    for((k=0; k < $NFILES; ++k))
    do
        dd if=/dev/urandom of=random_file_$(printf "%04d" $k).bin bs=${SIZE} count=1 > /dev/null 2>&1
    done
    REPO_SIZE_BEFORE=$(du .git -sh | awk '{ print $1 }')
    
    echo -n "${i};${SIZE};${NFILES};${REPO_SIZE_BEFORE};" >> ${LOGFILE}
    ${TIMECMD} ${TIMEOPT} git add random_file*.bin
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}
    
    ${TIMECMD} ${TIMEOPT} git commit -m "commit$i"
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}    

    REPO_SIZE_AFTER=$(du .git -sh | awk '{ print $1 }')
    echo -n "${REPO_SIZE_AFTER};" >> ${LOGFILE}

    for D in ${TEST_DST_REPO_PATH} ${TEST_DST_DEPTH_REPO_PATH} ${TEST_RSYNC_FULL_COPY_PATH}
    do
        test -d "${D}" && rm -rf "${D}"
    done
    
    ${TIMECMD} ${TIMEOPT} git --git-dir="${TEST_SOURCE_REPO_PATH}/.git" --work-tree="${TEST_SOURCE_REPO_PATH}" \
        push --all "${TEST_DST_PUSH_REPO_URL}" 
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}
    ${TIMECMD} ${TIMEOPT} git clone "${TEST_SOURCE_REPO_URL}" "${TEST_DST_REPO_PATH}"
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}
    ${TIMECMD} ${TIMEOPT} git clone --depth 1 "${TEST_SOURCE_REPO_URL}" "${TEST_DST_DEPTH_REPO_PATH}"
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}
    ${TIMECMD} ${TIMEOPT} git --git-dir="${TEST_DST_DEPTH_REPO_PATH}/.git" --work-tree="${TEST_DST_DEPTH_REPO_PATH}" \
        pull --unshallow "${TEST_SOURCE_REPO_URL}" 
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}
    ${TIMECMD} ${TIMEOPT} git --git-dir="${TEST_DST_PULL_REPO_PATH}/.git" --work-tree="${TEST_DST_PULL_REPO_PATH}" \
        pull "${TEST_SOURCE_REPO_URL}"
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}

    ${TIMECMD} ${TIMEOPT} rsync -r --exclude=".git/*" -–update –delete "${TEST_SOURCE_REPO_PATH}/"* "${TEST_RSYNC_UPDATE_PATH}/"
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}

    ${TIMECMD} ${TIMEOPT} rsync -r --exclude=".git/*" -–update –delete "${TEST_SOURCE_REPO_PATH}/"* "${TEST_RSYNC_FULL_COPY_PATH}/"
    truncate -s -1 ${LOGFILE}
    ${DROPCACHECMD}
    truncate -s -1 ${LOGFILE} # removes the last ;
    echo >> ${LOGFILE}
done
