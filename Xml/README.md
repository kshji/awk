
Here is some helps for XML files handling using Awk.

getXML.awk is parser. It parse data to the some variables. You can use those variables to look
values, elements, paths, attributes, ...

You can easily reformat XML to the csv format and after that parse CSV format using awk. Usually it's
easier to handle some "table data" as XML when using Awk, ksh, ...

getXML.awk has copied from discuss
https://groups.google.com/forum/#!search/getxml.awk by Jan Weber. Thanks Jan.

I use new **gawk** with extension library. I have used @inclide in my awk scripts to include getXML.awk, but
you can use only any awk, add getXML.awk to the end of your awk-script.

