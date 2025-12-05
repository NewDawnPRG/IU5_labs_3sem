format ELF64 executable 3
entry begin

SYS_WRITE   = 1
SYS_EXIT    = 60
SYS_CLONE   = 56
SYS_WAITPID = 61

CLONE_VM    = 0x00000100
CLONE_FS    = 0x00000200
CLONE_FILES = 0x00000400
CLONE_SIGHAND = 0x00000800
SIGCHLD     = 17

STACKSIZE = 4096

segment readable executable

begin:
    mov rcx, [rsp]
    cmp rcx, 2
    jl bad_args

    mov rsi, [rsp+16]
    mov rdi, rsi
    call str_to_num
    mov [limit], rax

    mov qword [plus_part], 0
    mov qword [minus_part], 0

    mov rax, SYS_CLONE
    mov rdi, CLONE_VM or CLONE_FS or CLONE_FILES or CLONE_SIGHAND or SIGCHLD
    mov rsi, stack1 + STACKSIZE
    xor rdx, rdx
    xor r10, r10
    xor r8, r8
    xor r9, r9
    syscall

    test rax, rax
    jz first_thread

    mov [tid1], rax

    mov rax, SYS_CLONE
    mov rdi, CLONE_VM or CLONE_FS or CLONE_FILES or CLONE_SIGHAND or SIGCHLD
    mov rsi, stack2 + STACKSIZE
    xor rdx, rdx
    xor r10, r10
    xor r8, r8
    xor r9, r9
    syscall

    test rax, rax
    jz second_thread

    mov [tid2], rax

wait1:
    mov rax, SYS_WAITPID
    mov rdi, [tid1]
    xor rsi, rsi
    xor rdx, rdx
    syscall

wait2:
    mov rax, SYS_WAITPID
    mov rdi, [tid2]
    xor rsi, rsi
    xor rdx, rdx
    syscall

    mov rax, [plus_part]
    sub rax, [minus_part]

    call output_num

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

bad_args:
    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, errmsg
    mov rdx, errlen
    syscall

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

first_thread:
    mov rcx, 0
    mov r8, [limit]

loop1:
    cmp rcx, r8
    jg finish1

    cmp rcx, 3
    jl add_num

    mov rax, rcx
    sub rax, 3
    xor rdx, rdx
    mov rbx, 4
    div rbx

    cmp rdx, 2
    jge add_num
    jmp next1

add_num:
    mov rax, rcx
    lock add [plus_part], rax

next1:
    inc rcx
    jmp loop1

finish1:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

second_thread:
    mov rcx, 0
    mov r8, [limit]

loop2:
    cmp rcx, r8
    jg finish2

    cmp rcx, 3
    jl skip2

    mov rax, rcx
    sub rax, 3
    xor rdx, rdx
    mov rbx, 4
    div rbx

    cmp rdx, 2
    jge skip2

sub_num:
    mov rax, rcx
    lock add [minus_part], rax

skip2:
    inc rcx
    jmp loop2

finish2:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

str_to_num:
    xor rax, rax
    xor rcx, rcx

process_char:
    mov cl, byte [rdi]
    test cl, cl
    jz stn_done

    cmp cl, '0'
    jl stn_bad
    cmp cl, '9'
    jg stn_bad

    sub cl, '0'
    imul rax, 10
    add rax, rcx

    inc rdi
    jmp process_char

stn_bad:
    mov rax, -1

stn_done:
    ret

output_num:
    push rbx
    push r12
    push r13

    mov r12, rax
    mov r13, 0

    test r12, r12
    jns pos_num
    neg r12
    mov r13, 1

pos_num:
    sub rsp, 32
    mov rbx, rsp
    add rbx, 31
    mov byte [rbx], 0

    test r12, r12
    jnz conv_start
    dec rbx
    mov byte [rbx], '0'
    jmp sign_check

conv_start:
    mov rax, r12
    mov rcx, 10

conv_loop:
    dec rbx
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rbx], dl
    test rax, rax
    jnz conv_loop

sign_check:
    cmp r13, 1
    jne print_now
    dec rbx
    mov byte [rbx], '-'

print_now:
    mov rdx, rsp
    add rdx, 32
    sub rdx, rbx

    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, rbx
    syscall

    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    add rsp, 32
    pop r13
    pop r12
    pop rbx
    ret

segment readable writeable

limit       dq 0
plus_part   dq 0
minus_part  dq 0
tid1        dq 0
tid2        dq 0

errmsg   db "Need argument N", 10
errlen   = $ - errmsg
nl       db 10

stack1 rb STACKSIZE
stack2 rb STACKSIZE
