format ELF64 executable 3
entry start

segment readable executable

start:
    mov rax, rdi
    cmp rax, 3
    jne .exit

    mov r12, [rsi + 8]
    mov r13, [rsi + 16]

    mov rax, 80
    mov rdi, r12
    syscall

    xor r14, r14
    mov rsi, r13
.conv_loop:
    movzx rax, byte [rsi]
    test al, al
    jz .conv_done
    cmp al, '0'
    jb .conv_done
    cmp al, '9'
    ja .conv_done
    imul r14, 10
    add r14, rax
    sub r14, '0'
    inc rsi
    jmp .conv_loop
.conv_done:

    mov rcx, r14
    test rcx, rcx
    jz .exit

.loop:
    mov rax, 83
    mov rdi, r12
    mov rsi, 755o
    syscall

    mov rax, 80
    mov rdi, r12
    syscall

    loop .loop

.exit:
    mov rax, 60
    mov rdi, 0
    syscall
