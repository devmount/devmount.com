# devmount.com

Do you remember the days when websites consisted of just 3 files or less? One for server-side scripts (or markup only), one for client-side scripts and one for styles. While I think that the use of frameworks and a lot of build steps is absolutely necessary for certain use cases, I believe that they can be total overkill for smaller projects.

This is why I decided to build my personal portfolio website the old-fashioned way. You can find it on <https://devmount.com>.

I created this for my website, but you know I love FOSS so you can totally use this repo as template for your own page.

<img src="https://github.com/devmount/devmount.com/assets/5441654/1dcc0249-d97a-41d0-a6d6-ec3319e5601a" width="50%" alt="screencast of devmount.com website appearance" />

## Get started

This projects has two independent parts: **Retrieving the data** and **serving the website**. No further dependencies, complicated build steps or additional services required. In addition to the obvious static information, this website also contains some dynamic data retrieved from different locations (like repository or user stats from GitHub or posts stats from dev.to). I created a `build.sh` script, which basically does all the work like collecting the data and inserting it into the static html. This not only keeps the site very fast, it also gives you the freedom to carry out updates at the desired time on the desired location. You could e.g. run it via a cronjob or just use GitHub actions or just call it manually if you don't need any automation at all.

1. Create a `.env` file from the corresponding example file and modify its values

   ```bash
   cp .env.example .env
   ```

2. Modify the `template.html` file to your needs. You can use template variables which are based on the `.env` entries, in format `{{var_name}}` (see all available template variables in the table below). Make sure to fill in all ENV vars that are a requirement for the template variables you use.
3. Run `./build.sh` manually or setup any automation to run this file (like cron or GitHub actions). It creates an `index.html` file from the template with all variables replaced. Keep in mind that there are API call limits.
4. Serve the website by putting the files anywhere you want and calling the generated `index.html` or pointing your web server to the containing directory

## Template variables

You can use the following template variables:

| Template variable               | Description                                                   | Required ENV var          |
|---------------------------------|---------------------------------------------------------------|---------------------------|
| `{{user_github}}`               | Your GitHub username                                          | `USER_GITHUB`             |
| `{{user_dev}}`                  | Your dev.to username                                          | `USER_DEV`                |
| `{{user_medium}}`               | Your Medium username                                          | `USER_MEDIUM`             |
| `{{user_mastodon}}`             | Your MAstodon server/@username                                | `USER_MASTODON`           |
| `{{user_linkedin}}`             | Your LinkedIn username                                        | `USER_LINKEDIN`           |
| `{{user_xing}}`                 | Your Xing username                                            | `USER_XING`               |
| `{{user_stackoverflow}}`        | Your StackOverflow username                                   | `USER_STACKOVERFLOW`      |
| `{{user_keybase}}`              | Your Keybase username                                         | `USER_KEYBASE`            |
| `{{user_codepen}}`              | Your Codepen username                                         | `USER_CODEPEN`            |
| `{{user_x}}`                    | Your X username                                               | `USER_X`                  |
| `{{user_matrix}}`               | Your Matrix @username:server                                  | `USER_MATRIX`             |
| `{{pgp_fingerprint_keybase}}`   | The fingerprint of your PGP Key                               | `PGP_FINGERPRINT_KEYBASE` |
| `{{fingerprint_preview}}`       | The last 16 chars of your PGP Key                             | `PGP_FINGERPRINT_KEYBASE` |
| `{{email}}`                     | Your contact email address                                    | `EMAIL`                   |
| `{{url_legal}}`                 | URL to your legal page                                        | `PAGE_URL_LEGAL`          |
| `{{url_privacy}}`               | URL to your privacy page                                      | `PAGE_URL_PRIVACY`        |
| `{{url_donation}}`              | URL to your donations page                                    | `PAGE_URL_DONATION`       |
| `{{url_sponsoring}}`            | URL to your sponsoring page                                   | `PAGE_URL_SPONSORING`     |
| `{{year}}`                      | The current year                                              |                           |
| `{{age}}`                       | Your age in years                                             | `BIRTH_DATE`              |
| `{{profession_age}}`            | The age of your business in years                             | `PROFESSION_SINCE_DATE`   |
| `{{opensource_age}}`            | The age of your OS activities in years                        | `OPENSOURCE_SINCE_DATE`   |
| `{{copyright_year}}`            | The age of your website in years                              | `COPYRIGHT_SINCE_DATE`    |
| `{{gh_issues}}`                 | The number of GitHub issues you created                       | `GITHUB_TOKEN`            |
| `{{gh_prs}}`                    | The number of GitHub PRs you created                          | `GITHUB_TOKEN`            |
| `{{gh_repos_created}}`          | The number of GitHub repositories you created (without forks) | `GITHUB_TOKEN`            |
| `{{gh_repos_contributed}}`      | The number of foreign GitHub repositories you contributed to  | `GITHUB_TOKEN`            |
| `{{gh_prs_reviewed}}`           | The number of GitHub PRs you reviewd                          | `GITHUB_TOKEN`            |
| `{{gh_commits}}`                | The number of commits you did on GitHub                       | `GITHUB_TOKEN`            |
| `{{gh_stars}}`                  | The number of stars you received on GitHub repositories       | `GITHUB_TOKEN`            |
| `{{gh_repo_N_commits}}`         | The number of commits of GitHub repository `N`\*              | `REPOS_GITHUB`            |
| `{{gh_repo_N_description}}`     | The description of GitHub repository `N`\*                    | `REPOS_GITHUB`            |
| `{{gh_repo_N_stars}}`           | The number of stars of GitHub repository `N`\*                | `REPOS_GITHUB`            |
| `{{dev_post_N_reactions}}`      | The number of positive reactions to DEV post `N`\*            | `POSTS_DEV`               |
| `{{dev_post_N_comments}}`       | The number of comments on DEV post `N`\*                      | `POSTS_DEV`               |
| `{{dev_post_N_reading_time}}`   | The reading time in minutes of DEV post `N`\*                 | `POSTS_DEV`               |

\* Replace `N` with the position of the repository/post in the configured list, beginning with 1. Example: `{{gh_repo_2_description}}` will be replaced with the description of the second repository given in `REPOS_GITHUB` ENV var.

## Final thoughts

This is basically a tiny static site generator and I know there are already great solutions out there. But sometimes, you just want to stay dependency free, keep things simple and and at the same time up-to-date and running longterm without having to worry about them.

## Licence

This project is licensed under [MIT License](./LICENSE). Feel free to use it for your next little static website.
