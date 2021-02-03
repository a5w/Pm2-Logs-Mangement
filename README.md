
# Pm2-Logs-Mangement
Interactive bash script to manage pm2 logs

This is a bash script to interactively check or email logs according to the date.
Update the function in the script with your smtp details.


> emailsend() {
> 
> SERVER="**smtp.gmail.com**"
> 
> USER="**Youre_Email@gmail.com**"
> 
> PASS="**Youre_PassWord**"
> 
> FROM="**Youre_Email@gmail.com**"
> 
> TO="${recipient}"
> 
> SUBJ="[${hostname}]PM2 process ${process} logs "
> 
> MESSAGE="Log File is Attached"
> 
> CHARSET="utf-8"
> 
> sendemail -f $FROM -t $TO -u $SUBJ -s $SERVER:587 -m $MESSAGE -v -o
> message-charset=$CHARSET -xu $USER -xp $PASS -a $FILE
> 
> }


## Required packages for linux

 - sendemail
 
 ## Required module for pm2
 
 - pm2-logrotate
