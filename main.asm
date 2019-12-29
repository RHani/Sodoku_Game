INCLUDE Irvine32.inc
INCLUDE macros.INC

	CARRIAGE_RETURN = 13
	SPACE = 10
	BOARD_SIZE = 81 * 2

	NAME_SIZE   = 10
	TRIALS_SIZE = 1
	TIME_SIZE   = 5
	STAT_SIZE   = 18 

	BOARD_SIZE_2 = 500

player STRUCT
	playerName byte 10 dup(?)
	playerCorrect word 0
	playerWrong word 0
	playerTime dd 0
player ENDS

Plyer struc 
	Nam byte 4 dup(?) 
	Correct_try byte ?
	Wrong_try byte ? 
	PLay_time Dword ?
Plyer ends

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
.DATA
    
	ROW_SIZE byte 9

	; for validating input
	correct_msg byte 'Correct!' , 0
	wrong_msg byte 'Wrong!'     , 0
	invalid_msg byte 'Invalid!' , 0
	isCorrect byte ? ; for cmp_value proc , boolean output
	indx byte ?
	row_space byte ?
	
	; sodoku boards
	tmp_board  BYTE BOARD_SIZE DUP(?)
	init_board BYTE BOARD_SIZE DUP(?) 
	user_board BYTE BOARD_SIZE DUP(?)
	ans_board  BYTE BOARD_SIZE DUP(?)
	
	; readingFile proc
	fileHandle HANDLE ?
	boardFile Byte "SudokuBoards/diff_?_?.txt",0 
	boardAnsFile Byte "SudokuBoards/diff_?_?_solved.txt",0
	
	; trials counter | stat data
	trials_wrong word   0
	trials_correct word 0
	steps_count word   0

	; game timing
	start_time word ?
	time_taken word ?
	time_taken_arr byte 5 dup(?)

	; storing currect game state
	prev_user byte "SudokuBoards\previous\user.txt" , 0
	prev_init byte "SudokuBoards\previous\init.txt" , 0
	prev_ans  byte "SudokuBoards\previous\ans.txt"  , 0
	prev_stat byte "SudokuBoards\previous\stat.txt" , 0

	outputFile byte "Output.txt" , 0
	
	trials byte 3
	stat byte 10 dup(?)

	; Menu data
	gameLabel byte    "         ~SODOKU GAME~        " , 0
	bar byte      "******************************"     , 0
	loadPrev byte "**** 1-LOAD PREVIOUS GAME ****"     , 0
	newGame byte  "********  2-NEW GAME   *******"     , 0
	diff1 byte    "********** 1-Easy   **********"     , 0 
	diff2 byte    "********** 2-Medium **********"     , 0
	diff3 byte    "********** 3-Hard   **********"     , 0
	nameEntry byte"*** Please enter your name ***"     , 0
	showSolvedTxt byte "*** 1- Wanna see solved board " , 0
	resetBoardTxt byte "*** 2- Reset the board        " , 0
	enterValTxt   byte "*** 3- Input a value (r,c,val)" , 0
	exitTxt   byte     "*** 4- Exit                   " , 0

	; board separators
	sep_h byte " --------------------------- " , 0
	sep_v byte "|", 0

	rr byte ?
	cc byte ?
	vv byte ?

	; player stat
	currentPlayer player {"anonymous" , 0 , 0 , 0 }
	tmpArr byte STAT_SIZE dup(?)
	playerNameTmp byte 10 dup(?)
	playerTimeTmp byte 5 dup(0)
	enterName byte "Please enter your name: ",0
	nameSize dd ?

	;extras
	zeros_count dword 0
	numConv dd 0
	delimiter byte ','
	player_name byte 10 dup(0)
	emptyArr byte " ",0
	tmpUserRead byte 200 dup(?)

	; bonus stuff variables
	buffer byte BOARD_SIZE_2 dup(?)
	tem dword ?
	file_len dword ?
	end_of_file dword ?
	Temp_plyer Plyer <>     
	Plyers Plyer 20 dup (<>)
	s dword 20
	sss dword 10

	Na_me byte 5 Dup(?)
	
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
.code
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;ReadingFile proc reads from file into a buffer
;Recieves file name
;Returns the board in EAX
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
rankFn PROC file_name:ptr dword

	; Open the file for input.
	mov edx, file_name
	mov ecx , sizeof file_name
	call OpenInputFile
	mov fileHandle,eax ; cursor -> filehandle

	; Check for errors.
	cmp eax,INVALID_HANDLE_VALUE ; error opening file?
	jne file_ok ; no: skip and close if has problem
	jmp quit

	file_ok:
	; Read the file into a buffer.
	mov edx,OFFSET buffer
	mov ecx, BOARD_SIZE_2
	call ReadFromFile

	jnc check_buffer_size ; error reading?

	call WriteWindowsMsg
	jmp close_file

	check_buffer_size:
	cmp eax,BOARD_SIZE_2 ; buffer large enough?
	jb buf_size_ok ; yes

	jmp quit ; and quit if is large

	buf_size_ok:
	mov buffer[eax], 0 ; insert null terminator
	mov file_len , eax

	;---------------
	;Display the buffer.
	mov edx , OFFSET buffer ; display the buffer

	;Read The File ---------------
	mov esi , offset Plyers

	BigWhile :
	cmp byte ptr [edx],'@'
	je end_bigwhile 

	;Fill The Name ---------------
	Namewhile :

	cmp byte ptr [edx],2ch

	je end_namewhile 

	mov bl ,byte ptr [edx]
	mov (Plyer ptr[esi]).Nam[0], bl
	inc edx

	mov al ,(Plyer ptr[esi]).Nam[0]
	call writechar
 

	mov bl ,byte ptr [edx]

	mov (Plyer ptr[esi]).Nam[1], bl
	inc edx
	mov al ,(Plyer ptr[esi]).Nam[1]
	call writechar
 
	mov bl ,byte ptr [edx]

	mov (Plyer ptr[esi]).Nam[2], bl
	inc edx
	mov al ,(Plyer ptr[esi]).Nam[2]
	call writechar
 

	mov bl ,byte ptr [edx]

	mov (Plyer ptr[esi]).Nam[3], bl
	inc edx
	mov al ,(Plyer ptr[esi]).Nam[3]
	call writechar

	jmp NameWhile

	end_Namewhile :
	;Fill The Name ---------------
	inc edx
	call crlf 

	;Fill The Correct ---------------
	Correctwhile :

	cmp byte ptr [edx],2ch

	je end_correctwhile 

	mov bl ,byte ptr [edx]
	mov (Plyer ptr[esi]).Correct_try, bl
	mov al ,(Plyer ptr[esi]).Correct_try
	 call writechar
	 inc edx 

	jmp Correctwhile

	end_correctwhile :
	;Fill The Correct ---------------
	inc edx
	call crlf
	;Fill The Wrong ---------------
	Wrongwhile :

	cmp byte ptr [edx],2ch

	je end_wrongwhile 

	mov bl ,byte ptr [edx]
	mov (Plyer ptr[esi]).Wrong_try, bl
	mov al ,(Plyer ptr[esi]).Wrong_try
	call writechar
	inc edx 

	jmp Wrongwhile

	end_wrongwhile :
	;Fill The Wrong ---------------
	inc edx
	call crlf 
	;Fill The Time ---------------
	Timewhile :

	cmp byte ptr [edx],2ch

	je end_timewhile 

	mov ebx ,dword ptr [edx]
	add edx , 3
	mov tem , ebx
	;---------------

	mov edi , offset tem
	mov ebx ,0

	push edx
	mov ecx , 4
	l1 :
	push ecx 
	mov eax , 10 
	mul ebx
	mov ebx , eax
	mov cl ,byte ptr [edi]
	sub cl , 48
	add bl , cl

	inc edi
	pop ecx
	loop l1 
	pop edx

	;---------------

	mov (Plyer ptr[esi]).PLay_time , ebx
	inc edx

	mov eax , (Plyer ptr[esi]).PLay_time 
	call writedec

	jmp Timewhile

	end_timewhile :
	;Fill The Time ---------------
	inc edx
	call crlf
	cmp byte ptr [edx],'@'
	je end_bigwhile 
	add esi, 10
	jmp BigWhile

	end_Bigwhile :

	;Read The File ---------------

	close_file:
	mov eax,fileHandle

	call CloseFile

