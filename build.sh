source .env

# Do calculations
let YEAR=`date +%Y`
let AGE=(`date +%s`-`date +%s -d $BIRTH_DATE`)/31536000
let PROFESSION_AGE=(`date +%s`-`date +%s -d $PROFESSION_SINCE_DATE`)/31536000
let OPENSOURCE_AGE=(`date +%s`-`date +%s -d $OPENSOURCE_SINCE_DATE`)/31536000
let COPYRIGHT_YEAR=`date +%Y -d $COPYRIGHT_SINCE_DATE`

# Build GitHub stats
QUERY='{
  viewer {
    issues { totalCount }
    pullRequests { totalCount }
    gists(first: 100) {
      totalCount
      nodes { stargazers { totalCount } }
    }
    repositories(affiliations: OWNER, isFork: false, first: 100) {
      totalCount
      nodes { stargazers { totalCount } }
    }
    repositoriesContributedTo { totalCount }
  }
}'
QUERY="$(echo $QUERY)"
RESULT=$(curl -s -i -H 'Content-Type: application/json' -H "Authorization: bearer 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" -X POST -d "{\"query\": \"query $QUERY\"}" https://api.github.com/graphql | tail -n 1)

GH_ISSUES=$(python3 -c "import json; print(json.loads('$RESULT')['data']['viewer']['issues']['totalCount'])")
GH_PRS=$(python3 -c "import json; print(json.loads('$RESULT')['data']['viewer']['pullRequests']['totalCount'])")
GH_REPOS_CONTRIBUTED=$(python3 -c "import json; print(json.loads('$RESULT')['data']['viewer']['repositoriesContributedTo']['totalCount'])")

# Create a new file from template
cp index.template.html index.html

# Update file while replacing all markers
sed -i -e "s/{{year}}/$YEAR/g" index.html
sed -i -e "s/{{age}}/$AGE/g" index.html
sed -i -e "s/{{profession_age}}/$PROFESSION_AGE/g" index.html
sed -i -e "s/{{opensource_age}}/$OPENSOURCE_AGE/g" index.html
sed -i -e "s/{{gh_issues}}/$GH_ISSUES/g" index.html
sed -i -e "s/{{gh_prs}}/$GH_PRS/g" index.html
sed -i -e "s/{{gh_repos_contributed}}/$GH_REPOS_CONTRIBUTED/g" index.html
sed -i -e "s/{{copyright_year}}/$COPYRIGHT_YEAR/g" index.html
