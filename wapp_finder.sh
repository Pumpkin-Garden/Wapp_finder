cat << "EOF"
__        __   _   _____         _                 _                       _____ _           _           
\ \      / /__| |_|_   _|__  ___| |__  _ __   ___ | | ___   __ _ _   _    |  ___(_)_ __   __| | ___ _ __ 
 \ \ /\ / / _ \ '_ \| |/ _ \/ __| '_ \| '_ \ / _ \| |/ _ \ / _` | | | |   | |_  | | '_ \ / _` |/ _ \ '__|
  \ V  V /  __/ |_) | |  __/ (__| | | | | | | (_) | | (_) | (_| | |_| |   |  _| | | | | | (_| |  __/ |   
   \_/\_/ \___|_.__/|_|\___|\___|_| |_|_| |_|\___/|_|\___/ \__, |\__, |   |_|   |_|_| |_|\__,_|\___|_|   
                                                           |___/ |___/                                   

EOF

<<'###Description'
I was inspired by the quality of web technology discovery by the Wappalyzer app. 
What you are looking at now is a simple wrapper to scan a large list of web servers 
  with JSON parsing for further viewing in Excel.
###Description

# For color printing
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

wappalyzer=""   # path to wappalyzer cli.js

if [[ $1 == "-h" || -z $wappalyzer ]]
then
  echo "Description:"
  echo -e "\tThe output of the script will be ${YELLOW}printed and saved to${NC} the file ${YELLOW}found_technologies.txt${NC}"
  echo -e "\tSpecify the list of ${YELLOW}targets for scanning in${NC} the ${YELLOW}hosts.txt${NC} file\n"
  
  echo "Requirements:"
  echo -e "\t Set the wappalyzer variable ${YELLOW}(line 23)${NC}\n"
  
  echo "Examples:"
  echo -e "\t./wapp_finder.sh" 
  echo -e "\t./wapp_finder.sh -h\n"
  exit  
fi

echo "URL|Technologies count|Name|Description|Confidence|Version|CPE|Categories" > found_technologies.txt
echo -e "URL \t\t\t\t${YELLOW}Name${NC}\t\tConfidence\t${YELLOW}Version${NC}\t\tCategories"

while read url
do
  node $wappalyzer -e -r -p full -w 90000 -a "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36" $url > data_json
  technologies_count=`cat data_json | jq ".technologies[].name" | wc -l`
  i=0
  while [[ $i -ne $technologies_count ]]
  do
    technologies_name=`cat data_json | jq -r ".technologies[$i].name"`
    technologies_description=`cat data_json | jq -r ".technologies[$i].description"`
    technologies_confidence=`cat data_json | jq -r ".technologies[$i].confidence"`
    technologies_version=`cat data_json | jq -r ".technologies[$i].version"`
    technologies_cpe=`cat data_json | jq -r ".technologies[$i].cpe"`
    technologies_categories=`cat data_json | jq -r ".technologies[$i].categories[].name" | tr "\n" ";"`
    let i++
    echo "$url|$technologies_count|$technologies_name|$technologies_description|$technologies_confidence|$technologies_version|$technologies_cpe|$technologies_categories" >> found_technologies.txt
    echo -e "$url\t${YELLOW}$technologies_name${NC}\t\t$technologies_confidence\t${YELLOW}$technologies_version${NC}\t$technologies_categories"
  done
done < hosts.txt

echo -e "\nDetailed result saved to file ${YELLOW}found_technologies.txt${NC}"
rm data_json
