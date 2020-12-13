(def zip (fn (f xs ys)
  (if xs
    (cons
      (f (car xs) (car ys))
      (zip f (cdr xs) (cdr ys))
    )
    nil
  )
))

(zip + (quote (1 2 3)) (quote (4 5 6)))

nil