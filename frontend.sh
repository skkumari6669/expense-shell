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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Remove the default content in html folder"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Download the application code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "Extract the frontend content"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense conf"

systemctl restart nginx
VALIDATE $? "Restart nginx"




