Problem 4:  EncryptIt.asm

 The user shall be presented with the option to enter a string or use the default string.  This means there will be a sub menu.  The default string is the phrase "Encryption using a rotation key"  (without the quotes.  After the user, enters the string (or selects the default string option), encrypt the string.  Then ask the user if they want to decrypt the string.  If the user enters Y or y, then call a decrypt procedure and wait for a keystroke, then present the main menu.  If the user enters N or n, present the main menu.

Any user entered string cannot be longer than 140 characters. If it is truncate the string to 140 characters, not including the null.

Problem 6:  GCD.asm

Sub-Menu:  Ask the user if they want to 1) enter two numbers or 2) find the GCD of  two numbers generated randomly between -1250 and +1250

 

 After the GCD is calculated (either option 1 or option 2) display the results in the following format. 

            The GCD of -4 and -12 is 4. 

Once the user is ready to continue, display the main menu again.  User entered numbers will not exceed the DWORD signed values.  if the user exceeds this value an error message should appear.

 

Basic Error Checking:  User should only be able to enter values in the designated ranges of the menus.  Otherwise an error message should appear.  Example:  That is not a valid option, please try again.