; declaration d'un tableau d'entier 

data segment
    erreur db 0AH,0DH,"la valeur inseree est >255 vous douvez re-saisir $,10,13"   
    er db 0AH,0DH,"l'affichage en binaire :$,10,13" 
    e db 0AH,0DH,"l'affichage en decimal :$,10,13"
    msg1 db 0AH,0DH,"donner la valeur a insere :$,10,13"
    msg db 0AH,0DH,"la fin du tableau  $,10,13"   
    tab db 100 dup(?) 
    cn db 3 dup(?)   
    x dw ?                                        
    h db 0AH,0DH,"l'affichage en hexadecimal :$,10,13"
data ends


code segment
    assume ds:data,cs:code,ss:seg_pile
debut:
    mov ax,data
    mov ds,ax
      
    push offset erreur
    push offset cn
    push offset msg1
    push offset e 
   
    
    mov di,0
    mov si ,0 
bcl:
    xor cx,cx   ; ici on fait cx=0 pour re-initialiserle cl apres avoir une valeur qu'est >255
    push ax 
    push cx        ;pour garder l'etat de la sortie "1,2,3"
    call lecture 
    
    call convertion 
    pop cx
    pop ax 
    cmp cl,2       ;taille insuffisante
    jz bcl        ; on fait un saut pour re-boucler
       
    mov tab[si],al ; sinon on inserre la valeur obtenu
    
    cmp cl,1
    jz etiq
    
    cmp cl,3
    jz saut
    inc si
    inc di 
    cmp di,99
    jnz bcl ;ici on fait la verification si on depasse la taille on compare avec 99 car j'ai reserve une cqse pour l'*  

saut:
    mov tab[si+1],'*'
    jmp fn   
etiq:
  
fn:
    lea dx,msg  
    mov ah,09H
    int 21H
           
    mov bx, offset tab 
    push bx            ; on empile l'@ du tableau pour faire l'addition
    
    push ax            ; push ax pour recuperer le resultat 
    call addition 
    pop ax             ; la recuperation du resultat 
    mov x,ax           ; on met le resultat dans x puis on fait push pour garder la valeur pour l'affichage
    pop bx 
     
    push offset h
    push offset er
    push x             ; on push x
    call affichage    
  
    jmp fin  
    

    
lecture PROC Near
    ; sauvegarde du contexte
    push cx
    push ax
    push di
    push bp
    ; recuperation des parametre
    mov bp,sp
    mov di,[bp+18]
      
    mov dx,[bp+16]  ; AFFICHER LE MESSAGE QUI DEMANDE A LUTILISATEUR D4ENTRER LES NOMBRES
    mov ah,09H
    int 21H
    
    mov cx ,3   ; car on a trois chiffres 
