//
//    Dump_App.hpp
//
//    dump App's buffer contents in Console App
//
//     12:21 PM
//     Oct 02, 2015
//         Mighten Dai<mighten.dai@gmail.com>
//

#pragma once

//////////////////////////////////////////////
//    Function name:     do_dump_buffer
//    Parameter(s):      (void *)pBuffer, unsigned int length
//    return value:      0 indicate normally done. Otherwise abnormal.
int    do_dump_buffer(  unsigned char *pBuffer, unsigned int length )
{
	unsigned int    index;
	
	printf("Now dumping buffer with the given length as the byte order low to high.\n");
	
	for ( index = 0; index < length; ++index )
	{
		printf("%02d indicate ----> 0x%02X\n", index, pBuffer[index] );
	}
	
	putchar('\n');

	return 0;
}