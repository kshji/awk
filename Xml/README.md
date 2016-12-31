# XML parsing using Awk #

Here is some helps for XML files handling using Awk.

  * http://www.grymoire.com/Unix/Awk.html Awk manual
  * http://gawkextlib.sourceforge.net/xmlgawk.html Gnu Awk extensions including Xml and Postgresql
  * https://www.gnu.org/software/gawk/manual/gawk.pdf Gnu Awk manual (pdf)
     * https://www.gnu.org/software/gawk/manual/gawk.html  Gnu Awk manual (html)
  * http://gawkextlib.sourceforge.net/xmlgawk.html XML and GnuAwk using gawkextlib extension

This examples use standard Awk, no need for Gnu Awk extensions.

You can look more question&answer from http://www.unix.com/shell-programming-and-scripting/ and search xml or awk.

## Some nice commands to handle xml-data ##

Xmllint is nice tool to test and format xml files:
  * xmllint --pretty 1 example.xml
  * xmllint --pretty 0 example.xml
  * xmllint --pretty 2 example.xml

Xmllint also include XPath support.

If needed pack xml, it can be done using **tr**:
```sh
# remove CR and NL
cat example.xml | tr -d "\015\012" 
```


Other interesting command tools to handle Xml-data:
   * xml2
   * xmlstarlet
   * xmllint
   * PostgreSQL

### Xml2 ###
```sh
xml2 < example.xml
```

Output:
```text
/MYELEMENT/HEADER/CODE=XXXX
/MYELEMENT/HEADER/NAME=SOMEDEST
/MYELEMENT/HEADER/ID=XXXXX1111XXX
/MYELEMENT/HEADER/TYPE=START
/MYELEMENT/MAIN/ELEMENTX/@attr1=Value1
/MYELEMENT/MAIN/ELEMENTX/@attr2=Value2
/MYELEMENT/MAIN/ELEMENTX=ElemValue
/MYELEMENT/MAIN/NO=123123
/MYELEMENT/MAIN/TXT=Some
/MYELEMENT/MAIN/DIR=111-000-1111
/MYELEMENT/DATA/NUM=000-000-0000
```
### Xmllint and XPATH ###

**XPath** ?
http://www.w3schools.com/xml/xpath_examples.asp

Get element NUM value:
```sh
xmllint example.xml --xpath '//NUM/text()'
```

### PostgreSQL ###
Posgresql include field type XML and lot of nice XPath functions to parse XML to the tables.
Postgresql command COPY is so fast to read xml file to the database. I'll the fastest method to parse xml to the Postgresql database.
Look my git Postgresql directory.


## getXML.awk ##

**getXML.awk** is parser. It parse data to the some variables. You can use those variables to look
values, elements, paths, attributes, ...

You can easily reformat XML to the csv format and after that parse CSV format using awk. Usually it's
easier to handle some "table data" as XML when using Awk, ksh, ...

getXML.awk has copied from discuss
https://groups.google.com/forum/#!search/getxml.awk by Jan Weber. Thanks Jan.

I use new **gawk** with extension library. I have used @include in my awk scripts to include getXML.awk, but
you can use any awk, add getXML.awk to the end of your awk-script.




### example.xml ###

```xml
<?xml version="1.0" encoding="UTF-8"?>
<MYELEMENT>
  <HEADER>
    <CODE>XXXX</CODE>
    <NAME>SOMEDEST</NAME>
    <ID>XXXXX1111XXX</ID>
    <TYPE>START</TYPE>
  </HEADER>
  <MAIN>
    <ELEMENTX attr1="Value1" attr2="Value2">ElemValue</ELEMENTX>
    <NO>123123</NO>
    <TXT>Some</TXT>
    <DIR>111-000-1111</DIR>
  </MAIN>
  <DATA>
    <NUM>000-000-0000</NUM>
  </DATA>
</MYELEMENT>
```




### get.1.example.awk ###
Parse xml and printout what the getXML.awk can parse:
```sh
  gawk -f get.1.example.awk example.xml
```


### get.2.example.awk ###
Parse xml and printout out only element and attribute values with path:
```sh
  gawk -f get.2.example.awk example.xml
```
Output:
```text
TAG|ELEMENT|PATH|ATTR|VALUE
DAT|CODE|/MYELEMENT/HEADER/CODE||XXXX
DAT|NAME|/MYELEMENT/HEADER/NAME||SOMEDEST
DAT|ID|/MYELEMENT/HEADER/ID||XXXXX1111XXX
DAT|TYPE|/MYELEMENT/HEADER/TYPE||START
ATTR|ELEMENTX|/MYELEMENT/MAIN/ELEMENTX|attr1|Value1
ATTR|ELEMENTX|/MYELEMENT/MAIN/ELEMENTX|attr2|Value2
DAT|ELEMENTX|/MYELEMENT/MAIN/ELEMENTX||ElemValue
DAT|NO|/MYELEMENT/MAIN/NO||123123
DAT|TXT|/MYELEMENT/MAIN/TXT||Some
DAT|DIR|/MYELEMENT/MAIN/DIR||111-000-1111
DAT|NUM|/MYELEMENT/DATA/NUM||000-000-0000
```

### get.3.example.awk ###
Parse get.2.example.awk output = basic awk processing ...
```sh
  gawk -f get.2.example.awk example.xml | awk -f get.3.example.awk
```

Output:
```text
attr1 Value1
NUM 000-000-0000
```

## Simple AWK XML Parser ##
If you need parse some elements from xml data, it can be done easily:

This idea is simple: parse input using delimiter chars < > | " =
```awk
awk -F '[<|>="]' '

# give some rules to search interesting values, example:
/NUM/ { print "FOUND:",$3 }

# here is debug printing, easier to see what you can do/get
      {#-debug print
         for (f=1;f<=NF;f++) printf "%d:%s ",f,$f
         printf "\n"
      }

' example.xml
```
Output
```text
1: 2:?xml version 3: 4:1.0 5: encoding 6: 7:UTF-8 8:? 9:
1: 2:MYELEMENT 3:
1:   2:HEADER 3:
1:     2:CODE 3:XXXX 4:/CODE 5:
1:     2:NAME 3:SOMEDEST 4:/NAME 5:
1:     2:ID 3:XXXXX1111XXX 4:/ID 5:
1:     2:TYPE 3:START 4:/TYPE 5:
1:   2:/HEADER 3:
1:   2:MAIN 3:
1:     2:ELEMENTX attr1 3: 4:Value1 5: attr2 6: 7:Value2 8: 9:ElemValue 10:/ELEMENTX 11:
1:     2:NO 3:123123 4:/NO 5:
1:     2:TXT 3:Some 4:/TXT 5:
1:     2:DIR 3:111-000-1111 4:/DIR 5:
1:   2:/MAIN 3:
1:   2:DATA 3:
FOUND: 000-000-0000
1:     2:NUM 3:000-000-0000 4:/NUM 5:
1:   2:/DATA 3:
1: 2:/MYELEMENT 3:
```


Very simple method to get element value:

```awk
awk -F'</?NUM>' 'NF>1{print $2}' example.xml
```

Output:
```text
000-000-0000
```
OR

Caller give the element name to get values
```awk
awk -v elem=NUM '
BEGIN {
    RS="<"
    FS=">"
    }
$1 == elem { print $2 }
' example.xml

```
