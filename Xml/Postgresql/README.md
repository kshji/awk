# Postgresql XML input/output #

Postgresql include lot of tools for XML data parsing to database, print out for XML,
Xpath support, stylesheet support, ...

https://www.postgresql.org/docs/current/static/functions-xml.html

## Example xml ##

example.xml
```xml 
<promotions>
    <promotion promotion-id="old-promotion">
        <nametext>some1</nametext>
        <enabled-flag>true</enabled-flag>
        <searchable-flag>false</searchable-flag>
    </promotion>
    <promotion promotion-id="new-promotion">
        <nametext>some2</nametext>
        <enabled-flag>false</enabled-flag>
        <searchable-flag>false</searchable-flag>
        <exclusivity>no</exclusivity>
        <price>100</price>
        <price>200</price>
        <price>300</price>
    </promotion>
</promotions>
```


## Create table ##

Create table **xmlinput** , schema **my**
```sql
CREATE TABLE my.xmlinput
(
  id serial NOT NULL,
  created TIMESTAMP WITH TIME zone NOT NULL DEFAULT now(),
  xmldoc text, -- saved input xml 
  xmldata xml, -- parsed/validated xml
  keyvalue text, -- some example fld from xml
  name text,
  CONSTRAINT pk_xmlinput PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
```

## Remove namespace ##
I like to use XML without namespaces.  

Here is some stylesheet which you can use to remove namespace from xml file.

rm_namespace.xsl
```xsl 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="no"/>
 
<xsl:template match="/|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>
 
<xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
</xsl:template>
 
<xsl:template match="@*">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>
</xsl:stylesheet>
```

```sh
xsltproc rm_namespace.xsl example.xml >  pure.xml
```

If you reading xml file to field (text or xml), then you need to remove newline and carriage return chars.

```
tr -d '\012\015' < pure.xml > purepacked.xml
```



## Copy xml to the database

PG COPY command is fast to handle CSV, JSON, XML, pipes, ... , don't try INSERT.

Use psql command to COPY xml to the field xmldoc (or xmldata if valilated xml):
```sh
psql -d databasename -h hostname -p 5432 -U dbuser -c '\copy my.xmlinput (xmldoc) from purepacked.xml'
# OR pipe sql command from stdin, this method you can use variables in sql syntax
echo "
\\copy my.xmlinput (xmldoc) from purepacked.xml
;" | psql -d databasename -h hostname -p 5432 -U dbuser
```



```sql
SET XML OPTION DOCUMENT; --CONTENT 

-- validate, true/false
SELECT	xmlparse(DOCUMENT xmldoc)
FROM my.xmlinput WHERE id=1
;

-- parse xml text to the field type xml
UPDATE my.xmlinput  SET xmldata=xmlparse(CONTENT xmldoc)
WHERE xmldata IS NULL
;
```



Example how to use **Xpath**
```sql
WITH x AS (SELECT
'<promotions>
    <promotion promotion-id="old-promotion">
        <nametext>some1</nametext>
        <enabled-flag>true</enabled-flag>
        <searchable-flag>false</searchable-flag>
    </promotion>
    <promotion promotion-id="new-promotion">
        <nametext>some2</nametext>
        <enabled-flag>false</enabled-flag>
        <searchable-flag>false</searchable-flag>
        <exclusivity>no</exclusivity>
        <price>100</price>
        <price>200</price>
        <price>300</price>
    </promotion>
</promotions>'::xml AS t
)
SELECT xpath('//@promotion-id',       node) promotion_id
      ,xpath('//enabled-flag/text()', node) enabled_flag
      ,xpath('//exclusivity/text()',  node) exclusivity
      ,xpath('//price/text()',        node) price
FROM (SELECT unnest(xpath('/promotions/promotion', t)) AS node FROM x) sub
;
```

```sql
WITH x AS (SELECT
'<promotions>
    <promotion promotion-id="old-promotion">
        <nametext>some1</nametext>
        <enabled-flag>true</enabled-flag>
        <searchable-flag>false</searchable-flag>
    </promotion>
    <promotion promotion-id="new-promotion">
        <nametext>some2</nametext>
        <enabled-flag>false</enabled-flag>
        <searchable-flag>false</searchable-flag>
        <exclusivity>no</exclusivity>
        <price>100</price>
        <price>200</price>
        <price>300</price>
    </promotion>
</promotions>'::xml AS t
)
SELECT unnest(xpath('//@promotion-id',       node)) promotion_id
      ,unnest(xpath('//enabled-flag/text()', node)) enabled_flag
      ,unnest(xpath('//exclusivity/text()',  node)) exclusivity
      ,unnest(xpath('//price/text()',        node)) price
FROM (SELECT unnest(xpath('/promotions/promotion', t)) AS node FROM x) sub
;

```

Parse xml to the table format from xmldata field:
```sql
SELECT 
       unnest(xpath('//@promotion-id',       xmldata)) keyvalue
      ,unnest(xpath('//nametext/text()',     xmldata)) "name"
      ,unnest(xpath('//enabled-flag/text()', xmldata)) enabled_flag
FROM my.xmlinput
;

```

It's normal that you need also cast field type.
Most of casting have to make using 1st text and then type what you need.
Example boolean, date, int, ...

```sql
SELECT 
       CAST(unnest(xpath('//@promotion-id',       xmldata)) AS text) keyvalue
      ,CAST(unnest(xpath('//nametext/text()',     xmldata)) AS text) "name"
      ,CAST( CAST (unnest(xpath('//enabled-flag/text()', xmldata)) AS text ) AS boolean) enabled_flag
FROM my.xmlinput
;

```

Look more functions from doc. Example  **xpath_table** is powerful function to make 
relations from xml.

