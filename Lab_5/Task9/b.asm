format elf64
public _start

include 'func.asm'

section '.bss' writable
  buffer rb 100
  num_buf rb 100
  buf64 rb 64
  buf2 rb 64
  stro dq 0
  rev_buf rb 100

section '.data' writable
  endfile db '10e', 0

section '.text' executable

_start:
  mov rdi, [rsp+16]
  mov rax, 2
  mov rsi, 0o
  syscall
  cmp rax, 0
  jl l1

  mov r8, rax

  mov rdi, [rsp + 24]
  mov rax, 2
  mov rsi, 577
  mov rdx, 777o
  syscall
  cmp rax, 0
  jl l1

  mov r10, rax

  mov rax, 0
  mov rdi, r8
  mov rsi, buffer
  mov rdx, 100
  syscall
  mov r9, rax

  mov rdi, num_buf
  mov rcx, 0

  mov rsi, buffer

xor rcx,rcx
next_char:
  cmp rcx, r9
  je end_of_text

  mov al, [buffer + rcx]
  inc rcx

  cmp al, '0'
  jl not_digit
  cmp al, '9'
  jg not_digit

  mov [rdi], al
  inc rdi
  jmp next_char

not_digit:
  cmp rdi, num_buf
  je next_char

  mov byte [rdi], 0
  mov rsi, num_buf
  sub rdi, num_buf
  mov rdx, rdi
  push rdx
  call write_number
  pop rdx
  inc rdx
  mov rdi, num_buf
  jmp next_char

write_number:
  push rdi
  push rsi
  push rax
  push rcx
  push rdx

  mov rax, 1
  mov rdi, r10
  syscall

  pop rdx
  pop rcx
  pop rax
  pop rsi
  pop rdi
  ret

end_of_text:
  mov rdi, r8
  mov rax, 3
  syscall
  mov rdi, r10
  syscall

l1:
  call exit
