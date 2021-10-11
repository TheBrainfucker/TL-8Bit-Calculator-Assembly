.MODEL SMALL  
.STACK 100H  
.DATA

MSG DB '### TL Calculator ###$'
MSG0 DB 10,13,10,13,'Calculate 2 unsigned 8-Bit Hex numbers.$'  
MSG1 DB 10,13,10,13,'To Add, type: 1$'
MSG2 DB 10,13,'To Sub, type: 2$'
MSG3 DB 10,13,'To Mul, type: 3$'
MSG4 DB 10,13,'To Div, type: 4$'
MSG5 DB 10,13,'what do  you want to do: $'
MSG6 DB 10,13,10,13,'Enter 1st Number: $'
MSG7 DB 10,13,'Enter 2nd Number: $'
MSG8 DB 10,13,10,13,'Result: $'
MSG9 DB 10,13,10,13,'RULE: Insert UPPER case letters for hex value. PUT 0(ZERO) BEFORE SINGLE DIGIT NUMBER. E.g. 01,02,..,0E,0F$' 
MSG10 DB 10,13,'Remainder: $'                          
NUM1 DB ?
NUM2 DB ?
RESULT DB ?
REMAINDER DB ?
CARRY DB 00H
CHOICE DB ?
COUNT DB 00H 

.CODE
MAIN PROC
        
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX,MSG
    MOV AH,9
    INT 21H

    LEA DX,MSG0
    MOV AH,9
    INT 21H
    
    LEA DX,MSG1
    MOV AH,9
    INT 21H
    
    LEA DX,MSG2
    MOV AH,9
    INT 21H
    
    LEA DX,MSG3
    MOV AH,9
    INT 21H
    
    LEA DX,MSG4
    MOV AH,9
    INT 21H 
     
    LEA DX,MSG5
    MOV AH,9
    INT 21H
    
    MOV AH,1
    INT 21H
    MOV CHOICE,AL
    
    LEA DX,MSG9
    MOV AH,9
    INT 21H
    
    LEA DX, MSG6
    MOV AH,09H
    INT 21H
    CALL READ_8_BIT
    MOV NUM1,AL
    
    MOV AH,09H
    LEA DX, MSG7
    INT 21H
    CALL READ_8_BIT
    MOV NUM2,AL
    
    MOV BH,CHOICE ;CHOOSE OPERATOR
    SUB BH,48
    
    CMP BH,1
    JE ADD_ME
    
    CMP BH,2
    JE SUB_ME
     
    CMP BH,3
    JE MUL_ME
    
    CMP BH,4
    JE DIV_ME
    

    OUTPUT:
        MOV RESULT,AL
        MOV REMAINDER,AH
        
        MOV AH,09H
        LEA DX, MSG8
        INT 21H
        
        CMP CARRY,0
        JNE PRINT_CARRY
        
        MOV AL,RESULT
        MOV AH,REMAINDER
        JMP DIV_AND_PRINT  
   
    ADD_ME:
        XOR AH,AH
        MOV AL,NUM1
        ADD AL,NUM2
        JNC OUTPUT
        INC CARRY
        JMP OUTPUT
   
    SUB_ME:
        XOR AH,AH
        MOV AL,NUM1
        SUB AL,NUM2
        JNC OUTPUT
        INC CARRY
        JMP OUTPUT  
    
    MUL_ME:
        XOR AH,AH
        MOV AL,NUM2
        MUL NUM1
        JNC OUTPUT
        INC CARRY
        JMP OUTPUT
 
    DIV_ME:  
        XOR AH,AH
        MOV BH,NUM2
        MOV AL,NUM1
        DIV BH
        INC CARRY
        JMP OUTPUT
  
    PRINT_CARRY:
        MOV BH,CHOICE
        SUB BH,48
        
        CMP BH,1
        JE ADD_OVERFLOW
        CMP BH,4
        JE DIV_OVERFLOW
        
        MOV AL,REMAINDER
        JMP DIV_AND_PRINT
        
        ADD_OVERFLOW:
            MOV AL,CARRY
            JMP DIV_AND_PRINT
            
        DIV_OVERFLOW:    
            MOV AL,RESULT
            MOV AH, REMAINDER
            MOV RESULT, AH
            
    DIV_AND_PRINT:    
        INC COUNT  
        XOR AH,AH
        MOV BH,16
        DIV BH
        MOV REMAINDER,AH
        CMP AL,0
        JE LAST_TIME
        CMP AL,09H
        JLE GOT_NUMBER
                               
    GOT_LETTER:
        ADD AL,55
            
        MOV AH,2
        MOV DL,AL
        INT 21H
        
        MOV AL,REMAINDER
        CMP COUNT,2
        JE DONE_CARRY
        JMP DIV_AND_PRINT
    
    GOT_NUMBER:
        ADD AL,48
        
        MOV AH,2
        MOV DL,AL
        INT 21H
        
        MOV AL,REMAINDER
        CMP COUNT,2
        JE DONE_CARRY
        JMP DIV_AND_PRINT

    LAST_TIME:
        MOV COUNT,2
        MOV AL,AH
        CMP AL,09H
        JLE GOT_NUMBER
        JMP GOT_LETTER   
  
    DONE_CARRY:    
        CMP CARRY,1
        JNE EXIT
         
        MOV BH,CHOICE
        SUB BH,48
        
        CMP BH,4
        JNE NOT_DIV_OVERFLOW
        MOV AH,09H
        LEA DX, MSG10
        INT 21H 
        
        NOT_DIV_OVERFLOW:
            MOV CARRY,0
            MOV AL,RESULT
            JMP DIV_AND_PRINT                     
        
    EXIT:
        
    MOV AX, 4C00H
    INT 21H
        
MAIN ENDP

PROC READ_8_BIT
    
    PUSH CX
    MOV AH,01H
    INT 21H
    
    SUB AL,30H ;ASCII TO HEXA
    CMP AL,09H ;CHECK IF IT'S A NUMBER
    JLE SUB_P1
    SUB AL,07H
    
    SUB_P1:
        MOV CL,04H
        ROL AL,CL
        MOV CH,AL
        MOV AH,01H
        INT 21H
        SUB AL,30H
        CMP AL,09H
        JLE SUB_P2
        SUB AL,07H
    
    SUB_P2:
        ADD AL,CH
        POP CX
        RET
    
ENDP READ_8_BIT  

END MAIN
