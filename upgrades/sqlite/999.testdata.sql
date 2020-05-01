/*
 * The MIT License
 *
 * Copyright (c) 2019-2020 Yurii Dubinka
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom
 * the Software is  furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 * OR OTHER DEALINGS IN THE SOFTWARE.
 */
insert into systems(id, properties)
values (1,
        '{"type":"Lazylead::Jira", "username":"", "password":"", "site":"https://jira.spring.io", "context_path":""}'),
       (2,
        '{"type":"Lazylead::Jira", "username":"${jsi_usr}", "password":"${jsi_psw}", "site":"https://jira.spring.io", "context_path":""}');
insert into teams(id, name, properties)
values (1, 'BA squad', '{"from":"basquad@fake.com", "usr":"${usr}"}');
insert into tasks(name, cron, enabled, id, system, team_id, action, properties)
values ('echo', '* * * * *', 'false', 1, 1, 1, 'Lazylead::Task::Echo', '{}'),
       ('expired due date', '* * * * *', 'false', 2, 1, 1,
        'Lazylead::Task::Notification',
        '{"sql":"filter=100500","subject":"[DD] PDTN!","template":"lib/messages/due_date_expired.erb"}'),
       ('task with cc', '* * * * *', 'false', 3, 1, 1, 'Lazylead::Task::Echo',
        '{"cc":"leelakenny@mail.com,maciecrane@mail.com"}'),
       ('task', '* * * * *', 'false', 4, 2, 1, 'Lazylead::Task::Echo', '{}'),
       ('pman', '', '', 5, 2, 1, '', '{"postman":"Lazylead::Postman"}');