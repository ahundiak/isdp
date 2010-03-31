/*

 DESCRIPTION

  This function does the following:

  Extends the ends of a curve (simple or composite) according to the options
  and arguments specified. It can extend linearly or polynomially.  

  If it is used to extend the ends linearly (by means of the option 
  EMS_EXT_LINEAR) then any non-linear end curves (arcs, general bsplines, 
  parabolas etc.) are ALWAYS converted to general bsplines by merging with the 
  end linear end segment of specified length. The caller can specify vectors
  at either end along which to extend. If not, end tangents are used.

  If it is used to extend the ends polynomially, then arcs are maintained as 
  arcs by doing a polynomial extention. Obviously, for linear curves, this case
  is the same as "EMS_EXT_LINEAR" above. But all non-linear non-arcs (i.e. those
  curves that are not circular or elliptical arcs or not line segments) are 
  ALWAYS tangentially extended, which also means that they form a general 
  bspline curve after the extension. The extention distance for arcs is NOT 
  bound by the options mentioned below, and is arbitrrily set in this function
  such that the extended arc subtends a 270 degree angle at the center.

  In both the cases above, the caller can specify distances to extend at either
  end. If not specified, they are calculated based on the following options 
  (note the exception in the case of the arc above):
     EMS_EXT_TO_BOUNDING_BOX
     EMS_EXT_TO_SURFACE  or
     EMS_EXT_TO_REFPLANE


 ARGUMENTS

 cvid[I]
 -------

  This contains the information about the curve

 ext_options[I]
 --------------

  Options currently supported are:

    EMS_EXT_TO_BOUNDING_BOX       Extend curve to the solid's bounding box 
    EMS_EXT_TO_SURFACE            Extend curve to the given surface.
    EMS_EXT_TO_REFPLANE           Extend curve to the given RP.
    EMS_EXT_LINEAR                Extend curve ends linearly, using the input 
                                  ext_vec. If ext_vec is input as NULL, then use
                                  the end tangents.
    EMS_EXT_POLYNOMIAL            Do a polynomial extention of the curve at 
                                  either end. Obviously, for linear segments it
                                  is the same as "EMS_EXT_LINEAR", but arcs are
                                  are maintained as arcs by extending them
                                  polynomially. Since polynomial extend for 
                                  general b-splines is a totally unpredictable
                                  outcome, we extend them using "ext_vec" if
                                  non-NULL or else by the end tangents.

                                  NOTE:
                                  Currently, for arcs, the extention is such 
                                  that they subtend an angle of 270 degrees at 
                                  the center. This can even be made an input 
                                  into this function later.

 closure[I]
 ----------

  Pass TRUE if the curve needs to be closed after the extension
  else FALSE

 dist[I]  
 -------

  Variable for storing info - by what distance the curve has to be extended
  at its either end. This provide the flexibility of extending the curve
  by different distances at either end.

 ext_vec[I]
 ----------

  The vector direction along which the extension needs to be done. If
  this is NULL, then the default will be to take the outward tangents at the 
  end of the curve, in case of linear extension.

 sfid[I]
 -------

  The surface/solid which drives the extension of the input curve.

  if ext_options is EMX_EXT_TO_BOUNDING_BOX
      this is the id of the surface/solid to whose bounding box the input curve
      will be extended to. However, if it is polynomial extend, the bounding 
      box is currently ignored for arcs (270 deg. extend is done).

  if ext_options is EMX_EXT_TO_SURFACE or EMX_EXT_TO_REFPLANE
     this is the id of the surface/solid upto which  the input curve will be 
     extended to. However, if it is polynomial extend, the surface is currently
     ignored for arcs (270 deg. extend is done). (NOTE: This will be later 
     modified to extend upto surface/RP if the arc that has been extended by 
     the pre-determined angle does happen to intersect surface/RP).

 bounding_box[I]
 --------------- 
 
 Can be NULL. Is looked first if EMS_EXT_TO_BOUNDING_BOX is set. The extension
 happens till this box. However, if it is polynomial extend, the bounding 
 box is currently ignored for arcs (270 deg. extend is done).      
 
 modenvsf [I]
 ------------

   The module env for the surface/solid/RP.
     
 self_intersection[O]
 --------------------

  Information if the extended curve self-intersects. For a closed curve (if the
  caller requested that the curve be closed), the endpt contact where the curve
  closes does NOT count as self-intersection.

 const_args[I]
 -------------

  Construct list arguments.

 new_id[O]
 ---------

  Id of the modified curve.

 HISTORY

   Rustagi : 12/18/92 : Creation
   Sudha   : 07/09/93 : Modified for BSprototypes anisfication
   NP      : 07/30/93 : Create the closure curve ONLY if needed. Also, delete 
                        ALL objects created in here, on error.
   NP      : 09/30/93 : Now, we merge any extentions with end segments, if the 
                        end segment happens to be linear. This is to prevent 
                        creation of adjacent co-planar surfaces while placing 
                        rib features which cause problems. Eventually the 
                        merging can be controlled by an option. 
                        Also did some clean-up of code.
   NP      : 10/06/93 : Did some major reshuffling of code. Now only extend 
                        curve to the bounding box, if the newly added option
                        EMS_EXT_TO_BOUNDING_BOX is set. Merged two options
                        parameters into one. Handled the fact that input comp. 
                        cv can have composite comps. Streamlined code.

   NP      : 10/19/93 : Completely re-wrote this function to make it as flexible
                        as possible and to handle as many cases as possible. 
                        Major enhancement is the polynomial extension of arcs.
                        Re-named function to EFextend_curve_by_option(). Also
                        re-wrote the description and arguments to reflect the 
                        new functionality.

   NP      : 01/04/94 : Added a new function "EFfix_self_intersections" to this
                        file. Rib code can handle a lot more cases now.
                        
   SAM	   : 04/15/94 : - Added argument bounding_box applicable only with 
        		  EMS_EXT_TO_BOUNDING_BOX as one of the option.
                        - When ext_vec is supplied don't do polynomial
                          extension, merge the curve.
                       
*/

