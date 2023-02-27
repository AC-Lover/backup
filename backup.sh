read -p 'Bot token: ' tk
read -p 'Chat id: ' chatid
if [[ ! $chatid =~ ^\-?[0-9]+$ ]]; then
   echo "${chatid} is not a number."
   exit 1
fi
read -p 'Caption (for example, your domain, to identify the database file more easily): ' caption
read -p 'Cronjob (only hours are supported ) (e.g : 6) : ' cron
if [[ ! $cron =~ ^[0-9]+$ ]]; then
   echo "${cron} is not a number."
   exit 1
fi
read -p 'x-ui or marzban? [x/m] : ' xm


if [[ "$xm" == "m" || "$xm" == "M" ]]; then
ZIP="zip -r /root/ac-backup.zip /root/marzban/* /var/lib/marzban/*"
ACLover="marzban backup"
elif [[ "$xm" == "x" || "$xm" == "X" ]]; then
ZIP="zip /root/ac-backup.zip /etc/x-ui/x-ui.db /usr/local/x-ui/bin/config.json"
ACLover="x-ui backup"
else
echo "Please choose m or x only !"
exit 1
fi

export IP=$(hostname -I)
caption="${caption}\n\n${ACLover}\n<code>${IP}</code>"

sudo apt install zip -y
sudo apt install curl -y

cat >/root/ac-backup.sh <<EOL
$ZIP
curl -F chat_id="${chatid}" -F caption=\$'${caption}' -F parse_mode="HTML" -F document=@"/root/ac-backup.zip" https://api.telegram.org/bot${tk}/sendDocument
EOL

{ crontab -l -u root; echo "0 */${cron} * * * /bin/bash /root/ac-backup.sh >/dev/null 2>&1"; } | crontab -u root -
bash /root/ac-backup.sh
echo "\nDone"
