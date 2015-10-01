# MSR [Test Version]

Ready for having access to the whole look of the CPU 
    by querying Model Specific Register.



The current version is:

User versus Driver data identification.

User, give MSR data in the form of 4 bytes unsigned integer, and dump the buffer when return from DriverIoControl

Driver, receive the MSR address and, fill 0x22 ~ 0x29 into user buffer for user's later read.


This test version is finished ar 09:31 PM, Oct 01, 2015, by Mighten Dai.




And the problem's complete resolution is supposed to be put up later.
       Because the College Entrance Exam in China, and I will goto college in fall of 2016.
BTW, I am sorry for any form of not convenience caused by me...