quit:
ret
rankFn endp
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; sorting function 
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
BubbleSort PROC ,pArray:PTR DWORD, Count:DWORD ,CArray:DWORD 
	mov ebx, CArray
	mov ecx,Count

	dec ecx ; decrement count by 1

	L1:
	cmp ecx,0
	je end_l1
	push ecx ; save outer loop count
	mov esi,pArray ; point to first value
	mov edi , offset Temp_plyer

	L2:
	cmp ecx , 0
	je end_l2
	mov al, ( Plyer ptr [esi]).Nam[0]  
	mov ( Plyer ptr [edi]).Nam[0],al

	mov al, ( Plyer ptr [esi]).Nam[1]  
	mov ( Plyer ptr [edi]).Nam[1],al

	mov al, ( Plyer ptr [esi]).Nam[2]  
	mov ( Plyer ptr [edi]).Nam[2],al
	mov al, ( Plyer ptr [esi]).Nam[3]  
	mov ( Plyer ptr [edi]).Nam[3],al

	mov al, ( Plyer ptr [esi]).Correct_try  
	mov ( Plyer ptr [edi]).Correct_try,al
   
	mov al, ( Plyer ptr [esi]).Wrong_try  
	mov ( Plyer ptr [edi]).Wrong_try,al

	mov eax, ( Plyer ptr [esi]).PLay_time   
	mov ( Plyer ptr [edi]).PLay_time ,eax
	

	cmp ( Plyer ptr [esi+ebx]).PLay_time,eax      ; compare a pair of values

	jg L3 ; if [ESI] >= [ESI+ebx], no exchange

	mov al, ( Plyer ptr [esi+ebx]).Nam[0] 
	xchg( Plyer ptr [edi]).Nam[0],al
	mov al ,( Plyer ptr [edi]).Nam[0]
	mov ( Plyer ptr [esi]).Nam[0] , al

	mov al, ( Plyer ptr [esi+ebx]).Nam[1]  
	xchg ( Plyer ptr [edi]).Nam[1],al
	mov al ,( Plyer ptr [edi]).Nam[1]
	mov ( Plyer ptr [esi]).Nam[1] , al

	mov al, ( Plyer ptr [esi+ebx]).Nam[2]  
	xchg ( Plyer ptr [edi]).Nam[2],al
	mov al ,( Plyer ptr [edi]).Nam[2]
	mov ( Plyer ptr [esi]).Nam[2] , al

	mov al, ( Plyer ptr [esi+ebx]).Nam[3]  
	xchg ( Plyer ptr [edi]).Nam[3],al
	mov al ,( Plyer ptr [edi]).Nam[3]
	mov ( Plyer ptr [esi]).Nam[3] , al

	mov al, ( Plyer ptr [esi+ebx]).Correct_try 
	xchg ( Plyer ptr [edi]).Correct_try,al
	mov al ,( Plyer ptr [edi]).Correct_try
	mov ( Plyer ptr [esi]).Correct_try , al

	mov al, ( Plyer ptr [esi+ebx]).Wrong_try 
	xchg ( Plyer ptr [edi]).Wrong_try,al
	mov al ,( Plyer ptr [edi]).Wrong_try
	mov ( Plyer ptr [esi]).Wrong_try , al

	mov eax, ( Plyer ptr [esi+ebx]).PLay_time  ; exchange the pair
	xchg ( Plyer ptr [edi]).PLay_time,eax
	mov eax ,( Plyer ptr [edi]).PLay_time
	mov ( Plyer ptr [esi]).PLay_time , eax
	
	L3: add esi,ebx ; move both pointers forward
	
	dec ecx
	jmp L2 ; inner loop
	end_l2:
	pop ecx ; retrieve outer loop count.
	dec ecx
	
	end_l1: ; else repeat outer loop

