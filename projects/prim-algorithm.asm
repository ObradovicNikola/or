; zadatak:
; Dat je niz tacaka sa X i Y koordinatama u 2D koordinatnom sistemu. 
; Cena povezivanja dve tacke je Manhattan distanca izmedju njih (apsolutna vrednost). 
; Vratiti koji je minimalni trosak povezivanja svih tacaka 
; (sve tacke su povezane ako postoji putanja izmedju bilo koje 2 tacke). 
; ==========
; imamo potpun graf za koji treba pronaci tezinu minimalnog pokrivajuceg stabla
; minimum spanning tree (eng.)
; ==========
; postoje dva algoritma za resavanje ovog problema Primov i Kruskalov
; ali  u asembleru nam je jednostavnije da implementiramo Primov algoritam za ovaj zadatak
; Primov algoritam:
; https://www.geeksforgeeks.org/prims-minimum-spanning-tree-mst-greedy-algo-5/
; 1) Napravimo set mstSet (minimum spanning tree set) koji ce da cuva cvorove koje dodamo u MST,
;   u nasem slucaju ovo ce da bude niz nula i jedinica. Element x je u MST, ako je mstSet[x] == 1. 
; 2) Dodeljujemo key vrednost za svaki cvor u ulaznom grafu. Inicijalizujemo sve key vrednosti kao INFINITE (0xFFFF).
; 3) Dodelimo kljucnu vrednost 0 prvom cvoru, to znaci da pravimo nase stablo pocevsi od ovog cvora
; 4) Dokle god ima cvorova u grafu koji nisu u mstSet-u: 
;    a) Odaberemo cvor U koji nije u mstSet-u i ima najmanju vrednost kljuca od svih takvih cvorova. 
;    b) Stavimo odabrani cvor u mstSet. 
;    c) Azuriramo vrednost kljuca svih suseda cvora U (kod nas su svi susedi). Da bi smo azurirali vrednost kljuca, 
;       za svaki susedni cvor V koji vec nije u mstSet-u, ako je tezina grane izmedju cvorova U i V manja od 
;       prethodne vrednosti kljuca cvora V, azuriramo vrednost kljuca cvora V na tezinu grane U-V.
; 5) Kada smo dodali sve cvorove u mstSet, algoritam je zavrsen i tezina minimalnog pokrivajuceg stabla je zbir svih kljuceva
; * ideja je da je kljucna vrednost svakog cvora tezina grane koja ga povezuje sa ostatkom minimalnog pokrivajuceg stabla
data segment
    ; Definicija podataka
    poruka0 db "Unesite broj elemenata tacaka: $" 
    strMaxNiz db "        "
    MaxNiz dw 0
    poruka1 db "Unesite x koordinatu: $"
    poruka2 db "Unesite y koordinatu: $"
    strN db "        "
    N dw 0
    NizX dw 100 dup(0)
    NizY dw 100 dup(0)
    mstSet dw 100 dup(0)
    mstSetCount dw 0
    cvorU dw 0xFFFF
    NizKljuceva dw 100 dup(0xFFFF)
    porukaRezultat db "Tezina minimalnog pokrivajuceg stabla: $"
    strRez db "           "
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

nadjiCvorU proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Petlja za prolazak kroz sve tacke
    xor si, si
    xor di, di
    ; smesti index cvora U u cvorU
    ; resetuj cvorU
    mov cvorU, 0xFFFF
    petljaNadjiCvorU:
        mov ax, MaxNiz
        mov dx, 2
        mul dx
        cmp si, ax
        jge krajNadjiCvorU

        ; Ako je trenutni ukljucen u mstSet
        ; prelazimo na sledeceg kandidata
        cmp mstSet[si], 1
        je sledeciCvorU

        ; u suprotnom, proveravamo da li trenutni cvor ima manji kljuc od trenutnog U ako je U vec bio izabran
        cmp cvorU, 0xFFFF
        je setujNoviU
        mov di, cvorU
        ; si - trenutni kljuc
        ; di - kljuc cvora U
        mov ax, NizKljuceva[si]
        cmp ax, NizKljuceva[di]
        ; unsigned poredjenje, jer NizKljuceva[si] je unsigned, a pocinje sa 1, pa je ovo jako bitno
        jae sledeciCvorU

        setujNoviU:
            mov cvorU, si

    sledeciCvorU:
        ; SI se poveca za 2 kako bi dobio poziciju sledeceg elementa u nizu, jer su elementi niza veliki 2 bajta.
        add si, 2
        jmp petljaNadjiCvorU
    krajNadjiCvorU:
        mov di, cvorU
        mov mstSet[di], 1
        inc mstSetCount

    pop di  
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax 
    ret
