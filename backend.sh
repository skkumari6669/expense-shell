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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default nodejs:18"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install nodejs"

id expense
echo "id is:: $id"
if [$? -ne 0 ]
then 
   echo -e "Expense user is not exits..$G please create $N" 
   useradd expense &>>$LOG_FILE
   VALIDATE $? "Creating expense user"
else
   echo -e "Expense user is already created ... $Y skipping $N"  
fi

mkdir -p /app
VALIDATE $? "Create /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Down load the application code to /app folder"

cd /app
rm -rf /app/* # remove the existing code
unzip /tmp/backend.zip
VALIDATE $? "Extracting backend application code"

npm install &>>$LOG_FILE
VALIDATE $? "Install npm package"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

# Load the data before running backend

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL client"

mysql -h mysql.devops81s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Load the schema"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload" 

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enable backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restart backend"













