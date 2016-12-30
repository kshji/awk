#!/bin/ksh
# or use bash
# compare.files.sh
# Jukka Inkeri 2016-12-26
# example how to compare current and prevous version
# - new lines
# - updated lines
# - removed lines
# Result: union file and also removed, new, updated, nottouched, newversion files
#
# - make two example file
# - first version, the original
cat <<EOF > $0.1.dat
1234 Some data ver 1
2345 Some data string, this will removed in next version
4567 timestamp $(date +'%Y-%m-%d_%H:%M:%S')
5678 Hello world
6789 Yes or No
EOF

sleep 2 # to get new timestamp value
 
# -- new version
cat <<EOF > $0.2.dat
1234 Some data ver 1
4567 timestamp $(date +'%Y-%m-%d_%H:%M:%S')
6789 Yes or No
7890 New dataline
8901 Other new line
EOF
 
# This awk script has done so that you can select which column/field is key
# In this example key field is 1st
po=$0.removed.dat
uu=$0.new.dat
mu=$0.updated.dat
ei=$0.same.dat
newver=$0.newversion.dat
debug=1
keyfld=1
deli=" "  # whitespace is default, only example how you can set field sep. Chars or strings
> $po
> $uu
> $mu
> $ei
> $newver
 
# 
f1="$0.1.dat"   # older version
f2="$0.2.dat"   # newer version
 
# -F delimiter
# -v set variable for Awk
# awk code between '  ' and then 1-n input files
# awk code can be also in file (between ' ' data). If in file then you need option -f inputawkrules
# 
awk -F "$deli" -v firstf=$f1 -v keyfld=$keyfld  -v debug=$debug -v removef=$po -v newf=$uu \
        -v updatedf=$mu -v nochangef=$ei \
'
# - read 1st file keys to the array ind1 and data to array data1 (data=line)
function read_file1(inputfile) {
	# scan input file 1st and save to the array
        while (i = getline < inputfile ) {
                ind1[$keyfld]=1   # save key
                data1[$keyfld]=$0 # save data line
                }
        close(inputfile)
        if (debug>0 ) {
                for (i in ind1) {
                        print tied,"ind1",i > "/dev/stderr"
                        }
                print "________________________________" > "/dev/stderr"
                }
}
 
# - look which keys are not in ind2 => remove from ind1
# - we dont need this function in this solution, but this example how you can collect those keys
function removed(t1,t2) {
        for (i in t1) {
                if (t2[i] != 1 ) {
                        if (debug>0)   print "removed",i > "/dev/stderr"
                        print i >> removef
                        }
                }
 
}
BEGIN { # BEGIN section has proceseed before input file is opened
        # read 1st file to the arrays
        read_file1(firstf)
        }
 
# - read rules for newer file (2nd file), rules is for input line, no need to make while read line ..
#   Rule blocks are for input record, default is line using newline record separator
 
# - for everyline when NumberofFields is > 0
NF < 1 { # not enough fields
         next  # next line reading 
       }
 
# default rule = no rule before {   } block = for everylines
        {
        ind2[$keyfld]=1       # save key
        data2[$keyfld]=$0     # save data
        if (debug>1) print "avain:",$keyfld,ind2[$keyfld]
        if (ind1[$keyfld] != 1 ) {  # wasnt in 1st version = new line 
                if (debug>0)  print "newver",$keyfld,"data:",data2[$keyfld] > "/dev/stderr"
                print data2[$keyfld] >> newf
                }
        if ( ind1[$keyfld] == 1 && ind2[$keyfld] == 1 && (data1[$keyfld] != data2[$keyfld] ) ) {
                # updated, some diff between values
                if (debug>0)  print "changed","data1:",data1[$keyfld],"data2:",data2[$keyfld] > "/dev/stderr"
                print data2[$keyfld] >> updatedf

		#you can save remove value if needed
                #print ind2[$keyfld] >> removef
                }
	# if no change in line then print it = keep it
        if ( ind1[$keyfld] == 1 && ind2[$keyfld] == 1 && (data1[$keyfld] == data2[$keyfld] ) ) {
                # no change in any fields, keep it
                print data2[$keyfld] >> nochangef
                }
        }
 
END { # this special block has done after input file has readed and closed
        # - now we can look which keys are removed
        removed(ind1,ind2)
        }
 
' "$f2"
 
# - done, look result files
for f in $po $mu $uu $ei
do
        ((debug<1)) && continue
        echo "______________________________________________________________________"
        echo "$f"
        cat $f
        echo "______________________________________________________________________"
done
 
# and make current version
cat $ei $mu $uu > $newver
 
((debug>0)) && diff $f1 $newver
 
echo "New version $newver" >&2
