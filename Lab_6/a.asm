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
extrn exit
extrn timeout
extrn usleep
extrn printw

section '.bss' writable
    xmax dq 1
    ymax dq 1
    palette dq 1
    delay dq 50000
    spiral_count dq 0
    spiral_dir dq 1
    horizontal_step dq 100
    vertical_step dq 1
    current_max_step dq 1
    vertical_phase_count dq 0

section '.text' executable

_start:
    call initscr
    xor rdi, rdi
    mov rdi, [stdscr]
    call getmaxx
    dec rax
    mov [xmax], rax
    call getmaxy
    dec rax
    mov [ymax], rax

    call start_color

    mov rdi, 1
    mov rsi, 7
    mov rdx, 7
    call init_pair

    mov rdi, 2
    mov rsi, 3
    mov rdx, 3
    call init_pair

    call refresh
    call noecho
    call raw

    mov rax, ' '
    or rax, 0x100
    mov [palette], rax

    mov rax, [xmax]
    shr rax, 1
    sub rax, 50
    mov r8, rax

    mov rax, [ymax]
    shr rax, 1
    mov r9, rax

    mov [spiral_dir], 1
    mov [spiral_count], 0
    mov [horizontal_step], 100
    mov [vertical_step], 2
    mov [current_max_step], 1
    mov qword [vertical_phase_count], 0

    .main_loop:
        cmp r8, 0
        jl .reset
        cmp r8, [xmax]
        jg .reset
        cmp r9, 0
        jl .reset
        cmp r9, [ymax]
        jg .reset
        jmp .loop

    .reset:
        mov rax, [xmax]
        shr rax, 1
        sub rax, 50
        mov r8, rax

        mov rax, [ymax]
        shr rax, 1
        mov r9, rax

        mov [spiral_dir], 1
        mov [spiral_count], 0
        mov [horizontal_step], 100
        mov [vertical_step], 2
        mov [current_max_step], 1
        mov qword [vertical_phase_count], 0

        mov rax, [palette]
        and rax, 0x100
        cmp rax, 0
        jne .mag
        mov rax, [palette]
        and rax, 0xff
        or rax, 0x100
        jmp @f
        .mag:
        mov rax, [palette]
        and rax, 0xff
        or rax, 0x200
        @@:
        mov [palette], rax

    .loop:
        mov rdi, r9
        mov rsi, r8
        push r8
        push r9
        call move
        mov rdi, [palette]
        call addch
        call refresh
        mov rdi, 1
        call timeout
        call getch

        cmp rax, 'j'
        jne @f
        jmp .exit

        @@:
        cmp rax, 'l'
        jne @f
        cmp [delay], 50000
        je .fast
        mov [delay], 50000
        jmp @f
        .fast:
        mov [delay], 10000
        @@:
        mov rdi, [delay]
        call usleep

        pop r9
        pop r8

        mov rax, [spiral_dir]
        cmp rax, 0
        je .horizontal
        cmp rax, 2
        je .horizontal
        cmp qword [vertical_phase_count], 0
        je .set_vertical_step_2
        cmp qword [vertical_phase_count], 1
        je .set_vertical_step_2
        mov rbx, [vertical_step]
        jmp .after_set_max
    .set_vertical_step_2:
        mov rbx, 2
        jmp .after_set_max
    .horizontal:
        mov rbx, [horizontal_step]
    .after_set_max:
        mov [current_max_step], rbx

        mov rax, [spiral_count]
        inc rax
        mov [spiral_count], rax
        cmp rax, [current_max_step]
        jl .move_current_dir

        mov [spiral_count], 0

        mov rax, [spiral_dir]
        cmp rax, 1
        je .vertical_complete
        cmp rax, 3
        je .vertical_complete
        inc qword [horizontal_step]
        jmp .change_dir

    .vertical_complete:
        inc qword [vertical_phase_count]
        cmp qword [vertical_phase_count], 2
        je .skip_increment_step
        inc qword [vertical_step]
        jmp .change_dir
    .skip_increment_step:
        jmp .change_dir

    .change_dir:
        mov rax, [spiral_dir]
        cmp rax, 1
        je .to_right
        cmp rax, 0
        je .to_up
        cmp rax, 3
        je .to_left
        mov rax, 1
        jmp .dir_set
    .to_right:
        mov rax, 0
        jmp .dir_set
    .to_up:
        mov rax, 3
        jmp .dir_set
    .to_left:
        mov rax, 2
    .dir_set:
        mov [spiral_dir], rax

    .move_current_dir:
        mov rax, [spiral_dir]
        cmp rax, 1
        je .down
        cmp rax, 0
        je .right
        cmp rax, 3
        je .up
        dec r8
        jmp .main_loop

    .down:
        inc r9
        jmp .main_loop

    .right:
        inc r8
        jmp .main_loop

    .up:
        dec r9
        jmp .main_loop

    .exit:
    call endwin
    call exit
