; Nadji najduzi podstring bez karaktera koji se ponavljaju

; pomeramo imaginarni prozor po unetom stringu
; dodajemo karakter po karakter
; ukoliko novi karakter vec postoji u trenutno posmatranom prozoru,
; izbacujemo elemente sleva, dok ne izbacimo element koji zelimo da dodamo
; ovako prolazimo kroz ceo string, i pamtimu granice prozora u trenutku kada je on bio najduzi
; kompleksnost algoritma O(n)
data segment
; Definicija podataka
    porukaUnos db 'Unesite string: $'   
    porukaDuzina db 'Duzina unetog stringa je: $'
    strDuzina db "        "
    brojDuzina dw 0         ; duzina stringa koji je unet od korisnika                    
    string db '                                   ' ; string koji se unosi od korisnika
    NizSet db 255 dup(0)    ; niz od 255 elemenata koji su svi nule na pocetku, ukoliku se neko slovo nadje u trenutno posmatranom prozoru, element na njegovom indeksu ce imati vrednost 1
    LeviIndex db 0          ; levi indeks trenutno posmatranog prozora
    LeviIndexFinal db 0     ; levi indeks konacnog najduzeg podstringa
    DesniIndex db 0         ; desni indeks trenutno posmatranog prozora
    DesniIndexFinal db 0    ; desni indeks konacnog najduzeg podstringa
    MaxDuzina dw 0          ; pamtimo max duzinu prozora 
    strMaxDuzina db "        " ; za ispis duzine..
    porukaMaxDuzina db 'Duzina podstringa: $'
    porukaPodstring db 'Najduzi podstring  u kojem se karakteri ne ponavljaju je:$'
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
    ; ispis duzine stringa
    push brojDuzina
    push offset strDuzina
    call inttostr
    writeString strDuzina

    ; Trazenje podstringa:
    
    
    ; Inicijalizujemo prozor na prvi karakter
    ; leva i desna granica prozora su na indeksu 0
    ; MaxDuzina se postavlja na 1
    ; u NizSet oznacavamo koji karakter postoji u prozoru sa vrednoscu 1
    
    ; si - index trenutnog elementa
    xor si, si
    xor ax, ax
    mov al, string[si]
    mov di, ax
    mov NizSet[di], 1
    mov MaxDuzina, 1

    ; ukoliko uneti string ima samo jedan karakter,
    ; prelazimo odmah na ispis
    cmp brojDuzina, 1
    je gotovaPodstringPetlja

    inc si
nadjiPodstringPetlja:
    ; prolazi kroz ceo uneti string, od pocevsi od indeksa 1

    ; while string[si - trenutni] in NizSet, pomeraj levi index
    ; zelimo da dodamo element na si indeksu u prozor
    ; dokle god taj element postoji u prozoru, pomeramo levu granicu prozora
    pomerajLeviIndexPetlja:
        xor ax, ax
        mov al, string[si]
        mov di, ax

        ; ako element koji ubacujemo nije u prozoru
        ; mozemo da predjemo na pomeranje desne granice, i
        ; da ga konacno dodamo u prozor
        cmp NizSet[di], 1
        jne pomeriDesniIndex

        ; izbacujemo najlevlji element iz prozora
        ; duzina imaginarnog prozora se ovde smanjuje
        xor ax, ax
        mov al, LeviIndex
        mov di, ax
        mov al, string[di]
        mov di, ax
        ; obelezavamo da string[di] vise nije u prozoru 
        mov NizSet[di], 0
        inc LeviIndex

        ; ponavljamo petlju za pomeranje levog indeksa,
        ; na pocetku petlje se radi provera, i
        ; po potrebi se prelazi na pomeranje desne granice za trenutni karakter
        jmp pomerajLeviIndexPetlja
        
        
    ; konacno pomeramo desnu granicu unapred
    ; duzina prozora se ovde povecava
    pomeriDesniIndex:
        xor ax, ax
        mov al, string[si]
        mov di, ax
        ; oznacavamo da je karakter dodat u prozor, i
        ; pomeramo desni indeks od prozora
        mov NizSet[di], 1
        inc DesniIndex
        ; MaxDuzina = max(MaxDuzina, DesniIndex - LeviIndex+1)
        ; racunamo novu duzinu prozora
        xor ax, ax
        mov al, DesniIndex
        sub al, LeviIndex
        inc al

        ; ukoliko je nova duzina veca od prethodne maksimalne duzine,
        ; podesavamo novu maksimalnu duzinu i nove krajnje granice prozora
        cmp ax, MaxDuzina
        jbe krajPodstringPetlja
        mov bl, LeviIndex
        mov LeviIndexFinal, bl
        mov bl, DesniIndex
        mov DesniIndexFinal, bl
        mov MaxDuzina, ax

; nakon zavrsetka obrade novog karaktera,
; prelazimo na sledeci karakter u nizu, i
; kada smo prosli kroz sve karaktere, prelazimo na ispis
krajPodstringPetlja:
    inc si
    cmp si, brojDuzina
    je gotovaPodstringPetlja
    jmp nadjiPodstringPetlja

gotovaPodstringPetlja:
    ; ispisi MaxDuzina
    call novired
    writeString porukaMaxDuzina
    push MaxDuzina
    push offset strMaxDuzina
    call inttostr
    writeString strMaxDuzina

; ispisi podstring
; ispisujem najduzi podstring
; tj. karaktere iz stringa od LeviIndexFinal do DesniIndexFinal, ukljucujuci i taj karakter na DesniIndexFinal, zato inc cx
call novired
xor si, si
xor ax, ax
mov al, LeviIndexFinal
mov si, ax
xor cx, cx
mov cl, DesniIndexFinal
inc cx

call novired
writeString porukaPodstring
call novired
call novired
ispisiPodstringPetlja:
    write string[si]
    inc si
    cmp si, cx
    je kraj
    jmp ispisiPodstringPetlja

kraj:
    call novired
    call novired
    writeString porukaKraj
    keypress
    krajPrograma 
ends
end start