L4: ret
BubbleSort ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; called to show ranked players based on sorting their time taken to 
; finish the game
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
rankPlayers PROC
	invoke rankFn, offset outputFile
	invoke BubbleSort ,  offset Plyers , s , sss
	call crlf
	
	mov esi , offset Plyers
	mov al ,(Plyer ptr[esi]).Nam[0]
	call writechar

	mov al ,(Plyer ptr[esi]).Nam[1]
	call writechar

	mov al ,(Plyer ptr[esi]).Nam[2]
	call writechar
 
	mov al ,(Plyer ptr[esi]).Nam[3]
	call writechar
	call crlf
ret
rankPlayers ENDP
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;ReadingFile PROC:
;Reads from file into initial_board
;Recieves file name
;Returns the board in an array
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
ReadingFile PROC file_name:ptr BYTE, arr:PTR BYTE

	; Open the file for input.
	mov edx, file_name
	call OpenInputFile
	mov fileHandle, eax				; cursor -> filehandle

	; Check for errors.
	cmp eax,INVALID_HANDLE_VALUE	; error opening file?
	jne file_ok ; no: skip and close if has problem
	jmp quit

	file_ok:
	; Read the file into the tmp board.
	mov edx, OFFSET tmp_board
	mov ecx, BOARD_SIZE
	call ReadFromFile

	jnc check_buffer_size			; error reading?
	call WriteWindowsMsg
	jmp close_file

	check_buffer_size:
	cmp eax, BOARD_SIZE				; buffer large enough?
	jb buf_size_ok ; yes

	jmp quit						; and quit if is large

	buf_size_ok:
	mov arr[eax], 0		            ; insert null terminator

	close_file:
	mov eax, fileHandle
	call CloseFile

	mov esi, arr
	mov ecx , lengthof tmp_board
	mov edx, 0
	l2:
	mov al, tmp_board[edx]

	cmp al , SPACE
	je con
	cmp al , CARRIAGE_RETURN
	je con
	
	mov byte ptr[esi], al

	con:
	inc esi
	inc edx 
	loop l2

