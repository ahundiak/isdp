/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
/*
History
        RC      ??              Creation date.
        SM      10-Oct-87       changed due to argument change in 
                                EMget_loops_for_inposition();
        RC      11/2/87         Modified for version 1.1.0
                                Also added code make natural boundary
                                if one does not exists
        SM      28-Mar-89       Argument change in 
                                EMget_loops_for_imposition. Function 
                                renamed as EMget_mapped_data().
        RC      02/22/90        Modification for feature loop update.
        NP      08/25/92	Modified for ANSI compliance. Added typecasts.
   
*/

# include <stdio.h>
# include "emsdef.h"
# include "emsmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "emsinter.h" 
# include "bsparameters.h"
# include "bstypes.h"
# include "bserr.h"
# include "emsimpdef.h"
# include "emsmapdef.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "emssfint.h"      /* EMSsfintedpar    */
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

from EMSloopset import EMsplityourself, EMget_loops, EMget_props;
from EMSloop    import EMget_props, EMtrimyourself, EMextractyourself;

extern OMuword OPP_EMSplane_class_id;

extern IGRboolean WANT_POST220_BEHAVIOR;

method EMget_split_areas (
        IGRlong                         *EMmsg;
        struct  GRmd_env                *my_env;
        IGRlong                         num_of_objects;
        struct  GRlc_info               object_info[];
        IGRlong                         *num_of_bad_points;
        IGRpoint                        **bad_points;
        IGRboolean                      want_bad_curves;
        IGRlong                         *num_of_bad_curves;
        IGRlong                         bad_curve_indices[];
        IGRint                          *num_imp_loops;
        GRobjid                         **imp_loop_ids;
        struct  EMSsfintedpar           ***trim_info;
        IGRint                          *num_spltyr_entries;
        struct  EMSownercomp            **sf_loops_removed;
        IGRint                          *num_new_loops_created;
        GRobjid                         **new_loops_created;
        IGRboolean                      want_status_message)

/*
 Notes
        Given a surface and the a set of objects, it
        splits the surface into areas using the objects
        as boundaries.

History  RC     05/01/87        Creation Date

*/

