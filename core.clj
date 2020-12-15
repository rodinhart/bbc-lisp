(def seq cons)
(def first car)
(def rest (fn (p) ((cdr p))))

(def reify (fn (xs)
  (if xs
    (cons (first xs) (reify (rest xs)))
    nil)))

(def zip (fn (f xs ys)
  (if xs
    (seq
      (f (first xs) (first ys))
      (fn () (zip f (rest xs) (rest ys))))
    nil)))

(def take (fn (n xs)
  (if (= n 0)
    nil
    (if xs
      (seq
        (first xs)
        (fn () (take (- n 1) (rest xs))))
      nil))))

(def s (seq 1 (fn () (seq 1 (fn () (zip + s (rest s)))))))

(reify (take 5 s))