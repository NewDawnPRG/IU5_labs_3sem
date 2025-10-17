format ELF64
public _start

include 'func.asm'

_start:
    mov rsi, [rsp + 16]
    call str_number
    mov rbx, rax
    test rbx, 1
    jz .print_error
    call calculate_sum
    call print

.print_error:
    mov rsi, error_msg
    mov rdx, 5
    mov rax, 1
    mov rdi, 1
    syscall
    call exit

calculate_sum:
    mov rbx, rax
    xor rsi, rsi
    mov rcx, 1

.loop:
    cmp rcx, rbx
    jg .done

    mov rax, rcx
    add rsi, rax

.next:
    add rcx, 2
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
error_msg db "error", 0xA
