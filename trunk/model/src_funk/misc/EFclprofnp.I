/*________________________________________________________________________
 |                                                                        |
 | OVERVIEW                                                               |
 |                                                                        |
 |    Functions in this file help close Add/Remove profile. Given a open  |
 |    profile and the type of solid needs to be generated from the prof-  |
 |    ile and the range box to which the profile need to be extended li-  |
 |    nearly before closing, the API  (AddRmProcessProfile)  closes  the  |
 |    profile accordingly. If a solid of projection need to be generated  |
 |    the closure algorithm is straight forward.If a solid of revolution  |
 |    need to be generated then the profile is closed w.r.t. the axis of  |
 |    revolution. If a solid of skinning need to be generated  then  the  |
 |    profile is closed w.r.t. the trace curve.                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |    The closure algorithm implemented here is different from the other  |
 |    conventional algorithms followed in EMS and comes up with  a right  |
 |    profile all the time.                                               |
 |                                                                        |
 |    Even though it is a very general purpose stuff, but the  API seems  |
 |    to be attempting at Add/Remove. One can take further steps to make  |
 |    it option independent.                                              |
 |                                                                        |
 | KEYWORDS                                                               |
 |                                                                        |
 |    Add/Remove, Open profile, Range Box, Intersection, Closed profile,  |
 |    External API.                                                       |
 |                                                                        |
 | CAVEATS                                                                |
 |                                                                        |
 |    Present implintation does not take care of the skinning option. In  |
 |    which case the profile is closed as it is in "projected" option.    |
 |                                                                        |
 | HISTORY                                                                |
 |                                                                        |
 |    Sanjay  12/30/94   Creation                                         |
 |                                                                        |
 |________________________________________________________________________|
*/

class implementation Root;

#include <stdio.h>
#include <math.h>
#include <memory.h>
#include <malloc.h>
#include <alloca.h>

#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsfeaopts.h"
#include "EMSsfintsort.h"
#include "EMSasfeatdef.h"
#include "emsbool.h"
#include "emscvexten.h"
#include "EC_I.h"
#include "msmacros.h"
#include "emsmacros.h"
#include "emsmapdef.h"
#include "emsedgedef.h"
#include "EMSssprops.h"
#include "madef.h"

// Prototypes

#include "bscveval.h"
#include "bsconic.h"
#include "bsvalues.h"
#include "bsdistptpts.h"
#include "bsptlngen.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bsarclen.h"
#include "mabctoar.h"
#include "maartobc.h"
#include "bsmergarrcv.h"
#include "bscvarreval.h"
#include "bscvkttol2.h"
#include "bsarclen.h"
#include "bsdistptpt.h"  
#include "bsdistptpts.h"  
#include "bsfreecv.h"
#include "bscvcv_int.h"
#include "bscv_slfint.h"
#include "bspolyxttpt.h"
#include "mabcendpts.h"
#include "bscv_endpt.h"
#include "bsalloccv.h"
#include "bsmdistptcv.h"
#include "bsbx2.h"
#include "bsmklnintbx.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bssfarrevn.h"
#include "bsprptonsf.h"  
#include "bsplptnorrg.h"
#include "bscvkttol2.h"
#include "bsarclen.h"
#include "bscvtstclsd.h"
#include "bsrev_cv.h"
#include "bscv_copy.h"
#include "bspartofcv.h"
#include "maptplpro.h"
#include "bsproj0.h"
#include "bsarclnparc.h"
#include "bsdirfitcv.h"
#include "bsrgbxplint.h" 
#include "bsptinbx.h"
#include "bspolyxttpt.h"
#include "bsmerge_cv.h"
#include "bsxln.h"
#include "bsxlnln.h"
#include "maptlndis.h"
#include "bstagsorti.h"
#include "bstagsort.h"
#include "bsxlnpl.h"

#include "addrmopts.h"
#include "addprot.h"

// Debug includes

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

// Pathway includes

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWattrib.h"
#include "PWattribid.h"

#include "PWapi/dotp.h"
#include "PWapi/rngbx.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/sfcompsf.h"
#include "PWapi/normvec.h"

#define OUTSIDE	0
#define INSIDE 	1

#define START   0
#define STOP    1

// imports 

from GRgraphics		import GRcopy, GRxform, GRdelete, GRgetrang, 
                               GRconstruct, GRchgprops, GRptproject;
from GRconnector 	import GRdisconn, GRrigidconn;
from GRowner 		import GRget_number_components, GRget_components;
from GRvg		import GRgetsize, GRgetgeom, GRpostabsg, GRgeomprops, GRdetplane, EMptatpr, EMpratpt;
from EMSloopset		import EMget_loops;
from GRcurve 		import EMcrvslfint, GRendpts, GRptextend, EMcrvcrvint, GRrevparm, EMpartofcv;
from EMSloop		import EMmake_lb_loop, EMget_props, EMpt_location, EMget_edges;
from EMSedge		import EMget_props_type;
from EMSsurface		import EMsfsfint;
from GRcompcurve	import EMmakecomp;
from EMSsubbs           import EMget_props, EMrtreerange;
      
// extern classids

extern OMuword 	OPP_GRcompcurve_class_id, OPP_EMSloop_class_id, OPP_EMSplane_class_id,
		OPP_GR3dlineseg_class_id, OPP_EMScomposite_class_id, OPP_GRbcsubbc_class_id, OPP_GRlinear_class_id, OPP_SKline_class_id, OPP_GA3dlineseg_class_id, OPP_GA3dlinestr_class_id,  OPP_GR3dlinestr_class_id;

// extern function declarations

extern IGRint GRabsg_del_by_objid();
extern IGRboolean EFisAncestryValid();
extern PWresult AddRmProcessCoplanar
(
  PWobjid cvobj,
  PWobjid fcobj,
  PWosnum os,

  PWvector cvnormal,

  struct GRvg_construct *p_constargs,

  int *num_outcvs,
  PWobjid **p_outcvobj,
  PWboolean *extended
);


#ifdef __STDC__
#argsused
#elseif
/*ARGSUSED*/
#endif

// Macros

#define GetRightClass(classid) \
{ \
 if (is_a_subclass (classid, OPP_GRlinear_class_id) == OM_S_SUCCESS) \
 { \
   if (classid == OPP_SKline_class_id || classid == OPP_GA3dlineseg_class_id) \
     classid = OPP_GR3dlineseg_class_id; \
   else if (classid == OPP_GA3dlinestr_class_id) \
     classid = OPP_GR3dlinestr_class_id; \
 } \
 else \
   classid = OPP_GRbcsubbc_class_id; \
}

#define CopyModProfileInfo(from_info, to_info) \
{ \
  (to_info).props = (from_info).props; \
  OM_BLOCK_MOVE (&(from_info).grid, &(to_info).grid, sizeof(struct GRid)); \
  OM_BLOCK_MOVE (&(from_info).mdenv, &(to_info).mdenv, sizeof(struct GRmd_env)); \
  OM_BLOCK_MOVE ((from_info).plane.point, (to_info).plane.point, sizeof(IGRpoint)); \
  OM_BLOCK_MOVE ((from_info).plane.normal, (to_info).plane.normal, sizeof(IGRvector)); \
  (to_info).parms[0] = (from_info).parms[0];  \
  (to_info).parms[1] = (from_info).parms[1];  \
  (to_info).iparm = (from_info).iparm;  \
}

// Static function declarations

static void ReverseVector();
static void GetRightBox(); 
%safe
static PWresult create_cvobj_from_loop
(
  struct PWgeomloop *p_loop,
  PWboolean merge_start,
  PWboolean merge_stop,
  int num_cvs,
  PWosnum os,

  double lentol,
  struct GRvg_construct *p_constargs,

  PWobjid *cvobj
);
%endsafe



/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*___________________________________________________________________________
 |                                                                           |
 | ABSTRACT                                                                  |
 |                                                                           |
 |   Given a open profile, range box to which the profile need to be extende |
 |   linearly and the type of solid need to be generated from  the  resultant|
 |   closed profile, it extends and closes the profile and creates a new pro-|
 |   file is output.                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |   Given a open profile, a closed profile is generated by extending the    |
 |   profile depending on the input solid range box so that solid genere-    |
 |   ated by this profile is bigger than the input solid.                    |
 |                                                                           |
 |   The closure also depends on the type of the solid one want  to create   |
 |   from this profile. In case of a solid of projection  it is  straight-   |
 |   forward, extend the profile by looking at the range box limits of the   |
 |   surface/solid. In case of solid of revolution, it is extended to meet   | 
 |   the axis of revolution and is never closed. So, the solid need to  be   |
 |   generated with a different mechanism. In case of a solid  of skinning   |
 |   the profile is closed either with respect to the trace curve /  solid   |
 |   range box limits whichever resulsts in  smaller profile. In  case  of   |
 |   one need to take into account the trace curve information  such  that   |
 |   "skinning" does not end up in producing the self interesecting surfa-   |
 |   ces.                                                                    |
 |                                                                           |
 |   Linear extension is done taking into account the end tangents  of the   |
 |   profile. The extended segments are merged with the end segments.  New   |
 |   segments will be added to close the profile.The number segments added   |
 |   will vary from profile to profile such that it just bigger  than  the   |
 |   input solid range box.                                                  |
 |                                                                           |
 |   One can close an open profile either  in  clockwise/counter-clockwise   |
 |   direction. So, the reversed bit is the one which tells how  to  close   |
 |   profile. If reversed is FALSE, the flow of the  original  profile  is   |
 |   maintained, otherwise it  is reversed after closure. This  represents   |
 |   material addition vector (Tangent to the profile X Normal of  profile   |
 |   plane).                                                                 |
 |                                                                           |
 | ALGORITHM                                                                 |
 |                                                                           |
 |   * Intersect the solid range box with the profile plane.This will gen-   |
 |     erate a polygon made of 4 line segments  i.e. trapezoid.              |
 |   * If profile is lying on any one of the planar surfaces of  the  base   |
 |     solid then the polygon is nothing but the external P-LOOP  of  that   |
 |     planar surface.                                                       |
 |   * Extend this polygon so that it encloses the profile range box.        |
 |   * Get the end tangents of the profile and intersect the tangents with   |
 |     all the segments of polygon. Take the point whichever is  close  to   |
 |     the respective end points of the profile.                             |
 |   * According to flow direction of the profile  select  the segments of   |
 |     the polygon whichever falls in it's path.                             |
 |   * Merge the end tangents with the end segments of the profile and add   |
 |     the segments of the polygon as components to form a closed profile.   |
 |   * If at all the profile end tangents are intersecting before they in-   |
 |     tersect with polygon segments then it is considered as self inters-   |
 |     ection and the profile is closed with the end tangents itself.        |
 |   * If at all the end tangents are overlapping each other, then the pr-   |
 |     ofiile is closed with the end tangents being merged into one segment. |
 |   * If the feature to be generated is revolved then  the  above  closed   |
 |     profile is intersected with the axis of revolution. If there is any   |
 |     intersection then that part of the curve is extracted which contains  |
 |     the actual input profile. Otherwise it is unmodified.                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 |   Memory for all the output arguments is allocated in this routine. So,   |
 |   it is the caller's responsibility to free the allocated memory.         |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |                                                                           |
 |   msg             O   Return Code                                         |
 |   opts            I   Not supported. For future use.                      |
 |   matopts         I   Add/Remove material                                 |
 |   solopts         I   Type of solid generated from the profile.           |
 |   feaopts         I   Feature type (ToNext/FromTo/Finite/ThruAll)         |
 |   reversed        I   Whether the profile direction need to be reversed   |
 |                       while closing it. This nothing but "Material Add-   |
 |                       ition Direction".                                   |
 |   prof_info       I   Profile ID, transformation matrix and Plane of the  |
 |                       profile.                                            |
 |   sfid            I   Base solid ID on which the feature need to be cre-  |
 |                       ated.                                               |
 |   envsf           I   Environment matrix for the base solid.              |
 |   axis_ends       I   If the solid need to be generated is solid of rev-  |
 |                       olution then axis of revolution ends.               |
 |   const_args      I   Construction List                                   |
 |   bool_type       O   Type of boolean operation need to be done.          |
 |   extprof_info    I   Extended profile information . ID, Matrix & Plane.  |
 |                                                                           |
 | RETURN CODE                                                               |
 |                                                                           |
 |   TRUE  - Success                                                         |
 |   FALSE - Failure                                                         |
 |                                                                           |
 | KEYWORDS                                                                  |
 |                                                                           |
 |   Add/Remove, Open profile, Base Solid, Intersection, Closed profile,     |
 |   Extension, Self intersection, Overlap and External API.                 |
 |                                                                           |
 | CAVEATS                                                                   |
 |                                                                           |
 |   The present code does not take care  of skinning cases. So,  one  can   |
 |   improve the functionality which will also take into account the trace   |
 |   curve information. Extension of the profile is directly dependent  on   |
 |   the maximum offset for trace curve so that it does not intersects  it   |
 |   self.                                                                   |
 |                                                                           |
 |   One of the assumptions here is no part of the input profile is consu-   | 
 |   during it's modification. In other words, the output profile consists   |
 |   original profile fully.                                                 |
 |                                                                           |
 | HISTORY                                                                   |
 |                                                                           |
 |   Sanjay                Creation                                          |
 |___________________________________________________________________________|
*/

