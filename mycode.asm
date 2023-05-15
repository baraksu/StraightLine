.MODEL small
.STACK 100h
.DATA
    width equ 320
    hight equ 200
    scale equ 12
     
    m dw 0
    b dw 0     
    
    invMsg db 13, 10, 'What you entered is invalid! try again: $' 
    enterM db 13, 10, 'Enter the m fot the function y = mx+b. The number must be between -9 and 9: $'
    enterB db 13, 10, 'Enter the b fot the function y = mx+b. The number must be between -9 and 9: $'
    
.CODE
start:  
    mov ax, @data
    mov ds, ax
    
    ; get m and b
    lea dx, enterM 
    mov ah, 09h
    int 21h
    push offset m
    call GetNum
                  
    lea dx, enterB 
    mov ah, 09h
    int 21h
    push offset b
    call GetNum 
    
    mov ah, 0
    mov al, 13h
    int 10h
    
    call DrawXAxis
    call DrawYAxis 
    
    
    
exit:
    mov ah, 4ch
    int 21h

;------------------------------
    
proc GetNum
    push bp
    mov bp, sp
    mov cl, 0   
    
    input:    
        mov ah, 01h
        int 21h
    
        cmp al, '-'
        je pressedMinus
        cmp al, '9'
        ja invalid
        cmp al, '0'
        jb invalid
    
        sub al, '0' 
        mov bx, [bp+4] 
        pop bp
        
        xor ah, ah
           
        cmp cl, 0FFh
        je negative
         
        mov [bx], ax
    
    ret 2        
    
    negative:
        neg ax
        mov [bx], ax
        
        ret 2 
    
    invalid:
        mov cl, 0  
        lea dx, invMsg 
        mov ah, 09h
        int 21h
        
        jmp input
        
    pressedMinus:    
        not cl 
        jmp input    
    
endp GetNum


proc DrawYAxis
    mov dl, 0
    mov cx, width/2
    drawYLine:
        call drawPixel
        dec cx
        call drawPixel
        inc cx
        inc dl
    cmp dl, hight
    jb drawYLine
    
    ret
endp DrawYAxis 


proc DrawXAxis
    mov cx, 319
    mov dl, hight/2
    drawXLine:
        call drawPixel
        dec dl
        call drawPixel
        inc dl
    loop drawXLine
    
    ret
endp DrawXAxis


proc drawPixel
    xor dh,dh
    mov al, 15
    mov ah, 0ch
    int 10h
    ret
endp drawPixel
    
END