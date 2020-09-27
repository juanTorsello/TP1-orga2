
;dudas:
;como se usa la seccion . data, por el tema de que hay muchas funciones
;hay funciones que no las marca en la consigna, pero aca aparecen para hacerlas
;duda de las referencias
;preguntar que onda con las db y esas cosas
;en que tamaño se realizan las cuentas en assembler




section .data

; strPrint
;modo_fopen: db "w", 10
string_format: db "%s", 0
string_NULL: db "NULL",0

;modo_fopen_T: db "w", 10
tree_inicio_str: db "(", 0
tree_fin_str: db ")->", 0
string_format_inicio: db "%s", 0
string_NULL_T: db "NULL",0




section .text

%define NULL 0

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

global treePrintAux

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

  movss xmm1, [rdi]
  comiss xmm1, [rsi]
  je .iguales            ; ver como carajo son los saltos
  jb .menor
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
  push r15

  mov r13, rdi  ;guardo la posicion donde arranca mi parametro
  ; ya tengo en rdi donde arranca mi string para pasarselo a strLen
  call strLen  ; devuelve en rax el la cantidad de bytes que tengo que reservar
  mov rdi, rax ; lo paso a rdi para despues llamar a malloc
  inc rdi ; uno mas para el 0 final
  call malloc ;tengo en rax el puntero que apunta al arranque de la memoria resevada
  mov r12, rax ; no quiero modificar rax asi ya lo tengo apuntando al arranque del string que deveuelvo

.ciclo:
  cmp byte [r13], 0
  je .fin
  mov byte r14b, [r13] ;r13 apunta al arranque del string que recibo como parametro
  mov byte [rax], r14b
  inc r13
  inc rax
  jmp .ciclo

.fin:

  mov byte [rax], 0 ; le agregamos el 0 final
  mov rax, r12;

  pop r15
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
  push r12
  push r13

.ciclo:
  xor r12, r12
  xor r13, r13
  mov r12b, [rdi]  ; copio el char al que apunte rdi de "a"
  mov r13b, [rsi]  ; copio el char al que apunte rsi de "b"
  cmp r12b, r13b    ; cmp los char
  jl .menor
  jg .mayor
  cmp r12b, 0      ; Si alguno es 0, entonces fin
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

  pop r13
  pop r12
  pop rbp
  ret





strDelete:
  call free
  ret


  extern fprintf

  strPrint:
  ; char* a -> RDI
  ; FILE* pFile -> RSI

  ; Stack frame (Armado)
    push rbp
    mov rbp, rsp
    push r12
    push r13

    mov r12,rdi    ; R12 aux con el char* a
    mov rdi,rsi
    mov r13, rsi
    ;mov rsi, modo_fopen

    ; ; fopen toma rdi: FILE, rsi: modo_fopen
    ; call fopen
    mov rsi, string_format
    cmp byte [r12], 0
    je .NULL
    mov rdx,r12
    jmp .fprintf

  .NULL:
    mov rdx, string_NULL

  .fprintf:
    ;fprintf(fp, "%s", r8);
    ; rdi: FILE, rsi: string_format, rdx: char* a (R8)
    call fprintf
    mov rdi,r13
    ;call fclose ; RDI: FILE ; NO ANDA, preguntar si va aca o en C

  .fin:
    ; Stack Frame (Limpieza)
    pop r13
    pop r12
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
      sub rsp, 8
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

      ;salvamos caso vacio
      cmp dword [r13 + off_count], 0
      je .casoVacio

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
      ;jmp .fin

    .casoVacio:

    mov rdi, 16
    call malloc
    mov r14,rax

    mov dword [r12 + off_count], 0
    mov [r12 + off_doc_values], r14
    mov dword [r14 + off_type], 0
    mov qword [r14 + off_doc_values], NULL


    .fin:
      mov rax, r12

      pop r15
      pop r14
      pop r13
      pop r12
      pop rbx
      add rsp, 8
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


extern getCompareFunction

;void listAdd(list_t* l, void* data)
 listAdd:  ;54 instrucciones aprox

;list_t* (puntero a centinela) -> rdi
;void * data -> rsi

;armo stackframe
  push rbp
  mov rbp,rsp
  sub rsp, 8
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

  cmp qword [r12 + off_list_size], NULL
  je .casoVacio

  mov r15, [r12 + off_list_first_ptr] ;r15 -> puntero a first de la lista
