# wayback_fetcher

This is a simple script to help you download a site from the wayback machine (https://web.archive.org/), from a certain date/time, with delay, and convert it from php if desired

# Usage
```
# edit the script variables at the top, then run:
./wayback_fetcher.sh
```

# Refresh the copy of wayback-machine-downloader
Just delete the "wayback-machine-downloader" dir, rerun the script, and it will clone it...
- we checkout the PR that applies the --delay feature, in the future once PR is merged, we can remove that...  which you may need to do...)

# Convert PHP to HTML
Set PROCESS_PHP=1 to start a php server then wget to covert to .html
On mac, use `brew install php` to install php, which has a serve function

