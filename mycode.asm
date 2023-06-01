.MODEL small
.STACK 100h
.DATA
    width equ 320 ;the width of the screen
    hight equ 200 ;the hight of the screen
    scale equ 12  ;the scale of the graph (kne mida)
     
    m dw 0 ;stores the m value
    b db 0 ;stores the b value    
    x db 0 ;stores the value of the x the y value should be calculated to
    
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
    
    ;prints logo             
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
    
    ;get x
    lea dx, enterX
    mov ah, 09h
    int 21h
    push offset x
    call GetX  
    
    ;calculate and output the y value for the entered x
    call ValueCalY 
    call PrintY
    
    ;ask if want to draw graph
    lea dx, wantGraph
    mov ah, 09h
    int 21h     
    ;checks answer
    mov ah, 01h
    int 21h
    cmp al, 'y'
    jne exit
    
    ;sets the screen for drawing
    mov ah, 0
    mov al, 13h
    int 10h
    
    ;draw the axises and the graph
    call DrawXAxis
    call DrawYAxis  
    call DrawGraph

    
exit:
    mov ah, 4ch
    int 21h

;------------------------------
    
proc GetMB 
    ;goal: accept a one digit number from the user and put it in the inputed varible (m/b) 
    ;input: the offset of the M/B varible the value is put in
    ;output: the value accepted is put in the given offset/varible
    push bp
    mov bp, sp
    mov cl, 0   ;flags wheter the number is positive or negative  
    
    input1:    
        mov ah, 01h
        int 21h
        
        ;check validity
        cmp al, '-'
        je pressedMinus1
        cmp al, '9'
        ja invalid1
        cmp al, '0'
        jb invalid1
        
        ;gets to this part if the char entered is a number
        sub al, '0'      
        mov bx, [bp+4] 
        pop bp
        
        xor ah, ah
           
        cmp cl, 0FFh    ;checks the negative/positive flag (cl). 0FFh = neg, 00h = pos 
        je negative
         
        mov [bx], ax    ;puts the value of the entered number (stored in ax) into the inputed varible
    
    ret 2           
    
    negative:
        neg ax          ;changes the value of the entered number from positive to negative
        mov [bx], ax    ;puts the value of the entered number (stored in ax) into the inputed varible
        
        ret 2 
    
    invalid1:
        mov cl, 0   ;resrt the negative/positive flag (cl)  
        lea dx, invMsg 
        mov ah, 09h
        int 21h
        
        jmp input1
        
    pressedMinus1:    
        not cl      ;triggers the negative/positive flag (cl)
        jmp input1      
    
endp GetMB    


proc GetX   
    ;goal: accept a one digit/two digit number from the user and put it in the inputed varible (x)
    ;input: offset of the varible x
    ;output: outputs the entered value to the given offset/varible (x)
    push bp
    mov bp, sp  
    
    ;moves the inputed offset to si and reset the varible (x)
    mov si, [bp+4]
    mov [si], 0
    
    xor bl, bl  ;flags wheter a digit was already pressed
    xor dh,dh   ;flags wheter the number is positive or negative  
    mov cx, 2   ;determines how many times the loop will be done (how many digits are accepted)
    
    input2:
        ;check validity
        mov ah, 01h
        int 21h
        cmp al, '-'
        je pressedMinus2 
        cmp al, 13      ;checks if enter
        je continue
        cmp al, '0'
        jb invalid2
        cmp al, '9'
        ja invalid2
        
        ;gets to this part if the char entered is a number
        mov bl,1    ;flags that a digit was entered
        mov bh, al  ;moves the entered char into bh
        mov al, [si];moves the value sored in the inputed varible (x) into al    
        mov dl, 10  
        mul dl      ;multiplies the value in al (the value stored in x) by 10 
        
        ;takes the last char entered, turns it to a number, adds it to al and puts al into the inputed varible (x)
        sub bh, '0'
        add al, bh
        mov [si], al
        
        loop input2
        
    continue:
        cmp dh, 0   ;checks the negative/positive flag (dh). 0FFh = neg, 00h = pos 
        je return
        neg [si]    ;changes the value of the inputed varible (x) from positive to negative
        jmp return    
           
    pressedMinus2: 
        cmp bl, 1   ;checks wether a digit was already entered
        je invalid2        
        not dh      ;triggers the negative/positive flag (dh)   
        jmp input2 
        
    invalid2:    
        lea dx, invMsg
        mov ah, 09h                               
        int 21h
        
        mov [si], 0 ;resets the inputed varible 
        xor bl, bl  ;resrt the entered a digit flag (bl)
        xor dh,dh   ;resrt the negative/positive flag (dh)
        mov cx, 2   ;reset cx, to accept 2 digits again
        jmp input2
        
    return:
        pop bp
        ret 2
        
endp GetX 