IGRboolean AddRmProcessProfile
(
IGRlong                 *msg, 
IGRlong                 matopts,
IGRlong                 solopts,
IGRlong                 feaopts,
IGRboolean              reversed,
struct ProfileInfo      *prof_info,
struct GRid             *sfid,
struct GRmd_env         *envsf,
IGRvector               proj_vec,
IGRdouble               *axis_ends,
struct GRvg_construct   *const_args,
enum EMSbooltype        *bool_type,
IGRint                  *num_extprof,
struct ModProfileInfo   **extprof_info
)
{
  BSrc      rc=BSSUCC;
  IGRint    n_int=0, knt=0;
  IGRlong   sts=OM_S_SUCCESS, loc_msg = EMS_S_Success;
  GRrange   slrange, prof_range;
  IGRshort  *cvmattyp;
  IGRpoint  PT, dummypt, intpts[6], new_intpts[4];
  IGRvector NORMAL, vec1, vec2, crossvec;
  IGRdouble ENDS[6], *cvmat=NULL, dotp, diag;
  IGRboolean ok=TRUE, extended=FALSE;
  struct GRid *prof=NULL, grid;
  struct GRmd_env *envcv=NULL;
  struct IGRplane PLANE;

  GRobjid   mdid, mdid1;

  IGRboolean self_int=FALSE;
  int num_newprof=0;
  struct ModProfileInfo *newprof_info=NULL;

  /* INITIALIZATION */

  *msg = EMS_S_Success;

  PLANE.point = PT; PLANE.normal = NORMAL;
  prof = &prof_info->grid;
  envcv = &prof_info->mdenv;
  cvmat = envcv->md_env.matrix;
  cvmattyp = &envcv->md_env.matrix_type;
  grid.osnum = prof->osnum; 
  mdid = envcv->md_id.objid;
  mdid1= const_args->env_info->md_id.objid;


  /*
   * Initialize the output.
   */
  *num_extprof = 0;
  *extprof_info = NULL;

  /* 
   * Set the type of boolean operation one need to do after generating the
   * secondary solid from the output closed profile depending on the  Add/
   * Remove material feature.
   */

  if (matopts & EMSadd_material)
  { 
    /*
     * Add Material Feature. Want to add the material to the base solid.
     * So, it is union operation.
     */

    *bool_type = EMSbool_union;
  }
  else
  {
    /*
     * Remove Material Feature. Want to remove the material from the base
     * solid. So, it is a difference operation. But, it  depends on  the 
     * material removal direction and the extent of it's removal. If the 
     * material need to be removed from thru out the solid and the mater-
     * ial removal direction selected is out side the profile, it depicts
     * an intersection operation.
     */

    if (reversed && (feaopts & EMSfeature_thru_all))
    {
      reversed = FALSE;
      *bool_type = EMSbool_intersect;
    }
    else
      *bool_type = EMSbool_difference;
  }

  /*
   * If the profile plane is not given, get the profile plane.
   */
  if( !prof_info->plane.point || !prof_info->plane.normal )
  {
    ok = GetCvOrSfPlane (prof->objid, prof->osnum, envcv, &PLANE);
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "AddRmProcessProfile : GetCvOrSfPlane error",
        action = GOTO_VALUE, value = wrapup );

    BSnorvec (&rc, NORMAL);
  }
  else
  {
    OM_BLOCK_MOVE( prof_info->plane.point, PLANE.point, sizeof(IGRpoint) );
    OM_BLOCK_MOVE( prof_info->plane.normal, PLANE.normal, sizeof(IGRvector) );
  }

  /*
   * get the end points of the profile
   */
  sts = om$send(msg = message GRcurve.GRendpts(&loc_msg,
                                &envcv->md_env.matrix_type,
                                envcv->md_env.matrix,
                                &ENDS[0], &ENDS[3]),
                senderid = prof->objid,
                targetid = prof->objid,
                targetos = prof->osnum);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = loc_msg,
      str = "AddRmProcessProfile : GRvg.GRendpts error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Check for Coplanar case and Process for Coplanar
   */
  if (matopts & EMSadd_material)
  {
    /*
     * Processing the profile for Add Material feature. special processing
     * need to be done in case the profile is lying on any of  the  planar
     * surface of the base solid. In case if the profile is lying  on  one
     * of the planar surfaces, then extend the profile so that it interse-
     * cts with the surface boundaries and close the profile with the sur-
     * face boundaries i.e. edges.
     */ 

    IGRboolean             coplanar=FALSE; 
    struct EMSpartolbasis  ptolb;  
    struct IGRbsp_surface  *plane=NULL;
    struct GRid            the_ploop, the_plane;

    memset (&ptolb, 0, sizeof(struct EMSpartolbasis));

    /*
     * Check whether the profile is lying on any of the planar surfaces of 
     * the base solid.
     */
    ok = CheckCoplanarCase (&loc_msg, feaopts, prof, envcv, sfid, envsf, 
                            &coplanar, &the_plane, &plane, &ptolb, &the_ploop); 
    
    if (coplanar) // If the profile is coplanar with any surface of the solid
    {
      /*
       * Profile is coplanar with one  of  the surfaces of  the  base solid. 
       * Close the profile with the external P_LOOP of the Coplanar Surface.
       */ 
      int num_outcvs=0;
      PWvector cvnormal;
      PWobjid *p_outcvobj=NULL;
      PWresult PWsts=PW_K_Success;
     
      memcpy (cvnormal, NORMAL, sizeof (PWvector)); 
      if (reversed) pwRevVec (cvnormal, cvnormal);

      PWsts = AddRmProcessCoplanar (prof->objid, the_ploop.objid, prof->osnum,
                   cvnormal, const_args, &num_outcvs, &p_outcvobj, &extended); 
      add$status( test = !(1&PWsts), msg = *msg, code = EMS_E_Fail,
          str = "AddRmProcessProfile : AddRmProcessCoplanar error",
          action = GOTO_VALUE, value = wrapup );

      num_newprof = num_outcvs;
      newprof_info = (struct ModProfileInfo *) malloc (num_outcvs * 
                             sizeof (struct ModProfileInfo));
      for (knt=0; knt<num_outcvs; knt++) 
      {
        memset (&newprof_info[knt], 0, sizeof (struct ModProfileInfo));
        newprof_info[knt].grid.objid = NULL_OBJID;
        newprof_info[knt].plane.point  = (double *) malloc (sizeof(IGRpoint));
        newprof_info[knt].plane.normal = (double *) malloc (sizeof(IGRvector));
        OM_BLOCK_MOVE (PLANE.point, newprof_info[knt].plane.point, 
                       sizeof(IGRpoint));
        OM_BLOCK_MOVE (PLANE.normal, newprof_info[knt].plane.normal, 
                       sizeof(IGRvector));

        newprof_info[knt].grid.objid = p_outcvobj[knt];
        newprof_info[knt].grid.osnum = prof->osnum;
        newprof_info[knt].props = ModProf_Coplanar;
        OM_BLOCK_MOVE (envcv, &newprof_info[knt].mdenv, 
                       sizeof(struct GRmd_env));
        OM_BLOCK_MOVE (envcv, &newprof_info[knt].mdenv, 
                       sizeof(struct GRmd_env));
      }

      if(plane) { om$dealloc(ptr = plane); plane = NULL; }

      goto process_for_revolved;

    } // if (coplanar): if it is a coplanar case

  } // if (add material): if it is add material stuff
  
  /*
   * get the R-Tree Range box (tight range) of the solid
   */ 
  ok = GetSurfaceRtreeRange (sfid->objid, sfid->osnum, envsf, slrange);
  add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
              str = "AddRmProcessProfile : GetSurfaceRtreeRange error", 
              action = GOTO_VALUE, value = wrapup );
  
  if (solopts & EMSfeature_skinned)
  {
    /*
     * As skinning may potentially result in self-intersecting surfaces,
     * just extend the range box by chord height.
     */
    IGRdouble  cht;

    BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht);
    EM3dbxinc (slrange, cht);
  }
  else
  {
    /*
     * Increase the range box limits by 10% of the diagonal distance
     */
    diag = BSdistptpt( &rc, &slrange[0], &slrange[3]);
    EM3dbxinc (slrange, 0.1 * diag);
  }

  /*
   * Intersect the profile plane (infinite) with the range box of the solid
   */
  BSrgbxplint (&slrange[0], &slrange[3], PLANE.point, PLANE.normal, 1.0, 
               &n_int, intpts, &rc);
  add$status (test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror, 
      str = "AddRmProcessProfile : BSrgbxplint error", action = GOTO_VALUE,
      value = wrapup  ); 

  if (!n_int || n_int < 4)
  {
    /*
     * If it is add material, it is an error condition as the resultant 
     * operation will be resulting in infinite addition material. So, 
     * error out.
     */

    add$status (test = (matopts & EMSadd_material), msg = *msg, 
        code = EMS_E_AddRmInfinite, 
        str = "AddRmProcessProfile : Unbounded Addition Of Material", 
        action = GOTO_VALUE, value = wrapup  ); 

    /*
     * This is remove material and the solid range box is not intersecting
     * with the profile plane. In this case we need to do some thing spec-
     * ial. In a way the range box need to be extended so that it interse-
     * cts with the profile plane.
     */

    if (!ExtendAndIntersectBoxWithPlane (&slrange[0], &slrange[3], PLANE.point,
      PLANE.normal, (solopts & EMSfeature_projected) ? proj_vec : PLANE.normal,
      &n_int, intpts))
      add$status (test = TRUE, msg = *msg, code = EMS_E_Fail, 
          str = "AddRmProcessProfile : Case not supported.",
          action = GOTO_VALUE, value = wrapup  ); 
  }


  if (n_int > 4)
  {
    /*
     * If the number intersection points is more than four, consider first
     * 4 intersection points.
     */
#ifdef DEBUG
  printf("Number Of Intersections are greater than 4\n");
#endif
    n_int = 4;
  }

  /*
   * The intersection points returned from the above BS routine are not 
   * ordered to form a polygon. So, arrange the points such  that  they 
   * form a polygon i.e. trapezoid.
   */
  GetRightBox(intpts, NORMAL);

  /*
   * TBD :
   * In case of Remove material, we should be getting a better range box
   */

  /*
   * get the range box of the profile
   */
  ok = GetObjectRange (prof->objid, prof->osnum, envcv, prof_range);
  add$status (test = !ok, msg = *msg, code = EMS_E_Fail, 
      str = "AddRmProcessProfile : GetObjectRange error", 
      action = GOTO_VALUE, value = wrapup);

  /*
   * extend the polygon, such  that it encloses the profile range box. 
   */
  ok = ExtendPolyToEncloseRangeBox (&loc_msg, intpts, prof_range, NORMAL, 
                                    &extended, new_intpts); 
  add$status (test = !ok, msg = *msg, code = EMS_E_Fail, 
      str = "AddRmProcessProfile : ExtendPolyToEncloseRangeBox error", 
      action = GOTO_VALUE, value = wrapup);

  if (OM_Gf_verbose_warning && (matopts&EMSadd_material) && extended)
  {
    printf("AddRm Msg: Unbounded Addition of Material\n");
  }

  OM_BLOCK_MOVE (new_intpts, intpts, 4 * sizeof(IGRpoint));

  /*
   * Arrange the intersection points i.e. polygon, in such a way that they 
   * flow in the same direction as the profile.
   */
  BSmkvec (&rc, vec1, intpts[1], intpts[0]);
  BSnorvec (&rc, vec1);

  BSmkvec (&rc, vec2, intpts[1], intpts[2]);
  BSnorvec (&rc, vec2);

  BScrossp (&rc, vec1, vec2, crossvec);
  BSnorvec (&rc, crossvec);

  dotp = BSdotp (&rc, crossvec, PLANE.normal);
  if (dotp < 0.0)
  {
    OM_BLOCK_MOVE (intpts[3], dummypt, sizeof(IGRpoint));
    OM_BLOCK_MOVE (intpts[1], intpts[3], sizeof(IGRpoint));
    OM_BLOCK_MOVE (dummypt, intpts[1], sizeof(IGRpoint));
  }

  num_newprof = 1;
  newprof_info = (struct ModProfileInfo *) 
                         malloc (sizeof (struct ModProfileInfo));
  memset (&newprof_info[0], 0, sizeof (struct ModProfileInfo));
  newprof_info->plane.point  = (double *) malloc (sizeof(IGRpoint));
  newprof_info->plane.normal = (double *) malloc (sizeof(IGRvector));
  newprof_info->grid.objid = NULL_OBJID;

  /*
   * Now extend and close the profile with the polygon/box.
   */
  ok = CloseProfileWithBox (&loc_msg, const_args, prof_info, reversed, intpts, 
                            slrange, &self_int, &newprof_info[0]);
  add$status (test = !ok, msg = *msg, code = EMS_E_Fail,
      str = "AddRmProcessProfile : CloseProfileWithBox error",
      action = GOTO_VALUE, value = wrapup );