{

IGRboolean              is_ls_natural, status, trim_loop, world_flag;
IGRlong                 OM_stat, mthd_stat, num_bytes = 0;
GRobjid                 *loopids = NULL, *trim_lps = NULL, *trim_lps_ptr= NULL;
IGRint                  BUF_INC, BUF_SIZE, extyr_buf_size, i, j, k,
                        *num_bdrys = NULL, num_loops = 0, num_sfs = 0,
                        spltyr_buf_size, trmyr_buf_size;
IGRuint			chan_count;
IGRushort       	lp_props, options, split_options, ls_props;
OMuword                 my_classid;
struct  IGRbsp_surface  *srf_geom = NULL;
struct  EMSpartolbasis   partolbasis;
OM_S_OBJECT_LINKAGE ls_id;
struct  EMSsfintedpar   **against_bdrys = NULL, *EMsfintedpar_malloc(),
                        **lp_bdrys = NULL, **trim_info_ptr = NULL,
                        **out_bdrys = NULL;
OM_S_CHANSELECT         sf_ls_chan;
extern void                    EMsfintedpar_free();
struct  GRid            clip_ls;


OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

(*imp_loop_ids) = NULL;

*num_of_bad_points = 0;
*num_of_bad_curves = 0;
*num_imp_loops = 0;
*num_spltyr_entries = 0;
*num_new_loops_created = 0;

sf_ls_chan.type = OM_e_addr;
sf_ls_chan.u_sel.addr = &ME.EMSsubbs->to_loopset;

OM_stat = om$get_channel_objects (object = me,
                        p_chanselect = &sf_ls_chan,
                        list = &ls_id,
                        size = 1,
                        count = &chan_count);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
EMerr_hndlr ((chan_count != 1),*EMmsg,EMS_E_ChanCountNot1,wrapup);

/*
 * get my surface geometry
 */

OM_stat = om$send(mode = OM_e_wrt_object,
               msg = message GRvg.GRgetsize(
                &mthd_stat, &my_env->md_env.matrix_type, 
                my_env->md_env.matrix, &num_bytes),
         targetid = my_id);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

srf_geom = (struct IGRbsp_surface *) om$malloc (size = num_bytes);
EMerr_hndlr(!srf_geom,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

OM_stat = om$send(mode = OM_e_wrt_object,
               msg = message GRvg.GRgetgeom( &mthd_stat,
                &my_env->md_env.matrix_type, my_env->md_env.matrix, 
                (IGRchar *) srf_geom), targetid = my_id);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

/*
 * get the parametric tolerance for the surface
 */

world_flag = TRUE;

OM_stat = om$send (msg = message EMSsubbs.EMpartolbasis ( &mthd_stat,
                    &my_env->md_env.matrix_type, my_env->md_env.matrix,
                    &world_flag, FALSE, &partolbasis.tol),
                  targetid = my_id);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
 

/*
 * convert the incoming objects into valid loops to
 * be used for spliting the loopset of the surface
 */

clip_ls.objid = NULL_OBJID;
options = NULL | EMMapBnd_StrokeIfNeeded | EMMapBnd_NoValidate |
          ( (want_status_message) ? EMMapBnd_WantStatMsg : NULL) |
          ( (want_bad_curves) ? EMMapBnd_WantBadCurves : NULL);

OM_stat = om$get_classid (object = me, p_classid = &my_classid);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = om$is_ancestry_valid (subclassid = my_classid,
                                 superclassid = OPP_EMSplane_class_id);
if (OM_stat == OM_S_SUCCESS) options |= EMMapBnd_SurfIsPlane;

{
 struct EMSgetlp_output		junk;
 struct EMSgetlp_badcrvinfo	badcrv;
 struct IGRpolyline		badpts;

 badcrv.bad_indices = bad_curve_indices;
 badcrv.num = 0;
 badpts.num_points = 0;
 junk.num_objs = 0;
 junk.objs = NULL;

 status = EMget_mapped_data(
                num_of_objects,
                NULL, 
                object_info,
                NULL, 
                srf_geom,
                &partolbasis.tol,
                my_env,
                num_of_bad_curves && bad_curve_indices ? &badcrv : NULL,
                num_of_bad_points && bad_points ? &badpts : NULL,
                &junk, 
                NULL, 
                clip_ls, 
                options, 
                NULL, 
               &mthd_stat);
 
 *imp_loop_ids = junk.objs;
 *num_imp_loops = junk.num_objs;
 if(num_of_bad_curves) *num_of_bad_curves = badcrv.num;
 if(num_of_bad_points) *num_of_bad_points = badpts.num_points;
 if(bad_points) *bad_points = (IGRpoint *) badpts.points;

 EMerr_hndlr ((!status || !(1&mthd_stat)), *EMmsg, EMS_E_Fail,wrapup);
}

if (! (*num_imp_loops))
{
   fprintf (stderr, "No valid boundaries to impose \n");
   *EMmsg = EMS_E_NoValidBnd;
   goto wrapup;
}

/*
 * split the loopset of the surface using the loops
 * obtained above. Once the loopset is split,
 * the areas obtained (old ones that are uneffected
 * and new creations) are returned to the caller.
 */

partolbasis.in_world = TRUE;
partolbasis.is_valid = TRUE;
partolbasis.mattyp = &my_env->md_env.matrix_type;
partolbasis.mat = my_env->md_env.matrix;

/*
 * Since The loops obtained from the EMget_mapped_data
 * have to be saved for further processing and loopset
 * splityourself does not keep them, it is needed to
 * to trim the loops here only.
 *
 * Since, trimming is expensive, a trivial check is made 
 * to decide whether trimming for a loop is really needed or not.
 * This trivial test is as follows:
 *
 * Assuming that loops returned by EMget_mapped_data
 * are not self intersecting (which is true), if the loopset
 * under consideration is a natural loopset and the 
 * loop under consideration is a closed loop, there is no need to
 * send it for trimming as it will not be trimmed any way.
 */

OM_stat = om$send (msg = message EMSloopset.EMget_props (
                       &mthd_stat, &ls_props),
                     targetid = ls_id.S_objid, targetos = ls_id.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

is_ls_natural = (ls_props & EMLS_NATURAL) ? TRUE : FALSE;

/*
 * allocate memory for trimming process
 */

BUF_SIZE = (*num_imp_loops) * 3;
BUF_INC = *num_imp_loops;

trmyr_buf_size = BUF_SIZE;
   
against_bdrys = (struct EMSsfintedpar **) om$malloc(size = 
                (trmyr_buf_size * sizeof(struct EMSsfintedpar *)));
EMerr_hndlr(!against_bdrys,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

lp_bdrys = (struct EMSsfintedpar **) om$malloc(size = 
             (trmyr_buf_size * sizeof(struct EMSsfintedpar *)));
EMerr_hndlr(!lp_bdrys,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

loopids = (GRobjid *) om$malloc (size = (trmyr_buf_size * 
                                sizeof(GRobjid)));
EMerr_hndlr(!loopids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

num_bdrys = (IGRint *) om$malloc (size = (trmyr_buf_size *
                        sizeof(IGRint)));
EMerr_hndlr(!num_bdrys,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

/*
 * allocate memory for extract
 */

extyr_buf_size = BUF_SIZE;

out_bdrys = (struct EMSsfintedpar **) om$malloc(size = 
                (extyr_buf_size * sizeof(struct EMSsfintedpar *)));
EMerr_hndlr(!out_bdrys,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

/* 
 *allocate memory to be used by extractyourself and splityourself
 */

spltyr_buf_size = BUF_SIZE;
*num_spltyr_entries = 0;
*trim_info = (struct EMSsfintedpar **) om$malloc (size = 
                (spltyr_buf_size * sizeof(struct EMSsfintedpar *)));
EMerr_hndlr(!(*trim_info),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

trim_lps = (GRobjid *) om$malloc (size = (spltyr_buf_size * 
                                        sizeof(GRobjid)));
EMerr_hndlr(!trim_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

for ( i = 0; i < *num_imp_loops; i++)
{
  trim_loop = TRUE;

  if (!WANT_POST220_BEHAVIOR && is_ls_natural)
  {
     /*
      * check if the loop is a closed loop or not ?
      */
        
     OM_stat = om$send (msg = message EMSloop.EMget_props(
                         &mthd_stat, &lp_props),
                        targetid = (*imp_loop_ids)[i]);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

     if (!(lp_props & EMLP_OPEN))
     {
       trim_loop = FALSE;

       if (!(*num_spltyr_entries < spltyr_buf_size))
       {
          spltyr_buf_size += BUF_INC;
          trim_lps = (GRobjid *) om$realloc(ptr = (IGRchar *)trim_lps,
                        size = spltyr_buf_size * sizeof(struct GRid));
          EMerr_hndlr(!trim_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

          *trim_info = (struct EMSsfintedpar **) om$realloc(
                   ptr = (IGRchar *)*trim_info, size = spltyr_buf_size * 
                        sizeof(struct EMSsfintedpar *));

          EMerr_hndlr(!trim_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

       } /* if (!(*num_spltyr_entries < spltyr_buf_size)) */

       trim_lps[*num_spltyr_entries] = (*imp_loop_ids)[i];

       (*trim_info)[*num_spltyr_entries]  = (struct EMSsfintedpar *) 
                 om$malloc (size = sizeof(struct EMSsfintedpar));
       EMerr_hndlr (!(*trim_info)[*num_spltyr_entries], *EMmsg,
                        EMS_E_NoDynamicMemory,wrapup);

       (*trim_info)[*num_spltyr_entries]->edgeid = NULL_OBJID;
       (*trim_info)[*num_spltyr_entries]->next = NULL;
       (*num_spltyr_entries)++;

     } /* if (!(lp_props & EMLP_OPEN)) */
                
  } /* if (is_ls_natural) */
        
  if (trim_loop)
  {
    num_loops = 0;

    OM_stat = om$send (msg = message EMSloop.EMtrimyourself(
                                        &mthd_stat,
                                        &(ls_id.S_objid),
                                        NULL,
                                        &against_bdrys,
                                        &lp_bdrys,
                                        &loopids,
                                        &num_loops,
                                        &num_bdrys,
                                        &trmyr_buf_size,
                                        &partolbasis),
                                targetid = (*imp_loop_ids)[i]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        
    for (j = 0; j < num_loops; j++)
    {
     if(!num_bdrys[j]) continue;

      /*
       * check if memory will be avaialable for extracting
       */

      if ( (*num_spltyr_entries + num_bdrys[j]) > spltyr_buf_size)
      {
         spltyr_buf_size = *num_spltyr_entries + num_bdrys[j];
         trim_lps = (GRobjid *) om$realloc (ptr = (IGRchar *)trim_lps,
                        size = spltyr_buf_size * sizeof(struct GRid));
         EMerr_hndlr(!trim_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

         *trim_info = (struct EMSsfintedpar **) om$realloc (
                       ptr = (IGRchar *)*trim_info, size = spltyr_buf_size * 
                         sizeof(struct EMSsfintedpar *));

         EMerr_hndlr (!(*trim_info),*EMmsg,EMS_E_NoDynamicMemory, wrapup);

      } /* if ( (*num_spltyr_entries + num_bdrys[j]) > spltyr_buf_size) */
                
      trim_info_ptr = &((*trim_info)[*num_spltyr_entries]);
      trim_lps_ptr = &trim_lps[*num_spltyr_entries];

      OM_stat = om$send (msg = message EMSloop.EMextractyourself
                                (&mthd_stat,
                                 lp_bdrys[j],
                                 against_bdrys[j],
                                 num_bdrys[j],
                                &trim_lps_ptr,
                                &out_bdrys,
                                &trim_info_ptr,
                                TRUE,
                                EMImpBnd_NoInputDelete,
                                &partolbasis),
                        targetid = loopids[j]);

       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

       *num_spltyr_entries += num_bdrys[j];
                
       /*
        * deallocate the space for out_bdrys link list.
        */

       for (k = 0; k < num_bdrys[j]; k++)
       {
           EMsfintedpar_free(out_bdrys[k],2);
           out_bdrys[k] = NULL;
        }

    } /* for (j = 0; j < num_loops; j++) */

        
  } /* if (trim_loop) */

  trmyr_buf_size += num_loops;

} /* for ( i = 0; i < *num_imp_loops; i++) */

if (want_status_message) ex$message(msgnumb = EMS_S_SplittingArea)

split_options = EMImpBnd_CloseRegular | EMImpBnd_CloseReverse |
		(want_status_message ? EMImpBnd_WantStatMsg : NULL) |
		EMImpBnd_SplitTopology | EMImpBnd_NoDummyEdges | 
        EMImpBnd_NoFeatureUpdate;

if ( (*num_spltyr_entries) )
{
		
  OM_stat = om$send (msg = message EMSloopset.EMsplityourself(
                        &mthd_stat,
                         trim_lps,
                         *num_spltyr_entries,
                         *trim_info,
                         NULL,
                         NULL,
                         new_loops_created,
                         num_new_loops_created,
                         split_options,
                        &num_sfs,
                        sf_loops_removed,
                        &partolbasis,
                        my_env),
                 senderid = my_id,
                 p_chanselect = &sf_ls_chan);

  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
}
else
{  *EMmsg = EMS_E_NoTrimBnd;
   goto wrapup;
}

wrapup:

    EMWRAPUP (*EMmsg,OM_stat,"In EMSsubbs.EMget_split_areas");

    if (srf_geom) om$dealloc (ptr = srf_geom);
    if (against_bdrys) om$dealloc (ptr = against_bdrys);
    if (lp_bdrys) om$dealloc (ptr = lp_bdrys);
    if (loopids) om$dealloc (ptr = loopids);
    if (num_bdrys) om$dealloc (ptr = num_bdrys);
    if (out_bdrys) om$dealloc (ptr = out_bdrys);
    if (trim_lps) om$dealloc (ptr = trim_lps);

    return (OM_stat);

}
end implementation EMSsubbs;
