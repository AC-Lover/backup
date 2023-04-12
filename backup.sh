#!/bin/bash

# Bot token
# گرفتن توکن ربات از کاربر و ذخیره آن در متغیر tk
while [[ -z "$tk" ]]; do
    read -p 'Bot token: ' tk
    if [[ $tk == $'\0' ]]; then
        echo "Invalid input. Token cannot be empty."
        unset tk
    fi
done

# Chat id
# گرفتن Chat ID از کاربر و ذخیره آن در متغیر chatid
while [[ -z "$chatid" ]]; do
    read -p 'Chat id: ' chatid
    if [[ $chatid == $'\0' ]]; then
        echo "Invalid input. Chat id cannot be empty."
        unset chatid
    elif [[ ! $chatid =~ ^\-?[0-9]+$ ]]; then
        echo "${chatid} is not a number."
        unset chatid
    fi
done

# Caption
# گرفتن عنوان برای فایل پشتیبان و ذخیره آن در متغیر caption
read -p 'Caption (for example, your domain, to identify the database file more easily): ' caption

# Cronjob
# تعیین زمانی برای اجرای این اسکریپت به صورت دوره‌ای
while true; do
    read -p 'Cronjob (minutes and hours) (e.g : 30 6 or 0 12) : ' minute hour
    if [[ $minute == 0 ]] && [[ $hour == 0 ]]; then
        cron_time="* * * * *"
        break
    elif [[ $minute == 0 ]] && [[ $hour =~ ^[0-9]+$ ]] && [[ $hour -lt 24 ]]; then
        cron_time="0 */${hour} * * *"
        break
    elif [[ $hour == 0 ]] && [[ $minute =~ ^[0-9]+$ ]] && [[ $minute -lt 60 ]]; then
        cron_time="*/${minute} * * * *"
        break
    elif [[ $minute =~ ^[0-9]+$ ]] && [[ $hour =~ ^[0-9]+$ ]] && [[ $hour -lt 24 ]] && [[ $minute -lt 60 ]]; then
        cron_time="*/${minute} */${hour} * * *"
        break
    else
        echo "Invalid input, please enter a valid cronjob format (minutes and hours, e.g: 0 6 or 30 12)"
    fi
done


# x-ui or marzban or hiddify
# گرفتن نوع نرم افزاری که می‌خواهیم پشتیبانی از آن بگیریم و ذخیره آن در متغیر xmh
while [[ -z "$xmh" ]]; do
    read -p 'x-ui or marzban or hiddify? [x/m/h] : ' xmh
    if [[ $xmh == $'\0' ]]; then
        echo "Invalid input. Please choose x, m or h."
        unset xmh
    elif [[ ! $xmh =~ ^[xmh]$ ]]; then
        echo "${xmh} is not a valid option. Please choose x, m or h."
        unset xmh
    fi
done

# m backup
# ساخت فایل پشتیبانی برای نرم‌افزار Marzban و ذخیره آن در فایل ac-backup.zip
if [[ "$xmh" == "m" ]]; then

if [ -d /opt/marzban ]; then
dir="/opt/marzban/*"
else
dir="/root/marzban/*"
fi


ZIP="zip -r /root/ac-backup.zip ${dir} /var/lib/marzban/*"
ACLover="marzban backup"

# x-ui backup
# ساخت فایل پشتیبانی برای نرم‌افزار X-UI و ذخیره آن در فایل ac-backup.zip
elif [[ "$xmh" == "x" ]]; then
ZIP="zip /root/ac-backup.zip /etc/x-ui/x-ui.db /usr/local/x-ui/bin/config.json"
ACLover="x-ui backup"

# hiddify backup
# ساخت فایل پشتیبانی برای نرم‌افزار Hiddify و ذخیره آن در فایل ac-backup.zip
elif [[ "$xmh" == "h" ]]; then
ZIP=$(cat <<EOF
cd /opt/hiddify-config/hiddify-panel/
python3 -m hiddifypanel backup
cd /opt/hiddify-config/hiddify-panel/backup
latest_file=\$(ls -t *.json | head -n1)
rm -f /root/ac-backup.zip
zip /root/ac-backup.zip /opt/hiddify-config/hiddify-panel/backup/\$latest_file
EOF
)
ACLover="hiddify backup"
else
echo "Please choose m or x or h only !"
exit 1
fi

export IP=$(hostname -I)
caption="${caption}\n\n${ACLover}\n<code>${IP}</code>"

# install zip
# نصب پکیج zip
sudo apt install zip -y

# send backup to telegram
# ارسال فایل پشتیبانی به تلگرام
cat >/root/ac-backup.sh <<EOL
$ZIP
curl -F chat_id="${chatid}" -F caption=\$'${caption}' -F parse_mode="HTML" -F document=@"/root/ac-backup.zip" https://api.telegram.org/bot${tk}/sendDocument
EOL


# remove cronjobs
sudo crontab -l | grep -v '/root/ac-backup.sh' | crontab -

# Add cronjob
# افزودن کرانجاب جدید برای اجرای دوره‌ای این اسکریپت
{ crontab -l -u root; echo "${cron_time} /bin/bash /root/ac-backup.sh >/dev/null 2>&1"; } | crontab -u root -

# run the script
# اجرای این اسکریپت
bash /root/ac-backup.sh

# Done
# پایان اجرای اسکریپت
echo -e "\nDone\n"
