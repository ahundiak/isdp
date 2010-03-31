/*

Name
  EFmerge_surfaces

Abstract

Synopsis
 Get all the surfaces and merge them together.  Determine the class of
 surface to construct and construct it.  Return the id of the new surface.

Description
 This function takes a list of surface object ids (along with other
 necessary information about each of the surfaces) and merges all of them
 together, forming a single surface. The order in which this 
 merge takes place is strictly in the order in which they are present in 
 the input surfaces array. That is, no attempt is made to try permutations
 and  combinations among the surfaces to find continuity. If continuity 
 conditions are not met between successive surfaces, the function aborts and an
 error status is returned. 

Return Value
 *msg                    completion code
                         - MSSUCC if successful
                         - MANOMEMORY if no dynamic memory available
                         - MSINARG if math failed, note that this probably
                           indicates that the input surfaces were not 
                           connected or were not compatible
                         - MSFAIL (severe) if failure
                           due to allocation problems

Notes
 The merged surface is reparameterized based on the length of it's polygon.
 
Index

Keywords
  construct,function,modify,surface

History
 Jack   21-Feb-93 : Copied all the code from the method EMmerge_surfaces to 
                    this function.  I did this since I needed to make the
                    EFmerge_the_surfaces call BEFORE constructing an object.
 Sudha  07/06/93  : Modified for BSprototypes ansification

 */

class implementation EMSsubbs;

#include "EMS.h"
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif
# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif
#include "OMerrordef.h"
#include "msdef.h"
#include "madef.h"
#include "bserr.h"
#include "emsdef.h"
#include "bsgeom_cvsf.h"
#include "EMSsfparms.h"
#include "bsconic.h"
#include "bssrmktsncg.h"
#include "bssftgeomsf.h"
#include "bssf_rev.h"
#include "bssf_copy.h"
#include "bsmergsfnna.h"
#include "bsfreesf.h"
#include "bsarclnpars.h"
#include "bsallocsf.h"

%safe
static IGRboolean  EFmerge_the_surfaces();
%endsafe

from EMSrevol import EMgetRevolvedFormat;

IGRlong EFmerge_surfaces( number_of_surfaces,
                          surfaces,
                          construct_list,
                          new_grid,
                          msg)

IGRlong       number_of_surfaces;
struct        GRlc_info surfaces[];
struct        GRvg_construct *construct_list;
struct GRid  *new_grid; 
IGRlong       *msg;


{
 IGRboolean     status;
 IGRlong        msg_loc, sts;
 struct         IGRbsp_surface *merged_surface;
 struct         BSgeom_bsp_surf merged_sf_struct;
 void           getsfclassid();
 OMuword        sf_classid = 0;
 struct IGRbsp_surface *temp_surface;
 IGRint         num_uknots = 0;
 IGRint         num_vknots = 0;
 IGRdouble     *uknots = NULL;
 IGRdouble     *vknots = NULL;


/*
 * Initialize
 */
 *msg = MSSUCC;
 merged_surface = NULL;
 new_grid->objid = NULL_OBJID;
 
/*
 * Merge the surfaces
 */
 status = EFmerge_the_surfaces(
   number_of_surfaces,
   surfaces,
   NULL_OBJID,
   &merged_surface,
   msg);
  if (!status) goto wrapup;


 /*
  * reparameterize the knots, the math that removes excess knots
  * requires this be done.
  */ 
 BSarclnpars(
      msg,
      2,
      merged_surface);

 if (*msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }


 BSallocsf(
     merged_surface->u_order,
     merged_surface->v_order,
     merged_surface->u_num_poles,
     merged_surface->v_num_poles,
     merged_surface->rational,
     0,                            /* No boundaries */
    &temp_surface,
     msg);
 if (*msg != BSSUCC)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }

 uknots = (IGRdouble *) alloca(merged_surface->u_num_poles * sizeof(IGRdouble));
 vknots = (IGRdouble *) alloca(merged_surface->v_num_poles * sizeof(IGRdouble));

 /*
  * remove any excess knots without changing the shape of the surface
  */
 BSsrmktsncg(merged_surface,
             FALSE,0.0,FALSE,
             temp_surface,              
            &num_uknots,
            &num_vknots,
             uknots,
             vknots,
             msg);

 if (*msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }



/*
 * find out if the surface that was created is a special type
 */
 merged_sf_struct.bspsf = temp_surface;
 merged_sf_struct.type = BSGEN_BSP_SF;
 merged_sf_struct.sfgen_cv = NULL;

 BSsftgeomsf(&merged_sf_struct,
              TRUE,
              100,
              msg);
 if(*msg != BSSUCC)
   {
     *msg = MSFAIL;
      goto wrapup;
   }
                

 getsfclassid( merged_sf_struct.type,
              &sf_classid);

 status = om$construct ( classid =  sf_classid, 
                         osnum   =  new_grid->osnum, 
                         p_objid = &(new_grid->objid));
 if (!(1&status)) goto wrapup;



