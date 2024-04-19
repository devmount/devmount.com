source .env

# constants
GH_API_URL='https://api.github.com/graphql'

# Do date calculations
let YEAR=`date +%Y`
let AGE=(`date +%s`-`date +%s -d $BIRTH_DATE`)/31536000
let PROFESSION_AGE=(`date +%s`-`date +%s -d $PROFESSION_SINCE_DATE`)/31536000
let OPENSOURCE_AGE=(`date +%s`-`date +%s -d $OPENSOURCE_SINCE_DATE`)/31536000
let COPYRIGHT_YEAR=`date +%Y -d $COPYRIGHT_SINCE_DATE`
let GH_YEAR=`date +%Y -d $OPENSOURCE_SINCE_DATE`

# Build GitHub general stats
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
RESULT=$(curl -s -i -H 'Content-Type: application/json' -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "{\"query\": \"query $QUERY\"}" $GH_API_URL | tail -n 1)

GH_ISSUES=$(python3 -c "import json; print(json.loads('$RESULT')['data']['viewer']['issues']['totalCount'])")
GH_PRS=$(python3 -c "import json; print(json.loads('$RESULT')['data']['viewer']['pullRequests']['totalCount'])")
GH_REPOS_CREATED=$(python3 -c "import json; print(len(json.loads('$RESULT')['data']['viewer']['repositories']['nodes']))")
GH_REPOS_CONTRIBUTED=$(python3 -c "import json; print(json.loads('$RESULT')['data']['viewer']['repositoriesContributedTo']['totalCount'])")
GH_STARS=$(python3 -c "import json; from functools import reduce; print(reduce(lambda a, c: a + c['stargazers']['totalCount'], json.loads('$RESULT')['data']['viewer']['repositories']['nodes'], 0))")

COMMIT_QUERY_TEMPLATE='_YEAR: contributionsCollection(from: \"YEAR-01-01T00:00:00.000Z\") { totalCommitContributions }'
REVIEW_QUERY_TEMPLATE='_YEAR: contributionsCollection(from: \"YEAR-01-01T00:00:00.000Z\") { totalPullRequestReviewContributions }'
COMMIT_QUERY=''
REVIEW_QUERY=''
for i in $(seq $GH_YEAR $YEAR);
do
  COMMIT_YEAR="${COMMIT_QUERY_TEMPLATE//YEAR/$i}"
  COMMIT_QUERY="${COMMIT_QUERY} ${COMMIT_YEAR}"
  REVIEW_YEAR="${REVIEW_QUERY_TEMPLATE//YEAR/$i}"
  REVIEW_QUERY="${REVIEW_QUERY} ${REVIEW_YEAR}"
done
COMMIT_QUERY="{viewer{${COMMIT_QUERY}}}"
REVIEW_QUERY="{viewer{${REVIEW_QUERY}}}"
COMMIT_RESULT=$(curl -s -i -H 'Content-Type: application/json' -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "{\"query\": \"query $COMMIT_QUERY\"}" $GH_API_URL | tail -n 1)
REVIEW_RESULT=$(curl -s -i -H 'Content-Type: application/json' -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "{\"query\": \"query $REVIEW_QUERY\"}" $GH_API_URL | tail -n 1)

GH_COMMITS=$(python3 -c "import json; from functools import reduce; print(reduce(lambda a, c: a + c['totalCommitContributions'], json.loads('$COMMIT_RESULT')['data']['viewer'].values(), 0))")
GH_PRS_REVIEWED=$(python3 -c "import json; from functools import reduce; print(reduce(lambda a, c: a + c['totalPullRequestReviewContributions'], json.loads('$REVIEW_RESULT')['data']['viewer'].values(), 0))")


# Create a new file from template
cp index.template.html index.html

# Update file while replacing all markers
sed -i \
  -e "s/{{year}}/$YEAR/g"\
  -e "s/{{age}}/$AGE/g"\
  -e "s/{{profession_age}}/$PROFESSION_AGE/g"\
  -e "s/{{opensource_age}}/$OPENSOURCE_AGE/g"\
  -e "s/{{gh_issues}}/$GH_ISSUES/g"\
  -e "s/{{gh_prs}}/$GH_PRS/g"\
  -e "s/{{gh_repos_created}}/$GH_REPOS_CREATED/g"\
  -e "s/{{gh_repos_contributed}}/$GH_REPOS_CONTRIBUTED/g"\
  -e "s/{{gh_prs_reviewed}}/$GH_PRS_REVIEWED/g"\
  -e "s/{{gh_commits}}/$GH_COMMITS/g"\
  -e "s/{{gh_stars}}/$GH_STARS/g"\
  -e "s/{{copyright_year}}/$COPYRIGHT_YEAR/g" index.html
