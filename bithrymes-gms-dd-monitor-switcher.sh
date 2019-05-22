#!/usr/bin/env bash
read -r -p "Select server-1, bingo-gms to activate " A
#read -r -p "Select server-2, bingo-gms to activate " B

if [[ -z "$A" ]]; then
   printf '%s\n' "No server-1 input entered, re-run bash to activate required gms-server"
   exit 
else
read -r -p "Select server-2, bingo-gms to activate " B
fi
if [[ -z "$B" ]]; then
   printf '%s\n' "No server-2 input entered, re-run bash to activate required gms-server"
   exit 
else

diff(){
  awk 'BEGIN{RS=ORS=" "}
       {NR==FNR?a[$0]++:a[$0]--}
       END{for(k in a)if(a[k])print k}' <(echo -n "${!1}") <(echo -n "${!2}")
}
Array1=(1 2 4 5 6)
Array2=($A $B)
Array3=($(diff Array1[@] Array2[@]))
echo Servers to be excluded bingo-gms-${Array3[@]}

#Current unix timestamp
test=$(date '+%s')
#Unix Timestamp after 15 minutes
timestamp=$((test + 950))

rm -rf terraform.tfstate terraform.tfstate.backup

#initialise Terraform
terraform init

#Importing old Monitor ID
if which jq >/dev/null; then
    echo jq already installed
else
    echo jq does not exist,installing
sudo apt-get install jq -y
fi

cdiff=$(curl -G "https://api.datadoghq.com/api/v1/monitor" \
        -d "api_key=Put datadog api key" \
        -d "application_key=Put datadog app key" \
	| jq -r '.[] | .name, .id' | awk '{ print $1 }'  | paste - - -d = | grep -E '902TF' | sed -r 's/^.{6}//')

sfsc=$(curl -G "https://api.datadoghq.com/api/v1/monitor" \
        -d "api_key=Put datadog api key" \
        -d "application_key=Put datadog app key" \
	| jq -r '.[] | .name, .id' | awk '{ print $1 }'  | paste - - -d = | grep -E '601TF' | sed -r 's/^.{6}//')

echo 902 Alert Number Old ID "$cdiff"
echo 601 Alert Number Old ID "$sfsc"

terraform import datadog_monitor.sfsconnectionmonitor $sfsc
terraform import datadog_monitor.connectiondifference $cdiff

#Destroying Old Monitor
terraform destroy -auto-approve -var test1="1" -var server1="1" -var server2="1" -var server3="1" -var server4="1" -var server5="1"

#Creating Alerts
terraform apply -auto-approve -var test1="$timestamp" -var server1="$A" -var server2="$B" -var server3="${Array3[0]}" -var server4="${Array3[1]}" -var server5="${Array3[2]}"

fi
