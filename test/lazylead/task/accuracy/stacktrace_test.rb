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

    test "exception is found" do
      assert Stacktrace.new.passed(
        OpenStruct.new(
          description: "{noformat}sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target; nested exception is javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target{noformat}"
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

    test "java error is found in code section" do
      assert Stacktrace.new.passed(
        OpenStruct.new(
          description: "
            asdfasdfasdf
            {code:java}texta-line1
            ;texta-line2{code}
            asdjf;asdjfa;sdjf
            as;djf;asdjf
            {code}javax.servlet.ServletException: Something went wrong
             at com.example.myproject.OpenSessionInViewFilter.doFilter(OpenSessionInViewFilter.java:60)
             at org.mortbay.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1157)
             at com.example.myproject.ExceptionHandlerFilter.doFilter(ExceptionHandlerFilter.java:28)
             at org.mortbay.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1157)
             at com.example.myproject.OutputBufferFilter.doFilter(OutputBufferFilter.java:33)
             at org.mortbay.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1157)
             at org.mortbay.jetty.servlet.ServletHandler.handle(ServletHandler.java:388)
             at org.mortbay.jetty.security.SecurityHandler.handle(SecurityHandler.java:216)
             at org.mortbay.jetty.servlet.SessionHandler.handle(SessionHandler.java:182)
             at org.mortbay.jetty.handler.ContextHandler.handle(ContextHandler.java:765)
             at org.mortbay.jetty.webapp.WebAppContext.handle(WebAppContext.java:418)
             at org.mortbay.jetty.handler.HandlerWrapper.handle(HandlerWrapper.java:152)
             at org.mortbay.jetty.Server.handle(Server.java:326)
             at org.mortbay.jetty.HttpConnection.handleRequest(HttpConnection.java:542)
             at org.mortbay.jetty.HttpConnection$RequestHandler.content(HttpConnection.java:943)
             at org.mortbay.jetty.HttpParser.parseNext(HttpParser.java:756)
             at org.mortbay.jetty.HttpParser.parseAvailable(HttpParser.java:218)
             at org.mortbay.jetty.HttpConnection.handle(HttpConnection.java:404)
             at org.mortbay.jetty.bio.SocketConnector$Connection.run(SocketConnector.java:228)
             at org.mortbay.thread.QueuedThreadPool$PoolThread.run(QueuedThreadPool.java:582)
          Caused by: com.example.myproject.MyProjectServletException
             at com.example.myproject.MyServlet.doPost(MyServlet.java:169)
             at javax.servlet.http.HttpServlet.service(HttpServlet.java:727)
             at javax.servlet.http.HttpServlet.service(HttpServlet.java:820)
             at org.mortbay.jetty.servlet.ServletHolder.handle(ServletHolder.java:511)
             at org.mortbay.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1166)
             at com.example.myproject.OpenSessionInViewFilter.doFilter(OpenSessionInViewFilter.java:30)
             ... 27 more
          Caused by: org.hibernate.exception.ConstraintViolationException: could not insert: [com.example.myproject.MyEntity]
             at org.hibernate.exception.SQLStateConverter.convert(SQLStateConverter.java:96)
             at org.hibernate.exception.JDBCExceptionHelper.convert(JDBCExceptionHelper.java:66)
             at org.hibernate.id.insert.AbstractSelectingDelegate.performInsert(AbstractSelectingDelegate.java:64)
             at org.hibernate.persister.entity.AbstractEntityPersister.insert(AbstractEntityPersister.java:2329)
             at org.hibernate.persister.entity.AbstractEntityPersister.insert(AbstractEntityPersister.java:2822)
             at org.hibernate.action.EntityIdentityInsertAction.execute(EntityIdentityInsertAction.java:71)
             at org.hibernate.engine.ActionQueue.execute(ActionQueue.java:268)
             at org.hibernate.event.def.AbstractSaveEventListener.performSaveOrReplicate(AbstractSaveEventListener.java:321)
             at org.hibernate.event.def.AbstractSaveEventListener.performSave(AbstractSaveEventListener.java:204)
             at org.hibernate.event.def.AbstractSaveEventListener.saveWithGeneratedId(AbstractSaveEventListener.java:130)
             at org.hibernate.event.def.DefaultSaveOrUpdateEventListener.saveWithGeneratedOrRequestedId(DefaultSaveOrUpdateEventListener.java:210)
             at org.hibernate.event.def.DefaultSaveEventListener.saveWithGeneratedOrRequestedId(DefaultSaveEventListener.java:56)
             at org.hibernate.event.def.DefaultSaveOrUpdateEventListener.entityIsTransient(DefaultSaveOrUpdateEventListener.java:195)
             at org.hibernate.event.def.DefaultSaveEventListener.performSaveOrUpdate(DefaultSaveEventListener.java:50)
             at org.hibernate.event.def.DefaultSaveOrUpdateEventListener.onSaveOrUpdate(DefaultSaveOrUpdateEventListener.java:93)
             at org.hibernate.impl.SessionImpl.fireSave(SessionImpl.java:705)
             at org.hibernate.impl.SessionImpl.save(SessionImpl.java:693)
             at org.hibernate.impl.SessionImpl.save(SessionImpl.java:689)
             at sun.reflect.GeneratedMethodAccessor5.invoke(Unknown Source)
             at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25)
             at java.lang.reflect.Method.invoke(Method.java:597)
             at org.hibernate.context.ThreadLocalSessionContext$TransactionProtectionWrapper.invoke(ThreadLocalSessionContext.java:344)
             at $Proxy19.save(Unknown Source)
             at com.example.myproject.MyEntityService.save(MyEntityService.java:59) <-- relevant call (see notes below)
             at com.example.myproject.MyServlet.doPost(MyServlet.java:164)
             ... 32 more
          Caused by: java.sql.SQLException: Violation of unique constraint MY_ENTITY_UK_1: duplicate value(s) for column(s) MY_COLUMN in statement [...]
             at org.hsqldb.jdbc.Util.throwError(Unknown Source)
             at org.hsqldb.jdbc.jdbcPreparedStatement.executeUpdate(Unknown Source)
             at com.mchange.v2.c3p0.impl.NewProxyPreparedStatement.executeUpdate(NewProxyPreparedStatement.java:105)
             at org.hibernate.id.insert.AbstractSelectingDelegate.performInsert(AbstractSelectingDelegate.java:57)
             ... 54 more{code}
            asdfasdfasdf{code:sql}select 1 from dual {code}what?
            "
        )
      )
    end

    test "pair detected" do
      assert_equal [[1, 4]],
                   Stacktrace.new.pairs(%w[aa tag bb cc tag dd], "tag")
    end

    test "proper pair detected" do
      assert_equal [[1, 4]],
                   Stacktrace.new.pairs(%w[aa tag bb cc tag dd tag], "tag")
    end
  end
end