; ciclo: (para encontrar donde va el nodo nuevo)
.ciclo:

  ;comparar
  mov rdi, [r12 + off_list_type]
  call getCompareFunction

  mov rdi, [r15 + off_nodeList_data]

  mov rsi, r14 ; el valor que recibimos por paramtro
  call rax   ; en rax nos quedo 1, 0 o -1

  cmp eax, 0
  jle .agregarIzq ;

  cmp qword [r15 + off_nodeList_next], NULL ; si es el ultimo elemento va a un caso especial
  je .casoUltimo

  mov r15, [r15 + off_nodeList_next]; avanzar
  jmp .ciclo

.agregarIzq:
  cmp qword [r15 + off_nodeList_prev], NULL
  je .esPrimero

  mov r13, [r15 + off_nodeList_prev]  ; que r13 sea el nodo anterior
  mov [r15 + off_nodeList_prev], rbx  ; que el r15->prev apunte al nuevo(rbx)
  mov [r13 + off_nodeList_next], rbx  ; que el r13->next apunte al nuevo(rbx)
  mov [rbx + off_nodeList_prev], r13  ; que el rbx->prev apunte a r13
  mov [rbx + off_nodeList_next], r15  ; que el rbx->next apunte a r15

  jmp .fin

.esPrimero:
  ;r12 -> centinela
  mov qword [rbx + off_nodeList_prev], NULL
  mov [rbx + off_nodeList_next], r15
  mov [r12 + off_list_first_ptr], rbx
  mov [r15 + off_nodeList_prev], rbx

  jmp .fin


.casoUltimo:
  mov [r15 + off_nodeList_next], rbx
  mov [rbx + off_nodeList_prev], r15
  mov qword [rbx + off_nodeList_next], NULL
  mov [r12 + off_list_last_ptr], rbx

  jmp .fin

.casoVacio:

  mov [r12 + off_list_last_ptr] , rbx
  mov [r12 + off_list_first_ptr], rbx
  mov qword [rbx + off_nodeList_next] , NULL
  mov qword[rbx + off_nodeList_prev] , NULL




.fin:


  mov [rbx + off_nodeList_data] , r14
  inc qword [r12 + off_list_size]  ; incrementamos el size de la lista

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  add rsp, 8
  pop rbp
  ret


;*** Tree ***


%define off_tree_first_ptr 0
%define off_tree_size 8
%define off_tree_type_key 12
%define off_tree_duplicates 16
%define off_tree_type_data 20

%define off_nodeTree_key 0
%define off_nodeTree_values 8
%define off_nodeTree_left 16
%define off_nodeTree_right 24



;int treeInsert(tree_t* tree, void* key, void* data)


extern listNew

treeInsert:
;tree_t* -> RDI
;void* key -> RSI
;void* data -> RDX
;armo stackframe
  push rbp
  mov rbp,rsp
  sub rsp,24
  push rbx
  push r12
  push r13
  push r14
  push r15

  mov r12, rdi        ; R12        -> PUNTERO A CENTINELA TREE
  mov [rbp - 8] , rsi ; [rbp - 8]  -> PUNTERO A KEY
  mov [rbp - 16], rdx ; [rbp - 16] -> PUNTERO A DATA (significado)

  ;ver si es primer elemento
  mov qword [rbp - 24], 0  ; flag Agregar Primero
  cmp dword [r12 + off_tree_size], 0
  je .preAgregado

  mov r13, [r12 + off_tree_first_ptr]  ; R13 -> PUNTERO A PRIMER NODO

.ciclo:

;comparo
  mov edi, [r12 + off_tree_type_key]
  call getCompareFunction

  mov rdi, [r13 + off_nodeTree_key] ; el elemento del tree
  mov rsi, [rbp - 8]                ; el valor que recibimos por paramtro

  call rax                          ; 1 si el parametro (rsi) es mas grande

  cmp eax, 0
  je .igual
  jl .masChico


.masGrande:

  cmp qword [r13 + off_nodeTree_right], NULL
  mov qword [rbp - 24], 1  ; flag Agregar Derecha
  je .preAgregado

  mov r13, [r13 + off_nodeTree_right]
  jmp .ciclo

.masChico:

  cmp qword [r13 + off_nodeTree_left], NULL
  mov qword [rbp - 24], -1  ; flag Agregar Izquierda
  je .preAgregado

  mov r13, [r13 + off_nodeTree_left]
  jmp .ciclo


