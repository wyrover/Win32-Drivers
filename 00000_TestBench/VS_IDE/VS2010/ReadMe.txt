# VS2010

The TestBench

But,  something puzzle would happen:

1. The DDK installed on my Computer has not set the Environment, which entails it necessary to set the include diretories accordingly.
   please go follows these procedures:
   1)  Right-click your mouse on the VS2010 at the "Solution Explorer" tab
   2)  Select "Properties"
   3)  Follow: C/C++ |  General  | Additional Include Directories 
   4)  Click the "Configuration Active(...)", "..." means it is according to your previous setting.
   5)  Select the other, i.e., Debug to Release   or  Release to Debug, configure it again

2. It contrasts your intuition that
     \VS_IDE\VS2010\Debug
     \VS_IDE\VS2010\Release
   Folders contain the *.sys after compilation, rather than    \VS_IDE\VS2010\VS2010\Debug, where the compilation log make sense.

3. The means of opening the MSVS2010 is to click the "VS2010.sln" file at \00000_TestBench\VS_IDE\VS2010