nadjiCvorU endp

azurirajKljuceve proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; sada pravimo petlju za azuriranje kljuceva svih cvorova koji vec nisu u mstSet-u
    xor si, si
    azurirajKljucevePetlja:
        mov ax, MaxNiz
        mov dx, 2
        mul dx
        cmp si, ax
        jge krajAzurirajKljuceve

        ; Ako je trenutni ukljucen u mstSet
        ; prelazimo na sledeci cvor
        cmp mstSet[si], 1
        je sledeciCvor

        ; u suprotnom, azuriramo kljuc trenutnog cvora
        ; racunamo Manhattan distancu izmedju cvora U ciji je indeks u cvorU i trenutnog cvora
        mov di, cvorU
        mov ax, NizX[si]
        mov bx, NizY[si]
        mov cx, NizX[di]
        mov dx, NizY[di]
        cmp ax, cx
        jge oduzmiOdPrvogX
        sub cx, ax
        mov ax, cx
        jmp racunajY
        oduzmiOdPrvogX:
            sub ax, cx
        racunajY:
        cmp bx, dx
        jge oduzmiOdPrvogY
        sub dx, bx
        mov bx, dx
        jmp racunajManhattan
        oduzmiOdPrvogY:
            sub bx, dx
        racunajManhattan:
        ; u ax je abs(x1-x2)
        ; u bx je abs(y1-y2)
        add ax, bx
        ; manhattan distanca je u ax
        ; poredimo novu distancu sa trenutnom vrednosti kljuca u NizKljuceva[si]
        cmp ax, NizKljuceva[si]
        ; unsigned poredjenje, jer NizKljuceva[si] je unsigned, a pocinje sa 1, pa je ovo jako bitno
        jae sledeciCvor
        mov NizKljuceva[si], ax
        jmp sledeciCvor

        sledeciCvor:
        ; SI se poveca za 2 kako bi dobio poziciju sledeceg elementa u nizu, jer su elementi niza veliki 2 bajta.
        add si, 2
        jmp azurirajKljucevePetlja
    krajAzurirajKljuceve:

    pop di
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax 
    ret
azurirajKljuceve endp

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
    xor si, si
    ; xor, resetuje registar na 0
unosTacaka:
    ; Ucitavanje x koordinate                  
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
    mov NizX[si], ax

    ; Ucitavanje y koordinate                  
    call novired
    writeString poruka2
    push 6
    push offset strN
    call readString    
    ; Konvertovanje stringa u broj
    push offset strN
    push offset N
    call strtoint 
    ; Smestanje broja u niz
    mov ax, N
    mov NizY[si], ax

    ; SI se poveca za 2 kako bi dobio poziciju sledeceg elementa u nizu, jer su elementi niza veliki 2 bajta.
    add si, 2
    loop unosTacaka

    ; Primov algoritam
    xor si, si
    mov NizKljuceva[si], 0


    ; Petlja za prolazak kroz sve tacke, dokle god je mstSetCount manji od MaxNiz
    prim:
        mov ax, mstSetCount
        cmp ax, MaxNiz
        jge krajPrima

        ; pogledati sta je cvor U u uvodnom opisu algoritma ako nije jasno
        call nadjiCvorU
        ; sada imamo index cvora U u cvorU promenljivoj
        ; mozemo da azuriramo NizKljuceva svih cvorova koji nisu u mstSet-u
        call azurirajKljuceve
        jmp prim
    krajPrima:

    ; sada moramo da saberemo kljuceve iz niza NizKljuceva
    ; da bi smo dobili konacnu tezinu  mst-a
    ; cuvamo zbir u cx
    xor cx, cx
    xor si, si
    petljaSaberiKljuceve:
        mov ax, MaxNiz
        mov bx, 2
        mul bx
        cmp si, ax
        jge krajSaberiKljuceve

        add cx, NizKljuceva[si]
        add si, 2
        jmp petljaSaberiKljuceve

    krajSaberiKljuceve:
    ; ispis rezultata na ekran
    call novired
    call novired
    writeString porukaRezultat
    push cx
    push offset strRez
    call inttostr
    writeString strRez

    ; kraj programa
    call novired
    call novired
    writeString poruka3
    keypress
    krajPrograma 
ends
end start
