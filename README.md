

#Universal Binary Format#

<pre>This is UBF, a framework for Getting Erlang to talk to the outside
world.  This repository is based on Joe Armstrong's original UBF code
with an MIT license file added to the distribution.  Since then, a
large number of enhancements and improvements have been added.


What is UBF?
============

UBF is the "Universal Binary Format", designed and implemented by Joe
Armstrong.  UBF is a language for transporting and describing complex
data structures across a network.  It has three components:

   * UBF(A) is a "language neutral" data transport format, roughly
     equivalent to well-formed XML.

   * UBF(B) is a programming language for describing types in UBF(A)
     and protocols between clients and servers.  This layer is
     typically called the "protocol contract".  UBF(B) is roughly
     equivalent to Verified XML, XML-schemas, SOAP and WDSL.

   * UBF(C) is a meta-level protocol used between a UBF client and a
     UBF server.

See http://norton.github.com/ubf for further details.


Quick Start Recipe
==================

To download, build, and test the ubf application in one shot, please
follow this recipe:

    $ mkdir working-directory-name
    $ cd working-directory-name
    $ git clone git://github.com/norton/ubf.git ubf
    $ cd ubf
    $ ./rebar get-deps
    $ ./rebar clean
    $ ./rebar compile
    $ ./rebar eunit

For an alternative recipe with other "features" albeit more complex,
please read further.


To download
===========

1. Configure your e-mail and name for Git

    $ git config --global user.email "you@example.com"
    $ git config --global user.name "Your Name"

2. Install Repo

    $ mkdir -p ~/bin
    $ wget -O - https://github.com/android/tools_repo/raw/master/repo > ~/bin/repo
    $ perl -i.bak -pe 's!git://android.git.kernel.org/tools/repo.git!git://github.com/android/tools_repo.git!;' ~/bin/repo
    $ chmod a+x ~/bin/repo

    CAUTION: Since access to kernel.org has been shutdown due to
    hackers, fetch and replace repo tool with android's GitHub
    repository mirror.

3. Create working directory

    $ mkdir working-directory-name
    $ cd working-directory-name
    $ repo init -u git://github.com/norton/manifests.git -m ubf-default.xml

    NOTE: Your "Git" identity is needed during the init step.  Please
    enter the name and email of your GitHub account if you have one.
    Team members having read-write access are recommended to use "repo
    init -u git@github.com:norton/manifests.git -m
    ubf-default-rw.xml".

    TIP: If you want to checkout the latest development version of
    UBF, please append " -b dev" to the repo init command.

4. Download Git repositories

    $ cd working-directory-name
    $ repo sync

For futher information and help for related tools, please refer to the
following links:

- Erlang - http://www.erlang.org/
  * *R13B04 or newer, R14B03 has been tested most recently*
- Git - http://git-scm.com/
  * *Git 1.5.4 or newer, Git 1.7.6.1 has been tested recently*
  * _required for Repo and GitHub_
- GitHub - https://github.com
- Python - http://www.python.org
  * *Python 2.4 or newer, Python 2.7.1 has been tested most recently
     (CAUTION: Python 3.x might be too new)*
  * _required for Repo_
- Rebar - https://github.com/basho/rebar/wiki
- Repo - http://source.android.com/source/git-repo.html


To build - basic recipe
=======================

1. Get and install an erlang system
   http://www.erlang.org

2. Build UBF
   $ cd working-directory-name/src
   $ make compile

3. Run the unit tests
   $ cd working-directory-name/src
   $ make eunit


To build - optional features
============================

A. Dialyzer Testing _basic recipe_

   A.1. Build Dialyzer's PLT _(required once)_

   $ cd working-directory-name/src
   $ make build-plt

   TIP: Check Makefile and dialyzer's documentation for further
   information.

   A.2. Dialyze with specs

   $ cd working-directory-name/src
   $ make dialyze

   CAUTION: If you manually run dialyzer with the "-r" option, execute
   "make clean compile" first to avoid finding duplicate beam files
   underneath rebar's .eunit directory.  Check Makefile for further
   information.

   A.3. Dialyze without specs

   $ cd working-directory-name/src
   $ make dialyze-nospec

B. To build the Java client and run its encoding/decoding unit test:

   $ cd working-directory-name/src
   $ make -C lib/ubf/priv/java

