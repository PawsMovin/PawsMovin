## Installation (Easy mode - For development environments)

### Prerequisites

 * Latest version of Docker ([download](https://docs.docker.com/get-docker)).
 * Latest version of Docker Compose ([download](https://docs.docker.com/compose/install))
 * Git ([download](https://git-scm.com/downloads))

 If you are on Windows Docker Compose is already included, you do not need to install it yourself.
 If you are on Linux/MacOS you can probably use your package manager.

### Installation

1. Download and install the [prerequisites](#prerequisites).
2. Clone the repo with `git clone https://github.com/PawsMovin/PawsMovin.git`.
3. `cd` into the repo.
4. Copy the sample environment file with `cp .env.sample .env`.
5. Run the following commands:
    ```
    docker compose run --rm -e SEED_POST_COUNT=100 pawsmovin /app/bin/setup
    docker compose run --rm reports /app/bin/setup
    docker compose up
    ```
    After running the commands once only `docker compose up` is needed to bring up the containers.
6. To confirm the installation worked, open the web browser of your choice and enter `http://localhost:3001` into the address bar and see if the website loads correctly. Create an account via http://localhost:3001/users/new. The first created user will automatically be promoted to the "Owner" level.

Note: When gems or js packages are updated you need to execute `docker compose build` to reflect them in the container.

#### <a id="docker-troubleshooting"></a>I followed the above instructions but it doesn't work, what should I do?

Try this:

1. `docker compose down -v` to remove all volumes.
2. `docker compose build --no-cache` to rebuild the image from scratch.
3. Follow the [instructions](#installation) starting from step 5.

#### <a id="windows-executable-bit"></a>Why are there a bunch of changes I can't revert?

You're most likely using Windows. Give this a shot, it tells Git to stop tracking file mode changes:

`git config core.fileMode false`

#### <a id="development-tools"></a>Things to aid you during development

`docker compose run --rm tests` to execute the test suite.

`docker compose run --rm rubocop` to run the linter.

The postgres server accepts outside connections which you can use to access it with a local client. Use `localhost:34518` to connect to a database named `pawsmovin_development` with the user `pawsmovin`. Leave the password blank, anything will work.

## Production Setup

Installation follows the same steps as the docker compose file. Ubuntu 20.04 is the current installation target.
There is no script that performs these steps for you, as you need to split them up to match your infrastructure.
Running a single machine install in production is possible, but is likely to be somewhat sluggish due to contention in disk between postgresql and opensearch.
Minimum RAM is 4GB. You will need to adjust values in config files to match how much RAM is available.
If you are targeting more than a hundred thousand posts and reasonable user volumes, you probably want to procure yourself a database server. See tuning guides for postgresql and opensearch for help planning these requirements.

### Help & Wiki Pages
These wik/help pages are expected to exist, as they are linked to in various places.
#### Wiki Pages
* help:accounts
* help:api
* help:artists
* help:blacklist
* help:cheatsheat
* help:comments
* help:contact
* help:dmails
* help:flag_notice
* help:forums
* help:global_blacklist
* help:home
* help:notes
* help:pools
* help:post_relationships
* help:posts
* help:privacy_policy
* help:replacement_notice
* help:sets
* help:tag_aliases
* help:tag_implications
* help:tagging_checklist
* help:tags
* help:takedown
* help:takedown_verification
* help:terms_of_service
* help:upload
* help:upload_whitelist
* help:uploading_guidelines
* help:user_name_change_requests
* help:user_settings
* help:wiki
* internal:rules_body

#### Help Pages
* accounts (help:accounts)
* api (help:api)
* artists (help:artists)
* blacklist (help:blacklist)
* cheatsheet (help:cheatsheet)
* comments (help:comments)
* dmails (help:dmails)
* forums (help:forums)
* global_blacklist (help:global_blacklist)
* notes (help:notes)
* pools (help:pools)
* post_relationships (help:post_relationships)
* posts (help:posts)
* privacy_policy (help:privacy_policy)
* sets (help:sets)
* tag_aliases (help:tag_aliases)
* tag_implications (help:tag_implications)
* tagging_checklist (help:tagging_checklist)
* tags (help:tags)
* terms_of_service (help:terms_of_service)
* upload (help:upload)
* upload_whitelist (help:upload_whitelist)
* uploading_guidelines (help:uploading_guidelines)
* user_name_change_requests (help:user_name_change_requests)
* user_settings (help:user_settings)
* wiki (help:wiki)

### Production Troubleshooting

These instructions won't work for everyone. If your setup is not
working, here are the steps I usually recommend to people:

1) Test the database. Make sure you can connect to it using psql. Make
sure the tables exist. If this fails, you need to work on correctly
installing PostgreSQL, importing the initial schema, and running the
migrations.

2) Test the Rails database connection by using rails console. Run
Post.count to make sure Rails can connect to the database. If this
fails, you need to make sure your configuration files are
correct.

3) Test Nginx to make sure it's working correctly.  You may need to
debug your Nginx configuration file.

4) Check all log files.

### Recommender
To have recommendations, a user must have at least 50 favorites. A post must have at least 5 favorites to have recommendations.
There are some scripts in `db/seeds` to generate both users and favorites.

To train the model, simply run:
`docker compose run --rm recommender python -m poetry run python train`
