[![Versions](https://img.shields.io/badge/semver-2.0-green)](https://semver.org/spec/v2.0.0.html)
[![Gem Version](https://badge.fury.io/rb/lazylead.svg)](https://rubygems.org/gems/lazylead)
[![Downloads](https://ruby-gem-downloads-badge.herokuapp.com/lazylead?type=total)](https://rubygems.org/gems/lazylead)
[![](https://img.shields.io/docker/pulls/dgroup/lazylead.svg)](https://hub.docker.com/r/dgroup/lazylead "Image pulls")
[![](https://images.microbadger.com/badges/image/dgroup/lazylead.svg)](https://microbadger.com/images/dgroup/lazylead "Image layers")
[![Commit activity](https://img.shields.io/github/commit-activity/y/dgroup/lazylead.svg?style=flat-square)](https://github.com/dgroup/lazylead/graphs/commit-activity)
[![Hits-of-Code](https://hitsofcode.com/github/dgroup/lazylead)](https://hitsofcode.com/view/github/dgroup/lazylead)
[![License: MIT](https://img.shields.io/github/license/mashape/apistatus.svg)](./license.txt)

[![Build status circleci](https://circleci.com/gh/dgroup/lazylead/tree/master.svg?style=shield)](https://circleci.com/gh/dgroup/lazylead/tree/master)
[![0pdd](http://www.0pdd.com/svg?name=dgroup/lazylead)](http://www.0pdd.com/p?name=dgroup/lazylead)
[![Dependency Status](https://requires.io/github/dgroup/lazylead/requirements.svg?branch=master)](https://requires.io/github/dgroup/lazylead/requirements/?branch=master)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=dgroup_lazylead&metric=alert_status)](https://sonarcloud.io/dashboard?id=dgroup_lazylead)
[![codebeat badge](https://codebeat.co/badges/f3bc8c19-5986-413f-89c4-c869b1e9b705)](https://codebeat.co/projects/github-com-dgroup-lazylead-master)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/e1ec2d63ff9040d99c934e3c05c24abe)](https://www.codacy.com/manual/dgroup/lazylead?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=dgroup/lazylead&amp;utm_campaign=Badge_Grade)
[![Maintainability](https://api.codeclimate.com/v1/badges/e873a41b1c76d7b2d6ae/maintainability)](https://codeclimate.com/github/dgroup/lazylead/maintainability)
[![codecov](https://codecov.io/gh/dgroup/lazylead/branch/master/graph/badge.svg)](https://codecov.io/gh/dgroup/lazylead)

[![DevOps By Rultor.com](http://www.rultor.com/b/dgroup/lazylead)](http://www.rultor.com/p/dgroup/lazylead)
[![EO badge](http://www.elegantobjects.org/badge.svg)](http://www.elegantobjects.org/#principles)

⚠️ We're still in a very early alpha version, the API may change frequently until we release version `1.0`.

### Overview
Ticketing systems (Github, Jira, etc.) are strongly integrated into our processes and everyone understands their necessity. As soon as a developer becomes a lead/technical manager, he or she faces a set of routine tasks that are related to ticketing work. On large projects this becomes a problem, more and more you spend time running around on dashboards and tickets, looking for incorrect deviations in tickets and performing routine tasks instead of solving technical problems.

The idea of automatic management is not new, for example [Zerocracy](https://www.zerocracy.com/) is available on the market. 
I like this idea, but large companies/projects are not ready yet for such a decisive breakthrough and need step-by-step solutions such as [lazylead](https://github.com/dgroup/lazylead). 
I think you remember how [static code analysis](https://en.wikipedia.org/wiki/Static_program_analysis) treated at in the past; today we have a huge toolkit (pmd, checkstyle, qulice, rubocop, peon, etc) for each language that allows you to avoid routine issues and remove from the code reviewer the unnecessary load.
 
Join our telegram group [lazylead.org](https://t.me/lazyleads) for discussions.

| Daily annoying task                                                                 | Jira  | Github | Trello | SVN |
| :---------------------------------------------------------------------------------- | :---: | :----: | :----: | :----: |
| [Notify ticket's assignee](lib/lazylead/task/alert/alert.rb)                        | ✅ | ⌛ | ⌛ | ❌ |  
| [Notify ticket's reporter](lib/lazylead/task/alert/alert.rb)                        | ✅ | ⌛ | ⌛ | ❌ | 
| [Notify ticket's manager](lib/lazylead/task/alert/alert.rb)                         | ✅ | ⌛ | ⌛ | ❌ | 
| [Notify about illegal "Fix Version" modification](lib/lazylead/task/fix_version.rb) | ✅ | ❌ | ❌ | ❌ | 
| [Expected comment in ticket is missing](lib/lazylead/task/missing_comment.rb)       | ✅ | ⌛ | ⌛ | ❌ | 
| [Propagate some fields from parent ticket into sub-tasks](.docs/propagate_down.md)  | ✅ | ❌ | ❌ | ❌ |   
| [Evaluate the ticket formatting accuracy](.docs/accuracy.md)                        | ✅ | ⌛ | ⌛ | ❌ |   
| Print the current capacity of team into newly created tasks                         | ⌛ | ⌛ | ⌛ | ❌ |   
| Create/retrofit the defect automatically into latest release                        | ⌛ | ⌛ | ❌ | ❌ |   
| [Notify about expired(ing) due dates](.docs/duedate_expired.md)                     | ✅ | ❌ | ⌛ | ❌ | 
| Notify about absent original estimations                                            | ⌛ | ⌛ | ⌛ | ❌ | 
| Notify about 'Hot potato' tickets                                                   | ⌛ | ⌛ | ⌛ | ❌ | 
| Notify about long live tickets (aging)                                              | ⌛ | ⌛ | ⌛ | ❌ | 
| Create a meeting(s) automatically in case some tickets appeared (group by assignee/reporters/component/ticket type/etc) | ⌛ | ⌛ | ⌛ | ❌ | 
| Propogate fields from parent tickets to sub-tasks | ✅ | ⌛ | ⌛ | ❌ | 
| Notify about tickets without comments with expected text | ✅ | ⌛ | ⌛ | ❌ | 
| Notify about team loading (no tasks on teammates) | ✅ | ⌛ | ⌛ | ❌ | 
| Notify about tickets matches predefined multiple conditions | ✅ | ⌛ | ⌛ | ❌ | 
| Link automatically the ticket and Confluence page if link found in ticket's comments/description | ✅ | ⌛ | ⌛ | ❌ | 
| Notify about tickets assigned to your team members not by effective managers| ✅ | ⌛ | ⌛ | ❌ | 
| Notify about modifications of important files in SVN | ❌ | ❌ | ❌ | ✅ | 
| Notify about diff changes for past X period in SVN | ❌ | ❌ | ❌ | ✅ | 
| Notify about changes with some text for past X period in SVN | ❌ | ❌ | ❌ | ✅ | 

| Integration                                           | Type          | Status |
| :---------------------------------------------------- | :-----------: | :----: |
| [Microsoft Exchange Server](lib/lazylead/exchange.rb) | Emails        | ✅ |
| [Microsoft Exchange Server](lib/lazylead/exchange.rb) | Calendar      | ⌛ |
| [mail.yandex.com](lib/lazylead/postman.rb)            | Emails        | ✅ |
| [mail.google.com](lib/lazylead/postman.rb)            | Emails        | 🌵 |
| calendar.google.com                                   | Calendar      | ⌛ |
| slack.com                                             | Notifications | ⌛ |

✅ - implemented, ⌛ - planned, 🌵 - implemented, but not tested, ❌ - not supported by ticketing system.

New ideas, bugs, suggestions or questions are welcome [via GitHub issues](https://github.com/dgroup/lazylead/issues/new)!

### Get started
⚠️ We're still in a very early alpha version, the API may change frequently until we release version `1.0`.

Let's assume that:
- your team is using jira as a ticketing system
- you defined a jira filter with tickets where actions need. The filter id is `555` and it has JQL like
   ```text
   project=XXXX and type=Bug and status not in (Closed, Cancelled, "Ready For Testing", "On Hold) 
    and parent = YYYY and duedate < startOfDay()
   ```
- you have `MS Exchange` server for email notifications
- you want to notify your developers during working days at `8am (UTC)` time about tickets where due dates are expired

For simplicity, we are using [docker-compose](https://docs.docker.com/compose/):
1.  Define yml file with configuration [tasks.yml](.github/tasks.yml)
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
    git clone https://github.com/dgroup/lazylead.git ll && cd ll
    ```

2.  Create a container, using `docker-compose -f .github/tasks.yml up`
    The container will stop as there were no tasks provided:
    ```bash
    ll > docker-compose -f .github/tasks.yml up                                                         
    Creating lazylead ... done
    Attaching to lazylead
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Version: 0.5.0
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Memory footprint at start is 52MB
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Database: '/lazylead/db/ll.db', sql migration dir: '/lazylead/upgrades/sqlite'
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Migration applied to /lazylead/db/ll.db from /lazylead/upgrades/sqlite
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Database connection established
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] SMTP connection established with {host} as {user}.
    lazylead    | [2020-08-09T06:17:32] WARN  [main] ll-001: No tasks found.
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Memory footprint at the end is 67MB
    lazylead exited with code 0
    ll > 
    ```

3.  Define your team and tasks in database. 
    Yes, there are no UI yet, but its planned. Pull requests are welcome! 
    The tables structure defined [here](upgrades/sqlite/001-install-main-lazylead-tables.sql).
    Modify you [sqlite](https://sqlite.com/index.html) file(`ll.db`) using [DB Browser](https://sqlitebrowser.org/) or any similar tool.
    Please change the `<youremail.com>` to your email address in order to be in CC when developer get the notification:
    ```sql
    insert into teams (id, name, properties) 
               values (1, 'Dream team with lazylead', '{}');
    insert into systems(id, properties)    
               values (1,'{"type":"Lazylead::Jira", "username":"${jira_user}", "password":"${jira_password}", "site":"${jira_url}", "context_path":""}');
    insert into tasks  (name, schedule, enabled, id, system, team_id, action, properties)
               values ('Expired due dates', 
                       'cron:0 8 * * 1-5', 
                       'true',
                       1, 1, 1, 
                       'Lazylead::Task::AssigneeAlert',
                       '{"sql":"filter=555", "cc":"<youremail.com>", "subject":"[LL] Expired due dates", "template":"lib/messages/due_date_expired.erb", "postman":"Lazylead::Exchange"}');
    
    ```
    Yes, for task scheduling we are using [cron](https://crontab.guru) here, but you may use other scheduling types from [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler).

4.  Once you changed `./ll.db`, please restart the container using `docker-compose -f .github/tasks.yml restart`
    ```bash
    ll > docker-compose -f .github/tasks.yml restart
    Restarting lazylead ... done
    ```
    check the logs and stop container if needed
    ```bash
    ll > docker logs lazylead
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Version: 0.5.0
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Memory footprint at start is 52MB
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Database: '/lazylead/db/ll.db', sql migration dir: '/lazylead/upgrades/sqlite'
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Migration applied to /lazylead/db/ll.db from /lazylead/upgrades/sqlite
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Database connection established
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] SMTP connection established with {host} as {user}.
    lazylead    | [2020-08-09T06:17:32] DEBUG [main] Task scheduled: id='1', name='Expired due dates', cron='0 8 * * 1-5', system='1', action='Lazylead::Task::AssigneeAlert', team_id='1', description='', enabled='true', properties='{"sql":"filter=555", "cc":"my.email@google.com", "subject":"[LL] Expired due dates", "template":"lib/messages/due_date_expired.erb", "postman":"Lazylead::Exchange"}'
    ...
    ```

### How to contribute?
[![EO badge](http://www.elegantobjects.org/badge.svg)](http://www.elegantobjects.org/#principles) 

Pull requests are welcome! Don't forget to add your name to contribution section and run this, beforehand:
```ruby
bundle exec rake
```
Everyone interacting in this project’s codebases, issue trackers, chat rooms is expected to follow the [code of conduct](.github/CODE_OF_CONDUCT.md).

Contributors:
 * [dgroup](https://github.com/dgroup) as Yurii Dubinka ([yurii.dubinka@gmail.com](mailto:yurii.dubinka@gmail.com))
