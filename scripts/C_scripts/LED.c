#include <stdio.h>
#include <stdlib.h> // atoi
#include <stdint.h> // uint32t
#include <sys/mman.h> // mmap
//#d e f ine TYPE int // s i on d e f i n i t h comme int* , a l o r s l ' increment e s t en mu l t i p l e de 4 !
#define TYPE char

int main ( int argc , char ** argv )
{ 
	const int base_addr1= 0xF8000000;
	const int base_addr2= 0xe000a000;
	TYPE *h = NULL; // int*h = NULL;
	int map_file = 0;
	unsigned int page_addr, page_offset;
	unsigned page_size=sysconf(_SC_PAGESIZE);
	uint32_t value= 0x80; // 1 ou 128 pour LED orange ou rouge
	if (argc >= 2) value = atoi(argv[1]);
	printf(" value = 0x%x\n", value);
	page_addr = base_addr1&( ~ ( page_size −1) );
	page_offset= base_addr1−page_addr;
	printf(" page =0x%x size =0x%x offset =0x%x\n", page_addr, page_size,page_offset);

	// mmap the deviceint o memory
	map_file = open("/ dev / mem " , O_RDWR | O_SYNC);
	h=mmap(NULL, page_size ,PROT_READ|PROT_WRITE,MAP_SHARED, map_file, page_addr );
	if (h<0) { printf(" mmap pointer : %x\n" , (int) (h));return (−1);}
	// exemple baremetal pour de b loque r acces SLCR r e g i s t e r s
	// h t t p s :// forums . x i l i n x . com/ x lnx / at tachment s / x lnx /EDK/29780/1/ h e l l owo r l d . c
	printf( "@ -> %x %x \n" , (unsigned int)h , (unsigned int) (h+0x0c ));
	printf( " init -> %x \n" , (*(unsigned int*) (h+0x0c / sizeof(TYPE))));
	*(unsigned int*) (h+0x04/ sizeof(TYPE))=0x767b; // l o c k
	printf( " lock -> %x\n" , (*(unsigned int*) (h+0x0c / sizeof(TYPE))));
	*(unsigned int*) (h+0x08/ sizeof(TYPE))=0xDF0D; // unlock
	printf( " unlock -> %x\n" , (*(unsigned int*) (h+0x0c / sizeof(TYPE))));

	// IL FAUT L 'HORLOGE DE GPIO ! b i t 22 de 0xF8000000+0x0000012C , s inon meme l e c t u r e echoue (0 x00 )
	// h t t p s :// forums . x i l i n x . com/ t5 /Embedded−Linux/Zynq−mmap−GPIO/td−p/368601
	printf( "ck -> %x\n" , (*(unsigned int*) (h+0x12c / sizeof(TYPE))));
	*(unsigned int*) (h+0x12c / sizeof(TYPE)) j=(1<<22);
	printf( "ck -> %x\n" , (*(unsigned int*) (h+0x12c / sizeof(TYPE))));
	page_addr = ( base_addr2 & ( ~ ( page_size −1) ) );
	page_offset = base_addr2 − page_addr;
	printf ( "%x %x\n" , page_addr , page_size );
	h=mmap(NULL, page_size ,PROT_READ|PROT_WRITE,MAP_SHARED, map_file , page_addr );
	if (h<0) {printf ( " mmap pointer : %x\n" , (int) (h) ); return (−1);}
	// wr i t e r e g (0xE000A000 , 0x00000000 , 0x7C020000 ); //MIO pin 9 value update
	// wr i t e r e g (0xE000A000 , 0x00000204 , 0x200 ); // s e t d i r e c t i o n of MIO9
	// wr i t e r e g (0xE000A000 , 0x00000208 , 0x200 ); // output enab l e of MIO9
	// wr i t e r e g (0xE000A000 , 0x00000040 , 0x00000000 ); // output 0 on MIO9
	// data = r ead r e g (0xE000A000 , 0x00000060 ); // read data on MIO

	// h t t p s ://www. x i l i n x . com/ suppor t / documentat ion/ u s e r g u i d e s /ug585−Zynq−7000−TRM. pdf p .1347
	*( unsigned int*) (h+page_offset+0)=(value ); // GPIO programming sequence : p .386
	printf("hk: %x\n" , *(unsigned int*) (h+page_offset));
	*( unsigned int*) (h+page_offset+0x204/ sizeof(TYPE))=value; // d i r e c t i o n
	printf("hk +204: %x\n" , *(unsigned int*) (h+page_offset+(0x204) / sizeof(TYPE)));
	*( unsigned int*) (h+page_offset+0x208/ sizeof(TYPE) )=value; // output enab l e
	printf("hk +208: %x\n" , *(unsigned int*) (h+page_offset+(0x208) / sizeof(TYPE)));
	*( unsigned int*) (h+page_offset+0x040/ sizeof(TYPE) )=value; // output value
	printf("hk +40: %x\n" , *(unsigned int*) (h+page_offset+0x40) / sizeof(TYPE));
	close(map_file);
	return 0;
}