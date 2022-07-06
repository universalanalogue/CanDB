# CanDB
A lightweight database for cataloging canned goods

## Dependancies

Bash -ge V4

gnucoreutils

## Installation
>LINUX
1) git clone https://github.com/universalanalogue/CanDB.git

2) chmod +x -R CanDB ; cd CanDB

3) Load ./candb.sh.  It will automatically create a template cdb (CANDATABASE) file to use for the database.  If you register a can with option 3, and it doesn't exist in the UPC register, it will start the UPC registration function.  Reports generated with option 5 can be exported in the reports interface using the e key.

>FREEBSD
1) Have bash, gsed, gawk, and coreutils installed

2) git clone https://github.com/universalanalogue/CanDB.git

3) chmod +x -R CanDB ; cd CanDB

4) ./bsd.sh

5) rest the same as linux.

>MACOS

1) Install bash, gsed, gawk, coreutils, and git from homebrew

2) Rest the same as FREEBSD

>Windows

1) Install Cygwin

2) Be sure you install git during the install

3) Rest the same as Linux


## What it does
CanDB is a small script for managing a csv database of canned goods.  It reads UPCs and allows for categorization of UPC and managing of individual cans in a collection.  It also provides facilities for report generation, viewing and export. 

## Todo
1) Daily Value data import and reporting
2) Recipe managment

## Why?
Why not?  I do everything else this way so why not a database?
