; Da li je uneti string palindrom - iterativno

data segment
; Definicija podataka
    porukaUnos db 'Unesite string: $'   
    porukaDuzina db 'Duzina unetog stringa je: $'
    strDuzina db "        "
    brojDuzina dw 0                             
    string db '                      '
    porukaJestePalindrom db 'String jeste palindrom$'
    porukaNijePalindrom db 'String nije palindrom$'
    porukaKraj db 'Pritisnite neki taster...$'
  
ends
; Deficija stek segmenta
stek segment stack
    dw 128 dup(0)
ends
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
; Kraj programa           
krajPrograma macro
    mov ax, 4c02h
    int 21h
endm   

; String length proc
getLength macro source, destination
    push ax
    push dx 
    push cx              
    LOCAL duzina
    mov dx, offset source 
    mov si, dx
    mov cx, 0
    duzina:            
        mov al, [si] 
        add cx, 1  
        inc si 
        cmp al, '$' 
        jne duzina
    dec cx
    mov destination, cx  
    pop cx
    pop dx
    pop ax   
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

; check palindrom recursive
isPalindrom proc
    push ax
    push bx
    push cx
    push dx
    mov bp, sp
    mov si, [bp+12]
    mov di, [bp+10]

    cmp si, di
    ja jestePalindrom

    mov al, string[si]
    mov bl, string[di]
    cmp al, bl
    jne nijePalindrom

    jmp dalje


jestePalindrom:
    call novired
    writeString porukaJestePalindrom
    jmp krajRekurzije

nijePalindrom:
    call novired
    writeString porukaNijePalindrom
    jmp krajRekurzije


dalje:
    inc si
    dec di
    push si
    push di
    call isPalindrom

krajRekurzije:



    pop dx
    pop cx
    pop bx
    pop ax
    ret 4

start:
    ; postavljanje segmentnih registara       
    ASSUME cs: code, ss:stek
    mov ax, data
    mov ds, ax
	
    ; Mesto za kod studenata

    ; Ucitavanje stringa sa tastature
    call novired
    writeString porukaUnos

    push 20
    push offset string
    call readString

    ; dobavljanje i ispis duzine stringa
    getLength string, brojDuzina
    call novired
    writeString porukaDuzina
    write ' '
    ; konvertovanje broja u string
    push brojDuzina
    push offset strDuzina
    call inttostr
    writeString strDuzina


    ; Provera da li je string palindrom
    
    ; si - pokazivac na pocetak stringa
    xor si, si
    ; di - pokazivac na kraj stringa
    xor di, di
    mov di, brojDuzina

    call novired
    write string[si]
    call novired
    dec di
    write string[di]

    ; poziv rekuzivne funkcije
    push si
    push di
    call isPalindrom

kraj:   
    call novired
    writeString porukaKraj
    keypress
    krajPrograma 
ends
end start
