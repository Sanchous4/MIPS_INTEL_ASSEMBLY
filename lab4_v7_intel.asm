.686
    .model flat, stdcall
    option casemap :none
    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\fpu.inc;
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\fpu.lib

.data
    someArray DD    1, 2, 3, 4, 5,
                    1, 6, 13, 3, 4,
                    1, 7, 5, 6, 2,
                    1, 3, 5, 6, 1
    rowIndex dD 2 ; -2
    columnIndex dD 3 ; -2 
    matchNumber Dd 0
    firstItemDiagonal Dd ?
    secondItemDiagonal dd ?
    firstAddressDiagonal Dd ?
    secondAddressDiagonal dd ?
    thirdItemDiagonal dd ?
    adressReturn Dd ?
    saverEDX dd ?
    titleApp db "App",0
    linkResultSumTitle byte 50 dup (?)
    linkResultPrevious byte 50 dup (?)
    foundElements db "Suitable elments in someArray: %.1li",0;
    foundPreviousElement db "Address of previous element: %.8lx",0;
    notFoundSuitableElemnts db "No suitable elements",0 ;
    notFoundPreviousElement db "Previous element doesn't exist",0;
.code
    start: 
    XOR EBX,EBX
    ADD EBX,20 ;next column 
    MOV ECX, rowIndex ;счётчик циклов по строкам

    loopByRows: 
        MOV EDX, columnIndex ;счётчик циклов по столбцам
        XOR ESI,ESI
        INC ESI
        XCHG ECX,EDX ;перенастройка ЕСХ на счётчик столбцов

        loopByColumns: 
            push someArray[EBX+ESI*4-4-20]
            push someArray[EBX+ESI*4]
            push someArray[EBX+ESI*4+4+20]
            mov saverEDX,EDX
            CALL compareDiagonal
            mov EDX, saverEDX
            JNE nextColumn
            INC matchNumber
            LEA EAX, someArray[EBX+ESI*4];
            PUSH EAX
                
            nextColumn: 
                INC ESI
                LOOP loopByColumns
                ADD EBX,20
                XCHG ECX,EDX ;перенастройка ЕСХ на счётчик строк
                LOOP loopByRows

    cmp matchNumber, 0
    JE noMatchs
    cmp matchNumber, 1
    JE oneMatch

    pop firstAddressDiagonal
    pop secondAddressDiagonal

    invoke wsprintf, ADDR linkResultSumTitle, ADDR foundElements, matchNumber
    invoke MessageBox, NULL, ADDR linkResultSumTitle, addr titleApp, MB_OK
    invoke wsprintf, ADDR linkResultPrevious, ADDR foundPreviousElement, secondAddressDiagonal
    invoke MessageBox, NULL, ADDR linkResultPrevious, addr titleApp, MB_OK           

    jmp STOP

    noMatchs:
        invoke MessageBox, NULL, ADDR notFoundSuitableElemnts, addr titleApp, MB_OK
        jmp STOP

    oneMatch:
        invoke wsprintf, ADDR linkResultSumTitle, ADDR foundElements, matchNumber
        invoke MessageBox, NULL, ADDR linkResultSumTitle, addr titleApp, MB_OK
        invoke MessageBox, NULL, ADDR notFoundPreviousElement, addr titleApp, MB_OK
        jmp STOP

    STOP: invoke ExitProcess, NULL

    compareDiagonal proc 
        POP adressReturn 
        POP firstItemDiagonal
        POP secondItemDiagonal 
        POP thirdItemDiagonal
        MOV EAX, firstItemDiagonal
        MUL thirdItemDiagonal
        CMP EAX, secondItemDiagonal
        PUSH adressReturn 
        RET
    compareDiagonal endp
end start
