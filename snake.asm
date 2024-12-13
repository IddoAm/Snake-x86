
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
    
; Screen mode  
mov ax, 0x0013
int 10h
  
      
jmp game_loop

key_input db 0 
direction db 1; 1, up, 2, down, 3 right, 4 left
x_position dw 160
y_position dw 100  
color dw 4
  
game_loop:   
    mov al, key_input
        
    cmp al, 'w'         
    je set_up             
    
    cmp al, 's'            
    je set_down   
    
    cmp al, 'd'           
    je set_right           
    
    cmp al, 'a'            
    je set_left 
         
    move_player:     

    cmp direction, 2
    jbe vertical
      
    horizontal:
        mov ax, x_position  
        cmp direction, 3  
        je positive 
        jmp negetive
      
    vertical:
        mov ax, y_position  
        cmp direction, 1  
        jne positive
        
    negetive:
        dec ax
        jmp store_variable
        
    positive: 
        inc ax
      
    store_variable:     
        cmp direction, 2
        jbe store_y_position   
    
    store_x_position:
        mov x_position, ax  
        jmp drawing

    store_y_position:
        mov y_position, ax 
        
    drawing:  
    mov ax, x_position
    mov bx, y_position
    mov cx, color
      
    push cx
    push bx
    push ax
    
    call point
    
    sub sp, 6              
    
    input_handeling:

    mov ah, 0x01 
    int 16h               
    jz no_key_pressed          
             
    mov ah, 0x00
    int 16h
    mov [key_input], al  

    jmp game_loop

set_up:
    mov direction, 1      
    jmp move_player

set_down:
    mov direction, 2      
    jmp move_player         
    
set_right:
    mov direction, 3      
    jmp move_player

set_left:
    mov direction, 4       
    jmp move_player


    
no_key_pressed:
    mov [key_input], 0
    jmp game_loop 
    
PROC point ; Draw pixel (dw x, dw y, db colorIndex)
    push bp              
    mov bp, sp 
     
    mov ah, 0ch
    mov cx, [bp+4] ; x
    mov dx, [bp+6] ; y
    mov al, [bp+8] ; color
    int 10h
    
    
    mov sp, bp            
    pop bp  
    ret 
ENDP point

ret




