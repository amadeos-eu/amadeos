#!/bin/sh
# Autostart DazeOS CDE Front Panel Dock
DAZEOS_JAR="${DAZEOS_JAR:-/opt/dazeos/dazeos-demo.jar}"
JAVA_OPTS="${JAVA_OPTS:---enable-native-access=ALL-UNNAMED}"
JAVA_BIN="${JAVA_HOME:+$JAVA_HOME/bin/java}"
JAVA_BIN="${JAVA_BIN:-$(command -v java 2>/dev/null || true)}"

if [ -n "$JAVA_BIN" ] && [ -f "$DAZEOS_JAR" ]; then
    "$JAVA_BIN" $JAVA_OPTS -jar "$DAZEOS_JAR" panel &
fi

