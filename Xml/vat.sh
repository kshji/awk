#!/usr/local/bin/awsh
# vat.sh
# - check VAT code, VAT code validity
#  vat.sh -c FI -n 17802552
#  vat.sh -v FI17802552
#  vat.sh -v FI17802552 -o csv
#  vat.sh -v FI17802552 -o xml
#  vat.sh -v FI17802552 -o list
#
# Jukka Inkeri 2019-05-15
#
# http://ec.europa.eu/taxation_customs/vies/?locale=fi
# http://ec.europa.eu/taxation_customs/vies/technicalInformation.html
# http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl

PRG=$0
BINDIR="${PRG%/*}"
[ "$PRG" = "$BINDIR" ] && BINDIR="." # - same dir as program
PRG="${PRG##*/}"

mkdir -p tmp 2>/dev/null
chmod 1777 tmp 2>/dev/null


########################################################
usage()
{
	echo "usage:$PRG -n nro -m country | -v vatkoodi [ -o csv|list|xml -d 0|1 ]" >&2
}

########################################################
country=FI
vat=""
vatnr=""
url="http://ec.europa.eu/taxation_customs/vies/services/checkVatService"
debug=0
outputformat=csv  # list

while [ $# -gt 0 ]
do
	arg="$1"
	case "$arg" in
		-d) debug="$2"; shift ;;
		-v) vat="$2"
			country=${vat:0:2}
			vatnr=${vat:2}
			shift 
			;;
		-c) country="$2"; shift ;;
		-n) vatnr="$2"; shift ;;
		-o) outputformat="$2" ; shift ;;
		-*) usage ; exit 1 ;;
		*) break ;;
	esac
	shift
done

((debug>0)) && echo "$country - $vatnr - $vat" >&2

outf="tmp/$$.out.vat.xml"
inf="tmp/$$.in.vat.xml"
varf="tmp/$$.var.vat.xml"

# SOAP template
cat <<XML > $inf
<s11:Envelope xmlns:s11='http://schemas.xmlsoap.org/soap/envelope/'>
  <s11:Body>
    <tns1:checkVat xmlns:tns1='urn:ec.europa.eu:taxud:vies:services:checkVat:types'>
      <tns1:countryCode>$country</tns1:countryCode>
      <tns1:vatNumber>$vatnr</tns1:vatNumber>
    </tns1:checkVat>
  </s11:Body>
</s11:Envelope>
XML


flags="-q -S"

((debug>0)) && cat "$inf" >&2

wget   $flags -O "$outf"  --no-check-certificate \
        --header "Content-Type: text/xml; charset=UTF-8" \
        --post-file $inf \
        "$url" 2>/dev/null

((debug>0)) && cat "$outf" >&2
((debug>0)) && xmllint --format "$outf" >&2




((debug>0 )) && echo "___________________________________________________________"

awk  '
	BEGIN {
    	RS="<"
    	FS=">"
    	OFS="="
    	out=0
    	}
  /checkVatResponse/ { 	# printout only checkVatResponse sublements
			out++
			next
			}
  out != 1 { next  }
  $1 ~ /^\// { next }
  NF < 2	{ next }
  #NF == 2	&& ($1 == "requestDate" || $1 == "valid" || $1 == "vatNumber" || $1 == "address" || $1 == "name" || $1 == "countryCode" ) { 
  NF == 2 {
		printf "%s=\"%s\"\n", $1,$2
		}
  ' "$outf" > "$varf"

((debug>0)) && cat $varf
. "$varf"

lf=$'\x0a'
# convert newlines to comma
address=${address//$lf/,}

case "$outputformat" in
	csv)
		echo "valid|vat|name|requestDate|address" 
		echo "$valid|$countryCode$vatNumber|$name|$requestDate|$address" 
		;;
	xml) 
		xmllint --format "$outf"
		;;
	*)
		cat "$varf"
		;;
esac

# default ok, valid true
ok=0
[ "$valid" != "true" ] && ok=2

((debug<1)) && rm -f "$outf" "$inf" "$varf" 2>/dev/null

# remove over 5 days old tmp files 
find tmp -maxdepth 1 -name "*.xml" -mtime +5 -delete 2>/dev/null

exit $ok

