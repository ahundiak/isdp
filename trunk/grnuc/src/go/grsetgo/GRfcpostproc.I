/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSpost_processing 

Description
   This method is used to copy and clip the elements overlapping the
   fence.

   *msg         IGRlong        return code
   *target_env  GRmd_env       Environment to copy objects to.
   *owner_id    GRid           Owner object.
   copy_flag    IGRint         Flag if 1 then copy and post process.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    01/09/87    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgs.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "go.h"

from GRgsmgr      import   GRpre_clip;
from GRsvset      import   GSsvinit;

extern IGRint GRclip_function();

method GSpost_processing (IGRlong *msg; struct GRmd_env *target_env; 
                          struct GRid *owner_id; IGRint copy_flag)
{
IGRlong                 om_msg;
IGRlong                 ret_msg;
IGRint                  i;
unsigned int            count;
IGRint                  temp_count;
IGRlong                 clip_flag;
IGRshort                fence_flag;
OM_S_CHANSELECT         to_sets_chansel;
OM_S_CHANSELECT         overlap_chansel;
OM_S_CHANSELECT         fence_chansel;
struct GRid             sv_id1;        /* Connected to the fence set    */
struct GRid             *inside_id;    /* Object id of inside save set  */
struct GRid             *outside_id;   /* Object id of inside save set  */
struct GRid             my_GRid;
struct GRobj_env        obj_env;
struct GRclip_args      clip_args;
struct GRmd_env         temp_env;
struct IGRrt_prism      rp;
struct IGRcv_prism      cp;
struct GRfunction_info  function_info;

   *msg = MSSUCC;

   if (!(me->properties & GRIS_POST_PROCESSING))
   {
      return(OM_S_SUCCESS);
   }

   om_msg = 1;
   ret_msg = 1;
   to_sets_chansel.type = OM_e_name;
   to_sets_chansel.u_sel.name = "GRgrset.to_sets";
   overlap_chansel.type = OM_e_name;
   overlap_chansel.u_sel.name = "GRfcset.clip_overlap";
   fence_chansel.type = OM_e_name;
   fence_chansel.u_sel.name = "GRcmpowner.to_components";
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

   /* 
    *  Do not connect to the complex channel;
    *  Do not delete the original;
    *  Add overlap to the outside;
    *  Clip using the right prism.
    *  Do not perform a range check on the elements.
    *  Perform a flexible connection with override.
    */

   clip_flag = GR_CLIP_NODEL  | GR_CLIP_NORGCK |
               GR_CLIP_FLEXCONN;

   if (!copy_flag)
   {
      /*
       *  Delete the original copy.
       */

      clip_flag &= (0xffffffff ^ GR_CLIP_NODEL);
   }
   
   if (me->properties & GRIS_INSIDE)
   {
      inside_id = &sv_id1;
      outside_id = NULL;
      fence_flag = GRFN_CLIP_INSIDE;
      if (!copy_flag)
      {
         clip_flag |= GR_CLIP_CONSTR_ALL_PIECES;
      }
	  clip_flag |= GR_CLIP_OVL_IN;
   }else if (me->properties & GRIS_OUTSIDE)
   {
      inside_id = NULL;
      outside_id = &sv_id1;
      fence_flag = GRFN_CLIP_OUTSIDE;
      if (!copy_flag)
      {
         clip_flag |= GR_CLIP_CONSTR_ALL_PIECES;
      }
	  clip_flag |= GR_CLIP_OVL_OUT;
   }else
   {
      *msg = MSFAIL;
      return (OM_E_ABORT);
   }

   if (copy_flag)
   {
      /*
       *  Copy the elements on the members channel. 
       */

      om_msg = om$send (mode = OM_e_wrt_message,
               msg = message GRgrset.GScopy(&ret_msg, target_env, NULL,
               owner_id), targetid = my_id);

      if (! (om_msg & ret_msg & 1) )
      {
         *msg = MSFAIL;
         return (OM_E_ABORT);
      }
   }

   /*
    *  Calculate the right prism size.
    */

   if (me->prism_type == GR_RIGHT_PRISM)
   {   
      /* 
       *  Format the right prism geometry 
       */

      clip_flag |= GR_CLIP_RTPRISM;
      rp.height = me->prism_height;
      rp.polygon.num_points = me->prism_num_poles;
      rp.polygon.points = me->prism_poles;

      for (i=0; i<16; ++i)
      {
         rp.matrix[i] = me->prism_matrix[i];
      }
   }else
   {
      /* 
       *  Format the curve prism geometry.
       */

      cp.height = me->prism_height;
      cp.curve.num_poles = me->prism_num_poles;
      cp.curve.order = me->prism_curve_order;
      cp.curve.periodic = me->prism_curve_periodic;
      cp.curve.non_uniform = me->prism_curve_non_uniform;
      cp.curve.num_knots = me->prism_curve_num_knots;
      cp.curve.rational = me->prism_curve_rational;
      cp.curve.planar = me->prism_curve_planar;
      cp.curve.phy_closed = me->prism_curve_phy_closed;
      cp.curve.num_boundaries = me->prism_curve_num_boundaries;
      for (i=0; i<16; ++i) 
      {
         cp.matrix[i] = me->prism_matrix[i];
      } 

      cp.curve.poles = me->prism_poles;
      if (cp.curve.rational)
      {
         cp.curve.weights = me->prism_curve_weights;
      }

      if (cp.curve.num_knots)
      {
         cp.curve.knots = me->prism_curve_knots;
      }

      if (cp.curve.num_boundaries)
      {
         cp.curve.bdrys = me->prism_curve_bdrys;
      }
   }

