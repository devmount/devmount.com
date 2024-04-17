source .env

# do calculations
let YEAR=`date +%Y`
let AGE=(`date +%s`-`date +%s -d $BIRTH_DATE`)/31536000
let PROFESSION_AGE=(`date +%s`-`date +%s -d $PROFESSION_SINCE_DATE`)/31536000
let OPENSOURCE_AGE=(`date +%s`-`date +%s -d $OPENSOURCE_SINCE_DATE`)/31536000
let COPYRIGHT_YEAR=`date +%Y -d $COPYRIGHT_SINCE_DATE`

# create a new file from template
cp index.template.html index.html

# replace all markers
sed -i -e "s/{{year}}/$YEAR/g" index.html
sed -i -e "s/{{age}}/$AGE/g" index.html
sed -i -e "s/{{profession_age}}/$PROFESSION_AGE/g" index.html
sed -i -e "s/{{opensource_age}}/$OPENSOURCE_AGE/g" index.html
sed -i -e "s/{{copyright_year}}/$COPYRIGHT_YEAR/g" index.html
