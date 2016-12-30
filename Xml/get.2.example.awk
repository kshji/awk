# get.2.example.awk
# use getXML.awk parser
# example to print out xml elements and attributes values
# gawk -f  get.2.example.awk example.xml
BEGIN {
     OFS="|"
     #while ( getXML(ARGV[1],1) ) {
     print "TAG","ELEMENT","PATH","ATTR","VALUE"
     while ( getXML(ARGV[1],0) ) {
         xdataline=0
         # trim value XITEM, remove also newlines
         gsub(/^ */,"",XITEM)
         gsub(/ *$/,"",XITEM)
         gsub(/\n/,"",XITEM)
         gsub(/\r/,"",XITEM)
         # element value
         if (XTYPE == "TAG") TAGNAME=XITEM  # - save ELEMENT name
         if (XTYPE == "DAT" && length(XITEM)>0 ) xdataline=1
         # attribute value
         if (XTYPE=="TAG" && length(XITEM)>0 && length(XATTR)>0 ) xdataline=1
         if (xdataline != 1 ) continue

         # this data we need ELEMENT or ATTRIBUTE
         if (XTYPE == "DAT") print XTYPE, TAGNAME, XPATH, "",XITEM  # element

	 # print out attributes
         for (attrName in XATTR) {
             print "ATTR",TAGNAME,XPATH,attrName,XATTR[attrName]
             }
     }
     if (XERROR) {
         print XERROR;
         exit 1;
     }
}


# if your awk not support include, then add getXML.awk file here
@include "getXML.awk"
