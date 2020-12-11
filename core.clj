(def len (fn (xs)
  (if xs
    (+ 1 (len (cdr xs)))
    0)))

(len (quo (1 1 1 1 1)))