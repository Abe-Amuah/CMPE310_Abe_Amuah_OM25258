section .data
    result_prompt db "Hamming Distance: ", 0
    newline db 0xA, 0
    foo db "foo", 0   ; Hardcoded string "foo"
    bar db "bar", 0   ; Hardcoded string "bar"

section .bss
    hamming_distance resd 1  ; Reserve 4 bytes for Hamming distance
    distance_str resb 10     ; Buffer for the Hamming distance string

global main
section .text
main:
    ; Initialize Hamming distance to 0
    mov dword [hamming_distance], 0

    ; Initialize the index for string comparison
    xor ecx, ecx        ; Set ECX to 0 (index for string comparison)

compare_loop:
    ; Load the current byte of both strings
    mov al, [foo + ecx]
    mov bl, [bar + ecx]

    ; If both strings are null-terminated, exit the loop
    cmp al, 0
    je done
    cmp bl, 0
    je done

    ; Calculate the difference (XOR) between the characters (bitwise comparison)
    xor al, bl          ; XOR the two characters to get the differing bits

    ; Count the number of 1 bits in the XOR result (Hamming distance for this byte)
    mov ah, al          ; Copy the result into AH for bit counting
    xor edx, edx        ; Clear EDX (Hamming distance accumulator)
count_bits:
    test ah, 1          ; Test the least significant bit (LSB)
    jz no_bit           ; If the bit is 0, jump to no_bit
    inc edx             ; If the bit is 1, increment the counter
no_bit:
    shr ah, 1           ; Shift the bits to the right
    jnz count_bits      ; Repeat for all bits until AH is 0

    ; Add the Hamming distance for this byte to the total
    add [hamming_distance], edx

    ; Move to the next byte in the strings
    inc ecx
    jmp compare_loop

done:
    ; Print the result prompt: "Hamming Distance: "
    mov eax, 1          ; syscall number for write
    mov edi, 1          ; file descriptor 1 (stdout)
    mov esi, result_prompt ; pointer to the result prompt
    mov edx, 18         ; length of result prompt
    syscall

    ; Print the Hamming distance as a number (converting it to string)
    mov eax, [hamming_distance] ; Load the Hamming distance into eax
    mov ecx, 10         ; Base 10 for number conversion
    mov ebx, distance_str   ; Buffer for converted digits
    add ebx, 10         ; Move the buffer pointer to the end
    mov byte [ebx], 0   ; Null-terminate the buffer

    ; Convert to string (reverse order)
convert_to_str:
    xor edx, edx        ; Clear edx (remainder)
    div ecx             ; Divide eax by 10, quotient in eax, remainder in edx
    dec ebx             ; Move the pointer back for the next character
    add dl, '0'         ; Convert remainder to ASCII character
    mov [ebx], dl       ; Store character in buffer
    test eax, eax       ; Check if quotient is zero
    jnz convert_to_str  ; If not, continue dividing

    ; Move the buffer pointer back to the start of the string
    mov esi, ebx        ; Set esi to point to the beginning of the string

    ; Print the Hamming distance string from the correct position
print_loop:
    mov al, [esi]       ; Load character
    test al, al         ; Check if it is null terminator
    jz done_printing    ; If null terminator, stop printing
    mov eax, 1          ; syscall number for write
    mov edi, 1          ; file descriptor 1 (stdout)
    mov edx, 1          ; length of character
    syscall
    inc esi             ; Move to the next character
    jmp print_loop

done_printing:
    ; Print newline
    mov eax, 1          ; syscall number for write
    mov edi, 1          ; file descriptor 1 (stdout)
    mov esi, newline    ; pointer to the newline character
    mov edx, 1          ; length of newline
    syscall

    ; Exit the program
    mov eax, 60         ; syscall number for exit
    xor edi, edi        ; status 0
    syscall
