/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
#include "bs.h"                /* Has igr stuff plus bs codes and types */
#include "msdef.h"             /* Has MSFAIL */
#include "godef.h"             /* Has GRLN and GRCURVE */
#include "transdef.h"          /* Has GUBSBUF_SIZE */
#include "translate.h"
#include "transmacros.h"
#include "transerr.h"
#include "EMSsplitdef.h"       /* Has SPLIT_BOTH, SPLIT_U, SPLIT_V */
#include "EMSssprops.h"		   /* Has inactive bit defined */
#include "bsparameters.h"
#include "bserr.h"
#include "EMSfmtsf.h"
#include "EMSprop.h"
#include "OMmacros.h"


/*
 
Description
    This method writes a surface to the Envelope file as IGDS
    bspline surface shape. Before writing, it checks whether it
    overflows in terms of num_poles in u or v and the number of
    boundaries and points per boundary. If so, it breaks the 
    surface such that none of the resultant sub_surfaces overflow
    in terms of poles in u or v and in terms of boundarys/boundary_pts.

Histroy
    RC     05/24/89     Creation Date
    NP     08/26/92     Modified for ANSI compliance. Extern declaration of the
			function GUget_symb_level() was in the wrong block.
			Added required typecasts.
*/

method EMcreate_envelope_and_igds_files (
         IGRlong                *EMmsg; 
         struct GRmd_env        *md_env;
         IGRdouble              *scale_factor; 
         struct GUcvt_bufs      *cvt_buffers;
         IGRlong                *IGDS_filedesc; 
         IGRdouble              *max_abs_overflow;
         IGRint                 *cmpnt_tag; 
         IGRboolean             is_tag_good; 
         IGRdouble              *file_ige_range;
         IGRint                 *num_processed_ids, *processed_ids_arrsz;
         GRobjid                **processed_ids)
{
 struct IGRbsp_surface *sf_geom = NULL, **res_sfs_geom = NULL;
 struct GRmd_env       new_env;
 struct GRid           act_st_GRid;
 struct GRsymbology    symbology;
 struct GRprops        geom_props;
 struct IGResbs        attributes;
 GRname                my_name;
 extern  IGRlong       GUget_symb_level();

 IGRmatrix             scale_mat;
 IGRlong               OM_stat, mthd_stat, sf_size, rc;
 IGRint                num_res_sfs = 0, sf_inx, i, j;
 IGRshort              four = 4;

 IGRboolean            is_sf_split = FALSE, status, my_act_st_processed, 
                       has_name;

 extern void           EFbreak_sf_to_avoid_IGDS_overflow(), 
                       EFwrite_sf_to_envelope_and_IGDS_files(),
                       EFwrite_component_to_envelope_file(),
                       EFmemory_allocation();
 extern IGRboolean     MAmulmx(), MAtypemx();

 
 /* ************************************************************* */

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

/*
{
   IGRlong dlb_loc_msg, OM_stat;
   IGRboolean did_set_inactive;
   OM_stat = om$send(msg = message EMSsubbs.EMset_inactive(
                           &dlb_loc_msg, &did_set_inactive),
                     targetid = my_id);
 }
*/

 if (me->ss_props & EMSIS_INACTIVE) goto wrapup;

 /*
  * o If the incoming cmpnt_tag is not good, I have been sent
  *   this message from Rtree. 
  * o Get my active state id.
  * o Check if my active state has already been processed or not.
  *   o If processed, return
  *     o else,
  *      o Write active state as the component to Envelope file.
  *      o Send the message to the active state with valid tag_id.
  */

 if (!is_tag_good)
 {
   OM_stat = om$send (msg = message EMSsurface.EMgetactiveid (&mthd_stat,
                       &act_st_GRid, NULL),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

   my_act_st_processed = FALSE;
   if (*num_processed_ids)
   {
    for (i = 0; i < *num_processed_ids; i++)
    {
     if ((*processed_ids)[i] == act_st_GRid.objid)
     {
      my_act_st_processed = TRUE;   break;

     }
    } /* for (i = 0; i < *num_processed_ids; i++) */

   } /* if (*num_processed_ids) */
  
   if (!my_act_st_processed)
   {
    EFwrite_component_to_envelope_file (&rc, act_st_GRid.objid, 
      act_st_GRid.osnum, md_env, cmpnt_tag, scale_factor, file_ige_range);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    OM_stat = om$send (msg = 
                   message EMSsurface.EMcreate_envelope_and_igds_files (
                        &mthd_stat, md_env, scale_factor, cvt_buffers, 
                        IGDS_filedesc, max_abs_overflow, cmpnt_tag,
                        TRUE, file_ige_range, num_processed_ids,
                        processed_ids_arrsz, processed_ids),
                       targetid = act_st_GRid.objid); 
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_SurfaceError,wrapup);

    if (*processed_ids_arrsz < (*num_processed_ids + 1))
    {
      EFmemory_allocation (&rc, (IGRchar **) processed_ids,
          *num_processed_ids+1, processed_ids_arrsz, sizeof(GRobjid),
          10, 10);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

    } /* if (*act_st_processed_arrsz < (*num_act_st_processed + 1)) */

    (*processed_ids)[(*num_processed_ids)++] = act_st_GRid.objid;

   } /* if (!my_act_st_processed) */

 } /* if (!is_tag_good) */
 else
 {
  /* 
   * Generate new matrix with the scale factor
   */

  for(i=0; i<16; i++) scale_mat[i] = 0.0;
  scale_mat[0] = scale_mat[5] = scale_mat[10] = *scale_factor;
  scale_mat[15] = 1.0;

  new_env = *md_env;

  status = MAmulmx(&rc, &four, &four, &four, scale_mat, 
                   md_env->md_env.matrix, new_env.md_env.matrix);
  EMerr_hndlr (!status || !(1&rc), *EMmsg, EMS_E_BSerror, wrapup);

  status = MAtypemx(&rc, new_env.md_env.matrix, 
                    &new_env.md_env.matrix_type);
  EMerr_hndlr (!status || !(1&rc), *EMmsg, EMS_E_BSerror, wrapup);

  /* 
   * Hereafter use new_env instead of md_env.
   */

  {
   /*
    * Check IGDS overflow
    */
  
   GRrange             range;
   IGRlong             num_values = 6;
   IGRboolean          world = TRUE, no_overflow;
   extern  IGRboolean  GUcheck_overflow();

   OM_stat = om$send( msg = message GRvg.GRgetrang(&mthd_stat,
                      &new_env.md_env.matrix_type, new_env.md_env.matrix,
                      &world, range),
                     targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_SurfaceError,wrapup);

   no_overflow = GUcheck_overflow (&rc, &num_values, range, 
                                   max_abs_overflow);
   if (!no_overflow || !(1 & rc) ) goto wrapup;
 }

 /*
  * Get the symbology of this surface
  */

 OM_stat = om$send( msg = message GRvg.GRgetsymb( &mthd_stat, &symbology),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

/*
 * Call to support alternative symbology/level mapping.
 */

OM_stat = GUget_symb_level(&rc, &symbology);
if (! (1 & OM_stat)) goto wrapup;

 /*
  * Call the complex handler to determine whether to continue formatting
  * this object.
  */
/*
 {
    struct GRid        my_GRid;
    IGRchar            IGDSclass = 0;
    IGRboolean         format, mark_as_cpx, cpx_calling = FALSE;
    extern IGRboolean  GUcpxhandler();

    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;

    if(! GUcpxhandler(&rc, &cpx_calling, md_env, cvt_buffers->dgn_buf, 
                      cvt_buffers->bs_buf, cvt_buffers->ele_buf, 
                      &cvt_buffers->ele_size, IGDS_filedesc, 
                      max_abs_overflow,
                      scale_factor, &IGDSclass, &me->properties,
                      &symbology.level, &my_GRid, &format, &mark_as_cpx))
    {
      *EMmsg = MSSUCC;          
      goto wrapup;
    }
    if(! format) goto wrapup;
  }

*/

  /*
   * Get the element specific attributes of this surface
   */
 
  OM_stat = om$send ( msg = message GRvg.GRgetattr( &mthd_stat,
                       (IGRchar *)&attributes),
                      targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);
  attributes.type = 0;

  /* 
   * Get the element name if any.
   */

  OM_stat = om$send(msg = message GRvg.GRgetname (&mthd_stat, my_name),
                    targetid = my_id);
  has_name = 1 & mthd_stat;

  /*
   * Get the geometric properties of this surface
   */

  OM_stat = om$send (msg = message GRvg.GRgeomprops( &mthd_stat,
                      &new_env.md_env.matrix_type,
                      new_env.md_env.matrix, &geom_props),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);

  /*
   *
   * o Get my geometry.
   * o Break myself if either my geometry or topology is overflowing
   *   IGDS limit.
   * o For each of the resultant surfaces,
   *   o Convert it to IGDS format.
   *   o Write the surface patch as a bspline shape.
   */

  OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat, 
                      &new_env.md_env.matrix_type, new_env.md_env.matrix,
                      &sf_size),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_SurfaceError, wrapup);

  if (sf_size > GUBSBUF_SIZE)
  {
   sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
   EMerr_hndlr (!sf_geom, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
  else
   sf_geom = (struct IGRbsp_surface *) cvt_buffers->bs_buf;

  OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat, 
                      &new_env.md_env.matrix_type, new_env.md_env.matrix,
                      (IGRchar *) sf_geom),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_SurfaceError, wrapup);

  /*
   * Break the surface such that neither its geometry (poles) nor
   * nor its boundaries (num_pts_per_boundary or num_boundaries)
   * overflow IGDS limits.
   */

  EFbreak_sf_to_avoid_IGDS_overflow (&rc, my_id, OM_Gw_current_OS, 
           &sf_geom, &new_env, scale_factor, &is_sf_split, &num_res_sfs, 
           &res_sfs_geom);
  EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * For each of the resultant subsurfaces,
   *  o Convert it to IGDS format.
   *  o Write IGDS converted surface as a bspline shape to the 
   *    Envelope file.
   */

  for (sf_inx = 0; sf_inx < num_res_sfs; sf_inx++)
  {
   if (res_sfs_geom[sf_inx])
   {
    /*
     * Write sf to envelope and IGDS files
     */

     EFwrite_sf_to_envelope_and_IGDS_files(&rc, res_sfs_geom[sf_inx],
                  IGDS_filedesc, cvt_buffers, "EMSsubbs", &symbology,
                  &geom_props, &me->properties, &attributes, &has_name,
                  my_name, *cmpnt_tag);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   } /* if (res_sfs_geom[sf_inx]) */

  } /* for (sf_inx = 0; sf_inx < num_res_sfs; sf_inx++) */

 } /* else for if (!is_tag_good) */

 wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "EMSsubbs.EMwrite_to_envelope_file");

  if (sf_geom)
  {
   if (sf_geom->bdrys) 
   {
     for (i = 0; i < sf_geom->num_boundaries; i++)
     {
       if (sf_geom->bdrys[i].points) free (sf_geom->bdrys[i].points);
     }
     free(sf_geom->bdrys);
   } 
   if (sf_geom != (struct IGRbsp_surface *)cvt_buffers->bs_buf) free(sf_geom);

  } /* if (sf_geom) */

  if (is_sf_split)
  {
   if (res_sfs_geom)
   {
    for (i = 0; i < num_res_sfs; i++)
    {
      if (res_sfs_geom[i]) 
      {
       extern  IGRboolean  BSfreesf();
       IGRboolean       bsrc, status;

       if (res_sfs_geom[i]->num_boundaries)
       {
        for (j = 0; j < res_sfs_geom[i]->num_boundaries; j++)
          if (res_sfs_geom[i]->bdrys[j].points)
            free (res_sfs_geom[i]->bdrys[j].points);

        free (res_sfs_geom[i]->bdrys);
        res_sfs_geom[i]->num_boundaries = 0;
        res_sfs_geom[i]->bdrys = NULL;

       } /* if (res_sfs_geom[i]->num_boundaries) */

       status = BSfreesf(&bsrc, res_sfs_geom[i]);

      } /* if (res_sfs_geom[i]) */

    } /* for (i = 0; i < num_res_sfs; i++) */

    free (res_sfs_geom);

   } /* if (res_sfs_geom) */

  } /* if (is_sf_split) */

  /*
   * Always return success whether or not it is honest
   */

  *EMmsg = EMS_S_Success;
  return (OM_S_SUCCESS);

}

end implementation EMSsubbs;

