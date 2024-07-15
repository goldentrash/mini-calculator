# Mini Calculator

- for Compiler Class Assignments
- using `Flex` & `Bison`

## Getting Started

```sh
$ flex calc.l
$ bison -d calc.y
$ gcc calc.tab.c lex.yy.c -o calc -lm
$ ./calc < ./input.txt
```
