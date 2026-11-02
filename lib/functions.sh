#!/bin/bash
# lib/functions.sh – all functions for Login Activity Report
DATA="data/login.log"

LOG="logs/activity.log"

# write one line to the activity log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG"
}

# check the data file / folder exists before using it
check_data() {
    if [ ! -e "$DATA" ]; then
        echo "Data not found: $DATA"
        return 1
    fi
}

show_help() {
    echo "Usage: ./main.sh            -> open the menu"
    echo "       ./main.sh --help     -> show this help"
    echo "       ./main.sh --backup   -> backup data/ now"
    echo "       ./main.sh --cron     -> run the scheduled (crontab) task"
}

view_data() {
    check_data || return
    if [ -d "$DATA" ]; then ls -l "$DATA"; else cat -n "$DATA" | more; fi
}

do_backup() {
    f="backups/data_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$f" data/
    echo "Backup saved: $f ($(du -h "$f" | cut -f1))"
    log "backup created $f"
}

view_log() {
    if [ -f "$LOG" ]; then tail -n 15 "$LOG"; else echo "No activity yet."; fi
}

# ------------------------------------------------------------
# FEATURE 1: Failed attempts per user
# Commands you can use: awk, grep, sort, uniq -c, cut
# ------------------------------------------------------------
feature_1() {
    echo "== Failed attempts per user =="
    if ! check_data; then return 1; fi
    printf "%-15s %s\n" "User" "Failed Attempts"
    awk 'NF == 4 && $4 == "failed" {
	 count[$3]++
    }
    	 END {
  	       for (user in count)
		     print user,count[user]
 	 }' "$DATA" | sort -k2,2nr
    log "feature_1 used"
}

# ------------------------------------------------------------
# FEATURE 2: Users with more than 3 failures (alert)
# Commands you can use: awk, grep, sort, uniq -c, cut
# ------------------------------------------------------------
feature_2() {
    echo "== Users with more than 3 failures (alert) =="
    if ! check_data; then return 1; fi
    awk 'NF == 4 && $4 == "failed"  {
	 count[$3]++
    }
    END {
	 for (user in count) {
	      if (count[user] > 3) {
		  printf "%-15s %d\n",user,count[user]
	       }
	  }
    }' "$DATA" | sort -k2,2nr > /tmp/loginwatch_alerts.txt
     
     if [ -s /tmp/loginwatch_alerts.txt ]; then
	   echo "Security Alert: Users with more than 3 failed attempts"
           printf "%-15s %s\n" "username" "failed  attempts"
           cat /tmp/loginwatch_alerts.txt
     else
            echo "no user have more than 3 failed attempts"
     fi
      rm -f /tmp/loginwatch_alerts.txt
      log "feature_2 used"
}

# ------------------------------------------------------------
# FEATURE 3: Peak login hours
# Commands you can use: awk, grep, sort, uniq -c, cut
# ------------------------------------------------------------
feature_3() {
    echo "== Peak login hours =="
    if ! check_data; then
 	  return 1
    fi
    awk 'NF == 4 {
	 split($2, time, ":")
         print time[1] ":00"
    }' "$DATA" | sort | uniq -c | sort -k1,1nr
    log "feature_3 used"
}

# ------------------------------------------------------------
# FEATURE 4: Successful logins per day
# Commands you can use: awk, grep, sort, uniq -c, cut

# ------------------------------------------------------------
feature_4() {
    echo "== Sucessful logins per day =="
    if ! check_data; then
          return 1
    fi
    printf "%-15s %s\n" "Date" "Sucessfull Login"
    awk 'NF == 4 && $4 == "success" {
         count[$1]++
    }
    END {
          for (day in count) {
                print day, count[day]
          }
    }' "$DATA" | sort
    log "feature_4 used"
}

# ------------------------------------------------------------
# FEATURE 5: Security report file
# Commands you can use: awk, grep, sort, uniq -c, cut
# ------------------------------------------------------------
feature_5() {
    echo "== Security report file =="
    if ! check_data; then
         return 1
    fi
    mkdir -p reports
    REPORT="reports/security_report.txt"
    {
      echo "LOGIN ACTIVITY SECURITY REPORT"
      echo "Generated on: $(date)"
      echo "======================="
      echo "Failed attempts per user:"
      awk 'NF == 4 && $4 == "failed" {
          count[$3]++
      }
      END {
           for (user in count)
                print user, count[user]
     }' "$DATA" | sort -k2,2nr
   } > "$REPORT"
   echo "Report saved to: $REPORT"
   cat "$REPORT"
 
    log "feature_5 used"
}

# ------------------------------------------------------------
# CRON TASK: Every day at 6 AM, append users with more than 3 failed logins to security_alerts.txt
# Runs when crontab calls:  ./main.sh --cron
# ------------------------------------------------------------
cron_task() {
    mkdir -p reports
    if ! check_data; then
          log "cron task failed:data validation failed"
           return 1
    fi
    feature_5 >> reports/cron_output.txt 2>&1
    echo "$(date '+%-%m-%d %H:%M') cron task ran" >> reports/cron_output.txt4
    log "cron task ran"
}

