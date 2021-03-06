;;; punify --- Display Scheme code w/o unnecessary comments / whitespace

;; 	Copyright (C) 2001, 2006 Free Software Foundation, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public
;; License along with this software; see the file COPYING.LESSER.  If
;; not, write to the Free Software Foundation, Inc., 51 Franklin
;; Street, Fifth Floor, Boston, MA 02110-1301 USA

;;; Author: Thien-Thi Nguyen

;;; Commentary:

;; Usage: punify FILE1 FILE2 ...
;;
;; Each file's forms are read and written to stdout.
;; The effect is to remove comments and much non-essential whitespace.
;; This is useful when installing Scheme source to space-limited media.
;;
;; Example:
;; $ wc ./punify ; ./punify ./punify | wc
;;     89     384    3031 ./punify
;;      0      42     920
;;
;; TODO: Read from stdin.
;;       Handle vectors.
;;       Identifier punification.

;;; Code:

(define-module (scripts punify)
  :export (punify))

(define %include-in-guild-list #f)
(define %summary "Strip comments and whitespace from a Scheme file.")

(define (write-punily form)
  (cond ((and (list? form) (not (null? form)))
         (let ((first (car form)))
           (display "(")
           (write-punily first)
           (let loop ((ls (cdr form)) (last-was-list? (list? first)))
             (if (null? ls)
                 (display ")")
                 (let* ((new-first (car ls))
                        (this-is-list? (list? new-first)))
                   (and (not last-was-list?)
                        (not this-is-list?)
                        (display " "))
                   (write-punily new-first)
                   (loop (cdr ls) this-is-list?))))))
        ((and (symbol? form)
              (let ((ls (string->list (symbol->string form))))
                (and (char=? (car ls) #\:)
                     (not (memq #\space ls))
                     (list->string (cdr ls)))))
         => (lambda (symbol-name-after-colon)
              (display #\:)
              (display symbol-name-after-colon)))
        (else (write form))))

(define (punify-one file)
  (with-input-from-file file
    (lambda ()
      (let ((toke (lambda () (read (current-input-port)))))
        (let loop ((form (toke)))
          (or (eof-object? form)
              (begin
                (write-punily form)
                (loop (toke)))))))))

(define (punify . args)
  (for-each punify-one args))

(define main punify)

;;; punify ends here
