#!/bin/bash
#/var/log/enpense/script-name-<timestamp>.log

LOGFOLDER="/var/log/enpense"
SCRIPTNAME="$(echo $0 | cut -d "." -f1 )
TIMESTAMP="$(date +%F-%y-%m-%d-%H-%M-%S)

LOGFILE="$LOGFOLDER/$SCRIPTNAME/$TIMESTAMP.log"

# check user has root access or not

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $? -ne 0 ]
    then
       echo -e "$R please do the things with root preliviges $N" | tee -a $LOGFILE
       exit 1
    fi
}

CHECK_ROOT

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
       echo -e "$R $2 is ....failed $N" | tee -a $LOGFILE
       exit 1
    else
       echo -e "$R $2 is ....success $N" | tee -a $LOGFILE
    fi      
}

echo -e "$R Script executing started at ...$(date) $N" | tee -a $LOGFILE


dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installed MYSQL" &>>$LOGFILE

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabled MYSQL" &>>$LOGFILE

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Started MYSQL server" &>>$LOGFILE

mysql -h mysql.devops81s.online -uroot -pEXPENSEAPP@1 -e 'show databases;' &>>$LOGFILE 
# -e means it shows dbs with out enter into the db
if [ $? -ne 0]
then
   echo "MYSQL root password is not set up... please set up" &>>$LOGFILE
   mysql_secure_installation --set-root-pass ExpenseApp@1
   VALIDATE $? "root password setting up" 
else
   echo -e "$R MYSQL root password is already set....$Y skipping" | tee -a $LogFILE
fi




