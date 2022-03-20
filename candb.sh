#!/bin/bash

cleaninput (){
input=$(tr -d ' ' <<< "$1")
input=$(tr -d "," <<< "$input")
echo "$input"

}

cleanupc(){
upc=$(tr '[:upper:]' '[:lower:]' <<< "$1")
echo "$upc"
}

repaircsv(){
#still needs a way to remove trailing indev ,
csv=$(cat candb.csv)
csv=$(tr -d "\r" <<< "$csv")
csv=$(sed 's/,,//g' <<<"$csv")
echo "$csv" > candb.csv
}

regupc(){
upc="$1"
count=$(sed -n '/#upctbl/,/#cantbl/p' candb.csv | grep -w "$upc" | wc -l)
if [ "$count" -eq 1 ] ; then overlay "$upc2" 3 6
read case1 ; fi
if [ "$count" -eq 0 ] ; then
overlay "$upc" 14 5
overlay "$upc3" 3 6
overlay "$prompt" 1 29
printf "\e[29;5H"
read man
man=$(cleaninput $man)
overlay "$man" 22 6
overlay "$upc4" 3 7
overlay "$prompt" 1 29
printf "\e[29;5H"
read mod
mod=$(cleaninput $mod)
overlay "$mod" 16 7
overlay "$upc5" 3 8
overlay "$prompt" 1 29
printf "\e[29;5H"
read oz
oz=$(cleaninput $oz)
overlay "${oz}oz" 19 8
while true ;do
overlay "$upc6" 3 9
overlay "$prompt" 1 29
printf "\e[29;5H"
read case1

case $case1 in
[1]) type=veg ; break ;;
[2]) type=fruit ; break ;;
[3]) type=carb ; break ;;
[4]) type=meat ; break ;;
[5]) type=sause ; break ;;
[6]) type=bean ; break ;;
[7]) type=meal ; break ;;
[8]) type=soup ; break ;;
esac
done
overlay "$type" 15 9
sed -i "/^#upctbl/a $upc,$man,$mod,$type,${oz}oz" candb.csv
fi
}

fulllist(){
#1y/n
cantbl=$(sed -n '/#cantbl/,/#cantblend/p' candb.csv | sed '/#/d' | grep ".$1")
upctbl=$(sed -n '/#upctbl/,/#cantbl/p' candb.csv | sed '/#/d')
upc=$(tr "," " " <<< "$upctbl" | awk '{ print $1 }')
t=$(wc -l <<< "$upc")
c=1
can="$cantbl"

while [ $c -le $t ] ; do
a1=$(sed "${c}q;d" <<< "$upc")
info=$(grep "$a1" <<< "$upctbl")
can=$(sed "s/$a1/$info/" <<< "$can")
c=$((c+1))
done
can=$(tr "," " " <<< "$can")
echo "$can"

}

reader () {
text=("$1")
title=$(printf "# CandDB Report Manager %-48s #")
fill=$(printf '%-54s')
bar1=$(printf "%-74s" | tr ' ' '#')
prompt=$(printf "# : %-69s#")

while true ; do
printf "\e[0;0H"
page5=$(wc -l <<< "$text")
page2=$(wc -w <<< "$page1")
if [ $page2 -eq 0 ] ; then page1=1 ; fi
total=20
count=1
page3=$((page1 * total))
page6=$(head -n $page3 <<< "$text" | tail -n "$total")
form=$(while [ $count -le $total ] ; do
a1=$(printf '%-70s' "$(sed "${count}q;d" <<< "$page6")")
printf "# $a1 # \n"
count=$((count+1))
done)
page1p=$(printf '%-2s' "$page1")
page5p=$(printf '%-2s' $(((page5 / total)+1)))
echo -e "$bar1\n$title\n$bar1\n$form\n$bar1
# page: $page1p / $page5p  # $fill#
$bar1
# Commands: n) next page # p) previous page # d) done reading e) export  #
$bar1\n$prompt\n$bar1"
printf "\e[29;5H"
read case1
case $case1 in

[n]) if [ $page1 -lt "$page5p" ] ; then page1=$((page1 + 1)) ; fi ;;
[p]) if [ $page1 -ne 1 ] ; then page1=$(($page1 -1)) ; fi ;;
[d]) break ;;

esac
done
}

overlay(){
#$1 input $2 xaxis start $3 yaxis start
#compatibility for 0 position
xaxis=$2 ; if [ $xaxis -eq 0 ] ; then xaxis=1 ; fi
yaxis=$3 ; if [ $yaxis -eq 0 ] ; then yaxis=1 ; fi
var1=("$1")
#replace newlines with bare locators
var1=$(awk 1 ORS='nwlne' <<< "$var1" | sed "s/\(.*\)nwlne/\1/ ; s/nwlne/\\\\e[#layer;${xaxis}H/g")
#create counter for finished locators
mat=$(($(grep -o '#layer' <<< "$var1" | wc -l)+1))
#finish locators
var1=$(awk -v yaxis="$yaxis" -v v=1 -v mat="$mat" '{while( v < mat)
if($x~/#layer/){sub(/#layer/,v++ + yaxis)}}1' <<< "$var1")
#draws overlay
printf "\e[${yaxis};${xaxis}H${var1}"
}

ui (){
title=$(printf "# CanDB %-64s #")
fill=$(printf '%-54s')
bar1=$(printf "%-74s" | tr ' ' '#')
prompt=$(printf "# : %-69s#")
printf "\e[0;0H"
total=22
count=1
form=$(while [ $count -le $total ] ; do
printf "# %-70s # \n"
count=$((count+1))
done)

echo -e "$bar1\n$title\n$bar1\n$form
$bar1
# Type C to cancel Transaction                                           #
$bar1\n$prompt\n$bar1"
overlay "$graphic" 57 15
}

printf "\ec"
repaircsv

prompt=$(printf "# : %-69s#")

menu1=("Main Menu
1) register new upc
2) remove upc from register
3) register can
4) remove can from register
5) reports
e) exit")

