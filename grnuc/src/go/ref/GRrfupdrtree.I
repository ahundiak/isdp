class implementation GRreffile;

#include "grimport.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "ref.h"
#include "refdef.h"
#include "referr.h"
#include "msdef.h"
#include "msmacros.h"

/*
   Name

       GRrfupdrtree

   Abstract

       This method will update the range of the reference file in the R-tree.
     The new range will be computed from the reference file object space.
     Then it will adjust the clipping polygon with the new range.

   Arguments
 
      IGRlong    *msg        completion code   
      struct GRmd_env *msg   object's module environment 

   Return values

      -MSSUCC if successful
      -MSFAIL if failure

   History

      Gang     05/28/93    Design date.

*/

from GRclippoly import GRcpupdrtree;

method GRrfupdrtree( IGRlong *msg; struct GRmd_env *md_env) 
{
  IGRint sts;
  IGRint i,j;
  IGRdouble ref_range[6];
  IGRdouble range[6];
  IGRdouble master_range[6];
  IGRdouble pass_range[6];
  struct GRid ref_id;
  struct GRmd_env ref_env;
  OM_S_CHANSELECT clip_chan;
  struct IGRlbsys lbsys;
  struct IGRcv_prism curve_prism;
  struct IGRcv_prism trans_cp;
  IGRdouble points[30];
  IGRdouble knots[12];
  IGRint dimension;
  GRspacenum osnum;
  

      sts = 0;
      i = 0;
      j = 0;
      dimension = 0;
      clip_chan.type = OM_e_addr;
      clip_chan.u_sel.addr = &me->to_clip;

      /* check to be sure the file is attached */
      dimension = om$dimension_of(varray = me->filename);
      sts = om$os_name_to_number(osname = me->osname, p_osnum = &osnum);

      if(!(dimension && (sts & 1)))
       {
          return(OM_S_SUCCESS);
       }

      /* check to be sure that this is not a background attachment */

      if((me->ref_properties & GRRF_BACKGROUND) &&
	 (OM_Gw_current_OS != EX_active_OS_num))
       {
	  return(OM_S_SUCCESS);
       }

      /* Remove the reference file object from the R-tree */

      sts  = om$send(msg = message GRvg.GRremwrng(msg, md_env),
                    senderid = my_id,
                    targetid = my_id);

      if(!(sts & *msg & 1))
       {
	 return (OM_S_SUCCESS);
       }

      /* Get the module environment of the reference file */

      sts = om$send( msg = message GRreffile.GRgetenvironment(msg,md_env,
                                                              &ref_env),
                     senderid = my_id,
                     targetid = my_id);

      if(!(sts & *msg & 1))
       {
	 return (OM_S_SUCCESS);
       }

      /* Compute the range from the R-tree in the refrence file object space */

      ref_id.objid = my_id;
      ref_id.osnum = md_env->md_id.osnum;

      GRgetreffilerng( msg, &ref_env, ref_range);
  
      if(!(*msg & 1))
       {
	 return (OM_S_SUCCESS);
       }

      /* To get the vw_volume convert the range to view coordinates */

      j = 2;

      MAptsxform(msg, &j, me->vw_rotation, ref_range, me->vw_volume);

      if(!(*msg & 1))
       {
	 return(OM_S_SUCCESS);
       }

      j = 2;

      MAptsxform(msg, &j, me->ref_to_master_matrix, ref_range, range);
 
      if(!(*msg & 1))
       {
	 return(OM_S_SUCCESS);
       }

      for(i =0; i < 3 ; i++)
       {
         lbsys.diag_pt1[i] = ref_range[i];
         lbsys.diag_pt2[i] = ref_range[i+3];
       }

      for(i=0; i < 16; i++)
         lbsys.matrix[i] = me->ref_to_master_matrix[i];

      /* load the pointers for the clip function */

      curve_prism.curve.poles = points;
      curve_prism.curve.weights = 0;
      curve_prism.curve.knots = knots;

      /* call routine to form curve prism from local bounded system */

      MAcpfrlb(msg, &lbsys, &curve_prism);

      if(!(*msg & 1))
       {
	 return(OM_S_SUCCESS);
       }

      /* get the range to be added to the Rtree */

      MAcpextents(msg, &curve_prism, &master_range[0], &master_range[3]);

      if(!(*msg & 1))
       {
	 return(OM_S_SUCCESS);
       }

      /* Send the GRcpupdrtree message to the clipping polygon */

      sts = om$send(msg = message GRclippoly.GRcpupdrtree(msg, master_range,
                                                          &curve_prism,
                                                          md_env,FALSE),
                    senderid = my_id,
                    p_chanselect = &clip_chan);


      /* load the pointers for the clip function */

      trans_cp.curve.poles = points;
      trans_cp.curve.weights = 0;
      trans_cp.curve.knots = knots;

      MAcpxform(msg, &curve_prism, me->master_to_ref_matrix, &trans_cp);

      MAcpextents(msg, &trans_cp, &pass_range[0], &pass_range[3]);

      /* Fill the reference file pass range */

      for(i=0; i < 6; i++)
        {
          me->range[i] = pass_range[i];
        }

      /* Mark the attachment that Shrink/Wrap is applied  */

      me->ref_properties = me->ref_properties | GRRF_SHRINK_WRAP;

      /* Add the reference file object to the R-tree with the new range */

      GRowneradd(msg, md_env, &my_id, &ref_id.osnum, master_range);

  return(sts);

}

end implementation GRreffile;
