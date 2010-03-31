/* - special conversion routine EMSsfsolid_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "EMSasdef.h"
#include "REsfsolid.h"
#include "REgenbs.h"
#include "REgencompsf.h"
#include "REassoc.h"
#include "OMport.h"

struct EMSassoc_instance 
{
  struct OM_sd_varlenarr_descr info;
  unsigned char type;
};

EMSsfsolid_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{
  switch(me->type)
  {
  case EMS_ASno_type:
  case EMS_ASsolid_by_capping_surface:
  case EMS_ASsolid_surface_of_projection:
  case EMS_ASsolid_surface_of_projection1:
  case EMS_ASsolid_surface_of_revolution:
  case EMS_ASsolid_surface_of_revolution1:
  case EMS_ASsolid_cylinder:
  case EMS_ASsolid_tube_by_linear_and_radii:
  case EMS_ASsolid_sphere_by_center_and_radius:
  case EMS_ASsolid_cone_by_axis_and_diameters:
  case EMS_ASsolid_torus_by_axis_center_and_radius:
  case EMS_ASsolid_right_elliptical_cylinder:
  case EMS_ASsolid_right_elliptical_cone:
  case EMS_ASsolid_ellipsoid_by_foci_axis_len:
  case EMS_ASsolid_ellipsoid_by_center_axis_radius:
    {/*No special conversion needed*/
      return (1);
    }

  case EMS_ASsolid_skinning_surface:
  case EMS_ASsolid_drafted_surface:
  case EMS_ASsolid_drafted_surface1:
    {
      int sts, count, buf_len;
      char *buffer;

      buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
      buffer = (char *)((unsigned int) (&me->info) +
          OMPORT_INTEGER_VALUE (&me->info.i_offset) );

      if (!buf_len) return(1);

      if (me->type == EMS_ASsolid_skinning_surface)
      {
        sts = OMPORT_CONV_INT(buffer, 2);
      }
      else /*drafted surface case*/
      {
        struct EMSdrafted_surface *surf;
        short num_sides;

        surf = ( struct EMSdrafted_surface *)buffer;
        num_sides = OMPORT_SHORT_VALUE(&surf->num_sides);
        sts = OMPORT_CONV_SHORT(surf, 2);
        sts = OMPORT_CONV_BY_TEMPLATE_NAME(surf->codes_views,
            "codes_views_T", 
            num_sides);
      }
      return(sts);
    }
  case  EMS_ASfunction:
    /*
     * skinning solid uses this type
     */
    {
      int sts, buf_len;
      char *buffer;
      int func_name_size;

      buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
      buffer = (char *)((unsigned int) (&me->info) +
          OMPORT_INTEGER_VALUE (&me->info.i_offset) );

      if (!buf_len) return(1);

      if (!strcmp(buffer,"EFSkinSolid")) {
        int offsize;

        func_name_size = strlen(buffer) + 1;
        buffer += func_name_size;
        buffer += (offsize = (unsigned int)buffer % 8) ?
            (8 - offsize)
            :
            offsize;
        sts = OMPORT_CONV_INT(buffer,2);
      }
    }
    break;
  }
  return(1);
}
