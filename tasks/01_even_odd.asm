org 100h

code_seg    SEGMENT
    MOV AX, 0x9999  ; inicijalni broj
    MOV BX, 0xFFFF  ; broj koji se dodaje na inicijalni
    ADD AX, BX
    MOV SI, AX ; proverava se parnost AX
    AND SI, 1 ; si = 0 ako je ax paran, 1 ako je neparan

kraj:	JMP kraj ; beskonacna petlja, kraj programa

code_seg	ENDS
END
