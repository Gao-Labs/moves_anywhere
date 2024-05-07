#!/bin/sh

export PATH=jre/bin:ant/bin:$PATH
export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8
export ANT_OPTS=-XX:-UseGCOverheadLimit
#For running on Git Bash with windows, ensure that JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 is uncommented and JAVA_HOME=/usr is commented
#export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export JAVA_HOME=/usr
export JRE_HOME=jre
