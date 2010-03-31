/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

# include "msdef.h"
# ifndef gocmacros_include
# include "gocmacros.h" /* GRgetabsg */
# endif

method EMvalidateClass(
 IGRlong               *EMmsg;
 struct  GRmd_env      *md_env;
 GRobjid               *new_objid;
 struct IGRbsp_surface *sf_geom)

/*
Abstract
    This method performs the class validation with respect to the
    geometry.

Arguments

    md_env    - input
        The module info the object.

    new_objid - output
        The object id of the new object if the surface changes class.
        Otherwise it will be the id of the original surface.

    sf_geom - input
        The caller may send the surface geometry, or NULL. If surf is
        NULL, the geometry will be generated from the surface object.

History
        DLB   10/27/88     fixed sd_override field in om$change_class
        RC    01/18/87     Creation Date

*/

{
  IGRchar                   *absptr;
  IGRboolean                is_linear_map_ok;
  IGRboolean                stat;
  IGRboolean   EFis_linear_map_ok();
  IGRlong                   OM_stat;
  IGRlong   mthd_stat;
  IGRlong   EMchgclass();
  struct  IGRbsp_surface    *surf;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  absptr = NULL;
  surf = NULL;

  if (!sf_geom)
  {
    GRgetabsg (&mthd_stat, &md_env->md_env.matrix_type,
                md_env->md_env.matrix, &absptr, i);
    EMerr_hndlr (!(1&mthd_stat),*EMmsg, EMS_E_Fail,wrapup);
   
    surf = (struct IGRbsp_surface *) absptr; 
  }
  else surf = sf_geom;

  /*
   * Check if the surface still verifies the EMSplane criterion
   * or not. If not, change its class to free_from.
   */

  if ( (surf->u_order == 2) && (surf->v_order == 2) &&
       (surf->planar) && (!surf->rational))
  {
     stat = EFis_linear_map_ok ( &mthd_stat, surf, &is_linear_map_ok);
     EMerr_hndlr (!stat || !(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
  }
  else is_linear_map_ok = FALSE;
   
  if (!is_linear_map_ok)
  {
    OM_stat = om$change_class(objid = my_id, osnum = OM_Gw_current_OS,
                             classname = "EMSgenbs",
                             sd_override = OM_K_change_class_sd_override);
    EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror,wrapup);

  } /* if (!is_linear_map_ok) */

wrapup:

  if (absptr) GRabsg_del(absptr);

  EMWRAPUP (*EMmsg, OM_stat, "In EMSplane.EMputGeom");

  return (OM_stat);

}

end implementation EMSplane;
