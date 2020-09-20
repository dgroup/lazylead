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
          1. Lorem Ipsum is
          2. Text of the printing (and typesetting industry. Lorem Ipsum)
          3. has been the industry's standard dummy text ever since the 1500s
          4. When an unknown
          5. Printer took a galley of type and scrambled it to make a type specimen book
          ER: It has survived not only five centuries
          AR: but also the leap into electronic typesetting, remaining essentially unchanged -
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
            1. It was popularised in the 1960s ;
            2. With the release of Letraset sheets containing 'Lorem Ipsum passages'
             !xxxx-xxx.png|thumbnail!

            3.  and more recently with desktop 'publishing software li'ke Aldus PageMaker including version;

            ER:
            Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots.

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
           # Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia,

          *Test steps:*
           # Lorem Ipsum comes from sections 1.10.32 and 1.10.33
           # This book is a treatise on the theory of ethics (very popular )
          !xxx.png|width=514,height=262!
           # The first line of Lorem Ipsum, 'Lorem ipsum dolor sit amet..'
          *ER: The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those intereste*
          *!xxx-xx-xx.png|width=535,height=61!*
           # Sections 1.10.32 and 1.10.33 from 'de Finibus Bonorum et Malorum' by Cicero are also  > xxxx
          *ER: It is a long established fact that a reader will be distracted by the
          *!xxxxxxxx-xxx-x-xx.png|width=826,height=167!*
          *!xxxxxx-xxx-xx-xxx.png|width=373,height=59!*
           #  The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters,

          *ER: As opposed to using 'Content here, content here', making *
          *AR: it look like readable English *
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
            Many desktop publishing packages.

            *TC:*
             # Various versions have evolved over the years,
             # sometimes by accident,
             # sometimes on purpose (injected humour and the like).

            *ER:*  !ER.png|thumbnail!

            *AR:* There are many variations of passages of Lorem Ipsum available,

            !AR.png|thumbnail!

            *LOGS [^xXXxxx.zip]*

            Randomised words which don't look even slightly believable: http://xxx.xxx.xxx:0000/xxx/xxx.jsp#!board;xxxxxXx=xxxxx;xxxxXxx=xxx;xxxxXx=xxxxxx

            If you are going to use a passage: http://xxx.xxx.xxx:0000"
        )
      )
    end

    test "tc ar er case 3" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            *Preconditions:*
             # All the Lorem Ipsum generators on the Internet
             # tend to repeat predefined chunks as necessary, (x xx xxxx)
             # making this the first true generator on the Internet.
             # It uses a dictionary of over 200 Latin words,
             # combined with a handful of model sentence structures,

            *Test case:*
             1. to generate Lorem Ipsum which looks reasonable -> generated Lorem Ipsum -> is therefore always free from repetition (xxx xxxx)
             2. [injected humour], or non-characteristic words etc.
             3. Lorem ipsum dolor sit amet, consectetur [adipiscing] elit
             4.  sed do eiusmod [tempor] incididunt ut 'labore' et dolore magna aliqua
             5. Ut enim ad minim veniam,
             6. Quis nostrud exercitation ullamco laboris

            *ER =* Duis aute irure dolor in reprehenderit: [Voluptate Velit].[dolore] = eu fugiat nulla pariatur

            *AR =* Excepteur sint occaecat Cupidatat

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
            1. Sed ut perspiciatis unde omnis iste
            2. Natus error sit voluptatem accusantium doloremque

            *Test Steps*
            1. laudantium, totam → rem aperiam → eaque ipsa → 'quae ab illo ' 
            2. inventore veritatis et quasi architecto beatae

            *ER* = Nemo enim ipsam voluptatem

            *AR* = Neque porro quisquam est, qui dolorem ipsum quia dolor sit

            !image-2020-09-04-18-45-10-682.png|thumbnail!

            [http://xxxx.xxx:0000/xxx/xxx.jsp?xxx=xxxx#xxxXxx=xxx;xxxXxx=xxxxxx]
            Ut enim ad minima veniam, quis nostrum exercitationem"
        )
      )
    end

    test "tc ar er case 5" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            *Preconditions*
            1. But I must explain to you how all
            2. this mistaken idea of denouncing pleasure

            *Test Steps*
            1. And praising → pain was → born and I will give
            2. Nor again is there anyone who loves or pursues or desires to obtain pain

            *ER* = To take a trivial example,

            *AR* = Which of us ever undertakes laborious physical exercise

            !image-2020-xx-xx-xx-xx-xx-xxx.png|thumbnail!

            [http://xxx.xxx:0000/xxx/xxx.jsp?xxx=xxxx;xxxXx=4428;xxxXx=xxxx]
            except to obtain some advantage from it? "
        )
      )
    end

    test "tc ar er case 6" do
      assert Testcase.new.passed(
        OpenStruct.new(
          description: "
            [https://xxxx.xxxx.xxx.com/]

            *Precondition:* But who has any right to find fault with a man who chooses

            *TC:*
             # njoy a pleasure that has no annoying consequences, : [yyyyyy.zzz.com|https://xxx.yyyy.com/]
             # At vero eos et accusamus et iusto odio dignissimos: 8443286573113926860
             # ducimus qui blanditiis [praesentium]
             # Et harum quidem rerum facilis est et expedita distinctio.
             # Nam libero tempore, cum soluta nobis est eligendi

            *ER:* omnis voluptas assumenda est,

            *AR:* omnis dolor repellendus.

            [^screenshot-1.png]"
        )
      )
    end
  end
end
