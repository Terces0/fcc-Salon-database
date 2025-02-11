#! /bin/bash
psql="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"
echo -e "\n *-*-* RAF's SALON *-*-* \n"

main(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  avl_services=$($psql "select service_id, name from services order by service_id")
  if [[ -z $avl_services ]]
  then
    echo "Unfortunately, there are no available services for now"
  else
    echo "$avl_services" | while IFS='|' read -r service_id name
    do
        echo "$service_id) $name"
    done
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      main "Incorrect input, try again"
    else
      services_available=$($psql "select service_id from services where service_id = $SERVICE_ID_SELECTED")
      service_name=$($psql "select name from services where service_id = $SERVICE_ID_SELECTED")
      if [[ -z $services_available ]]
      then 
        main "The inputted service couldn't be found, try again"
      else
        echo -e "\nInput phone number: "
        read CUSTOMER_PHONE
        customer_name=$($psql "select name from customers where phone = '$CUSTOMER_PHONE'")
        if [[ -z $customer_name ]]
        then 
          echo -e "\nNo name found, input name: "
          read CUSTOMER_NAME
          name_input=$($psql "insert into customers (phone, name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        else
          CUSTOMER_NAME=$customer_name
        fi
        echo -e "\nInput appointment time for $service_name: "
        read SERVICE_TIME
        customer_id=$($psql "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
        if [[ $SERVICE_TIME ]]
        then
          total_customer_inputs=$($psql "insert into appointments (customer_id,service_id,time) values ($customer_id,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
          if [[ $total_customer_inputs ]]
          then 
            echo -e "\nI have put you down for a $service_name at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
        fi
      fi
    fi
  fi
}

main

