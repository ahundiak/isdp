/* - special convertion routine EMSgensolid_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REgensolid.h"
#include "REshsolid.h"
#include "OMport.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSgensolid_OMPORT_EMSassoc(classid, ME, me)
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

		case	EMS_ASsolid_by_offsetting_surface:
                case    EMS_ASsolid_by_offsetting_surface1:
				sts = OMPORT_CONV_INT(buffer, 1);
				break;
		case	EMS_ASthinwall_from_compsurf: {
		        	struct EMSshell_solid *shell;
       				IGRint num_mult_tks;

        			buf_len = OMPORT_INTEGER_VALUE 
						(&me->info.i_count);
        			buffer = (char *)((unsigned int) (&me->info) +
                 		  OMPORT_INTEGER_VALUE (&me->info.i_offset) );
			        shell = ( struct EMSshell_solid *)buffer;

			        if(!buf_len) return (1);

                                /* The first three fields are respectively:
                                    one 'IGRushort' and two 'IGRboolean's. */
			        sts = OMPORT_CONV_SHORT(shell, 3);
			        if(!sts)  return (sts);

			        num_mult_tks = OMPORT_INTEGER_VALUE
						(&shell->num_mult_tks);

			        sts = OMPORT_CONV_INT(&shell->num_mult_tks, 1);
			        sts = OMPORT_CONV_BY_TEMPLATE_NAME(
                                        shell->sfs_views,
                                        "shell_sfs_T",
                                        num_mult_tks+1 );
			        if(!sts) return(sts);
                            }
                            break;
                            
		default:	break;
	}

	return(1);
}
