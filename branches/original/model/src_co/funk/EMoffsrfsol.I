/*
 Description

 This function creates a solid by offsetting a surface which possibly has
 boundaries.  It is assumed that the resulting solid is valid, i.e. no
 checks are made to ensure that the solid does not intersect itself, etc..

 Bugs

 Ruled surfaces are created as the side surfaces when surfaces of
 projection would be more appropriate in some cases.

 History

 07/13/88 : rlw : Creation date
 07/20/88 : rlw : Changed due to changes in Brooke's function
 10/23/88 : DLB : Removed EMreduce_range send to copied surface.
 08/10/89 : pp  : Modified arguments to EMgenerate_offset_surface
 19/01/93 : sam : Passed addtional arguments to EMoffset .
 */

class implementation EMSsubbs;

#include "EMS.h"
#include "bs.h"                 /* BSSUCC, etc. */
#include "godef.h"              /* Properties masks */
#include "msdef.h"              /* MSSUCC, MSFAIL */
#include "EMSopt.h"             /* Has required offset option */

IGRlong EMoffset_surface_to_solid(
 lc_info,               /* Locate information for a EMSsubbs subclass srf */
 offset_distance,       /* Distance surface is to be offset */
 use_natural_normal,    /* Offset in natural normal direction? */
 construct_list,        /* Standard construct list */
 my_stupid_id,          /* Callers object id */
 solid_id)              /* Resulting solid - NULL_OBJID on failure */

struct          GRlc_info *lc_info;
IGRdouble       offset_distance;
IGRboolean      use_natural_normal;
struct          GRvg_construct *construct_list;
OM_S_OBJID      my_stupid_id;
GRobjid         *solid_id;

{
 OMuword                space_number;
 IGRlong                sts, *msg;
 GRobjid                sf_id, offset_sf_id;
 struct                 GRmd_env *md_env;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 sf_id = NULL_OBJID;
 offset_sf_id = NULL_OBJID;
 *solid_id = NULL_OBJID;
 md_env = construct_list->env_info;
 space_number = md_env->md_id.osnum;
/*
 * Copy the original surface to the 
 * destination object space (possibly the same).
 */
 {
  struct        GRid *id;
  struct        GRmd_env *old_md_env;

  id = &lc_info->located_obj;
  old_md_env = &lc_info->module_info;
  sts = om$send(
    msg = message GRgraphics.GRcopy(
     msg,
     old_md_env,
     md_env,
     &sf_id),
    senderid = my_stupid_id,
    targetid = id->objid,
    targetos = id->osnum);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * Compress the surfaces topology and reduce it's range.
 */
 {
/******************DLB 10/23/88 **************************************
  GRobjid       new_surface;
*********************************************************************/
  sts = om$send(
    msg = message EMSsubbs.EMcompress_top(
     msg,
     md_env),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
/******************DLB 10/23/88 **************************************
  sts = om$send(
    msg = message EMSsubbs.EMreduce_range(
     msg,
     md_env,
     &new_surface),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  sf_id = new_surface;
*********************************************************************/
 }
/*
 * Change the symbology of the copied surface
 */
 {
  struct        GRsymbology symbology;
  struct        IGResbs *element_specific;

  symbology.level = construct_list->level;
  symbology.display_attr = *(construct_list->display);
  sts = om$send(
    msg = message GRvg.GRputsymb(
     msg,
     &symbology),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (!(1 & sts)) goto wrapup;
  element_specific = (struct IGResbs *) construct_list->class_attr;
  sts = om$send(
    msg = message GRvg.GRputattr(
     msg,
     (IGRchar *) element_specific),
    senderid = my_stupid_id,
    targetid = sf_id,
    targetos = space_number);
   if (!(1 & sts)) goto wrapup;
  }
/*
 * Offset the copied surface with the option
 * to preserve topology
 */
  {
   IGRshort     offset_option;
   IGRlong	msg_loc;
   struct       GRmdenv_info *mdenv_info;

   offset_option = EMS_opt_offsetS_copy_topology;
   mdenv_info = &md_env->md_env;
   sts = om$send(
     msg = message EMSsurface.EMoffset(&msg_loc, offset_option,
      &md_env->md_env.matrix_type, md_env->md_env.matrix,
      construct_list,
      use_natural_normal,
      offset_distance,
      0, NULL, NULL,
      0, NULL, NULL,
      &offset_sf_id,NULL),
     senderid = my_stupid_id,
     targetid = sf_id,
     targetos = space_number);
    if (! (1 & sts)) goto wrapup;
  }
/*
 * Create the side surface(s), if any, and connect up the
 * topology between all the surfaces.
 */
 {
  extern        IGRlong EFnaturalGeneralSolidFromSurfaces();

  sts = EFnaturalGeneralSolidFromSurfaces(
    msg,
    my_stupid_id,
    space_number,
    sf_id, 
    offset_sf_id,
    construct_list,
    NULL,               /* I don't want the pieces if it fails */
    solid_id);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * eof
 */
wrapup:
 if (! (1 & *msg))
  {
   IGRlong      loc_msg;

   if (sf_id != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       md_env),
      senderid = my_stupid_id,
      targetid = sf_id,
      targetos = space_number);
    }
   if (offset_sf_id != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       md_env),
      senderid = my_stupid_id,
      targetid = offset_sf_id,
      targetos = space_number);
    }
   if (*solid_id != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       md_env),
      senderid = my_stupid_id,
      targetid = *solid_id,
      targetos = space_number);
    }
   return(FALSE);
  }
 else
  return(TRUE);
}

end implementation EMSsubbs;
