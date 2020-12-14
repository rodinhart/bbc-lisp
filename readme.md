# bbc-lisp

A cell in the box-pointer model is 32 bits, with the following flavours:

| M = marked by GC                      | type      | description                                       |
| ------------------------------------- | --------- | ------------------------------------------------- |
| `yyyyyyyy yyyyyy00 xxxxxxxx xxxxxx0M` | Cons      | cons(x, y), x and y are pointers to cells         |
| `yyyyyyyy yyyyyy01 xxxxxxxx xxxxxx0M` | Procedure | x is for example ((x y) (+ x y)), y is the env    |
| `yyyyyyyy yyyyyy10 xxxxxxxx xxxxxx0M` | Macro     | x is for example ((a b) (list b a)), y is the env |
| `00000000 00000011 xxxxxxxx xxxxxx0M` | Native    | x = pointer to native routine                     |
| `cccccccd bbbbbbbd aaaaaaad dddd001M` | Symbol    | 7 ASCII chars packed in 28 bits                   |
| `00000000 nnnnnnnn nnnnnnnn 0000011M` | Number    | n = 16 bit unsigned integer                       |
