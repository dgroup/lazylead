[![Versions](https://img.shields.io/badge/semver-2.0-green)](https://semver.org/spec/v2.0.0.html)
[![Gem Version](https://badge.fury.io/rb/lazylead.svg)](https://rubygems.org/gems/lazylead)
[![Downloads](https://ruby-gem-downloads-badge.herokuapp.com/lazylead?type=total)](https://rubygems.org/gems/lazylead)
[![](https://img.shields.io/docker/pulls/dgroup/lazylead.svg)](https://hub.docker.com/r/dgroup/lazylead "Image pulls")
[![](https://images.microbadger.com/badges/image/dgroup/lazylead.svg)](https://microbadger.com/images/dgroup/lazylead "Image layers")
[![](https://images.microbadger.com/badges/version/dgroup/lazylead.svg)](https://microbadger.com/images/dgroup/lazylead "Image version")
[![Commit activity](https://img.shields.io/github/commit-activity/y/dgroup/lazylead.svg?style=flat-square)](https://github.com/dgroup/lazylead/graphs/commit-activity)
[![Hits-of-Code](https://hitsofcode.com/github/dgroup/lazylead)](https://hitsofcode.com/view/github/dgroup/lazylead)
[![License: MIT](https://img.shields.io/github/license/mashape/apistatus.svg)](./license.txt)

[![Build status circleci](https://circleci.com/gh/dgroup/lazylead.svg?style=shield)](https://circleci.com/gh/dgroup/lazylead)
[![0pdd](http://www.0pdd.com/svg?name=dgroup/lazylead)](http://www.0pdd.com/p?name=dgroup/lazylead)
[![Dependency Status](https://requires.io/github/dgroup/lazylead/requirements.svg?branch=master)](https://requires.io/github/dgroup/lazylead/requirements/?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/e873a41b1c76d7b2d6ae/maintainability)](https://codeclimate.com/github/dgroup/lazylead/maintainability)

[![DevOps By Rultor.com](http://www.rultor.com/b/dgroup/lazylead)](http://www.rultor.com/p/dgroup/lazylead)
[![EO badge](http://www.elegantobjects.org/badge.svg)](http://www.elegantobjects.org/#principles)

### Overview
Ticketing systems (Github, Jira, etc.) are strongly integrated into our processes and everyone understands their necessity. As soon as a developer becomes a lead/technical manager, he or she faces a set of routine tasks that are related to ticketing work. On large projects this becomes a problem, more and more you spend time running around on dashboards and tickets, looking for incorrect deviations in tickets and performing routine tasks instead of solving technical problems.

The idea of automatic management is not new, for example [Zerocracy](https://www.zerocracy.com/) is available on the market. 
I like this idea, but large companies/projects are not ready yet for such a decisive breakthrough and need step-by-step solutions such as [lazylead](https://github.com/dgroup/lazylead). 
I think you remember how [static code analysis](https://en.wikipedia.org/wiki/Static_program_analysis) treated at in the past; today we have a huge toolkit (pmd, checkstyle, qulice, rubocop, etc) for each language that allows you to avoid routine/known issues and remove from the code reviewer the unnecessary load.
 
Join our [telegram group](https://t.me/lazyleads) for discussions.

| Daily annoying task                                                    | Jira               | Github      | Trello      |
| :--------------------------------------------------------------------- | :----------------: | :---------: | :---------: |
| [Notify ticket's assignee](lib/lazylead/task/alert.rb)                 | :white_check_mark: | :hourglass: | :hourglass: |
| [Notify ticket's reporter](lib/lazylead/task/alert.rb)                 | :white_check_mark: | :hourglass: | :hourglass: |
| [Notify ticket's manager](lib/lazylead/task/alert.rb)                  | :white_check_mark: | :hourglass: | :hourglass: |
| [Notify about illegal "Fix Version" modification](lib/lazylead/task/fix_version.rb)                        | :white_check_mark: | :x:         | :x:         | 
| [Expected comment in ticket is missing](lib/lazylead/task/missing_comment.rb)                                  | :white_check_mark: | :hourglass: | :hourglass: |
| Propagate some fields from parent ticket into sub-tasks                | :hourglass:        | :x:         | :x:         |  
| Print the current capacity of team into newly created tasks            | :hourglass:        | :hourglass: | :hourglass: |  
| Create/retrofit the defect automatically into latest release           | :hourglass:        | :hourglass: | :x:         |  
| Notify about expired(ing) due dates                                    | :hourglass:        | :hourglass: | :hourglass: |
| Notify about absent original estimations                               | :hourglass:        | :hourglass: | :hourglass: |
| Notify about 'Hot potato' tickets                                      | :hourglass:        | :hourglass: | :hourglass: |
| Notify about long live tickets (aging)                                 | :hourglass:        | :hourglass: | :hourglass: |
| Notify about tickets with invalid format (missing url/stacktrace, etc) | :hourglass:        | :hourglass: | :hourglass: |
| Create a meeting(s) automatically in case some tickets appeared (group by assignee/reporters/component/ticket type/etc) | :hourglass: | :hourglass: | :hourglass: |

:white_check_mark: - implemented, :hourglass: - planned, :x: - not supported by ticketing system.

| Integration                                           | Type          | Status             |
| :---------------------------------------------------- | :-----------: | :----------------: |
| [Microsoft Exchange Server](lib/lazylead/exchange.rb) | Emails        | :white_check_mark: |
| [Microsoft Exchange Server](lib/lazylead/exchange.rb) | Calendar      | :hourglass:        |
| [mail.yandex.ru](lib/lazylead/postman.rb)             | Emails        | :white_check_mark: |
| [mail.google.ru](lib/lazylead/postman.rb)             | Emails        | :cactus:           |
| slack                                                 | Notifications | :hourglass:        |

:white_check_mark: - implemented, :hourglass: - planned, :cactus: - implemented, but not tested.

New ideas, bugs, suggestions or questions are welcome [via GitHub issues](https://github.com/dgroup/lazylead/issues/new)!

### Get started
:warning: We're still in a very early alpha version, the API may change frequently until we release version 1.0.

Let's assume that:
- your team is using jira as a ticketing system
- you defined a jira filter with tickets where actions need. The filter id is `555` and it has JQL like `project=XXXX and type=Bug and status not in (Closed, Cancelled, "Ready For Testing", "On Hold) and parent = YYYY and duedate < startOfDay()`
- you have `MS Exchange` server for email notifications
- you want to notify your developers during working days at `8am (UTC)` time about tickets where due dates are expired

For simplicity, we are using [docker-compose](https://docs.docker.com/compose/):
1. Define yml file with configuration [tasks.yml](.github/tasks.yml):
    ```yml
    version: '2.3'
    services:
    
      lazylead:
        image: dgroup/lazylead:latest
        container_name: lazylead
        mem_limit: 128m
        environment:
          # The jira server details.
          # Please ensure that your jira filter(s) grants this user to see issues.
          # Sometimes jira filter(s) may be created with restricted visibility, thus
          #  lazylead can't find the issues. 
          jira_url: https://your.jira.com
          jira_user: theuser
          jira_password: thepass
          # The MS Exchange server details, please ensure that '/ews/Exchange.asm` 
          #  will be after your server url. Just change the url to your server.
          exchange_url: https://your.ms.exchange.server/ews/Exchange.asmx
          exchange_user: theuser
          exchange_password: the password
        volumes:
          - ./:/lazylead/db
        # db/ll.db is sqlite file with jira related annoying tasks
        entrypoint: bin/lazylead --sqlite db/ll.db --trace --verbose
   ```
   or just download the project using git
   ```bash
   git clone https://github.com/dgroup/lazylead.git ll && cd ll && pwd && ls -lah
   ```
2. Create a container, using `docker-compose -f .github/tasks.yml up`
   The container will stop as there were no tasks provided:
   ```bash
   ll > docker-compose -f .github/tasks.yml up                                                                                                           100% 🔋  13:35:04
   Creating lazylead ... done
   Attaching to lazylead
   lazylead    | [2020-06-06T10:35:13] DEBUG Memory footprint at start is 52MB
   lazylead    | [2020-06-06T10:35:13] DEBUG Database: '/lazylead/db/ll.db', sql migration dir: '/lazylead/upgrades/sqlite'
   lazylead    | [2020-06-06T10:35:13] DEBUG Migration applied to /lazylead/db/ll.db from /lazylead/upgrades/sqlite
   lazylead    | [2020-06-06T10:35:13] DEBUG Database connection established
   lazylead    | [2020-06-06T10:35:13] WARN  SMTP connection enabled in test mode.
   lazylead    | [2020-06-06T10:35:13] WARN  ll-001: No tasks found.
   lazylead    | [2020-06-06T10:35:13] DEBUG Memory footprint at the end is 66MB
   lazylead exited with code 0
   ll > 
   ```
3. Define your team and tasks in database. 
   Yes, there are no UI yet, but its planned. Pull requests are welcome! 
   The tables structure defined [here](upgrades/sqlite/001-install-main-lazylead-tables.sql).
   Modify you [sqlite](https://sqlite.com/index.html) file(`ll.db`) using [DB Browser](https://sqlitebrowser.org/) or any similar tool.
   Please change the `<youremail.com>` to your email address in order to be in CC when developer get the notification:
   ```sql
   insert into teams  (id, name, properties) 
               values (1, 'Dream team with lazylead', '{}');
   insert into systems(id, properties)    
               values (1,'{"type":"Lazylead::Jira", "username":"${jira_user}", "password":"${jira_password}", "site":"${jira_url}", "context_path":""}');
   insert into tasks  (name, cron, enabled, id, system, team_id, action, properties)
               values ('Expired due dates', 
                       '0 8 * * 1-5', 
                       'true',
                       1, 1, 1, 
                       'Lazylead::Task::AssigneeAlert',
                       '{"sql":"filter=555", "cc":"<youremail.com>", "subject":"[LL] Expired due dates", "template":"lib/messages/due_date_expired.erb", "postman":"Lazylead::Exchange"}');
    
   ```
   Yes, for task scheduling we are using [cron](https://crontab.guru).
4. Once you changed `./ll.db`, please restart the container using `docker-compose -f .github/tasks.yml restart`
   ```bash
   ll > docker-compose -f .github/tasks.yml restart                                                                                                      100% 🔋  14:37:19
   Restarting lazylead ... done
   ```
   check the logs and stop container if needed
   ```bash
   ll > docker logs lazylead
    2020-06-06T11:37:36] DEBUG Memory footprint at start is 52MB
    [2020-06-06T11:37:37] DEBUG Database: '/lazylead/db/ll.db', sql migration dir: '/lazylead/upgrades/sqlite'
    [2020-06-06T11:37:37] DEBUG Migration applied to /lazylead/db/ll.db from /lazylead/upgrades/sqlite
    [2020-06-06T11:37:37] DEBUG Database connection established
    [2020-06-06T11:37:37] WARN  SMTP connection enabled in test mode.
    [2020-06-06T11:37:37] DEBUG Task scheduled: id='1', name='Expired due dates', cron='0 8 * * 1-5', system='1', action='Lazylead::Task::AssigneeAlert', team_id='1', description='', enabled='true', properties='{"sql":"filter=555", "cc":"my.email@google.com", "subject":"[LL] Expired due dates", "template":"lib/messages/due_date_expired.erb", "postman":"Lazylead::Exchange"}'
   ll > docker stop lazylead                                                                                                                            
   lazylead
   ```

#### Contribution guide
Pull requests are welcome! 
Don't forget to run this, beforehand:
```
bundle exec rake
```
Everyone interacting in this project’s codebases, issue trackers, chat rooms is expected to follow the [code of conduct](.github/CODE_OF_CONDUCT.md).
