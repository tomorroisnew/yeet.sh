echo $1

#setup
mkdir $1
cd $1

#MAKE A PASSIVE FOLDER AND SAVE OUTPUT THERE
mkdir passive
cd passive

amass enum --passive -d $1 -o amass.txt &
#amass enum -passive -d $1 -o amass.txt -r 8.8.8.8 &
subfinder -d $1 -all -o subfinder.txt &
assetfinder $1 -subs-only | grep -v '*' | tee assetfinder.txt &
curl -s https://crt.sh/?q=$1 | grep $1 | cut -d ">" -f2 | cut -d "<" -f 1 | sort -u | tee crt.txt &
sublist3r -d $1 -o sublister.txt &

wait

cd ../
cat passive/* | sort -u > passiveoutputs.txt

cat passiveoutputs.txt | httpx -no-color -o passiveoutputx.txt

cat passiveoutputx.txt | cut -d "/" -f 3 > passiveoutput.txt 

#altdns
altdns -i passiveoutput.txt -o altdns1.txt -w ~/tools/altdns/words.txt

#massdns
~/tools/massdns/bin/massdns -r ~/tools/massdns/lists/resolvers.txt -t A -o S altdns1.txt -w lmao.txt
#parsemassdns
sed 's/A.*//' lmao.txt | sed 's/CN.*//' | sed 's/\..$//' | sort -u > massdns1.txt

cat massdns1.txt passiveoutput.txt| sort -u | grep $1 | httpx -title -status-code -o final.txt -location -content-length -no-color
#rm -rf lmao.txt altdns1.txt
mkdir trash
mv lmao.txt altdns1.txt massdns1.txt passiveoutputx.txt passiveoutputs.txt trash

echo done
