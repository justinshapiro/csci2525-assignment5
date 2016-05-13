; Programming Assignmnet #5 for CSCI 2525 - Assembly Language & Computer Organization
; Written by Justin Shapiro

TITLE GCD.asm
; Best viewed in Notepad++

INCLUDE Irvine32.inc    ; Needed for the following procedures:
						;   - ReadString
						;   - WriteString
						;   - ReadInt
						;   - ReadChar
						;   - WriteChar
						;   - Randomize
						;   - RandomRange
						;   - SetTextColor
						;   - Clrscr
						;   - Crlf

.data

	num1 			 DWORD 0
	num2			 DWORD 0
	GCD				 DWORD 0
	
	; text prompts
	startMenuPrompt  BYTE "What do you want to do?: ", 0
	startMenuOption1 BYTE "1. Run the program (GCD.asm)", 0
	startMenuOption2 BYTE "2. Quit", 0
	programWelcome   BYTE "Welcome to the GCD Finder 5000!",0
	mainMenuPrompt   BYTE "Please choose from the following options: ", 0
	mainMenuOption1	 BYTE "1. Find GCD of two specific numbers", 0
	mainMenuOption2  BYTE "2. Find GCD of two random number between -1250 and 1250", 0
	mainMenuOption3  BYTE "3. Quit", 0
	userEnterPrompt  BYTE "Selection: ", 0
	badInputPrompt   BYTE "Invalid selection. Please try again.", 0
	userNum1Prompt   BYTE "Enter your first number: ", 0
	userNum2Prompt   BYTE "Enter your second number: ", 0
	resultPrompt1    BYTE "The GCD of ", 0
	resultPrompt2    BYTE " and ", 0
	resultPrompt3    BYTE " is ", 0
	overflowError    BYTE "Sorry, that number exceeds 32-bits. Please try again.", 0
	zeroError		 BYTE "Sorry, values must be non-zero. Please try again.", 0
	
