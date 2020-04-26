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
-- @todo #/DEV Add indexes to all columns which have foreign keys in order to
--  avoid full table scans.

--  @todo #/DEV Add description to each column using ANSI column command.
--   Potentially switch to h2 is required.

-- @todo #/DEV Add index by name to table persons in order to avoid full table
--  scans during access by name.
PRAGMA foreign_keys = ON;
create table if not exists teams
(
    id         integer primary key autoincrement,
    name       text not null,
    properties text
);
-- @todo #/DEV system.properties - column should be a json map(key,value)
create table if not exists systems
(
    id         integer primary key autoincrement,
    properties text not null
);
-- @todo #/DEV task.cron - add regexp verification of cron expression.
create table if not exists tasks
(
    id          integer primary key autoincrement,
    name        text    not null,
    cron        text    not null,
-- @todo #/DEV task.cron - add support for non-cron based schedule like at, once, every.
--  More details:
--  https://github.com/jmettraux/rufus-scheduler
--  https://stackoverflow.com/questions/46691666/using-constantize-to-invoke-both-a-class-and-method-from-separate-strings
    system      integer not null,
    action      text    not null,
    team_id     integer not null,
    description text,
    enabled     text,
    properties  text    not null,
-- @todo #/DEV tasks.enabled - add index for future search. Research is required.
    foreign key (system) references systems (id) on delete cascade,
    foreign key (team_id) references teams (id) on delete cascade
);
