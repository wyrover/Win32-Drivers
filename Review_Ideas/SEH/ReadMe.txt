# SEH, Structed Exception Handler,

  corresponding to the issue I discovered in doing Intel 32-bit language's CPlusPlus test, at the location of :
     /Intel-32-bit-PM-Assembly-language/Interrupts_Exceptions/External_experiments/divided_by_ZERO.cpp



The special mechanism implemented by Microsoft OS rather the compiler itself as described in some Visual Studio's Documentation.
Therefore, you can even use the SEH in C programming language or Kernel-Mode Driver Assembly Language(Portrayed in Four-F's codes)


In this section, mainly the structure of arranging codes behaves like this, 

__try{
    ....
}
__except( ....)
{
    ....
}



__try{
    ....
}
__finally
{
    ....
}


And I have passed the
1>
__try{}__except( EXCEPTION_EXECUTE_HANDLER ){}

2> 
__try{}__finally{}

But  I failed in the implementation of the following, for lacking of proper example dislike odd thing, for instance, even you've installed the divide-by-zero Handler,
    you can also obtain the result of BSOD( Terminology, Blue Screen Of Death for short)

I have enough of implementating:
__try{}__except( EXCEPTION_CONTINUE_EXECUTION){}

Because I am a very beginner of Windows Kernel Mode Driver Developer.

But, chances are that I will accomplish it later.