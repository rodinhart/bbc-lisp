# bbc-lisp

A cell in the box-pointer model is 32 bits, with the following flavours:

```
xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx   type
cccccccd bbbbbbbd aaaaaaad dddd011M   Symbol, 7 ASCII chars packed in 28 bits
```
