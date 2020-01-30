# robot-fw-built-in-library-tests

This project contains robot test cases, which aim to use all the available keywords in the Robot FW built-in library:

https://robotframework.org/robotframework/latest/libraries/BuiltIn.html

A test case may fail due to 2 reasons:

* Programmer could not understood the keyword at all. In that case the test case is tagged with 'not-understood' tag.
* Programmer did understand the test case, and he wanted to show a failing example with for a certain builtin library keyword.
 In that case, the test case is tagged with 'failure-expected' tag.
