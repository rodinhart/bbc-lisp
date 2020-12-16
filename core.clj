(def rest (fn (p) ((cdr p))))

(def fold (fn (step init xs)
  (if xs
    (fold step (step init (car xs)) (rest xs))
    init)))

(def take (fn (n xs)
  (if (= n 0)
    nil
    (cons (car xs) (fn () (take (- n 1) (rest xs)))))))

(def zip (fn (f xs ys)
  (cons
    (f (car xs) (car ys))
    (fn () (zip f (rest xs) (rest ys))))))

(def s (fn (a b) (cons a (fn () (s b (+ a b))))))

(fold (fn (_ x) (prn x)) nil (take 10 (s 1 1)))