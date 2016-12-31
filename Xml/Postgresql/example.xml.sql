
CREATE SCHEMA my;

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

SET XML OPTION DOCUMENT; --CONTENT 

-- validate, true/false
SELECT  xmlparse(DOCUMENT xmldoc)
FROM my.xmlinput WHERE id=1
;

-- parse xml text to the field type xml
UPDATE my.xmlinput  SET xmldata=xmlparse(CONTENT xmldoc)
WHERE xmldata IS NULL
;


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

SELECT 
       unnest(xpath('//@promotion-id',       xmldata)) keyvalue
      ,unnest(xpath('//nametext/text()',     xmldata)) "name"
      ,unnest(xpath('//enabled-flag/text()', xmldata)) enabled_flag
FROM my.xmlinput
;


SELECT 
       CAST(unnest(xpath('//@promotion-id',       xmldata)) AS text) keyvalue
      ,CAST(unnest(xpath('//nametext/text()',     xmldata)) AS text) "name"
      ,CAST( CAST (unnest(xpath('//enabled-flag/text()', xmldata)) AS text ) AS boolean) enabled_flag
FROM my.xmlinput
;
