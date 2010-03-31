/* - special conversion routine EMSgencompsf_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REgencompsf.h"
#include "REassoc.h"
#include "OMport.h"

struct EMSassoc_instance {
  struct OM_sd_varlenarr_descr info;
  unsigned char type;
};

EMSgencompsf_OMPORT_EMSassoc(classid, ME, me)
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

  case  EMS_ASfillet_by_edge_radius:
  case    EMS_ASfillet_by_edge_radius_w_track_pt:
  case  EMS_ASfillet_by_edge_radii:
  case    EMS_ASfillet_by_edge_radii_w_track_pt:
  case  EMS_ASfillet_by_surface_surface_radius:
  case    EMS_ASfillet_by_surface_surface_radius_w_track_pt:
  case  EMS_ASfillet_by_surface_surface_radii:
  case    EMS_ASfillet_by_surface_surface_radii_w_track_pt:
  case  EMS_ASfillet_by_curve_surface_surface:
  case    EMS_ASfillet_by_curve_surface_surface_w_track_pt:
  case  EMS_ASfillet_by_curve_surface_radius:
  case    EMS_ASfillet_by_curve_surface_radius_w_track_pt:
  case  EMS_ASfillet_by_triple_surfaces:
  case    EMS_ASfillet_by_triple_surfaces_w_track_pt:
    {
      struct EMSfillet_surface_new *surf;
      surf = ( struct EMSfillet_surface_new *)buffer;
      sts = OMPORT_CONV_SHORT(&surf->props,1);
      sts = OMPORT_CONV_SHORT(&surf->view_index, 1);
      sts = OMPORT_CONV_DOUBLE(&surf->cht_tol, 1);
      sts = OMPORT_CONV_SHORT(&surf->reverse, 1);
    }
    break;

  case  EMS_ASfillet_by_surfaces_and_radii:
  case    EMS_ASfillet_by_surfaces_and_radii_w_track_pt:
    {
      struct EMSfillet_surface *surf;
      surf = ( struct EMSfillet_surface *)buffer;
      sts = OMPORT_CONV_SHORT(&surf->props,1);
      sts = OMPORT_CONV_DOUBLE(&surf->rho_value, 1);
      sts = OMPORT_CONV_SHORT(&surf->view_index, 1);
    }
    break;

  case  EMS_ASblend_curve_surface:  
    {
      struct EMSblend_curve_surface *surf;
      surf = ( struct EMSblend_curve_surface *)buffer;
      sts = OMPORT_CONV_BY_TEMPLATE_NAME(
          surf->center_point,
          "IGRpoint_T", 
          1 );
      sts = OMPORT_CONV_BY_TEMPLATE_NAME(
          surf->normal_vector,
          "IGRvector_T", 
          1 );
    }
    break;

  case  EMS_ASsurface_by_offsetting_surface:
  case    EMS_ASsurface_by_offsetting_surface1:  
    {
      if(buf_len > 4)   /* Post 2.2 Models */
      {
         struct EMSoffset_surface *surf;
         int num_sides;

         surf = ( struct EMSoffset_surface *)buffer;
         num_sides = OMPORT_INTEGER_VALUE
                           (&surf->num_spec_tks);

         sts = OMPORT_CONV_INT(surf, 2);
         if(!sts) return (sts);
         sts = OMPORT_CONV_BY_TEMPLATE_NAME(
                            surf->off_surf_views,
                            "surfs_views_T",
                            num_sides+1 );
      }
      else       /* EMS 2.2 Models */
      {
         struct EMSoffset_simple_surface *surf;

         surf = (struct EMSoffset_simple_surface *)buffer;
         sts = OMPORT_CONV_INT(surf, 1);
      }
    }
    break;

  case    EMS_ASdrafted_surface1:
  case  EMS_ASdrafted_surface:  
    {
      struct EMSdrafted_surface *surf;
      short num_sides;
      surf = ( struct EMSdrafted_surface *)buffer;
      num_sides = OMPORT_SHORT_VALUE(&surf->num_sides);
      sts = OMPORT_CONV_SHORT(surf,2);
      sts = OMPORT_CONV_BY_TEMPLATE_NAME(
          surf->codes_views,
          "codes_views_T", 
          num_sides );
    }
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
    }
    break;
  default:  
    break;

  }
  return(1);
}
