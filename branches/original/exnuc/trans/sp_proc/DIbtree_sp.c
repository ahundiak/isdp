#include "OMminimum.h"
#include "OMport.h"

struct BTree {
char *root;
char type;
int nfree;
int *data;
int *cmp;
int size;
int last;
};

struct DIbtree_instance {
struct BTree *tree;
struct OM_sd_varlenarr_descr buffer;
};

DIbtree_OMPORT_DIbtree(classid, ME, me)
short classid;
char *ME;
struct DIbtree_instance *me;
{

	int sts, buf_len, i;
	char *buffer;

        buf_len = OMPORT_DIMENSION_OF(&me->buffer);
	buffer = OMPORT_VLA_VALUE(&me->buffer);

	if(buf_len){
		char *next_ptr;
		unsigned int end;

		next_ptr = (char *)strchr(buffer, 0);
		next_ptr++;
		sts = OMPORT_CONV_INT((int *)next_ptr, 1);
		if (!sts) return sts;
		next_ptr += 4;
 		end = (unsigned int) buffer + buf_len;

	        while ( (int)next_ptr < (int)end ) {
		   next_ptr = (char *)strchr(next_ptr, 0);
		   next_ptr++;
		   sts = OMPORT_CONV_INT(next_ptr, 1);
		   if (!sts) return sts;
		   next_ptr += 4;
	        }
	}		

        return(1);

}
