insert into teams (id, name, properties)
values (1, 'Dream team with lazylead', '{}');
insert into systems(id, properties)
values (1, '{"type":"Lazylead::Jira", "site":"${jira_url}", "context_path":""}');
insert into tasks (name, schedule, enabled, id, system, team_id, action, properties)
values ('Expired due dates',
        'cron:* * * * *',
        'true',
        1, 1, 1,
        'Lazylead::Task::AssigneeAlert',
        '{
          "sql": "resolution = unresolved and due < startOfDay()",
          "cc": "their@lead.com",
          "subject": "[LL] Expired due dates",
          "template": "lib/messages/due_date_expired.erb",
          "postman": "Lazylead::FilePostman"
        }');
insert into tasks (name, schedule, enabled, id, system, team_id, action, properties)
values ('Reporter''s ticket score in Spring Data MongoDB',
        'cron:* * * * *',
        'true',
        2, 1, 1,
        'Lazylead::Task::Accuracy',
        '{
          "from": "ll@fake.com",
          "to": "lead@fake.com",
          "rules": "Lazylead::Stacktrace,Lazylead::Testcase",
          "fields": "attachment,description,environment,components,versions,reporter,labels,priority,duedate,summary",
          "colors": "{\"0\":\"#FF4F33\",\"30\":\"#FEC15E\",\"50\":\"#19DD1E\"}",
          "jql": "type=Bug and project =''Spring Data MongoDB'' and key >= DATAMONGO-1530 and key <= DATAMONGO-1600",
          "silent": "true",
          "subject": "[LL] Reporter''s ticket score in Spring Data MongoDB",
          "template": "lib/messages/accuracy.erb",
          "postman":"Lazylead::FilePostman"
        }');