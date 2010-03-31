/* - special conversion routine EMSsfaddraft_OMPORT_EMSassoc - */

#include "OMport.h"
#include "igrtypedef.h"
#include "EMSasfeatdef.h"

struct EMSview_info {
	unsigned short	parent_index;
	unsigned short	view_index;
};

struct EMSadd_draft{
	double	cht;
	unsigned short num_views;
	struct EMSview_info views[1]; 
};

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSsfaddraft_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{

        int sts, count, buf_len;
        char *buffer;
	short num_views;
	struct EMSadd_draft *draft;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

        if(!buf_len) return (1);

	draft = ( struct EMSadd_draft *)buffer;
	sts = OMPORT_CONV_DOUBLE(&draft->cht, 1);
	num_views = OMPORT_SHORT_VALUE( &draft->num_views );
	sts = OMPORT_CONV_SHORT(&draft->num_views, 1);
	sts = OMPORT_CONV_SHORT(draft->views, 2*num_views);

	return(1);
}
