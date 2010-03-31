/* - special convertion routine GAcurve_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "GAbcsubbc.h"
#include "EMSkey.h"
#include "REcurve.h"
#include "REassoc.h"
#include "OMport.h"

/*
struct EMSkey {
	short chan_count;
	short chan_index;
	char  sub_item_type;
};
*/

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

GAbcsubbc_OMPORT_EMSassoc(classid, ME, me)
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
		case GAbcsubbc_AScurve_by_data_reduction:
	  	{
		  struct GAbcsubbc_AScurve_by_data_reduction_info *info;
		  info = (struct GAbcsubbc_AScurve_by_data_reduction_info *) 
		         buffer;
		  sts = OMPORT_CONV_DOUBLE(&info->cht,1);
		}
                break;

	        case EMS_ASfunction:
		{
		  int funk_size, offsize;
		  /*
		   * Stored pattern is func_name + \0.
		   */
		  funk_size = strlen(buffer) + 1;

		  if (strcmp(buffer, "EMCrLawCv") == 0)
		  {
		    struct EMSlaw_curve *info;

		    buffer += funk_size;
		    if (!(offsize = (unsigned int) buffer % 8))
		      buffer += 8 - offsize;
		    
		    info = (struct EMSlaw_curve *) buffer;
		    sts = OMPORT_CONV_DOUBLE(info->axis, 3);
		    sts = OMPORT_CONV_DOUBLE(info->normal, 3);
		    sts = OMPORT_CONV_SHORT(&info->reversed, 1);
		  }
		}
		break;

                default:
                 GAcurve_OMPORT_EMSassoc(classid, ME, me);
	}

	return(1);
}
