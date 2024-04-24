#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Scheduler ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "Services available:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY 1;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  # prompt for service to schedule
  echo -e "\nWhich service would you like to schedule?"
  read SERVICE_ID_SELECTED
  # if service not exist or not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # redisplay main menu
    MAIN_MENU "That is not an available service."
  else
    SCHEDULE_MENU
  fi
}

GET_TIME() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWhat time would you like to schedule for?"
  read SERVICE_TIME
  # if [[ ! $SCHEDULE_TIME =~ ^[0-1][0-9]:[0-5][0-9]$ || $SCHEDULE_TIME =~ ^[2][0-3]:[0-5][0-9]$ ]]
  if [[ -z $SERVICE_TIME ]]
  then
    GET_TIME "Please enter a valid time as 'HH:MM'"
  fi
}

SCHEDULE_MENU() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //')
  echo -e "\nLet's schedule your $SERVICE_NAME_FORMATTED."
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_ID ]]
  then
    # create new customer
    echo -e "\nLooks like this is your first time with us. Please enter your name:"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //')
    echo -e "\nWelcome back $CUSTOMER_NAME!"
  fi

  GET_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME');")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU


