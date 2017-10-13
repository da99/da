
da\_html.cr
=========

Compile time checking of HTML dsl: Don't do it!:

  * Too difficult.
  * Leads to more brittle code: Nim's macros == lots of AST code.
  * You create *TWO* code-bases: runtime and compile time.
    * That's more stuff to maintain.

Final solution for HTML verification:
  * Easiest and more effective: Unit testing.
    * Allows flexibility in implementations.
    * Write code, test, automate creation of valid/invalid test data.

