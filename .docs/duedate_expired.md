## Notify Jira ticket assignee about expired(ing) due date 
#### Why?
Why do we need this if Jira has `Filter Subscription` feature:
- https://confluence.atlassian.com/jira064/receiving-search-results-via-email-720416706.html
- https://confluence.atlassian.com/jiracorecloud/advanced-searching-765593707.html

As far as I know, filter subscription feature doesn't allow(for now) to group tickets by assignee and send to each of them personal message with missing due dates.
Right now its just send whole list of tickets to you or specified group.
In worst cases, shared responsibility leads to irresponsibility each individual.

#### How to use lazylead for this
Let's assume that 
1.  JQL for tickets with expired due dates: `project = PRJ and resolution = unresolved and duedate < startOfDay()`
2.  you've saved this JQL as jira filter with id `222`
3.  you want to sent an email notification to each assignee about his/her missing due dates over `MS Exchange server` 

For simplicity, we are using [docker-compose](https://docs.docker.com/compose/):
1.  Define yml file with `docker-compose` configuration in `lazylead.yml`
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
    
2.  Create a container, using `docker-compose -f lazylead.yml up`
    The container will stop as there were no tasks provided:
    ```bash
    ll > docker-compose -f lazylead.yml up                                                         
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

3.  Define your team and tasks in database. 
    The tables structure defined [here](../upgrades/sqlite/001-install-main-lazylead-tables.sql).
    Modify you [sqlite](https://sqlite.com/index.html) file(`ll.db`) using [DB Browser](https://sqlitebrowser.org/) or any similar tool.
    You may add your email into tasks.properties `"cc":"your@email.com"` in order to be aware that developer got the message, but i don't recommend you as you'll get a dozen of messages in a few days :) .
    ```sql
    insert into teams (id, name, properties) 
               values (1, 'Dream team with lazylead', '{}');
    insert into systems(id, properties)    
               values (1,'{"type":"Lazylead::Jira", "username":"${jira_user}", "password":"${jira_password}", "site":"${jira_url}", "context_path":""}');
    insert into tasks (name, cron, enabled, id, system, team_id, action, properties)
               values ('Expired due dates', 
                       '0 8 * * 1-5', 
                       'true',
                       1, 1, 1, 
                       'Lazylead::Task::AssigneeAlert',
                       '{"sql":"filter=222", "cc":"<youremail.com>", "subject":"[LL] Expired due dates", "template":"lib/messages/due_date_expired.erb", "postman":"Lazylead::Exchange"}');
    
    ```
    Yes, for task scheduling we are using [cron](https://crontab.guru).

4.  Once you changed `./ll.db`, please restart the container using `docker-compose -f .github/tasks.yml restart`
    ```bash
    ll > docker-compose -f .github/tasks.yml restart
    Restarting lazylead ... done
    ```


#### Where is the code?
| Logic | Tests | Email Template |
| :-----: | :------: | :-----: |
| AssigneeAlert in [alert.rb](../lib/lazylead/task/alert.rb)| [duedate_test.rb](../test/lazylead/task/duedate_test.rb) | [due_date_expired.erb](../lib/messages/due_date_expired.erb) |
