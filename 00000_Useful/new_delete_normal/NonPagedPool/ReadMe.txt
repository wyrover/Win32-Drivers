# new_delete_normal

The Non-PagedPool version

Overload the operator new/delete in the C++ coded Win32 Driver

>>>>>>>>>>>>>>   Caution    <<<<<<<<<<<<<<<<<<<<<
1. The Operator Overloading features can only be enable in C++.
2. To avoid mistake, you ought to use: "new/delete"  rather than "new/delete [] ".
3. If it frequently applies an fixed-size memory location, this would be not suitable.
     Lookaside, the generic one will give you help.