quit:
ret 
ReadingFile endp
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; parses the player data stored from previous game
; set trials counters to the saved values 
; set time to saved value to count on it
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
parsePlayer PROC 
	mov edx, offset prev_stat
	call OpenInputFile
	mov fileHandle, eax			

	mov edx, OFFSET tmpArr
	mov ecx, STAT_SIZE
	call ReadFromFile

	mov tmparr[eax], 0		

	mov eax, fileHandle
	call CloseFile

	; begin parsing -------

	; player Name parsing
	mov edi, offset tmpArr
	mov ecx , 10
	mov esi , offset playerNameTmp
	
	cld
	mov ecx , 10
	mov esi , offset tmpArr
	mov edi , offset playerNameTmp
	rep movsb

	;mov edx , offset playerNameTmp
	;mov ecx , 10
	;call writeString
	;call crlf	

	cld
	mov ecx , 10
	mov esi , offset playerNameTmp
	mov edi , offset currentPlayer.playerName
	rep movsb

	; player trials parsing
	mov edi, offset tmpArr
	add edi , 10
	
	mov al, [edi]
	sub al , '0'
	mov bx , 10
	mul bx
	mov bx , ax
	inc edi
	mov al, [edi]
    sub al , '0'
	add bx , ax
	
	mov currentPlayer.playerCorrect , bx
	mov trials_correct , bx 

	inc edi
	mov al, [edi]
	sub al , '0'
	mov bx , 10
	mul bx
	mov bx, ax
	inc edi
	mov al, [edi]
    sub al , '0'
	add bx , ax
	mov currentPlayer.playerWrong , bx
	mov trials_wrong , bx
	
	; player time parsing 

	inc edi
	mov ecx , 5
	mov esi , offset playerTimeTmp
	read1:
		mov al , [edi]
		;call writechar
		mov [esi] , al
		inc esi 
		inc edi 
	loop read1
	call crlf 

	mov edi , offset playerTimeTmp
	; store int ans in numConv 
	mov ebx , 10000
	mov ecx , 5
	output:
		mov dl , [edi]
		sub dl , '0'
		movzx eax , dl
		push ebx
		mul ebx
		add numConv , eax
		inc edi
		pop ebx
		mov eax , ebx
		mov ebx , 10
		div ebx
		mov ebx , eax
	loop output

	mov ebx , numConv
	mov currentPlayer.playerTime , ebx
	mov start_time , bx
	
ret
parsePlayer ENDP
;//////////////////////////////////////////////////////////////////////
; loads saved previous game boards
;//////////////////////////////////////////////////////////////////////
getBoards PROC, file_name:ptr BYTE, arr:PTR BYTE

	; Open the file for input.
	mov edx, file_name
	mov ecx , lengthof file_name
	call OpenInputFile
	mov fileHandle, eax				; cursor -> filehandle

	; Check for errors.
	cmp eax, INVALID_HANDLE_VALUE	; error opening file?
	jne file_ok ; no: skip and close if has problem
	jmp quit

	file_ok:
	; Read the file into the tmp board.
	mov edx, arr
	mov ecx, BOARD_SIZE
	call ReadFromFile

	jnc check_buffer_size			; error reading?
	call WriteWindowsMsg
	jmp close_file

	check_buffer_size:
	cmp eax, BOARD_SIZE				; buffer large enough?
	jb buf_size_ok ; yes

	jmp quit						; and quit if is large

	buf_size_ok:
	mov arr[eax], 0		            ; insert null terminator

	close_file:
	mov eax, fileHandle
	call CloseFile

	quit:
ret
getBoards ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; checks if the input indices are within range or not
; return in bl, 0 -> valid , 1 -> invalid
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
check_indices PROC row:byte , col:byte
	movzx eax , row
	cmp eax , 0 ; eax >= 0
	jnae invalid
	cmp eax , 9 ; eax <= 9
	jnbe invalid
	mov bl , 0
	;jmp checkCol ; incase row valid,check col
	movzx eax , col
	checkNum:
	cmp eax , 0 ; eax >= 0
	jnae invalid
	cmp eax , 9 ; eax <= 9
	jnbe invalid
	mov bl , 0
	jmp last

	invalid:
	mov bl , 1
	
	last:
