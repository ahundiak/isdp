/* - special conversion routine EMSsfboolean_OMPORT_EMSassoc - */

#include "OMport.h"
#define	EMS_ASbool_saveside 3

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSsfboolean_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{
	int sts, buf_len;
	char *buffer;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );
	if(!buf_len) return (1);
	switch( me->type ) {
		case	EMS_ASbool_saveside:
				sts = OMPORT_CONV_INT(buffer, 1);
				break;
		default	:	break;
	}
	return(1);
}
