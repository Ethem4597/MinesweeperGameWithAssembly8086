; in vga memory: first byte is ascii character, byte that follows is character attribute.
; if you change the second byte, you can change the color of
; the character even after it is printed.
; character attribute is 8 bit value,
; high 4 bits set background color and low 4 bits set foreground color.

; hex    bin        color
; 
; 0      0000      black
; 1      0001      blue
; 2      0010      green
; 3      0011      cyan
; 4      0100      red
; 5      0101      magenta
; 6      0110      brown
; 7      0111      light gray
; 8      1000      dark gray
; 9      1001      light blue
; a      1010      light green
; b      1011      light cyan
; c      1100      light red
; d      1101      light magenta
; e      1110      yellow
; f      1111      white
 

;include 'emu8086.inc' ; for print function
 
  
.model small
.stack 100h 

data segment
    
    ;for mines
    mineRow db 31h,33h,34h,35h,33h,32h
    mineColumn db 32h,34h,33h,35h,31h,34h
    ;to understand the same input coordinates
    inputRow db 30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h
    inputColumn db 30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h,30h
                    
    msgRow db 'Row : $' 
    
    msgColumn db ' Column : $'
    
    arrow db ' ==> : $'
    
    brackets1 db '($'
    
    brackets2 db ')$'
    
    comma db ',$'
    
    space db '                                         $'
    
    again db 'Please write a number between 1 and 5$'
    
    healthStr db 'Health $'
    
    erase db '    $'
    
    zero db '0$'
    
    healthSymbol db 3,3,3
    
    currentHealth db 33h 
    
    scoreStr db 'Score : $'
    
    scorePoint dw 0
    
    gameisOver db 'Game Over$' 
    
    pressAnyKey db 'Press Any Key$'
    
    mines db 'Mines : $'
    
    minesweeper db 'Minesweeper$'
    
    purpose1 db 'In this game you have to find $' 
    
    purpose2 db 'areas that are not mines.$'
    
    instructions1 db 'To do this, you need to enter $'
    
    instructions2 db 'row and column values.$'
    
    doneBy1 db 'Made by Ethem Akgul for the $'
    
    doneBy2 db 'Microprocessors course.$'
    
    goodLuck db 'Good Luck$'
    
    choice1 db 'Do you want to see the $'
    
    choice2 db 'coordinates of the mines? (y/n) : $'
    
    mineInfo dw 31h   ;show (31h) or not show (30h) the mines coordinates
    
    fullHealthStr db 'And you didnt take any damage.$'
    
    halfHealthStr db 'And now you have war scars.$'
    
    lastHealthStr db 'But some limbs are missing.$' 
    
    wellDone db 'Congratulations$'
    
    clearMines db 'You found all the mines.$'
    
    numberofCoordinates db 30h
    
    sameInputValues db 'Enter a different coordinate than before$'
    
ends    

.code

    main proc
         
        ;call setDataforPrint
        mov ax,@data 
        mov ds,ax    
        
            
        ; set video mode    
        
        mov ax, 0     ; text mode 40x25, 16 colors, 8 pages (ah=0, al=0)
        int 10h       ; do it!

        
        ; cancel blinking and enable all 16 colors:
        mov ax, 1003h
        mov bx, 0
        int 10h
        
        call madeByInfo 
        
        
        inputRequired:
        
        mov ah,07h        ;y/n  79h 6eh
        int 21h
        mov dh,al
        
        cmp dh,79h  ;y
        je showCoordinates
        
        cmp dh,6eh  ;n
        je dontshowCoordinates
        
        jmp inputRequired
        
        showCoordinates:
            mov mineInfo,31h
            jmp goOn    
             
        dontshowCoordinates:     
            mov mineInfo,30h
             
        goOn:
            
            ;mov ah,07h
            ;mov al,0
            ;int 21h
            
            call clearAll
            
             
            
            mov  dh, 0    ;row
            mov  dl, 0     ;column
            mov  bh, 0
            mov  ah, 02h   ;SetCursor 
            int  10h 
            
            
         
        call printHealth
        
        call setHealth
        
        call printScore
                        
        call setDataforLocation
        
        call mineField
        
        call border
        
        call numbers
        
        call setDataforPrint
        
        cmp mineInfo,31h
        jne invisibleMines

        mov  dh, 15    ;row
        mov  dl, 0     ;column
        mov  bh, 0
        mov  ah, 02h   ;SetCursor 
        int  10h
        
        mov ah,09h        
        lea dx,mines ;print 'Mines : '
        int 21h
        
        call printMines 
        
        invisibleMines:
                
        
        call InputOutput    
            
     
     hlt       
    ;ret        
    main endp
    