process_for_revolved :

  if (solopts & EMSfeature_revolved)
  {
    /*
     * One want to create a solid of revolution from the profile. So, the 
     * closed profile should not intersect with the rotational axis. Pro-
     * cess the profile for revolved operation.
     */

    struct ModProfileInfo revprof_info;

    memset (&revprof_info, 0, sizeof(struct ModProfileInfo));

    for (knt=0; knt<num_newprof; knt++)
    {
      revprof_info.grid.objid = NULL_OBJID;
      revprof_info.plane.point = NULL;
      revprof_info.plane.normal = NULL;

      ok = ProcessProfileForRevolved (&loc_msg, matopts, feaopts, const_args,
                            &newprof_info[knt], axis_ends, &revprof_info); 
      add$status (test = !ok, msg = *msg, code = EMS_E_Fail, 
          str = "AddRmProcessProfile : ProcessProfileForRevolved error",
          action = GOTO_VALUE, value = wrapup);

      if (revprof_info.grid.objid != NULL_OBJID)
      {
        /*
         * A new profile is generated after processing the profile for revolved.
         * So, copy the new profile info. into extprof_info.
         */
 
        // envcv->md_id.objid = NULL_OBJID;
        DeleteObject (&newprof_info[knt].grid.objid, envcv);
    
        CopyModProfileInfo (revprof_info, (newprof_info[knt]));
      }

      if (revprof_info.plane.point) free (revprof_info.plane.point);
      if (revprof_info.plane.normal) free (revprof_info.plane.normal);
    }
  }
  else
  {
    /* 
     * TBD: 
     *     Here should be the code for processing the profile for skinned 
     *     operation. One can call the function "ProcessProfileForSkinned"
     */

  }

  *num_extprof = num_newprof;
  *extprof_info = newprof_info;

