#include "OMport.h"

struct DPcodpb_instance {
unsigned short cct_flags;
struct OM_sd_varlenarr_descr ctable_filename;
unsigned short persp_flags;
unsigned short sws_flags;
struct OM_sd_varlenarr_descr d_expansion;
struct OM_sd_varlenarr_descr i_expansion;
struct OM_sd_varlenarr_descr s_expansion;
struct OM_sd_varlenarr_descr c_expansion;
};

DPcodpb_OMPORT_DPcodpb(classid, ME, me)
short classid;
char *ME;
struct DPcodpb_instance *me;
  {
  int  sts;
  char *data;

  data = OMPORT_VLA_VALUE(&me->c_expansion);
  sts = OMPORT_CONV_BY_TEMPLATE_NAME(data, "DPCODPB_DATA", 1);
  if(!sts) return(0);

  return(1);
}

