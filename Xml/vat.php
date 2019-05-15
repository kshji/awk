<?php
$country1 = 'FI';
$country2 = 'FI';
$vatnum1 = '17355879';
$vatnum2 = '17802552';

//Prepare the URL
$url = 'http://ec.europa.eu/taxation_customs/vies/viesquer.do?ms='.$country1.'&iso='.$country1.'&vat='.$vatnum1.'&name=&companyType=&street1=&postcode=&city=&requesterMs='.$country2.'&requesterIso='.$country2.'&requesterVat='.$vatnum2.'&BtnSubmitVat=Verify';

$response = file_get_contents($url);
// Do sth with the response
echo $response;

?>
