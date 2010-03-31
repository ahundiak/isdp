/* - special conversion routine EMSsfmkface_OMPORT_EMSassoc - */

#include "OMport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "EMSasfeatdef.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSsfmkface_OMPORT_EMSassoc(classid, ME, me)
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

	sts = OMPORT_CONV_DOUBLE(buffer, 1);

	return(1);
}
