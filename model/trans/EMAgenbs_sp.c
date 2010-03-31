/* - special convertion routine EMAgenbs_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REgenbs.h"
#include "REassoc.h"
#include "ex.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "OMport.h"

struct EMSassoc_instance {
  struct OM_sd_varlenarr_descr info;
  unsigned char type;
};

EMAgenbs_OMPORT_EMSassoc(classid, ME, me)
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

  case  EMS_ASfitted_surface :

    sts = OMPORT_CONV_DOUBLE(buffer, 1);
    break;

  case  EMS_ASskinning_surface :
    /* this type is obsolete as of 2.4, skinning uses *
       * now EMS_ASfunction case below       */
    sts = OMPORT_CONV_INT(buffer, 2);
    break;

  case  EMS_ASdirect_fit_surface :
  case  EMS_ASsurface_by_poles  :
  case  EMS_ASdirect_fit_surface_by_curves :

    break;

  case  EMS_ASleast_squares_fit_surface :
    break;

  case  EMS_ASnetwork_of_curves :

    /** Two longs followed by an array of chars **/

    sts = OMPORT_CONV_INT(buffer, 2);
    break;

  case  EMS_ASsurface_by_bound   :
    break;

  case  EMS_ASbox_by_4pts :
    break;

  case  EMS_AStube_by_linear_and_radii :
    break;

  case  EMS_ASdefault_ruled_surface  :
  case  EMS_ASarclength_ruled_surface :
  case  EMS_ASdevelopable_ruled_surface :

    {
      struct EMSruled_surface *surf;

      surf = (struct EMSruled_surface *)buffer;
      count = OMPORT_INTEGER_VALUE(&surf->num_cp);
      sts = OMPORT_CONV_INT(&surf->num_cp, 1);
      sts = OMPORT_CONV_DOUBLE(surf->chardata, 2*count);
    }

    break;


  case  EMS_ASblend_exterior   :

    break;
  case  EMS_ASfunction: 
    {
      int func_name_size;

      if (!strcmp(buffer,"EFSkinSurface")) {
        int offsize;

        func_name_size = strlen(buffer) + 1;
        buffer += func_name_size;
        buffer += (offsize = (unsigned int)buffer % 8) ?
            (8 - offsize)
            :
            offsize;
        sts = OMPORT_CONV_INT(buffer,2);
      }
      else if (!strcmp(buffer,"EFCsecSurf")) {
        int offsize, cs_count, tr_count, offset;
        struct EMScross_section_surface *recomp_info;
        struct GRlc_info *lc_info;

        func_name_size = strlen(buffer) + 1;
        buffer += func_name_size;
        buffer += (offsize = (unsigned int)buffer % 8) ?
                  (8 - offsize) : offsize;
        recomp_info = (struct EMScross_section_surface *)buffer;

        tr_count = OMPORT_INTEGER_VALUE(&recomp_info->number_of_trace_curves);
        cs_count = OMPORT_INTEGER_VALUE(&recomp_info->number_of_sections);
        sts = OMPORT_CONV_INT(&recomp_info->number_of_sections,1);  
        sts = OMPORT_CONV_INT(&recomp_info->number_of_trace_curves,1);  
        sts = OMPORT_CONV_DOUBLE(recomp_info->refpln,12);  
        sts = OMPORT_CONV_DOUBLE(recomp_info->dirvec,3);  
        sts = OMPORT_CONV_INT(&recomp_info->mirror_case,1);  
        sts = OMPORT_CONV_DOUBLE(&recomp_info->chardata[tr_count+cs_count],4*cs_count);  

        /* Unfortunately there may be a struct GRlc_info in the chardata ... */
        if (recomp_info->att_method_props & 0x8 ) {

           offset=tr_count+cs_count+4*cs_count*sizeof(double);
           lc_info = (struct GRlc_info *)&recomp_info->chardata[offset];

           sts = OMPORT_CONV_SHORT(&lc_info->located_obj.osnum,1);
           sts = OMPORT_CONV_INT(&lc_info->located_obj.objid,1);
           sts = OMPORT_CONV_SHORT(&lc_info->module_info.md_id.osnum,1);
           sts = OMPORT_CONV_INT(&lc_info->module_info.md_id.objid,1);
           sts = OMPORT_CONV_SHORT(&lc_info->module_info.md_env.matrix_type,1);
           sts = OMPORT_CONV_DOUBLE(lc_info->module_info.md_env.matrix,16);
        }
      }
    }
    break;

  default  :  
    break;

  }

  return(1);
}
