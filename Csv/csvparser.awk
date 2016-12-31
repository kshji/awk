# csvparser.awk
# Jukka Inkeri
# awk -v deli=";" -v debug=0 -f csvparser.awk input.csv
# -v debug=1   # you get debug msg
# -v deli="|"  # delimeter, default is ;
# -f csvparser.awk input.csv
# array f include fldnames
# array v include values
# This example csv file 1st line include column names.
# if there is extra columns in data lines, those are removed
# This not include all RFC (csv) properties ...
# 
 
function parse_var(cnt) {
        for (i=1;i<=cnt;i++) {
                if (debug>0) { print "v:",i,$i }
                var=f[i]
                v[var]=$i
                if (debug>0) { print "k:",var,i,$i,"::",f[i],"!!",v[var] }
                }
}
 
# default delimiter is ;
BEGIN { if (deli=="") { deli=";" }
        FS=deli
        OFS=deli
        }
 
# like to remove "
      { gsub(/"/,"") }
 
NR==1 { # parse header line, get fld names
        for (i=1;i<=NF;i++) {
                f[i]=$i
                }
        fldcnt=i-1
        if (debug>0) {
                for (i=1;i<=fldcnt;i++) {
                        print "f",i,f[i]
                        }
                }
        next
        }
 
NF>=fldcnt { # parse dataline values
        parse_var(fldcnt)
        # - set column "other" ... using key and label column value
        v["other"]=v["key"] "-and-" v["label"]
        # - print result
        print "B:",v["label"],v["key"],v["other"]
        }


# use example
# awk -v deli=";" -v debug=0 -f csvparser.awk input.csv
