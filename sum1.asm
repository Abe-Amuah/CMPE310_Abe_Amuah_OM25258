section .data
    prompt: dd "Enter the name of the file: "
    promptLen equ $ - prompt
    
    
section .bss
    buffer: resb 1024
    num_buffer resb 12
    pathname resb 128

global main
section .text
main:
    ;Prompting the user
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, promptLen
    int 80h

    ;Getting the file name
    mov eax, 3
    mov ebx, 0
    mov ecx, pathname
    mov edx, 128 
    int 80h
    mov esi, eax
    dec esi
    mov byte[pathname + esi], 0

    ;Opening the file
    mov eax, 5
    mov ebx, pathname
    mov ecx, 0    
    int 80h
    mov ebx, eax

    ;Reading the file into the buffer
    mov eax, 3
    mov ecx, buffer
    mov edx, 1024
    int 80h
    mov edi, eax

    xor eax, eax ;Holds the sum
    xor ebx, ebx ;Current Value
    xor ecx, ecx ;Index
    xor edx, edx
    xor esi, esi ;Line counter

parse:
    cmp ecx, edi
    jge done_parse

    mov dl, [buffer + ecx]
    cmp dl, 10
    je new_line

    cmp dl, 13
    je next

    cmp dl, '0'
    jb next
    cmp dl, '9'
    ja next

    sub dl, '0'
    imul ebx, ebx, 10
    add ebx, edx
    jmp next

new_line:
    inc esi
    cmp esi, 1
    je reset
    add eax, ebx

reset:
    xor ebx, ebx

next:
    inc ecx
    jmp parse

done_parse:
    cmp ebx, 0
    je exit
    cmp esi, 0
    jle exit
    add eax, ebx
 

exit:
    call print_answer
    mov eax, 1
    int 80h

print_answer:
    mov ecx, num_buffer
    add ecx, 11
    mov byte [ecx], 10
    dec ecx

    cmp eax, 0
    jne convert
    mov byte [ecx], '0'
    jmp print

convert:
next_digit:
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov [ecx], dl
    dec ecx
    test eax, eax
    jnz next_digit


print:
    mov eax, 4
    mov ebx, 1
    mov edx, num_buffer + 12
    sub edx, ecx
    mov ecx, ecx
    int 80h