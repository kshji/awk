# get.1.example.awk
# use getXML.awk parser
# example to print out xml tree
# gawk -f  get.1.example.awk example.xml

BEGIN {
     while ( getXML(ARGV[1],0) ) {
         print XTYPE, XITEM, XPATH;
         #print XLINE,XTYPE, XITEM, XPATH, XNODE;
         for (attrName in XATTR)
             print "\t" attrName "=" XATTR[attrName];
     }
     if (XERROR) {
         print XERROR;
         exit 1;
     }
}
# if your awk not support include, then add getXML.awk file here
@include "getXML.awk"
