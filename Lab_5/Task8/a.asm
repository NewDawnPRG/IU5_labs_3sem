format elf64
public _start

include 'func.asm'

section '.bss' writable
  buffer1 rb 1024
  buffer2 rb 1024
  found_flags rb 256
  temp_char rb 1

section '.text' executable

_start:
  mov rdi, [rsp+16]
  mov rax, 2
  mov rsi, 0
  syscall
  cmp rax, 0
  jl l1
  mov r8, rax

  mov rdi, [rsp + 24]
  mov rax, 2
  mov rsi, 0
  syscall
  cmp rax, 0
  jl l1
  mov r9, rax

  mov rdi, [rsp + 32]
  mov rax, 2
  mov rsi, 577
  mov rdx, 777o
  syscall
  cmp rax, 0
  jl l1
  mov r10, rax

  mov rax, 0
  mov rdi, r8
  mov rsi, buffer1
  mov rdx, 1024
  syscall
  mov r11, rax

  mov rax, 0
  mov rdi, r9
  mov rsi, buffer2
  mov rdx, 1024
  syscall
  mov r12, rax

  xor r14, r14
  mov rdi, found_flags
  mov rcx, 256
  .init_loop:
    mov byte [rdi + rcx - 1], 0
    loop .init_loop

  xor r14, r14
.search_in_f2_init:
  cmp r14, r12
  jge process_f1_start
  movzx rdi, byte [buffer2 + r14]
  mov byte [found_flags + rdi], 1
  inc r14
  jmp .search_in_f2_init

process_f1_start:
  xor r13, r13
.next_char1:
  cmp r13, r11
  jge process_done

  mov al, [buffer1 + r13]
  inc r13
  movzx rdi, al
  cmp byte [found_flags + rdi], 0
  je .next_char1_loop
  cmp byte [found_flags + 512 + rdi], 1
  je .next_char1_loop

  mov byte [found_flags + 512 + rdi], 1
  mov [temp_char], al
  mov rax, 1
  mov rdi, r10
  mov rsi, temp_char
  mov rdx, 1
  syscall

.next_char1_loop:
  jmp .next_char1

process_done:
  mov rdi, r8
  mov rax, 3
  syscall
  mov rdi, r9
  syscall
  mov rdi, r10
  syscall

l1:
  call exit
