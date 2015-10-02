//
//    Dump_Drv.hpp
//
//    dump Driver's buffer contents
//
//     12:22 PM
//     Oct 02, 2015
//         Mighten Dai<mighten.dai@gmail.com>
//


//////////////////////////////////////////////
//    Function name:     do_dump_buffer
//    Parameter(s):      (unsigned char *)pBuffer, unsigned int length
//    return value:      0 indicate normally done. Otherwise abnormal.
#pragma    PAGEDCODE
int    do_dump_buffer(  unsigned char *pBuffer, unsigned int length )
{
	unsigned int    index;
	
	KdPrint(("\n Now dumping buffer with the given length as the byte order low to high.\n"));
	
	for ( index = 0; index < length; ++index )
	{
		KdPrint(("%02d indicate ----> 0x%02X\n", index, pBuffer[index] ));
	}
	
	return 0;
}