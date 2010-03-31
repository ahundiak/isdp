/* - special conversion routine EMSsffeature_OMPORT_EMSassoc - */

#include "OMport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "EMSasfeatdef.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSsffeature_OMPORT_EMSassoc(classid, ME, me)
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

                case EMS_ASSOC_FEATURE_ADD_MATERIAL:
                case EMS_ASSOC_FEATURE_REMOVE_MATERIAL:
                     OMPORT_CONV_INT(buffer,2); 
                     break;
            
		case EMS_ASSOC_FEATURE_RIB:

                     OMPORT_CONV_INT(buffer,2);
                     break;
                 
		default	:	
                     break;
	}
	return(1);
}
