#!/bin/bash


while [[ -z "$tk" ]]; do
    echo "Bot token: "
    read -r tk
    if [[ $tk == $'\0' ]]; then
        echo "Invalid input. Token cannot be empty."
        unset tk
    fi
done


while [[ -z "$chatid" ]]; do
    echo "Chat id: "
    read -r chatid
    if [[ $chatid == $'\0' ]]; then
        echo "Invalid input. Chat id cannot be empty."
        unset chatid
    elif [[ ! $chatid =~ ^\-?[0-9]+$ ]]; then
        echo "${chatid} is not a number."
        unset chatid
    fi
done


echo "Caption (for example, your domain, to identify the database file more easily): "
read -r caption


while true; do
    echo "Cronjob (minutes and hours) (e.g : 30 6 or 0 12) : "
    read -r minute hour
    if [[ $minute == 0 ]] && [[ $hour == 0 ]]; then
        cron_time="0 0 * * *"
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



while [[ -z "$xmhsp" ]]; do
    echo "x-ui or s-ui or marzban or hiddify or pasarguard? [x/s/m/h/p] : "
    read -r xmhsp
    if [[ $xmhsp == $'\0' ]]; then
        echo "Invalid input. Please choose x, s, m, h or p."
        unset xmhsp
    elif [[ ! $xmhsp =~ ^[xmhsp]$ ]]; then
        echo "${xmhsp} is not a valid option. Please choose x, s, m, h or p."
        unset xmhsp
    fi
done

while [[ -z "$crontabs" ]]; do
    echo "Would you like the previous crontabs to be cleared? [y/n] : "
    read -r crontabs
    if [[ $crontabs == $'\0' ]]; then
        echo "Invalid input. Please choose y or n."
        unset crontabs
    elif [[ ! $crontabs =~ ^[yn]$ ]]; then
        echo "${crontabs} is not a valid option. Please choose y or n."
        unset crontabs
    fi
done

if [[ "$crontabs" == "y" ]]; then
sudo crontab -l | grep -vE '/root/ac-backup.+\.sh' | crontab -
fi


if [[ "$xmhsp" == "m" ]]; then

if dir=$(find /opt /root -type d -iname "marzban" -print -quit); then
  echo "The folder exists at $dir"
else
  echo "The folder does not exist."
  exit 1
fi

if [ -d "/var/lib/marzban/mysql" ] || [ -d "/var/lib/mysql/marzban" ]; then

path=""

if [ -d "/var/lib/marzban/mysql" ]; then
  path="/var/lib/marzban/mysql"
elif [ -d "/var/lib/mysql/marzban" ]; then
  path="/var/lib/mysql/marzban"
else
  echo "Neither path exists."
  exit 1
fi

  sed -i -e 's/\s*=\s*/=/' -e 's/\s*:\s*/:/' -e 's/^\s*//' /opt/marzban/.env

  docker exec marzban-mysql-1 bash -c "mkdir -p /var/lib/mysql/db-backup"
  source /opt/marzban/.env

    cat > "$path/ac-backup.sh" <<EOL
#!/bin/bash

USER="root"
PASSWORD="$MYSQL_ROOT_PASSWORD"


