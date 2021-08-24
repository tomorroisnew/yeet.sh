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

cat passiveoutputs.txt | httpx -no-color -o final.txt -title -status-code -location -content-length 

echo done
