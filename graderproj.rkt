#lang racket

;;;; Michael Wright
;;;; mswvgc@umsystem.edu
;;;; 03/10/2023
;;;; CS490 Program 1

;; Reads a file and return a list of lists representing the file contents.
(define (process-file file-path)
  
  ;; Reads the contents of a file and stores it into a string
  (define input-string
    (call-with-input-file file-path (lambda (input-port) (port->string input-port))))

  ;; Splits the input string into a list of lines
  (define lines (string-split input-string "\n"))

  ;; Splits each line into a list of substrings
  (define result
    (map (lambda (line)
           (string-split line))
         lines))

  result) ; Return the list of lists


;; Sorts by last name and then first name
;; Uses selection sort recursively 
(define (sort-name lst)

  ;; Gets last name
  (define (lastname stringlist)
    (first (rest stringlist)))

  ;; Gets first name
  (define (firstname stringlist)
    (first stringlist))

  ;; Sorts as "lastname firstname"
  (define (sortname stringlist)
    (string-append (lastname stringlist) " " (firstname stringlist)))

  ;; Compares two strings using a comparison function
  (define (min-str str1 str2 lt-func)
    (if (lt-func str1 str2) str1 str2))

  ;; Finds minimum value based on last name 
  (define (min-name lst sel)
    (define (iter lst m)
      (cond
        [(empty? lst) m]
        [else  (iter (rest lst) (min-str m (sel (first lst)) string-ci<?))]))
    (iter lst "zzzzzzzzzzzzzzzzz"))
  
  (if (< (length lst) 2)
      lst
      (let
          ([m (min-name lst sortname)])
          (append (filter (lambda (x) (string-ci=? (sortname x) m)) lst)
                  (sort-name (filter (lambda (x) (string-ci<? m (sortname x))) lst))))))

;; Computes average exam and quiz scores
;; Floating point values
(define (compute-avgs lst)
  
  (define (avg-scores lst)
    (let ([nums (map string->number lst)])
      (exact->inexact (/ (apply + nums) (length nums)))))
  
  (if (empty? lst)
      empty
      (let*
          ([first-name (list-ref lst 0)]
          [last-name (list-ref lst 1)]
          ; Compute quiz and exam averages
          [quiz-scores (list (list-ref lst 2)
                             (list-ref lst 3)
                             (list-ref lst 4)
                             (list-ref lst 5)
                             (list-ref lst 6))]
          [exam-scores (list (list-ref lst 7)
                             (list-ref lst 8)
                             (list-ref lst 9))]
          [quiz-avg (avg-scores quiz-scores)]
          [exam-avg (avg-scores exam-scores)])
        
          (list first-name last-name quiz-avg exam-avg))))

;; Computes final grade and letter grade
(define (compute-final-grade-with-letter lst)

  ;; Assign letter grade based on score
  (define (get-letter-grade score)
    (cond ((>= score 90) "A")
          ((>= score 80) "B")
          ((>= score 70) "C")
          ((>= score 60) "D")
          (else "F")))
  
  (if (empty? lst)
      empty
      (let*
          ([first-name (list-ref lst 0)]
          [last-name (list-ref lst 1)]
          [quiz-average (list-ref lst 2)]
          [exam-average (list-ref lst 3)]
          ; Compute final grade and letter grade
          [final-grade (+ (* exam-average 0.65) (* quiz-average 0.35))]
          [letter-grade (get-letter-grade final-grade)])
        
          (list first-name last-name final-grade letter-grade))))

;; Formats list for output
(define (prep-for-file lst)
  (define (iter lst so-far)
    (if (empty? lst)
        so-far
        (letrec (
                 [line (first lst)]
                 ; Added letter grade to output (cadddr line)
                 [outline (string-append (car line) " " (cadr line) " " (number->string (caddr line)) " " (cadddr line)  "\n")]) 
          (iter (rest lst) (string-append so-far outline)))))
  (iter lst ""))

;; Read student data from input file
(define starting-list (process-file "/home/mw/Downloads/GradebookData.txt")) 

;; Compute quiz and exam averages
(define average-grade-list (map compute-avgs starting-list))

;; Compute final grades and letter grades
(define final-grade-with-letter-list (map compute-final-grade-with-letter average-grade-list))

;; Sort by name
(define print-out-list (sort-name final-grade-with-letter-list))

;; Opens output file
;; Replaces old file if one already exists
(define out (open-output-file "output1.txt" #:mode 'text #:exists 'replace))

(display (prep-for-file print-out-list) out)  ; Send to output
(close-output-port out)  ; Close file