menu2=("Reports menu
1) Specific UPC by expiration (active)
2) show inactive cans
3) All Active Cans by UPC
4) All Active By expiration
5) All Active by item name
6) All Active by Type
e) exit")

upc1=("Enter UPC:")
upc2=("Can already in register
Press Enter to continue")
upc3=("Enter Manufaturer:")
upc4=("Enter Model:")
upc5=("Enter Capacity:")
upc6=("Food Group:
1) Vegetable
2) Fruit
3) Starch
4) meat
5) Sauce
6) Bean
7) Meal
8) Soup")
upc7=("WILL DELETE ALL CANS WITH THIS UPC!!!
UPC to delete")
upc8=("Please enter Expiration YY-MM-DD")
id1=("Type id to remove (ie 0001)")

graphic=('  _____________
 /_____________\ 
|               |
|_______________|
|               |
|     CanDB     |
|               |
|_______________|
|               |
|_______________|
 \_____________/')

intro=1

while true ; do

ui


overlay "$menu1" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read case1


case $case1 in
[1]) ui
overlay "$upc1" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc
upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
if [[ "$upc" != c ]] ; then
regupc "$upc" ; fi
input=1 ;;


[2]) ui
overlay "$upc7" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc
upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
count=$(sed -n '/#upctbl/,/#cantbl/p' candb.csv | grep -w "$upc" | wc -l)
if [[ "$upc" != c ]] ; then
if [ "$count" -eq 1 ] ; then
sed -i "/$upc/c\\" candb.csv ; fi ; fi
intro=1 ;;

[3]) ui
overlay "$upc1" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc
upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
overlay "$upc" 14 5
if [[ "$upc" != c ]] ; then
count=$(sed -n '/#upctbl/,/#cantbl/p' candb.csv | grep -w "$upc" | wc -l)
if [ "$count" -eq 0 ] ; then
regupc "$upc"
disp=18
else
disp=6
fi
overlay "$upc8" 3 $disp

overlay "$prompt" 1 29
printf "\e[29;5H"
read exp
exp=$(cleaninput $exp)
number=$(sed -n '/#cantbl/,/#cantblend/p' candb.csv | sed '/#/d' | tail -n 1 | tr "," " " | awk '{ print $1 }')
num1=$((number+1))
num2=$((5-$(wc -c <<< "$num1")))
zero=$(printf "%-${num2}s" | tr ' ' '0')
num1=("$zero$num1")
sed -i "/^#cantblend/i $num1,$upc,$exp,.y" candb.csv
fi 
intro=1;;

[4]) ui
overlay "$upc1" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc

upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
if [[ "$upc" != c ]] ; then

cantbl=$(sed -n '/#cantbl/,/#cantblend/p' candb.csv | sed '/#/d' | grep -w "$upc" | grep '.y')
upctbl=$(sed -n '/#upctbl/,/#cantbl/p' candb.csv | sed '/#/d' | grep "$upc")
can=$(sed "s/$upc/$upctbl/" <<< "$cantbl" | tr "," " ")
can=$(awk ' { print $7,$1,$3,$4,$6,$5 } ' <<< "$can" | sort | head -n 5)

overlay "$id1" 3 8
overlay "$can" 3 10
overlay "$prompt" 1 29
printf "\e[29;5H"
read id
id=$(cleanupc $id)
if [[ "$id" != c ]]
then
can=$(grep "$id" <<< "$cantbl")
can=$(sed "s|.y|.n|" <<< "$can")
sed -i "/$id/c\\$can" candb.csv
fi
fi
intro=1 ;;

[5]) while true ; do
ui
overlay "$menu2" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read case1
case $case1 in

[1]) overlay "$upc1" 3 12
overlay "$prompt" 1 29
printf "\e[29;5H"

upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
if [[ "$upc" != c ]] ; then
cantbl=$(sed -n '/#cantbl/,/#cantblend/p' candb.csv | sed '/#/d' | grep "$upc" | grep '.y')
upctbl=$(sed -n '/#upctbl/,/#cantbl/p' candb.csv | sed '/#/d' | grep "$upc")
can=$(sed "s/$upc/$upctbl/" <<< "$cantbl")
can=$(tr "," " " <<< "$can")
#merged list fields
#1 id 2 upc 3 brand 4 item 5 type 6 size 7 exp 8 active
can=$(awk ' { print $7,$2,$3,$4,$6,$5 } ' <<< "$can" | sort)
reader "$can"
fi ;;

[2]) can=$(fulllist n)
can=$(awk ' { print $1,$2,$3,$4,$6,$7,$5 } ' <<< "$can" | sort)
reader "$can"
;;

[3]) can=$(fulllist y)
can=$(awk ' { print $2,$3,$4,$6,$5,$7 } ' <<< "$can" | sort)
reader "$can"
;;

[4]) can=$(fulllist y)
can=$(awk ' { print $7,$2,$3,$4,$6,$5 } ' <<< "$can" | sort)
reader "$can"
;;

[5]) can=$(fulllist y)
can=$(awk ' { print $4,$3,$6,$5,$2,$7 } ' <<< "$can" | sort)
reader "$can"
;;

[6]) can=$(fulllist y)
can=$(awk ' { print $5,$4,$3,$6,$2,$7 } ' <<< "$can" | sort)
reader "$can"
;;

[e]) break ;;

esac

done
intro=1
;;


[e]) break ;;

esac
done