.igual: ;en este caso hay que ver si esta permitido repetidos.


  cmp dword [r12 + off_tree_duplicates], 0
  je .set0
  mov rdi,[r12 + off_tree_type_data]
  call getCloneFunction
  mov rdi, [rbp - 16] ; puntero a data
  call rax
  ; setear parametro de listAdd
  mov rdi, [r13 + off_nodeTree_values]
  mov rsi, rax
  call listAdd
  jmp .fin

.set0:
  mov rax, 0
  jmp .fin

;por el momento terminado


.preAgregado:

  inc qword [r12 + off_tree_size];

  ;pedimos memoria
  mov rdi, 32
  call malloc
  mov rbx, rax        ; RBX -> PUNTERO A MEMORIA SOLICITADA

  ;clonamos la key
  mov rdi,[r12 + off_tree_type_key]
  call getCloneFunction
  mov rdi, [rbp - 8]  ;puntero a data
  call rax            ;clonamos key
  mov r14, rax        ;R14 -> KEY CLONADA

  ;clonamos la data
  mov rdi,[r12 + off_tree_type_data]
  call getCloneFunction
  mov rdi, [rbp - 16] ; puntero a data
  call rax            ; clonamos data
  mov r15, rax        ; R15 -> DATA CLONADA

  ;insertamos datos clonados
  mov [rbx + off_nodeTree_key], r14     ; insertamos key
  mov rdi , [r12 + off_tree_type_data]  ;pasamos tipo de list
  call listNew

  ; setear parametro de listAdd
  mov [rbx + off_nodeTree_values], rax  ;guardamos puntero a lista en nodo
  mov rdi, [rbx + off_nodeTree_values]
  mov rsi, r15
  call listAdd

  ;seteamos ptr izq y der en 0
  mov qword [rbx + off_nodeTree_left], NULL
  mov qword [rbx + off_nodeTree_right], NULL

  ;vemos a donde seguimos
  cmp qword [rbp - 24], 0
  mov rax, 1                ; return 1;
  je .agregarPrimero
  jl .agregarIzq


.agregarDer:

  mov [r13 + off_nodeTree_right], rbx
  jmp .fin

.agregarIzq:

  mov [r13 + off_nodeTree_left], rbx
  jmp .fin

.agregarPrimero:

  mov [r12 + off_tree_first_ptr], rbx


.fin:


  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  add rsp, 24
  pop rbp
  ret



;void treePrint(tree_t* tree, FILE *pfile){

treePrint:
;tree_t* -> RDI
;FILE *  -> RSI

  push rbp
  mov rbp,rsp
  sub rsp, 8
  push r12
  push r13
  push r14

  mov r12, rdi ; R12 -> PUNTERO A CENTINELA
  mov r13, rsi ; R13 -> *FILE

  cmp dword [r12 + off_tree_size], 0  ;caso vacio
  je .fin

  mov r14, [r12 + off_tree_first_ptr]  ; *actual

  mov rdi, r14
  mov rsi, r13
  mov edx, [r12 + off_tree_type_key]
  call treePrintAux

.fin:

  pop r14
  pop r13
  pop r12
  add rsp, 8
  pop rbp
  ret

extern getPrintFunction
extern listPrint


treePrintAux:
;treeNode_t* ->RDI
;FILE -> RSI
;type_t -> RDX

  push rbp
  mov rbp,rsp
  push r12
  push r13
  push r14
  push r15

  mov r12, rdi ; R12 -> *actual
  mov r13, rsi ; R13 -> *FILE
  mov r14d, edx ; R15 -> type_t

  cmp qword [r12 + off_nodeTree_left], NULL
  jne .recuIzq
  jmp .printNodoActual



.recuIzq:
    mov rdi, [r12 + off_nodeTree_left]
    mov rsi, r13
    mov edx, r14d
    call treePrintAux

.printNodoActual:

  mov rdi, r13
  mov rsi, tree_inicio_str
  call fprintf              ;imprime primer parentesis

  mov edi, r14d
  call getPrintFunction     ;ve que tipo hay que imprimir
  mov rdi, [r12 + off_nodeTree_key]
  mov rsi, r13
  call rax                  ;imprime valor key

  mov rdi, r13
  mov rsi, tree_fin_str
  call fprintf              ;imprime segundo parentesis

  mov rdi, [r12 + off_nodeTree_values]
  mov rsi, r13
  call listPrint           ;imprime lista

  cmp qword [r12 + off_nodeTree_right], NULL
  je .fin

.recuDer:

    mov rdi, [r12 + off_nodeTree_right]
    mov rsi, r13
    mov edx, r14d
    call treePrintAux


.fin:

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  ret






























;