C. The Python client depends on the "py-interface" library.  To clone
   and build it, use:

   $ cd working-directory-name
   $ git clone git://repo.or.cz/py_interface.git
   $ cd py_interface
   $ autoconf
   $ make

   Then install as a normal Python package or run using
   "env PYTHONPATH=working-directory-name/py_interface python your-script.py"


Documentation -- Where should I start?
======================================

This README is a good first step.  Check out and build using the "To
build" instructions above.

The UBF User's Guide is the best next step.  Check out
http://norton.github.com/ubf/ubf-user-guide.en.html for further
detailed information.

The documentation is in a state of slow improvement.  Contributions
from the wider world are welcome.  :-)

One of the better places to start is to look in the "edoc" directory.
See the "Reference Documentation" section for suggestions on where to
find greater detail.

The unit tests in the "test/unit" directory provide small
examples of how to use all of the public API.  In particular, the
*client*.erl files contain comments at the top with a list of
prerequisites and small examples, recipe-style, for starting each
server and using the client.

The eunit tests in the "test/eunit" directory perform
several smoke and error handling uses cases.

The #1 most frequently asked question is: "My term X fails contract
Y, but I can't figure out why!  This X is perfectly OK.  What is going
on?"  See the the EDoc documentation for the contracts:checkType/3
function.


What is EBF?
============

EBF is an implementation of UBF(B) but does not use UBF(A) for
client<->server communication.  Instead, Erlang-style conventions are
used instead:

   * Structured terms are serialized via the Erlang BIFs
     term_to_binary() and binary_to_term().

   * Terms are framed using the 'gen_tcp' {packet, 4} format: a 32-bit
     unsigned integer (big-endian?) specifies packet length.

     +-------------------------+-------------------------------+
     | Packet length (32 bits) | Packet data (variable length) |
     +-------------------------+-------------------------------+

The name "EBF" is short for "Erlang Binary Format".


What about JSF and JSON-RPC?
============================

See the ubf-jsonrpc open source repository
http://github.com/norton/ubf-jsonrpc for details.  ubf-jsonrpc is a
framework for integrating UBF, JSF, and JSON-RPC.


What about TBF and Thrift?
==========================

See the ubf-thrift open source repository
http://github.com/norton/ubf-thrift for details.  ubf-thrift is a
framework for integrating UBF, TBF, and Thrift.


What about ABNF?
================

See the ubf-abnf open source repository
http://github.com/norton/ubf-abnf for details.  ubf-abnf is a
framework for integrating UBF and ABNF.


What about EEP8?
================

See the ubf-eep8 open source repository
http://github.com/norton/ubf-eep8 for details.  ubf-eep8 is a
framework for integrating UBF and EEP8.


To do (in medium term)
======================
  - quickcheck tests

