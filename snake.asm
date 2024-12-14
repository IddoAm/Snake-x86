
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
    
; Screen mode  
mov ax, 0x0013
int 10h
  
      
jmp game_loop

key_input db 0  

direction db 1; 1, up, 2, down, 3 right, 4 left
last_direction db 1   


; end, turn-segements, start
snake_x dw 160, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
snake_y dw 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

segment_count dw 2 

snake_length dw 30 
used_length dw 1

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
    mov bx, segment_count ; head index 
    dec bx
    shl bx, 1    
    
    mov ah, direction
    cmp last_direction, ah
    je no_new_segment
    
    ; Create new segment 
    inc segment_count
    add bx, 2
    mov ax, snake_x[bx-2] 
    mov cx, snake_y[bx-2] 
    
    mov snake_x[bx], ax 
    mov snake_y[bx], cx    
    
    no_new_segment:
        
    
    cmp direction, 2
    jbe vertical    
    
    horizontal:
        mov ax, snake_x[bx]  
        cmp direction, 3  
        je positive 
        jmp negetive
      
    vertical:
        mov ax, snake_y[bx]   
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
        mov snake_x[bx], ax  
        jmp move_tail

    store_y_position:
        mov snake_y[bx], ax 
        
     
        
    move_tail:   
    mov cx, used_length
    cmp cx, snake_length
    jl not_move_end
    
    ; Undraw end
    mov ax, snake_x[0]
    mov dx, snake_y[0]
    mov cx, 0
      
    push cx
    push dx
    push ax
    
    call point
    
    sub sp, 6  
    ; Move towards other cell   
    mov dx, 1 ; go positive
      
    mov cx, snake_x[0]
    cmp cx, snake_x[2]    
    je move_tail_y
      
    move_tail_x:
        cmp cx, snake_x[2]  
        jg set_positive_x       
        mov dx, -1
          
        set_positive_x:
        
               
        sub snake_x[0], dx
        jmp segment_tail_status
           
    move_tail_y: 
        mov cx, snake_y[0] 
        cmp cx, snake_y[2]  
        jg set_positive_y       
        mov dx, -1
          
        set_positive_y:
        
        sub snake_y[0], dx
        jmp segment_tail_status
    
    segment_tail_status:
    
    ; Check if the tail reached the segement, if it did remove the segment and collapse the rest 
     
    mov cx, snake_x[0]
    cmp cx, snake_x[2]
    jne drawing 
      
    mov cx, snake_y[0]
    cmp cx, snake_y[2]
    jne drawing
     
     
    mov di, 2
    dec segment_count  
    sub bx, 2
    move_segments:
        cmp di, bx
        jg drawing 
        
        mov ax, snake_x[di+2]
        mov cx, snake_y[di+2]
        mov snake_x[di], ax
        mov snake_y[di], cx   
        
        add di, 2
        jmp move_segments
    
    not_move_end:
    inc used_length
    
        
    drawing:  
    mov ax, snake_x[bx]
    mov bx, snake_y[bx]
    mov cx, color
      
    push cx
    push bx
    push ax
    
    call point
    
    sub sp, 6              
    
    input_handeling:
     
    mov al, direction    
    mov last_direction, al
     
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




