# L45 – Login Activity Report

**Student:** SABAA MEMON | **Roll:** F19 | **Division:** G | **Enrollment:** 24004501210193

## Problem
Analyse a sample login log and report failed logins and peak hours.

## Who will use it
A lab admin checking suspicious login attempts (sample data).

## Folder structure
- main.sh – menu (run with ./main.sh)
- lib/functions.sh – all functions
- data/ – data files
- reports/ – reports created by the script
- backups/ – tar.gz backups
- logs/ – activity.log and cron.log

## Features
1. Failed attempts per user
2. Users with more than 3 failures (alert)
3. Peak login hours
4. Successful logins per day
5. Security report file

## How to run
    cd ~/linux_project/loginwatch
    ./main.sh
    ./main.sh --help

## Crontab task
Every day at 6 AM, append users with more than 3 failed logins to security_alerts.txt

    0 6 * * * /bin/bash $HOME/linux_project/loginwatch/main.sh --cron >> $HOME/linux_project/loginwatch/logs/cron.log 2>&1

## Commands used
awk, grep, sort, uniq -c, cut

## What I learned
(write 3-5 lines here)
