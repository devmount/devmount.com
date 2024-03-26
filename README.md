# devmount.com

Do you remember the days when websites consisted of just 3 files or less? One for server-side scripts (or markup only), one for client-side scripts and one for styles. While I think that the use of frameworks and a lot of build steps is absolutely necessary for certain use cases, I believe that they can be total overkill for smaller projects.

This is why I decided to build my personal portfolio website the old-fashioned way. You can find it on <https://devmount.com>.

## Get started

This projects has two independent parts: **Retrieving the data** and **serving the website**. No further dependencies, complicated build steps or additional services required. In addition to the obvious static information, this website also contains some dynamic data retrieved from different locations (like code stats from GitHub). I created an `update.sh` script, which basically does all the work like collecting the data and inserting it into the static html. This not only keeps the site very fast, it also gives you the freedom to carry out updates at the desired time from the desired location. You could e.g. run it via a cronjob or just use GitHub actions or just call it manually if you don't need any automation at all.

1. Create a `.env` file from the corresponding example file and modify its values

   ```bash
   cp .env.example .env
   vim .env
   ```

2. Modify the `index.template` file to your needs. You can use all entries existing in `.env` as template markers, e.g. `{{name}}`
3. Run `./update.sh` manually or setup any automation to run this file
4. Serve the website by putting the files anywhere you want and calling the generated `index.html` or pointing your web server to the containing directory.

## Final thoughts

This is basically a tiny static site generator and I know there are already great solutions out there. But sometimes, you just want to stay dependency free, keep things simple and and at the same time running longterm without having to worry about them.
