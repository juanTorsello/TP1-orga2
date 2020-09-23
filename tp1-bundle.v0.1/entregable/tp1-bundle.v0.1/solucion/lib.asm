
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
    %define off_doc_node 16

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


extern getDeleteFunction
extern intDelete

docDelete:    ; parece andar, no rompe, pero tiene leaks
; void docDelete(document_t* a)
; Borra un documento, esto incluye borrar todos los datos que contiene utilizando las funciones delete
; asociadas a cada tipo de los datos.

;IN: document_t* a -> RDI

;armo stackframe
  push rbp
  mov rbp,rsp
  push rbx
  push r12
  push r13
  push r14
  push r15

  mov r12, rdi  ; me guardo el puntero al document en r12
  mov r13, [rdi + off_doc_values] ; * a values
  mov rbx, [rdi + off_count] ; auxiliarmente r9 = document.count
  xor r15, r15  ; limpio iterador del ciclo

.ciclo:
  cmp r15, rbx
  je .doc_t_delete

  ; value delete:
  ; borro el contenido (value)
  mov rdi, [r13 + off_type] ; rdi = type_t
  call getDeleteFunction
  mov rdi, [r13 + off_data_ptr] ; rdi = * data
  call rax  ; call al delete correspondiente

  ; borro el tipo (value)    ; creo que el tipo este vendria a ser int, sino por las dudas
                             ; se puede repetir lo mismo de antes y llamar a rax
  ;;mov rdi, [r13 + off_type] ; rdi = * type_t
  ;;call intDelete
  ; call getDeleteFunction
  ; mov rdi, [r13 + off_type] ; rdi = * type_t
  ; call rax  ; call al delete correspondiente
  ;;;;xor r13, r13

  ; avanzo
  inc r15 ; avanzo la i
  add r13, off_doc_node  ; avanzo el puntero al siguiente nodo (r13 + 16)
  jmp .ciclo

.doc_t_delete:

  ;delete doc value ponter: ;al ya borrrar todos los nodos, ahora solo borro el puntero
  mov rdi, [r12 + off_doc_values]
  call free

  ;delete doc count:
  xor r12, r12 ; limpio por las dudas el doc_count


.fin:

  pop r15
  pop r14;
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret

  ; r12  : * document in
  ; r15  : contador "i" del ciclo

  ; ? habra que hacer un delete del vector tambien?


; idea:
;
; recorrer values e ir borrando

; Finalmente borrar:
    ;document_t:
      ; int count;
      ; docElem_t* values;







;*** List ***


%define off_list_type 0
%define off_list_size 4
%define off_list_first_ptr 8
%define off_list_last_ptr 16
%define off_nodeList_data 0
%define off_nodeList_next 8
%define off_nodeList_prev 16









; void listAdd(list_t* l, void* data){
;
;     //a es parametro
;     while (l.haySiguiente) {
;       if(a < b){
;         if es primero → agregar izquierda acomodando centila, caso first
;         agregamos a la izquierda
;       } else{
;         if(l.esUltimo){
;           agregar a la derecha, caso last
;         } else{
;         l.avanzar
;         }
;     }
;
; }

extern getCompareFunction

;void listAdd(list_t* l, void* data)
listAdd:  ;54 instrucciones aprox
;list_t* (puntero a centinela) -> rdi
;void * data -> rsi

;armo stackframe
  push rbp
  mov rbp,rsp
  push rbx
  push r12
  push r13
  push r14
  push r15

;filtramos caso vacio

; preparamos todo:
  mov r12, rdi ; guardamos el puntero a centinela en otro lugar para no perderlo
  mov r14, rsi ; sacamos la data de rsi

; new Node:
  mov rdi, 24
  call malloc
  mov rbx, rax ; guardamos en rbx la memoria solicitada

; filtramos caso vacio
  cmp qword [r12 + off_list_size], 0
  je .casoVacio

  mov r15, [rdi + off_list_first_ptr] ;r15 -> puntero a first de la lista
; ciclo: (para encontrar donde va el nodo nuevo)
.ciclo:
  ; cmp qword [r15 + off_nodeList_next], 0 ; si es el ultimo elemento va a un caso especial
  ; je .casoUltimo

  ;comparar
  mov rdi, [r12 + off_list_type]
  call getCompareFunction
  mov rdi, [r15  + off_nodeList_data]    ; a = el valor del elemento de la lista, b = nuestro valor a meter
  mov rsi, [r14] ; el valor que recibimos por paramtro
  call rax   ; en rax nos quedo 1, 0 o -1

  cmp rax, 0
  jle .agregarIzq ; para que no se me aumente siempre el r13 cuando ya es momento de enlazar, y no de volver al ciclo, MENOR O IGUAL JEJe

  cmp qword [r15 + off_nodeList_next], 0 ; si es el ultimo elemento va a un caso especial
  je .casoUltimo

  mov r15, [r15 + off_nodeList_next]; avanzar
  jmp .ciclo

.agregarIzq:
  cmp qword [r15 + off_nodeList_prev], 0
  je .esPrimero

  mov r13, [r15 + off_nodeList_prev]  ; que r13 sea el nodo anterior
  mov [r15 + off_nodeList_prev], rbx  ; que el r15->prev apunte al nuevo(rbx)
  mov [r13 + off_nodeList_next], rbx  ; que el r13->next apunte al nuevo(rbx)
  mov [rbx + off_nodeList_prev], r13  ; que el rbx->prev apunte a r13
  mov [rbx + off_nodeList_data], r14  ; que el rbx->dato apunte a r14
  mov [rbx + off_nodeList_next], r15  ; que el rbx->next apunte a r15

  jmp .fin

.esPrimero:
  ;r12 -> centinela
  mov byte [rbx + off_nodeList_prev], 0 ;;;
  mov [rbx + off_nodeList_data], r14
  mov [rbx + off_nodeList_next], r15
  mov [r12 + off_list_first_ptr], rbx
  mov [r15 + off_nodeList_prev], rbx

  jmp .fin


.casoUltimo:
  mov [r15 + off_nodeList_next], rbx
  mov [rbx + off_nodeList_prev], r15
  mov [rbx + off_nodeList_next], 0
  mov [rbx + off_nodeList_data], r14
  mov [r12 + off_list_last_ptr], rbx

  jmp .fin

.casoVacio:

  mov [r12 + off_list_last_ptr] , rbx
  mov [r12 + off_list_first_ptr], rbx
  mov [rbx + off_nodeList_data] , r14
  mov [rbx + off_nodeList_next] , 0
  mov [rbx + off_nodeList_prev] , 0


; fin :)

.fin:

  inc  [r12 + off_list_size]  ; incrementamos el size de la lista
  ; despues se puede poner el dato solo aca en el fin
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret


;*** Tree ***

treeInsert:
ret
treePrint:
ret
