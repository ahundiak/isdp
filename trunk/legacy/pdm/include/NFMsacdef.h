#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

/* define the NULL pointers */

#define MEMNULL	(MEMptr)0
#define MEMPTRNULL (MEMptr *)0

/* define the buffer sizes */
#define SIZE		96
#define HALFSIZE	48
#define ATTR_NAME_SIZE	48
#define QRY_STR_SIZE	2048
#define STR_SIZE	1024

/* define the structures */

typedef struct NFMsa_index_struct {
			long sa_no;
			long index;
			char old_name[16];
			char new_name[16];
		   } NFMsa_index;
