; Programming Assignmnet #5 for CSCI 2525 - Assembly Language & Computer Organization
; Written by Justin Shapiro

TITLE EncryptIt.asm
; Best viewed in Notepad++

INCLUDE Irvine32.inc    ; Needed for the following procedures:
						;   - ReadString
						;   - WriteString
						;   - ReadInt
						;   - ReadChar
						;   - WriteChar
						;   - SetTextColor
						;   - Clrscr
						;   - Crlf

.data
	
	; constant for max string size (140 characters not including null terminator)
	maxChar = 141
	
	; encryption/decryption key array
	key              BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6
	
	; user-defined string and default string
	userString       BYTE maxChar DUP(0)
	defaultString    BYTE "Encryption using a rotation key", 0
	
	; counter for program to know when to repeat the key for strings greater than the key length
	strLengthCounter BYTE 0
	
	; if the user selects N to decypting the default string, it will remain encrypted until the user chooses to decrypt it
	decryptCheck     BYTE 0

	; text prompts
	startMenuPrompt  BYTE "What do you want to do?: ", 0
	startMenuOption1 BYTE "1. Run the program (EncryptIt.asm)", 0
	startMenuOption2 BYTE "2. Quit", 0
	programWelcome   BYTE "Welcome to the Cryptokey generator 5000!",0
	mainMenuPrompt   BYTE "Please choose from the following options to encrypt your message: ", 0
	mainMenuOption1	 BYTE "1. Enter a string", 0
	mainMenuOption2  BYTE "2. Use the default string", 0
	mainMenuOption3  BYTE "3. Quit", 0
	userEnterPrompt  BYTE "Selection: ", 0
	badInputPrompt   BYTE "Invalid selection. Please try again.", 0
	userStringPrompt BYTE "Enter a string (140 characters or less): ", 0
	readBackString1  BYTE "Your encrypted string is: ", 0
	readBackString0  BYTE "Default string is already encrypted, choose Y below to decrypt: ", 0
	readBackString2  BYTE "Your decrypted string is: ", 0
	subMenuPrompt    BYTE "DECRYPT STRING? (Y/N): ", 0
	
