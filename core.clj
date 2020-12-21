(def rat (fn (d n)
  (cons
    (/ d (gcd d n))
    (/ n (gcd d n)))))
(def nume car)
(def deno cdr)

(def add (fn (a b)
  (rat
    (+ (* (nume a) (deno b)) (* (nume b) (deno a)))
    (* (deno a) (deno b)))))

(def x (rat 1 2))
(def y (rat 1 4))
(def z (add x y))

(prn (cons (nume z) (cons (deno z) nil)))