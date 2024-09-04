#!/bin/bash
#/var/log/enpense/script-name-<timestamp>.log

LOGS_FOLDER="/var/log/enpense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%F-%y-%m-%d-%H-%M-%S)

LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER

# check user has root access or not

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $? -ne 0 ]
    then
       echo -e "$R please do the things with root preliviges $N" | tee -a $LOG_FILE
       exit 1
    fi
}


VALIDATE(){
    if [ $1 -ne 0 ]
    then 
       echo -e "$R $2 is ....failed $N" | tee -a $LOG_FILE
       exit 1
    else
       echo -e "$R $2 is ....success $N" | tee -a $LOG_FILE
    fi      
}

echo -e "$R Script executing started at ...$(date) $N" | tee -a $LOG_FILE

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installed MYSQL" &>>$LOG_FILE

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled MYSQL" &>>$LOG_FILE

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Started MYSQL server" &>>$LOG_FILE

mysql -h mysql.devops81s.online -uroot -pEXPENSEAPP@1 -e 'show databases;' &>>$LOG_FILE 
# -e means it shows dbs with out enter into the db
if [ $? -ne 0]
then
   echo "MYSQL root password is not set up... please set up" &>>$LOG_FILE
   mysql_secure_installation --set-root-pass ExpenseApp@1
   VALIDATE $? "root password setting up" 
else
   echo -e "$R MYSQL root password is already set....$Y skipping" | tee -a $LOG_FILE
fi




