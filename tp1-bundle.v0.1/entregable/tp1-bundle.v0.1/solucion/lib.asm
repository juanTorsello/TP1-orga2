
;dudas:
;como se usa la seccion . data, por el tema de que hay muchas funciones
;hay funciones que no las marca en la consigna, pero aca aparecen para hacerlas
;duda de las referencias
;preguntar que onda con las db y esas cosas
;en que tamaño se realizan las cuentas en assembler




section .data

; strPrint
modo_fopen: db "w", 10
string_format: db "%s", 10, 0
string_NULL: db "NULL",10,0




section .text

global floatCmp
global floatClone
global floatDelete
global floatPrint

global strClone
global strLen
global strCmp
global strDelete
global strPrint

global docClone
global docDelete

global listAdd

global treeInsert
global treePrint

extern malloc
extern free

;*** Float ***

floatCmp:
  ;rdi a
  ;rsi b
  ;eax resultado

  ;armo stracframe
  push rbp
  mov rbp, rsp

  movss xmm1, [rsi]
  comiss xmm1, [rdi]
  je .iguales            ; ver como carajo son los saltos
  jl .menor
  mov  eax, -1
  jmp .fin
.iguales:
  mov eax, 0       ; VA DD?????????????? o algun otro, o no hace falta
  jmp .fin
.menor:
  mov  eax, 1
.fin:
  pop rbp
  ret


floatClone:
  ;armo stackframe
  push rbp
  mov rbp,rsp

  movss xmm0, [rdi]
  mov rdi, 4
  call malloc
  movss [rax], xmm0
  ;fin
  pop rbp
  ret


floatDelete:
  call free
  ret


;*** String ***

strClone:
  ;char* a -> RDI
  ; armo stackframe
  push rbp
  mov rbp,rsp
  push r12
  push r13
  push r14

  mov r13, rdi  ;guardo la posicion donde arranca mi parametro
  ; ya tengo en rdi donde arranca mi string para pasarselo a strLen
  call strLen  ; devuelve en rax el la cantidad de bytes que tengo que reservar
  mov rdi, rax ; lo paso a rdi para despues llamar a malloc
  call malloc ;tengo en rax el puntero que apunta al arranque de la memoria resevada
  mov r12, rax ; no quiero modificar rax asi ya lo tengo apuntando al arranque del string que deveuelvo
.ciclo:
  cmp byte [r13], 0 ; l ; NOOO FUNCA
  je .fin
  mov r14B, [r13] ;r13 apunta al arranque del string que recibo como parametro
  mov [rax], r14B
  inc r13
  inc rax;
  jmp .ciclo

.fin:
  mov rax, r12;
  pop r14
  pop r13
  pop r12
  pop  rbp
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





strLen:
; char* a -> RDI
; Stack frame (Armado)
  push rbp
  mov rbp, rsp

  xor rax, rax  ; limpio el eax
.ciclo:
  cmp byte [rdi], 0  ;veo si termina el string
  je .fin
  inc rax       ;
  inc rdi       ; avanzo la posicion en el string
  jne .ciclo
.fin:
  ; Stack Frame (Limpieza)
  pop rbp
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



strCmp:
  ;char* a -> RDI
  ;char* b -> RSI

  ;armo Stackframe
  push rbp
  mov rbp,rsp

.ciclo:
  mov r8b, [rdi]  ; copio el char al que apunte rdi de "a"
  mov r9b, [rsi]  ; copio el char al que apunte rsi de "b"
  cmp r8b, r9b    ; cmp los char
  jl .menor
  jg .mayor
  cmp r8b, 0      ; Si alguno es 0, entonces fin
  je .iguales
  inc rdi         ; inc rdi para que apunte al siguiente char
  inc rsi         ; inc rsi para que apunte al siguiente char
  jmp .ciclo
.menor:
  mov eax, 1
  jmp .fin
.mayor:
  mov eax, -1
  jmp .fin
.iguales:
  mov rax, 0
