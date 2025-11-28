format ELF64

include 'func.asm'

public _start

THREAD_FLAGS = 2147585792
ARRLEN = 716

section '.bss' writable
    array rb ARRLEN
    buffer rb 20
    f db "/dev/random", 0
    stack1 rq 4096
    msg1 db "Третье число после максимального:", 0xA, 0
    msg2 db "Количество чисел, сумма цифр кратна 3:", 0xA, 0
    msg3 db "0.75-квантиль:", 0xA, 0
    msg4 db "Количество простых:", 0xA, 0
    msg_array db "Массив:", 0xA, 0

section '.text' executable
_start:
    mov rax, 2
    mov rdi, f
    mov rsi, 0
    syscall
    mov r8, rax

    mov rax, 0
    mov rdi, r8
    mov rsi, array
    mov rdx, ARRLEN
    syscall

    .filter_loop:
        call filter
        cmp rax, 0
        jne .filter_loop

    mov rsi, msg_array
    call print_str
    call new_line
    call print_array

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .quantile_75

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall
    call input_keyboard

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .third_after_max

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall
    call input_keyboard

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .count_sum_digits_div3

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall
    call input_keyboard

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .count_primes

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall
    call input_keyboard

    call exit

.quantile_75:
    mov rsi, msg3
    call print_str
    call new_line

    mov rax, ARRLEN
    mov rbx, 4
    xor rdx, rdx
    div rbx
    mov rbx, 3
    mul rbx
    dec rbx
    mov al, [array + rbx]
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.third_after_max:
    mov rsi, msg1
    call print_str
    call new_line

    mov rax, ARRLEN
    sub rax, 4
    mov al, [array + rax]
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.count_sum_digits_div3:
    mov rsi, msg2
    call print_str
    call new_line

    xor r8, r8
    xor r9, r9

.sum_loop:
    cmp r9, ARRLEN
    jge .sum_done

    mov al, [array + r9]
    movzx rax, al
    xor rbx, rbx
    mov rcx, 10

.sum_digits:
    xor rdx, rdx
    div rcx
    add rbx, rdx
    test rax, rax
    jnz .sum_digits

    mov rax, rbx
    xor rdx, rdx
    mov rcx, 3
    div rcx
    test rdx, rdx
    jnz .skip_inc
    inc r8

.skip_inc:
    inc r9
    jmp .sum_loop

.sum_done:
    mov rax, r8
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.count_primes:
    mov rsi, msg4
    call print_str
    call new_line

    xor r8, r8
    xor r9, r9

.prime_loop:
    cmp r9, ARRLEN
    jge .prime_done

    movzx rax, byte [array + r9]
    cmp rax, 2
    jl .not_prime
    cmp rax, 2
    je .is_prime
    test al, 1
    jz .not_prime

    mov rcx, 3

.prime_test_loop:
    mov rdx, rcx
    imul rdx, rcx
    cmp rdx, rax
    jg .is_prime
    xor rdx, rdx
    mov rbx, rax
    div rcx
    test rdx, rdx
    jz .not_prime
    mov rax, rbx
    add rcx, 2
    jmp .prime_test_loop

.is_prime:
    inc r8

.not_prime:
    inc r9
    jmp .prime_loop

.prime_done:
    mov rax, r8
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

print_array:
    xor r9, r9
    .print_loop:
        cmp r9, ARRLEN
        jge .done
        mov al, [array + r9]
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        inc r9
        jmp .print_loop
    .done:
        ret

filter:
    xor rax, rax
    mov rsi, array
    mov rcx, ARRLEN
    dec rcx
    .check:
        mov dl, [rsi]
        mov dh, [rsi + 1]
        cmp dl, dh
        jbe .ok
        mov [rsi], dh
        mov [rsi + 1], dl
        inc rax
    .ok:
        inc rsi
    loop .check
    ret
