# jo-backup

## introduction

rsync wrapper to use with cron or anacron. 
Starting the backup is delayed until two conditions are met:

* power supply must be plugged in
* cpu threashold must be below a given limit

## Config 

jo-backup looks for a config file in _/etc/jo-backup.conf_ and _~/.jo-backup.conf_.
Values from the global configuration can be overwritten with the local file.

### Example 
```
THREASHOLD=20
VERBOSE=0

# rsync options
#
# source and destination are passed as last and before last parameter to rsny
# this means all sources and destinatoins which are allowed for rsync are as values

SRC="/home/johannes/"
DST="odroid@192.168.2.11:/mnt/backup/"

RSYNC_OPTS="-vc --exclude .cache --exclude [Cc]ache*/  --exclude *~ --exclude *.bak --exclude *.backup*  --exclude Temp/ --exclude temp/ --exclude  tmp/"

```

### Description

* THREASHOLD: threashold for overall cpu which needs to be reached before the backup starts
* VERBOSE: 0 = Quiet, 1 = Warning, 2 = Debug. (Currently no warings implemented)

* SRC: backup source
* DST: backup destination
* RSYNC_OPTS: additional options passed to rsync see ```man rsync``` for more details.

## required programms

* acpi 
* mpstat
* awk
* bc
* rsync


# Todo:

* Make check for power supply configureable via config file
* Make intveral for cpu usage configurable  via config file
* Make sleep intervall configurable via config file
* Add max check counter for condtions
* Make options from config files also avilable via command line
