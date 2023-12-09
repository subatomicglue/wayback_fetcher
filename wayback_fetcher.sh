#!/bin/bash

# we use the excellent "wayback machine downloader":
# https://github.com/hartator/wayback-machine-downloader

# Settings:

# URL
URL="http://metahistory.org"

# Dir to download to
OUTDIR="metahistory"

# The date/time to use when pulling from wayback machine
# Navigate to your $URL inside of https://web.archive.org/
# Navigate to the time you want
# Copy the date/time from the URL, e.g.
# https://web.archive.org/web/20160327185523/http://metahistory.org/GRAIL/SpiritualWarrior.php
DATE_TIME=20160327183840

# waybackmachine will ban you if you hit it too hard, be nice, delay
DELAY=4

# we can pull the html from the php, set to 1 to do that, or 0 to skip
PROCESS_PHP=1

if [ ! -d "wayback-machine-downloader" ]; then
  echo "Pulling down the wayback-machine-downloader script"
  mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'clone_wayback')
  function on_exit_clone {
    echo "Removing \"$mytmpdir\""
    rm -rf "$mytmpdir"
  }
  trap on_exit_clone INT EXIT

  git clone https://github.com/hartator/wayback-machine-downloader.git "$mytmpdir/wayback-machine-downloader"

  #  pull the PR to get --delay option:
  #  https://github.com/hartator/wayback-machine-downloader/pull/268
  cd "$mytmpdir/wayback-machine-downloader"
    gh pr checkout 268
  cd -

  rm -rf ./wayback-machine-downloader
  rm -rf "$mytmpdir/wayback-machine-downloader/.git"
  cp -r "$mytmpdir/wayback-machine-downloader" .
fi

if [ ! -d "$OUTDIR" ]; then
  echo "Download \"$URL\" to \"$OUTDIR\" from the year/time \"$DATE_TIME\""
  ./wayback-machine-downloader/bin/wayback_machine_downloader --delay $DELAY -t $DATE_TIME --directory "$OUTDIR" "$URL"
fi

if [ "$PROCESS_PHP" == "1" ]; then
  echo "serving php from metahistory/"
  cd "$OUTDIR"
    nohup php -S localhost:8000 &
    pid=$!
    echo "waiting a second for php server to start (if errors, may need to increase)"
    sleep 1
  cd -

  echo "trapping CTRL-C and exit, so we can cleanup php later..."
  function on_exit_php {
    echo "Killing $pid"
    kill -9 $pid
  }
  trap on_exit_php INT EXIT

  echo "pulling an HTML-only copy to \"${OUTDIR}_html\""
  wget -rc --convert-links --no-host-directories --adjust-extension --directory-prefix="./${OUTDIR}_html" http://localhost:8000/
fi

