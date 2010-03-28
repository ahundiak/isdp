/* #######################    APOGEE COMPILED   ######################## */
class implementation COref;

#include "dpstruct.h"

struct dyn_args
{
  struct GRid         clone_clip;        /* Clone of clipping polygon */
  struct GRparms      clone_clip_parms;  /* Clone clippoly parameters */
  struct GRmd_env     mod_info;          /* Module information */
  IGRpoint            from_point;
};

from GRclippoly import GRmodify_height;
from GRgraphics import GRptproject;
from GRreffile  import GRcopy, GRdelete;

method dynamics(int dynamics; int *sts)
{
  struct GRid         clone_ref;         /* Clone of reference file */

  OM_S_CHANSELECT     chansel;           /* Channel object is on */
  OM_S_OBJECT_LINKAGE linkage;           /* Linkage for object on channel */

  IGRboolean          dyn_on;            /* Is dynamics on? */ 
  IGRboolean          inquire=1;         /* Inquire from DPdynflags */
  struct dyn_args     data;              /* Arguments */
  IGRuint             count;  
  IGRint              i;
  IGRlong             OMmsg = OM_S_SUCCESS;
  IGRlong             msg;

  IGRint DYrfclmod();


   /* 
    *  If dynamics are off then exit
    */

   DPdynflags(&msg, &inquire, &dyn_on, NULL); 
   if (!dyn_on)
     {
       return(MSSUCC);
     }
    
    data.mod_info = ME.COref->mod_info;

   /* 
    * Make a clone of the reference file attachment.
    */
   OMmsg = om$send (msg = message GRreffile.GRcopy(&msg,
                               &data.mod_info,
                               &data.mod_info,
                               &clone_ref.objid),
                    targetid = ME.COref->reffile.objid,
                    targetos = ME.COref->reffile.osnum,
                    senderid = NULL_OBJID);

    /*
     * Pull the clippoly of the reference attachment clone off of the channel.
     */
    chansel.type       = OM_e_name;
    chansel.u_sel.name = "GRreffile.to_clip";

    clone_ref.osnum = data.mod_info.md_id.osnum;

    OMmsg = om$get_channel_objects(osnum        = clone_ref.osnum,
                                   objid        = clone_ref.objid,
                                   p_chanselect = &chansel,
                                   list         = &linkage,
                                   size         = 1,
                                   count        = &count);

    data.clone_clip.osnum = linkage.osnum;
    data.clone_clip.objid = linkage.S_objid;

    /* 
     * Initialize remaining data structure for dynamics.
     */
   data.clone_clip_parms = ME.COref->clippoly_parms;
   for (i=0; i < 3; ++i) data.from_point[i] = ME.COref->from_point[i];

   /*
    * Call dp$dynamics.
    */
   dp$dynamics(dyn_fun = DYrfclmod, information = &data);

   /* 
    * Remove the clone of the reference file attachment
    */
   OMmsg = om$send (msg = message GRreffile.GRdelete(&msg,
                               &data.mod_info),
                    targetid = clone_ref.objid,
                    targetos = clone_ref.osnum,
                    senderid = NULL_OBJID);


   return(MSSUCC);
}

#argsused
extern IGRint DYrfclmod (dptr, point, mtx, objects, num_objects, buffers,
                         num_buffers, in_dummy1, in_dummy2, in_dummy3, 
                         out_dummy1, out_dummy2, out_dummy3)
struct dyn_args  	*dptr;
struct EX_button     	*point;
IGRdouble        	*mtx;
struct GRid            **objects;
IGRint			*num_objects;
struct DPele_header    **buffers;
IGRint 			*num_buffers;
IGRchar			*in_dummy1;
IGRchar			*in_dummy2;
IGRchar			*in_dummy3;
IGRchar		       **out_dummy1;
struct GRmdenv_info    **out_dummy2;
IGRchar		       **out_dummy3;


{
  struct IGRline    dyn_boreline;      /* Boreline "to" point */
  IGRpoint          pts[2];            /* Boreline points */
  IGRlong           OMmsg = OM_S_SUCCESS;
  IGRlong           msg;
  IGRpoint          tpoint;

  OMmsg = 1;

  tpoint[0] = point->x;
  tpoint[1] = point->y;
  tpoint[2] = point->z;

  /*
   * Construct the boreline
   */
  dyn_boreline.point1 = pts[0];
  dyn_boreline.point2 = pts[1];

  GRbrlnconstr(&msg, tpoint, mtx, &dyn_boreline);

  /* 
   * Modify the clipping polygon
   */
  OMmsg = om$send ( msg = message GRclippoly.GRmodify_height (&msg,
                               &dptr->mod_info,
                               &dptr->clone_clip_parms,
                                dptr->from_point,
                               &dyn_boreline),
                    targetid = dptr->clone_clip.objid,
                    targetos = dptr->clone_clip.osnum,
                    senderid = NULL_OBJID);

  /*
   * The current "to" point becomes the new "from" point, so
   * project it onto the prism.
   */
  OMmsg = om$send (msg = message GRgraphics.GRptproject(&msg,
                              &dptr->mod_info.md_env.matrix_type,
                               dptr->mod_info.md_env.matrix,
                               tpoint,
                               dptr->from_point,
                              &dptr->clone_clip_parms),
                   targetid = dptr->clone_clip.objid,
                   targetos = dptr->clone_clip.osnum,
                   senderid = NULL_OBJID);

  *num_buffers = 0;
  *buffers     = NULL;
  *objects     = &dptr->clone_clip;
  *num_objects = 1;

  return(MSSUCC);
}

end implementation COref;



