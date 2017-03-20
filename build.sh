#!/bin/sh
PROJECT_SHORTNAME=StealthElf
TARGET=src
GIT=`git log --pretty=format:'%h' -n 1 $TARGET`
GIT_COUNT=`git log --pretty=format:'' $TARGET | wc -l`
OUTPUT=${PROJECT_SHORTNAME}-v${GIT_COUNT}.p8
RAW=/tmp/p8c16.tmp

cat $TARGET/header.lua > ${OUTPUT}
#Add git_count
sed -i -e "s/%%git_count%%/${GIT_COUNT}/g" ${OUTPUT}
#add git info
echo "git,git_count = \"$GIT\",\"$GIT_COUNT\"" >> ${OUTPUT}

rm -f ${RAW}
#add and process code
for file in $TARGET/lua/* ; do
  cat $file >> ${RAW}
  printf "\n" >> ${RAW}
done

#Remove leading and trailing whitespace
sed -i 's/^[ \t]*//;s/[ \t]*$//' ${RAW}
#Remove all comments
#sed -i 's:--.*$::g' ${RAW}
#Delete empty lines
#sed -i '/^$/d' ${RAW}

cat ${RAW} >> ${OUTPUT}

echo "__gfx__" >> ${OUTPUT}
cat $TARGET/gfx >> ${OUTPUT}

echo "__gff__" >> ${OUTPUT}
cat $TARGET/gff >> ${OUTPUT}

echo "__map__" >> ${OUTPUT}
cat $TARGET/map >> ${OUTPUT}

echo "__sfx__" >> ${OUTPUT}
cat $TARGET/sfx >> ${OUTPUT}

echo "__music__" >> ${OUTPUT}
cat $TARGET/music >> ${OUTPUT}
