<?php
DEFINE ( 'VIES_URL', 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService' );

/**
 * VIES VAT number validation
 *
 * @author Eugen Mihailescu
 *        
 * @param string $countryCode           
 * @param string $vatNumber         
 * @param int $timeout          
 */
function viesCheckVAT($countryCode, $vatNumber, $timeout = 30) {
    $response = array ();
    $pattern = '/<(%s).*?>([\s\S]*)<\/\1/';
    $keys = array (
            'countryCode',
            'vatNumber',
            'requestDate',
            'valid',
            'name',
            'address' 
    );

    $content = "<s11:Envelope xmlns:s11='http://schemas.xmlsoap.org/soap/envelope/'>
  <s11:Body>
    <tns1:checkVat xmlns:tns1='urn:ec.europa.eu:taxud:vies:services:checkVat:types'>
      <tns1:countryCode>%s</tns1:countryCode>
      <tns1:vatNumber>%s</tns1:vatNumber>
    </tns1:checkVat>
  </s11:Body>
</s11:Envelope>";

    $opts = array (
            'http' => array (
                    'method' => 'POST',
                    'header' => "Content-Type: text/xml; charset=utf-8; SOAPAction: checkVatService",
                    'content' => sprintf ( $content, $countryCode, $vatNumber ),
                    'timeout' => $timeout 
            ) 
    );

    $ctx = stream_context_create ( $opts );
    $result = file_get_contents ( VIES_URL, false, $ctx );

    if (preg_match ( sprintf ( $pattern, 'checkVatResponse' ), $result, $matches )) {
        foreach ( $keys as $key )
            preg_match ( sprintf ( $pattern, $key ), $matches [2], $value ) && $response [$key] = $value [2];
    }
    return $response;
}

print_r ( viesCheckVAT ( 'FI', '17802552' ) );
?>
