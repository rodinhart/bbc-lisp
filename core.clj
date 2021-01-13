(def fmap (fn (f coll)
  (fn (step init)
    (coll
      (fn (r x) ((f x) step r))
      init))))

(def fol_ (fn (f init xs)
  (if xs
    (fol_ f (f init (car xs)) (cdr xs))
    init)))

(def fold (fn (xs)
  (fn (step init)
    (fol_ step init xs))))

(def reify (fn (coll)
  (coll (fn (r x) (cons x r)) nil)))

(def and (fn (p q r)
  (if p
    (if q
      (if r
        1
        nil)
      nil)
    nil)))

(def saf_ (fn (q rank file)
  (and
    (!= (car q) rank)
    (!= (car (cdr q)) file)
    (!=
      (abs (- (car q) rank))
      (abs (- (car (cdr q)) file))))))

(def safe (fn (bord rank file)
  (if bord
    (if (saf_ bord rank file)
      (safe (cdr (cdr bord)) rank file)
      nil)
    1)))

(def range (fold (quote (1 2 3 4 5 6 7))))
(def empty (fold nil))

(def iter (fn (brds rank) (reify (fmap
  (fn (file) (fmap
    (fn (bord) (if (safe bord rank file)
      (fold (cons (cons rank (cons file bord)) nil))
      empty))
    (fold brds)))
  range))))

(range
  (fn (brds rank) (iter brds rank))
  (cons nil nil))