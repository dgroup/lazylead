## Propagate fields from parent Jira ticket to sub-tasks
#### Why?
Why do we need this if Jira has automation already?

Could you able use this feature right now? Just right now, without requests to some admin/jira owner/submitting some tickets to someone/etc... I doubt.
In a huge company that's almost impossible to change something special for you in short terms. 

#### How to use lazylead for this
Let's assume that 
1.  JQL for parent tickets for the propagation: `issue in parentsOf("project='PRJ' and 'External ID' is empty") and "External ID" is not empty and updated >-1d`.
2.  you've saved this JQL as jira filter with id `222`. 

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
    ```sql
    insert into teams (id, name, properties) 
               values (1, 'Dream team with lazylead', '{}');
    insert into systems(id, properties)    
               values (1,'{"type":"Lazylead::Jira", "username":"${jira_user}", "password":"${jira_password}", "site":"${jira_url}", "context_path":""}');
    insert into tasks (name, schedule, enabled, id, system, team_id, action, properties)
               values ('Propagate customfield_1 (External ID) to sub-tasks', 
                       'cron:0 8 * * 1-5', 
                       'true',
                       1, 1, 1, 
                       'Lazylead::Task::PropagateDown',
                       '{"jql":"filter=222", "propagate":"customfield_1"}');
    
    ```
    Yes, for task scheduling we are using [cron](https://crontab.guru) here, but you may use other scheduling types from [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler).

4.  Once you changed `./ll.db`, please restart the container using `docker-compose -f .github/tasks.yml restart`
    ```bash
    ll > docker-compose -f .github/tasks.yml restart
    Restarting lazylead ... done
    ```

5.  Once task completed, please check your sub-tasks, they should have `customfield_1` and comment like
    ```text
    The following fields were propagated from <parent-ticket-key>:
    ||Field||Value||
    |customfield_1|<parent-field-value>|
    Posted by [lazylead v0.0.0|https://bit.ly/2NjdndS]]
    ```

#### Where is the code?
| Logic | Tests |
| :-----: | :------: |
| [propagate_down.rb](../lib/lazylead/task/propagate_down.rb)| [propagate_down_test.rb](../test/lazylead/task/propagate_down_test.rb) | 
