/* - special conversion routine EMSsfrndbool_OMPORT_EMSassoc & slrndbool- */

#include "OMport.h"
#include "igrtypedef.h"
#include "EMSasfeatdef.h"

struct EMSview_info {
	unsigned short	parent_index;
	unsigned short	view_index;
};

struct EMSround_chamfer {
	IGRdouble	cht;
	unsigned short	num_views;
	struct EMSview_info views[1]; 
};

struct EMSassoc_instance
{
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSsfrndbool_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{

        int sts, count, buf_len;
        char *buffer;
	short num_views;
	struct EMSround_chamfer *round_cham;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

        if(!buf_len) return (1);

	round_cham = ( struct EMSround_chamfer *)buffer;
	sts = OMPORT_CONV_DOUBLE(&round_cham->cht, 1);
	num_views = OMPORT_SHORT_VALUE( &round_cham->num_views );
	sts = OMPORT_CONV_SHORT(&round_cham->num_views, 1);
	sts = OMPORT_CONV_SHORT(round_cham->views, 2*num_views);

	return(1);
}

EMSslrndbool_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{
   return(EMSsfrndbool_OMPORT_EMSassoc(classid, ME, me));
}
