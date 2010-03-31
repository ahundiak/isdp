/* - special convertion routine EMSsfimpbnd_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "EMSasdef.h"
#include "REsfimpbnd.h"
#include "OMport.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSsfimpbnd_OMPORT_EMSassoc(classid, ME, me)
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
		
		case	EMS_ASno_type:
				sts = OMPORT_CONV_BY_TEMPLATE_NAME(buffer,
						"EMSimpbndinfo_T", 1 );
				break;		

		default	:	break;
	}

	return(1);
}
