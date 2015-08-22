//
//  new_delete_PagedPool.hxx
//
//  C++ Header file for overloading the operator new/delete.
//      Because the Runtime library located in C++ doesn't work in Kernel-Mode Driver.
//
//   *****Caution!!!
//     1. The Operator Overloading features can only be enable in C++.
//     2. To avoid mistake, you ought to use: "new/delete"  rather than "new/delete [] ".
//     3. If it frequently applies an fixed-size memory location, this would be not suitable.
//         "new_delete_lookaside.hxx", the generic one will give you help.
//
//   History:
//  1. Begin:  12:00 PM, Aug 19, 2015, By Mighten Dai <mighten.dai@gmail.com>
//

#ifndef   MACRO_PROTECTION__INCLUDE__NEW_DELETE_PAGED_POOL_HXX__
#define   MACRO_PROTECTION__INCLUDE__NEW_DELETE_PAGED_POOL_HXX__

//////////////////////////////////////////////////////////////////////////////
void * (__cdecl)    operator new(   size_t size,    POOL_TYPE PoolType=PagedPool )
{
	return ExAllocatePool( PagedPool, size );
}

//////////////////////////////////////////////////////////////////////////////
void (__cdecl) operator delete(void* pointer)
{
	ExFreePool(pointer);
}

//////////////////////////////////////////////////////////////////////////////

#endif // #ifndef   MACRO_PROTECTION__INCLUDE__NEW_DELETE_PAGED_POOL_HXX__