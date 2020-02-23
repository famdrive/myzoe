#!/bin/bash

# https://muscatoxblog.blogspot.com/2019/07/delving-into-renaults-new-api.html

#source ../incl
source credentials

function jsonGet {
	 var=$1
	  json=$2

	   echo $(echo $json|perl -pe 's/^.*?"'$var'":.*?"(.*?)".*$/$1/g')

   }

 function jsonGetH {
	  var=$1
          json=$2

	    echo $json|perl -pe 's/^.*?"'$var'":.*?{(.*?)}.*$/$1/g'
    }

  function  getZoe {
	  echo "$1: "
     echo $( curl -s "$kamereon_rooturl/commerce/v1/accounts/kmr/remote-services/car-adapter/v1/cars/$VID/$1" -H "x-gigya-id_token: $id_token" -H  "apikey: $kamereon_apikey" -H "x-kamereon-authorization: Bearer $accessToken" )
}



url1=$(curl -s -s https://renault-wrd-prod-1-euw1-myrapp-one.s3-eu-west-1.amazonaws.com/configuration/android/config_fr_$country.json)

apiKey=$( jsonGet apikey "$(jsonGetH gigyaProd "$url1")" )
kamereon=$( jsonGetH wiredProd "$url1" )
kamereon_apikey=$( jsonGet  apikey "$kamereon" )
kamereon_rooturl=$( jsonGet  target "$kamereon" )

#echo "$kamereon-rooturl"

cookie=$(curl -s  "https://accounts.eu1.gigya.com/accounts.login" -d "ApiKey=${apiKey}&loginID=${user}&password=${password}" )
cookie=$( jsonGetH sessionInfo "$cookie"  )
cookie=$( jsonGet cookieValue "$cookie" )

personID=$( curl -s  "https://accounts.eu1.gigya.com/accounts.getAccountInfo" -d "oauth_token=${cookie}" ) 
data=$( echo $personID |tr -d '\r')
data=$( jsonGetH data "$data"  )
personID=$( jsonGet personId "$data"  )
gigyaDataCenter=$( jsonGet gigyaDataCenter "$data"  )

id_token=$(curl -s  "https://accounts.eu1.gigya.com/accounts.getJWT?oauth_token=$cookie&fields=data.personId,data.gigyaDataCenter&expiration=900")
id_token=$( jsonGet id_token "$id_token"  )

kamereon_accounts=$( curl -s  "$kamereon_rooturl/commerce/v1/persons/$personID?country=$country" -H "x-gigya-id_token: $id_token" -H  "apikey: $kamereon_apikey"  ) 
kamereon_accounts=$( jsonGetH accounts "$kamereon_accounts" )
kamereon_accounts=$( jsonGet accountId "$kamereon_accounts" )

accessToken=$( curl -s "$kamereon_rooturl/commerce/v1/accounts/$kamereon_accounts/kamereon/token?country=$country" -H "x-gigya-id_token: $id_token" -H  "apikey: $kamereon_apikey" )
accessToken=$( jsonGet accessToken "$accessToken" )

echo $kamereon_rooturl


getZoe battery-inhibition-status

getZoe lock-status

getZoe battery-status

getZoe hvac-status

getZoe charge-mode

getZoe cockpit

getZoe location

getZoe

