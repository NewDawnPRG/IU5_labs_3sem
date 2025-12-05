format ELF64
public _start

extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn timeout
extrn usleep
extrn printw
extrn mvaddch
extrn erase
extrn curs_set

section '.data' writable
    sine_table db 0,4,7,9,10,9,7,4,0,-4,-7,-9,-10,-9,-7,-4

section '.bss' writable
    xmax dq ?
    ymax dq ?
    xmid dq ?
    ymid dq ?
    palette dq ?
    current_x dq ?
    delay dq ?

section '.text' executable
_start:
    call initscr
    mov rdi, [stdscr]
    call getmaxx
    dec rax
    mov [xmax], rax
    xor rdx, rdx
    mov rcx, 2
    div rcx
    mov [xmid], rax

    call getmaxy
    dec rax
    mov [ymax], rax
    xor rdx, rdx
    mov rcx, 2
    div rcx
    mov [ymid], rax

    xor rdi, rdi
    call curs_set

    call start_color
    mov rdi, 1
    mov rsi, 2
    mov rdx, 2
    call init_pair

    call noecho
    call raw
    mov rdi, [stdscr]
    mov rsi, 1
    call keypad

    mov rax, ' '
    or rax, 0x0100
    mov [palette], rax

    mov qword [current_x], 0

.main_loop:
    call erase

    mov rax, [current_x]
    mov rcx, 16
    xor rdx, rdx
    div rcx
    mov rbx, sine_table
    movsx rax, byte [rbx + rdx]
    mov rbx, [ymid]
    add rbx, rax

    cmp rbx, 0
    jge .y_not_below
    mov rbx, 0
.y_not_below:
    cmp rbx, [ymax]
    jl .y_in_range
    mov rbx, [ymax]
    dec rbx
.y_in_range:

    mov rdi, rbx
    mov rsi, [current_x]
    mov rdx, [palette]
    call mvaddch

    call refresh

    mov rdi, 1
    call timeout
    call getch
    cmp rax, 'q'
    je .exit_program

    mov rax, [current_x]
    inc rax
    cmp rax, [xmax]
    jl .update_x
    xor rax, rax
.update_x:
    mov [current_x], rax

    mov rdi, 100000
    call usleep

    jmp .main_loop

.exit_program:
    mov rdi, 1
    call curs_set
    call endwin

    mov rax, 60
    xor rdi, rdi
    syscall
