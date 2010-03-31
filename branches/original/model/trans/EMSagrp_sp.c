/* - special convertion routine EMSagrp_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REagrp.h"
#include "OMport.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSagrp_OMPORT_EMSassoc(classid, ME, me)
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

		case	EMS_ASintersect_elements:
		case	EMS_ASintersect_elements1:
		                {
					struct EMSintersect_elements *elem;
					elem = (struct EMSintersect_elements *)
						buffer;
					sts = OMPORT_CONV_DOUBLE(&elem->cht, 1);
				}
				break;
			
		case	EMS_ASiso_parametric_curves: {
					struct EMSisoparametric_curves *curve;
					curve = (struct EMSisoparametric_curves *)
						buffer;
					sts = OMPORT_CONV_INT(&curve->num_parms, 1);
					sts = OMPORT_CONV_DOUBLE(&curve->start_param, 1);
					sts = OMPORT_CONV_DOUBLE(&curve->end_param, 1);
				}
				break;
			
		default:	break;
	}

	return(1);
}
