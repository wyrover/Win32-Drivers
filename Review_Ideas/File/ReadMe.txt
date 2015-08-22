# File

Sometimes it is necessary to store some kernel message into a *.log file.

Remember a truth that, when you want to make a path global,
    just simply make it a wchar_t array rather than macro.
	
	I have crashed my PC many times by using macro,
 But I somehow fixed this bug by using wchar_t array.
 
 Maybe I mark the string at the location of \
         code_seg("INIT"),
  Which means that it can be discarded after initialization.
  
  
  Maybe other reasons, various reasons, I mark it an uncertain item.
      It is supposed to sovle later.