clearall proc
    
    xor cx,cx
    mov dh,24  ;clear row
    mov dl,39  ;clear column
    mov bh,7
    mov ax,700h
    int 10h 
    
    mov ax,0
    int 10h
    
ret
endp

numbers proc ;ruler

    mov bx,190

    mov [bx], 49        ;1   Row
    mov [bx+4], 50      ;2
    mov [bx+8], 51      ;3
    mov [bx+12], 52     ;4
    mov [bx+16], 53     ;5
        
        add bx,156
    
    mov [bx], 49        ;1   Column
    mov [bx+160], 50    ;2
    mov [bx+320], 51    ;3
    mov [bx+480], 52    ;4
    mov [bx+640], 53    ;5    
        
    
ret
endp    
    
    

madeByInfo proc
    
    call setDataforPrint 
     
    mov  dh, 0    ;row
    mov  dl, 13   ;column
    mov  bh, 0
    mov  ah, 02h  ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,minesweeper ;print 'Minesweeper'
    int 21h
    
    mov  dh, 3    ;row
    mov  dl, 5   ;column
    mov  bh, 0
    mov  ah, 02h  ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,purpose1 ;print 'In this game you have to find '
    int 21h
    
    mov  dh, 5    ;row
    mov  dl, 5   ;column
    mov  bh, 0
    mov  ah, 02h  ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,purpose2 ;print 'areas that are not mines.'
    int 21h
    
    mov  dh, 7    ;row
    mov  dl, 5     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,instructions1 ;print 'To do this, you need to enter '
    int 21h
    
    mov  dh, 9     ;row
    mov  dl, 5      ;column
    mov  bh, 0
    mov  ah, 02h    ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,instructions2 ;print 'row and column values.'
    int 21h
    
    mov  dh, 11     ;row
    mov  dl, 5      ;column
    mov  bh, 0
    mov  ah, 02h    ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,doneBy1 ;print 'Made by Ethem Akgul for the '
    int 21h
    
    mov  dh, 13     ;row
    mov  dl, 5      ;column
    mov  bh, 0
    mov  ah, 02h    ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,doneBy2 ;print 'microprocessors course.'
    int 21h
    
    mov  dh, 15      ;row
    mov  dl, 14      ;column
    mov  bh, 0
    mov  ah, 02h     ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,goodLuck ;print 'Good Luck'
    int 21h
    
    mov  dh, 17     ;row
    mov  dl, 5      ;column
    mov  bh, 0
    mov  ah, 02h    ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,choice1 ;print 'Do you want to see the'
    int 21h
     
    mov  dh, 19     ;row
    mov  dl, 5      ;column
    mov  bh, 0
    mov  ah, 02h    ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,choice2 ;print 'coordinates of the mines? (y/n) : '
    int 21h
      
ret
endp        
    
    

printDecimal proc          
     
    ;initialize count
    mov cx,0
    mov dx,0
    label1:
        ; if ax is zero
        cmp ax,0
        je print1     
         
        ;initialize bx to 10
        mov bx,10       
         
        ; extract the last digit
        div bx                 
         
        ;push it in the stack
        push dx             
         
        ;increment the count
        inc cx             
         
        ;set dx to 0
        xor dx,dx
        jmp label1
    print1:
        ;check if count
        ;is greater than zero
        cmp cx,0
        je exit
         
        ;pop the top of stack
        pop dx
         
        ;add 48 so that it
        ;represents the ASCII
        ;value of digits
        add dx,48
         
        ;interrupt to print a
        ;character
        mov ah,02h
        int 21h
         
        ;decrease the count
        dec cx
        jmp print1
exit:
ret
endp    
    

printHealth proc
    
    call setDataforPrint
    
    mov ah,09h        
    lea dx,healthStr ;print 'Health '
    int 21h
       
ret
endp

setHealth proc
    call setDataforPrint
    
    mov  dh, 0    ;row
    mov  dl, 7     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,erase
    int 21h
    
    mov  dh, 0    ;row
    mov  dl, 7     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    
    mov si,0
    mov ch,0
    mov cl,currentHealth
    sub cl,30h  
    
    cmp cl,0 
    
    je over
    
    showDHealth:
      
    mov dh,0
    mov ah, 2h
    mov dl,healthSymbol[si]
    int 21h
    
    inc si
    cmp si,cx
    jne showDHealth
    jmp done 
    
    over:
    
        mov ah,09h        
        lea dx,zero ;print '0'
        int 21h
    done:    

