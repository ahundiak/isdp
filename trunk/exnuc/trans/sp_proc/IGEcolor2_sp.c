#include "OMport.h"
#include "igrtypedef.h"

struct IGEcolor2_instance 
{
      IGRshort  num_bg_log_hl_colors;  
      struct OM_sd_varlenarr_descr bg_log_hl_colors;  
      IGRshort  num_names;    /* Number of names of colors */
      struct OM_sd_varlenarr_descr names;   
      struct OM_sd_channel_hdr *to_IGEuserramp;
      struct OM_sd_channel_hdr *to_APPcolor2;
      struct OM_sd_channel_hdr *notify;
      struct OM_sd_varlenarr_descr tolerance_pct;
      struct OM_sd_varlenarr_descr gamma; 

      struct OM_sd_varlenarr_descr data; 

      /* this data will used as the structure IGEcolor2_data */
      /* struct IGEcolor2_data                                     */
      /* int version                                                  */
      /* int user_cube_size default,max,max-1,min+1,min               */
      /* int num_ramp_colors number of colors to try when using ramps */
};

IGEcolor2_OMPORT_IGEcolor2(classid, ME, me)
short classid;
char *ME;
struct IGEcolor2_instance *me;
{
  int sts;
  char *data;

  data = OMPORT_VLA_VALUE(&me->data);
  if ( OMPORT_DIMENSION_OF( data ) )
  { 
     sts = OMPORT_CONV_BY_TEMPLATE_NAME(data, "IGECOLOR2_DATA", 1);
  }
  if(!sts) return(0);

  return(1);

}

