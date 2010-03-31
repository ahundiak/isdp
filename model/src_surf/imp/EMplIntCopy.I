/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

# include "emssfdef.h"
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "emsdef.h"

/*

 HISTORY
        RC  01/17/89    Creation Date
        SM  06-Jul-89   Added bdry_options and sf_options arguments
        AIC 09/09/91    Removed HSURF bundle changes; handled by EMSsubbs
*/

method EMintcopy(
        IGRlong         *EMmsg; 
        struct GRmd_env *obj_mdenv;
        struct GRmd_env *new_mdenv; 
        GRobjid         *newobjid;
        struct EMcp_info *copy_info;
	IGRushort       bdry_options,  sf_options)
{
    IGRlong           OM_stat, mthd_stat, sts, rc;
    IGRboolean        sf_copy_exists;
    extern void       EMcpsearch ();

    *EMmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;

    /*
     * find out if I have been already copied or not.
     * If so, return my counter part's objid and I am all done
     */
        
    EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
                &sf_copy_exists);
    EMerr_hndlr(!(1&mthd_stat), *EMmsg, mthd_stat, wrapup);
    if (sf_copy_exists) goto wrapup;

    /* 
     * copy  myself 
     */

    OM_stat = om$send(mode = OM_e_wrt_parent,
                      msg = message EMSplane.EMintcopy (EMmsg,
                       obj_mdenv, new_mdenv, newobjid, copy_info, 
		       bdry_options, sf_options),
                      targetid = my_id);
    EMerr_hndlr (!(1&OM_stat & *EMmsg),*EMmsg, EMS_E_SurfaceError,wrapup);

    /*
     * If the copy's environment matrix is not identity, 
     * there is some transformation going on. In such instances,
     * if I have a cross_hatch graphics data, it needs to be updated.
     * Basically, the cross hatch update will keep the same cross hatch
     * angle but will appropriately scale the spacings.
     */

     if (new_mdenv->md_env.matrix_type != MAIDMX)
     {    
       IGRmatrix           inv_mx;
       IGRlong             mx_type;
       extern IGRlong      EFmatrixClassification();
       IGRshort            dim = 4;
       IGRboolean          status;
       extern IGRboolean   MAidmx(), MAinvmx();
       extern void         EFplane_xform_support ();
       
       status = MAinvmx (&rc, &dim, new_mdenv->md_env.matrix, inv_mx);
       EMerr_hndlr (!status || !(1&rc), *EMmsg, EMS_E_Fail, wrapup);

       mx_type = EFmatrixClassification (inv_mx);

       if (mx_type == EMSnonuniformTransformation ||
           mx_type == EMSuniformTransformation )
       {
         struct GRlc_info      lc_info;
         struct IGRbsp_surface *my_geom, *cp_geom;
         extern void           EFplane_xform_support();

         my_geom = cp_geom = NULL;
         lc_info.located_obj.objid = my_id;
         lc_info.located_obj.osnum = OM_Gw_current_OS;
         lc_info.module_info = *obj_mdenv; 

         sts = EMget_the_geometry( 
                  &lc_info,
                  FALSE,        /* Not a curve */
                  FALSE,        /* Not directed */
                  FALSE,        /* One large malloc is OK */
                  my_id,
                  &my_geom,
                  EMmsg);
         EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

         lc_info.module_info = *new_mdenv;
         lc_info.module_info.md_env.matrix_type = MAIDMX;
         status = MAidmx (&rc, lc_info.module_info.md_env.matrix);
         lc_info.located_obj.objid = *newobjid;
         lc_info.located_obj.osnum = new_mdenv->md_id.osnum;

         sts = EMget_the_geometry( 
                  &lc_info,
                  FALSE,        /* Not a curve */
                  FALSE,        /* Not directed */
                  FALSE,        /* One large malloc is OK */
                  *newobjid,
                  &cp_geom,
                  EMmsg);
         EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

         /*
          *  o For non_uniform scaling Reset the edge types to freeform.  
          *    Actually we should compute the actual types, but this 
          *    requires an undo amount of effort.
          * 
          *  o In case I have a cross hatch graphics data object,
          *    uniform/non_uniform transformation should result in:
          *      o Cross_hatch angle should remain unchanged.
          *      o Spacing should be scaled appropriately.
          */

         EFplane_xform_support (&rc, mx_type, *newobjid, 
                                new_mdenv->md_id.osnum, my_geom, 
                                cp_geom);
         EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

         if (my_geom) om$dealloc (ptr = my_geom);
         if (cp_geom) om$dealloc (ptr = cp_geom);

       } /* if (mx_type == EMSnonuniformTransformation ||
                mx_type == EMSuniformTransformation ) */

     } /* if (new_mdenv->md_env.matrix_type != MAIDMX) */

wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSplane.EMintcopy");
    return(OM_stat);
}

end implementation EMSplane;

