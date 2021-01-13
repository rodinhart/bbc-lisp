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

(def iter (fn (brds rank) (fmap
  (fn (bord) (fmap
    (fn (file) (if (safe bord rank file)
      (fold (cons (cons rank (cons file bord)) nil))
      empty))
    range))
  brds)))

(def queens (range
  (fn (brds rank) (iter brds rank))
  (fold (cons nil nil))))

(def cls (fn ()
  (list
    (vdu 22 7 23 1 0 0 0 0 0 0 0 0)
    (range
      (fn (r rank) (range
        (fn (s file)
          (vdu 31 rank file 46))
        nil))
      nil)
  )))

(def draw (fn (bord hack)
  (if bord
    (draw (cdr (cdr bord)) (vdu 31 (car (cdr bord)) (car bord) 81))
    nil)))

(queens
  (fn (r x) (draw x (cls)))
  nil)