class implementation Root;


#include "OMprimitives.h"
#include "OMmacros.h"                   /* OM_BLOCK_MOVE */

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "bsparameters.h"
#include "bsconic.h"
#include "bserr.h"
#include "bsvalues.h"

#include "emserr.h"                     /* EMerr_hndlr */
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emscvexten.h"


/* BS prototypes */

#include "bsptlngen.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bsarclen.h"
#include "mabctoar.h"
#include "maartobc.h"
#include "bsmergarrcv.h"
#include "bscvarreval.h"
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bsdistptpts.h"
#include "bsarclen.h"

#define M_PI            3.14159265358979323846


#define DELTA_ANGLE ( M_PI / 2.0) /* ninety degrees */
#define ARCLEN_FACTOR 20

/* imports */

from GRcurve     import EMcrvcrvint, GRptextend;
from GRcurve     import GRdisextend, GRendpts, EMcrvslfint;
from GRvg        import GRgetsize, GRgetgeom, GRpostabsg, GRgeomprops;
from EMSsurface  import EMcrvsrfint;
from GRgraphics  import GRdelete, GRcopy, GRconstruct;
from GRconnector import GRrigidconn, GRdisconn;

/* extern functions */

extern void         EMsort_by_parameter();
extern IGRlong      EFextend_to_bounds();
extern IGRboolean   EFisAncestryValid();
extern IGRboolean   GRabsg_del_by_objid();
extern void         EFget_lowest_components();

/* extern declarations */

extern OMuword OPP_GRsubbc_class_id, OPP_GRlinear_class_id;
extern OMuword OPP_GRbcsubbc_class_id, OPP_GR3dlineseg_class_id;
extern OMuword OPP_GRcirarc_class_id, OPP_GRellarc_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_GRcompcurve_class_id;

#ifdef __STDC__
#argsused
#elseif
/*ARGSUSED*/
#endif

IGRlong EFextend_curve_by_option(msg,
                         cvid,
                         modenvcv,
                         ext_options,
                         closure,
                         ext_dist,/*NULL, if it has to be calc. acc to options*/
                         ext_vec, /*NULL, if end tangents are to be used */
                         bounding_box,
                         sfid,
                         modenvsf,
                         self_intersection,
                         const_args,
                         new_id)
IGRlong    *msg;
struct GRid *cvid;
struct GRmd_env *modenvcv, *modenvsf;
IGRlong    ext_options;
IGRboolean closure;
IGRdouble  *ext_dist;
IGRvector  *ext_vec;
GRrange	   bounding_box;
struct     GRid *sfid;
IGRboolean *self_intersection;
struct     GRvg_construct *const_args;
struct     GRid *new_id;
{
 BSrc          rc;
 OMuint        index, count;
 IGRint        i, j, type, num_comps;
 IGRlong       sts, msg_loc, num_bytes, num_alloc_slots, num_inter;
 IGRdouble     par, *vec, *dist, cht, extended_dist, unextended_dist;
 IGRdouble     start_dist, end_dist;
 IGRdouble     startpar, endpar, midpar, junk_dist;
 IGRboolean    extend_linear, is_composite, status;
 GRspacenum    const_os;
 GRobjid       new_cv, junkid, start_cv, end_cv, *comps, *cv;
 struct GRid   owner;
 struct GRpost_info post_info;
 IGRpoint      cv_startpt, cv_endpt, junkpt, points[2][3], ext_pt, max_ext_pt;
 IGRpoint      new_cv_startpt, new_cv_endpt, endpt;
 IGRvector     tangent, start_tangent, end_tangent;
 OM_S_CHANSELECT to_owner, to_components;

 struct IGRarc         arc;
 struct GRparms        *cv_pars;
 struct GRprops        props;
 struct IGRbsp_curve   *current_geom;
 struct IGRbsp_curve   ext_cvgeom, ext_curve, **cvgeom, *cv_array[2];
 struct IGRbsp_curve   *start_cvgeom,*end_cvgeom,line_geom,*merged_cv;

