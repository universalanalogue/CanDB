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

#repaircdb(){
#still needs a way to remove trailing indev ,
#cdb=$(cat candb.cdb)
#cdb=$(tr -d "\r" <<< "$cdb")
#cdb=$(sed 's/,,//g' <<<"$cdb")
#echo "$cdb" > candb.cdb
#}

buildcdb(){
echo "#upctbl
#cantbl
#cantblend" >> candb.cdb
}

regupc(){
upc="$1"
count=$(sed -n '/#upctbl/,/#cantbl/p' candb.cdb | grep -w "$upc" | wc -l)
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
[9]) type=spice ; break ;;
[1][0]) type=medicine ; break ;;
esac
done
overlay "$type" 15 9
sed -i "/^#upctbl/a $upc,$man,$mod,$type,${oz}oz" candb.cdb
fi
}

fulllist(){
#1y/n
cantbl=$(sed -n '/#cantbl/,/#cantblend/p' candb.cdb | sed '/#/d' | grep ".$1")
upctbl=$(sed -n '/#upctbl/,/#cantbl/p' candb.cdb | sed '/#/d' | tr -d ' ' | sed '/^$/d')
upc=$(tr "," " " <<< "$upctbl" | awk '{ print $1 }')
t=$(wc -l <<< "$upc")
c=1
can="$cantbl"
#read -p "$can"
while [ $c -le $t ] ; do
a1=$(sed "${c}q;d" <<< "$upc")
info=$(grep "$a1" <<< "$upctbl")
can=$(sed "s/$a1/$info/" <<< "$can")
c=$((c+1))
done
can=$(tr "," " " <<< "$can")

echo "$can"

}

colorset(){
#  blk green                      background    text     cursor   resetpos
if [ $1 -eq 2 ] ; then printf '\e]11;black\a\e[0;32m\e]12;green\a\e[0;0H' ; fi
#  blk gold
if [ $1 -eq 1 ] ; then printf '\e]11;black\a\e[0;33m\e]12;gold\a\e[0;0H' ; fi
}

reader () {
#oldvariables
#page1=curpage1 ; page1p=curpage2 ; page2=n/u ; page3=textvis1
#page4=n/u ; page5=txtlgth ; page5p=totpage ; page6=textvis2
#interface stuff
eprompt=$(printf "# File name to Export: %-49s #")
text=("$1")
header=("$2")
title=$(printf "# CandDB Report Manager %-48s #")
fill=$(printf '%-35s')
bar1=$(printf "%-74s" | tr ' ' '#')
prompt=$(printf "# : %-69s#")
#total length of $text
txtlgth=$(wc -l <<< "$text")
#total visable lines in the interface
total=19
totpage=$(printf '%-2s' $(((txtlgth / total)+1)))

#used for alternating color lines
cc=33
curpage1=1
count=1
#sets a variable of the total length of text with appropriate
#number of preceeding zeros
num2=$((5-$(wc -c <<< "$txtlgth")))
zero=$(printf "%-${num2}s" | tr ' ' '0')
num1=("$zero$txtlgth")

while true ; do
printf "\e[0;0H"

#used to get visible area of text in the block
textvis1=$((curpage1 * total))
textvis2=$(head -n $textvis1 <<< "$text" | tail -n "$total")

form=$(while [ $count -le $total ] ; do
a1=$(printf '%-70s' "$(sed "${count}q;d" <<< "$textvis2")")
#the escapes flip flop colors between gold and green
printf "#\e[0;${cc}m $a1 \e[0;33m# \n"
cc=$((cc+1))
if [ $cc -eq 34 ] ; then cc=32 ; fi
count=$((count+1))
done)
curpage2=$(printf '%-2s' "$curpage1")

echo -e "$bar1\n$title\n$bar1\n# $header\n$form\n$bar1
# page: $curpage2 / $totpage # Total Items: $num1 # $fill#
$bar1
# Commands: n) next page # p) previous page # d) done reading e) export  #
$bar1\n$prompt\n$bar1"
printf "\e[29;5H"
read case1
case $case1 in

[n]) if [ $curpage1 -lt "$totpage" ] ; then curpage1=$((curpage1 + 1)) ; fi ;;
[p]) if [ $curpage1 -ne 1 ] ; then curpage1=$((curpage1 -1)) ; fi ;;
[e]) overlay "$eprompt" 1 27
overlay "$prompt" 1 29
printf "\e[29;5H"
read name
echo "$header
$text" > "${name}
Total Items: $num1".txt ;;
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
colorset 1
if [ ! -f candb.cdb ]
then
buildcdb
fi

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
8) Soup
9) Spice
10) Medicine")
upc7=("WILL DELETE ALL CANS WITH THIS UPC!!!
UPC to delete")
upc8=("Please enter Expiration YY-MM-DD")
id1=("Type id to remove (ie 0001)")

graphic=('  _____________
 /_____________\ 
|               |
|_______________|
|     CanDB     |
|   V1.00.04    |
|               |
|_______________|
|               |
|_______________|
 \_____________/')


num='^[0-9]+$'
while true ; do
unset upc
ui
overlay "$menu1" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read case1

if [ $(wc -c <<< $case1) -eq 13 ] && [[ $case1 =~ $num ]] ; then upc="$case1" ; case1=3 ;fi

case $case1 in
[1]) ui
overlay "$upc1" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc
upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
if [[ "$upc" != c ]] ; then
regupc "$upc" ; fi ;;


[2]) ui
overlay "$upc7" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc
upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
count=$(sed -n '/#upctbl/,/#cantbl/p' candb.cdb | grep -w "$upc" | wc -l)
if [[ "$upc" != c ]] ; then
if [ "$count" -eq 1 ] ; then
#this preps the id for recycling
workf1=$(sed -n '/#upctbl/,/#cantbl/p' candb.cdb | sed "/$upc/c\ " | sed 's/#cantbl//')
workf2=$(sed -n '/#cantbl/,/#candtblend/p' candb.cdb | sed "s/$upc.*/------------,--------,.n/")