.code

	;=======================================================================;
	;--------------------------- MAIN PROCEDURE ----------------------------;
	; Function: drives the program, lets the user to select to run the      ;
	;		    program, then lets the user select to use a default or      ;
	;			custom string.												;
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
			
			; 1. Run the program (EncryptIt.asm)
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
				je EncryptItStart
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
					
		EncryptItStart:									; start of EncryptIt
			call Clrscr
			
			; Welcome to the Cryptokey generator 5000!
			mov edx, OFFSET programWelcome				; user is displayed a welcome message once
			call WriteString
			call Crlf
			call Crlf
			
		MainMenu:										; main menu for EncryptIt
			; Please choose from the following options to encrypt your message: 
			mov edx, OFFSET mainMenuPrompt
			call WriteString
			call Crlf
			
			; 1. Enter a string
			mov edx, OFFSET mainMenuOption1
			call WriteString
			call Crlf
			
			; 2. Use the default string
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
			je userStringJmp
		cmp eax, 2
			je defaultStringJmp
		cmp eax, 3
			je quit
		jmp BadInput									; error checking user input
			BadInput:
				call Crlf
				mov edx, OFFSET badInputPrompt
				call WriteString
				
				call Crlf
				call Crlf
				call Crlf
				
				jmp MainMenu							; if user enters in an invalid value, they will see the menu again
		
		; Option 1: Enter your own string
		userStringJmp:
			call GetUserString							; call GetUserString to retrieve data
			jmp MainMenu
		
		; Option 2: Use the default string
		defaultStringJmp:
			call UseDefaultString						; call UseDefaultString to encrypt the default string
			jmp MainMenu
	
	quit:
		call Clrscr										; clear terminal window
		jmp StartMenu									; go back to StartMenu
	quitReal:		
		exit											; only accessable via StartMenu option 2
	main ENDP
	
	
	;=======================================================================;
	;------------------------ GetUserString PROCEDURE ----------------------;
	; Function: retrieves a string from the user and calls Encrypt. Lets    ;	
	;           the user decide whether or not they want to decrypt it      ;
	; Requires: call by main PROC    										;
	; Recieves: nothing														;
	; Returns:  nothing that will later get used, but string array will be  ;
	;			filled nevertheless											;
	;=======================================================================;
	GetUserString PROC
	
		call Crlf
		
		; Enter a string (140 characters or less):
		mov edx, OFFSET userStringPrompt
		call WriteString
		call Crlf
		call Crlf
		
		mov edx, OFFSET userString						; use ReadString in order to obain a string from user
		mov ecx, maxChar
		call ReadString
		mov ecx, eax									; store string length into ecx for later passing to Encrypt
		
		push ecx
		call Crlf
		
		call Encrypt									; pass length of string in ecx and offset of string array in edx to Encrypt
		
		call Crlf
		call Crlf
		
		EncryptOrDecrypt:								; Create label system that lets the user choose to decrypt the string
			; DECRYPT STRING? (Y/N):
			mov edx, OFFSET subMenuPrompt				; print sub-menu that prompts the user to choose Y or N to decrypt
			call WriteString
			
			call ReadChar
			pop ecx ; had to happen sometime
			
			call Crlf
			call Crlf
			call Crlf
			
			; direct user to their specified location if their input is valid
			cmp al, 'Y'
				je decryptJmp
			cmp al, 'y'
				je decryptJmp
			cmp al, 'N'
				je exitProc
			cmp al, 'n'
				je exitProc
			jmp BadInput								; error checking user input
		BadInput:
			call Crlf
			
			; Invalid selection. Please try again.
			mov edx, OFFSET badInputPrompt
			call WriteString
				
			call Crlf
			call Crlf
			jmp EncryptOrDecrypt						; if user enters in an invalid value, they will see the sub-menu again
		
		decryptJmp:
			mov edx, OFFSET userString					; pass the offset of the user string in edx to Decrypt 
			call Decrypt
			
	exitProc:
		call Crlf
		call Crlf
		call Crlf
		call Crlf
		ret
	GetUserString ENDP
	
	
	;=======================================================================;
	;------------------------ UseDefaultString PROCEDURE -------------------;
	; Function: passes a default string to Encrypt and lets the user choose ;
	;           whether or not to decrypt it                                ;
	; Requires: call by main PROC    										;
	; Recieves: nothing														;
	; Returns:  nothing									                 	;
	;=======================================================================;
	UseDefaultString PROC
	
		call Crlf
	
		mov edx, OFFSET defaultString					; store offset of defaultString in edx to pass to Encrypt
		mov ecx, LENGTHOF defaultString					; store length of defaultStrig in ecx to pass to Encrypt
		cmp decryptCheck, 0								; check to see if the default string is not already encrypted
			jne BypassEncrypt
		call Encrypt									; if the default string is not already encrypted, encrypt it
		
		call Crlf
		call Crlf
		jmp EncryptOrDecrypt
		
		BypassEncrypt:									; if default string is already encryted, user is told accordingly
			; Default string is already encrypted, choose Y below to decrypt: 
			mov edx, OFFSET readBackString0
			call WriteString
			call Crlf
			call Crlf
		
		EncryptOrDecrypt:
			; DECRYPT STRING? (Y/N): 
			mov edx, OFFSET subMenuPrompt				; ask user if they want to decrypt the default string
			call WriteString
			
			call ReadChar
			
			call Crlf
			call Crlf
			call Crlf
			
			; direct user to their specified location if their input is valid
			cmp al, 'Y'
				je decryptJmp
			cmp al, 'y'
				je decryptJmp
			cmp al, 'N'
				je exitProc
			cmp al, 'n'
				je exitProc
			jmp BadInput								; error checking user input
		BadInput:
			call Crlf
			
			; Invalid selection. Please try again.
			mov edx, OFFSET badInputPrompt
			call WriteString
				
			call Crlf
			call Crlf
			jmp EncryptOrDecrypt						; if user enters in an invalid value, they will see the sub-menu again
		
		decryptJmp:
			mov decryptCheck, 0							; set string as decrypted
			mov ecx, LENGTHOF defaultString 			; pass the length of the default string in ecx to Decrypt 
			mov edx, OFFSET defaultString				; pass the offset of the default string in edx to Decrypt 
			call Decrypt
			jmp SkipSetDecryptCheck
			
	exitProc:
		mov decryptCheck, 1								; set string as not encrypted if user chose not to decrypt it
		SkipSetDecryptCheck:
			call Crlf
			call Crlf
			call Crlf
			call Crlf
	ret
	UseDefaultString ENDP
	
	
	;=======================================================================;
	;--------------------------- Encrypt PROCEDURE -------------------------;
	; Function: encrypts either the default or user-entered string and      ;
	;			prints it to the terminal simultaneously                    ;
	; Requires: call by UseDefaultString or GetUserString                   ;
	; Recieves: length of string in ecx and offset of string array in edx   ;
	; Returns:  encrypted string array   				                 	;
	;=======================================================================;
	Encrypt PROC
		
		mov ebx, 0
		
		push edx
			; Your encrypted string is: 
			mov edx, OFFSET readBackString1
			call WriteString
		pop edx
		
		call Crlf
		
		mov eax, red									; make the encrypted string show up red on the terminal
		call SetTextColor
		
		mov strLengthCounter, 0							; set the iteration counter to zero prior to the encryption loop
		mov bh, LENGTHOF key							; put the length of the encryption key in bh
		mov esi, OFFSET key								; put the offset of the encryption key in esi
		L1:												; START STRING ENCRYPTION
			push ecx
				mov cl, [esi]							; move the current byte of the encryption key to cl
				mov bl, [edx]						    ; move the first character of the string to bl
				ror bl, cl								; encrypt the single character using a right-rotation
				mov [edx], bl							; move the encrypted character back into the string array, replacing the original character
			pop ecx
			mov al, [edx]								; move the encrypted character to al to print to the terminal
			call WriteChar
			inc edx
			inc strLengthCounter					
			cmp strLengthCounter, bh					
				jae RegenerateKey						; if the number of iterations equals the length of the encryption key, jump to reset it	
			inc esi
				jmp loopEnd
			RegenerateKey:
				mov esi, OFFSET key						; pass the beginning of the encryption key to esi so it can repeat
				mov strLengthCounter, 0					; set the iteration counter back to zero to keep checking if the key string has been exceeded
		loopEnd:
		loop L1											; END STRING ENCRYPTION
		
		mov eax, lightGray								; set text color back to default
		call SetTextColor
		
	ret
	Encrypt ENDP
	
	
	;=======================================================================;
	;--------------------------- Decrypt PROCEDURE -------------------------;
	; Function: decrypts either the default or user-entered string and      ;
	;			prints it to the terminal simultaneously                    ;
	; Requires: call by UseDefaultString or GetUserString                   ;
	; Recieves: length of string in ecx and offset of string array in edx   ;
	; Returns:  decrypted string array   				                 	;
	;=======================================================================;
	Decrypt PROC
		
		mov ebx, 0
		
		push edx
			; Your decrypted string is: 
			mov edx, OFFSET readBackString2
			call WriteString
		pop edx
		
		call Crlf
		
		mov eax, green									; make the decrypted string show up green on the terminal
		call SetTextColor
		
		mov strLengthCounter, 0							; set the iteration counter to zero prior to the decryption loop
		mov bh, LENGTHOF key							; put the length of the decryption key in bh
		mov esi, OFFSET key								; put the offset of the decryption key in esi
		L1:												; START STRING DECRYPTION
			push ecx
				mov cl, [esi]							; move the current byte of the encryption key to cl
				mov bl, [edx]						    ; move the first character of the string to bl
				rol bl, cl								; decrypt the single character using a left-rotation
				mov [edx], bl							; move the decrypted character back into the string array, replacing the encrypted character
			pop ecx
			mov al, [edx]								; move the decrypted character to al to print to the terminal
			call WriteChar
			inc edx
			inc strLengthCounter					
			cmp strLengthCounter, bh					
				jae RegenerateKey						; if the number of iterations equals the length of the decryption key, jump to reset it	
			inc esi
				jmp loopEnd
			RegenerateKey:
				mov esi, OFFSET key						; pass the beginning of the decryption key to esi so it can repeat
				mov strLengthCounter, 0					; set the iteration counter back to zero to keep checking if the key string has been exceeded
		loopEnd:
		loop L1											; END STRING DECRYPTION
		
		mov eax, lightGray								; set text color back to default
		call SetTextColor
		
		call Crlf
		call Crlf
		
		call WaitMsg
	ret
	Decrypt ENDP


END main