wrapup:

  if (!(1&*msg) && num_newprof)
  { 
    // envcv->md_id.objid = NULL_OBJID;
    for (knt=0; knt<num_newprof; knt++)
    {
      if (newprof_info[knt].grid.objid != NULL_OBJID)
        DeleteObject (&newprof_info[knt].grid.objid, envcv);
    }
  }

  envcv->md_id.objid = mdid;
  const_args->env_info->md_id.objid = mdid1;
  if (!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/* ------------------------------------------------------------------------- */
/*                          HELPER FUNCTIONS LISTING                         */
/* ------------------------------------------------------------------------- */

/*
  DESCRIPTION

     Given a closed profile with which the solid of revolution need to be 
     generated and the axis of revolution, it intersects the profile with
     the axis and extracts the part of the curve which contains the first
     components of the input closed curve. If there is no intersection no
     new object is generated.

  NOTES

     All the memory for the output is allocated in this routine.  

  RETURN CODE

     TRUE   - Success
     FALSE  - Failure
*/

IGRboolean ProcessProfileForRevolved
(
IGRlong                *msg,
IGRlong                matopts, 
IGRlong                feaopts,
struct GRvg_construct  *const_args, 
struct ModProfileInfo  *prof_info,
IGRdouble              *axis_ends,
struct ModProfileInfo  *newprof_info
)
{
  /* status stuff */
  BSrc        rc;
  IGRboolean  ok=TRUE;
  IGRlong     sts = OM_S_SUCCESS, loc_msg = EMS_S_Success;

  /* general stuff */
  IGRint           i;
  struct GRid      *prof;
  struct IGRplane  PLANE;
  struct GRmd_env  *envcv;
  IGRpoint         PT, NORMAL;
  IGRdouble        diag;
  GRrange          range;
  GRobjid          mdid, mdid1;
  OMuword          os;

  /* For axis line */
  IGRpoint             line[2], pt0, pt1, line_pts[2];
  IGRdouble            line_knots[4];
  struct IGRbsp_curve  axis_curve;

  // Variables required for intersection of two curves
  IGRlong              pnt_slots = 0, crv_slots = 0;
  IGRlong              num_int = 0, num_cvint = 0;
  struct GRparms       *int_parms = NULL;

  /* Initialize the return status */
  *msg = EMS_S_Success;

  PLANE.point = PT; PLANE.normal = NORMAL;

  /* Initialize the profile stuff */
  prof       = &prof_info->grid;
  envcv      = &prof_info->mdenv;

  mdid = envcv->md_id.objid;
  os   = prof->osnum;
  mdid1= const_args->env_info->md_id.objid;

  // envcv->md_id.objid = NULL_OBJID;
  // const_args->env_info->md_id.objid = NULL_OBJID;

  OM_BLOCK_MOVE (prof_info->plane.point, PLANE.point, sizeof(IGRpoint));
  OM_BLOCK_MOVE (prof_info->plane.normal, PLANE.normal, sizeof(IGRvector));

  newprof_info->plane.point = (double *) malloc (sizeof(IGRpoint));
  newprof_info->plane.normal = (double *) malloc (sizeof(IGRvector));

  CopyModProfileInfo ((*prof_info), (*newprof_info));

  /* 
   * Project the axis ends on to the plane of the profile
   */
  ok = MAptplproj( &loc_msg, (IGRpoint *) &axis_ends[0], &PLANE, line[0] );
  add$status( test = !ok || (loc_msg != MSSUCC), msg = *msg,
      code = EMS_S_Success, str = "Process Profile : No need to intersect the axis with the Profile created",
      action = GOTO_VALUE, value = wrapup );

  ok = MAptplproj( &loc_msg, (IGRpoint *) &axis_ends[3], &PLANE, line[1] );
  add$status( test = !ok || (loc_msg != MSSUCC), msg = *msg,
      code = EMS_S_Success, str = "Process Profile : No need to intersect the axis with the Profile created",
      action = GOTO_VALUE, value = wrapup );

  /*
   * get the axis line which goes beyond the range box limits of the closed
   * profile. For that, get the profile range box and projet it  on  to the 
   * axis vector.
   */

  GetObjectRange (prof->objid, prof->osnum, envcv, range);
  add$status( test = !ok, msg = *msg, code = EMS_E_Fail, 
      str = "ProcessProfileForReovlved : GetObjectRange error",
      action = GOTO_VALUE, value = wrapup );

  diag = BSdistptpt (&rc, &range[0], &range[3]);
  EM3dbxinc (range, (0.5 * diag));

  ok = BSproj0( &loc_msg, &range[0], line, pt0 );
  add$status( test = !ok || BSERROR(loc_msg), msg = *msg,
      code = EMS_E_BSerror, str = "ProcessProfileForReovlved : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  ok = BSproj0( &loc_msg, &range[3], line, pt1 );
  add$status( test = !ok || BSERROR(loc_msg), msg = *msg,
      code = EMS_E_BSerror, str = "ProcessProfileForReovlved : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Create a B-spline curve geometry from the projected end points of the 
   * axis.
   */
  memset (&axis_curve, 0, sizeof(struct IGRbsp_curve));
  axis_curve.poles = &line_pts[0][0];
  axis_curve.knots = &line_knots[0];

  ok = BSlngen( &loc_msg, pt0, pt1, &axis_curve, NULL );
  add$status( test = BSERROR(loc_msg), msg = *msg, code = EMS_E_BSerror,
      str = "ProcessProfileForReovlved : BSlngen error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Find the intersection points between the axis curve and the profile curve
   * which is generated after extension.
   */
  sts = om$send( msg = message GRcurve.EMcrvcrvint( &loc_msg, const_args,
                               &envcv->md_env, &axis_curve, NULL, NULL,
                               NULL, &pnt_slots, &num_int, NULL,
                               &int_parms, NULL, NULL, &crv_slots,
                               &num_cvint, NULL, NULL, NULL ),
                 senderid = NULL_OBJID,
                 targetid = prof->objid,
                 targetos = prof->osnum );
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "ProcessProfileForReovlved : GRcurve.EMcrvcrvint error",
      action = GOTO_VALUE, value = wrapup );

  add$status (test = (num_int == 1), msg = *msg, code = EMS_E_Fail, 
      str = "ProcessProfileForReovlved : Axis is touching the profile, Closure problem",
      action = GOTO_VALUE, value = wrapup );

  /*
   * If the number of intersection points is greater than or equal to 2, then
   * there is a need to create a new profile which should be used  to  create 
   * the solid of revolution.
   */

  if (num_int >= 2)
  {
    /* Channel stuff */
    OM_S_CHANSELECT  to_components;
    struct GRparms   start_parm, stop_parm, mid_parm; 
    IGRint           start_index=0, stop_index=0, *index=NULL, *subs=NULL;
    IGRint           num_comps, compid1, compid2, npar;
    IGRdouble        par;

    /*
     * If the number of interections is greater than two and feature is add
     * material, then it results in unbounded addition of material. So, er-
     * ror out with this informative message.
     */ 

    add$status (test = (num_int > 2) && (matopts & EMSadd_material),msg = *msg, 
        code = EMS_E_AddRmInfinite, str = "ProcessProfileForReovlved : Unbounded Addition of Material",
        action = GOTO_VALUE, value = wrapup );

    /*
     * If the number of intersections is greater than two and the feature to
     * be produced is finite or thru all it should have been handled in tot-
     * ally different way, i.e. one should produce the complementary solid. 
     * So, error out with a failure message.
     */

    add$status (test = (num_int > 2) && ((feaopts & EMSfeature_finite) || (feaopts & EMSfeature_thru_all)), msg = *msg, code = EMS_E_Fail, 
        str = "ProcessProfileForReovlved : Complementary Solid Need to be produced",
        action = GOTO_VALUE, value = wrapup );

    /*
     * Now a part of the curve need to be extracted. We want to extract that
     * part of the curve which is close to the start of the input close cur-
     * ve (according to the parametrization of the curve). 
     */

    if (prof_info->props & ModProf_Composite)
    {
      /*
       * The incoming closed profile is a composite one. So, get the  
       * interescting segment's indices in the composite profile.
       */

      EMmake_chanselect(GRcmpowner_to_components, &to_components);
  
      index = (int *) alloca (num_int * sizeof(int));
      subs  = (int *) alloca (num_int * sizeof(int));
  
      for (i=0; i<num_int; i++)
      {
        index[i] = GetObjectIndexOnChannel (int_parms[i].leaf_id.objid, 
                                     int_parms[i].leaf_id.osnum, 
                                     prof->objid, prof->osnum, &to_components);
      }
 
      /*
       * sort the indices in the ascending order and get the first and last
       * indices and take first two the intersecting segments.
       */ 

      BStagsorti ((int *) &num_int, index, subs, &rc);

      start_index = subs[0];
      stop_index = subs[1];

      /*
       * If both the intersecting segments are same and they are in the in-
       * creasing order of the parameter then reverse the indices.
       */

      if ((int_parms[start_index].leaf_id.objid == 
          int_parms[stop_index].leaf_id.objid) &&
          (int_parms[start_index].u > int_parms[stop_index].u))
      {
        start_index = subs[1];
        stop_index = subs[0];
      }
    }
    else
    {
      /*
       * Incoming profile is not a composite profile. If the number of inter-
       * sections is greater than two, it results in more than two segments, 
       * which is invalid. So, error out.
       */

      add$status (test = (num_int > 2), msg = *msg, code = EMS_E_Fail, 
        str = "ProcessProfileForReovlved : Extended Profile results into two segments",
        action = GOTO_VALUE, value = wrapup );

      start_index = 0;
      stop_index = 1;
    }

    if (OM_Gf_verbose_warning && num_int > 2)
      printf ("\nAdd/Remove Msg : Intersection Operation\n"); 

    OM_BLOCK_MOVE (&int_parms[start_index], &start_parm, 
                   sizeof(struct GRparms));
    OM_BLOCK_MOVE (&int_parms[stop_index], &stop_parm, 
                   sizeof(struct GRparms));
    OM_BLOCK_MOVE (&start_parm, &mid_parm, sizeof(struct GRparms));

    if (start_parm.leaf_id.objid == stop_parm.leaf_id.objid)
    {
      /*
       * The intersecting segments are same. Take the mid parameter of the
       * segment as the mid_param for extracting the part of curve.
       */

      OM_BLOCK_MOVE (&start_parm, &mid_parm, sizeof(struct GRparms));

      mid_parm.u = start_parm.u + (stop_parm.u - start_parm.u) / 2.0;
    }
    else
    {
      /*
       * The intersecting segments are different. Take the incoming param-
       * eter as the mid parameter as this parameter corresponds to an ac-
       * tual point on the original profile from which this closed profile
       * is generated.
       */

      mid_parm.polygon_inx = FALSE;
      mid_parm.leaf_id.objid = prof_info->iparm.id;
      mid_parm.leaf_id.osnum = os;
      mid_parm.u = prof_info->iparm.u;
    }

    /*
     * Extract the part of the closed curve with the help of above computed
     * mid parameter info.
     */

    sts = om$send( msg = message GRcurve.EMpartofcv( &loc_msg,
                                 &envcv->md_env.matrix_type,
                                 envcv->md_env.matrix, const_args,
                                 &start_parm, &mid_parm, &stop_parm,
                                 &newprof_info->grid.objid),
                       senderid = NULL_OBJID,
                       targetid = prof->objid,
                       targetos = prof->osnum );
    add$status( test = !(1&sts&loc_msg), msg = *msg,code = EMS_E_CurveError,
        str = "ProcessProfileForReovlved : GRcurve.EMpartofcv error",
        action = GOTO_VALUE, value = wrapup );

    newprof_info->grid.osnum = os;

    /*
     * Generate the start and stop params info. Which means, the segment
     * and parametric info corrsponding to the incoming closed   profile
     * info, which is nothing but the end points of the original profile 
     * from which the closed profile is generated.
     */

    /*
     * get the number of components of the partial profile.
     */
    num_comps = GetObjectNumCompsOnChannel (newprof_info->grid.objid, 
                           newprof_info->grid.osnum, &to_components);

    if (start_parm.leaf_id.objid == prof_info->parms[0].id)
    {
      if (num_comps)
        compid1 = GetObjectAtIndexOnChannel (newprof_info->grid.objid,
                             newprof_info->grid.osnum, 0, &to_components);
      else
        compid1 = newprof_info->grid.objid;

      sts = om$send (msg = message GRvg.EMpratpt (&loc_msg, 
                                   &envcv->md_env.matrix_type,
                                   envcv->md_env.matrix, prof_info->parms[0].pt,
                                   &par, &npar),
                     senderid = NULL_OBJID,
                     targetid = compid1,
                     targetos = os);
      add$status (test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
          str = "ProcessProfileForReovlved : GRvg.EMpratpt error",
          action = GOTO_VALUE, value = wrapup );

      newprof_info->parms[0].id = compid1;
      newprof_info->parms[0].u = par;
    }
    else
    {
      newprof_info->parms[0].id = 
             GetObjectAtIndexOnChannel (newprof_info->grid.objid,
                                        newprof_info->grid.osnum, 
                                        prof_info->parms[0].index, 
                                        &to_components);
    }


    if (stop_parm.leaf_id.objid == prof_info->parms[1].id)
    {
      if (num_comps)
        compid2 = GetObjectAtIndexOnChannel (newprof_info->grid.objid,
                   newprof_info->grid.osnum, num_comps-1, &to_components);
      else
        compid2 = newprof_info->grid.objid;


      sts = om$send (msg = message GRvg.EMpratpt (&loc_msg,
                                   &envcv->md_env.matrix_type,
                                   envcv->md_env.matrix, prof_info->parms[0].pt,
                                   &par, &npar),
                     senderid = NULL_OBJID,
                     targetid = compid1,
                     targetos = os);
      add$status (test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
          str = "ProcessProfileForReovlved : GRvg.EMpratpt error",
          action = GOTO_VALUE, value = wrapup );

      newprof_info->parms[1].id = compid2;
      newprof_info->parms[1].u = par;
    }
    else
    {
      if (prof_info->parms[1].index > num_comps)
      {
        newprof_info->parms[1].id = 
           GetObjectAtIndexOnChannel (newprof_info->grid.objid,
                   newprof_info->grid.osnum, num_comps-1, &to_components);
        newprof_info->parms[1].u = 1.0;
      }
      else
      {
        newprof_info->parms[1].id = 
           GetObjectAtIndexOnChannel (newprof_info->grid.objid,
                   newprof_info->grid.osnum, prof_info->parms[1].index, 
                   &to_components);

      }
    }
  }
  else
  {
    newprof_info->grid.objid = NULL_OBJID;
  } 

wrapup :

  envcv->md_id.objid = mdid;
  const_args->env_info->md_id.objid = mdid1;

  if (!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/*
  DESCRIPTION

     Given an open profile and a box (consisting of 4 segments) around it
     it extends the profile by using the end tangents such that it inter-
     sects with the segments of the box and closes the  profile  with the
     segments of the box.The segments which matches with the profile flow
     will be considered for closing profile.
 
  NOTES

     All the memory for the output is allocated in this routine.

  RETURN CODE

     TRUE   - Success
     FALSE  - Failure
*/

IGRboolean CloseProfileWithBox
(
IGRlong                *msg,
struct GRvg_construct  *const_args,
struct ProfileInfo     *prof_info,
IGRboolean             reversed,
IGRpoint               *boxpts, 
IGRdouble              *slrange,
IGRboolean             *self_int,
struct ModProfileInfo  *newprof_info
)
{
  /* status stuff */
  IGRboolean    ok=TRUE;
  IGRlong       sts=OM_S_SUCCESS, loc_msg=EMS_S_Success;

  /* channel stuff */
  OM_S_CHANSELECT  to_components;

  /* profile info */
  struct GRid      *prof;
  struct GRmd_env  *envcv;
  IGRint           prof_ncomps=0, startindx=0, stopindx=0, poly_inx=0;
  GRobjid          *profcomps=NULL;

  /* intersection between the lines */
  IGRpoint   line1[2], line2[2], ln_intpt;

  /* BS curve geometrices */
  struct IGRbsp_curve  *extcv1=NULL, *extcv2=NULL;
  struct SegmentInfo   seginfo1, seginfo2;

  /* general stuff */
  BSrc             rc;
  struct GRid      grid;
  IGRchar          *geometry;
  IGRint           inx, nd=3, i;
  GRobjid          startcvid, stopcvid, lineid, compcvid, mdid, mdid1;
  IGRshort         *cvmattyp;
  IGRvector        proftan[2], eval[2], startpt, stoppt;
  IGRdouble        *cvmat, u_pars[2];
  IGRboolean       newflag, start_deextended=FALSE, stop_deextended=FALSE,
                   on_curve=FALSE;
  OMuword          os, classid;
  IGRpoint         xyzpts[2];
  struct IGRbsp_curve *startcv=NULL, *stopcv=NULL, *cv1, *cv2;
  
  /* Initialize the return status */
  *msg = EMS_S_Success;

  /*
   * initialize the profile stuff
   */
  prof       = &prof_info->grid;
  envcv      = &prof_info->mdenv;
  grid.osnum = prof->osnum;
  *self_int  = FALSE;

  cvmat    = envcv->md_env.matrix;
  cvmattyp = &envcv->md_env.matrix_type;

  mdid = envcv->md_id.objid;
  os   = prof->osnum;

  mdid1    = const_args->env_info->md_id.objid;
  geometry = const_args->geometry;
  newflag  = const_args->newflag;

  newprof_info->props = NULL;

  /*
   * get the to_component channel data
   */
  EMmake_chanselect(GRcmpowner_to_components, &to_components);

  /*
   * get the tangents of the profile at the ends.
   *     o Get the number of components of the profile
   *     o if ncomps
   *       then
   *         get the first and last components of the profile
   *         evalulate the tangents at parameters 0 and 1 on first and last 
   *         components of the profile, which are nothing but end tangents.
   *       else 
   *         get the profile geometry and evaluate the tangents at 0.0 and 1.0.
   *       fi
   */ 
  /*
   * If the profile is a composite curve, then it will have components other-
   * wise, it is a single curve and prof_ncomps will be zero.
   */

  prof_ncomps = GetObjectNumCompsOnChannel (prof->objid, prof->osnum, 
                                            &to_components);
 
  /* 
   * get the profile components, if any 
   */ 
  if (prof_ncomps)
  {
    profcomps = (GRobjid *) alloca (prof_ncomps * sizeof(GRobjid)); 
    ok = GetObjectCompsOnChannel (prof->objid, prof->osnum, prof_ncomps, 
                                  &to_components, profcomps);
    startindx = 0; stopindx = prof_ncomps-1;
  }

  do 
  {
    if (prof_ncomps)
    { 
      /*
       * Profile is a composite curve. Get the components at the start and 
       * stop indices and their geometrices respectively. 
       */

      startcvid = profcomps[startindx];
      grid.objid = startcvid;
      sts = EMgetvggeom (&loc_msg, cvmattyp, cvmat, &grid, (IGRchar **)&startcv, 
                         NULL);
      add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : EMgetvggeom error",
          action = GOTO_VALUE, value = wrapup );
  
      stopcvid = profcomps[stopindx];
      grid.objid = stopcvid;
      sts = EMgetvggeom (&loc_msg, cvmattyp, cvmat, &grid,(IGRchar **)&stopcv,
                         NULL);
      add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : EMgetvggeom error",
          action = GOTO_VALUE, value = wrapup );
    }
    else
    {
      /*
       * Profile is a single curve, get it's geometry.
       */

      sts = EMgetvggeom (&loc_msg, cvmattyp, cvmat, prof, (IGRchar **)&startcv,
                         NULL);
      add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : EMgetvggeom error",
          action = GOTO_VALUE, value = wrapup );
  
      stopcvid = startcvid = prof->objid;
      stopcv = startcv;
    }

    /*
     * Get the backward tangent at the start point of the first profile segment.
     */
    BScveval (startcv, 0.0, 1, eval, &rc); 
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_Fail,
        str = "CloseProfileWithBox : BScveval error",
        action = GOTO_VALUE, value = wrapup );

    OM_BLOCK_MOVE (eval[1], proftan[0], sizeof(IGRvector));
    BSnorvec (&rc, proftan[0]);
    ReverseVector (proftan[0]);

    /*
     * Get the forward tangent at the end point of the last profile segment.
     */
    BScveval (stopcv, 1.0, 1, eval, &rc); 
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_Fail,
        str = "CloseProfileWithBox : BScveval error",
        action = GOTO_VALUE, value = wrapup );
     
    OM_BLOCK_MOVE (eval[1], proftan[1], sizeof(IGRvector));
    BSnorvec (&rc, proftan[1]);
  
    OM_BLOCK_MOVE (&startcv->poles[0], line1[0], sizeof(IGRpoint));  
    OM_BLOCK_MOVE (&stopcv->poles[(stopcv->num_poles-1)*3], line2[0], 
                   sizeof(IGRpoint));  

    /*
     * Generate a infinite line representing the backward tangent of the first
     * profile segment. Also, generate an infinite line representing the forw-
     * ard tangent of the last profile segment. Perform the intersection betw-
     * een them. If there is any intersection,
     *    o check whether the intersection point is lying with in the range 
     *      box of the solid or not.
     *    o If it is so, check whether this inersection point is along the 
     *      input lines from the start points of the lines.
     *    o If it is so, there will be self intersecion between the end tang-
     *      ents (forward and backward tangents of the end segments). Need to
     *      be processed seperately.
     */

    for (inx=0; inx<3; inx++)
    {
      line1[1][inx] = line1[0][inx] + proftan[0][inx]; 
      line2[1][inx] = line2[0][inx] + proftan[1][inx]; 
    }

    BSxln (&rc, line1[0], line1[1], line2[0], line2[1], ln_intpt);
    if (rc == BSSUCC && 
        BSptinbx (&rc, ln_intpt, &slrange[0], &slrange[3], &nd))
    {
      IGRvector vec;

      BSmkvec (&rc, vec, line1[0], ln_intpt);
      BSnorvec (&rc, vec);

      if (BSdotp (&rc, vec, proftan[0]) > 0.0)
      {
        BSmkvec (&rc, vec, line2[0], ln_intpt);
        BSnorvec (&rc, vec);

        if (BSdotp (&rc, vec, proftan[1]) > 0.0)
          *self_int = TRUE;
      }
    }

    if (*self_int)
    {
      /*
       * The end segments are going to intersect after extension. So, special
       * processing.
       */

      ok = ExtendCvToPt (startcv, START, ln_intpt, &extcv1);
      add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : ExtendCvToPt error",
          action = GOTO_VALUE, value = wrapup );

      if (startcvid == stopcvid)
        ok = ExtendCvToPt (extcv1, STOP, ln_intpt, &extcv2);
      else
        ok = ExtendCvToPt (stopcv, STOP, ln_intpt, &extcv2);

      add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : ExtendCvToPt error",
          action = GOTO_VALUE, value = wrapup );

      /*
       * Now generate the parameter values on the modified profile 
       * corresponding to the end points of the original profile.
       */
      OM_BLOCK_MOVE (&startcv->poles[0], startpt, sizeof(IGRpoint)); 
      OM_BLOCK_MOVE (&stopcv->poles[(stopcv->num_poles-1)*3], stoppt, 
                     sizeof(IGRpoint));
      if (startcvid == stopcvid)
      {
        cv1 = cv2 = extcv2;
      }
      else
      {
        cv1 = extcv1; cv2 = extcv2;
      }

      ok = BSprptoncv (&rc, cv1, startpt, &u_pars[0], &on_curve);
      add$status (test = !ok || BSERROR(rc) || !on_curve, msg = *msg, 
          code = EMS_E_Fail, str = "CloseProfileWithBox : BSprptoncv error",
          action = GOTO_VALUE, value = wrapup );

      ok = BSprptoncv (&rc, cv2, stoppt, &u_pars[1], &on_curve);
      add$status (test = !ok || BSERROR(rc) || !on_curve, msg = *msg, 
          code = EMS_E_Fail, str = "CloseProfileWithBox : BSprptoncv error",
          action = GOTO_VALUE, value = wrapup );

      OM_BLOCK_MOVE (startpt, xyzpts[0], sizeof(IGRpoint));
      OM_BLOCK_MOVE (stoppt, xyzpts[1], sizeof(IGRpoint));

      break;
    }
    else
    {
      /* 
       * End tangents are not intersecting. So, extension does not result in
       * self intersection of the profile.
       */

      /*
       * Extend the first segment to intersect with the box.
       */
      ok = ExtendCvToIntersectWithBox (&loc_msg, startcv, START, proftan[0], 
                                       boxpts, &start_deextended, &seginfo1, 
                                       &extcv1);
      add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : ExtendCvToIntersectWithBox error",
          action = GOTO_VALUE, value = wrapup );

      /*
       * Extend the last segmeent to intersect with the box.
       */
      if (startcvid == stopcvid)
      {
        /*
         * First and last segments are same i.e. open profile consists of only
         * one segment. So, need to extend the profile first segment again but
         * this time at stop parameter.
         */

        add$status( test = !extcv1, msg = *msg, code = EMS_E_AddRmInfinite, 
            str = "CloseProfileWithBox : Unbounded addition of material",
            action = GOTO_VALUE, value = wrapup );  

        ok = ExtendCvToIntersectWithBox (&loc_msg, extcv1, STOP, proftan[1],
                                         boxpts, &stop_deextended, &seginfo2, 
                                         &extcv2);
        add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
            str = "CloseProfileWithBox : ExtendCvToIntersectWithBox error",
            action = GOTO_VALUE, value = wrapup );

        add$status( test = !extcv2, msg = *msg, code = EMS_E_AddRmInfinite, 
            str = "CloseProfileWithBox : Unbounded addition of material",
            action = GOTO_VALUE, value = wrapup );  
      }
      else
      {
        /*
         * First and last segments are different. 
         */

        ok = ExtendCvToIntersectWithBox (&loc_msg, stopcv, STOP, proftan[1],
                                         boxpts, &stop_deextended, &seginfo2, 
                                         &extcv2);
        add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
            str = "CloseProfileWithBox : ExtendCvToIntersectWithBox error",
            action = GOTO_VALUE, value = wrapup );
      }

      if (!extcv1)
        startindx ++;

      if (!extcv2)
        stopindx --;

      if (stopindx < startindx)
        add$status( test = TRUE, msg = *msg, code = EMS_E_AddRmInfinite,
            str = "CloseProfileWithBox : Unbounded addition of material",
            action = GOTO_VALUE, value = wrapup );

      if (extcv1 && extcv2)
      {
        /*
         * Both the segments are extended to intersect with the box.
         */
  
        OM_BLOCK_MOVE (&startcv->poles[0], startpt, sizeof(IGRpoint)); 
        OM_BLOCK_MOVE (&stopcv->poles[(stopcv->num_poles-1)*3], stoppt, 
                       sizeof(IGRpoint));

        OM_BLOCK_MOVE (startpt, xyzpts[0], sizeof(IGRpoint));
        OM_BLOCK_MOVE (stoppt, xyzpts[1], sizeof(IGRpoint));

        if (start_deextended)
          u_pars[0] = 0.0;
        else
        {
          if (startcvid == stopcvid)
            cv1 = extcv2;
          else
            cv1 = extcv1;

          ok = BSprptoncv (&rc, cv1, startpt, &u_pars[0], &on_curve);
          add$status (test = !ok || BSERROR(rc) || !on_curve, msg = *msg, 
              code = EMS_E_Fail, str = "CloseProfileWithBox : BSprptoncv error",
              action = GOTO_VALUE, value = wrapup );
        }
         
        if (stop_deextended)
          u_pars[1] = 1.0;
        else
        {
          ok = BSprptoncv (&rc, extcv2, stoppt, &u_pars[1], &on_curve);
          add$status (test = !ok || BSERROR(rc) || !on_curve, msg = *msg, 
              code = EMS_E_Fail, str = "CloseProfileWithBox : BSprptoncv error",
              action = GOTO_VALUE, value = wrapup );
        } 
        break;
      }
    }
  }while(1);

  // envcv->md_id.objid = NULL_OBJID;
  // const_args->env_info->md_id.objid = NULL_OBJID; 
  const_args->newflag = FALSE;
 
  if (*self_int && !prof_ncomps)
  {
    /*
     * Profile extension results in self intersection or profile and is made 
     * of a single curve.
     */

    /*
     * Construct the object out of extended profile which resulted in 
     * self intersection.
     */
    classid = GetObjectClass (prof->objid, prof->osnum);

    GetRightClass (classid);
    const_args->geometry = (IGRchar *) extcv2;

    sts = om$construct (classid = classid, 
                        osnum   = os,
                        p_objid = &compcvid, 
                        msg = message GRvg.GRconstruct (const_args));
    add$status (test = !(1&sts), msg = *msg, code = EMS_E_Fail,
        str = "CloseProfileWithBox : om$construct error",
        action = GOTO_VALUE, value = wrapup);

    newprof_info->props |= ModProf_SelfIntersecting;
  
    for (i=0; i<2; i++)
    {
      newprof_info->parms[i].index = 0;
      newprof_info->parms[i].id = compcvid;
      newprof_info->parms[i].u = u_pars[i];
      OM_BLOCK_MOVE (xyzpts[i], newprof_info->parms[i].pt, sizeof(IGRpoint));
    }

    newprof_info->iparm.index = 0;
    newprof_info->iparm.id = compcvid;
    newprof_info->iparm.u = u_pars[0] + (u_pars[1] - u_pars[0])/2.0;
  }
  else
  {
    /*
     * Profile could be a composite/single profile.
     */

    GRobjid    copyid;
    IGRlong    index=0;

    poly_inx = 0;

    /*
     * Construct a composite curve without any components.
     */
    sts = om$construct (classid = OPP_GRcompcurve_class_id,
                        osnum   = prof->osnum,
                        p_objid = &compcvid);
    add$status (test = !(1&sts), msg = *msg, code = EMS_E_Fail,
        str = "CloseProfileWithBox : om$construct error",
        action = GOTO_VALUE, value = wrapup);

    if (prof_ncomps)
    { 
      /*
       * Composite profile. Add the components of the to the new composite
       * curve.
       */
      for(i = startindx, index=0; i<=stopindx; i++, index++)
      {
        if (i == startindx || i == stopindx)
        {
          /*
           * This is a first or last segment. So, take the extended curve
           * segments, create the objects out of them and connect to the
           * composite curve.
           */

          classid = GetObjectClass (profcomps[i], os);

          GetRightClass (classid);
          const_args->geometry = (IGRchar *) ((i == startindx) ? 
                                              extcv1 : extcv2);

          sts = om$construct (classid = classid,
                              osnum   = os,
                              p_objid = &copyid,
                              msg = message GRvg.GRconstruct (const_args));
          add$status (test = (!(1&sts)), msg = *msg, code = EMS_E_Fail,
              str = "CloseProfileWithBox : om$construct error",
              action = GOTO_VALUE, value = wrapup);

          newprof_info->parms[poly_inx].index = index;
          newprof_info->parms[poly_inx].id = copyid;
          newprof_info->parms[poly_inx].u = u_pars[poly_inx];
          OM_BLOCK_MOVE (xyzpts[poly_inx], newprof_info->parms[poly_inx].pt,
                         sizeof(IGRpoint));
          poly_inx++;
        }
        else
        {
          /*
           * It is a middle segment. Just copy it and connect to the newly
           * created composite curve.
           */

          ok = CopyObject (profcomps[i], os, envcv, &copyid);
          add$status (test = !ok, msg = *msg, code = EMS_E_Fail,
              str = "CloseProfileWithBox : CopyObject error",
              action = GOTO_VALUE, value = wrapup);

          if (i == (startindx+1))
          {
            newprof_info->iparm.index = index;
            newprof_info->iparm.id = copyid;
            newprof_info->iparm.u = 0.5;
          }
        }

        ok = ConnectObject (copyid, os, compcvid, os, index);
        add$status (test = !ok, msg = *msg, code = EMS_E_Fail,
            str = "CloseProfileWithBox : ConnectObject error",
            action = GOTO_VALUE, value = wrapup);
      }

      if (index <= 2)
      {
        newprof_info->iparm.index = newprof_info->parms[0].index;
        newprof_info->iparm.id = newprof_info->parms[0].id;
        newprof_info->iparm.u = u_pars[0] + (1.0 - u_pars[0])/2.0;
      }
    }
    else
    {
      /*
       * Single component profile. Create a new curve out of the extended 
       * curve.
       */
      index = 0;

      classid = GetObjectClass (prof->objid, prof->osnum);

      GetRightClass (classid);
      const_args->geometry = (IGRchar *) extcv2;

      sts = om$construct (classid = classid,
                          osnum   = os,
                          p_objid = &copyid,
                          msg = message GRvg.GRconstruct (const_args));
      add$status (test = (!(1&sts)), msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : om$construct error",
          action = GOTO_VALUE, value = wrapup);

      ok = ConnectObject (copyid, os, compcvid, os, index);
      add$status (test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "CloseProfileWithBox : ConnectObject error",
          action = GOTO_VALUE, value = wrapup);

      for (i=0; i<2; i++)
      {
        newprof_info->parms[i].index = index;
        newprof_info->parms[i].id = copyid;
        newprof_info->parms[i].u = u_pars[i];
        OM_BLOCK_MOVE (xyzpts[i], newprof_info->parms[i].pt, sizeof(IGRpoint));
      }
      newprof_info->iparm.index = index;
      newprof_info->iparm.id = copyid;
      newprof_info->iparm.u = u_pars[0] + (u_pars[1] - u_pars[0])/2.0;

      index ++;
    }

    if (!*self_int)
    {
      /*
       * Extension is not resulted in self intersection. Now create the 
       * new curve. 
       */

      IGRint    n_lines=0, type, incr=0;
      IGRpoint  lines[6], lnpoles[2];
      IGRdouble lnknots[4], dist1=0, dist2=0;
      struct IGRbsp_curve bsline;

      /*
       * By now, the intersection box direction is fixed by the profile normal.
       * One advantage we have in case of this box is, take any two adjacent 
       * segments of box represents same normal. Once we fixed the box directi-
       * on the way in which we want to close profile depends on the reversed
       * flag. Here instead of reversing the profile direction reverse the box
       * direction while closing.
       */
  
      memset (&bsline, 0, sizeof(struct IGRbsp_curve));
      bsline.poles = &lnpoles[0][0];
      bsline.knots = &lnknots[0];

      OM_BLOCK_MOVE (seginfo2.intpt, lines[n_lines], sizeof(IGRpoint));
      n_lines++;

      if (seginfo2.segment == seginfo1.segment)
      { 
        i = seginfo2.segment;
        dist1 = BSdistptpt (&rc, boxpts[i], seginfo1.intpt);
        dist2 = BSdistptpt (&rc, boxpts[i], seginfo2.intpt);
        
        if (reversed)
        {
          if (dist1 > dist2)
            incr = -1;
          else
            incr = 0;
        }
        else
        {
          if (dist1 > dist2)
            incr = 0;
          else 
            incr = 1;
        }

      }
      else 
      {
        if (reversed)
          incr = -1;
        else
          incr = 1;
      }

      i = seginfo2.segment;

      if (incr) 
      {
        do
        {
          if (incr > 0) i++;
          if (i > 3) i = 0;
          OM_BLOCK_MOVE (boxpts[i], lines[n_lines], sizeof(IGRpoint));
          n_lines++;
          if (incr < 0) i--;
          if (i < 0) i = 3;
        }while (i != seginfo1.segment);
      }

      OM_BLOCK_MOVE (seginfo1.intpt, lines[n_lines], sizeof(IGRpoint));
  

      for(i=0; i<n_lines; i++)
      {
        ok = BSptlngen (&rc, lines[i], lines[i+1], &bsline, &type);
        add$status (test = !ok || BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
            str = "CloseProfileWithBox : BSptlngen error", 
            action = GOTO_VALUE, value = wrapup);
 
        const_args->geometry = (IGRchar *) &bsline;
  
        sts = om$construct (classid = OPP_GR3dlineseg_class_id,
                            osnum   = prof->osnum,
                            p_objid = &lineid,
                            msg = message GRvg.GRconstruct (const_args));
        add$status (test = !(1&sts), msg = *msg, code = EMS_E_Fail,
            str = "CloseProfileWithBox : GRvg.GRconstruct error",
            action = GOTO_VALUE, value = wrapup);
  
        ok = ConnectObject (lineid, os, compcvid, os, index);
        add$status (test = !ok, msg = *msg, code = EMS_E_Fail,
            str = "CloseProfileWithBox : ConnectObject error",
            action = GOTO_VALUE, value = wrapup);
  
        index++;
      }
    }

    ok = PostObjectGeom (compcvid, prof->osnum, envcv, NULL, &compcvid);
    add$status (test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "CloseProfileWithBox : PostObjectGeom error",
        action = GOTO_VALUE, value = wrapup);

    newprof_info->props |= ModProf_Composite;
  }

  newprof_info->grid.objid = compcvid;
  newprof_info->grid.osnum = prof->osnum;
  OM_BLOCK_MOVE (prof_info->plane.point, newprof_info->plane.point, 
                 sizeof(IGRpoint));
  OM_BLOCK_MOVE (prof_info->plane.normal, newprof_info->plane.normal, 
                 sizeof(IGRvector));
  OM_BLOCK_MOVE (&prof_info->mdenv, &newprof_info->mdenv, 
                 sizeof(struct GRmd_env)); 