.fin:
  pop rbp
  ret




strDelete:
  call free
  ret





  ;extern fopen
  ;extern fclose
  extern fprintf

  strPrint:
  ; char* a -> RDI
  ; FILE* pFile -> RSI

  ; Stack frame (Armado)
    push rbp
    mov rbp, rsp

    mov r8,rdi    ; R8 aux con el char* a
    mov rdi,rsi
    mov r9, rsi
    ;mov rsi, modo_fopen

    ; ; fopen toma rdi: FILE, rsi: modo_fopen
    ; call fopen
    mov rsi, string_format
    cmp byte [r8],0
    je .NULL
    mov rdx,r8
    jmp .fprintf

  .NULL:
    mov rdx, string_NULL

  .fprintf:
    ;fprintf(fp, "%s", r8);
    ; rdi: FILE, rsi: string_format, rdx: char* a (R8)
    call fprintf
    mov rdi,r9
    ;call fclose ; RDI: FILE ; NO ANDA, preguntar si va aca o en C

  .fin:
    ; Stack Frame (Limpieza)
    pop rbp
    ret





;*** Document ***
; document_t* docClone(document_t* a)
; Genera una copia del documento junto con todos sus datos. Para esto, debe llamar a las funciones
; clone de cada uno de los tipos de los datos que integran el documento.
; posibles cosos: none, int, float, string, document

extern getCloneFunction
extern intClone


    %define off_type 0
    %define off_count 0
    %define off_data_ptr 8
    %define off_doc_values 8

    docClone:
      ; document_t* a -> RDI
      ;armo stackframe
      push rbp
      mov rbp,rsp
      sub rsp,16
      push rbx
      push r12
      push r13
      push r14
      push r15


      mov r13, rdi
      mov r13, [r13 + off_doc_values]; PUNTERO AL VALUE ORIGINAL

      ; largo del vector
      mov rcx, [rdi + off_count]
      mov [rbp - 8], rcx


      ;armar el document_t nuevo
      mov rdi, 16 ;tamaño del bloque
      call malloc
      mov r12, rax             ;PUNTERO A NUEVO DOCUMENTO -> R12
                               ;0x408670 memoria de nuevo doc
      ; creamos arreglo

      mov  rax , [rbp - 8]
      mov r8, 16 ; el tamaño de cada elemento del vector
      mul r8 ; mul  cx        ; supuestamente hace rax = r8 * rax
      mov rdi, rax ; paso el document_size * 16 a rdi para el malloc
      call malloc
      mov r14,rax ; PUNTERO AL NUEVO VECTOR DE DOCUMENTOS -> R14
                  ; 0x408690 memoria de nuevo values


      ; Ya tenemos toda la memoria solicitada
      ; volcado de data a document:

      mov rcx, [rbp - 8]
      mov [r12 + off_count], rcx
      mov [r12 + off_doc_values], r14

      ; volcado de data a los document elem:
      xor r15, r15 ; RCX contador del vector (la "i" de nuestro querido for)
      xor rbx, rbx
    .ciclo:
      cmp r15 , [rbp - 8]
      je .fin
      mov r9, [r13 + rbx + off_type] ; pisamos el que antes era el largo
      mov [r14  + rbx + off_type], r9
      mov rdi, r9
      call getCloneFunction
      mov rdi, [r13 + rbx + off_data_ptr]
      call rax
      mov [r14 + rbx + off_data_ptr], rax
      add rbx, 16
      inc r15
      jmp .ciclo
      ;r9   : auxiliar que tiene el tipo del dato
      ;r12  : * al nuevo documento
      ;r13  : * al values
      ;r15  : contador de ciclos
    .fin:
      mov rax, r12

      pop r15
      pop r14
      pop r13
      pop r12
      pop rbx
      add rsp, 16
      pop rbp
      ret



docDelete:
ret

;*** List ***

listAdd:
ret

;*** Tree ***

treeInsert:
ret
treePrint:
ret
