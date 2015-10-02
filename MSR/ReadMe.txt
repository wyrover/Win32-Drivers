# MSR [Test Version]

Ready for having access to the whole look of the CPU 
    by querying Model Specific Register.



------------------------------------------------------------
@ Version 1.0 

User versus Driver data identification.

User, give MSR data in the form of 4 bytes unsigned integer, and dump the buffer when return from DriverIoControl

Driver, receive the MSR address and, fill 0x22 ~ 0x29 into user buffer for user's later read.


This test version is finished at 09:31 PM, Oct 01, 2015, by Mighten Dai.

See history on GitHub for more detailed information.

------------------------------------------------------------
@ Version 2.0 

Compared with the preceding version,
     this commitment is very close to the final distribution

And the program hopefully cannot be published until the end of 2015.
           I have to finish my homework...

What's more, This test version is finished at 01:43 PM, Oct 02, 2015, by Mighten Dai.
