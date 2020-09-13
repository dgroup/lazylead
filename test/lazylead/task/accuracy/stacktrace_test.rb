# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2020 Yurii Dubinka
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

require_relative "../../../test"
require_relative "../../../../lib/lazylead/task/accuracy/stacktrace"

module Lazylead
  class StacktraceTest < Lazylead::Test
    test "java stacktrace is found" do
      assert Stacktrace.new.passed(
        OpenStruct.new(
          description: "
          XXXXXX env: http://xxxx.xxx.com:00000/
          WL log [^clust1.log]
          http://xxx.xxx.com/display/xxx/SQLException+No+more+data+to+read+from+socket

          During call we found in clust1.log the following error
          {noformat}
            at xxx.xxx.xxx.xxx.wrapper.XxxXxxXxxxXxx.xxxxXxxxXxxx(XxxXxxXxxxXxx.java:233)
            at xxx.xxx.xxx.xxx.wrapper.XxxXxxXxxxXxx.xxxxXxxxXxxx(XxxXxxXxxxXxx.java:343)
            ... 318 more
          Caused by: javax.transaction.TransactionRolledbackException: EJB Exception: ; nested exception is:
            javax.ejb.TransactionRolledbackLocalException: EJB Exception:
            at weblogic.utils.StackTraceDisabled.unknownMethod()
          Caused by: javax.ejb.TransactionRolledbackLocalException: EJB Exception:
            ... 1 more
          Caused by: javax.ejb.EJBException: java.sql.SQLRecoverableException: No more data to read from socket
            ... 1 more
          Caused by: java.sql.SQLRecoverableException: No more data to read from socket
            ... 1 more
          {noformat}

          The investigation is required.
          More details here: XXXXX-xxxxxx"
        )
      )
    end

    test "stacktrace is found" do
      assert Stacktrace.new.passed(
        OpenStruct.new(
          description: "
            Stack Trace
            {noformat}
            javax.transaction.TransactionRolledbackException: EJB Exception: ; nested exception is:
             java.lang.IllegalArgumentException: Unknown xxxx-xxx xxx \"xxx.xxx.xxx.configuration\"
             at weblogic.ejb.container.internal.EJBRuntimeUtils.asTxRollbackException(EJBRuntimeUtils.java:134)
             at weblogic.ejb.container.internal.BaseRemoteObject.handleSystemException(BaseRemoteObject.java:595)
             at weblogic.ejb.container.internal.BaseRemoteObject.handleSystemException(BaseRemoteObject.java:537)
             at weblogic.ejb.container.internal.BaseRemoteObject.postInvoke1(BaseRemoteObject.java:365)
             at weblogic.ejb.container.internal.StatelessRemoteObject.postInvoke1(StatelessRemoteObject.java:20)
             at weblogic.ejb.container.internal.BaseRemoteObject.__WL_postInvokeTxRetry(BaseRemoteObject.java:307)
             at weblogic.ejb.container.internal.SessionRemoteMethodInvoker.invokeInternal(SessionRemoteMethodInvoker.java:67)
             at weblogic.ejb.container.internal.SessionRemoteMethodInvoker.invoke(SessionRemoteMethodInvoker.java:21)
             at xxx.xxxx.xxxxxx.xxx.xxx.XxxxXxxxXxxxXxxxxxx.xxxxXxxxXXxxxx(Unknown Source)
             at xxxx.xxxxxx.xxxxx.xxx.xxxxxx.xxx.xxxxxxxx.xxxx.xxxxxx.XxxxxXxxxx.xxxXxxxXxxxx(XxxxXxxxXxxx.java:677)
             at xxxx.xxxxxx.xxxxx.xxx.xxxxxx.xxx.xxxxxxxx.xxxx.xxxxxx.XxxxxXxxxx.xxxXxxxXxxxx(XxxxXxxxXxxx.java:304)
             at xxxx.xxxxxx.xxxxx.xxx.xxxxxx.xxx.xxxxxxxx.xxxx.xxxxxx.XxxxxXxxxx.xxxXxxxXxxxx(XxxxXxxxXxxx.java:75)
             at xxxx.xxxxxx.xxxxx.xxx.xxxxxx.xxx.xxxxxxxx.xxxx.xxxxxx.XxxxxXxxxx.xxxXxxxXxxxx(XxxxXxxxXxxx.java:138)
             at sun.reflect.GeneratedMethodAccessor2010.invoke(Unknown Source)
            {noformat}

            Log file -   [^clust3.log]

            Path to log file
            {noformat}
            \\ftp.server.com\\logs.tgz
            {noformat}

            Server link - http://xxxxxXxxXxxx:0000

             !214.png|thumbnail!"
        )
      )
    end

    test "ORA error is found" do
      assert Stacktrace.new.passed(
        OpenStruct.new(
          description: "
            {noformat}
            @XXXX/xxx/xxx/xxxx_xxx_xxxxx_xxx_xx.sql
            ORA-02291:	1	 integrity constraint (XXX_XXX_XXX.XX_xxx) violated - xx xxx not found for xx_xx=xx xxxxx_xx=XXXXXXX xxxxx=XXXXXXXX xxx_xx=xxx xx_xxx=xxxx.xxx.xxx.xxxxx.xxx.xxx.xxxxx
            XXXX-xxx-xxxx: xxxxx xxxxx Xxxxx xxxx Xxxx
            {noformat}

            XXXX - XXX_XXX.X.XXXX.XXXX.XXXX.XxxxxxXX.X_xxxXXXXXX"
        )
      )
    end
  end
end