.code
	
	;=======================================================================;
	;--------------------------- MAIN PROCEDURE ----------------------------;
	; Function: drives the program, lets the user to select to find the     ;
	;		    GCD of their own two numbers or two random numbers			;
	; Requires: nothing														;
	; Recieves: nothing														;
	; Returns:  nothing														;
	;=======================================================================;
	main PROC
	
		StartMenu:										; menu to select whether or not to run the program
			; What do you want to do?:
			mov edx, OFFSET startMenuPrompt
			call WriteString
			call Crlf
			
			; 1. Run the program (GCD.asm)
			mov edx, OFFSET startMenuOption1
			call WriteString
			call Crlf
			
			; 2. Quit
			mov edx, OFFSET startMenuOption2
			call WriteString
			call Crlf
			call Crlf
			
			; Selection: 
			mov edx, OFFSET userEnterPrompt
			call WriteString
		
			call ReadInt
			
			; direct user to their specified location if their input is valid
			cmp eax, 1
				je GCD_Start
			cmp eax, 2
				je quitReal
			jmp BadInput0
				BadInput0:								; error checking user input
					call Crlf
					
					; Invalid selection. Please try again.
					mov edx, OFFSET badInputPrompt
					call WriteString
					call Crlf
					call Crlf
					call Crlf
					
					jmp StartMenu						; if user enters in an invalid value, they will see the menu again
					
		GCD_Start:										; start of GCD program
			call Clrscr
			
			; Welcome to the GCD Finder 5000!
			mov edx, OFFSET programWelcome				; user is displayed a welcome message once
			call WriteString
			call Crlf
			call Crlf
			
		MainMenu:										; main menu for GCD program
			; Please choose from the following options: 
			mov edx, OFFSET mainMenuPrompt
			call WriteString
			call Crlf
			
			; 1. Find GCD of two specific numbers
			mov edx, OFFSET mainMenuOption1
			call WriteString
			call Crlf
			
			; 2. Find GCD of two random number between -1250 and 1250
			mov edx, OFFSET mainMenuOption2
			call WriteString
			call Crlf
			
			; 3. Quit
			mov edx, OFFSET mainMenuOption3				; This will bring user back to StartMenu
			call WriteString
			call Crlf
			call Crlf
			
			; Selection: 
			mov edx, OFFSET userEnterPrompt
			call WriteString
		
		call ReadInt
		
		; direct user to their specified location if their input is valid
		cmp eax, 1
			je specificGCDJmp
		cmp eax, 2
			je randomGCDJmp
		cmp eax, 3
			je quit
		jmp BadInput									; error checking user input
			BadInput:
				call Crlf
				mov edx, OFFSET badInputPrompt
				call WriteString
				
				mov ecx, 2
				L01: call Crlf
				loop L01
				
				jmp MainMenu	
				
		; Option 1: Find GCD of two specific numbers
		specificGCDJmp:
			call GetUserGCDNums						       ; call GetUserGCDNums to retrieve data
			mov ecx, 3
			L02: call Crlf
			loop L02
			jmp MainMenu
		
		; Option 2: Find GCD of two random number between -1250 and 1250
		randomGCDJmp:
			call Randomize
			call RandomGCD						       ; call RandomGCD to find GCD of two random numbers
			mov ecx, 3
			L03: call Crlf
			loop L03
			jmp MainMenu
	
	quit:
		call Clrscr										; clear terminal window
		jmp StartMenu									; go back to StartMenu
	quitReal:		
		exit											; only accessable via StartMenu option 2
	main ENDP
	
	;=======================================================================;
	;----------------------- GetUserGCDNums PROCEDURE ----------------------;
	; Function: gets the two numbers to find the GCD from the user			;
	; Requires: call by main PROC										    ;
	; Recieves: nothing														;
	; Returns:  nothing														;
	;=======================================================================;
	GetUserGCDNums PROC
		
		GetEAX:
			; Enter your first number:
			mov edx, OFFSET userNum1Prompt
			call WriteString
			
			call ReadInt
			jo OverflowErrorEAX
			jz ZeroErrorEAX
			mov num1, eax
			call Crlf
			jmp saveEAXjmp
			
			OverflowErrorEAX:
				; Sorry, that number exceeds 32-bits. Please try again.
				mov edx, OFFSET OverflowError
				call WriteString
				call Crlf
				
				mov cl, 1		; set Overflow flag back to 0
				neg cl		
				jmp GetEAX
				
			ZeroErrorEAX:
				; Sorry, values must be non-zero. Please try again.
				mov edx, OFFSET ZeroError 
				call WriteString
				call Crlf
				
				jmp GetEAX
		
		saveEAXjmp:
			mov edi, eax
		GetEBX:
			; Enter your second number: 
			mov edx, OFFSET userNum2Prompt
			call WriteString
			
			call ReadInt
			jo OverflowErrorEBX
			jz ZeroErrorEBX
			mov ebx, eax
			mov num2, ebx
			call Crlf
			jmp Get_GCD
				
			OverflowErrorEBX:
				; Sorry, that number exceeds 32-bits. Please try again.
				mov edx, OFFSET OverflowError
				call WriteString
				call Crlf

				mov cl, 1
				neg cl
				jmp GetEBX
			
			ZeroErrorEBX:
				; Sorry, values must be non-zero. Please try again.
				mov edx, OFFSET ZeroError 
				call WriteString
				call Crlf
				
				jmp GetEBX

		Get_GCD:
			mov eax, edi
			call GCDAlgorithm
		
		call WriteGCD
		
		ret
		GetUserGCDNums ENDP
	
	
	;=======================================================================;
	;------------------------- RandomGCD PROCEDURE -------------------------;
	; Function: generates two random integers between -1250 and 1250		;
	; Requires: call by main PROC										    ;
	; Recieves: nothing														;
	; Returns:  nothing														;
	;=======================================================================;
	RandomGCD PROC
		GCD1: 						
		mov eax, 1251					; generate first random integer for the first GCD number
		call RandomRange
		mov num1, eax					; store in num1
					
		mov eax, 1251					; generate second random integer for the first GCD number 
		call RandomRange
		mov num2, eax					
		neg num2						; negate it and store in num2
		
		mov eax, num1
		add eax, num2					; take the sum of the two numbers to get the first GCD number
		
		cmp eax, 0						; make sure number generated is not zero
			je GCD1
			
		mov edx, eax					; store the first GCD number in edx
		
		GCD2:
		mov eax, 1251					; generate first random integer for the second GCD number
		call RandomRange
		mov num1, eax					; store in num1
		
		mov eax, 1251					; generate second random integer for the second GCD number
		call RandomRange
		mov num2, eax
		neg num2						; negate it and store in num2
		
		mov ebx, num1
		add ebx, num2					; take the sum of the two numbers to get the first GCD number
		mov num2, ebx					; store the second GCD number in num2 and in ebx
		
		cmp ebx, 0						; make sure number generated is not zero
			je GCD1
		
		mov num1, edx					; store the first GCD number in num2 and in eax	
		mov eax, edx
		call GCDAlgorithm
		
	
		
		call WriteGCD
				
	ret
	RandomGCD ENDP
	
	;=======================================================================;
	;------------------------- RandomGCD PROCEDURE -------------------------;
	; Function: find the GCD of two numbers passed to it            		;
	; Requires: call by some function									    ;
	; Recieves: numbers	in EAX and EBX										;
	; Returns:  GCD in EAX   												;
	;=======================================================================;
	GCDAlgorithm PROC
	
		TestEAX:					; Test for negative number. If negative, negate
			cmp eax, 0
				jge TestEBX
				neg eax
		TestEBX:					; Test for negative number. If negative, negate
			cmp ebx, 0
				jge GCD_Finder
				neg ebx	
				
		GCD_Finder:
			cdq
			div ebx
			mov eax, ebx
			mov ebx, edx
			cmp ebx, 0
			je exitPROC
		jmp GCD_Finder
			
	exitPROC:
		ret
	GCDAlgorithm ENDP
	
	;=======================================================================;
	;-------------------------- WriteGCD PROCEDURE -------------------------;
	; Function: writes the GCD to the screen in the request format     		;
	; Requires: num1, num2, and EAX to contain values					    ;
	; Recieves: numbers	in EAX, num1, and num2								;
	; Returns:  nothing  											     	;
	;=======================================================================;
	WriteGCD PROC
	
		mov GCD, eax
		
		mov edx, OFFSET resultPrompt1
		call WriteString
		mov eax, num1
		call WriteInt
		mov edx, OFFSET resultPrompt2
		call WriteString
		mov eax, num2
		call WriteInt
		mov edx, OFFSET resultPrompt3
		call WriteString
		mov eax, GCD
		call WriteInt
		mov al, '.'
		call WriteChar
		call Crlf
		call Crlf
	
		call WaitMsg
	ret		
	WriteGCD ENDP
	
END main
		