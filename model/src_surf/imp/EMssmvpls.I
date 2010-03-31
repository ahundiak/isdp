/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY:

Long Ago:  ??   Creation.
08/26/92:  NP   Modified for ANSI compliance.

*/


#include "EMS.h"
# include "OMmacros.h"     /* OM_BLOCK_MOVE */
# include "OMprimitives.h"     /* OM primitives */
# include "OMminimum.h"     /* for gocmacros.h  */
# include "igrtypedef.h"     /* for gocmacros.h  */
# include "godef.h"
# include "gocmacros.h"     /* GRgetabsg macro  */
# include "msdef.h" /* MS message codes */
# include "OMstackalloc.h"
# include "ex.h" /* For struct EX_button */
# include "EMSopt.h"
# include "EMSmvpl.h" /* FOR EMMOVE.. */
%safe
# include <math.h>
%endsafe
# define DEBUG 0

extern OMuword  OPP_EMSgenbs_class_id;

method EMmove_poles(IGRlong *msg; 
                    struct GRmd_env *md_env;
                    IGRint options; 
                    IGRint num_poles;
                    IGRint *indices;
                    IGRdouble *from_point;
                    IGRdouble *to_point; 
                    IGRchar *buff;
                    GRobjid *newobjid)
{
        IGRlong OMmsg;                  /* OM return value              */
        IGRlong msg1;                   /* local completion code        */
        IGRchar *absgptr;               /* abstract geometry pointer    */
        IGRlong i,j,k,status,size,ptnum,from_ptnum, to_ptnum;  
        IGRdouble *unwpoles;
        struct IGRbsp_surface *surf;    /* pointer to B-spline surf     */
        struct IGRpointset pt_set;      /* point set,control pts of surf*/
        struct GRpost_info info;        /* information for GRpostabsg   */
        IGRint index;
        IGRlong stat_func;
        IGRlong from_u_pole_inx, from_v_pole_inx,
                to_u_pole_inx, to_v_pole_inx,
                from_p_inx, to_p_inx, u_inx, v_inx;
        IGRdouble weight,dist,temp_dist;
        IGRvector vec;

        IGRpoint pole;                  /* pole to alter                */
        IGRdouble *vectors;
        struct EX_button topt;
        struct EMmove_pole_addtnl_info *mvpl_info;
        IGRdouble *dists;
        IGRpoint new_topt;
        void           EFck_sf_bs_props();

        *msg = MSSUCC;
        OMmsg = OM_S_SUCCESS;
        
        GRgetabsg(&msg1,&md_env->md_env.matrix_type,md_env->md_env.matrix,
                  &absgptr,i);

        if (! (1 & msg1))
        {
           *msg = MSFAIL;
           OMmsg = OM_E_ABORT;
           goto wrapup;
        }

        surf = (struct IGRbsp_surface *)absgptr;
        surf->num_boundaries = 0;

        if (buff) mvpl_info = (struct EMmove_pole_addtnl_info *) buff;

        if (options & EMMOVE_POLE_ALONG_SPECIFIED_VECTORS)
         vectors = mvpl_info->vectors; 
        else vectors = NULL;

        if (options & EMMOVE_POLE_ALONG_SPECIFIED_DISTS)
         dists = mvpl_info->dists;
        else
         dists = NULL;

        topt.x = to_point[0];
        topt.y = to_point[1];
        topt.z = to_point[2];

        EMconstrain(&topt);

        new_topt[0] = topt.x;
        new_topt[1] = topt.y;
        new_topt[2] = topt.z;

        if (vectors)
        {
         struct IGRline line;
         IGRint last_index;
         IGRdouble t;
         IGRpoint todir;
         IGRpoint proj_pt;
       
         line.point1 = from_point;
         line.point2 = todir;
         last_index = num_poles;

         for (k=0;k<3;k++)
           todir[k] = from_point[k] + 
                       vectors[3*(last_index) + k];

         stat_func = MAptlnproj(msg,new_topt,&line,proj_pt,&t);
           if (!(1&stat_func))
           {
              *msg = MSFAIL; goto wrapup;
           }

         for (k=0;k<3;k++)
          vec[k] = proj_pt[k] - from_point[k];

         dist = sqrt(vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);

         if (t < 0) dist = -dist;
        }
     else
       {
        for (k=0;k<3;k++)
         vec[k] = new_topt[k] - from_point[k];
       }

        for(i=0;i<num_poles;i++)
        {
         index = indices[i];
         if (surf->rational)
           weight = surf->weights[index];
         else
           weight = 1;

          if (vectors)
          {
           for (k=0;k<3;k++)
            vec[k] = dist*vectors[3*i+k];
          }

          if (dists)
           temp_dist = dists[i];
          else
           temp_dist = 1;

         for (j=0;j<3;j++)
          surf->poles[3*index+j] += vec[j]*weight*temp_dist;
        }

/*
 * Make sure that the surface's bs-props (planar, u_phy_closed
 * v_phy_closed) are still coreect.
 */

 EFck_sf_bs_props (msg, surf,(EMS_VAL_PLANAR | EMS_VAL_PHY_CLSD) );
 if (!(1 & *msg)) goto wrapup;

/*
 * Post back into the database
 */
 {
  OMuword        my_classid;

  OMmsg = om$get_classid(p_classid = &my_classid,
                         objid = my_id,
                         osnum = OM_Gw_current_OS);
   if (!(1 & OMmsg)) goto wrapup;     
  if (my_classid == OPP_EMSgenbs_class_id)
   {
    struct      GRpost_info info;

    info.construct_flag = FALSE;
    OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRpostabsg(
                   msg,
                   md_env,
                   &info,
                   (IGRchar *) surf,
                   newobjid),
                  senderid = my_id,
                  targetid = my_id);
    if (!(1 & OMmsg)) goto wrapup;
   }
  else
   {
    IGRshort    chan_flag, del_flag;
    IGRlong     EMchgclass();
    struct      GRid my_GRid;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    chan_flag = TRUE;
    del_flag = TRUE;
    OMmsg = EMchgclass (
            msg, 
            md_env, 
            my_GRid, "EMSgenbs", 
            &ME.GRgraphics->properties, 
            surf,
            &chan_flag, 
            &del_flag, 
            newobjid);
    if (!(1 & OMmsg)) goto wrapup;
   }
 } /* Post logic */

wrapup:

  GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
  GR_NOTIFY_LISTENERS(msg, &OMmsg, GR_GEOM_MODIFIED);
  return(OMmsg);
}

end implementation EMSsubbs;