ret
endp    


printScore proc
    
    call setDataforPrint
    
    mov  dh, 0    ;row
    mov  dl, 25     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,scoreStr ;print 'Score : '
    int 21h
    
    mov ah,09h        
    lea dx,zero ;print '0'
    int 21h           
        
ret
endp


printMines proc
    
    call setDataforPrint
    mov si,0
    printMine:
        
        mov ah,09h        
        lea dx,brackets1 ;print '('
        int 21h  
        
        mov dh,0
        mov ah, 2h
        mov dl,mineRow[si]
        int 21h  
        
        mov ah,09h        
        lea dx,comma  ;print ','
        int 21h
        
        mov dh,0
        mov ah, 2h
        mov dl,mineColumn[si]
        int 21h
        
        mov ah,09h        
        lea dx,brackets2 ;print '('
        int 21h    
        
        inc si
        cmp si,6
        jne printMine

ret
endp    
    

setDataforPrint proc
    
    mov ax,@data 
    mov ds,ax     ;set data segment for printing on screen
    
ret
endp

setDataforLocation proc
    
    mov ax,0b800h 
    mov ds,ax     ;set data segment for finding location on screen
    
ret
endp



mineField proc
    
    mov cx,5
    mov bx,350

    field:    
        
        mov [bx], 178
        mov [bx+4], 178
        mov [bx+8], 178
        mov [bx+12], 178
        mov [bx+16], 178
        
        add bx,160
        
    loop field
         
        
ret
endp


InputOutput proc 

   
takeInput:

call setDataforPrint

mov  dh, 17    ;row
mov  dl, 0     ;column
mov  bh, 0
mov  ah, 02h   ;SetCursor 
int  10h


mov ah,09h        
lea dx,msgRow     ;print 'Row : '
int 21h



mov ah,01h        ;input Row
int 21h
mov dh,al

mov ch,dh

mov ah,09h        
lea dx,msgColumn     ;print ' Column : '
int 21h


mov ah,01h            ;input Column
int 21h
mov dl,al

mov cl,dl

mov ah,09h        
lea dx,arrow ;print ' ==> : '
int 21h

mov ah,09h        
lea dx,brackets1 ;print '('
int 21h

 

 
mov al,ch      ;ch = input row
mov ah,0eh
int 10h 

mov ah,09h        
lea dx,comma  ;print ','
int 21h



mov al,cl     ;dl = input column
mov ah,0eh
int 10h

mov ah,09h        
lea dx,brackets2  ;print ')'
int 21h

  
 

;check if inputs are between 1,5 

call setDataforLocation

cmp ch,30h      ;from ascii , decimal = 0
jbe clearRow    ;clear the current row

cmp ch,36h      ;from ascii , decimal = 6
jae clearRow    ;clear the current row

cmp cl,30h      ;from ascii , decimal = 0
jbe clearRow    ;clear the current row

cmp cl,36h      ;from ascii , decimal = 6
jae clearRow    ;clear the current row

jmp numberCorrect

clearRow:
    
    call setDataforPrint

    mov  dh, 17    ;row
    mov  dl, 0     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,space   ;print empty row(clear row)
    int 21h
    
    
    mov  dh, 17    ;row
    mov  dl, 0     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,again  ;print warning message
    int 21h
    
    mov cx, 100 
    nop         ; do nothing
    waiting: 
    dec cx 
    jnz waiting ; wait a little
    
    
    
    mov  dh, 17    ;row
    mov  dl, 0     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,space
    int 21h
    
    ;print '                                        '
     
    jmp takeInput
    
numberCorrect:

mov dh,ch  ;dh input row
mov dl,cl  ;dl input column    

;check the input coordinates to see if they have the same input coordinates
    
