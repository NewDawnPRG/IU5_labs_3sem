str_number:
    push rcx
    push rbx
    xor rax,rax
    xor rcx,rcx
.loop:
    xor     rbx, rbx
    mov     bl, byte [rsi+rcx]
    cmp     bl, 48
    jl      .finished
    cmp     bl, 57
    jg      .finished
    sub     bl, 48
    add     rax, rbx
    mov     rbx, 10
    mul     rbx
    inc     rcx
    jmp     .loop
.finished:
    cmp     rcx, 0
    je      .restore
    mov     rbx, 10
    div     rbx
.restore:
    pop rbx
    pop rcx
    ret

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