ret
check_indices ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; check if the input index is valid for editing
; return bool answer in bl, 0 -> valid , 1 -> invalid
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
check_valid PROC index:byte
	mov edx , offset init_board
    add dl , indx
	mov bl , [edx]
	cmp bl , '0'
	je valid
	mov bl , '1'
	valid:
	ret
check_valid ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; compares the given value with correct solution
; isCorrect -> boolean value for answer correcteness (char)
;           -> 0 -> correct , 1 -> wrong , 2 -> invalid
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
cmp_value PROC row:byte , col:byte , val:byte  ;, isCorrect:byte
   INVOKE check_indices, row , col
   cmp bl , 0
   jne invalid
   
   ; indx -> (row*width) + col + spaces & spaces -> row * 2
   movzx eax , row
   mov ecx , 2
   mul ecx
   mov row_space , al

   movzx eax , row
   movzx ecx , ROW_SIZE
   mul ecx
   mov indx , al
   mov bl , col
   add indx , bl
   mov bl , row_space
   add indx , bl
   ;add indx , 4   

   ; check if index is valid
   mov ebx , 0
   invoke check_valid , indx
   cmp bl , '0'
   jne invalid
   
   mov edx , offset ans_board
   movzx ebx , indx
   add edx , ebx
   mov ebx , 0
   mov bl , [edx] ; to cmp with
   
   add val , '0'
   cmp bl , val
   je correct
   ;inc trials_wrong
   jmp wrong

   correct:
	   mov al , 0
	   mov isCorrect , al
	   inc trials_correct
	   dec steps_count
	   mov edx , offset user_board
	   add dl , indx
	   mov al , val
	   mov [edx] , al
	   jmp theEnd

   wrong:
	   mov al , 1
	   mov isCorrect , al
	   inc trials_wrong
	   jmp theEnd

   invalid:
       mov al , 1
	   mov isCorrect , al
	   jmp TheEnd
	   
   last:
	   mov al , 0
	   add isCorrect , 0
   theEnd:
ret
cmp_value ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; for console dislplay use
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
showSomething PROC somethin: ptr byte
	mov edx , somethin
	mov ecx , lengthof somethin
	call writestring
ret
showSomething ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; for console user, displayes the board matrix
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
showBoard PROC board: ptr byte
	mov esi , board
	invoke showSomething, offset sep_h
	call crlf
	mov ecx , 9
	outer:
	    mov ebx , ecx
		push ebx
		mov ecx , 9
		inner:
		    push ecx
			invoke showSomething, offset sep_v
	        pop ecx
			mov al, [esi]
	        call writechar
			mov al , ' '
	        call writechar
			inc esi
		loop inner
		invoke showSomething, offset sep_v
		call crlf
		add esi , 2 ; for extra spaces
		invoke showSomething, offset sep_h
	    call crlf
		pop ebx
		mov ecx , ebx
	loop outer
ret
showBoard ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; params: level -> the chosen level, user input
; loads a random value board from that level
; loads boards to start the game
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
pick_diff PROC level:byte  ; , barr:PTR BYTE
    mov dl , level
	add dl , '0'
    mov boardFile[18] , dl
	mov boardAnsFile[18] , dl

	; Random board
	; generates a random number between 0-3
	INVOKE getTickCount
	mov dx , 0
	xor ax , cx
	mov cx , 3
	div cx       ; dx contains the remainder of the division - from 0 to 3
	add dl , 1
	add dl , '0'  ; to ascii from '0' to '9'

	mov boardFile[20]    , dl
	mov boardAnsFile[20] , dl

	invoke ReadingFile , addr boardAnsFile , offset ans_board
	invoke ReadingFile , addr boardFile    , offset init_board
	invoke ReadingFile , addr boardFile    , offset user_board
ret
pick_diff endp
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
; for c# gui, getter for trials_correct
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
get_correct PROC Num:WORD
	mov ax , trials_correct
	mov Num, ax
get_correct ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; for c# gui, getter for trials_wrong
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
get_wrong PROC Num:WORD
	mov ax , trials_wrong
	mov Num, ax
get_wrong ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; starts timer at start of game
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
start_Timer PROC
	invoke getTickCount  ; time -> eax
	mov start_time , ax 
