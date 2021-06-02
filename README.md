# Cosaint

Cosaint (defence in Irish) is a collection of simple scripts to scrub files of any meta data, compress them and encrypt them. These scripts are suitable for running on individual files or as a service that automatically runs on specific folders/files. Cosaint is useful for protecting your files before you store them on a public cloud or any server you don't own.


## Dependancies
* gpg
* mat2
* inotify-tools


## Known Issues
SystemD service runs with root user so it doesn't have access to your gpg keys. One way around this is to setup another key for root user.
The SystemD service may also fail since password isn't provided so the --passphrase flag needs to be added as an option to the Cosaint script at some point.


## Setting up

This repo contains three shell scripts and a SystemD service file that runs the scripts automatically. The base cosaint.sh script can be used as a CLI and the two cosaint_monitoring and monitor_exif scripts are used by the SystemD service to automatically run the cosaint script. First thing you'll need to do is clone the Repo.

```
git clone https://github.com/CoogyEoin/Cosaint.git
```

Encrypting/Compressing a file can be preformed using the "encrypt" action flag, the file and the email associated with the recipients GPG key. An optional directory can be specified if you want to sync the file, otherwise it'll be kept locally.

```
cosaint -a encrypt -f <File you want encrypted> -e <Email of recipient gpg key> -d <Directory to sync to> 
```

Alternatively the "clean" action can be specified to just remove metadata of file or directory or the "all" action to perform both cleaning and encrypting.


To set up the SystemD service and perform all this automatically you'll need to copy the shell scripts into your **/usr/local/bin/** directory so they can be ran and the cosaint.service file into your **/etc/systemd/system** file so SystemD can run it.
Alternatively you can move the glanadh.service file to it if you just want to perform metadata removal automatically.

```
cp cosaint.sh /usr/local/bin/
cp cosaint_monitor.sh /usr/local/bin/
cp cosaint.service /etc/systemd/system/
```

Edit cosaint.service fike and **put the directory and email you want to monitor as flags**. It won't work otherwise. Then just enable and start the service and you should be good to go.

```
systemctl daemon-reload
systemctl enable cosaint
systemctl start cosaint
```

If all goes well then every time you add a new file to the specified directory the EXIF data will be removed, the file will be compressed and encrypted and the file will be synced to the sync directory specified. This works well if you use Nextcloud or some other cloud service as you can sync your local files with the cloud folder. 


Stay happy and stay private.
