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
    call calculate_sum
    call print

calculate_sum:
    mov rbx, rax
    xor rsi, rsi
    mov rcx, 1

.loop:
    cmp rcx, rbx
    jg .done

    mov rax, rcx
    add rax, 3
    xor rdx, rdx
    mov r8, 4
    div r8

    cmp rdx, 2
    jl .positive

.negative:
    mov rax, rcx
    sub rsi, rax
    jmp .next

.positive:
    mov rax, rcx
    add rsi, rax

.next:
    inc rcx
    jmp .loop

.done:
    ret

print:
    test rsi, rsi
    jns .positive_number

    push rsi
    mov rax, '-'
    call print_symbl
    pop rsi
    neg rsi

.positive_number:
    mov rax, rsi
    mov rcx, 10
    xor rbx, rbx
    iter1:
      xor rdx, rdx
      div rcx
      add rdx, '0'
      push rdx
      inc rbx
      cmp rax, 0
    jne iter1
    iter2:
      pop rax
      call print_symbl
      dec rbx
      cmp rbx, 0
    jne iter2
 mov rax, 0xA
 call print_symbl
 call exit
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
