- result of compare etc to be flags?
- CMP BLO or CMP BEQ

- need branch always for relocatable loops
- top of stack kept in memory (direct pointer access)?
- internalize symbols for speed?

| lisp              | forth                                           | cost | after |
| ----------------- | ----------------------------------------------- | ---- | ----- |
| 42                | PUSH 42                                         | 5    | 8     |
| x                 | PUSH x GET                                      | 5    | 9     |
| (+ x 1)           | PUSH 1 PUSH x GET ADD                           | 30   | 18    |
| (fn (x) (\* x x)) | PUSH x SET PUSH y SET PUSH y GET PUSH x GET ADD | 60   | 37    |
| 'x                | PUSH x                                          | 5    | 8     |