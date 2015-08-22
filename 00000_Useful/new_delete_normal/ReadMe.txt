# new / delete normal version

Two versions of allocation
> Paged
> NonPaged

Note that, according to Windows NT's common sense,
if IRQL bigger than and equal to DISPATHCH_LEVEL,
    we can only use NonPagedPool,
  or causes BSOD( Blue Screen Of Death )