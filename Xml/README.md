
Here is some helps for XML files handling using Awk.

*getXML.awk* is parser. It parse data to the some variables. You can use those variables to look
values, elements, paths, attributes, ...

You can easily reformat XML to the csv format and after that parse CSV format using awk. Usually it's
easier to handle some "table data" as XML when using Awk, ksh, ...

getXML.awk has copied from discuss
https://groups.google.com/forum/#!search/getxml.awk by Jan Weber. Thanks Jan.

I use new **gawk** with extension library. I have used @inclide in my awk scripts to include getXML.awk, but
you can use only any awk, add getXML.awk to the end of your awk-script.

Xmllint is nice tool to test and format xml files:
  * xmllint --pretty 1 example.xml
  * xmllint --pretty 0 example.xml
  * xmllint --pretty 2 example.xml

It also include XMLPATH support.

==== example.xml ====
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




==== get.1.example.awk ====
Parse xml and printout what the getXML.awk can parse:
  ''gawk -f get.1.example.awk example.xml''


==== get.2.example.awk ====
Parse xml and printout out only element and attribute values with path:
  ''gawk -f get.2.example.awk example.xml''

Output:
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

==== get.3.example.awk ====
Parse get.2.example.awk output = basic awk processing ...
  ''gawk -f get.2.example.awk example.xml | awk -f get.3.example.awk''

Output:
attr1 Value1
PORTED_NUM 000-000-0000
