# TODO

## Code

- [x] vars:
    - [x] Var
    - [x] RangeVar
    - [x] SetVar
    - [x] VarVar
    - [x] VarFactory
- [ ] methods:
    - [ ] MethodFactory
    - [ ] Method
    - [ ] RubyMethod
- [ ] main:
    - [x] ExpParser
    - [x] ExpStr
    - [ ] Parser
    - [ ] Runner
- [ ] tests

## Parser

While parsing, break out into parts into an array:

- ['bb.com/', Var('[05-]'), ' bb ', Var('[u=1-4]'), ...]

This is the job of the Parser class.
