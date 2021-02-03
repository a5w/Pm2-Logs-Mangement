#!/bin/bash

logs='/home/web/.pm2/logs'
email_folder='~/.pm2/.emails_list'
email_file=${email_folder}/list.txt
hostname=$(hostname)

emailsend() {

SERVER="smtp.gmail.com"
USER="Your_Email@gmail.com"
PASS="Your_PassWord"
FROM="Your_Email@gmail.com"
TO="${recipient}"
SUBJ="[${hostname}]PM2 process ${process} logs "
MESSAGE="Log File is Attached"
CHARSET="utf-8"
sendemail -f $FROM -t $TO -u $SUBJ -s $SERVER:587 -m $MESSAGE -v -o message-charset=$CHARSET -xu $USER -xp $PASS -a $FILE

}

email_list() {
  if [[ ! -d ${email_folder} ]]; then
    mkdir -p ${email_folder}
  fi

  if [[ ! -f ${email_file} ]]; then
    touch ${email_file}
  fi

 email() {
      if [[ ${1} == 'add' ]]; then
        declare -a emails_list=$(cat "${email_file}")
        read -p "Please enter new eMail: " new_email
        if cat ${email_file} | grep "^${new_email}" ; then
          echo "eMail already exists"
          break 1
        else
          echo "${new_email}" >> "${email_file}"
          echo "email added"
          declare -a emails_list=$(cat "${email_file}")
          break 1
        fi
      elif [[ ${1} == 'delete' ]]; then
        while true; do
        declare -a emails_list=$(cat "${email_file}")
        emails_list=("ALL" ${emails_list[@]})
        PS3='Please Select an eMail to delete: '
        select email in ${emails_list[@]}
        do
          if [[ ${email} == "ALL" ]]; then
            rm ${email_file}
            touch ${email_file}
            echo "All emails deleted"
            break 3
          else
            sed -i "/${email}/d" ${email_file}
            echo "email ${email} deleted"
            break 3
          fi
        done
      done
      fi
    }

while true; do
  declare -a emails_list=$(cat "${email_file}")
  if [[ -z ${emails_list} ]]; then
    echo '+--------------------------------------+'
    echo '| No Email found, Please Add new email |'
    echo '+--------------------------------------+'
  fi
    options=("Add-eMail" "Delete-eMail" "All" ${emails_list[@]})
    PS3='Please Select: '
    select option in ${options[@]}
    do
      if [[ ${option} == "Add-eMail" ]]; then
        email add
      elif [[ ${option} == "Delete-eMail" ]]; then
        email delete
      elif [[ ${option} == "All" ]]; then
        unset -v 'options[0]'
        unset -v 'options[1]'
        unset -v 'options[2]'
        recipient=${options[@]}
        echo "email sent to ${recipient[@]}"
        ${1}
        break 2
      else
        recipient=${option}
        ${1}
        echo "email sent to ${recipient}"
        break 2
      fi
    done
  done
}

logs_file() {
  process_list=$(ls ${logs} | sort | awk -F__ '{print $1}' | awk -F. '{print $1}' | uniq)
  PS3='Please select the process: '
  select process in ${process_list[@]}
   do
    log_files=$(ls ${logs}/${process}* | awk -F__ '{print $2}' | awk -F. '{print $1}'| sort -r)
    PS3='Please select the date: '
    logs_files=("TODAY" ${log_files[@]})
    select log in ${logs_files[@]}
      do
        if [[ ${log} == 'TODAY' ]]; then
          FILE=${logs}/${process}.log
          if [[ ! -z ${1} ]]; then
          ${1} ${FILE}
          break
        else
          break
          fi
        else
          FILE=${logs}/${process}__${log}.log
          if [[ ! -z ${1} ]]; then
          ${1} ${FILE}
          break
          else
            break
          fi
        fi
      done
      break
  done
}

main_menu() {
PS3='Would you like to email or view logs?: '
options=("View" "eMail" "Exit")
select option in ${options[@]}
do
  if [[ ${option} == "View" ]]; then
    logs_file "less"
    break
  elif [[ ${option} == "eMail" ]];then
    logs_file
    email_list emailsend
    break
  elif [[ ${option} == "View-&-eMail" ]];then
    logs_file
    email_list emailsend
    logs_file "less"
    break
  elif [[ ${option} == "Exit" ]]; then
    exit 1
  fi
done
}
 while true;
 do
main_menu
if [[ ${option} == "Exit" ]]; then
  exit 1
fi
done
