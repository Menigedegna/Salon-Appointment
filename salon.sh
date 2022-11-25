#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do 
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
}

CUSTOMER_INFO(){
  #ask phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if not found
  if [[ -z $CUSTOMER_ID ]]
  then
    #ask customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #insert new customer
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    #get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    #get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  #get service name
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #select appointment
  echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME
  #insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')") 
  #display result
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
#if correct service is selected
if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ && $SERVICE_ID_SELECTED -ge 1 && $SERVICE_ID_SELECTED -le 3 ]]
then 
  CUSTOMER_INFO
else
  MAIN_MENU "I could not find that service. What would you like today?"
fi