   if (om_msg & ret_msg & 1)
   {   
      /*
       *  Send the fence the pre_clip message.
       */

      om_msg = om$send (
               msg = message GRgsmgr.GRpre_clip (&ret_msg, &fence_flag),
               p_chanselect = &fence_chansel);

      om_msg = om$get_channel_count (object= me, 
               p_chanselect = &overlap_chansel, count = &count);

      /*
       *  Perform the clip operation on all objects on the overlap 
       *  channel[i].
       */
         
      for (i = 0; (i < count) && (om_msg & ret_msg & 1); ++i)
      {
         if (copy_flag && owner_id)
         {
            sv_id1 = *owner_id;
         }else
         {
            if (copy_flag)
            {
               /*
                *  If we are coping the objects then all the objects
                *  will be copied into the target_env.
                */

               temp_count = 1;
               obj_env.mod_env = *target_env;
            }else
            {
               /*
                *  Retreive the first object from the save set.
                *  The module environment can be used to find a saveset
                *  within that object space.
                */

               temp_count = 0;
               om_msg = om$send(
                        msg = message GRgrset.GSget_object (&ret_msg, 
                        &obj_env, sizeof (struct GRobj_env), &temp_count, 
                        NULL, NULL),
                        p_chanselect = &overlap_chansel,
                        from = i, to = i);
            }

            if ((om_msg & ret_msg & 1) && (temp_count))
            {
               /*
                *  Send the GSenv_compare message to graphics set.
                *  This method will return a save set.
                */
   
               om_msg = om$send (
                        msg = message GRgrset.GSenv_compare (
                        &ret_msg, &obj_env.mod_env, NULL, &sv_id1),
                        targetid = my_id);

               if ( !(om_msg & ret_msg & 1))
               {
                  /*
                   *  Create a saveset and connect it to my self
                   */

                  sv_id1.osnum = obj_env.mod_env.md_id.osnum;
                  om_msg = gr$gsinit (msg = &ret_msg,
                           p_chanselect = &to_sets_chansel,
                           p_objid = &sv_id1.objid,
                           osnum = obj_env.mod_env.md_id.osnum); 
   
                  if (om_msg & ret_msg & 1) 
                  {
                     om_msg = om$send (
                              msg = message GRsvset.GSsvinit(&ret_msg,
                              &obj_env.mod_env, NULL, NULL), 
                              targetid = sv_id1.objid,
                              targetos = sv_id1.osnum);
                  }
               }
            }

            /*
             *  Perform the clip operation.  Pass the clip message out 
             *  the clip_overlap channel.  New elements will be generated
             *  that are either inside, or outside the fence.
             */

            clip_args.msg = &ret_msg;
            clip_args.mod_env = &temp_env;
            clip_args.target_env = (copy_flag) ? target_env : &temp_env;
            clip_args.prism = (me->prism_type == GR_RIGHT_PRISM) ? 
                              (IGRchar *)&rp : (IGRchar *)&cp,
            clip_args.inside_id = inside_id;
            clip_args.outside_id = outside_id;
            clip_args.overlap_id = NULL;
            clip_args.clip_flag = &clip_flag;

            function_info.md_env = &temp_env;
            function_info.pass_to_other_spaces = 0;
            function_info.info = (IGRchar *) &clip_args;

            om_msg = om$send(msg = message GRgrset.GSpass (
                     &ret_msg, message GRgraphics.GRfunction (&ret_msg,
                     GRclip_function, (IGRchar *) &function_info),
                     &temp_env), p_chanselect = &overlap_chansel,
                     from = i, to = i);
         }
      }  /* End of For loop */

      if (om_msg & ret_msg & 1)
      {
         /*
          *  Disconnect the objects from the overlap channel.
          */
                              
         om_msg = om$send (
                  msg = message GRgrset.GSempty (&ret_msg,
                  &my_GRid, &overlap_chansel),
                  p_chanselect = &overlap_chansel);

         if (om_msg & ret_msg & 1)
         {      
            /*
             *  Delete the overlap save set.
             */

            om_msg = om$send (
                     msg = message GRgrset.GSdissolve (&ret_msg),
                     p_chanselect = &overlap_chansel);

            if (om_msg & ret_msg & 1)
            {
               /*
                *  Clear the postprocessing bit.
                */

               me->properties &= (0xffffffff ^ GRIS_POST_PROCESSING);
            }
         }
      }
   }
   return (OM_S_SUCCESS);
}
end implementation GRfcset;
