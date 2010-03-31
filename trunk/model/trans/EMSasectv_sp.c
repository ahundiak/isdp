/* - special convertion routine EMSasectvw_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REagrp.h"
#include "OMport.h"
#include "EMSasectvw.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSasectvw_OMPORT_EMSassoc(classid, ME, me)
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

	switch( me->type )
        {
                case    EMS_ASsect_view:
                case    EMS_ASsection_view:
                case    EMS_ASsectvw:
                case    EMS_ASsectvw_tran:
                {
                    struct EMS_ASsect_view_info *elem;
                    struct EMS_ASsection_view_info *view_elem;
                    struct EMS_ASsectvw_info *sectvw_elem;
                    struct EMS_ASsectvw_tran_info *sectvw_tran_elem;

                    if (me->type == EMS_ASsect_view)
                        elem = (struct EMS_ASsect_view_info *) buffer;
                    else if (me->type == EMS_ASsection_view)
                    {
                        view_elem = (struct EMS_ASsection_view_info *) buffer;
                        elem = (struct EMS_ASsect_view_info *) &view_elem->view_info;
                        sts = OMPORT_CONV_DOUBLE(&view_elem->rot_angle, 1);
                    }
                    else if(me->type == EMS_ASsectvw_tran)
                    {
                     sectvw_tran_elem =(struct EMS_ASsectvw_tran_info *) buffer;
                     elem = (struct EMS_ASsect_view_info *)&sectvw_tran_elem->view_info;
                     sts = OMPORT_CONV_DOUBLE(&sectvw_tran_elem->rot_angle, 1);
                     sts = OMPORT_CONV_DOUBLE(sectvw_tran_elem->origin, 3);
                     sts = OMPORT_CONV_DOUBLE(sectvw_tran_elem->rot_matrix,16);
                    }
                    else  /* (me->type == EMS_ASsectvw) */
                    {
                        sectvw_elem = (struct EMS_ASsectvw_info *) buffer;
                        elem = (struct EMS_ASsect_view_info *) &sectvw_elem->view_info;
                        sts = OMPORT_CONV_DOUBLE(&sectvw_elem->rot_angle, 1);
                        sts = OMPORT_CONV_DOUBLE(sectvw_elem->origin, 3);
                    }
                    sts = OMPORT_CONV_DOUBLE(&elem->cht, 1);
                    sts = OMPORT_CONV_DOUBLE(elem->z_vec, 3);
                    sts = OMPORT_CONV_SHORT(&elem->flags, 1);
                }
                break;

		case	EMS_ASintersect_elements:
		case	EMS_ASintersect_elements1:
                {
    		    struct EMSsect_view_info *elem;

		    elem = (struct EMSsect_view_info *) buffer;
		    sts = OMPORT_CONV_DOUBLE(&elem->cht, 1);
		    sts = OMPORT_CONV_DOUBLE(elem->z_vec, 3);
		    sts = OMPORT_CONV_DOUBLE(elem->placement_pt, 3);
	        }
		break;
			
		default:	break;
	}

	return(1);
}