start_Timer ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; calculates the taken time in game
; called at end of game
; stores in take_time variable 
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
end_Timer PROC  ; ,time:dword
	invoke getTickCount
	sub ax , start_time
	mov time_taken , ax 
end_Timer ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; calculates the number of steps left for the user to win
; counts the number of zeros in user_board (unsolved cells)
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
steps_cnt PROC
	mov esi , offset user_board
	mov ecx, lengthof user_board
	steps:
	    mov bl , '0'
		cmp [esi] , bl
		jne next
		inc steps_count
		next:
		inc esi
	loop steps
ret
steps_cnt ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; stores currect game in a file
; PARAMS:
; board -> offset of board to store
; file -> file path
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
saveBoard PROC, board:dword , file:ptr byte
	; Create a new text file
	mov edx, file         
	call CreateOutputFile
	mov fileHandle, eax

    mov edx,  board
	mov ecx, BOARD_SIZE	 
    storeDigit:
	   mov eax, fileHandle
	   mov ebx , edx     ; store currect digit address
	   
	   push ecx		     
	   mov ecx, 1
	   call WriteToFile
	   pop ecx

	   mov edx , ebx     
	   inc edx           ;staging for writing next char
   loop storeDigit
   quit:
   ret
saveBoard ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; stores time in string array (reversed)
; return offset in edx
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
storeTime PROC
	mov esi  , offset time_taken_arr
	mov ax   , time_taken
	mov ecx  , 5
	;mov ebx , 10
	timeLop:
		mov edx , 0
		mov bx  , 10  
		div bx  ; rem - > dx , q -> ax
		mov bx  , ax
		add dx  , '0'
		mov [esi] , dl
		inc esi
	loop timeLop
	;mov edx , offset time_taken_arr
	;mov ecx , 5
	;call writestring
ret
storeTime ENDP
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; file format: 10 -> name, 2 -> correct, 2 -> wrong , 5 -> time (reversed)
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
savePlayer PROC, player_name_param:dword, file:ptr byte
	mov edx, file         
	call CreateOutputFile
	mov fileHandle, eax
	;----------- storin name
    mov edx, offset player_name
	mov ecx, lengthof player_name
	call writetofile
	; ----------- storin trials
	mov edx , offset stat
	;mov al , trials_correct 
	cbw
	mov [edx] , ax
	inc edx

	mov eax , 0
	;mov al , trials_wrong
	cbw
	mov [edx] , ax
	
	mov esi , offset stat
	mov ecx , lengthof stat
	lop:
       OR byte PTR [esi], 00110000b 
	   inc esi
    Loop lop

    ;storeStat:
    mov edx, offset stat
	mov eax, fileHandle
	mov ebx , edx    

	mov ecx, 2
	call WriteToFile
	; ----------- strorin time
	call storeTime ;ret offset time_taken_arr -> edx
	mov ecx, 6
    storeTimeArr:
	   mov eax, fileHandle
	   mov ebx , edx     ; store currect digit address
	   
	   push ecx		     
	   mov ecx, 1
	   call WriteToFile
	   pop ecx

	   mov edx , ebx     
	   inc edx           
   loop storeTimeArr

   quit:
   ret
savePlayer ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; used in savePlayer status, send either correct or wrong trials num
; parses and convert to string for file storage
; trials type -> word
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
parseTrials PROC, trialsVal:word
	mov ax  , trialsVal
	mov edx , 0
	mov bx  , 10
	div bx                  
	add dl  , '0'
	mov [edi +1] , dl
	add al  , '0'
	mov [edi] , al
ret
parseTrials  ENDP
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; convert the sent trials (correct/wrong) into string for file storage
; used in savePlayer2 proc
; trials type -> dword
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
parseTrialsD PROC, trialsVal:Dword
	mov eax , trialsVal
	mov edx , 0
	mov ebx , 10
	div ebx                  
	add dl  , '0'
	mov [edi +1] , dl
	add al  , '0'
	mov [edi] , al
