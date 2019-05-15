<?php
$countryCode='FI';
$vatNo='17802552';

$client = new SoapClient("http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl");
var_dump($client->checkVat(array(
  'countryCode' => $countryCode,
  'vatNumber' => $vatNo
)));


?>
