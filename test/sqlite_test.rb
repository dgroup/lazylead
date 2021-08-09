# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2021 Yurii Dubinka
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom
# the Software is  furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
# OR OTHER DEALINGS IN THE SOFTWARE.

require "sqlite3"
require_relative "test"

module Lazylead
  class SqliteTest < Lazylead::Test
    # Assert that table(s) has required column(s)
    def assert_tables(file, tables)
      raise "Table names is a null" if tables.nil?
      raise "Table names is empty" if tables.empty?
      schema = conn(file).query(
        "select t.name 'table', group_concat(i.name) 'columns'
         from sqlite_master t join pragma_table_info(t.name) i
         where
           t.type = 'table'
           and t.name in (#{tables.keys.map { |t| "'#{t}'" }.join(',')})
         group by t.name
         order by t.name"
      ).to_h
      refute_empty schema, "No tables found in #{file} for #{tables}"
      tables.each_with_index do |t, i|
        raise "Name not found for table with id #{i} in #{tables}" if t.empty?
        tbl = t.first.to_s
        cols = t.values_at(1).sort.join(",")
        raise "No columns found for table #{tbl} in #{tables}" if cols.empty?
        refute_nil schema[tbl], "Table '#{tbl}' not found in #{schema}"
        assert_equal cols, schema[tbl], "Columns mismatch for '#{tbl}'"
      end
    end

    # Assert that table(s) has required foreign key(s)
    #  which refers to the existing table.
    def assert_fk(file, *fks)
      raise "No foreign keys specified" if fks.nil? || fks.empty?
      schema = conn(file).query(
        "select t.name, fks.'from', fks.'table', fks.'to'
         from
          sqlite_master t join pragma_foreign_key_list(t.name) fks,
          sqlite_master e
         where e.type = 'table' and e.name = fks.'table'
         order by t.name, fks.'from'"
      ).map { |f| Array.new(f) }
      fks.each do |f|
        assert schema.any? { |fk| fk.sort == f.sort },
               "No foreign key found from #{f[0]}.#{f[1]} to #{f[2]}.#{f[3]}"
      end
    end

    private

    # Establish the connection to the local sqlite database
    def conn(file)
      raise "Path to sqlite file is a null" if file.nil?
      SQLite3::Database.new file
    end
  end
end