bouc:    
    mov ah, 01H ; la saisie
    int 21H 
                                            
    cmp al,'*'
    jz et     ;ici si on trouve une * on fait jmp pour stocker la valeur sans la convertir
    sub al,30H            
    mov [di],al    ; on a fait mov di,cn (l'adresse du chaine)  
  
    inc di
    loop bouc
et: 
    sub al,30H
    mov [di],al 
      
    pop bp 
    pop di 
    pop ax
    pop cx
       
    ret
lecture ENDP 


convertion PROC Near 
    ; sauvegarde du contexte
    push bx
    push ax
    push bp
    push si
    push cx 
    ; recuperation des parametre
    mov bp,sp
    mov si,[bp+20]     ; si recoit l'@ de cn 
    
    ; traitement
    xor ax,ax
    xor cx,cx
    mov al,[si] ;verification si la valeur est une * ou non 
    
    add al,30H
    cmp al,'*'   ;ici à chaque saisie on verifie si il y a *
    jz etiq1
    
    sub al,30H
    mov cl,[si+1] 
    
    add cl,30H
    cmp cl,'*'
    jz etiq2
    
    sub cl,30H
    mov bx,10
    mul bx 
    
    add ax,cx
    
    mov cl,[si+2]
    add cl,30H
    cmp cl,'*'
    jz etiq2
    
    sub cl,30H
    mov bx,10
    mul bx 
    
    add ax,cx    
    cmp ah,0 
    mov [bp+14] ,ax
    jne taille  
    jmp fin1
    
etiq1:
    mov [bp+14],al   ;on met le resultat dans dx  
    mov [bp+12],1
    jmp fin1     ; on garde le resultat de la convertion
    
etiq2:     
    mov [bp+14],ax
    mov [bp+12],3    
    jmp fin1     ; on garde le resultat de la convertion
         
taille:
    mov [bp+12],2
    mov dx,[bp+22]  ; affichage d'un message
    mov ah,09H
    int 21H
    ; si la taille est insuffisante alors on fait un appel a nouveau pour le remplissage
    
fin1:
    
    pop cx 
    pop si
    pop bp
    pop ax
    pop bx
    ret
convertion ENDP
     

addition PROC Near
    ; sauvegarde du contexte
    push di
    push bp 
    push ax   
    push bx
    ; recuperation des parametre
    ; on prend l'adresse du tableau apartir de la pile on le met dans bx
    mov [bp+10],0             
    mov bp ,sp 
    lea di,tab 
    xor ax,ax  
    ; traitement
    
bcle:
    
    mov bl,[di]
   
    cmp bl,'*'  ;verefication si on a trover l'* ou pas pour ne pas l'additionner
    jz finb      
     
    add ax, bx
    inc di 
    jmp bcle   
finb:
    mov [bp+10],ax 
    ; restauration du contexte
    pop bx
    pop ax
    pop bp
    pop di
ret    
addition ENDP     

affichage PROC Near 
   
   ;sauvegarde du contexte 
   push ax
   push bx
   push dx
   push cx 
   push bp
   ;recuperation des parametres 
   mov bp,sp
   
   mov dx,[bp+18]   ; affichage d'un message 
   mov ah,09H
   int 21H
   
   xor dx,dx
   xor ax,ax

   ;traitement
   mov ax,[bp+12]   ; recuperation du resultat
   mov bx,1000  
   div bx
           
   add al,30H 
     
   mov cx,dx
   
   mov dl,al
   mov ah,02H
   int 21H  
   
   mov ax,cx
   mov bl,100
   div bl
   
   add al,30H  
  
   mov cl,ah  
   
   mov dl,al
   mov ah,02H
   int 21H       
   
   mov ax,cl
   mov ah,0
   mov bl,10
   div bl
   
   add al,30H
   mov cl,ah
   add cl,30H
          
   mov dl,al
   mov ah,02H
   int 21H       
  
   
   mov dl,cl
   mov ah,02H
   int 21H  
   
   mov dx,[bp+14]  
   mov ah,09H
   int 21H
   
   mov bx,[bp+12]
   mov cx, 16
print: mov ah, 2   
       mov dl, '0'
       test bx, 1000000000000000b  
       jz zero
       mov dl, '1'
zero:  int 21h
       shl bx, 1
loop print


    mov dx,[bp+16]  
    mov ah,09H
    int 21H
   
    
    mov bx,[bp+12]
    and bx,1111000000000000b  ;mettre les 4 premiers bits dans le poids faible 
    shr bx,12
    cmp bx,10
    jge etH
    sub bx,7  ; ici j'ai fait une soustraction car on a va passer par etH si on aura bx>9 donc pour ne pas ajouter trop d'instruction
etH:
    add bl,37H
    mov dl,bl   
    mov ah,02H
    int 21H
   
 
    mov bx,[bp+12]
    and bx,0000111100000000b  ; bx<-les 4bits 
    shr bx,8
    cmp bx,10
    jge etH1
    sub bx,7
etH1:
    add bl,37H
    mov dl,bl   
    mov ah,02H
    int 21H 
   
    mov bx,[bp+12]
    and bx,0000000011110000b  ; bx<-les 4bits 
    shr bx,4
    cmp bx,10
    jge etH2
    sub bx,7
etH2:
    add bl,37H
    mov dl,bl   
    mov ah,02H
    int 21H 
   
    mov bx,[bp+12]
    and bx,0000000000001111b  ; bx<-les 4bits 
    cmp bx,10
    jge etH3
    sub bx,7
etH3:
    add bl,37H
    mov dl,bl   
    mov ah,02H
    int 21H  
   
   
   
   ; restauration des parametres 
    pop bp
    pop cx
    pop dx
    pop bx 
    pop ax
ret 
affichage ENDP     


        
fin: 
    popa 
    
    
    mov ax,4CH
    int 21H
code ends 
end debut
