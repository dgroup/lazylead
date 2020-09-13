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
require_relative "../../../../lib/lazylead/task/accuracy/testcase"

module Lazylead
  class TestcaseTest < Lazylead::Test
    test "test case header is absent" do
      refute Testcase.new.passed(
        OpenStruct.new(
          description: "
          1. Xxxxx xxx xxxx
          2. Xxx xxxx (XXX xxx xxx x xx xxx x x xxxx)
          3. xxxxx xxx xx xxxx
          4. Xxxxx
          5. Xxxxx xxxxx xxxxx xxxx
          ER: Xxxxx xx xxx xxxx
          AR: XXXXX XX XX XXX: Xxxxx Xxxxx Xxxx Xxxxx -
          {code:java}
          xxx.xxxxx.xxxxxx.xxxx.xxx.XxxxXxxxXxxXX: xxxx xxx xxx XX xxxxxx xxxxx XXXxxxXXxxXxxXxx]
          {code}"
        )
      )
    end

    test "er on the next line" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            TC:
            1. Xxxx xx xxx xXxxxx xxx ;
            2. Xxxx xx xxx xx 'Xxxx xXxxxx xxxx'
             !xxxx-xxx.png|thumbnail!

            3.  Xxxx xx 'Xxxxx xXXXX xxxxx xxxx' xxxx xx Xxx xxx;

            ER:
            Xxxx xx xxx xxxxxx xxx XX xx xXxxxx.

            AR:

            {code:java}
            Xxxxxx
            Xxxxx xxx xxx xxxx xxxx xx xxx.
            {code}

             !xxxx-x-x-x-x-x-xxx.png|thumbnail!"
        )
      )
    end

    test "tc ar er case 1" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
          *Preconditions:*
           # XXX+ Xxxxx Xxxxxxx XX[http://xxx.xxx.xxx:0000/xx/xxx.jsp?xx=_xxx]
           # Xxxx xxxxx xx XX xxx

          *Test steps:*
           # Xxxxx xxxx xxx XX XXXXXXXX
           # Xxxxx xxxxxxxx x (xxxxxxxx)
          !xxx.png|width=514,height=262!
           # Xxxxx xxx xxx xxx
          *ER: Xxxx Xxxxxx xxx xx xxxx xxx XXXX xx xxxxx*
          *!xxx-xx-xx.png|width=535,height=61!*
           # Xxxx xxx xxx x x > xxxx
          *ER: XXX XXX XXX xxx xxx*
          *!xxxxxxxx-xxx-x-xx.png|width=826,height=167!*
          *!xxxxxx-xxx-xx-xxx.png|width=373,height=59!*
           #  Xxxxx xxxxxx xx XX xxx xxx Xxxxx Xxxxx xxxxx xxxx

          *ER: Xxxx Xxxx xxxxx xxx xxxx Xxxx *
          *AR: Xxxx xxxx xxxx xxx xx x xx xx *
          *!xxxxx-xx-x-x-xxx.png|width=1062,height=272!*

          *[^xxx-xxxx.log]*

          [^xxxxxx.LOG]"
        )
      )
    end

    test "tc ar er case 2" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            *Pre-requisites:*
            XXX xxxx xXXXX xx XXXXX.

            *TC:*
             # Xxxxx xx xXxxxx.
             # Xxxxx xx Xxxxx-xxxx xxx
             # Xxxxx xx Xxxx xXxxx xxxxxx xxxxx

            *ER:*  !ER.png|thumbnail!

            *AR:* Xxxxxx xxxx xxx

            !AR.png|thumbnail!

            *LOGS [^xXXxxx.zip]*

            Xxxxxx xx XXXXX: http://xxx.xxx.xxx:0000/xxx/xxx.jsp#!board;xxxxxXx=xxxxx;xxxxXxx=xxx;xxxxXx=xxxxxx

            xXxxx xxxx: http://xxx.xxx.xxx:0000"
        )
      )
    end

    test "tc ar er case 3" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            *Preconditions:*
             # XXX
             # XX (x xx xxxx)
             # XX xxxx XXx
             # XX xxxxx XXx
             # Xxxxxxxx xxxx xx

            *Test case:*
             1. Xxxxxx xx Xxxxxx Xxxxx Xxxxx -> Xxxxxx Xxxxx Xxxxxx-> Xxxxxx xxxxx (xxx xxxx)
             2. Xxxxx xx [Xx-Xxxxx] xxx
             3. Xxxxx xx [Xx-Xxxxx] xxx
             4. Xxxxx xxx [Xxxxx] xxx xxx xxx xxx xx 'Xxx'
             5. Xxxxxxx xx XXX Xxxx-> XXX-> XXX
             6. Xxxx xxxx xx Xxxxx xxxxxx

            *ER =* Xxxxxx xxx xxxxx xxxx xxxx: [Xxxx Xxxx].[Xxxxx] = Xxx xx xxxx

            *AR =* Xxxxx Xxxxx xxx xxx xxx xxx xx XXXX

              !image-2020-09-04-18-24-26-052.png|thumbnail!

            !image-2020-09-04-18-24-51-729.png|thumbnail!

            !image-2020-09-04-18-26-01-262.png|thumbnail!

            XXX_XXX.x.XXXX.XXXX.XX.XxxxXX_xxxXXXXX

            [http://xxxx.xxx:0000/xxx/xx.jsp#xxxXxx=xxxx;xxxXxx=xxx]"
        )
      )
    end

    test "tc ar er case 4" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            *Preconditions*
            1. XXXx
            2. Xxxxx

            *Test Steps*
            1. Xxx xx Xxxxx → XXXX Xxxxx → Xxxxx Xxxxx → 'Xxxxxx' xxxx 
            2. Xxxx 'Xxxxxx' xxxx xx 'Xxxxx Xxxxxx' xxxx

            *ER* = Xxxx xxxx xxx xxx xxxxx xxx Xxxx-Xxxxx

            *AR* = Xxxxx xxx xx Xxxxx xxx xxx xxx Xxxxx Xxxx Xxxx xxxx xxx xxxxx

            !image-2020-09-04-18-45-10-682.png|thumbnail!

            [http://xxxx.xxx:0000/xxx/xxx.jsp?xxx=xxxx#xxxXxx=xxx;xxxXxx=xxxxxx]
            xxx_XXXX.x.XXXX.XXXX.XX.XxxxxXX_xxXXXX"
        )
      )
    end

    test "tc ar er case 5" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            *Preconditions*
            1. XXxxXX
            2. Xxxxxx

            *Test Steps*
            1. Xx xx Xxxxx → XXX Xxxxx → Xxxxxx Xxxxx → 'Xxxxxx' xxxx 
            2. Xxxxxx 'Xxxxxx' xxxxx xxx 'Xxxxx Xxxxx' xxxxx

            *ER* = Xxxxx xxxxx xxxx xxxxxx xxxxxxxx xxxxx xx XXxx-Xxxx

            *AR* = XXxxxx xxx xxxxxx xxx Xxxxx xxx xxxx xxxx Xxxxx Xxxx Xxxx xxx

            !image-2020-xx-xx-xx-xx-xx-xxx.png|thumbnail!

            [http://xxx.xxx:0000/xxx/xxx.jsp?xxx=xxxx;xxxXx=4428;xxxXx=xxxx]
            xxx_xxx.x.xxxx.xxx.xxx.xxxxXxx_xxx"
        )
      )
    end

    test "tc ar er case 6" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            [https://xxxx.xxxx.xxx.com/]

            *Precondition:* XXX xxxx xxxxxxxxx xxxxxx xxxxx XXXX

            *TC:*
             # Xxxxx xx xXxxx xxxx: [xxx.xxx.com|https://xxx.xxx.com/]
             # Xxx XXX xxxxx xxx xxx xxx: 8443286573113926860
             # xxxxx [Xxxxx]
             # xxxxx xx Xxxxxx xxxx xxxx xxx
             # Xxxxx xxxx xxx XXX

            *ER:* xxxx xxxx xxxx xxxxx xxxxx

            *AR:* xxxx xxxx xxxx

            [^screenshot-1.png]"
        )
      )
    end
  end
end
