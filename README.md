<h1 align="left">Backup</h1>

<p align="center">
 <a href="./README.md">
 English
 </a>
 /
 <a href="./README-fa.md">
 فارسی
 </a>
</p>

###

<p align="left">With this script, you can backup important information such as database from the x-ui, marzban, and hiddify panels and send it to Telegram with the help of the Telegram bot so that it is always available!</p>

###

<br clear="both">

<p align="left">‏<br>‏</p>

###

<h1 align="left">How does it work</h1>

###

<h3 align="left">Step 1: run the script</h3>

###

<p align="left">First, you run this command on your server<br><br></p> 

```bash
bash <(curl -Ls https://github.com/AC-Lover/backup/raw/main/backup.sh)
``` 

###

<h3 align="left">Step 2 : Token setting</h3>

###

<p align="left">Then it asks us for bot token, you have to create a bot from https://t.me/BotFather and give the token</p>

###

<h3 align="left">Step 3: Set chat id</h3>

###

<p align="left">Then it asks us for a chat ID, and to get your chat ID or the channel you set aside for backup, you must forward a message from yourself or the channel to this https://t.me/userinfobot bot, which will give you a chat ID.</p>

###

<h3 align="left">Step 4 : Caption setting</h3>

###

<p align="left">The next step asks you for a caption, which you can leave blank</p>

###

<h3 align="left">Step 5 : Cronjob setting</h3>

###

<p align="left">The next step asks you to run a cron job to determine when the robot will back up and send<br>whose format is like this:<br>0 1<br>The first value, which is 0, is the minute, and the second value, which is 1, is the hour<br>The minimum number for minutes is 0 and the maximum is 60<br>The minimum number for the hour is 0 and the maximum is 24<br>Enter 0 for both to set backup once every minute<br>In the example above, it is backed up once every hour<br>Note that there is a space between both values</p>

###

<h3 align="left">Step 6 : Panel selection</h3>

###

<p align="left">The next step will ask you which panel you want to backup<br>You have to choose one from marzbn, x-ui, and hiddify <br>The value of m means marzban, the value of x means x-ui, and the value of h means hiddify <br>Enter an option between x/m/h as per your requirement</p>

###

<h3 align="left">Step 7 : question of removing previous crown jobs</h3>

###

<p align="left">Then it will ask you if you want to delete the previously defined cron jobs or not?<br>Enter y if you want it to be cleared otherwise enter n</p>

###

<h1 align="left">Possible problems</h1>

###

<p align="left">If you have entered everything correctly, the backup file should be sent to you once, otherwise there is a problem in this process and you can raise your problem from the issues</p>

###

<h1 align="left">Help us</h1>

###

<p align="left">I used the translator and if I have gramme problem please help me to improve it<br>Also, I have tested this script only on Ubuntu and developers can help us to develop this script for other operating systems.</p>

###

<h1 align="left">Donation</h1>

###

<p align="left">https://nowpayments.io/donation/ACLover</p>

###

<h1 align="left">Video tutorial</h1>

https://github.com/AC-Lover/backup/assets/49290111/905c545c-caa9-4ad5-80d1-82c702fb3f2e


## Stargazers over time

[![Stargazers over time](https://starchart.cc/AC-Lover/backup.svg)](https://starchart.cc/AC-Lover/backup)