ret
parseTrialsD  ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; file format(fixed length):
; 10 -> name, 2 -> correct, 2 -> wrong , 5 -> time (reversed)
; savePlayer2 is alteration to savePlayer proc , managing datatypes
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
savePlayer2 PROC, file:ptr byte
	mov edx, file         
	call CreateOutputFile
	mov fileHandle, eax
	;----------- storin name
    ;mov edx, offset player_name
	;mov ecx, lengthof player_name 
	;call writetofile
	
	mov edx , offset player_name
	mov ecx, lengthof player_name
    storeNameArr:
	   mov eax, fileHandle
	   mov ebx , edx     ; store currect digit address

	   push ecx		     
	   mov ecx, 1
	   call WriteToFile
	   pop ecx
	   jmp next

	   insertEmpty:
	   push ecx		     
	   mov ecx, 1
	   mov al , ' '
	   movzx edx , al
	   call WriteToFile
	   pop ecx
	   jmp next

	   next:
	   mov edx , ebx     
	   inc edx           
   loop storeNameArr

	; ----------- storin trials
	mov edi , offset stat
	invoke parseTrialsD, trials_correct
	add edi , 2
	invoke parseTrialsD, trials_wrong

	;mov edx, offset stat
	;mov ecx , 2
	;call writestring

	;storeStat:
    mov edx, offset stat
	mov eax, fileHandle
	mov ecx , 4
	call WriteToFile

	; ----------- strorin time
	;call storeTime ;ret offset time_taken_arr -> edx
	;mov edx , offset time_taken_arr 
	;mov ecx, 5
	;call writeToFile
	
	call storeTime ;ret offset time_taken_arr -> edx
	mov edx , offset time_taken_arr
	mov ecx, 5
    storeTimeArr:
	   mov eax, fileHandle
	   mov ebx , edx        ; store currect digit address
	   
	   push ecx		     
	   mov ecx, 1
	   call WriteToFile
	   pop ecx

	   mov edx , ebx     
	   inc edx           
   loop storeTimeArr

   quit:
   ret
savePlayer2 ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; stores game and player data after exit option 
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
storelevel proc
	invoke saveboard , offset user_board  , addr prev_user
	invoke saveboard , offset ans_board   , addr prev_ans
	invoke saveboard , offset init_board  , addr prev_init
	;invoke savePlayer, offset player_name , addr  prev_stat
	invoke savePlayer2, addr  prev_stat
ret
storelevel endp
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; called in get previous game option after parsing player data 
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
assignValues PROC
	cld
	mov esi , offset currentPlayer.playerName
	mov edi , offset player_name
	mov ecx , 10
	rep movsb

	mov ax , currentPlayer.playerCorrect
	call writeDec
	call crlf
	
	;mov trials_correct , ebx

	mov eax , 0
	mov bx , currentPlayer.playerWrong
	mov trials_wrong , bx
	mov ax , trials_wrong
	call writeDec
	call crlf
	
	mov ebx , currentPlayer.playerTime
	mov start_time , bx

ret
assignValues ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; loads previous game
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
getPrevious PROC
	invoke getBoards , offset prev_user , offset user_board   
	invoke getBoards , offset prev_ans  , offset ans_board 
	invoke getBoards , offset prev_init , offset init_board  
	call crlf

	call parsePlayer
	; call assignValues 

	; displayes read values for testing 
	;mov ax , trials_correct
	;call writeDec
	;call crlf
	;mov ax , trials_wrong
	;call writeDec
	;call crlf
	;mov edx , offset player_name
	;mov ecx , 10
	;call writeString
ret
getPrevious ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; for console display use
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
showBar PROC
	mov edx, offset bar
	mov ecx , lengthof bar
	call writeString
	call crlf
ret
showBar ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; for console display use
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
showGameLabel PROC
	mov edx, offset gameLabel
	mov ecx , lengthof gameLabel
	call writeString
	call crlf
ret
showGameLabel ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; shows loading previous game or starting a new one options
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
showMainMenu PROC
	call showGameLabel
	mov edx, offset bar
	mov ecx , lengthof bar
	call writeString
	call crlf
	mov edx, offset loadPrev
	mov ecx , lengthof loadPrev
	call writeString
	call crlf
	call showBar
	mov edx, offset newGame
	mov ecx , lengthof newGame
	call writeString
	call crlf
	call showBar
	ret
showMainMenu ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; for console use, shows menu of difficulty options (easy,medium,hard)
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
showDiff PROC
	call showGameLabel
	call showBar
	mov edx , offset diff1
	mov ecx , lengthof diff1
	call writeString
	call crlf
	call showBar
	mov edx , offset diff2
	mov ecx , lengthof diff2
	call writeString
	call crlf
	call showBar
	mov edx , offset diff3
	mov ecx , lengthof diff3
	call writeString
	call crlf
	call showBar
ret
showDiff ENDP
;//////////////////////////////////////////////////////////////////
;reset_game proc:
;Resets everything to its initial values
;//////////////////////////////////////////////////////////////////
reset_game PROC

	mov trials_wrong   , 0
	mov trials_correct , 0
	mov steps_count    , 0

	call start_Timer

	mov esi , offset init_board
	mov ecx , lengthof init_board
	mov edx , 0

	fill_user_board:

	mov al, byte ptr[esi]
	mov user_board[edx], al

	fill:
	inc esi
	inc edx
	loop fill_user_board

