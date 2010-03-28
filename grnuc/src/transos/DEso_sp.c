/* - special conversion routine DEso$DEso - */

#include "OMminimum.h"
#include "OMport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "DEso.h"


struct DEso_instance {

struct OM_sd_channel_hdr       to_windows;
struct OM_sd_channel_hdr       to_contexts;
struct OM_sd_varlenarr_descr   soo;
int                            used;
GRspacenum                     osnum;
};


DEso_OMPORT_DEso(short classid, char *ME, struct DEso_instance *me)

{
   int  sts;
   char *data;
   int  nb_entry;

   data = OMPORT_VLA_VALUE(&me->soo);
   nb_entry = OMPORT_INTEGER_VALUE(&me->soo.i_count);
   sts = OMPORT_CONV_BY_TEMPLATE_NAME( data,"DESOE_STRUCT", nb_entry );

   if(!sts) return(0);

   return(1);

}

