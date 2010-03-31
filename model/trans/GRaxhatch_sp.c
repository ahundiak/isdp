/* - special convertion routine GRaxhatch_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REagrp.h"
#include "OMport.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grxhatch.h"
#include "GRaxhatch.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

GRaxhatch_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{
        struct GRaxhatch_info *elem;
	int sts, count, buf_len, index, index2;
	char *buffer;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

	if(!buf_len) return (1);

	switch( me->type ) {

           case	GR_axhatch_elem:

		elem = (struct GRaxhatch_info *) buffer;
		sts = OMPORT_CONV_DOUBLE(&elem->xhatch_spacing, 1);
		sts = OMPORT_CONV_DOUBLE(&elem->xhatch_angle, 1);
		sts = OMPORT_CONV_DOUBLE(elem->origin, 3);
                sts = OMPORT_CONV_INT(&elem->pattern_def.num_angles, 1);
                sts = OMPORT_CONV_SHORT(&elem->pattern_def.level, 1);

                for (index = 0; index < 3; index++)
                {
                    sts = OMPORT_CONV_DOUBLE(&elem->pattern_def.pass[index].angle, 1);
                    sts = OMPORT_CONV_SHORT(&elem->pattern_def.pass[index].num_lines, 1);

                    for (index2 = 0; index2 < 9; index2++)
                    {
                        sts = OMPORT_CONV_SHORT(&elem->pattern_def.pass[index].lines[index2].line_symbology.color, 1);
                        sts = OMPORT_CONV_DOUBLE(&elem->pattern_def.pass[index].lines[index2].perp_dist_next_line, 1);
                    }
                }

                sts = OMPORT_CONV_SHORT(&elem->window_grid.osnum, 1);
                sts = OMPORT_CONV_INT(&elem->window_grid.objid, 1);
                sts = OMPORT_CONV_SHORT(&elem->xhatch_color, 1);
		break;
			
  	    default:	break;
	}

	return(1);
}
