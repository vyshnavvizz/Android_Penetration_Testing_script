
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'


echo -e "$OKRED Unpacking APK file..."
echo -e "$OKRED=====================================================================$RESET"
unzip $PWD/$1 -d $PWD/$1-unzipped/
baksmali d $PWD/$1-unzipped/classes.dex -o $PWD/$1-unzipped/classes.dex.out/


echo -e "$OKRED Converting APK to Java JAR file..."
echo -e "$OKRED=====================================================================$RESET"
d2j-dex2jar $PWD/$1 -o $PWD/$1.jar --force

echo -e "$OKRED Decompiling using Jadx..."
echo -e "$OKRED=====================================================================$RESET"
jadx $PWD/$1 -d $PWD/$1-jadx/

echo -e "$OKRED Unpacking using APKTool..."
echo -e "$OKRED=====================================================================$RESET"
apktool d $PWD/$1 -o $PWD/$1-unpacked/ -f


echo -e "$OKRED Displaying AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
cat $PWD/$1-unpacked/AndroidManifest.xml

echo -e "$OKRED Displaying Package Info in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'package=' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Activities in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'activity ' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Services in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'service ' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Content Providers in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'provider' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Broadcast Receivers in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'receiver' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Intent Filter Actions in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'action|category' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Permissions in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'android.permission' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Exports in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'exported="true"' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null

echo -e "$OKRED Displaying Backups in AndroidManifest.xml..."
echo -e "$OKRED=====================================================================$RESET"
egrep -i 'backup' $PWD/$1-unpacked/AndroidManifest.xml --color=auto 2>/dev/null



################## INTENT REFERENCES

echo -e "$OKRED Searching for android.intent references..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH 'android\.intent' $a --color=auto 2>/dev/null; done;

################# COMMAND EXECUTION REFERENCES

echo -e "$OKRED Searching for command execution references... Hardening"
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH 'Runtime.getRuntime\(\).exec' $a --color=auto 2>/dev/null; done;

################# SQLITE REFERENCES

echo -e "$OKRED Searching for SQLiteDatabase references..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH 'SQLiteDatabase' $a --color=auto 2>/dev/null; done;



################# CONTENT PROVIDERS

echo -e "$OKRED Displaying content providers..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH 'content:://' $a --color=auto 2>/dev/null; done;

################# BROADCAST RECEIVERS

echo -e "$OKRED Searching for sendBroadcast references..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH 'sendBroadcast' $a --color=auto 2>/dev/null; done;



################# FILE REFERENCES



echo -e "$OKRED Searching for getSharedPreferences references..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH getSharedPreferences $a --color=auto 2>/dev/null; done;




################# HARDCODED Sensitive Strings

echo -e "$OKRED Searching for hardcoded Strings..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -inH 'secret|password|username' $a --color=auto 2>/dev/null; done;

echo -e "$OKRED Searching for sensitive information..."
echo -e "$OKRED=====================================================================$RESET"
strings $PWD/$1 | egrep -i 'user|pass|key|login|pwd|log' --color=auto  2>/dev/null
strings $PWD/$1 > $PWD/$1-strings.txt



################# SSL REFERENCES

echo -e "$OKRED Searching for client certificates..."
echo -e "$OKRED=====================================================================$RESET"
find $PWD/$1-unzipped/ | egrep '\.pkcs|\.p12|\.cer|\.der' --color=auto 2>/dev/null

echo -e "$OKRED Searching for SSL certificate pinning..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH getCertificatePinningSSL $a --color=auto 2>/dev/null; done;

echo -e "$OKRED Searching for SSL connections..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH 'ssl\.SSL' $a --color=auto 2>/dev/null; done;

python 3.py `find $PWD/$1-jadx`

echo -e "$OKRED Searching for DeviceId references..."
echo -e "$OKRED=====================================================================$RESET"
for a in `find $PWD/$1-jadx | egrep -i .java`; do egrep -nH 'getDeviceId' $a --color=auto 2>/dev/null; done;


echo -e "$OKRED DONE!"
echo -e "$OKRED=====================================================================$RESET"
