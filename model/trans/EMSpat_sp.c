/* - special conversion routine EMSslslotfea_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igrtypedef.h"
#include "OMport.h"
#include "GRascopy.h"

 struct EMSpatfea_instance
  {
   IGRshort pattern_type;
   IGRshort fea_props;
   struct OM_sd_varlenarr_descr deleted;
   struct OM_sd_varlenarr_descr info;
   OM_p_CHANNEL_HDR    listeners;
  };

EMSpatfea_OMPORT_EMSpatfea(classid, ME, me)
short classid;
char *ME;
struct EMSpatfea_instance *me;
{

        int sts, count, buf_len,type;
        char *buffer;
	struct GRptrn_matrix *mat;
	struct GRptrn_polar  *polar;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

        if(!buf_len) return (1);
        type= OMPORT_SHORT_VALUE (&me->pattern_type);

        switch(type) {

	case GR_ASCOPY_RECTANGULAR:
	  mat = (struct GRptrn_matrix *)buffer;
	  sts = OMPORT_CONV_BY_TEMPLATE_NAME(mat,"matrix_pat_T",1);
	  break;
	case GR_ASCOPY_POLAR:
	  polar = (struct GRptrn_polar *)buffer;
	  sts = OMPORT_CONV_BY_TEMPLATE_NAME(polar,"polar_pat_T",1);
	  break;			
	default:
	  break;

        }

	return(1);
}