echo "$workf1
$workf2" > candb.cdb
fi ; fi ;;

[3]) ui
overlay "$upc1" 3 5
if [ -z $upc ] ; then
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc
upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
fi
overlay "$upc" 14 5
if [[ "$upc" != c ]] ; then
count=$(sed -n '/#upctbl/,/#cantbl/p' candb.cdb | grep -w "$upc" | wc -l)
if [ "$count" -eq 0 ] ; then
regupc "$upc"
disp=20
else
disp=6
fi
overlay "$upc8" 3 $disp

overlay "$prompt" 1 29
printf "\e[29;5H"
read exp
exp=$(cleaninput $exp)
#check for recyclable numbers
num1=$(sed -n '/#cantbl/,/#cantblend/p' candb.cdb | sed '/#/d' | grep ".n" | tr "," " " | awk '{print$1}' | tr -d "-" | head -n 1)
upc=$(sed -n '/#cantbl/,/#cantblend/p' candb.cdb | sed '/#/d' | grep ".n" | grep "$num1" | tr "," " " | awk '{print$2}' | head -n 1)

sed -i "s|$num1,$upc|----,$upc|" candb.cdb
#run if no recycable numbers
if [ -z $num1 ] ; then
number=$(sed -n '/#cantbl/,/#cantblend/p' candb.cdb | sed '/#/d' | tail -n 1 | tr "," " " | awk '{ print $1 }')
if [ -z $number ] ; then number=0 ; fi
num1=$((10#$number+1))
num2=$((5-$(wc -c <<< "$num1")))
zero=$(printf "%-${num2}s" | tr ' ' '0')
num1=("$zero$num1")
fi
exp=$(tr "-" " " <<< "$exp")
exp1=$(awk '{ print $1 }' <<< "$exp")
exp2=$(awk '{ print $2 }' <<< "$exp")
exp3=$(awk '{ print $3 }' <<< "$exp")
if [ $(($(wc -c <<< "$exp1")-1)) -eq 1 ] ; then exp1=("0$exp1") ; fi
if [ $(($(wc -c <<< "$exp2")-1)) -eq 1 ] ; then exp2=("0$exp2") ; fi
if [ $(($(wc -c <<< "$exp3")-1)) -eq 1 ] ; then exp3=("0$exp3") ; fi
exp=("$exp1-$exp2-$exp3")

sed -i "/^#cantblend/i $num1,$upc,$exp,.y" candb.cdb
fi ;;

[4]) #change to use reader interface
 ui
overlay "$upc1" 3 5
overlay "$prompt" 1 29
printf "\e[29;5H"
read upc

upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
if [[ "$upc" != c ]] ; then

cantbl=$(sed -n '/#cantbl/,/#cantblend/p' candb.cdb | sed '/#/d' | grep -w "$upc" | grep '.y')
upctbl=$(sed -n '/#upctbl/,/#cantbl/p' candb.cdb | sed '/#/d' | grep "$upc")
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
sed -i "/$id/c\\$can" candb.cdb
fi
fi ;;

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
read upc
upc=$(cleaninput $upc)
upc=$(cleanupc $upc)
if [[ "$upc" != c ]] ; then
cantbl=$(sed -n '/#cantbl/,/#cantblend/p' candb.cdb | sed '/#/d' | grep "$upc" | grep '.y')
upctbl=$(sed -n '/#upctbl/,/#cantbl/p' candb.cdb | sed '/#/d' | grep "$upc")
can=$(sed "s/$upc/$upctbl/" <<< "$cantbl")
can=$(tr "," " " <<< "$can")
#merged list fields
#1 id 2 upc 3 brand 4 item 5 Name 6 size 7 exp 8 active
header=("Expiration UPC        Brand   Name   Size Type")
can=$(awk ' { print $7,$2,$3,$4,$6,$5 } ' <<< "$can" | sort)
reader "$can" "$header"
fi ;;

[2]) can=$(fulllist n)
header=("ID   UPC          Brand   Name   Size Expiration Type")
can=$(awk ' { print $1,$2,$3,$4,$6,$7,$5 } ' <<< "$can" | sort)
reader "$can" "$header"
;;

[3]) can=$(fulllist y)
header=("UPC        Brand   Name     Size  Type  Expiration")
can=$(awk ' { print $2,$3,$4,$6,$5,$7 } ' <<< "$can" | sort)
reader "$can" "$header"
;;

[4]) can=$(fulllist y)
header=("Expiration UPC        Brand   Name   Size Type")
can=$(awk ' { print $7,$2,$3,$4,$6,$5 } ' <<< "$can" | sort)
reader "$can" "$header"
;;

[5]) can=$(fulllist y)
header=("Name     Brand  Size  Type  UPC    Expiration")
can=$(awk ' { print $4,$3,$6,$5,$2,$7 } ' <<< "$can" | sort)
reader "$can" "$header"
;;

[6]) can=$(fulllist y)
header=("Type Name        Brand  Size  UPC    Expiration")
can=$(awk ' { print $5,$4,$3,$6,$2,$7 } ' <<< "$can" | sort)
reader "$can" "$header"
;;

[e]) break ;;

esac

done
;;


[e]) break ;;

esac
done


#stuff for daily value tables
#servings,calories,cff, tfat, sFat, trFAT,Cholesterol,sodium,Carb,fiber,Suger, protein,VAThiamin(b1)riboflav(b2),Nicin(b6),b12,Vc,ve,vk,Magnesium
#dvtbl
#dvtblend
#
#