/*
 * Fill the instance data
 */
 construct_list->geometry = (IGRchar *) temp_surface;
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRconstruct(
                construct_list),
               senderid = NULL_OBJID,
               targetos = new_grid->osnum,
               targetid = new_grid->objid);
 construct_list->geometry = NULL;
  if (!(1 & sts)) goto wrapup;
/*
 * Error logic
 */
wrapup:
 if (merged_surface) status = BSfreesf(&msg_loc, merged_surface);
 if (1 & *msg)
   return(OM_S_SUCCESS);   
 else
  {
   if(new_grid->objid != NULL_OBJID)
    {
     sts = om$send(mode = OM_e_wrt_object,
                   msg = message Root.delete(1),
                   senderid = NULL_OBJID,
                   targetos = new_grid->osnum,
                   targetid = new_grid->objid);

    }

   return(OM_E_ABORT);
  }



}

/* 

 Static function to merge together several surfaces.

 ss     09/30/86 : Design date.
 rlw    ??/??/?? : Modified to reparameterize surface after merge.
 rlw    05/16/87 : Fix typo on an EMallocsf().  This was causing
                   the routine to allocate insufficent memory at times
 rlw    05/19/87 : Moved all of the logic to this function.
 rlw    10/09/87 : Remove reparameterization logic and changed to use
                   another math merge routine
  
 */

static IGRboolean EFmerge_the_surfaces(
  number_of_surfaces,
  surfaces,
  my_stupid_id,
  the_merged_surface,
  msg)

IGRlong         number_of_surfaces;
struct          GRlc_info surfaces[];
OM_S_OBJID      my_stupid_id;
struct          IGRbsp_surface **the_merged_surface;
IGRlong         *msg;

