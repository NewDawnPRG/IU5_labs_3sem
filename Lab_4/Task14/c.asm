format ELF64
public _start

msg dq 256

include 'func.asm'

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, msg
    mov rdx, 256
    syscall

    call str_number
    mov r12, rax
    mov r13, 1

main_loop:
    cmp r13, r12
    jg end_program

    mov rax, r13
    call check_automorphic
    test rax, rax
    jz next_number

    mov rax, r13
    call print_number

next_number:
    inc r13
    jmp main_loop

end_program:
    call exit

check_automorphic:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rbx, rax
    mov rsi, rax

    mov rcx, 0
    mov rdi, 10
.count_digits:
    inc rcx
    xor rdx, rdx
    mov rax, rsi
    div rdi
    mov rsi, rax
    test rax, rax
    jnz .count_digits

    mov rax, 1
    mov rsi, 10
.calc_power:
    test rcx, rcx
    jz .calc_done
    mul rsi
    dec rcx
    jmp .calc_power
.calc_done:
    mov rdi, rax

    mov rax, rbx
    mul rax

    xor rdx, rdx
    div rdi

    cmp rdx, rbx
    je .automorphic
    mov rax, 0
    jmp .done

.automorphic:
    mov rax, 1
.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

print_number:
    push rax
    push rbx
    push rcx
    push rdx

    mov rcx, 10
    xor rbx, rbx

.digit_loop:
    xor rdx, rdx
    div rcx
    add rdx, '0'
    push rdx
    inc rbx
    test rax, rax
    jnz .digit_loop

.print_loop:
    pop rax
    call print_symbl
    dec rbx
    jnz .print_loop

    mov rax, 0xA
    call print_symbl

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

print_symbl:
     push rbx
     push rdx
     push rcx
     push rax
     push rax
     mov rax, 4
     mov rbx, 1
     pop rdx
     mov [place], dl
     mov rcx, place
     mov rdx, 1
     int 0x80
     pop rax
     pop rcx
     pop rdx
     pop rbx
     ret

place db ?
