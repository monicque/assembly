; user registration program
name "registration"
org 100h

jmp start; skip data bytes                 
 prompt1 db "Enter username $"
 prompt2 db 10, 13,"Enter Password $"
 passagain db 10, 13,"Enter password again $"
 msgsuccess db 10, 13, "Successful account creation $"
 errormsgpw db 10, 13, "Invalid password $"
 errormsgus db 10, 13, "Invalid username $"
 pass1 db 15,'?',15 dup('?')
 username db 20,'?',20 dup('?')
 pass2 db 15,'?',15 dup('?') 
                         
start:
    ; print first prompt
    mov AH, 09h
    mov DX, offset prompt1
    int 21h
    
    ; accept string input
    mov AH, 0Ah
    mov DX, offset username
    int 21h
     
    mov BL,  0
    
    ; load the start of string
    lea DI, username
     
 at_check:
    ; are we done yet?
    cmp BL, username[1]
    je errorus
    ;copy current character to CL
    mov CL, [DI + 2]
    ;count which character we are at
    inc BL
    ;move to the next character
    inc DI
    ;compare that character with '@' 
    cmp CL, '@'
    ;wound found the '@'
    je  right_pos
    ;we haven't found an '@'
    jne at_check
    
    ; ensure the '@' is at the right position
 right_pos: 
    ; one character behind
    sub DI, 2
    ; check for a character immediately before '@'
    mov DL,[DI + 2] 
    ; no char behind '@'- error
    cmp DL, 65
    jl  errorus
    cmp DL, 122
    ; no char behind '@'
    jg  errorus
    ; one character ahead
    add DI , 2
    ; check for a character immediately before '@'
    mov DL,[DI + 2] 
    ; no char ahead '@'- error
    cmp DL, 65
    jl  errorus
    cmp DL, 122
    ; no char ahead '@'
    jg  errorus
    
    ; we are good so far - check for '.'
    ; reload the effective address
    lea DI, username
    
    ; we are good so far - check for '.'
    ; reload the effective address
    mov BL, 2   
check_dot:
    ; are we done yet?
    cmp BL, username[1]
    je errorus
    ;copy current character to CL
    mov CL, [DI + 2]
    ;count which character we are at
    inc BL
    ;move to the next character
    inc DI
    ;compare that character with '.' 
    cmp CL, '.'
    ;wound found the '.'
    je  right_pos_dot
    ;we haven't found an '.'
    jne check_dot
    
    ; ensure the '@' is at the right position
 right_pos_dot: 
    ; one character behind
    sub DI, 2
    ; check for a character immediately before '.'
    mov DL,[DI + 2] 
    ; no char behind '.'- error
    cmp DL, 65
    jl  errorus
    cmp DL, 122
    ; no char behind '.'
    jg  errorus
    ; one character ahead
    add DI , 2
    ; check for a character immediately before '.'
    mov DL,[DI + 2] 
    ; no char ahead '.'- error
    cmp DL, 65
    jl  errorus
    cmp DL, 122
    ; no char ahead '.'
    jg  errorus

    ;username is good continue to password
       
    mov AH, 09h
    mov DX, offset prompt2
    int 21h
   
    lea DI, pass1
    mov BL, 0 ; keep count of no of characters entered

pass1_ent:
    ;get character input 
    mov AH, 7
    int 21h
    
    cmp AL, 13  
    ; have we finished input 
    je pass2_prompt 
    ;increment counter
    inc BL
    ; otherwise copy character into string  
    mov [DI + 2], AL
    ; move to next char
    inc DI  
    ; print asterik
    mov DL, '*'
    mov AH, 2
    int 21h
    ; loop until 'enter' is pressed
    jmp pass1_ent
    
pass2_prompt:
    lea DI, pass1
    mov [DI + 1], BL
    
    mov AH, 09h
    mov DX, offset passagain
    int 21h
    
    lea DI, pass2
    mov BL, 0 ; keep count of no of characters entered
    
pass2_ent:    
    ;get character input 
    mov AH, 7
    int 21h
    
    cmp AL, 13
    ; have we finished input
    je continue
    ;increment counter
    inc BL
    ; otherwise copy character into string  
    mov [DI + 2], AL
    inc DI 
    ; print asterik
    mov DL, '*'
    mov AH, 2
    int 21h
    ; loop until 'enter' is pressed
    jmp pass2_ent
    
continue:
    lea DI, pass2
    mov [DI+ 1], BL
  
    ; pass at least 8 chars
    mov BL, pass2[1]
    cmp BL, 8
    jl errorps
    
    ; ensure passwords are similar
    mov DL, pass1[1]
    cmp BL, DL
    jne errorps
    
    mov AH, pass1[1]
   
    ; set buffer addresses
    mov SI, offset pass2
    mov DI, offset pass1
    ; check all chars are matching   
        
next_char:
    dec AH
    mov AL, [DI+2]
    mov BL, [SI+2]
    cmp AL, BL
    jne errorps
    inc DI
    inc SI
    cmp AH, 0
    jne next_char
    
    ; passwords are same check for requirements
    ; load effective pass address       
    lea DI, pass1
    
    ; we are at the first character
    mov BL, 0
    
check_letter:
    ; have we gone through everything
    cmp BL, pass1[1]
    je errorps
    ; count current letter
    inc BL
    ; load the current character 
    mov AL, [DI + 2]
    ; set DI to next character
    inc DI
    ; is it a letter
    cmp AL, 90
    jge range_lower
    ; is it uppercase
    cmp AL, 65
    ; not it's not
    jl check_letter
    ; yes it is
    jge check_number

range_lower:
    cmp AL, 122
    ; this is not a character
    jl lower_llimit 
    ; ensure its within the limit
     
lower_llimit:
    cmp AL, 97
    ; AL is within 91 - 96, inclusive
    jle check_letter
    ; we found a character!

    ; search for a number
    ; reload pass address
    lea DI, pass1
    ; set character count
    mov BL, 0
    
check_number:
    ; have we gone through everything
    cmp BL, pass1[1]
    jge errorps
    ; count current letter
    inc BL
    ; load the current character 
    mov AL, [DI + 2]
    ; set DI to next character
    inc DI
    ; is it a letter
    cmp AL, 48
    ;less than - not a number
    jl check_number
    cmp AL, 57
    jg check_number
    ; AL within 48 - 57, we found a number!  
    
    ; both username and password validated 
    ; succesful account creation
    mov AH, 09h
    mov DX, offset msgsuccess
    int 21h
    ret
       
errorps:
    ; error is the password
    mov AH, 09h
    mov DX, offset errormsgpw
    int 21h
    ret
    
errorus:
    ; error in the username
    mov AH, 09h
    mov DX, offset errormsgus
    int 21h
    ret   