 /*
  * Initialisation
  */
  *msg   = EMS_S_Success;
  sts = OM_S_SUCCESS;
 
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);
  EMmake_chanselect(GRconnector_to_owners, &to_owner);
  EMmake_chanselect(GRcmpowner_to_components, &to_components);
 
  const_os = const_args->env_info->md_id.osnum;
 
  /* INITIALIZATIONS */

  new_id->objid = NULL_OBJID;
  if (self_intersection)
     *self_intersection = FALSE; /* assume */
  cv_pars   = NULL;
  num_comps = 0;
  comps     = NULL;
  merged_cv = NULL;

  /* Check the class of the incoming curve. If composite, get the ids of the 
   * end components. 
   */

  sts = om$send (msg = message GRvg.GRgeomprops(&msg_loc,
                               &const_args->env_info->md_env.matrix_type,
                               const_args->env_info->md_env.matrix,
                               &props),
                senderid = NULL_OBJID,
                targetid = cvid->objid,
                targetos = cvid->osnum);
  EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

  EMerr_hndlr(props.phy_closed, *msg, EMS_E_InvalidArg, ret_end);

  /* Make a copy of the input composite curve. We will only work on this copy */
  new_id->osnum = const_os;
  sts = om$send (msg = message GRgraphics.GRcopy(&msg_loc, 
                             modenvcv, const_args->env_info, &(new_id->objid)),
                   senderid = NULL_OBJID,
                   targetid = cvid->objid,
                   targetos = cvid->osnum);
  EMerr_hndlr (!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);

  is_composite =  EFisAncestryValid(&msg_loc, new_id->objid, new_id->osnum,
                             OPP_EMScomposite_class_id, TRUE);
  if (is_composite)
  {
      num_comps = 0;
      comps     = NULL;
      (void) EFget_lowest_components(&msg_loc, new_id, &num_comps, &comps,
                                     NULL, NULL, NULL);
      EMerr_hndlr (!(1&msg_loc), *msg, msg_loc, ret_end);

      /* start and end curves COULD be the same if the composite curve had just
       * ONE element.
       */
      start_cv = comps[0]; 
      end_cv   = comps[num_comps-1]; 
  }
  else
  {
      start_cv = end_cv = new_id->objid;
  }  

  /* if extend distances are input, use them */
   start_dist = ext_dist ? ext_dist[0] : 0.0; 
   end_dist   = ext_dist ? ext_dist[1] : 0.0; 

  /* get extend dist for either end  ONLY if "ext_dist" is not input */
  for (i=0; i<2 && !ext_dist; i++)
  {
     cv = (i==0? &start_cv : &end_cv);
     vec = (IGRdouble *) (ext_vec ? (i==0? ext_vec[0] : ext_vec[1]) : NULL);
     dist = (i==0? &start_dist : &end_dist);
     cvgeom = (i==0? &start_cvgeom : &end_cvgeom);

     /* store for later reference */
     sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                                &const_args->env_info->md_env.matrix_type,
                                const_args->env_info->md_env.matrix,
                                (i==0? cv_startpt : junkpt),
                                (i==0? junkpt : cv_endpt)),
		         senderid = NULL_OBJID,
                         targetid = *cv,
                         targetos = const_os);
     EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, ret_end);


     if (EFisAncestryValid(&msg_loc, *cv, const_os,
                             OPP_GRlinear_class_id, TRUE))
         extend_linear = TRUE;
     else if (EFisAncestryValid(&msg_loc, *cv, const_os,
                             OPP_GRsubbc_class_id, TRUE))
         extend_linear = TRUE;
     else if (EFisAncestryValid(&msg_loc, *cv, const_os,
                             OPP_GRcirarc_class_id, TRUE))
         extend_linear = FALSE;
     else if (EFisAncestryValid(&msg_loc, *cv, const_os,
                             OPP_GRellarc_class_id, TRUE))
         extend_linear = FALSE;
     else
     {
         /* for parabolas, hyperbolas etc., i.e. none of the above */
         extend_linear = TRUE;
     }

          
     /* get curve geometry */
     sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                               &const_args->env_info->md_env.matrix_type,
                               const_args->env_info->md_env.matrix, &num_bytes),
		         senderid = NULL_OBJID,
                         targetid = *cv,
                         targetos = const_os);
     EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, ret_end);
  
     *cvgeom = (struct IGRbsp_curve *) alloca (num_bytes);
  
     sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                                &const_args->env_info->md_env.matrix_type,
                                const_args->env_info->md_env.matrix,
                                (IGRchar *)(*cvgeom)),
		         senderid = NULL_OBJID,
                         targetid = *cv,
                         targetos = const_os);
     EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, ret_end);

  
     /* If the curve is a b-spline curve, then the option to polynomially extend
      * is overridden here. A b-spline curve is ALWAYS linearly extended, 
      * because polynomila extention for a b-spline can cause more problems than
      * it solves.
      */ 

     if ((ext_options & EMS_EXT_LINEAR) ||
         ((ext_options & EMS_EXT_POLYNOMIAL) && extend_linear))
     {
        if (vec)
        {
          OM_BLOCK_MOVE (vec, tangent, sizeof (IGRvector));
        }
        else
        {
           /* get the outward tangent to the curve */
           par = (i==0? 0.0 : 1.0);
           (void) BScvarreval(&rc,*cvgeom,&par,1,1,(IGRdouble *)points);
           for (j=0; j<3; j++)
             tangent[j] = (points[0][1][j]) * (i==0?-1.0:1.0) ;

        }

        BSnorvec(&rc, tangent); /* always BSSUCC */

        OM_BLOCK_MOVE (tangent, (i==0? start_tangent : end_tangent),
                              sizeof (IGRvector)); /* for later use below */

        /* get the endpt which we need to get extension distance for */
        par = (i==0? 0.0 : 1.0);
        (void) BScvarreval(&rc,*cvgeom,&par,1,0,(IGRdouble *)points);
        for (j=0; j<3; j++)
          endpt[j] = points[0][0][j];

        if (ext_options & EMS_EXT_TO_BOUNDING_BOX)
        {
           
           /* Find the extention of the endpt of the input curve upto range 
            * box, and along the outward tangent calculated above.
            */
           sts = EFextend_to_bounds (&msg_loc, modenvsf, endpt, 
                                      bounding_box, sfid, tangent, ext_pt);
           EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
    
           /* find extension dist*/
           if (msg_loc == EMS_I_NoSolution) /* bounding box behind endpt */
             *dist = 0.0;
           else
             *dist = BSdistptpt( &rc, endpt, ext_pt); /* always BSSUCC*/

           *dist += 10 * cht; /* just in case */
        }
        else if(ext_options & (EMS_EXT_TO_SURFACE | EMS_EXT_TO_REFPLANE))
        {

          /* surface/RP id better be passed in */
          EMerr_hndlr (!sfid, *msg, EMS_E_InvalidArg, ret_end);
        
          sts = EFextend_to_bounds (&msg_loc, modenvsf, endpt, 
                                      NULL, sfid, tangent, max_ext_pt);
          EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
   
          /* error out if surface/RP is BEHIND the tangent vector */
          EMerr_hndlr ((msg_loc == EMS_I_InvalidArg),*msg,EMS_E_Fail, ret_end);

          /* define a line segment with max possible length. This line seg
           * will now have to be trimmed back to the FIRST intersection with 
           * sf/RP. PUT THIS IN SOME TIME.
           */
          ext_curve.poles = (IGRdouble *)alloca (2 * sizeof (IGRpoint));
          ext_curve.knots = (IGRdouble *)alloca (4 * sizeof (IGRdouble));
 
          sts = BSptlngen(&rc, endpt, max_ext_pt, &ext_curve, &type);
          EMerr_hndlr ((rc!=BSSUCC) || (type!=BSCLINE), *msg, EMS_E_BSerror, 
                        ret_end);

          num_alloc_slots=0; /*number of alloced memory slots for function use*/
          num_inter=0; /* Initialize. IMPORTANT*/

          /* Intersect the above line seg. with sf/RP. If no intersection, error
           *  out.
           */

          cv_pars = NULL;

          sts = om$send(msg = message EMSsurface.EMcrvsrfint(
            &msg_loc,
            NULL, /* no need to construct objects out of intersections */
            &modenvsf->md_env,
            *cvgeom, /*  pass in the curve geometry */
            NULL, /* no need to pass in curve id */
            NULL, /* no need to pass in curve's GRmdenv_info */
            FALSE,/* dont need intersections in hole areas of surface */
            &num_alloc_slots, /* I, the caller, am NOT allocating any memory */
            &num_inter, /* number of intersections */
            NULL, /* intersection points are NOT to be converted into objects */
            NULL, /** DO NOT need UV intersection data on the solid */
            &cv_pars,     /* UV  intersection data on the curve */
            NULL, /* DO NOT need XYZ intersection data on the curve */
            NULL), /* DO NOT need int. props of int. pt wrt surface edges */
                   senderid = NULL_OBJID,
                   targetid = sfid->objid,
                   targetos = sfid->osnum);
          EMerr_hndlr (!(1&msg_loc&sts) || !num_inter, *msg, msg_loc, ret_end);

          /* sort the intersection parameters */
          EMsort_by_parameter(NULL, cv_pars, NULL, NULL, num_inter);

          /* get the FIRST intersection parameter on the line seg and eval it */
          par = cv_pars[0].u;
          (void) BScveval(*cvgeom,par,0,&ext_pt,&rc);
          EMerr_hndlr ((rc != BSSUCC), *msg, msg_loc, ret_end);

          *dist = BSdistptpt( &rc, endpt, ext_pt); /* always BSSUCC*/
          *dist += 10 * cht; /* just in case */

        }

     }
     else if ( (ext_options & EMS_EXT_POLYNOMIAL) && !extend_linear)
     {

        /* here, extention to bounding box does not make any sense, neither
         * does extend to surface/RP for that matter. Therefore the strategy 
         * here is to extend polynomially so that the arc forms a 270 deg. arc
         * and then try and see if it extends beyond bounding box or surface. 
         * If it does, truncate it, else return it as extended.(THIS LAST STUFF
         * HAS TO BE PUT IN).
         */
            
        status = MAbctoar(&msg_loc,*cvgeom,&arc);
        EMerr_hndlr ((msg_loc!=MSSUCC) || !status,*msg,EMS_E_BSerror,ret_end);

        if (start_cv == end_cv)
        {
          /* extend either end by half the actual sweep required. The new
           * new sweep angle is inclusive of existing sweep angle.
           */
          arc.sweep_angle = (2.0 * M_PI - arc.sweep_angle)/2.0 
                                + arc.sweep_angle - DELTA_ANGLE/2.0;
        }
        else
        {
            arc.sweep_angle = 2.0 * M_PI - DELTA_ANGLE;
        }


        ext_cvgeom.poles   = (IGRdouble *) alloca (BSCIRCLE_NUM_POLES_MAX *
                                            sizeof(IGRpoint) );
        ext_cvgeom.weights = (IGRdouble *) alloca (BSCIRCLE_NUM_POLES_MAX *
                                            sizeof(IGRdouble));
        ext_cvgeom.knots   = (IGRdouble *) alloca (BSCIRCLE_NUM_KNOTS_MAX *
                                            sizeof(IGRdouble));

        status = MAartobc(&msg_loc, &arc, &ext_cvgeom);
        EMerr_hndlr ((msg_loc!=MSSUCC) || !status,*msg,EMS_E_BSerror,ret_end);

        /* now that we have the bspline curve that represents the extention of
         * the conic arc to the distance we want, extract the extended distance.
         */

         startpar = 0.0;
         endpar   = 1.0;
         midpar   = 0.5;
         unextended_dist = BSarclen(&rc,&status,*cvgeom,&startpar,&endpar,
                                   &midpar,&junk_dist);
         EMerr_hndlr (rc!=BSSUCC || !status, *msg, EMS_E_BSerror, ret_end);

         extended_dist = BSarclen(&rc,&status,&ext_cvgeom,&startpar,&endpar,
                                   &midpar,&junk_dist);
         EMerr_hndlr (rc!=BSSUCC || !status, *msg, EMS_E_BSerror, ret_end);

         *dist = extended_dist - unextended_dist;

     }
     else
     {
         EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
     }


     /* deallocate memory allocated in the for loop */
    if (cv_pars)
    {
      om$dealloc (ptr=cv_pars); 
      cv_pars = NULL;
    }
  }/*for*/


  /* Now actually do the extending of the input curves. It is a trivial matter
   * to simply send the "GRcurve.GRdisextend" to the input curve. HOWEVER, we
   * have to specially take care of general b-spline curves, for which case, the
   * extend distance calculated above ALWAYS refers to a tangential extention.
   * By default, the GRdisextend method would extend the b-splie curve 
   * polynomially possibly producing undesirable results.
   */
 

   sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                                &modenvcv->md_env.matrix_type,
                                modenvcv->md_env.matrix,
                                cv_startpt, cv_endpt),
		         senderid = NULL_OBJID,
                         targetid = new_id->objid,
                         targetos = new_id->osnum);
   EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, ret_end);


  for (i=0; i<2; i++)
  {
     /* if (curve is linear) OR (if it is an arc and we want polynomial extend)
      * then we do a polynomial extend. Otherwise we create a general b-spline.
      */
     if (!ext_vec && 
          (EFisAncestryValid(&msg_loc, (i==0?start_cv:end_cv), const_os,
                                    OPP_GRlinear_class_id, TRUE)           ||
         ((EFisAncestryValid(&msg_loc, (i==0?start_cv:end_cv), const_os,
                                    OPP_GRcirarc_class_id, TRUE) || 
           EFisAncestryValid(&msg_loc, (i==0?start_cv:end_cv), const_os,
                                    OPP_GRellarc_class_id, TRUE)) && 
            (ext_options & EMS_EXT_POLYNOMIAL))))
     {   sts = om$send (msg = message GRcurve.GRdisextend(&msg_loc, 
                         modenvcv, (i==0?cv_startpt:cv_endpt),
                         (i==0? &start_dist : &end_dist),
                         (i==0? new_cv_startpt : new_cv_endpt)), 
                    senderid = NULL_OBJID,
                    targetid = new_id->objid,
                    targetos = new_id->osnum);
     }
     else
     {
        /* This end curve has to be merged with a linear extention 
         * segment. If the curve was an an arc, then the caller must have 
         * specified EMS_EXT_LINEAR, else it would not come in here. 
         */

        sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                               &const_args->env_info->md_env.matrix_type,
                               const_args->env_info->md_env.matrix, &num_bytes),
		         senderid = NULL_OBJID,
                         targetid = (i==0? start_cv:end_cv),
                         targetos = const_os);
        EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, ret_end);
  
        current_geom = (struct IGRbsp_curve *) alloca (num_bytes);
  
        sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                                &const_args->env_info->md_env.matrix_type,
                                const_args->env_info->md_env.matrix,
                                (IGRchar *)(current_geom)),
		         senderid = NULL_OBJID,
                         targetid = (i==0? start_cv:end_cv),
                         targetos = const_os);
        EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, ret_end);

        /* the tangent vector has been normalized above */
        for (j=0; j<3; j++)
          ext_pt[j] = (i==0? cv_startpt[j]: cv_endpt[j])  + 
                      ((i==0? start_tangent[j] : end_tangent[j]) * 
                                          (i==0? start_dist : end_dist));

        line_geom.poles = (IGRdouble *) alloca (2 * sizeof(IGRpoint));
        line_geom.knots = (IGRdouble *) alloca (4 * sizeof(IGRdouble));

        /* create the geometry parametrized in the direction of the curve*/
        status = BSptlngen(&rc, 
                   (i==0? ext_pt : cv_endpt), (i==0?  cv_startpt : ext_pt), 
                   &line_geom, &type);
        EMerr_hndlr ((rc!=BSSUCC)||(type!=BSCLINE),*msg,EMS_E_BSerror,ret_end);

        /* merge the two curves */
        cv_array[0] = (i==0? &line_geom : current_geom);
        cv_array[1] = (i==0? current_geom : &line_geom);

        (void) BSmergarrcv(2,cv_array,&merged_cv,&rc);
        EMerr_hndlr (rc!=BSSUCC,*msg,EMS_E_BSerror,ret_end);

        const_args->geometry = (IGRchar *)(merged_cv);

        new_cv = NULL_OBJID;
        sts = om$construct ( classid = OPP_GRbcsubbc_class_id,
                               osnum = const_os,
                               p_objid = &new_cv,
                               msg = message GRvg.GRconstruct(const_args));
        EMerr_hndlr (!(1&sts&(*(const_args->msg))),*msg,EMS_E_Fail,ret_end);

        if (is_composite)
        {
          /* Get the owner of this component. This is important because the
           * incoming composite curve could be a composite of composites.
           */
          owner.osnum = const_os;
          sts = om$get_objid_at_index (osnum = const_os,
                                 objid = (i==0?start_cv:end_cv),
                                 p_chanselect = &to_owner,
                                 index = 0,
                                 objidaddr = &(owner.objid),
                                 osnumaddr = &(owner.osnum));
          EMerr_hndlr (!(1&sts),*msg,EMS_E_OMerror,ret_end);

          /* get the index on owner's channel on which current curve is 
           * connected
           */
          sts = om$get_index (osnum_c = const_os,
                              objid_c = owner.objid,
                              p_chanselect = &to_components,
                              objid = (i==0?start_cv:end_cv),
                              osnum2 = const_os,
                              indexaddr = &index);
          EMerr_hndlr (!(1&sts),*msg,EMS_E_OMerror,ret_end);

          /* unlink the current curve from owner */
          sts = om$send (msg =  message GRconnector.GRdisconn(&msg_loc, &owner),
                         senderid = NULL_OBJID,
                         targetid = (i==0?start_cv:end_cv),
                         targetos = const_os);
          EMerr_hndlr (!(1&sts&msg_loc),*msg,EMS_E_Fail,ret_end);

          /* replace it with the new curve */
          sts = om$send (msg =  message GRconnector.GRrigidconn(&msg_loc, 
                                        &owner, (IGRlong *)&index),
                         senderid = NULL_OBJID,
                         targetid = new_cv,
                         targetos = const_os);
          EMerr_hndlr (!(1&sts&msg_loc),*msg,EMS_E_Fail,ret_end);

          /*delete the original curve */
          sts = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                 const_args->env_info),
                  senderid = NULL_OBJID,
                  targetid = (i==0?start_cv:end_cv),
                  targetos = const_os);
          EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

          /* update start/end curve info */
          if (i==0)
            start_cv = new_cv;
          else
            end_cv = new_cv;

          /* delete the owner's abstract buffer just in case */
          GRabsg_del_by_objid(&(owner.objid), &const_os);
          if (new_id->objid != owner.objid)
             GRabsg_del_by_objid(&(new_id->objid), &const_os);
        }
        else
        {
          /*delete the original curve */
          sts = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                const_args->env_info),
                  senderid = NULL_OBJID,
                  targetid = (i==0?start_cv:end_cv),
                  targetos = const_os);
          EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

          /*update start/end curve info */
          start_cv = end_cv = new_cv;

          new_id->objid = new_cv; /* this will be the output curve */
        }

        if (merged_cv)
        {
          BSfreecv(&rc,merged_cv);
          merged_cv = NULL;
        }
     }/*else*/

  }/*for*/


  /* add a new component if asked for, to close off the curve */
  if (closure)
  {
     /* get the endpts of the "to be output" composite/simple curve */

     sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                                &const_args->env_info->md_env.matrix_type,
                                const_args->env_info->md_env.matrix,
                                cv_startpt, cv_endpt),
                         senderid = NULL_OBJID,
                         targetid = new_id->objid,
                         targetos = const_os);
     EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, ret_end);

     line_geom.poles = (IGRdouble *) alloca (2 * sizeof(IGRpoint));
     line_geom.knots = (IGRdouble *) alloca (4 * sizeof(IGRdouble));

     /* create the geometry parametrized in the direction of the curve*/
     status = BSptlngen(&rc, cv_endpt, cv_startpt, &line_geom, &type);
     EMerr_hndlr ((rc!=BSSUCC)||(type!=BSCLINE),*msg,EMS_E_BSerror,ret_end);

     const_args->geometry = (IGRchar *)(&line_geom);

     /* create a GR3dlineseg object */
     new_cv = NULL_OBJID;
     sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
                               osnum = const_os,
                               p_objid = &new_cv,
                               msg = message GRvg.GRconstruct(const_args));
     EMerr_hndlr (!(1&sts&(*(const_args->msg))),*msg,EMS_E_Fail,ret_end);
 
     if (is_composite)
     {
        /* get number of components existing on channel */
      
        sts = om$get_channel_count (osnum = const_os,
                                    objid = new_id->objid,
                                    p_chanselect = &to_components,
                                    count = &count); 
        EMerr_hndlr (!(1&sts),*msg,EMS_E_OMerror,ret_end);

        /*simply add this component to the existing composite curve on the 
         * next available index.
         */
        index = count;
        sts = om$send (msg =  message GRconnector.GRrigidconn(&msg_loc,
                                        new_id, (IGRlong *)&index),
                         senderid = NULL_OBJID,
                         targetid = new_cv,
                         targetos = const_os);
        EMerr_hndlr (!(1&sts&msg_loc),*msg,EMS_E_Fail,ret_end);
 
     }
     else
     {
       /* we need to create a new composite curve for output */
       sts = om$construct ( classid = OPP_GRcompcurve_class_id,
                               osnum = const_os,
                               p_objid = &(new_id->objid));
       EMerr_hndlr (!(1&sts&(*(const_args->msg))),*msg,EMS_E_Fail,ret_end);

       /* The id of the original curve is still available in start_cv or 
        * end_cv. Connect both the original curve and the newly created closure
        * segment to it.
        */

       index = 0;
       sts = om$send (msg =  message GRconnector.GRrigidconn(&msg_loc,
                                        new_id, (IGRlong *)&index),
                         senderid = NULL_OBJID,
                         targetid = start_cv, /* or end_cv */
                         targetos = const_os);
       EMerr_hndlr (!(1&sts&msg_loc),*msg,EMS_E_Fail,ret_end);
       index = 1;
       sts = om$send (msg =  message GRconnector.GRrigidconn(&msg_loc,
                                       new_id, (IGRlong *)&index),
                        senderid = NULL_OBJID,
                        targetid = new_cv, /* or end_cv */
                        targetos = const_os);
       EMerr_hndlr (!(1&sts&msg_loc),*msg,EMS_E_Fail,ret_end);

     }

     /* do a post abstract geometry on the output composite curve. This will
      * update its closure properties etc.
      */
     post_info.construct_flag = FALSE;
     sts = om$send (msg = message GRvg.GRpostabsg(&msg_loc,
                         modenvcv, &post_info, (IGRchar *)NULL,&junkid),
                    senderid = NULL_OBJID,
                    targetid = new_id->objid,
                    targetos = new_id->osnum);
     EMerr_hndlr (!(1&sts&msg_loc),*msg,EMS_E_Fail,ret_end);

  }

  /* now we check for self-intersection if asked for */
  if (self_intersection)
  {
    num_alloc_slots = 0;
    num_inter = 0;
    status = om$send(msg = message GRcurve.EMcrvslfint(&msg_loc, const_args,
                               &const_args->env_info->md_env, &num_alloc_slots,
                               &num_inter, NULL, NULL, NULL, NULL, NULL, NULL,
                               NULL),
                         senderid = new_id->objid,
                         targetid = new_id->objid,
                         targetos = new_id->osnum);
    EMerr_hndlr(!(1&msg_loc&status), *msg, EMS_E_Fail, ret_end);
    if(closure ? (num_inter > 1) : num_inter)
     *self_intersection = TRUE;
    else
     *self_intersection = FALSE;
  }