proc DrawYAxis
    ;goal: draw the y axis 
    ;input: none
    ;output: draws y axis
    
    ;draws the first line in the y axis
    xor dl, dl
    mov cx, width/2
    drawYLine1:
        call DrawPixel
        inc dl
        cmp dl, hight
        jb drawYLine1 
        
    ;draws the second line of the y 
    xor dl, dl    
    dec cx
    drawYLine2:
        call DrawPixel
        inc dl
        cmp dl, hight
        jb drawYLine2
    
    ret
endp DrawYAxis 


proc DrawXAxis
    ;goal: draw the x axis
    ;input: none
    ;output: draws x axis
    
    ;draws the first line in the x axis
    mov cx, 319
    mov dl, hight/2
    drawXLine1:
        call DrawPixel
        loop drawXLine1                
    call drawPixel  ;draws the last pixel in the first line 
     
    ;draws the second line in the x axis    
    mov cx, 319
    dec dl
    drawXLine2:
        call DrawPixel  
        loop drawXLine2
    call drawPixel  ;draws the last pixel in the second line    
    
    ret
endp DrawXAxis


proc ValueCalY 
    ;goal: calculate the y value for the entered x
    ;input: x varible (the input is passed using a global varible, x)
    ;output: outputs to ax the y value for the given x
    
    ;puts in ax the value of x (al = x, ah = 0) 
    xor ah, ah 
    mov al, x                 
    
    imul byte ptr m ;multiplies al by m (byte ptr: in order to multiply only al and not ax)  
    
    cmp b, 0        ;checks wether b is positive/0
    jge bPositive
    
    ;gets to this part if b is negative
    ;adds b to ax (and makes bx negative)
    mov bh, 0FFh
    mov bl, b 
    add ax, bx
    
    ret
    
    bPositive: 
        ;adds b to ax
        xor bh, bh
        mov bl, b
        add ax, bx 
    
    ret
endp ValueCalY
    

proc PixelCalY 
    ;goal: calculate the y value for the currnt pixel (current x)
    ;input: current pixel x value (column). (passed through cx)
    ;output: outputs to dl the y value (row) of the pixel that need to be drawn
    
    ;moves the current value of cx to ax and turns it to an x value (from 0-319 to (-160)- 159)  
    mov ax, cx
    sub ax, width/2 
    
    imul m  ;nultiplies the x value by m 
    
    ;change the y value to fit into the screen (change the scale)
    mov dl, scale
    idiv dl
  
    add al, b   ;adds b to the y value
    
    ;changes the y value to a number that can be printed on the screen (from (-100)- 100 to 0-199)
    mov dl, hight/2
    sub dl, al
    
    ret
endp PixelCalY   
 

proc PrintY 
    ;goal: print the y value for x
    ;input: y value (passed through ax)
    ;output: prints the y value
    
    mov bx, ax  ;moves the y value from ax to bx
    
    lea dx, outputY
    mov ah, 09h
    int 21h
    
    mov ax, bx  ;moves back the y value from bx to ax
    xor ch, ch 
    mov cl, 100 ;divider (the number is devided by cl in order to seperate the digits)
    
    cmp ax, 0   ;checks if ax is positive/0
    jge printDig  
    
    ;gets to this part if ax/y is negative  
    mov bx, ax  ;moves the y value from ax to bx 
    
    ;prints -
    mov dl, '-'
    mov ah, 02h
    int 21h
   
    mov ax, bx  ;moves back the y value from bx to ax
    neg ax      ;turns the number to positive
    
    printDig:     
        div cl      ;seperate the first digit 
        mov bh, ah  ;move the reminder (rest of the number) to bh
        add al, '0' ;turns the seperated digit to a char
        
        ;prints the char
        mov dl, al 
        mov ah, 02h
        int 21h
        
        ;divides cl (the devider) by 10 
        mov ax, cx 
        mov bl, 10 
        div bl
        mov cl, al
        
        ;move the reminder (rest of the number) back to ax
        mov al, bh  
        xor ah, ah
        
        cmp cx, 0   ;checks if went over all the digits
        jne printDig
    
    ret
endp PrintY

  
proc DrawGraph
    ;goal: draw the graph
    ;input: none
    ;output: graph
    
    mov cx, width-1 ;moves to cx the amount of pixels (x values) that need to be drawn
    graph:
        call PixelCalY  ;calculate the y value for the current pixel
        call DrawPixel  ;draws the pixel
    loop graph
     
    ret
endp DrawGraph


proc DrawPixel
    ;goal: draw a pixel
    ;input: column = cx, row = dl 
    ;outpu: draws a pixel
     
    xor dh,dh   ;makes sure dh is empty, so dl is the only thing that affect the row (hight) of the pixel
    mov al, 15  ;sets the color to white
    
    ;draws the pixel on the screen in row: dx (dl), column: cx 
    mov ah, 0ch
    int 10h                                 
    
    ret
endp DrawPixel
    
END