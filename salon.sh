#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {

  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done <<< "$AVAILABLE_SERVICES"

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      SERVICE_NAME_SELECTED=$(echo $SERVICE_NAME_SELECTED | xargs)

      if [[ -z $SERVICE_NAME_SELECTED ]]
        then
          MAIN_MENU "I could not find that service. What would you like today?"
        else
          echo -e "\nWhat is your phone number?"
          read CUSTOMER_PHONE

          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)

          if [[ -z $CUSTOMER_NAME ]]
            then
              echo -e "\nI don't have a record for that phone number, what's your name?"
              read CUSTOMER_NAME
              INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          fi

          echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
          read SERVICE_TIME

          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          CUSTOMER_ID=$(echo $CUSTOMER_ID | xargs)

          INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

          echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
  fi
}

MAIN_MENU
