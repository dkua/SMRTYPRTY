(assign val (op make-compiled-procedure) (label entry1) (reg env))
(goto (label after-lambda2))

entry1
(assign env (op compiled-procedure-env) (reg proc))
(assign env (op extend-environment) (const (x y)) (reg argl) (reg env))
(assign arg1 (op lookup-variable-value) (const x) (reg env))
(assign arg2 (op lookup-variable-value) (const y) (reg env))
(assign arg1 (op +) (reg arg1) (reg arg2))
(save arg1)
(assign arg1 (op lookup-variable-value) (const x) (reg env))
(assign arg2 (op lookup-variable-value) (const y) (reg env))
(assign arg2 (op -) (reg arg1) (reg arg2))
(restore arg1)
(assign val (op *) (reg arg1) (reg arg2))
(goto (reg continue))

after-lambda2
(perform (op define-variable!) (const f) (reg val) (reg env))
(assign val (const ok))
