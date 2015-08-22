# Lookaside,
 is of vital significance when faced with these two situations:
   > allocating of fixed size every time
   > frequently allocating/releasing

By using this mechanism proves more efficient than system routine.

----------  Note that -------------
1> This is a speciall object that encapsulates the details of managing the memory space.
   We cannot grasp the more exciting from ScreenCapture but from C++ codes.

2> Due to the extra existance of initialization/Deletion of Lookaside object,
    there is no necessity to implement it into new/delete operator overloading.