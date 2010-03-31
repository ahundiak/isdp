/* - special conversion routine EMSslslotfea_OMPORT_EMSassoc - */

#include "OMport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "EMSasfeatdef.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSslslotfea_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{

        int sts, count, buf_len;
        char *buffer;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

        if(!buf_len) return (1);

        switch( me->type ) {

		case EMS_AS_THRU_ALL_SLOT_TYPE:
		case EMS_AS_THRU_NEXT_SLOT_TYPE:
		case EMS_AS_THRU_UNTIL_SLOT_TYPE:
		case EMS_AS_FINITE_SLOT_TYPE:
				sts = OMPORT_CONV_SHORT(buffer, 2);
				break;
			
		default:
				break;

        }


	return(1);
}