wrapup :

  envcv->md_id.objid = mdid;
  const_args->env_info->md_id.objid = mdid1; 
  const_args->geometry = geometry;
  const_args->newflag = newflag;

  if (startcv) om$dealloc (ptr = startcv);
  if (stopcv && (stopcv != startcv)) om$dealloc (ptr = stopcv);
  if (extcv1) om$dealloc (ptr = extcv1);
  if (extcv2) om$dealloc (ptr = extcv2);

  if (!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/*
  DESCRIPTION

     Given a curve, side i.e. start/stop to extend and point  to  which to
     extend, it extends the curve linearly and output's the extended curve 
     geometry in B-splie format which will be having the same order as in-
     coming curve. 

     If the incoming curve is a line and the point to extend  is  lying on
     the line then the extended curve also consists of two  poles, one the
     start/stop points and the other is extension point.
  
  NOTES

     All the memory for the output is allocated in this routine.

  RETURN CODE

     TRUE   - Success
     FALSE  - Failure
*/

IGRboolean ExtendCvToPt
(
struct IGRbsp_curve *cv,
IGRboolean          side,
IGRpoint            pt,
struct IGRbsp_curve **extcv
)
{
  BSrc       rc;
  IGRint     type;
  IGRlong    num_poles;
  IGRboolean ok;
  IGRpoint   endpt, poles[2];
  IGRdouble  knots[4];
  struct IGRbsp_curve lncv;

  if (cv->num_poles == 2 && !cv->rational)
  {
    /*
     * Incoming curve is a line curve.
     */

    struct IGRline line;
    double         dist; 

    line.point1 = &cv->poles[0];
    line.point2 = &cv->poles[3];

    if (MAptlndis( &rc, pt, &line, &dist))
    {
      IGRdouble basistol;

      BSEXTRACTPAR (&rc, BSTOLBASIS, basistol);

      if (dist < basistol)
      {
        /*
         * The extension point lies on the line.
         */

        BSalloccv (2, 2, 0, 0, extcv, &rc);
        if (rc != BSSUCC)
          return FALSE;

        /*
         * Post the new geometry of the curve which consists of extension
         * point.
         */

        ok = BScv_copy (&rc, cv, *extcv);
        if (side == START)
          OM_BLOCK_MOVE (pt, &(*extcv)->poles[0], sizeof(IGRpoint));
        else
          OM_BLOCK_MOVE (pt, &(*extcv)->poles[3], sizeof(IGRpoint));

        return TRUE;
      }
    }
  }

  /*
   * generate a line curve consisting of start/stop point of the curve and
   * the extension point.
   */

  memset (&lncv, 0, sizeof(struct IGRbsp_curve));
  lncv.poles = &poles[0][0];
  lncv.knots = &knots[0];

  if (side == START)
  {
    OM_BLOCK_MOVE (&cv->poles[0], endpt, sizeof(IGRpoint));
    ok = BSptlngen (&rc, pt, endpt, &lncv, &type); 
  }
  else
  {
    OM_BLOCK_MOVE (&cv->poles[(cv->num_poles-1) * 3], endpt, sizeof(IGRpoint));
    ok = BSptlngen (&rc, endpt, pt, &lncv, &type); 
  }

  if (!ok || BSERROR(rc))
    return FALSE;

  /*
   * Allocate the memory for the extension curve. Merge the incoming curve
   * and the line curve to create the extension curve.
   */

  if (cv->order == lncv.order)
    num_poles = cv->num_poles + lncv.num_poles - 1;
  else
    num_poles = cv->num_poles + lncv.num_poles + 
                ((lncv.num_poles - lncv.order + 2) *
                (cv->order - lncv.order)); 

  BSalloccv (cv->order, num_poles, cv->rational, 0, extcv, &rc);
  if (rc != BSSUCC)
    return FALSE;

  if (side == START)
  {
    ok = BSmerge_cv (&rc, &lncv, cv, *extcv); 
  }
  else
  { 
    ok = BSmerge_cv (&rc, cv, &lncv, *extcv); 
  }

  if (!ok || BSERROR(rc))
  {
    BSfreecv (&rc, *extcv);
    return FALSE;
  }

  /*
   * Reparametrize the curve, so that it does not create any further 
   * modelling problems.
   */
  BSarclnparc (&rc, *extcv);

  if (BSERROR(rc))
  {
    BSfreecv (&rc, *extcv);
    return FALSE;
  }

  return TRUE;
}

/*
  DESCRIPTION

     Given a curve, extension side i.e. start/stop,  extension vector and  a 
     box consisting of four linear segments, it linearly i.e. along tangent,
     extends the curve at the specified extension side to intersect with one 
     of the farthest segements of the box.

     If at all, there are no interaction points found in the tangent direct-
     ion, it deextends the curve to intersect with one of the farthest segm-
     ents of the box.

     It outputs a boolean flag (deextended) representing whether  the  curve 
     is extended/deextended and the segment info  (seginfo)  indicating  the 
     segment with which it found the intersection and the extended curve.

  NOTES

     All the memory for the output is allocated in this routine.

  RETURN CODE

     TRUE   - Success
     FALSE  - Failure
*/

IGRboolean ExtendCvToIntersectWithBox (
IGRlong              *EFmsg,
struct IGRbsp_curve  *cv,
IGRboolean           extside,
IGRdouble            *extvec,
IGRpoint             *boxpts,
IGRboolean           *deextended, 
struct SegmentInfo   *seginfo,
struct IGRbsp_curve  **extcv )
{
  IGRboolean     ok=TRUE, BSsts=TRUE;
  BSrc           rc;
  IGRint         n_intpts=0, i, j;
  IGRpoint       cvpt, intpt; 
  IGRdouble      dist=0, startdist=0;

  /*
   * Initialzation 
   */
  *EFmsg = EMS_S_Success;
  
  *deextended = FALSE;
  *extcv = NULL;

  /*
   * Extract the end point depending on the side to extend.
   */ 
  if (extside == START)
    OM_BLOCK_MOVE (&cv->poles[0], cvpt, sizeof(IGRpoint));
  else
    OM_BLOCK_MOVE (&cv->poles[(cv->num_poles-1) * 3], cvpt, sizeof(IGRpoint));

  for (i=0; i<4; i++)  
  {                   
    /* 
     * For each segment of the box, intersect an infinite vector in the 
     * direction of input extvec starting at the cvpt. 
     */

    if (i==3)
      j = 0;
    else j = i+1;

    if (IntersectBoundedLineWithDirectedVector(boxpts[i], boxpts[j], cvpt, 
                                               extvec, intpt))
    {
      /*
       * An intersection point exists between the segment and the directed
       * extension vector starting at one of the end points of the curve.
       */

      dist = BSdistptpts (&rc, cvpt, intpt);
      if (n_intpts)
      {
        /*
         * Already some intersection points are found. So, post the  one
         * which is at the maximum distance from cvpt as the current one.
         */
 
        if (dist > startdist)
        {
          seginfo->segment = i;
          OM_BLOCK_MOVE (intpt, seginfo->intpt, sizeof(IGRpoint));
          startdist = dist;
        }
      }
      else
      {
        startdist = dist;
        seginfo->segment = i;
        OM_BLOCK_MOVE (intpt, seginfo->intpt, sizeof(IGRpoint));
      }
       
      n_intpts++;
    }
  }

  if (!n_intpts)
  {
    IGRint    type, n_int=0; 
    IGRlong   n_over=0;
    struct IGRbsp_curve  bsln;
    IGRpoint  poles[2];
    IGRdouble knots[4], *intpts=NULL, *par0=NULL, *par1=NULL, *over0=NULL, 
              *over1=NULL, *end_pts=NULL;

    *deextended = TRUE;

    memset (&bsln, 0, sizeof(struct IGRbsp_curve));
    bsln.poles = &poles[0][0];
    bsln.knots = &knots[0];

    for (i=0; i<4; i++)
    {
      if (i==3)
        j = 0;
      else j = i+1;
     
      if (i)
      {
        OM_BLOCK_MOVE (boxpts[i], poles[0], sizeof(IGRpoint)); 
        OM_BLOCK_MOVE (boxpts[j], poles[1], sizeof(IGRpoint)); 
      }
      else
      {
        BSsts = BSptlngen (&rc, boxpts[i], boxpts[j], &bsln, &type);
        add$status (test = !BSsts || BSERROR(rc), msg = *EFmsg, 
            code = EMS_E_BSerror, str = "ExtendCvToIntersectWithBox : BSptlngen error", 
            action = GOTO_VALUE, value = wrapup);

      }

      BSsts = BScvcv_int (&rc, cv, &bsln, &n_int, &intpts, &par0, &par1, 
                          &n_over, &end_pts, &over0, &over1);
      add$status (test = !BSsts || BSERROR(rc), msg = *EFmsg, 
          code = EMS_E_BSerror, str = "ExtendCvToIntersectWithBox : BScvcv_int error", 
          action = GOTO_VALUE, value = wrapup);

      add$status (test = n_int > 1 || n_over > 0, msg = *EFmsg, 
          code = EMS_E_Fail, str = "ExtendCvToIntersectWithBox : Number of Intersections / overlaps is greater than one", 
          action = GOTO_VALUE, value = wrapup);

      if (n_int == 1)
      {
        seginfo->segment = i;
        OM_BLOCK_MOVE (&intpts[0], seginfo->intpt, sizeof(IGRpoint));
        
        BSalloccv (cv->order, (cv->num_poles + 3 * (2 * cv->order - 1)), 
                   cv->rational, cv->num_boundaries, extcv, &rc);
        add$status (test = BSERROR(rc), msg = *EFmsg, code = EMS_E_BSerror, 
            str = "ExtendCvToIntersectWithBox : BSalloccv error", 
            action = GOTO_VALUE, value = wrapup);

        BSsts = BSpolyxttpt (&rc, cv, cvpt, &intpts[0], *extcv);
        add$status (test = !BSsts || BSERROR(rc), msg = *EFmsg, code = EMS_E_BSerror, 
            str = "ExtendCvToIntersectWithBox : BSpolyxttpt error", 
            action = GOTO_VALUE, value = wrapup);

        break;
      }
    }
  }
  else
  {
    ok = ExtendCvToPt (cv, extside, seginfo->intpt, extcv);
    add$status (test = !ok, msg = *EFmsg, code = EMS_E_Fail, 
            str = "ExtendCvToIntersectWithBox : ExtendCvToPt error", 
            action = GOTO_VALUE, value = wrapup);
  }

wrapup :
  if (!(1&*EFmsg))
    return FALSE;
  else
    return TRUE;
}

/*
  DESCRIPTION

     Given a box consisting of four segments and a range box, it extends 
     the box to enclose the rangebox and ouputs a flag whether it is ex-
     tended or not.

  NOTES

     All the memory for the output must be allocated by the caller.

  RETURN CODE

     TRUE   - Success
     FALSE  - Failure
*/

IGRboolean ExtendPolyToEncloseRangeBox(
IGRlong    *EFmsg,
IGRpoint   *polypts, 
IGRdouble  *range,
IGRdouble  *normal,
IGRboolean *extended,
IGRpoint   *newpts )
{
  BSrc        rc=BSSUCC;
  IGRint      i=0, j=0, k=0, num=0;
  IGRlong     msg=EMS_S_Success;
  IGRboolean  BSsts=TRUE; 
  IGRvector   vec, vec1, crossvec;
  IGRdouble   par1[2], par2[2], dist, cht;
  IGRpoint    pts[2], int_pts[2];
 
  *EFmsg = EMS_S_Success;
  BSEXTRACTPAR (&msg, BSTOLCHRDHT, cht);
  if (extended) *extended = FALSE;

  /*
   * first copy all the polygon points to new points
   */
  OM_BLOCK_MOVE (polypts, newpts, 4*sizeof(IGRpoint));

  /*
   * make diagonal vector of the range box
   */
  BSmkvec (&rc, vec, &range[0], &range[3]);
  BSnorvec (&rc, vec);

  for (i=0; i<4; i++)
  {
    if (i == 3)
      j = 0;
    else j = i+1;

    /*
     * intersect the diagonal of the range box with the polygon line
     */
    num = 0;
    OM_BLOCK_MOVE (newpts[i], pts[0], sizeof(IGRpoint));
    OM_BLOCK_MOVE (newpts[j], pts[1], sizeof(IGRpoint));

    BSxlnln ((IGRpoint *) range, pts, &num, int_pts, par1, par2, &rc);
    add$status (test = BSERROR(rc), msg = *EFmsg, code = EMS_E_BSerror,
        str = "ExtendPolyToEncloseRangeBox : BSxlnln error",
        action = GOTO_VALUE, value = wrapup );

    add$status (test = (num == 2), msg = *EFmsg, code = EMS_E_BSerror,
        str = "ExtendPolyToEncloseRangeBox : BSxlnln resulting in two intersection points.",
        action = GOTO_VALUE, value = wrapup );

    /*
     * if there is an intersection, then polygon line should be moved 
     * along the diagonal vector, so that the polygon  line will have
     * no more intersections with the diagonal.
     */ 

    if (num)
    {
      IGRpoint line[2], intpt;

      BSmkvec (&rc, vec1, pts[0], pts[1]);
      BSnorvec (&rc, vec1);

      BScrossp (&rc, vec1, vec, crossvec);

      if (BSdotp(&rc, crossvec, normal) > 0.0)
      {
        dist = BSdistptpt (&rc, int_pts[0], &range[3]) + 100 * cht;

        for(k=0; k<3; k++)
          line[0][k] = newpts[i][k] + vec[k] * dist;
      }
      else
      {
        dist = BSdistptpt (&rc, int_pts[0], &range[3]) + 100 * cht;

        for(k=0; k<3; k++)
          line[0][k] = newpts[i][k] - vec[k] * dist;
      }

      for(k=0; k<3; k++)
        line[1][k] = line[0][k] + vec1[k];

      /*
       * intersect this line with the adjacent line segments to find the
       * new polygon points
       */
      if (i)
        k = i-1;
      else k = 3;

      BSsts = BSxln (&rc, line[0], line[1], newpts[k], newpts[i], intpt);
      add$status (test = !BSsts || BSERROR(rc), msg = *EFmsg, 
          code = EMS_E_BSerror, str = "ExtendPolyToEncloseRangeBox : BSxln error",
        action = GOTO_VALUE, value = wrapup );

      OM_BLOCK_MOVE (intpt, newpts[i], sizeof(IGRpoint));

      if (j == 3)
        k = 0;
      else k = j+1;

      BSsts = BSxln (&rc, line[0], line[1], newpts[k], newpts[j], intpt);
      add$status (test = !BSsts || BSERROR(rc), msg = *EFmsg,
          code = EMS_E_BSerror, str = "ExtendPolyToEncloseRangeBox : BSxln error",
        action = GOTO_VALUE, value = wrapup );

      OM_BLOCK_MOVE (intpt, newpts[j], sizeof(IGRpoint));

      if (extended) *extended = TRUE;
    }
  }

wrapup :

  if (!(1&*EFmsg))
    return FALSE;
  else
    return TRUE;
} 

/*
  DESCRIPTION

     Given a surface/solid, it finds the range box stored in the R-Tree
     for this surface/solid. For a solid it is the union of the of  the
     range boxes of it's indvidual components.

  NOTES

     All the memory for the output must be allocated by the caller.

  RETURN CODE

     TRUE   - Success
     FALSE  - Failure
*/

IGRboolean GetSurfaceRtreeRange(
GRobjid          sfid,
OMuword          sfos,
struct GRmd_env  *sfenv,
IGRdouble        *sfrange)
{
  IGRint       num=0, i=0, newnum=0;
  IGRlong      msg = EMS_S_Success, sts=OM_S_SUCCESS;
  IGRboolean   world=TRUE;
  GRrange      range;
  GRobjid      *comps=NULL;

  num = pwNumSfsOfCompSf (sfid, sfos);
  if (!num)
    return FALSE;

  comps = (GRobjid *) alloca (num * sizeof (GRobjid));
  if (!comps)
    return FALSE;

  newnum = pwGetSfsOfCompSf (sfid, sfos, comps);
  if (newnum != num)
    return FALSE;

  for (i=0; i<num; i++)
  {
    sts = om$send( msg = message EMSsubbs.EMrtreerange (&msg, 
                         &sfenv->md_env.matrix_type, sfenv->md_env.matrix,
                         &world, range), 
                   senderid = comps[i],
                   targetid = comps[i],
                   targetos = sfos);
    if(!(1&sts&msg)) 
      return FALSE;

    if (i)
      GRaccumulate_range (&msg, range, sfrange);
    else
      OM_BLOCK_MOVE (range, sfrange, sizeof(GRrange));
  }

  return TRUE;
}

/*
  DESCRIPTION

     Given a bounded line and a directed vector (a vector with starting 
     point), it returns intersetion point between the bounded line  and
     directed vector if any.

  NOTES

     All the memory for the output must be allocated by the caller.

  RETURN CODE

     TRUE   - If there is an intersection point found
     FALSE  - Otherwise.
*/

IGRboolean IntersectBoundedLineWithDirectedVector
(
IGRpoint   bound_lnpt1,
IGRpoint   bound_lnpt2,
IGRpoint   dir_vecpt, // start point of the direction vector
IGRpoint   dir_vec,   // Unit direction vector
IGRpoint   intpt
)
{
  BSrc        rc=BSSUCC;
  IGRint      i;
  IGRboolean  ok, intersect=FALSE;
  IGRpoint    dir_vecpt1;

  for(i=0; i<3; i++)
    dir_vecpt1[i] = dir_vecpt[i] + dir_vec[i];

  ok = BSxln (&rc, bound_lnpt1, bound_lnpt2, dir_vecpt, dir_vecpt1, intpt);
  if (rc == BSSUCC)
  {
    IGRint     ln_code=0;
    IGRdouble  par;

    /*
     * Test whether the intersection point is on bounded line or not
     */
    BSprptonln (bound_lnpt1, bound_lnpt2, intpt, &ln_code, &par, &rc);

    if (ln_code != 0) 
    {
      IGRvector vec;

      BSmkvec (&rc, vec, dir_vecpt, intpt);
      BSnorvec (&rc, vec);
 
      if (BSdotp(&rc, vec, dir_vec) > 0.0)
        intersect = TRUE;
    }
  }
  
  return intersect;   
}

/*
  DESCRIPTION

     Given the segments of a box containing 4 segments, it arranges the
     points such that they form a TRUE polygon (non-self-intersection).

  NOTES

     None
*/

static void GetRightBox
(
  IGRdouble *boxpts, 
  IGRdouble *normal
)
{
  BSrc       BSmsg;
  IGRint     numint=0, i, j;
  IGRdouble  par1[2], par2[2], out_boxpts[12];
  IGRpoint   int_pts[2], line1[2], line2[2];
  IGRvector  vec1, vec2, crossvec;
 
  OM_BLOCK_MOVE (boxpts, out_boxpts, 4 * sizeof(IGRpoint));
 
  OM_BLOCK_MOVE (out_boxpts, line1, 2 * sizeof(IGRpoint));
  OM_BLOCK_MOVE (&out_boxpts[6], line2, 2 * sizeof(IGRpoint));
 
  BSxlnln (line1, line2, &numint, int_pts, par1, par2, &BSmsg);
  if (BSERROR(BSmsg) || !numint)
  {
    /* interchange 2 and 4 */
    OM_BLOCK_MOVE (&out_boxpts[3], int_pts, sizeof(IGRpoint));
    OM_BLOCK_MOVE (&out_boxpts[9], &out_boxpts[3], sizeof(IGRpoint));
    OM_BLOCK_MOVE (int_pts, &out_boxpts[9], sizeof(IGRpoint));

    OM_BLOCK_MOVE (out_boxpts, line1, 2 * sizeof(IGRpoint));
    OM_BLOCK_MOVE (&out_boxpts[6], line2, 2 * sizeof(IGRpoint));
 
    BSxlnln (line1, line2, &numint, int_pts, par1, par2, &BSmsg);
  }
 
  if (numint)
  {
    /* interchange 2 and 3 */
 
    OM_BLOCK_MOVE (&out_boxpts[3], int_pts, sizeof(IGRpoint));
    OM_BLOCK_MOVE (&out_boxpts[6], &out_boxpts[3], sizeof(IGRpoint));
    OM_BLOCK_MOVE (int_pts, &out_boxpts[6], sizeof(IGRpoint));
 
    OM_BLOCK_MOVE (out_boxpts, boxpts, 4 * sizeof(IGRpoint));
  }

  /* 
   * Now, see whether it consistutes the same normal or not, otherwise
   * interchange the points again.
   */
  BSmkvec (&BSmsg, vec1, &boxpts[3], &boxpts[0]);
  BSmkvec (&BSmsg, vec2, &boxpts[3], &boxpts[6]);
  BScrossp (&BSmsg, vec1, vec2, crossvec);
  BSnorvec (&BSmsg, crossvec);

  if (BSdotp (&BSmsg, crossvec, normal) < 0.0)
  {
    OM_BLOCK_MOVE (boxpts, out_boxpts, 4 * sizeof(IGRpoint));
    for (i=0,j=3; i<4; i++,j--) 
    {
      OM_BLOCK_MOVE (&out_boxpts[j*3], &boxpts[i*3], sizeof(IGRpoint));
    }
  }
}

/*
  DESCRIPTION

     Reverses a given vector.

  NOTES

     None
*/

static void ReverseVector
(
IGRdouble *vec
)
{
 int inxm;
 for(inxm=0; inxm<3; inxm++)
   vec[inxm] *= (-1.0);
}

/*
  DESCRIPTION

    Given the minimum and maximum of the range box, a plane and the projection
    vector along which the box needs to be intersected with the plane, it exp-
    ands the range box such that it fully intersects with the plane and returns
    the intersection points. Normally the number of intersections output will
    be 4, but maximum will be 6. 

  NOTES

    The caller must allocate the memory for the intersection points that is 
    maximum of 6 points.
*/

IGRboolean ExtendAndIntersectBoxWithPlane
(
  IGRpoint  minpt,
  IGRpoint  maxpt,
  IGRpoint  pt,
  IGRvector normal,
  IGRvector projvec,
  IGRint    *numint,
  IGRpoint  *intpts
)
{
  BSrc       BSmsg=BSSUCC;
  IGRlong    msg=EMS_S_Success;
  IGRint     i=0, inx=0;
  IGRpoint   lnpt1, lnpt2, cubepts[8], tintpts[8];
  IGRvector  nprojvec;
  IGRdouble  diag=0;
  PWrange    intpts_range;

  /*
   * Normalize the projection vector.
   */
  pwNormVec (projvec, nprojvec); 

  /*
   * Get all the corner points of the range box.
   */
  GetCubePts (minpt, maxpt, cubepts); 

  for (i=0; i<8; i++)
  {
    /*
     * For each point of this corner point, generate a line along the 
     * projection vector.
     */

    OM_BLOCK_MOVE (cubepts[i], lnpt1, sizeof (IGRpoint));
    for (inx=0; inx<3; inx++)
       lnpt2[inx] = lnpt1[inx] + nprojvec[inx];

    /*
     * Intersect this infinite line with the infinite plane. If the line
     * happened to be on the plane, then take this point as the interse-
     * ction point.
     */ 

    BSxlnpl (&BSmsg, normal, pt, lnpt1, lnpt2, tintpts[i]);

    if (BSmsg == BSCOINCIDENT)
    {
      BSmsg = BSSUCC;
      OM_BLOCK_MOVE (cubepts[i], tintpts[i], sizeof (IGRpoint));
    }

    add$status (test = BSERROR(BSmsg), msg = msg, code = EMS_E_AddRmDisjoint, 
        str = "ExtendAndIntersectBoxWithPlane : BSxlnpl error",
        action = GOTO_VALUE, value = wrapup );
  }

  /*
   * get the range of the above generated intersection points and expand it
   * by 5 % of the diagonal distance.
   */

  pwGetRange (8, tintpts, intpts_range);

  diag = pwDistPtPt (intpts_range[MINIMUM], intpts_range[MAXIMUM]);
  
  pwExpandRange (intpts_range, (0.05 * diag));


  /*
   * Intersected the expanded range box with the infinite plane to generate
   * the intersection points.
   */

  BSrgbxplint (intpts_range[MINIMUM], intpts_range[MAXIMUM], pt, normal, 1.0,
               numint, intpts, &BSmsg);
  add$status (test = BSERROR(BSmsg), msg = msg, code = EMS_E_BSerror,
      str = "ExtendAndIntersectBoxWithPlane : BSrgbxplint error", 
      action = GOTO_VALUE, value = wrapup);

wrapup :

  if (msg & 1)
    return TRUE;
  else
    return FALSE;
}

/*
  DESCRIPTION

    Given the minimum and maximum points of the cube, it returns all the 
    corners of the cube.

  NOTES

    Caller must allocate for the corner points.
*/

void GetCubePts
(
  IGRpoint  minpt, 
  IGRpoint  maxpt,
  IGRpoint  cubepts[8]
)
{
  int pt=0;

  for (pt=0; pt<4; pt++)
    OM_BLOCK_MOVE (minpt, cubepts[pt], sizeof (IGRpoint));

  cubepts [1][1] = maxpt[1]; 

  cubepts [2][0] = maxpt[0];
  cubepts [2][1] = maxpt[1];

  cubepts [3][0] = maxpt[0]; 

  for (pt=4; pt<8; pt++)
    OM_BLOCK_MOVE (maxpt, cubepts[pt], sizeof (IGRpoint));

  cubepts [4][0] = minpt[0]; 
  cubepts [4][1] = minpt[1]; 

  cubepts [5][0] = minpt[0];

  cubepts [7][1] = minpt[1];
}


/*
  OVERVIEW

  NOTES

  HISTORY
*/

/* Prototypes */

#include "bssfnormal.h"

#include "PWapi/mergegm.h"
#include "PWapi/cvcons.h"
#include "PWapi/sflp.h"
#include "PWapi/lped.h"
#include "PWapi/sfgeom.h"
#include "PWapi/cvcompcv.h"
#include "PWapi/cvgeom.h"
#include "PWapi/clxyzcvfc.h"
#include "PWapi/clsid.h"
#include "PWapi/gmdatamem.h"
#include "PWapi/mx.h"

PWresult AddRmProcessCoplanar
(
  PWobjid cvobj,
  PWobjid fcobj, 
  PWosnum os,

  PWvector cvnormal,

  struct GRvg_construct *p_constargs,

  int *num_outcvs,
  PWobjid **p_outcvobj,
  PWboolean *extended
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;

  int num_loops=0, *num_edges_loop=NULL, start_inx=0, stop_inx=0, knt=0;
  struct PWgeomloop *p_loops=NULL, *p_prev_node=NULL, *p_next_node=NULL;
  struct PWgeomloop *p_start_node=NULL, *p_stop_node=NULL;
  PWboolean start_extended=FALSE, stop_extended=FALSE, reverse=FALSE;
  PWboolean merge_start=FALSE, merge_stop=FALSE;
  double lentol=0;

  short mattyp=MAIDMX;
  PWmatrix idmx;
  PWobjid sfobj=PW_K_NullObjid;
  struct IGRbsp_surface *p_sfgeom=NULL;
  PWvector sfnormal;
  IGRboolean aflag=0;

  int num_cvs=0; 
  PWobjid *p_cvobj=NULL;
  struct PWcvdata *p_cv=NULL;
  PWclassid cvclass=0;

  *num_outcvs = 0;
  *p_outcvobj = NULL;
  *extended = FALSE;

  /*
   * Determine whether the loop need to be reversed or not.
   */
  sfobj = pwSfOfLp (fcobj, os);
  OnErrorState (sfobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  if (aflag=pwIsActivationOn())
  {
    struct GRmd_env rfenv;
    pwGetActiveModuleEnv(&rfenv);

    PWsts = PW_GetSfBspsfStack (sfobj, os,rfenv.md_env.matrix_type,
                                rfenv.md_env.matrix , p_sfgeom);
  }
  else
  {
  PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, pwIdMx (idmx), p_sfgeom);
  }
  OnErrorCode (PWsts, wrapup);
  OnErrorState (!p_sfgeom->planar, PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  BSsfnormal (p_sfgeom, sfnormal, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  pwNormVec (sfnormal, sfnormal);

  if (pwDot (sfnormal, cvnormal) > 0.0)
    reverse = FALSE;
  else
    reverse = TRUE;

  /*
   * Get the geometry of all the curve component objects.
   */
  num_cvs = pwNumCvsOfCompCv (cvobj, os);
  OnErrorState (!num_cvs, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  p_cvobj = (PWobjid *) alloca (num_cvs * sizeof (PWobjid));
  OnErrorState (!p_cvobj, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                wrapup);

  num_cvs = pwCvsOfCompCv (cvobj, os, p_cvobj);
  OnErrorState (!num_cvs, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  p_cv = (struct PWcvdata *) alloca (num_cvs * sizeof (struct PWcvdata));
  OnErrorState (!p_cv, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory), 
                wrapup);

  /*
   * Get the model-space geometry.
   */
  for (knt=0; knt<num_cvs; knt++)
  {
    PWsts = PW_GetCvCvdataStack (p_cvobj[knt], os, mattyp, idmx, p_cv[knt]);
    OnErrorCode (PWsts, wrapup);
  }

  BSEXTRACTPAR (&BSmsg, BSTOLBASIS, lentol);

  /* 
   * Close the curve with face boundaries.
   */
  PWsts = pwCloseXyzCompCvWithFaceBounds (num_cvs, p_cv, fcobj, os, reverse,
                 NULL, NULL, FALSE, lentol, &start_extended, &stop_extended,
                 &num_loops, &num_edges_loop, &p_loops);
  OnErrorCode (PWsts, wrapup);

  if (start_extended || stop_extended)
    *extended = TRUE;
  else
    *extended = FALSE;

  /*
   * Determine whether to merge the end curves or not.
   */
  cvclass = omClassidFromObjid (p_cvobj[0], os);
  if (omIsAncestryValid (cvclass, OPP_GRlinear_class_id))
    merge_start = TRUE;
  else
    merge_start = FALSE;

  cvclass = omClassidFromObjid (p_cvobj[num_cvs-1], os);
  if (omIsAncestryValid (cvclass, OPP_GRlinear_class_id))
    merge_stop = TRUE;
  else
    merge_stop = FALSE;

  *num_outcvs = num_loops;
  (*p_outcvobj) = (PWobjid *) malloc (num_loops * sizeof (PWobjid));
  OnErrorState (!*p_outcvobj, PWsts, SetError (PW_K_Pathway, PW_K_Memory), 
                wrapup);

  start_inx = 0; stop_inx=0;
  for (knt=0; knt<num_loops; knt++)
  {
    if (!stop_inx)
      stop_inx = num_edges_loop[knt] - 1;
    else
      stop_inx += num_edges_loop[knt];

    p_start_node = pwNodeAtInxGeomloop (p_loops, start_inx);
    p_stop_node = pwNodeAtInxGeomloop (p_loops, stop_inx);
    p_prev_node = p_start_node->p_prev;
    p_next_node = p_stop_node->p_next;
    p_start_node->p_prev = NULL;
    p_stop_node->p_next = NULL;

    PWsts = create_cvobj_from_loop (p_start_node, merge_start, merge_stop,
                              num_cvs, os, lentol, p_constargs, 
                              &(*p_outcvobj)[knt]);
    OnErrorCode (PWsts, wrapup);

    start_inx = stop_inx + 1;
    p_start_node->p_prev = p_prev_node;
    p_stop_node->p_next = p_next_node;
  }

wrapup :

  if (p_loops) pwFreeGeomloop (p_loops); p_loops = NULL;

  PW_Wrapup (PWsts, "AddRmProcessCoplanar");
  return PWsts;
}

/*
 * Create Curve Objects.
 */

static PWresult create_cvobj_from_loop
(
  struct PWgeomloop *p_loop,
  PWboolean merge_start,
  PWboolean merge_stop,
  int num_cvs,
  PWosnum os,

  double lentol,
  struct GRvg_construct *p_constargs,

  PWobjid *cvobj
)
{
  PWresult PWsts=PW_K_Success;

  int num_outcvs=0, num_edges=0, ident=0, cvinx=0, cvinx1=0, knt=0, inx=0;
  PWobjid *p_cvobj=NULL;
  PWboolean *p_process=NULL;
  struct PWgeomloop *p_node=NULL, *p_next_node=NULL, *p_prev_node=NULL;
  struct PWgeomloop *p_startnode1=NULL, *p_startnode2=NULL;
  struct PWgeomloop *p_stopnode1=NULL, *p_stopnode2=NULL;
  PWboolean loc_merge_start=merge_start, loc_merge_stop=merge_stop;
  struct PWcvdata **p_cv=NULL, startcv, stopcv;

  *cvobj = PW_K_NullObjid;
  startcv.datatype = PWcvdata_null;
  stopcv.datatype = PWcvdata_null;

  /*
   * First create the individual curve objects.
   */
  num_edges = pwNumGeomloop (p_loop);
  p_cvobj = (PWobjid *) alloca (num_edges * sizeof (PWobjid));
  OnErrorState (!p_cvobj, PWsts, SetError (PW_K_Pathway, PW_K_Memory), wrapup);
  p_process = (PWboolean *) alloca (num_edges * sizeof (PWboolean));
  OnErrorState (!p_process, PWsts, SetError (PW_K_Pathway, PW_K_Memory), 
                wrapup);
  for (knt=0; knt<num_edges; knt++)
    p_process[knt] = TRUE;

  ident = PW_AttribIdent (PW_K_Trimming, PW_K_CurveInxAttr, 0);

  p_node = p_loop;
  while (p_node)
  {
    if (!loc_merge_start && !loc_merge_stop)
      break;

    if (pwGetIntAttrib (p_node->p_attrib, ident, &cvinx))
    {
      if ((cvinx == 0 || cvinx == -1) && loc_merge_start)
      {
        if (cvinx == 0)
        {
          p_prev_node = p_node->p_prev ? p_node->p_prev : 
                                         pwTailGeomloop (p_loop);
          if (pwGetIntAttrib (p_prev_node->p_attrib, ident, &cvinx1) && 
              cvinx1 == -1)
          {
            p_startnode1 = p_prev_node;
            p_startnode2 = p_node;
            pwInxOfNodeGeomloop (p_loop, p_node, &inx);
            p_process[inx] = FALSE;
            pwInxOfNodeGeomloop (p_loop, p_prev_node, &inx);
            p_process[inx] = FALSE;
            loc_merge_start = FALSE;
          }
        }
        else 
        {
          p_next_node = p_node->p_next ? p_node->p_next : p_loop;
          if (pwGetIntAttrib (p_next_node->p_attrib, ident, &cvinx1) && 
              cvinx1 == 0)
          {
            p_startnode1 = p_node;
            p_startnode2 = p_next_node;
            pwInxOfNodeGeomloop (p_loop, p_node, &inx);
            p_process[inx] = FALSE;
            pwInxOfNodeGeomloop (p_loop, p_next_node, &inx);
            p_process[inx] = FALSE;
            loc_merge_start = FALSE;
          }
        }
      }
  
      if (loc_merge_stop && (cvinx == (num_cvs - 1) || cvinx == num_cvs))
      {
        if (cvinx == (num_cvs-1))
        {
          p_next_node = p_node->p_next ? p_node->p_next : p_loop;
          if (pwGetIntAttrib (p_next_node->p_attrib, ident, &cvinx1) &&
              cvinx1 == num_cvs)
          {
            p_stopnode1 = p_node;
            p_stopnode2 = p_next_node;
            pwInxOfNodeGeomloop (p_loop, p_node, &inx);
            p_process[inx] = FALSE;
            pwInxOfNodeGeomloop (p_loop, p_next_node, &inx);
            p_process[inx] = FALSE;
            loc_merge_stop = FALSE;
          }
        }
        else
        {
          p_prev_node = p_node->p_prev ? p_node->p_prev : 
                                         pwTailGeomloop (p_loop);
          if (pwGetIntAttrib (p_prev_node->p_attrib, ident, &cvinx1) &&
              cvinx1 == (num_cvs - 1))
          {
            p_stopnode1 = p_prev_node;
            p_stopnode2 = p_node;
            pwInxOfNodeGeomloop (p_loop, p_prev_node, &inx);
            p_process[inx] = FALSE;
            pwInxOfNodeGeomloop (p_loop, p_node, &inx);
            p_process[inx] = FALSE;
            loc_merge_stop = FALSE;
          }
        }
      }
    }

    p_node = p_node->p_next;
  }

  if (num_cvs == 1 && merge_start && merge_stop && p_startnode1 &&
      p_startnode2 && p_stopnode1 && p_stopnode2 && 
      (p_startnode2 == p_stopnode1))
  {
    struct PWcvdata cvdata;

    PWsts = pwMergeCvdata (&p_startnode1->edge, &p_startnode2->edge, lentol, 
                           &cvdata);
    OnErrorCode (PWsts, wrapup);

    PWsts = pwMergeCvdata (&cvdata, &p_stopnode2->edge, lentol, &startcv);
    OnErrorCode (PWsts, wrapup);

    pwFreeCvdataGeom (&cvdata);
    p_stopnode1 = p_stopnode2 = NULL;
  }
  else
  {
    if (merge_start && p_startnode1 && p_startnode2)
    {
      PWsts = pwMergeCvdata (&p_startnode1->edge, &p_startnode2->edge, 
                             lentol, &startcv);
      OnErrorCode (PWsts, wrapup);
    }

    if (merge_stop && p_stopnode1 && p_stopnode2)
    {
      PWsts = pwMergeCvdata (&p_stopnode1->edge, &p_stopnode2->edge, lentol,
                             &stopcv);
      OnErrorCode (PWsts, wrapup);
    }
  }

  p_cv = (struct PWcvdata **) alloca (num_edges * sizeof (struct PWcvdata *));
  OnErrorState (!p_cv, PWsts, SetError (PW_K_Pathway, PW_K_Memory), wrapup);
 
  knt = 0; num_outcvs=0;
  p_node = p_loop;

  while (p_node)
  {
    if (!p_process[knt])
    {
      if (p_startnode1 == p_node || p_startnode2 == p_node)
      {
        p_cv[num_outcvs] = &startcv;
        p_startnode1 = p_startnode2 = NULL;
        num_outcvs ++;
      }
      else if (p_stopnode1 == p_node || p_stopnode2 == p_node)
      {
        p_cv[num_outcvs] = &stopcv;
        p_stopnode1 = p_stopnode2 = NULL;
        num_outcvs ++;
      }
    }
    else
    {
      p_cv[num_outcvs] = &p_node->edge;
      num_outcvs ++;
    } 

    p_node = p_node->p_next;
    knt ++;
  }
  
  for (knt=0; knt<num_outcvs; knt++)
  { 
    p_cvobj[knt] = pwCreateCvObj (p_cv[knt], os);
    OnErrorState (p_cvobj[knt] == PW_K_NullObjid, PWsts, 
     SetError (PW_K_Pathway, PW_K_Error), wrapup);
  }

  if (num_outcvs > 1)
  {
    long OMsts=OM_S_SUCCESS; 
    PWboolean ok=FALSE;
    PWobjid compcvobj=PW_K_NullObjid;

    OMsts = om$construct (classid = OPP_GRcompcurve_class_id, osnum = os,
                          p_objid = &compcvobj);
    OnErrorCode (OMsts, wrapup);

    for (knt=0; knt<num_outcvs; knt++)
    {
      ok = ConnectObject (p_cvobj[knt], os, compcvobj, os, knt);
      OnErrorState (!ok, PWsts, SetError (PW_K_Pathway, PW_K_Internal), 
                    wrapup);
    }

    ok = PostObjectGeom (compcvobj, os, p_constargs->env_info, NULL, 
                         &compcvobj);
    OnErrorState (!ok, PWsts, SetError (PW_K_Pathway, PW_K_Internal), 
                  wrapup);
    
    *cvobj = compcvobj;
  }
  else
  {
    *cvobj = p_cvobj[0];
  }

wrapup :

  pwFreeCvdataGeom (&startcv);
  pwFreeCvdataGeom (&stopcv);
  PW_Wrapup (PWsts, "create_cvobj_from_loop");
  return PWsts;
}

end implementation Root;