{
  IGRchar       *generic_pointer;
  IGRboolean    status;
  IGRlong   msg_loc, i, sts;
  struct IGRbsp_surface *tmp_surface = NULL, 
                        *merged_surface = NULL, 
                        *new_surface = NULL,
                        *tmp_rev_surface = NULL;
  struct IGRbsp_surface *surface = NULL;
  IGRint full_torus = 1,
         done_once = 0;
  OMuword my_classid;
  extern  OMuword  OPP_EMSptorus_class_id;
  struct IGRbsp_curve  base_curve;
  IGRpoint axis[2];
  IGRboolean is_360=FALSE,
             pos_orient_flag=FALSE;
  IGRdouble start_angle=0.0,
            sweep_angle=0.0;
            


/*
 * Initialize
 */

#if DEBUG
 fprintf(stderr, "\nInside merge surface function there are %d surfaces",
         number_of_surfaces);
#endif

 *msg = MSSUCC;
 *the_merged_surface = NULL;


/*
 * For each surface get the geometry and merge it in with the rest
 */

 for (i = 0; i < number_of_surfaces; i++)
  {


/*
 * Get the abstract buffer of the surface
 */

   sts = om$send(msg = message EMSsubbs.GRgenabsg(
                  msg,
                  &surfaces[i].module_info.md_env.matrix_type,
                  surfaces[i].module_info.md_env.matrix,
                  &generic_pointer),
                 senderid = my_stupid_id,
                 targetid = surfaces[i].located_obj.objid,
                 targetos = surfaces[i].located_obj.osnum);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   surface = (struct  IGRbsp_surface *) generic_pointer;

   /*
    * I need to do some special processing to determine if the result
    * of the merge will be a full torus.  All of the members must be
    * of class EMSptorus and the sweep must equal 360 degrees.  When 
    * full_torus gets changed to 0, I know that I won't get a full torus.
    */
   if(full_torus)
    {
     sts = om$get_classid( osnum = surfaces[i].located_obj.osnum,
                           objid = surfaces[i].located_obj.objid,
                           p_classid = &my_classid );
     if( my_classid != OPP_EMSptorus_class_id )
       full_torus = 0;
     else if( !(surface->u_phy_closed) && !(surface->v_phy_closed) )
               full_torus = 0; 
          else if(!done_once)
            {
               done_once=1;

                 /*
                  * call the first time to determine how many poles and knots, etc
                  * to allocate.
                  */
                 sts = om$send(msg = message EMSrevol.EMgetRevolvedFormat(
                         msg,
                         TRUE,
                        &surfaces[i].module_info.md_env.matrix_type,
                         surfaces[i].module_info.md_env.matrix,
                        &base_curve,
                         (IGRdouble *)axis,
                        &is_360,
                        &start_angle,
                        &sweep_angle,
                        &pos_orient_flag),
                 senderid = my_stupid_id,
                 targetid = surfaces[i].located_obj.objid,
                 targetos = surfaces[i].located_obj.osnum);

                 if (! (1 & sts))
                  {
                   *msg = MSFAIL;
                    goto wrapup;
                  }

                 /*
                  * alloca memory for the poles, knots, and 
                  */

                 base_curve.poles = (IGRdouble *)alloca((unsigned)(base_curve.num_poles *
                                                     sizeof(IGRpoint)));
                 if(base_curve.rational)
                   base_curve.weights = (IGRdouble *)alloca((unsigned)(base_curve.num_poles *
                                         sizeof(IGRdouble)));
 
                 base_curve.knots = (IGRdouble *)alloca((unsigned)((base_curve.order + 
                                              base_curve.num_poles) * sizeof(IGRdouble)));

                 /*
                  * call the second time to get the poles and knots etc filled out.
                  */
                  sts = om$send(msg = message EMSrevol.EMgetRevolvedFormat(
                         msg,
                         FALSE,
                        &surfaces[i].module_info.md_env.matrix_type,
                         surfaces[i].module_info.md_env.matrix,
                        &base_curve,
                        (IGRdouble *)axis,
                        &is_360,
                        &start_angle,
                        &sweep_angle,
                        &pos_orient_flag),
                 senderid = my_stupid_id,
                 targetid = surfaces[i].located_obj.objid,
                 targetos = surfaces[i].located_obj.osnum);


                 if (! (1 & sts))
                  {
                   *msg = MSFAIL;
                    goto wrapup;
                  }
            }
    }


   BSallocsf(
     surface->u_order,
     surface->v_order,
     surface->u_num_poles,
     surface->v_num_poles,
     surface->rational,
     0,                                         /* No boundaries */
     &tmp_surface,
     &msg_loc);
    if (msg_loc != BSSUCC)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }

   status = BSsf_copy(
     &msg_loc,
     surface, 
     tmp_surface);
    if (!status)
     {
      *msg = MSFAIL;
      goto wrapup;
     }


/*
 * Merge it with the rest of them
 */
   if (i == 0)
    {
     merged_surface = tmp_surface;
     tmp_surface = NULL;
    }
   else
    {
     BSmergsfnna (merged_surface, tmp_surface, &new_surface, &msg_loc);
     if (msg_loc != BSSUCC)
      {
        if (msg_loc == BSNOTCOMP)
         *msg = MSINARG;
        else
         *msg = MSFAIL;
        goto wrapup;
      }

     status = BSfreesf(
       &msg_loc, 
       tmp_surface);
     tmp_surface = NULL;

     status = BSfreesf(
       &msg_loc,
       merged_surface);
     merged_surface = new_surface;

     new_surface = NULL;

    } /* ELSE FOR if (i == 0) */
  } /* for (i = 0; i < object_count; i++) */


 /*
  * if the final merged surface is not closed in both directions, then
  * we don't have a full torus.
  */ 
 if(!( merged_surface->u_phy_closed ) || !( merged_surface->v_phy_closed ))
   full_torus = 0;


 if(full_torus)
  {
   /*
    * if we got this far, we know that the merge succeeded and we have
    * a full torus.  we want to create a sf of rev here that will represent
    * the torus.
    */

   BSallocsf(
     base_curve.order,
     BSCIRCLE_ORDER,
     base_curve.num_poles,
     BSCIRCLE_NUM_POLES_MAX,
     TRUE,
     0,                                         /* No boundaries */
     &tmp_rev_surface,
     &msg_loc);
    if (msg_loc != BSSUCC)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }


   is_360=TRUE;
   status = BSsf_rev(
     &msg_loc,
      axis[0],
      axis[1],
     &base_curve,
     &is_360,
     &start_angle, /* won't be used */
     &sweep_angle,  /* won't be used */
      tmp_rev_surface );
    if (!status)
     {
      *msg = MSFAIL;
      goto wrapup;
     }


    /*
     * return the resulting surface
     */
    tmp_rev_surface->num_boundaries = 0;
   *the_merged_surface = tmp_rev_surface;
    tmp_rev_surface = NULL;
        
  }
else
  {
   /*
    * Return the results
    */

    merged_surface->num_boundaries = 0;
   *the_merged_surface = merged_surface;
    merged_surface = NULL;

   /*
    * Normalize the surfaces knot vector
    */

    BSnrsfkntvc(*the_merged_surface);
  }


/*
 * Eof
 */

wrapup:
 if (tmp_surface)    status = BSfreesf (&msg_loc, tmp_surface);
 if (merged_surface) status = BSfreesf (&msg_loc, merged_surface);
 if (new_surface)    status = BSfreesf (&msg_loc, new_surface); 
 if (tmp_rev_surface) status = BSfreesf (&msg_loc, tmp_rev_surface);

 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation EMSsubbs;

