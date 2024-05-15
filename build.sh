source .env

# constants
GH_API_URL='https://api.github.com/graphql'

# Do date calculations
let YEAR=`date +%Y`
let AGE=(`date +%s`-`date +%s -d $BIRTH_DATE`)/31556952
let PROFESSION_AGE=(`date +%s`-`date +%s -d $PROFESSION_SINCE_DATE`)/31556952
let OPENSOURCE_AGE=(`date +%s`-`date +%s -d $OPENSOURCE_SINCE_DATE`)/31556952
let COPYRIGHT_YEAR=`date +%Y -d $COPYRIGHT_SINCE_DATE`
let GH_YEAR=`date +%Y -d $OPENSOURCE_SINCE_DATE`
FINGERPRINT_PREVIEW="$(echo ${PGP_FINGERPRINT_KEYBASE: -16} | sed 's/.\{4\}/& /g')"

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

QUERY_TEMPLATE='_YEAR: contributionsCollection(from: \"YEAR-01-01T00:00:00.000Z\") { totalCommitContributions totalPullRequestReviewContributions }'
QUERY=''
for i in $(seq $GH_YEAR $YEAR); do
  QUERY="${QUERY} ${QUERY_TEMPLATE//YEAR/$i}"
done
QUERY="{viewer{${QUERY}}}"
RESULT=$(curl -s -i -H 'Content-Type: application/json' -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "{\"query\": \"query $QUERY\"}" $GH_API_URL | tail -n 1)

GH_COMMITS=$(python3 -c "import json; from functools import reduce; print(reduce(lambda a, c: a + c['totalCommitContributions'], json.loads('$RESULT')['data']['viewer'].values(), 0))")
GH_PRS_REVIEWED=$(python3 -c "import json; from functools import reduce; print(reduce(lambda a, c: a + c['totalPullRequestReviewContributions'], json.loads('$RESULT')['data']['viewer'].values(), 0))")

# Build GitHub repository stats
GH_REPOS_LIST=(${REPOS_GITHUB//,/ })
GH_REPOS_COMMITS=()
GH_REPOS_STARS=()
GH_REPOS_DESCRIPTION=()
for r in "${GH_REPOS_LIST[@]}"; do
  GH_REPOS_COMMITS+=($(curl -s -I -k -H "Authorization: bearer $GITHUB_TOKEN" "https://api.github.com/repos/$r/commits?per_page=1" | sed -n '/^[Ll]ink:/ s/.*"next".*page=\([0-9]*\).*"last".*/\1/p'))
  RESULT=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" "https://api.github.com/repos/$r" | tr -d "\n")
  GH_REPOS_STARS+=($(python3 -c "import json; print(json.loads('$RESULT')['stargazers_count'])"))
  GH_REPOS_DESCRIPTION+=("$(python3 -c "import json; print(json.loads('$RESULT')['description'])")")
done

# Build dev.to post stats
DEV_POSTS_LIST=(${POSTS_DEV//,/ })
DEV_POSTS_REACTIONS=()
DEV_POSTS_COMMENTS=()
DEV_POSTS_READING_TIME=()
for p in "${DEV_POSTS_LIST[@]}"; do
  RESULT=$(curl -s "https://dev.to/api/articles/$p")
  DEV_POSTS_REACTIONS+=($(echo $RESULT | sed -r 's|.*"positive_reactions_count":([0-9]*),.*|\1|g'))
  DEV_POSTS_COMMENTS+=($(echo $RESULT | sed -r 's|.*"comments_count":([0-9]*),.*|\1|g'))
  DEV_POSTS_READING_TIME+=($(echo $RESULT | sed -r 's|.*"reading_time_minutes":([0-9]*),.*|\1|g'))
done

# Create a new file from template
cp template.html index.html

# Update file while replacing all markers
# Replace general markers
sed -i \
  -e "s|{{user_github}}|$USER_GITHUB|g" \
  -e "s|{{user_dev}}|$USER_DEV|g" \
  -e "s|{{user_medium}}|$USER_MEDIUM|g" \
  -e "s|{{user_mastodon}}|$USER_MASTODON|g" \
  -e "s|{{user_linkedin}}|$USER_LINKEDIN|g" \
  -e "s|{{user_xing}}|$USER_XING|g" \
  -e "s|{{user_stackoverflow}}|$USER_STACKOVERFLOW|g" \
  -e "s|{{user_keybase}}|$USER_KEYBASE|g" \
  -e "s|{{user_codepen}}|$USER_CODEPEN|g" \
  -e "s|{{user_x}}|$USER_X|g" \
  -e "s|{{user_matrix}}|$USER_MATRIX|g" \
  -e "s|{{pgp_fingerprint_keybase}}|$PGP_FINGERPRINT_KEYBASE|g" \
  -e "s|{{email}}|$EMAIL|g" \
  -e "s|{{url_legal}}|$PAGE_URL_LEGAL|g" \
  -e "s|{{url_privacy}}|$PAGE_URL_PRIVACY|g" \
  -e "s|{{url_donation}}|$PAGE_URL_DONATION|g" \
  -e "s|{{url_sponsoring}}|$PAGE_URL_SPONSORING|g" \
  index.html

# Replace computed markers
sed -i \
  -e "s|{{year}}|$YEAR|g" \
  -e "s|{{age}}|$AGE|g" \
  -e "s|{{profession_age}}|$PROFESSION_AGE|g" \
  -e "s|{{opensource_age}}|$OPENSOURCE_AGE|g" \
  -e "s|{{gh_issues}}|$GH_ISSUES|g" \
  -e "s|{{gh_prs}}|$GH_PRS|g" \
  -e "s|{{gh_repos_created}}|$GH_REPOS_CREATED|g" \
  -e "s|{{gh_repos_contributed}}|$GH_REPOS_CONTRIBUTED|g" \
  -e "s|{{gh_prs_reviewed}}|$GH_PRS_REVIEWED|g" \
  -e "s|{{gh_commits}}|$GH_COMMITS|g" \
  -e "s|{{gh_stars}}|$GH_STARS|g" \
  -e "s|{{fingerprint_preview}}|$FINGERPRINT_PREVIEW|g" \
  -e "s|{{copyright_year}}|$COPYRIGHT_YEAR|g" \
  index.html

# Replace GitHub repository specific markers
for i in $(seq 1 ${#GH_REPOS_LIST[@]}); do
  sed -i \
    -e "s|{{gh_repo_${i}_commits}}|${GH_REPOS_COMMITS[((i-1))]}|g" \
    -e "s|{{gh_repo_${i}_description}}|${GH_REPOS_DESCRIPTION[((i-1))]}|g" \
    -e "s|{{gh_repo_${i}_stars}}|${GH_REPOS_STARS[((i-1))]}|g" \
    index.html
done

# Replace dev.to post specific markers
for i in $(seq 1 ${#DEV_POSTS_LIST[@]}); do
  sed -i \
    -e "s|{{dev_post_${i}_reactions}}|${DEV_POSTS_REACTIONS[((i-1))]}|g" \
    -e "s|{{dev_post_${i}_comments}}|${DEV_POSTS_COMMENTS[((i-1))]}|g" \
    -e "s|{{dev_post_${i}_reading_time}}|${DEV_POSTS_READING_TIME[((i-1))]}|g" \
    index.html
done