ret
reset_game ENDP
;//////////////////////////////////////////////////////////////////
; check_game_ended proc:
; compares between # correct trials and # zeros in intital board
; Then uses the result to check whether the game ended or not
; Returns: a number in eax to show the case (1 -> ended, 0 -> not yet)
;//////////////////////////////////////////////////////////////////
check_game_ended PROC
	mov dx, trials_correct
	cmp dx, steps_count

	je ended

	mov eax, 0
	jmp done_check

	ended:
	mov eax, 1
done_check:
ret
check_game_ended ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; when user wants to show the solution
; compares initial board with user's and displayes the
; numbers missed in blue 
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
showClrBoard PROC 
	mov esi , offset init_board
	mov edi , offset user_board
	invoke showSomething, offset sep_h
	call crlf
	mov ecx , 9
	outer:
	    push ecx
		mov ecx , 9
		inner:
		    push ecx
			invoke showSomething, offset sep_v
	        pop ecx
			
			mov bl , [edi] ; user
			mov dl , [esi] ; init
			cmp dl , '0'
			jne writeWhite
			cmp dl , bl
			jne writeWhite
			
			mov eax, 3
		    call setTextColor

			writeWhite:
			mov al, [edi]
	        call writechar
			mov al , ' '
	        call writechar
			
			inc esi
			inc edi

			mov eax , 15
			call setTextColor
			
		loop inner
		invoke showSomething, offset sep_v
		call crlf
		add esi , 2 ; for extra spaces
		add edi , 2
		invoke showSomething, offset sep_h
	    call crlf
		pop ecx
	loop outer

ret
showClrBoard ENDP
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
main PROC
    ; rankPlayers sort winning players and output the fastest one 
	; to solve the sodoku, it uses bubble sort technique
	; call rankPlayers 

	call showMainMenu
	call readint
	cmp eax , 1
	jne newGameMode
		invoke getPrevious
		call clrscr
		mWrite "Welcome back "
		invoke showSomething, offset currentPlayer.playerName
		mWrite "!"
		call crlf
		jmp begin
	newGameMode:
		call clrscr
		call showDiff
		call readint
		invoke pick_diff, al
		invoke start_timer
		
		begin:
		;call clrscr
		invoke showBoard, offset init_board
		gameLoop:
			
			invoke showSomething, offset showSolvedTxt
			call crlf
			invoke showSomething, offset resetBoardTxt
			call crlf
			invoke showSomething, offset enterValTxt
			call crlf
			invoke showSomething, offset exitTxt
			call crlf
			
			call readint
			cmp eax , 1
			je solve
			cmp eax , 2
			je reset
			cmp eax , 3
			je input
			cmp eax , 4
			je exitGame

			solve:
				call clrscr 
				call showClrBoard
				jmp exitGame
			reset:
				call clrscr
				invoke showBoard , offset init_board
				jmp gameloop
			input:
				call readint
				mov rr , al
				call readint
				mov cc , al
				call readint
				mov vv , al
				
				INVOKE cmp_value, rr , cc , vv
				
				; in case correct, clrscr
				call clrscr
			    invoke showBoard, offset user_board
				mov al , isCorrect
				cmp al , 0
				jne wasWrong

				MOV EAX,2    ;green colour
				CALL SetTextColor
				mov edx , offset correct_msg
				mov ecx , lengthof correct_msg
				call writeString
				;mWrite "Correct"
				jmp inAnyway
				
				wasWrong:
				MOV EAX, 4   ;red colour 4
				CALL SetTextColor
				mov edx , offset wrong_msg
				mov ecx , lengthof wrong_msg
				call writeString
				;mWrite "Wrong"
				
				inAnyway:
				call crlf
				MOV EAX, 15    ;txt back to white
				CALL SetTextColor
				;call forTest

				jmp gameLoop

		exitGame:
			; save board & status
			invoke end_timer
			invoke showSomething, offset enterName
			mov edx , offset player_name
			mov ecx , lengthof player_name
			call readString

			mWrite "correct trials: "
			mov ax , trials_correct
			call writeDec
			call crlf
			mWrite "Incorrect trials: "
			mov ax , trials_wrong
			call writeDec
			call crlf
			mWrite "Taken Time: "
			mov ax , time_taken
			call writeDec
			call crlf
			
			mov nameSize , eax
			call storelevel

exit
main ENDP
END main