mov cx,25h           ;total areas 25      
mov si,0             ;0 to 25 for max inputs (max inputs are 21 ==> 2 mine area,19 safe area
    
call setDataforPrint
          
checkSameRowValues:

    cmp dh,inputRow[si]
    je checkSameColumnValues
    
    cmp si,23h
    jae differentCoordinates
    
    inc si
    jmp checkSameRowValues
        
checkSameColumnValues:
    
    cmp dl,inputColumn[si]
    je sameCoordinates
    
    cmp si,23h
    jae differentCoordinates
    
    inc si
    jmp checkSameRowValues
                    
sameCoordinates:
    
    call setDataforPrint
    
    mov  dh, 17    ;row
    mov  dl, 0     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,space   ;print empty row(clear row)
    int 21h
    
    mov  dh, 17    ;row
    mov  dl, 0     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,sameInputValues   ;print 'Enter a different coordinate than before'
    int 21h
    
    mov cx, 100 
    nop         ; do nothing
    waitaLittle: 
    dec cx 
    jnz waitaLittle ; wait a little
    
    mov  dh, 17    ;row
    mov  dl, 0     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,space   ;print empty row(clear row)
    int 21h
    
    jmp takeInput

      ;to find first zero value(default value) in inputRow

differentCoordinates:   ;add different coordinates 
    
    mov cx,0
    mov cl,numberofCoordinates                
    mov si,cx
    sub si,30h
    inc numberofCoordinates
    
    mov inputRow[si],dh
    mov inputColumn[si],dl

;check the input coordinates to see if they have the same input coordinates   
 


;check if the inputs overlap any mine

mov si,0 

call setDataforPrint

checkRow:
    
    cmp dh,mineRow[si]
    je checkColumn
   
    cmp si,6
    je fin
    
    incSi:
        inc si
        jmp checkRow
   
checkColumn:
    cmp dl,mineColumn[si]
    je blowMine
    
    inc si
    
    cmp si,6
    jne checkRow
    jmp fin

blowMine: 

    call setDataforLocation
    
    mov ch,0
    mov cl,dh
    sub cl,30h
    call findRow
    mov ch,0
    mov cl,dl
    sub cl,30h
    
    call findColumn 
    
    call paintMine 
    
    call setDataforPrint
    
    dec currentHealth
    
    call setHealth
     
    mov cl,currentHealth
    cmp cl,30h   ;0
    jne anotherRound
    
    call gameOver 
    
fin:  

    call setDataforLocation
    
    mov ch,0
    mov cl,dh
    sub cl,30h
    call findRow
    mov ch,0
    mov cl,dl
    sub cl,30h 
    
    call findColumn 
    
    call paintSafe
        

;check if the inputs overlap any mine 

;Set Score 
call setDataforPrint
mov  dh, 0    ;row
mov  dl, 32     ;column
mov  bh, 0
mov  ah, 02h   ;SetCursor 
int  10h

mov ah,09h        
lea dx,erase
int 21h

mov  dh, 0    ;row
mov  dl, 32     ;column
mov  bh, 0
mov  ah, 02h   ;SetCursor 
int  10h

add scorePoint,10 
mov ax,scorePoint        
call printDecimal


;win or not

cmp scorePoint,190
je win
jmp anotherRound

win:
jmp youWin

youWin:

    call congratulations

 

anotherRound:

 
mov  dh, 17    ;row
mov  dl, 0     ;column
mov  bh, 0
mov  ah, 02h   ;SetCursor 
int  10h

call setDataforPrint

;clear row
 
mov ah,09h        
lea dx,space
int 21h 
 
jmp takeInput


    
ret
endp
 

;find input row

findRow proc

    mov bx,191
    
    findRowL:

        add bx,160 ;831              
            
    loop findRowL
ret    
endP 

;find input row

;find input column

findColumn proc
    
    sub bx,4
    
    findColumnL:    

        add bx,4

    loop findColumnL

    ;mov [bx],11101100b
ret    
endp 

paintSafe proc
   
   mov [bx],1001b
   
ret
endp    

paintMine proc 
    
    mov [bx],11101100b
ret    
endp 


border proc ;build borders function 
    
    
    mov ah,6    ;set color
    mov al,0 
    mov bh,57   ;color ascii 
    
    
    ;outer borders
    
    
    ;top horizantal line
    
    mov ch,3    ;start row  
    mov cl,14   ;start column
    mov dh,3    ;end row (line width)
    mov dl,24   ;end column
    int 10h     ;print screen a line between values
            
    ;left vertical line
            
    mov ch,4    
    mov cl,14
    mov dh,13  
    mov dl,14
    int 10h
          
    ;bottom horizontal line
          
    mov ch,13   
    mov cl,14
    mov dh,13  
    mov dl,24  
    int 10h
     
    ;right vertical line
     
    mov ch,4    
    mov cl,24  
    mov dh,13  
    mov dl,24  
    int 10h 
    
    
    mov ah,6    ;set color
    mov al,0 
    mov bh,34
    
    
    ;inner borders
    
    ;1.horizontal
    
    mov ch,5    ;start row  
    mov cl,15   ;start column
    mov dh,5    ;end row (line width)
    mov dl,23   ;end column
    int 10h
    
    ;2.horizontal
    
    mov ch,7    ;start row  
    mov cl,15   ;start column
    mov dh,7    ;end row (line width)
    mov dl,23   ;end column
    int 10h
    
    ;3.horizontal
    
    mov ch,9    ;start row  
    mov cl,15   ;start column
    mov dh,9    ;end row (line width)
    mov dl,23   ;end column
    int 10h
    
    ;4.horizontal
    
    mov ch,11   ;start row  
    mov cl,15   ;start column
    mov dh,11   ;end row (line width)
    mov dl,23   ;end column
    int 10h
    
    ;1.vertical
            
    mov ch,4    
    mov cl,16
    mov dh,12  
    mov dl,16
    int 10h
    
    ;2.vertical
            
    mov ch,4    
    mov cl,18
    mov dh,12  
    mov dl,18
    int 10h
    
    ;3.vertical
            
    mov ch,4    
    mov cl,20
    mov dh,12  
    mov dl,20
    int 10h
    
    ;4.vertical
            
    mov ch,4    
    mov cl,22
    mov dh,12  
    mov dl,22
    int 10h
    
    ;mov ah,0  ;end
    ;int 21h

ret
endp

congratulations proc
    
    call setDataforPrint

    call clearAll
    
    mov  dh, 2      ;row
    mov  dl, 13     ;column
    mov  bh, 0
    mov  ah, 02h    ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,wellDone ;print 'Congratulations'
    int 21h
    
    mov  dh, 6      ;row
    mov  dl, 8     ;column
    mov  bh, 0      
    mov  ah, 02h    ;SetCursor 
    int  10h        
    
    mov ah,09h        
    lea dx,clearMines ;print 'You found all the mines.'
    int 21h
    
    mov  dh, 10      ;row
    mov  dl, 6     ;column
    mov  bh, 0      
    mov  ah, 02h    ;SetCursor 
    int  10h
    
    
    mov cl,currentHealth
    cmp cl,33h   ;3
    je fullHealth
    
    cmp cl,32h   ;2
    je halfHealth
    jmp lastHealth
    
    fullHealth:
        mov ah,09h        
        lea dx,fullHealthStr ;print 'And you didn't take any damage.'
        int 21h
    
        jmp cmpisDone
    
    halfHealth:
        mov ah,09h        
        lea dx,halfHealthStr ;print 'And now you have war scars.'
        int 21h
    
        jmp cmpisDone
        
    lastHealth:
        mov ah,09h        
        lea dx,lastHealthStr ;print 'But some limbs are missing.'
        int 21h
    
    cmpisDone:
    
    
    mov  dh, 14    ;row
    mov  dl, 15     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    
    mov ah,09h        
    lea dx,scoreStr ;print 'Score : '
    int 21h
    
    
    mov ax,scorePoint
    
    cmp ax,0  
    je printZero
    
    
    call printDecimal
    jmp dontPrintZero
    
    printZero:
        
        mov ah,09h        
        lea dx,zero ;print '0'
        int 21h             
    
    dontPrintZero:
        
    
    mov  dh, 16    ;row
    mov  dl, 13     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,pressAnyKey ;print 'Press Any Key'
    int 21h
    
    mov ah,07h    ;input without echo
    int 21h
    mov dh,al
    
    
hlt
endp

gameOver proc
    
    call setDataforPrint

    call clearAll
    
    mov  dh, 2    ;row
    mov  dl, 15     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,gameisOver ;print 'Game Over'
    int 21h
    
    mov  dh, 14    ;row
    mov  dl, 15     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    
    mov ah,09h        
    lea dx,scoreStr ;print 'Score : '
    int 21h
    
    
    mov ax,scorePoint
    call printDecimal
     
    
    mov  dh, 16    ;row
    mov  dl, 13     ;column
    mov  bh, 0
    mov  ah, 02h   ;SetCursor 
    int  10h
    
    mov ah,09h        
    lea dx,pressAnyKey ;print 'Press Any Key'
    int 21h
    
    mov ah,07h    ;input without echo
    int 21h
    mov dh,al
    
        
    
hlt
endp    


;find input column
end main