databases=\$(mysql -h 127.0.0.1 --user=\$USER --password=\$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

for db in \$databases; do
    if [[ "\$db" != "information_schema" ]] && [[ "\$db" != "mysql" ]] && [[ "\$db" != "performance_schema" ]] && [[ "\$db" != "sys" ]] ; then
        echo "Dumping database: \$db"
		mysqldump -h 127.0.0.1 --force --opt --user=\$USER --password=\$PASSWORD  --routines --databases \$db > /var/lib/mysql/db-backup/\$db.sql

    fi
done

EOL
chmod +x "$path/ac-backup.sh"

ZIP=$(cat <<EOF

docker exec marzban-mysql-1 bash -c "/var/lib/mysql/ac-backup.sh"
zip -r /root/ac-backup-m.zip /opt/marzban/* /var/lib/marzban/* /opt/marzban/.env -x $path/\*
zip -r /root/ac-backup-m.zip $path/db-backup/*
rm -rf "$path/db-backup/*"
EOF
)

    else
      ZIP="zip -r /root/ac-backup-m.zip ${dir}/* /var/lib/marzban/* /opt/marzban/.env"
fi

ACLover="marzban backup"

elif [[ "$xmhsp" == "x" || "$xmhsp" == "s" ]]; then

ACLover=""
dbDir=$(find /etc /opt/freedom /usr/local \
           -type d \( -iname "x-ui*" -o -iname "s-ui" \) \
           -print -quit 2>/dev/null)

if [[ -n "${dbDir}" ]]; then
  echo "The folder exists at $dbDir"
  if [[ $dbDir == "/opt/freedom/x-ui"* ]]; then
    dbDir="${dbDir}/db/x-ui.db"
    ACLover="x-ui backup"
  elif [[ $dbDir == "/usr/local/s-ui" ]]; then
    dbDir="${dbDir}/db/s-ui.db" 
    ACLover="s-ui backup"
  else
    dbDir="${dbDir}/x-ui.db"
    ACLover="x-ui backup"
  fi
else
  echo "The folder does not exist."
  exit 1
fi

configDir=$(find /usr/local -type d -iname "x-ui*" -print -quit 2>/dev/null)
if [[ -n "${configDir}" ]]; then
  echo "The folder exists at $configDir"
  configDir="${configDir}/config.json"
else
  configDir=""
fi

ZIP="zip /root/ac-backup-${xmhsp}.zip ${dbDir} ${configDir}"


elif [[ "$xmhsp" == "h" ]]; then

if ! find /opt/hiddify-manager/hiddify-panel/ -type d -iname "backup" -print -quit; then
  echo "The folder does not exist."
  exit 1
fi

if [ -f "/opt/hiddify-manager/hiddify-panel/backup.sh" ]; then
  backupCommand="bash backup.sh"
else
backupCommand="python3 -m hiddifypanel backup"
fi


ZIP=$(cat <<EOF

cd /opt/hiddify-manager/hiddify-panel/
if [ $(find /opt/hiddify-manager/hiddify-panel/backup -type f | wc -l) -gt 100 ]; then
  find /opt/hiddify-manager/hiddify-panel/backup -type f -delete
fi

$backupCommand

cd /opt/hiddify-manager/hiddify-panel/backup
latest_file=\$(ls -t *.json | head -n1)
rm -f /root/ac-backup-h.zip
zip /root/ac-backup-h.zip /opt/hiddify-manager/hiddify-panel/backup/\$latest_file

EOF
)
ACLover="hiddify backup"

elif [[ "$xmhsp" == "p" ]]; then

if dir=$(find /opt /root -type d \( -iname "pasarguard" -o -iname "pasargad" \) -print -quit 2>/dev/null); then
  echo "The folder exists at $dir"
else
  echo "The folder does not exist."
  exit 1
fi

if [ -f "/usr/local/bin/pasarguard" ]; then
  backupCommand="/usr/local/bin/pasarguard backup"
elif command -v pasarguard >/dev/null 2>&1; then
  backupCommand="pasarguard backup"
elif [ -f "${dir}/pasarguard.sh" ]; then
  backupCommand="bash ${dir}/pasarguard.sh backup"
else
  backupCommand=""
fi

ZIP=$(cat <<EOF

if [ -n "$backupCommand" ]; then
  $backupCommand
  latest_file=\$(ls -t ${dir}/backup/*.zip 2>/dev/null | head -n1)
fi

if [ -n "\$latest_file" ]; then
  cp "\$latest_file" /root/ac-backup-p.zip
else
  zip -r /root/ac-backup-p.zip ${dir}/* /var/lib/pasarguard/* ${dir}/.env -x "${dir}/backup/*" 2>/dev/null
fi

EOF
)
ACLover="pasarguard backup"

else
echo "Please choose m or x or s or h or p only !"
exit 1
fi


trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

IP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
caption="${caption}\n\n${ACLover}\n<code>${IP}</code>\nCreated by @AC_LoverBot - https://github.com/AC-Lover/backup"
comment=$(echo -e "$caption" | sed 's/<code>//g;s/<\/code>//g')
comment=$(trim "$comment")


sudo apt install zip -y

cat > "/root/ac-backup-${xmhsp}.sh" <<EOL
#!/bin/bash

rm -f /root/ac-backup-${xmhsp}.zip
$ZIP
echo -e "$comment" | zip -z /root/ac-backup-${xmhsp}.zip
curl -F chat_id="${chatid}" -F caption=\$'${caption}' -F parse_mode="HTML" -F document=@"/root/ac-backup-${xmhsp}.zip" https://api.telegram.org/bot${tk}/sendDocument
EOL



{ crontab -l -u root; echo "${cron_time} /bin/bash /root/ac-backup-${xmhsp}.sh >/dev/null 2>&1"; } | crontab -u root -


bash "/root/ac-backup-${xmhsp}.sh"

echo -e "\nDone\n"
