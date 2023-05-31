.MODEL small
.STACK 100h
.DATA
    width equ 320
    hight equ 200
    scale equ 12
     
    m dw 0
    b db 0     
    x db 0
    
    logo db 13,10,' _____ ___________  ___  _____ _____  _   _ _____   _     _____ _   _  _____',13,10,'/  ___|_   _| ___ \/ _ \|_   _|  __ \| | | |_   _| | |   |_   _| \ | ||  ___|',13,10,'\ `--.  | | | |_/ / /_\ \ | | | |  \/| |_| | | |   | |     | | |  \| || |__  ',13,10,' `--. \ | | |    /|  _  | | | | | __ |  _  | | |   | |     | | | . ` ||  __| ',13,10,'/\__/ / | | | |\ \| | | |_| |_| |_\ \| | | | | |   | |_____| |_| |\  || |___ ',13,10,'\____/  \_/ \_| \_\_| |_/\___/ \____/\_| |_/ \_/   \_____/\___/\_| \_/\____/ ',13,10,'$'
                                                                                                                                                                                  
    invMsg db 13, 10, 'What you entered is invalid! try again: $' 
    enterM db 13, 10, 'Enter the m fot the function y = mx+b. The number must be between -9 and 9: $'
    enterB db 13, 10, 'Enter the b fot the function y = mx+b. The number must be between -9 and 9: $'  
    enterX db 13, 10, 'Enter X value you want the y for. The number must be between -99 and 99: $'  
    outputY db 13, 10, 'The y value is: $' 
    wantGraph db 13,10, 'Do you want to see the graph of the function? Press y for yes and anything else for no: $'
    
.CODE
start:  
    mov ax, @data
    mov ds, ax
                 
    lea dx, logo
    mov ah, 09h
    int 21h             
                 
    ; get m and b
    lea dx, enterM 
    mov ah, 09h
    int 21h
    push offset m
    call GetMB
                  
    lea dx, enterB 
    mov ah, 09h
    int 21h
    push offset b
    call GetMB 
    
    lea dx, enterX
    mov ah, 09h
    int 21h
    push offset x
    call GetX
    call ValueCalY 
    call PrintY
    
    lea dx, wantGraph
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    cmp al, 'y'
    jne exit
    
    mov ah, 0
    mov al, 13h
    int 10h
    
    call DrawXAxis
    call DrawYAxis  
    call DrawGraph

    
exit:
    mov ah, 4ch
    int 21h

;------------------------------
    
proc GetMB
    push bp
    mov bp, sp
    mov cl, 0   
    
    input1:    
        mov ah, 01h
        int 21h
    
        cmp al, '-'
        je pressedMinus1
        cmp al, '9'
        ja invalid1
        cmp al, '0'
        jb invalid1
    
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
    
    invalid1:
        mov cl, 0  
        lea dx, invMsg 
        mov ah, 09h
        int 21h
        
        jmp input1
        
    pressedMinus1:    
        not cl 
        jmp input1    
    
endp GetMB

proc GetX
    push bp
    mov bp, sp  
    
    mov si, [bp+4]
    mov [si], 0
    
    xor dh,dh
    mov cx, 2
    
    input2:
        mov ah, 01h
        int 21h
        cmp al, '-'
        je pressedMinus2 
        cmp al, 13
        je continue
        cmp al, '0'
        jb invalid2
        cmp al, '9'
        ja invalid2
        
        mov bl,1
        mov bh, al 
        mov al, [si]
        mov dl, 10 
        mul dl
        
        sub bh, '0'
        add al, bh
        mov [si], ax
        
        loop input2
        
    continue:
        cmp dh, 0
        je return
        neg [si]
        jmp return    
           
    pressedMinus2: 
        cmp bl, 1
        je invalid2        
        not dh   
        jmp input2 
        
    invalid2:    
        lea dx, invMsg
        mov ah, 09h
        int 21h
        
        mov [si], 0 
        xor bl, bl
        xor dh,dh
        mov cx, 2 
        jmp input2
        
    return:
        pop bp
        ret 2
        
endp GetX 


proc DrawYAxis
    xor dl, dl
    mov cx, width/2
    drawYLine1:
        call drawPixel
        inc dl
        cmp dl, hight
        jb drawYLine1
    
    xor dl, dl    
    dec cx
    drawYLine2:
        call drawPixel
        inc dl
        cmp dl, hight
        jb drawYLine2
    
    ret
endp DrawYAxis 


proc DrawXAxis
    mov cx, 319
    mov dl, hight/2
    drawXLine1:
        call drawPixel
        loop drawXLine1 
        
    mov cx, 319
    dec dl
    drawXLine2:
        call drawPixel  
        loop drawXLine2
    
    ret
endp DrawXAxis


proc ValueCalY 
    xor ah, ah 
    mov al, x
    imul byte ptr m 
    
    cmp b, 0
    jge bPositive
    
    mov bh, 0FFh
    mov bl, b 
    add ax, bx
    
    ret
    
    bPositive:
        xor bh, bh
        mov bl, b
        add ax, bx 
    
    ret
endp ValueCalY
    

proc PixelCalY 
    mov ax, cx
    sub ax, width/2 
    
    imul m 
    
    mov dl, scale
    idiv dl
  
    add al, b
    mov dl, hight/2
    sub dl, al
    
    ret
endp PixelCalY   
 

proc PrintY
    mov bx, ax
    
    lea dx, outputY
    mov ah, 09h
    int 21h
    
    mov ax, bx
    xor ch, ch 
    mov cl, 100 
    
    cmp ax, 0
    jg printDig
    mov dl, '-'
    mov bx, ax
    mov ah, 02h
    int 21h     
    mov ax, bx
    neg ax
    
    printDig:      
        div cl
        mov bh, ah
        add al, '0'
        
        mov dl, al 
        mov ah, 02h
        int 21h
         
        mov ax, cx 
        mov bl, 10 
        div bl
        mov cl, al
        
        mov al, bh
        xor ah, ah
        
        cmp cx, 0
        jne printDig
    
    ret
endp PrintY

  
proc DrawGraph
    mov cx, 319
    graph:
        call PixelCalY
        call drawPixel
    loop graph
     
    ret
endp DrawGraph


proc drawPixel
    xor dh,dh
    mov al, 15
    mov ah, 0ch
    int 10h
    ret
endp drawPixel
    
END