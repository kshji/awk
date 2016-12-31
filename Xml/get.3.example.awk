# get.3.example.awk
# use getXML.awk parser
# example to print out xml elements and attributes values
# gawk -f  get.2.example.awk example.xml | awk -f get.3.example.awk

BEGIN { FS="|" }
$1 == "DAT" && $2 == "NUM" { print $2,$5 }
$1 == "ATTR" && $2 == "ELEMENTX" && $4=="attr1" { print $4,$5 }