To do (in long term)
====================
  - add more Thrift (http://incubator.apache.org/thrift/) support
    * Compact Format
  - add Avro (http://hadoop.apache.org/avro/) support
  - add Google's Protocol Buffers (http://code.google.com/apis/protocolbuffers/) support
  - add Bert-RPC (http://bert-rpc.org/) support
    * BERT-RPC is UBF/EBF with a specialized contract and plugin
      handler implementation for BERT-RPC. UBF/EBF already supports all
      of the BERT data types.
    * UBF is the text-based wire protocol.  EBF is the binary-based
      wire protocol (based on Erlang's binary serialization format).
  - support multiple listeners for a single ubf server
  - n-bidirectional requests/responses over single tcp/ip connection (similar to smpp)
  - replace plugin manager and plugin handler with gen_server-based
    implementation
  - enable/disable contract checker by configuration


Credits
=======

Many, many thanks to Joe Armstrong, UBF's designer and original
implementor.

Gemini Mobile Technologies, Inc. has approved the release of its
extensions, improvements, etc. under an MIT license.  Joe Armstrong
has also given his blessing to Gemini's license choice.</pre>.
<pre>This is UBF, a framework for Getting Erlang to talk to the outside
world.  This repository is based on Joe Armstrong's original UBF code
with an MIT license file added to the distribution.  Since then, a
large number of enhancements and improvements have been added.


What is UBF?
============

UBF is the "Universal Binary Format", designed and implemented by Joe
Armstrong.  UBF is a language for transporting and describing complex
data structures across a network.  It has three components:

   * UBF(A) is a "language neutral" data transport format, roughly
     equivalent to well-formed XML.

   * UBF(B) is a programming language for describing types in UBF(A)
     and protocols between clients and servers.  This layer is
     typically called the "protocol contract".  UBF(B) is roughly
     equivalent to Verified XML, XML-schemas, SOAP and WDSL.

   * UBF(C) is a meta-level protocol used between a UBF client and a
     UBF server.

See http://norton.github.com/ubf for further details.


Quick Start Recipe
==================

To download, build, and test the ubf application in one shot, please
follow this recipe:

    $ mkdir working-directory-name
    $ cd working-directory-name
    $ git clone git://github.com/norton/ubf.git ubf
    $ cd ubf
    $ ./rebar get-deps
    $ ./rebar clean
    $ ./rebar compile
    $ ./rebar eunit

For an alternative recipe with other "features" albeit more complex,
please read further.


To download
===========

1. Configure your e-mail and name for Git

    $ git config --global user.email "you@example.com"
    $ git config --global user.name "Your Name"

2. Install Repo

    $ mkdir -p ~/bin
    $ wget -O - https://github.com/android/tools_repo/raw/master/repo > ~/bin/repo
    $ perl -i.bak -pe 's!git://android.git.kernel.org/tools/repo.git!git://github.com/android/tools_repo.git!;' ~/bin/repo
    $ chmod a+x ~/bin/repo

    CAUTION: Since access to kernel.org has been shutdown due to
    hackers, fetch and replace repo tool with android's GitHub
    repository mirror.

3. Create working directory

    $ mkdir working-directory-name
    $ cd working-directory-name
    $ repo init -u git://github.com/norton/manifests.git -m ubf-default.xml

    NOTE: Your "Git" identity is needed during the init step.  Please
    enter the name and email of your GitHub account if you have one.
    Team members having read-write access are recommended to use "repo
    init -u git@github.com:norton/manifests.git -m
    ubf-default-rw.xml".

    TIP: If you want to checkout the latest development version of
    UBF, please append " -b dev" to the repo init command.

4. Download Git repositories

    $ cd working-directory-name
    $ repo sync

For futher information and help for related tools, please refer to the
following links:

- Erlang - http://www.erlang.org/
  * *R13B04 or newer, R14B03 has been tested most recently*
- Git - http://git-scm.com/
  * *Git 1.5.4 or newer, Git 1.7.6.1 has been tested recently*
  * _required for Repo and GitHub_
- GitHub - https://github.com
- Python - http://www.python.org
  * *Python 2.4 or newer, Python 2.7.1 has been tested most recently
     (CAUTION: Python 3.x might be too new)*
  * _required for Repo_
- Rebar - https://github.com/basho/rebar/wiki
- Repo - http://source.android.com/source/git-repo.html


To build - basic recipe
=======================

1. Get and install an erlang system
   http://www.erlang.org

2. Build UBF
   $ cd working-directory-name/src
   $ make compile

3. Run the unit tests
   $ cd working-directory-name/src
   $ make eunit


To build - optional features
============================

A. Dialyzer Testing _basic recipe_

   A.1. Build Dialyzer's PLT _(required once)_

   $ cd working-directory-name/src
   $ make build-plt

   TIP: Check Makefile and dialyzer's documentation for further
   information.

   A.2. Dialyze with specs

   $ cd working-directory-name/src
   $ make dialyze

   CAUTION: If you manually run dialyzer with the "-r" option, execute
   "make clean compile" first to avoid finding duplicate beam files
   underneath rebar's .eunit directory.  Check Makefile for further
   information.

   A.3. Dialyze without specs

   $ cd working-directory-name/src
   $ make dialyze-nospec

B. To build the Java client and run its encoding/decoding unit test:

   $ cd working-directory-name/src
   $ make -C lib/ubf/priv/java

C. The Python client depends on the "py-interface" library.  To clone
   and build it, use:

   $ cd working-directory-name
   $ git clone git://repo.or.cz/py_interface.git
   $ cd py_interface
   $ autoconf
   $ make

   Then install as a normal Python package or run using
   "env PYTHONPATH=working-directory-name/py_interface python your-script.py"


Documentation -- Where should I start?
======================================

This README is a good first step.  Check out and build using the "To
build" instructions above.

The UBF User's Guide is the best next step.  Check out
http://norton.github.com/ubf/ubf-user-guide.en.html for further
detailed information.

The documentation is in a state of slow improvement.  Contributions
from the wider world are welcome.  :-)

One of the better places to start is to look in the "edoc" directory.
See the "Reference Documentation" section for suggestions on where to
find greater detail.

The unit tests in the "test/unit" directory provide small
examples of how to use all of the public API.  In particular, the
*client*.erl files contain comments at the top with a list of
prerequisites and small examples, recipe-style, for starting each
server and using the client.

The eunit tests in the "test/eunit" directory perform
several smoke and error handling uses cases.

The #1 most frequently asked question is: "My term X fails contract
Y, but I can't figure out why!  This X is perfectly OK.  What is going
on?"  See the the EDoc documentation for the contracts:checkType/3
function.


What is EBF?
============

EBF is an implementation of UBF(B) but does not use UBF(A) for
client<->server communication.  Instead, Erlang-style conventions are
used instead:

   * Structured terms are serialized via the Erlang BIFs
     term_to_binary() and binary_to_term().

   * Terms are framed using the 'gen_tcp' {packet, 4} format: a 32-bit
     unsigned integer (big-endian?) specifies packet length.

     +-------------------------+-------------------------------+
     | Packet length (32 bits) | Packet data (variable length) |
     +-------------------------+-------------------------------+

The name "EBF" is short for "Erlang Binary Format".


What about JSF and JSON-RPC?
============================

See the ubf-jsonrpc open source repository
http://github.com/norton/ubf-jsonrpc for details.  ubf-jsonrpc is a
framework for integrating UBF, JSF, and JSON-RPC.


What about TBF and Thrift?
==========================

See the ubf-thrift open source repository
http://github.com/norton/ubf-thrift for details.  ubf-thrift is a
framework for integrating UBF, TBF, and Thrift.


What about ABNF?
================

See the ubf-abnf open source repository
http://github.com/norton/ubf-abnf for details.  ubf-abnf is a
framework for integrating UBF and ABNF.


What about EEP8?
================

See the ubf-eep8 open source repository
http://github.com/norton/ubf-eep8 for details.  ubf-eep8 is a
framework for integrating UBF and EEP8.


To do (in medium term)
======================
  - quickcheck tests

To do (in long term)
====================
  - add more Thrift (http://incubator.apache.org/thrift/) support
    * Compact Format
  - add Avro (http://hadoop.apache.org/avro/) support
  - add Google's Protocol Buffers (http://code.google.com/apis/protocolbuffers/) support
  - add Bert-RPC (http://bert-rpc.org/) support
    * BERT-RPC is UBF/EBF with a specialized contract and plugin
      handler implementation for BERT-RPC. UBF/EBF already supports all
      of the BERT data types.
    * UBF is the text-based wire protocol.  EBF is the binary-based
      wire protocol (based on Erlang's binary serialization format).
  - support multiple listeners for a single ubf server
  - n-bidirectional requests/responses over single tcp/ip connection (similar to smpp)
  - replace plugin manager and plugin handler with gen_server-based
    implementation
  - enable/disable contract checker by configuration


Credits
=======

Many, many thanks to Joe Armstrong, UBF's designer and original
implementor.

Gemini Mobile Technologies, Inc. has approved the release of its
extensions, improvements, etc. under an MIT license.  Joe Armstrong
has also given his blessing to Gemini's license choice.</pre>


##Modules##


<table width="100%" border="0" summary="list of modules">
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contract_driver.md" class="module">contract_driver</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contract_lex.md" class="module">contract_lex</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contract_manager.md" class="module">contract_manager</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contract_manager_tlog.md" class="module">contract_manager_tlog</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contract_parser.md" class="module">contract_parser</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contract_proto.md" class="module">contract_proto</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contract_yecc.md" class="module">contract_yecc</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contracts.md" class="module">contracts</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/contracts_abnf.md" class="module">contracts_abnf</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ebf.md" class="module">ebf</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ebf_driver.md" class="module">ebf_driver</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/proc_socket_server.md" class="module">proc_socket_server</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/proc_utils.md" class="module">proc_utils</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf.md" class="module">ubf</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_client.md" class="module">ubf_client</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_driver.md" class="module">ubf_driver</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_plugin_handler.md" class="module">ubf_plugin_handler</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_plugin_meta_stateful.md" class="module">ubf_plugin_meta_stateful</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_plugin_meta_stateless.md" class="module">ubf_plugin_meta_stateless</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_plugin_stateful.md" class="module">ubf_plugin_stateful</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_plugin_stateless.md" class="module">ubf_plugin_stateless</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_server.md" class="module">ubf_server</a></td></tr>
<tr><td><a href="https://github.com/norton/ubf/blob/master/doc/ubf_utils.md" class="module">ubf_utils</a></td></tr></table>

