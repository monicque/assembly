
name "beep"
jmp start
   stop_watch db 10,'?', 10 dup('?');declaring bytes to store the input string 
   message db "Enter the delay to beep in format HH:MM:SS $"; prompt message
   errormsg db 10, 13, "Incorrect format. Correct format HH:MM:SS $"
start:
    mov dx, offset message      ;input prompt
    mov ah, 09h                   
    int 21h
                         
    mov dx, offset stop_watch
    mov ah,0ah                  ;string input
    int 21h
    
    cmp stop_watch[1], 8        ; user entered more than 8 characters
    jg error                     
    
    lea DI, stop_watch
    ; get the hours
    mov al, 10                  ; for multipying with tens digits
  
    mov dh, [DI + 2]
    sub dh, 48                  ; convert to decimal
    mul dh
    mov dh, al                  ; multiply by ten to get the tens
    mov dl, [DI + 3]            
    sub dl, 48                  ; convert to decimal
    add dh, dl                  ; we have the hours in dh now
    
    ; get the minutes
    mov al, 10
    mov bl, [DI + 5]            
    sub bl, 48                  ; conver to decimal
    mul bl
    mov bl, al                      ; get the tens value
    mov bh, [DI + 6]
    sub bh, 48                  ; get the ones
    add bh, bl
    
    cmp bh, 60                  ; we have the minutes in al
    jl  minutes                  
    
    ;someone entered more than 60 seconds
    inc dh
    sub bh, 60
    
    
    ; get the seconds
minutes:
    mov al, 10
    mov bl, [DI + 8]            
    sub bl, 48                  ; conver to decimal
    mul bl
    mov bl, al                  ; get the tens value
    mov dl, [DI + 9]
    sub dl, 48                  ; get the ones
    add bl, dl
    
    cmp bl, 60
    jl  seconds
                                 ; carry one minutes
    inc bh
    sub bl, 60

seconds:    
    mov al, dh                   ; save hours since we'll use dx
    
      
    ; loop with a one second delay until time is over
main:
    ; set interval (1 million
    ; microseconds - 1 second):
    mov cx, 0Fh                   ;a delay of one second CX:DX MICROSECONDS
    mov dx, 4240h                 ;int15h/86h bios wait function
    mov ah, 86h
    int 15h   
    
    dec bl                        ; are the seconds over
    cmp bl, 0
    jne main
    cmp bh, 0                     ; are the minutes over
    jne min_to_sec                
    cmp al, 0                     ; are the hours over
    mov cx, 3
    jne hour_to_sec
    jmp beep

                                  ;borrow one hour
hour_to_sec:
    dec dh
    mov al, 60
                                  ;borrow one minutes
min_to_sec:
    dec bh
    mov bl, 60 
    jmp main
    
beep:
    mov ah, 02h                   ;beep by printing 07h
    mov dl, 07h
    int 21h
    loop beep
    ret
    
error:
    mov dx, offset errormsg      ; error message print
    mov ah, 09h                   
    int 21h  





