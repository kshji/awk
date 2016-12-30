# XML parsing using Awk #

Here is some helps for XML files handling using Awk.

  * http://www.grymoire.com/Unix/Awk.html Awk manual
  * http://gawkextlib.sourceforge.net/xmlgawk.html Gnu Awk extensions including Xml and Postgresql
  * https://www.gnu.org/software/gawk/manual/gawk.pdf Gnu Awk manual (pdf)
     * https://www.gnu.org/software/gawk/manual/gawk.html  Gnu Awk manual (html)
  * http://gawkextlib.sourceforge.net/xmlgawk.html XML and GnuAwk using gawkextlib extension

This examples use standard Awk, no need for Gnu Awk extensions.

You can look more question&answer from http://www.unix.com/search.php?searchid=2427388

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
/PORT_RESPONSE/HEADER/ORIGINATOR=XXXX
/PORT_RESPONSE/HEADER/DESTINATION=SOMEDEST
/PORT_RESPONSE/HEADER/MESSAGE_ID=XXXXX1111XXX
/PORT_RESPONSE/HEADER/MSGTYPE=PRI
/PORT_RESPONSE/ADMIN/ELEMENTX/@attr1=Value1
/PORT_RESPONSE/ADMIN/ELEMENTX/@attr2=Value2
/PORT_RESPONSE/ADMIN/ELEMENTX=5.0.0
/PORT_RESPONSE/ADMIN/NO=123123
/PORT_RESPONSE/ADMIN/REP=Some
/PORT_RESPONSE/ADMIN/NO_REP=111-000-1111
/PORT_RESPONSE/DATA/PORTED_NUM=000-000-0000
```
### Xmllint and XPATH ###

**XPath** ?
http://www.w3schools.com/xml/xpath_examples.asp

Get element PORTED_NUM value:
```sh
xmllint example.xml --xpath '//PORTED_NUM/text()'
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
<PORT_RESPONSE>
  <HEADER>
    <ORIGINATOR>XXXX</ORIGINATOR>
    <DESTINATION>SOMEDEST</DESTINATION>
    <MESSAGE_ID>XXXXX1111XXX</MESSAGE_ID>
    <MSGTYPE>PRI</MSGTYPE>
  </HEADER>
  <ADMIN>
    <ELEMENTX attr1="Value1" attr2="Value2">5.0.0</ELEMENTX>
    <NO>123123</NO>
    <REP>Some</REP>
    <NO_REP>111-000-1111</NO_REP>
  </ADMIN>
  <DATA>
    <PORTED_NUM>000-000-0000</PORTED_NUM>
  </DATA>
</PORT_RESPONSE>
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
DAT|ORIGINATOR|/PORT_RESPONSE/HEADER/ORIGINATOR||XXXX
DAT|DESTINATION|/PORT_RESPONSE/HEADER/DESTINATION||SOMEDEST
DAT|MESSAGE_ID|/PORT_RESPONSE/HEADER/MESSAGE_ID||XXXXX1111XXX
DAT|MSGTYPE|/PORT_RESPONSE/HEADER/MSGTYPE||PRI
ATTR|ELEMENTX|/PORT_RESPONSE/ADMIN/ELEMENTX|attr1|Value1
ATTR|ELEMENTX|/PORT_RESPONSE/ADMIN/ELEMENTX|attr2|Value2
DAT|ELEMENTX|/PORT_RESPONSE/ADMIN/ELEMENTX||5.0.0
DAT|NO|/PORT_RESPONSE/ADMIN/NO||123123
DAT|REP|/PORT_RESPONSE/ADMIN/REP||Some
DAT|NO_REP|/PORT_RESPONSE/ADMIN/NO_REP||111-000-1111
DAT|PORTED_NUM|/PORT_RESPONSE/DATA/PORTED_NUM||000-000-0000
```

### get.3.example.awk ###
Parse get.2.example.awk output = basic awk processing ...
```sh
  gawk -f get.2.example.awk example.xml | awk -f get.3.example.awk
```

Output:
```text
attr1 Value1
PORTED_NUM 000-000-0000
```

## Simple AWK XML Parser ##
If you need parse some elements from xml data, it can be done easily:

This idea is simple: parse input using delimiter chars < > | " =
```awk
awk -F '[<|>="]' '

# give some rules to search interesting values, example:
/PORTED_NUM/{print "FOUND:",$3}

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
1: 2:PORT_RESPONSE 3:
1:   2:HEADER 3:
1:     2:ORIGINATOR 3:XXXX 4:/ORIGINATOR 5:
1:     2:DESTINATION 3:SOMEDEST 4:/DESTINATION 5:
1:     2:MESSAGE_ID 3:XXXXX1111XXX 4:/MESSAGE_ID 5:
1:     2:MSGTYPE 3:PRI 4:/MSGTYPE 5:
1:   2:/HEADER 3:
1:   2:ADMIN 3:
1:     2:ELEMENTX attr1 3: 4:Value1 5: attr2 6: 7:Value2 8: 9:5.0.0 10:/ELEMENTX 11:
1:     2:NO 3:123123 4:/NO 5:
1:     2:REP 3:Some 4:/REP 5:
1:     2:NO_REP 3:111-000-1111 4:/NO_REP 5:
1:   2:/ADMIN 3:
1:   2:DATA 3:
FOUND: 000-000-0000
1:     2:PORTED_NUM 3:000-000-0000 4:/PORTED_NUM 5:
1:   2:/DATA 3:
1: 2:/PORT_RESPONSE 3:

```


Very simple method to get element value:

```awk
awk -F'</?PORTED_NUM>' 'NF>1{print $2}' example.xml
```

Output:
```text
000-000-0000
```
OR

Caller give the element name to get values
```awk
awk -v key=PORTED_NUM '
BEGIN {
    RS="<"
    FS=">"
    }
$1 == key { print $2 }
' example.xml

```
