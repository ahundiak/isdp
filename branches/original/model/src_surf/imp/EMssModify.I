/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:       EMSsubbs

     METHOD NAME:       GRmodify

     Abstract:  This method redefines the geometric representation
              of the object by changing some attribute of its
              geometry.
        
-----
%SC%    

     GRmodify(msg,md_env,vert_loc,point,boreline)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env       GRmd_env       environment information
     *vert_loc     GRparms        not meaningful in this implementation
     point         IGRpoint       point to identify pole to modify
     *boreline     IGRline        locates new pole that replaces 
                                  the pole to modify 
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg          IGRlong       completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   
                MAptpsproj

     Methods:   

                GRpostabsg              
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
        
        SS      07/04/86 : Creation date.
        rlw     05/26/87 : Changed "EMSsubbs" to "EMSsubbs"
        dhm     01/26/88 : Changed to check for EMSgenbs instead of
                           EMSsubbs in the post logic.
        dhm     04/05/88 : Added GR_NOTIFY_LISTENERS.
        RC      04/06/88 : Added a check for sf planarity and 
                           phy_closed properties before posting.
        NP      08/25/92 : Modified for ANSI compliance. Changed "my_classid" from
			   "OMword" to "OMuword".
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
        This method projects the input point onto the control points
        of the B-spline representation of the object and replaces
        that point found by the projection with the first point of
        the input boreline.  The method assumes that the boreline  
        was obtained by calling the routine GRbrlncon.c. 

----*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"
# include "OMmacros.h"     /* OM_BLOCK_MOVE */
# include "OMprimitives.h"     /* OM primitives */
# include "OMminimum.h"     /* for gocmacros.h  */
# include "igrtypedef.h"     /* for gocmacros.h  */
# include "godef.h"
# include "gocmacros.h"     /* GRgetabsg macro  */
# include "msdef.h" /* MS message codes */
# include "OMstackalloc.h"
# include "EMSopt.h"

extern OMuword  OPP_EMSgenbs_class_id;

method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
                struct GRparms *vert_loc; IGRpoint point; 
                struct IGRline *boreline; GRobjid *newobjid)

{
        IGRlong OMmsg;                  /* OM return value              */
        IGRlong msg1;                   /* local completion code        */
        IGRchar *absgptr;               /* abstract geometry pointer    */
        IGRlong i,status,size;          /* loop counter                 */
        IGRdouble *unwpoles;
        struct IGRbsp_surface *surf;    /* pointer to B-spline surf     */
        struct IGRpointset pt_set;      /* point set,control pts of surf*/
        struct GRpost_info info;        /* information for GRpostabsg   */
        IGRlong pt_num;                 /* point number of point set    */
        IGRpoint pole;                  /* pole to alter                */
  extern         IGRboolean MAptpsproj();        /* point to point set project   */
  extern         IGRboolean BSunwght_p();
        void       EFck_sf_bs_props();

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

        /*
         * form a point set from the B-spline poles
         * project the input point to this point set
         */

        pt_set.num_points = surf->u_num_poles * surf->v_num_poles;
        pt_set.points = surf->poles;

        unwpoles = NULL;
        if (surf->rational)
          {
          unwpoles = (IGRdouble *) OM_stack_alloc (pt_set.num_points * sizeof
                                   (IGRdouble) * 3);
          if (! unwpoles)
            {
            *msg = MSFAIL;
            goto wrapup;
            }
          status = BSunwght_p (&msg1, surf->poles, surf->weights,
                       &pt_set.num_points, unwpoles);
          pt_set.points = unwpoles;
          }

        if (! (1 & MAptpsproj(&msg1,point,&pt_set,pole,&pt_num)))
        {
           *msg = MSFAIL;
           OMmsg = OM_E_ABORT;
           if (unwpoles) OM_stack_dealloc (unwpoles);
           goto wrapup;
        }
        if (unwpoles) OM_stack_dealloc (unwpoles);

        /*
         * Replace the vertex found from the project with the first
         * point of the input boreline (formed by GRbrlncon.c).
         * Post the resulting B-spline.
         */

        size = 3 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (boreline->point1, pole, size);
        if (surf->rational)
          for (i=0; i<3; i++)
            pole[i] *= surf->weights[pt_num - 1];
        OM_BLOCK_MOVE (pole, &surf->poles[(pt_num-1)*3], size);

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

  GR_NOTIFY_LISTENERS(msg, &OMmsg, GR_GEOM_MODIFIED);
  return(OMmsg);

}

end implementation EMSsubbs;