ret_end:    
  /* on any kind of error, delete the output curve here */
  if (!(1&*msg&sts))
  {
     sts = om$send (msg = message GRgraphics.GRdelete(&msg_loc, const_args->env_info),
                    senderid = NULL_OBJID,
                    targetid = new_id->objid,
                    targetos = const_os);
  }

  if (comps)
    om$dealloc (ptr=comps);

  if (cv_pars)
     om$dealloc (ptr=cv_pars);

  if (merged_cv)
  {
    BSfreecv(&rc,merged_cv);
  }

  EMWRAPUP (*msg, sts, "In EFextend_curve_by_option");
  return(sts);
}


/******************************************************************************/

/* DESCRIPTION:
 *
 * NOTES:
 * -----
 * 1. "md_env" is assumed same for both the incming curve and the surface/solid.
 */
IGRlong EFfix_self_intersection (EFmsg, compcv, md_env, sfid, const_list)
IGRlong *EFmsg;
struct GRid *compcv, *sfid;
struct GRmd_env *md_env;
struct GRvg_construct *const_list;
{
  IGRlong sts, msg_loc, i, j;
  IGRint num_comps;
  GRobjid *comps=NULL, firstcv, lastcv;
  IGRboolean is_composite = FALSE;
  IGRshort mattyp;
  IGRdouble bastol, cht;
  GRspacenum os;
  IGRlong num_slots, num_cvslots, num_cvints; 
  IGRlong num_intcv1=0, num_intcv2=0, *num_intcv;
  IGRlong num_intsf1=0, num_intsf2=0, *num_intsf;
  struct GRparms *intcv1, *intcv2, **intcv;
  struct GRparms *intsf1, *intsf2, **intsf;
  struct IGRbsp_curve *cvgeom1, *cvgeom2, **cvgeom;
  struct GRid cvid[2];
  BSrc rc;
  IGRdouble *mat, knot_tol, arclen, target_arclen, delta;
  IGRboolean  trim1, trim2, success;
  IGRdouble trimpar1, trimpar2, *trimpar, testpar, midpar;
  IGRpoint junkpt, trimpt1, trimpt2, *trimpt, new_trimpt, endpt1, endpt2,*endpt;
  IGRpoint final_endpt;

