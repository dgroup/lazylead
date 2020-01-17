create table if not exists person (
    id    text primary key,
    name  text not null,
    email text not null
);
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

-- @todo #/DEV team.properties - column should be a json map(key,value)
create table if not exists team (
    id         integer primary key autoincrement,
    name       text not null,
    lead       text,
    properties text,
    foreign key (lead) references person(id)
);
create table if not exists cc (
    id        integer primary key autoincrement,
    team_id   integer,
    person_id text,
    foreign key (team_id) references team(id),
    foreign key (person_id) references person(id)
);
-- @todo #/DEV system.properties - column should be a json map(key,value)
create table if not exists system (
    id         integer primary key autoincrement,
    name       text not null,
    properties text
);
-- @todo #/DEV task.cron - add regexp verification of cron expression.
create table if not exists task (
    id          integer primary key autoincrement,
    name        text not null,
    cron        text not null,
    system      integer,
    action      text not null,
    team_id     integer,
    description text,
    foreign key (system) references system(id),
    foreign key (team_id) references team(id)
);
-- @todo #/DEV properties.type - add check function in order to restrict the supported types
create table if not exists properties (
    key   text primary key,
    value text,
    type  text not null
);
