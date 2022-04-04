data segment
    ; Definicija podataka
    poruka0 db "Unesite broj elemenata niza: $" 
    strMaxNiz db "        "
    MaxNiz dw 0
    poruka1 db "Unesite broj: $"
    strN db "        "
    N dw 0
    Niz dw 100 dup(0)
    NizObrnut dw 100 dup(0)
    poruka2 db "Obrnut niz: $"
    poruka3 db "Pritisnite neki taster...$"
ends
; Deficija stek segmenta
stek segment stack
    dw 128 dup(0)
ends
; Ispis znaka na ekran  
write macro c
    push ax   
    push dx
    mov ah, 02
    mov dl, c
    int 21h
    pop dx
    pop ax
endm
; Ucitavanje znaka bez prikaza i cuvanja     
keypress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm
; Isis stringa na ekran
writeString macro s
    push ax
    push dx  
    mov dx, offset s
    mov ah, 09
    int 21h
    pop dx
    pop ax
endm
; Kraj programa           
krajPrograma macro
    mov ax, 4c02h
    int 21h
endm   
           
code segment
; Novi red
novired proc
    push ax
    push bx
    push cx
    push dx
    mov ah,03
    mov bh,0
    int 10h
    inc dh
    mov dl,0
    mov ah,02
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
novired endp
; Ucitavanje stringa sa tastature
; Adresa stringa je parametar na steku
readString proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov dx, [bp+12]
    mov bx, dx
    mov ax, [bp+14]
    mov byte [bx] ,al
    mov ah, 0Ah
    int 21h
    mov si, dx     
    mov cl, [si+1] 
    mov ch, 0
kopiraj:
    mov al, [si+2]
    mov [si], al
    inc si
    loop kopiraj     
    mov [si], '$'
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
readString endp
; Konvertuje string u broj
strtoint proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov bx, [bp+14]
    mov ax, 0
    mov cx, 0
    mov si, 10
petlja1:
    mov cl, [bx]
    cmp cl, '$'
    je kraj1
    mul si
    sub cx, 48
    add ax, cx
    inc bx  
    jmp petlja1
kraj1:
    mov bx, [bp+12] 
    mov [bx], ax 
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
strtoint endp
; Konvertuje broj u string
inttostr proc
   push ax
   push bx
   push cx
   push dx
   push si
   mov bp, sp
   mov ax, [bp+14] 
   mov dl, '$'
   push dx
   mov si, 10
petlja2:
   mov dx, 0
   div si
   add dx, 48
   push dx
   cmp ax, 0
   jne petlja2
   
   mov bx, [bp+12]
petlja2a:      
   pop dx
   mov [bx], dl
   inc bx
   cmp dl, '$'
   jne petlja2a
   pop si  
   pop dx
   pop cx
   pop bx
   pop ax 
   ret 4
inttostr endp

obrniNiz proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
        
    ; popunjavanje obrnutog niza                  
    xor di, di ; destination index, index u obrnutom nizu
    mov cx, MaxNiz
    mov si, cx
    mov al, 2
    mul si
    mov si, ax
obrni:    
    sub si, 2  ; source index, index u unetom nizu
    mov ax, Niz[si]
    mov NizObrnut[di], ax
    add di, 2
    loop obrni
    
    pop di
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret
obrniNiz endp

start:
    ; postavljanje segmentnih registara       
    ASSUME cs: code, ss:stek
    mov ax, data
    mov ds, ax
	
    ; Mesto za kod studenata
    call novired
    writeString poruka0
    push 3
    push offset StrMaxNiz
    call readString    
    ; Konvertovanje stringa u broj
    push offset StrMaxNiz
    push offset MaxNiz
    call strtoint 
    ; Smestanje broja u niz
    mov cx, MaxNiz                                        
    mov si, 0
unos:
    ; Ucitavanje broja u string                  
    call novired
    writeString poruka1
    push 6
    push offset strN
    call readString    
    ; Konvertovanje stringa u broj
    push offset strN
    push offset N
    call strtoint 
    ; Smestanje broja u niz
    mov ax, N
    mov Niz[si], ax 
    ; SI se poveca za 2 kako bi dobio poziciju sledeceg elementa u nizu, jer su elementi niza veliki 2 bajta.
    add si, 2
    loop unos

    call obrniNiz
    
    call novired
    writeString poruka2
    call novired
    ; ispis obrnutog niza
    mov cx, MaxNiz
    xor si, si

ispisiNiz:
    mov ax, NizObrnut[si]
    push ax
    push offset strN
    call inttostr
    writeString strN
    Write ' '
    add si, 2
    loop ispisiNiz
    
    ; kraj programa
    call novired
    writeString poruka3
    keypress
    krajPrograma 
ends
end start