  *EFmsg = EMS_S_Success;
   sts   = OM_S_SUCCESS;

  /* Our charter inside this function is to do the following:
   * 
   * 1. Get the end curves of the incoming profile
   * 2. Trim the end curves back, if they either intersect one another or 
   *    intersect other interior curves.
   * NOTE: At this time we assume that the curve has more than one component.
   * ----  Otherwise, there is no way it can self-intersect. But, if the curve
   *       is a general bspline, it CAN self intersect. We ignore that case for
   *       right now and assume we are dealing with ONLY lines and arcs, in 
   *       which case, it will be an error, if the incoming curve has only ONE
   *       component.
   */

 /* INITIALIZATIONS */

 num_comps = 0;
 comps = NULL;
 cvgeom1 = NULL; 
 cvgeom2 = NULL; 
 intcv1 = NULL; 
 intcv2 = NULL; 
 intsf1 = NULL; 
 intsf2 = NULL; 
 os = compcv->osnum;
 mat = md_env->md_env.matrix;
 mattyp = md_env->md_env.matrix_type;

 BSEXTRACTPAR(&msg_loc, BSTOLBASIS, bastol);
 BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);

  num_comps = 0;
  comps = NULL;
  is_composite = FALSE;
 (void) EFget_lowest_components(&msg_loc, compcv, &num_comps, &comps, 
                                &is_composite, NULL, NULL);
  EMerr_hndlr(!(1&msg_loc) || (num_comps==1) || !is_composite, 
               *EFmsg, EMS_E_Fail, wrapup);


  firstcv = comps[0];
  lastcv  = comps[num_comps-1];
  cvid[0].objid = firstcv;
  cvid[1].objid = lastcv;
  cvid[0].osnum = cvid[1].osnum = compcv->osnum;

  /* First intersect the end components with the incoming surface/solid */

  for (i=0; i<2; i++)
  {
    intsf        = (i==0? &intsf1     : &intsf2);
    num_intsf    = (i==0? &num_intsf1 : &num_intsf2);
    cvgeom       = (i==0? &cvgeom1    : &cvgeom2);

    *cvgeom = NULL;
    sts = EMgetvggeom(&msg_loc, &mattyp, mat, &(cvid[i]), (IGRchar **)cvgeom, 
                      NULL);
    EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);


    *intsf      = NULL;
    num_slots   = 0;
    *num_intsf  = 0;
    sts = om$send(msg = message EMSsurface.EMcrvsrfint(
            &msg_loc,
            NULL, /* no need to construct objects out of intersections */
            &md_env->md_env,
            *cvgeom, /*  pass in the curve geometry */
            NULL, /* no need to pass in curve id */
            NULL, /* no need to pass in curve's GRmdenv_info */
            FALSE,/* dont want intersections in hole areas of surface */
            &num_slots, /* I, the caller, am NOT allocating any memory */
            num_intsf, /* number of intersections */
            NULL, /* intersection points are NOT to be converted into objects */
            NULL, /** DO NOT need UV intersection data on the solid */
            intsf,     /* UV  intersection data on the curve */
            NULL, /* DO NOT need XYZ intersection data on the curve */
            NULL), /* DO NOT need int. props of int. pt wrt surface edges */
                   senderid = NULL_OBJID,
                   targetid = sfid->objid,
                   targetos = sfid->osnum);
    EMerr_hndlr (!(1&msg_loc&sts) || !(*num_intsf), *EFmsg, EMS_E_Fail, wrapup); 
    if (*intsf)
    {
       EMsort_by_parameter (NULL, *intsf, NULL, NULL, *num_intsf);
    }

  } 

  /* Since a the curve coming in is an "extended" curve in the sense of rib 
   * placement and it BETTER intersect with the surface/solid. We make sure both
   * end components intersect incoming surface/solid.
   */
   EMerr_hndlr(!num_intsf1 || !num_intsf2, *EFmsg, EMS_E_Fail, wrapup);


  /* next intersect the end components with the incomng curve */

  trim1 = trim2 = FALSE; /* ASSUME we dont have to trim either end */
  for (i=0; i<2; i++)
  {
    num_intcv   = (i==0? &num_intcv1  : &num_intcv2);
    intcv       = (i==0? &intcv1      : &intcv2);
    intsf       = (i==0? &intsf1    : &intsf2);
    testpar     = (i==0? intsf1[num_intsf1-1].u : intsf2[0].u); 

    *intcv        = NULL;
    *num_intcv    = 0;
    num_cvints  = 0;
    num_slots   = 0;
    num_cvslots = 0;

    /* Ignore curve overlap. Get only the intersection points */
    sts = om$send(msg = message GRcurve.EMcrvcrvint(&msg_loc, const_list,
                             &(md_env->md_env), NULL, compcv, 
                             &(md_env->md_env), TRUE, 
                             &num_slots, num_intcv, NULL, intcv, NULL, 
                             NULL, &num_cvslots, &num_cvints, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = cvid[i].objid,
                     targetos = cvid[i].osnum);
    EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);


    /* sort the intersection paramters on the curve in increasing order.*/

    if (*intcv)
    {
       EMsort_by_parameter (NULL, *intcv, NULL, NULL, *num_intcv);
    }

    /* Now, as we move OUTWARDS on the composite curve (stoppt->startpt for
     * "firstcv" and startpt->stoppt for "lastcv") we pick the self-intersection
     * point just beyond the first intersection with the solid ("testpar") and 
     * use that as the trim point.
     */
    if (i==0)
    {
      if (intcv1) /*if "firstcv" finds an intersection with the rest of the cv*/
      { for (j=(num_intcv1-1); j>=0; j--)
        { if (intcv1[j].u < testpar) 
          {  trimpar1 = intcv1[j].u;
             trim1 = TRUE;
          }
        }
      }
    }
    else
    {
      if (intcv2) /* if "lastcv" finds an intersection with the rest of the cv*/
      { for (j=0; j<num_intcv2; j++)
        { if (intcv2[j].u > testpar)
          {  trimpar2 = intcv2[j].u;
             trim2 = TRUE;
          }
        }
      }
    }

    /* Also calc. the endpt of this component that will possibly be trimmed off.
     * This will be the "startpt" of the first component and the "endpt" of
     * the last.
     */
    sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                                &mattyp, mat,
                                (i==0? endpt1 : junkpt), 
                                (i==0? junkpt : endpt2)), 
                         senderid = NULL_OBJID,
                         targetid = cvid[i].objid,
                         targetos = cvid[i].osnum);
     EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
 
  }

  /* Since a self intersecting curve is coming in here, we better HAVE an
   * intersection on AT LEAST one of the end components.
   */
   EMerr_hndlr(!num_intcv1 && !num_intcv2, *EFmsg, EMS_E_Fail, wrapup);

  
 /* send each end, the message to extend/distend it to the trim point */ 

 for (i=0; i<2; i++)
 {
   if (i==0? !trim1 : !trim2) /* if this component is NOT to be trimmed */
     continue;

   endpt      = (i==0? &endpt1     : &endpt2);
   cvgeom     = (i==0? &cvgeom1    : &cvgeom2);

   trimpar    = (i==0? &trimpar1   : &trimpar2);
   trimpt     = (i==0? &trimpt1    : &trimpt2);
   
   /* We have a trim parameter for this component. To be safe, we can trim 
    * further back such that we move about say, 10*cht in terms of arc length. 
    * This will ensure we dont have a trimmed curve that is physically closed,
    * (if the only intersection between the end components is between themselves
    * and therefore, both ends are trimmed at the SAME XYZ point) but is not 
    * marked so.
    */
    BScvkttol2( (*cvgeom)->order, (*cvgeom)->knots, (*cvgeom)->num_poles, 
                 (*cvgeom)->poles, (*cvgeom)->weights, &knot_tol, &rc);
    EMerr_hndlr ((rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

    delta = knot_tol * cht / bastol;
    delta *= (i==0? 1.0 : -1.0); /* depending on which dir we want to move */
    target_arclen = ARCLEN_FACTOR * cht;
    arclen = 0.0; /* to start the while loop */
    testpar = (*trimpar);

    while (arclen < target_arclen)
    {
       /* Move the trim point some more and calc. the total moved distance*/
       testpar += delta; 
       midpar = (testpar+(*trimpar))/2.0; /* 'cos we dont have closed curves*/
       BSarclen(&rc,&success,*cvgeom,&testpar,trimpar,&midpar,&arclen);
       EMerr_hndlr((rc != BSSUCC) || !success, *EFmsg, EMS_E_BSerror, wrapup);
    }

   /* Now move the final testpar to "*trimpt". */
   (*trimpar) = testpar;

   BScveval(*cvgeom,*trimpar,0,trimpt,&rc);
   EMerr_hndlr ((rc != BSSUCC), *EFmsg, EMS_E_BSerror, wrapup);

   /* We have the correct trim point. Modify the component */
   sts = om$send (msg = message GRcurve.GRptextend (&msg_loc, md_env, *endpt,
                       *trimpt, final_endpt),
                     senderid = NULL_OBJID,
                     targetid = cvid[i].objid,
                     targetos = cvid[i].osnum);
   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

   if (BSdistptpts(&rc, *trimpt, final_endpt) > (bastol * bastol))
     EMerr_hndlr(TRUE,  *EFmsg, EMS_E_Fail, wrapup);
                 
   /* delete owners abstract buffer, just in case. do this later */
 }

 
wrapup:

  if (comps)
    {om$dealloc (ptr=comps);}
  if (cvgeom1)
    {om$dealloc (ptr=cvgeom1);}
  if (cvgeom2)
    {om$dealloc (ptr=cvgeom2);}
  if (intcv1)
    {om$dealloc (ptr=intcv1);}
  if (intcv2)
    {om$dealloc (ptr=intcv2);}
  if (intsf1)
    {om$dealloc (ptr=intsf1);}
  if (intsf2)
    {om$dealloc (ptr=intsf2);}

  EMWRAPUP (*EFmsg, sts, "In EFfix_self_intersection");
   
  return(sts);
}
end implementation Root;
