.686
.model flat, stdcall
option casemap: none ; case sensitive
    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\fpu.inc
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\fpu.lib
.data
    A DD 1.5
    B DD 0.8
    V8 DD 8.0
    V1 DD -1.0
    S DT 0.0
    str1 db "str1"
    str2 db "str2"
.code
start:
    FLD A
    FLD V8
    FMUL ST(0), ST(1) ;st0 = A*8
    FSTP A

    FLD B
    FCOMI ST(0),ST(1)
    JC A8greaterB
    FLD B
    F2XM1
    FLD1
    FADD ST,ST(1)
    FLD B
    JMP Stop

    A8greaterB:
    FLD B
    F2XM1
    FLD1
    FADD ST,ST(1)
    FLD A
    

    Stop:
    FADD ST,ST(1)
    FSTP S
    invoke FpuFLtoA, addr S, 5, addr str1+4, SRC1_REAL or SRC2_DIMM or STR_REG
    invoke MessageBox, 0, addr str2, addr str1, MB_OK
    invoke ExitProcess, NULL

end start
