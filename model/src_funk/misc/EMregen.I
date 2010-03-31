/*

DESCRIPTION:
  This function trims each intobj on the input 'inters' node with respect
  to its adjacent two (previous and next) intobjs and finally constructs
  loops obejcts. It also nests the loop appropriately in the surface's loopset.


  IGRlong EMregen_tpgy(msg, inters, orig_sf, const_list, options)
 
  Arguments:

  IGRlong 	  	*msg		- Error return code   - O
  struct EMSinters 	**inters	- Inters node of the  - I/O
			   		  surface on which
			  	  	  topolgy is to be
			  	  	  recreated.
  struct GRid	      	orig_sf		- The original surf.  - I
			  	  	  from whose loopset
			  	  	  the topology is
			  	  	  extracted.
  struct GRvg_construct	*const_list	- Construction list   - I
  IGRshort		options		- (For future use)    - I


ALGORITHM:

Note on input 'inters' : 
The input 'inters' node should consist of sets of intobjs. An intobj set 
is a set of intobjs forward and backward connected cyclically. Each set
corresponds to a loop that is to be eventually formed and each intobj in a
set corresponds to an edge to be eventually constructed. All the intobjs are
'in place' ie the appear in the same order in which the edges would appear
on the finally created loop. 
The last intobj of one set will be connected to the first intobj of the next 
set via the 'next' pointer. The last intobj on the last set is NULL
terminated.

PHASE A
For every intobj in a set get its next adjacent intobj  (pointed to by the 
'fwd' field) and do the following:

1) INTERSECT THE INTOBJS
   Intersect the intobj pair to get the split point. Since all the 
   incoming intobjs are ordered, this split point will become new "END" point 
   for the intobj being processed and the "START" point for the adjacent
   intobj.
   If the more_info of the 'current' intobj is not NULL, then it is assumed 
   that this  points to the split point ( "END" point for the current intobj). 
   In this case the intobj will not be intersected with its next adjacent 
   intobj. This is useful especially if we know apriori that intersection 
   will not yield a unique intersection point (eg. overlapping intobjs). 
   So the caller can handle such special cases by providing the correct split 
   point in the 'more_info'.

2) TRIM INTOBJS AT SPLIT POINT
   Using the split point obtained (Step 1) split the two intobjs.  If there is 
   an "other_intobj" for the intobj, that too gets split.
   Before splitting, the intobjs pointed by the 'fwd' and 'bwd' pointers are 
   temporarily saved.
   Delete one of the intobjs out of the two intobjs resulting from the split
   operation. The piece to be deleted is determined by whether the intobj is
   to be trimmed at the START or at the END. Set the intobj property bit
   EMSintobj_exact_atstop and EMSintobj_exact_atstart accordingly on the
   retained piece. If 'other_intobj' existed then its start/stop property 
   also is set appropriately (based on whether reverse connected or not).
   The saved 'fwd' and 'bwd' connected intobjs of the intobj (before trimming)
   are restored on the 'trimmed' intobj.

   All the operations involved in step 2 are done in the static function
   EFtrim_intobj().

3) TRIM REMAINING INTOBJS INCIDENT AT SPLIT POINT
   Get the other intobjs incident at this split point by going across the
   'other_intobj' of the current intobj and its adjacent intobj. Trim these
   using the same point (obtained above) and mark their 'exact_atstart/stop'
   property as in 2).

4) REFINE ALL THE TRIMMED INTOBJS
   Get the exact vertex point using the split point obtained above by 
   performing triple surface or curve surface iteration. Refine the end
   point of all the intobjs trimmed in steps 2 and 3 with this exact point.
   This is performed by the static function EFrefine_intobjs().

PHASE B
At the end of phase A all the intobjs on the inters node would have been
trimmed. The only thing remaining is to convert the intobj geometry to
EMSedge and construct an EMSloop from all the forward connected intobjs.
The 'nesting' of the loop in the loopset is determined and then nested
at the appropriate depth. EMlpinit is sent to the newly constructed loop
to set the loop properties. All these steps are performed in the external
function EMcreate_loop_from_int_group() in src_funk/misc/EMmklp.I.


HISTORY:	  

  ashok :	Oct-28-1992		Creation
  ashok :	Nov-30-1992		Added new arguments num_noint_intobjs
					and noint_intobjs which points to
					a list of intobj pairs that should
					not be intersected with one another.
					If NULLS are passed,  then every
					intobj on the surface will be tried for
					intersection with every other intobj on
					it.
  ashok :	Dec-5-1992		Added support for handling intersections
					between intobjs with UV data 
					represented as bspline.
  ashok	:	Dec-15-1992		Added support for handling intobjs
					representing a "seam edge". Also
					enhanced logic to determine if intobjs
					closed in XYZ and "touching" seams
					should OR should not split the seam.

  ashok :	Jan-10-1993		Modified to handle seams better. Now
					split points on seams are processed
					before splitting to determine their
					validity. Also now rerunning trace
					before returning to create loops from
					residual intobjs. Modified algorithm
					documentation appropriately.

  ashok :	Feb-12-1993		Rewrote as per new design. Now the
					input inters node has all the intobjs
					in place and connected by the fwd and
					bwd pointers. So we intersect now
					have to intersect every adjacent pair
					of intobjs in order to split them. Once
					the splits are done loops are created
					with the contiguous sets of intobjs.

 ashok :	15-Mar-1993		Added code to refine the intobjs after
					splitting. Also removed the unused
					arguments 'noint_intobjs' and
					'num_noint_intobjs'.

 NP    :        06-June-1993            Changed function name 
                                        "EMget_intersection_points" to the new
                                        name "EFget_intersection_points". The 
                                        new fn. includes Nirmal's enhancements
                                        to the function to handle objects and 
                                        a new parameter "intdata2_reversed" that
                                        I have added for consistency.
 ashok :	09-July-1993		Modified to take care of new parameter
					for function EMcreate_loop_from_
					intersection_group().
 ashok :	15-Oct-1993		Modified EFrefine_intobjs() so that
					ends of intobjs marked "isocurve" are
					not refined.
 ashok :	20-Oct-1992		Enhanced intobj trimming logic to
					detect errors and exit gracefully.
 sudhakar :     21-Nov-1993             Replaced the function "EFkeep_mindist_
                                        point" with an improved function for
                                        choosing the right split point
                                        whenever multiple split-point situation
                                        arises. This improved function is called
                                        "EFretain_the_right_splitpt()". Also
                                        added another arg. to the function
                                        "EFget_split_point" to enable a
                                        recursive call to this function.
 ashok	:	27-Dec-93		Added static functions
					EFchk_pt_on_seam() and
					EFvalidate_pt_on_seam() to properly
					handle during refinement vertices 
					lying on seam (avoid UV space jump)
 sudhakar :     28-Dec-93               Modified the function "EFget_split_
                                        point" to obtain the split point
                                        by retrying on the adjacent surface
                                        when "0" intersections result.
 ashok :        11-Jan-94               Rewrote the "EFrefine_intobjs()" and
                                        "EFget_split_point()" functions to 
                                        handle "special tangent" intobjs
                                        (TR# 119312801).
 sudhakar :     24-Jan-94               Modified "EFget_split_point()" function
                                        to consider a "special_tangent" 
                                        intobj on an adjacent surface for
                                        determining the split point to handle
                                        3 edge situations where two ofthe 
                                        edges are tangential and the third is
                                        a special tangent intobj.
 ashok :	31-Jan-94		Made a minor fix in EFrefine_intobjs to
					care of situation when a surface
					contributes more than one edge at a
					vertex.
 ashok :	10-Feb-94		Fixed TR 119416982. Modified
					EFretain_the_right_splitpt() to 
					support case where both intersections
					are free.
 sanjay :       11-Nov-94               Fixed TR 119423418. Fixed a "abr".
                                        Increased uv dimension from 2 to 3 and
                                        initialized the z to zero. 
 sanjay :       23-Aug-95               Fixed TR 119526844. Added a function 
                                        "EFvalidate_pt_on_xyzdegen" which will
                                        validate the refine point on a xyz
                                        degenerate intobj and sets it to the
                                        right end point.
*/

class implementation EMSsubbs;

#include "OMmacros.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "EMSssprops.h"
#include "EMSopt.h"
#include "bsmdistptsf.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bssfeval.h"
#include "bsfreecv.h"
#include "bstrpsfiter.h"
#include "bscvsfiter.h"
#include "bssfkttol2.h"
#include "bscoincdpts.h"

#define U 0
#define V 1
#define W 2

#define UNKNOWN -1
#define FIRST  0
#define SECOND 1
#define MIDDLE 50
#define LAST   100

#define START  0
#define STOP   1

#define FWD   0
#define BWD   1

#define THIS  0
#define OTHER 1
#define BUFF_SIZE 100

#define CONST_U  0
#define CONST_V  1

%safe
#include <math.h>
static void EFget_incident_intobjs();
IGRboolean EFis_rev_connect();
static void EFretain_the_right_splitpt();
static void EFtrim_intobj();
void EFget_partolbasis();
static void EFrefine_intobjs();
void EFmodify_end();
static void EFget_split_point();
static void EFdetect_duplicate();
static IGRboolean EFremapped_isocurve();
static IGRboolean EFchk_for_iso();
static void EFchk_pt_on_seam();
static void EFvalidate_pt_on_seam();
static void EFvalidate_pt_on_xyzdegen();
static IGRboolean EFmodify_spl_intobj();
%endsafe

struct EMregen_inc_info         /* structure for incedent intersections at a
			           vertex				     */
{
   struct EMSintobj *p_intobj;	/* pointer to an intersection at the vertex  */
   IGRint	    location;   /* whether the intersection starts or ends at
				   the vertex 				     */
};

from EMSloop import EMptinside;
from EMSloop import EMtreemod;
from EMSloopset import EMget_loops;
from EMSloopset import EMset_props;
from EMSedge import EMinternalpt;
/* ************************************************************************** */
IGRlong EMregen_tpgy(msg, inters, orig_sf, const_list, options)
/* ************************************************************************** */
IGRlong *msg;
struct EMSinters **inters;
struct GRid orig_sf;
struct GRvg_construct *const_list;
IGRshort options;

{
  IGRlong i, j, msg_loc, stat_OM, num_cvs, num_intobjs,
	  num_inc_fwd, num_inc_bwd;
  IGRdouble uvtol, cht_tol, lentol, min_dist, start_pt[2], stop_pt[2], uv[2],
	    pt1[3], pt2[3], *splt_pt=NULL;
  IGRushort exact1, exact2;
  IGRshort  loc_options;
  IGRboolean x_them, proc_start_intobj, rev_connect;
  IGRint loc;
  struct GRid this_sf;
  struct GRmd_env *env;
  struct EMSpypoint *p_pypt, *p_pypt1, *p_pypt2, loc_pypt, loc_xyz_pypt;
  struct EMSinters *loc_inters;
  struct EMSintobj *p_intobjs[2], *p_intobj, *loop_start_intobj, *p_save_intobj,
 		   *p_intobj_prev=NULL, *head_intobj, *other_intobj;
  struct EMregen_inc_info *inc_intobjs[2];
  struct EMSpartolbasis partolb, loc_partolb;
  GRobjid  loopset_id;
  OMuint num_lps;
  OM_S_OBJECT_LINKAGE comm_list[1];
  OM_S_CHANSELECT chan_to_loops, chan_to_loopset, chan_to_surface, 
		  chan_to_edges;

  extern void EFget_intersection_points(), EMsplit_sf_intobj_uv();
  extern void EMsortpypts();
  extern  void  EMpypoint_free(), EMintobj_free(), EMdelintobj();
  extern struct EMSpypoint *EMpypoint_malloc();
  extern IGRlong EMgetendpts_uv(), EMgetendpts_xyz(), EMprojectpt();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  p_pypt = NULL;
  p_pypt1 = NULL;
  p_pypt2 = NULL;
  loc_options = options;
  orig_sf.objid = NULL_OBJID; /* Parameter currently not in use. Supress
				 compiler warning */

  BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, lentol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);

  env = const_list->env_info;

  loc_inters = *inters;  

  this_sf = loc_inters->this_obj;
  EFget_partolbasis(&msg_loc, this_sf, env, &partolb);
  EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
  uvtol = partolb.tol;

/* PHASE A 
   ------- 
*/
  p_intobjs[FIRST] = loc_inters->cvs;
  loop_start_intobj = NULL;
  proc_start_intobj = TRUE;
  while(p_intobjs[FIRST])
  {
      if(loop_start_intobj == NULL)
      {
	loop_start_intobj = p_intobjs[FIRST];
	proc_start_intobj = TRUE;
      }
      if(p_intobjs[FIRST]->fwd)
        if(p_intobjs[FIRST]->fwd != loop_start_intobj)
	   p_intobjs[SECOND] = p_intobjs[FIRST]->fwd;
        else
	{
	   p_intobjs[SECOND] = loop_start_intobj;
	   loop_start_intobj = NULL;
	}
      else   /* only one intobj present in loop. Must be a closed(uv) intobj */
      {
	p_intobjs[FIRST] = p_intobjs[FIRST]->next;
	loop_start_intobj = p_intobjs[FIRST];
	proc_start_intobj = TRUE;
	continue;
      }

      /* Pre-process the intobj pair */

      for(i=FIRST; i<=SECOND; i++)
      {
	if(!(p_intobjs[i]->other_intobj_node)) continue;
	rev_connect = EFis_rev_connect(&msg_loc, p_intobjs[i]);
	other_intobj = p_intobjs[i]->other_intobj_node;

	exact1 = exact2 = 0x0;
	if(p_intobjs[i]->props & (i==FIRST? EMSintobj_exact_atstop :
				  EMSintobj_exact_atstart)) exact1 = 0x1;
	if(other_intobj->props & (i==FIRST ? (rev_connect ? 
			  EMSintobj_exact_atstart : EMSintobj_exact_atstop) :
							      (rev_connect ? 
			  EMSintobj_exact_atstop : EMSintobj_exact_atstart)))
	  exact2 = 0x1;

	if(exact1 ^ exact2)
	{
	  stat_OM = EMgetendpts_xyz(&msg_loc, &env->md_env.matrix_type,
			            env->md_env.matrix,
				    exact1 ? &p_intobjs[i]->this_xyzintobj :
				             &other_intobj->this_xyzintobj,
				    exact1 ? p_intobjs[i]->reversed :
					     other_intobj->reversed,
				    1, pt1, pt2);
	  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

	  switch(i)
	  {
	     case FIRST :
	       splt_pt = (exact1 ? &pt2[0] : (rev_connect ? &pt1[0] : &pt2[0]));
	       loc = (exact1 ? (rev_connect ? BEGIN : END) : END);
	       break;
	    case SECOND :
	       splt_pt = (exact1 ? &pt1[0] : (rev_connect ? &pt2[0] : &pt1[0]));
	       loc = (exact1 ? (rev_connect ? END : BEGIN) : BEGIN);
	        break;
	    default :
	        loc = 0;  /* Just to supress compiler warning */
		break;
	  }
	  stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			        env->md_env.matrix,
			        exact1 ? &other_intobj->this_xyzintobj :
				         &p_intobjs[i]->this_xyzintobj,
			        1, splt_pt, lentol, &loc_xyz_pypt, &min_dist);
	  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

          stat_OM = EMfind_uv_xyz_point (&msg_loc, &env->md_env, 
                    exact1 ? &other_intobj->this_obj_node->this_obj :
			     &p_intobjs[i]->this_obj_node->this_obj, NULL, 
                    exact1 ? &other_intobj->this_uvintobj :
			     &p_intobjs[i]->this_uvintobj,
		    exact1 ? &other_intobj->this_xyzintobj :
			     &p_intobjs[i]->this_xyzintobj,
                    FALSE, NULL, &loc_pypt, &loc_xyz_pypt);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	  loc_pypt.next = NULL;

#ifdef DEBUG
printf("trimming with exact end of common intobj\n");
printf("min_dist=%lg  splt_pt=%lg %lg\n", min_dist, loc_pypt.point[0],
	loc_pypt.point[1]);
#endif
	  p_intobjs[i]->other_intobj_node = NULL;
	  other_intobj->other_intobj_node = NULL;
	  EFtrim_intobj(&msg_loc, exact1 ? &other_intobj : &p_intobjs[i],
		        &loc_pypt, loc, env);
	  EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	  p_intobjs[i]->other_intobj_node = other_intobj;
	  other_intobj->other_intobj_node = p_intobjs[i];

	  if(proc_start_intobj && !exact1 && i==FIRST)
	  {
	     if(loop_start_intobj == loc_inters->cvs)
		loc_inters->cvs = p_intobjs[i];
	     loop_start_intobj = p_intobjs[i];
	  }

	} /* if(exact1 ^ exact2) */
      } /* for(i=0;....) */

      x_them = TRUE;
      exact1 = exact2 = 0x0;
      if(p_intobjs[0]->props & EMSintobj_exact_atstop)  exact1 = 0x1;
      if(p_intobjs[1]->props & EMSintobj_exact_atstart) exact2 = 0x1;
      if(exact1 & exact2) x_them = FALSE;
      else if(exact1 ^ exact2)
      {
	stat_OM = EMgetendpts_uv(&msg_loc,
				 exact1 ? &p_intobjs[0]->this_uvintobj :
				          &p_intobjs[1]->this_uvintobj,
				 exact1 ? p_intobjs[0]->reversed :
					  p_intobjs[1]->reversed,
				 1, start_pt, stop_pt);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

	stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			      env->md_env.matrix,
			      exact1 ? &p_intobjs[1]->this_uvintobj :
				       &p_intobjs[0]->this_uvintobj,
			      1, exact1 ? stop_pt : start_pt, partolb.tol,
			      &loc_pypt, &min_dist);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	loc_pypt.next = NULL;
	EFtrim_intobj(&msg_loc, exact1 ? &p_intobjs[SECOND]:&p_intobjs[FIRST],
		      &loc_pypt, exact1 ? BEGIN : END, env);
	EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	if(proc_start_intobj && !exact1)
	{
	  if(loop_start_intobj == loc_inters->cvs)
		loc_inters->cvs = p_intobjs[FIRST];
	  loop_start_intobj = p_intobjs[FIRST];
	}
	x_them = FALSE;
      }

      if(x_them)
      {
      /* First get all the incident intobjs at the vertex being formed by
	 the intobjs p_intobjs[START] and p_intobjs[STOP]
      */
	 inc_intobjs[FWD] = NULL;
	 inc_intobjs[BWD] = NULL;
	 EFget_incident_intobjs(&msg_loc, p_intobjs, &num_inc_fwd, &num_inc_bwd,
				&inc_intobjs[FWD], &inc_intobjs[BWD]);

      /* Check if the 1st intobj's more-info is not NULL. If non-NULL it is
	is expected to point to the intersection point.
      */
	 if(p_intobjs[FIRST]->more_info)
	 {
	    p_pypt = (struct EMSpypoint *) p_intobjs[FIRST]->more_info;
	    p_pypt1 = EMpypoint_malloc(&msg_loc, 1);
	    p_pypt2 = EMpypoint_malloc(&msg_loc, 1);
	    uv[0] = p_pypt->point[0];
	    uv[1] = p_pypt->point[1];
	    for(i=FIRST; i<=SECOND; i++)
	    {
	       stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			             env->md_env.matrix,
			             &p_intobjs[i]->this_uvintobj,
			             1, uv, partolb.tol,
				     i==0 ? p_pypt1 : p_pypt2, &min_dist);
	       EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, 
	                   ret_end);
	    }
	 }
	 else
	 {
            p_pypt1 = p_pypt2 = NULL;
	    EFget_split_point(&msg_loc, p_intobjs, uvtol, lentol, env,
			      num_inc_fwd, num_inc_bwd, inc_intobjs, 
			      &p_pypt1, &p_pypt2, 0);
	    EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
	 }
	 EFtrim_intobj(&msg_loc, &p_intobjs[FIRST], p_pypt1, END, env);
	 EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	 EFtrim_intobj(&msg_loc, &p_intobjs[SECOND], p_pypt2, BEGIN, env);
	 EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	 if(proc_start_intobj)
	 {
	   if(loop_start_intobj == loc_inters->cvs)
		loc_inters->cvs = p_intobjs[FIRST];
	   loop_start_intobj = p_intobjs[FIRST];
	 }

	/* Now trim all the intobjs incident at the vertex formed by
	   p_intobjs[START] and p_intobjs[STOP]. The code below expects
           p_intobj to always have a counterpart, other_intobj_node. If one
           is encountered w/o such a counterpart, construe error and wrapup.
	*/

	 for(j=FWD,num_intobjs=num_inc_fwd, p_intobj=p_intobjs[START]; j<=BWD; 
	       j++, num_intobjs=num_inc_bwd, p_intobj=p_intobjs[STOP])
	   for(i=0; i<num_intobjs;
		      p_intobj=inc_intobjs[j][i].p_intobj, i++)
	   {
	     loc = inc_intobjs[j][i].location;
	     exact1 = (loc == END ? 
		  inc_intobjs[j][i].p_intobj->props & EMSintobj_exact_atstop :
		  inc_intobjs[j][i].p_intobj->props & EMSintobj_exact_atstart);
	     if(exact1) continue;

	     EFget_partolbasis
		   (&msg_loc,
		    inc_intobjs[j][i].p_intobj->this_obj_node->this_obj,
		    env,
		    &loc_partolb);
	     EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

             EMerr_hndlr (!p_intobj->other_intobj_node, *msg, EMS_E_Fail,
              ret_end);
	     stat_OM = EMgetendpts_uv(&msg_loc, 
		     &p_intobj->other_intobj_node->this_uvintobj,
		     p_intobj->other_intobj_node->reversed,
		     1, start_pt, stop_pt);
	     EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,ret_end);

	     splt_pt = (loc == END ? &start_pt[0] : &stop_pt[0]);

	     stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			         env->md_env.matrix, 
				 &inc_intobjs[j][i].p_intobj->this_uvintobj,
			         1, splt_pt, loc_partolb.tol, &loc_pypt, 
				 &min_dist);
	     EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,ret_end);

	     loc_pypt.next = NULL;
	     EFtrim_intobj(&msg_loc, &inc_intobjs[j][i].p_intobj, &loc_pypt,
			   loc, env);
	     EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
	   } /* for(i=0; i<num_intobjs; i++) */

/* Refine all the 'intobjs' coming together at this vertex.
   Depending upon whether there are 3 or more  OR only 2 OR only 1 surface(s)
   participating at that vertx we will perform either Triple Surface iteration 
   method of refinement OR Curve-Surface iteration method of refinement OR 
   No refinement at all respectively.
*/

	 uv[0] = p_pypt1->point[0];
	 uv[1] = p_pypt1->point[1];
	 EFrefine_intobjs(&msg_loc, env, p_intobjs, uv, partolb, num_inc_fwd,
			  num_inc_bwd, inc_intobjs[FWD], inc_intobjs[BWD],
			  lentol);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

         EMpypoint_free(p_pypt1, MAXINT);
         EMpypoint_free(p_pypt2, MAXINT);
	 if(inc_intobjs[FWD])  om$dealloc(ptr = inc_intobjs[FWD]);
	 if(inc_intobjs[BWD])  om$dealloc(ptr = inc_intobjs[BWD]);
      } /* if(x_them) */
      p_intobjs[FIRST] = p_intobjs[FIRST]->next;
      proc_start_intobj = FALSE;
  } /* while(p_intobjs[FIRST]) */


/*
PHASE B
-------
*/

/* Create a loopset on the 'inters' surface if one not aready present. Also
   delete any existing loops if loopset is already present.
*/

stat_OM = EMmake_chanselect(EMSloopset_to_loops, &chan_to_loops);
stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
stat_OM = EMmake_chanselect (EMSloopset_to_surface, &chan_to_surface);
stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);

num_lps = 0;
om$get_channel_count(objid = this_sf.objid,
  		     osnum = this_sf.osnum,
		     p_chanselect = &chan_to_loopset, count = &num_lps);
EMerr_hndlr (num_lps > 1, *msg, EMS_E_Fail, ret_end);
	
if(num_lps == 0)
{
	  stat_OM = om$construct(classid = OPP_EMSloopset_class_id,
				 osnum = this_sf.osnum,
		                 p_objid = &loopset_id);
	  EMerr_hndlr (EMSerror(stat_OM), *msg, EMS_E_Fail, ret_end);
          stat_OM = om$send(msg = message Root.connect(chan_to_surface,
		                  0, this_sf.objid, this_sf.osnum,
				  chan_to_loopset, 0),
			    senderid = NULL_OBJID,
			    targetid = loopset_id,
			    targetos = this_sf.osnum);
	  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

	  stat_OM = om$send (msg = message EMSloopset.EMset_props (&msg_loc,
               			   EMLS_NATURAL, EMS_O_ON), 
			     senderid = NULL_OBJID,
			     targetos = this_sf.osnum,
			     targetid = loopset_id);
	  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

}
else
{
    	  num_lps = 0;
    	  om$get_channel_objects(objid = this_sf.objid,
		osnum = this_sf.osnum,
     		p_chanselect = &chan_to_loopset, count = &num_lps, size = 1,
     		list = comm_list);
    	  EMerr_hndlr (num_lps != 1, *msg, EMS_E_Fail, ret_end);
    
  	  loopset_id = comm_list[FIRST].S_objid;
    	  stat_OM = om$send (msg = message EMSloop.EMtreemod (&msg_loc, NULL,
               		         DELETE, NULL), p_chanselect = &chan_to_loops,
               		   senderid = loopset_id);
    	  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
}

/* Now we create loops from all the intobj sets on the inters node. 
   One intobj set corresponds to a set of forward and backward connected
   intobjs (cyclically). The last intobj of one set will be connected
   to the first intobj of the next set via the 'next' pointer.
*/

head_intobj = loc_inters->cvs;
num_cvs = loc_inters->num_cvs;

loop_start_intobj = head_intobj;
while(loop_start_intobj)
{
  loc_inters->num_cvs =0;
  loc_inters->cvs = loop_start_intobj;
  for(p_intobj=loop_start_intobj; p_intobj; (loc_inters->num_cvs)++)
  {
	p_intobj_prev = p_intobj;
	p_intobj = (p_intobj->fwd == loop_start_intobj ? NULL : p_intobj->fwd);
  }
  p_save_intobj = p_intobj_prev->next;
  p_intobj_prev->next = NULL;

/* Now call the function to create and impose the loop corresponding
   to the first group on the offset surface
*/

  EMcreate_loop_from_int_group(&msg_loc, loc_inters->cvs, 
			       &loopset_id, NULL, NULL, const_list, NULL,
			       (IGRshort)EMS_opt_mklp_ConnectAtLastIndex);

  p_intobj_prev->next = p_save_intobj;

  if(EMSerror (msg_loc))
  {
    loc_inters->cvs = head_intobj;	    
    loc_inters->num_cvs = num_cvs;
    *msg = EMS_E_Fail;
    goto ret_end;
  }
  loop_start_intobj = p_save_intobj;
}

loc_inters->cvs = head_intobj;	    
loc_inters->num_cvs = num_cvs;

ret_end:

 EMWRAPUP(*msg, stat_OM, "EMregen_tygy");
 return(stat_OM);
}

/* ************************************************************************* */
static void EFget_incident_intobjs(msg, p_intobjs, num_inc_fwd, num_inc_bwd,
				   fwd_intobjs, bwd_intobjs)
/* ************************************************************************* */
IGRlong			*msg, *num_inc_fwd, *num_inc_bwd;
struct EMSintobj	*p_intobjs[2];
struct EMregen_inc_info **fwd_intobjs, **bwd_intobjs;
{
  IGRlong		  i, msg_loc, count;
  IGRint		  buf_size, inc_size, loc;
  IGRboolean		  rev_connect, vert_at_end, cycled;
  struct EMSintobj	  *p_intobj, *tmp_intobj, *chk_intobj;
  struct EMregen_inc_info *inc_info;

  *msg = EMS_S_Success;
  buf_size = inc_size = 5;

  *num_inc_fwd = 0;
  *num_inc_bwd = 0;
  *fwd_intobjs = NULL;
  *bwd_intobjs = NULL;

  if(!p_intobjs[0]->other_intobj_node && !p_intobjs[1]->other_intobj_node)
  {
    return;
  }

  for(i=FWD, cycled=FALSE; !cycled && i<=BWD; i++)
  {
    inc_info = NULL;
    count = 0;

    vert_at_end = (i==FWD ? TRUE : FALSE);
    p_intobj = p_intobjs[i]->other_intobj_node;
    tmp_intobj = p_intobjs[i==FWD ? BWD:FWD];
    chk_intobj = tmp_intobj->other_intobj_node;
    while(!chk_intobj && (tmp_intobj->props & EMSintobj_xyzdegenerate))
    {
	tmp_intobj = (vert_at_end ? tmp_intobj->fwd : tmp_intobj->bwd);
	chk_intobj = tmp_intobj->other_intobj_node;
    }
    if(p_intobj)
    {
      /* Allocate memory for holding the incident info */
      inc_info = (struct EMregen_inc_info *) om$malloc(size = buf_size *
					     sizeof(struct EMregen_inc_info));
      EMerr_hndlr(!inc_info, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

    }
    while(p_intobj)
    {
      rev_connect = EFis_rev_connect(&msg_loc, p_intobj);
      EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
      tmp_intobj = (vert_at_end ? 
                          (rev_connect ?  p_intobj->bwd : p_intobj->fwd) :
                          (rev_connect ?  p_intobj->fwd : p_intobj->bwd));

      /* Check if we have cycled back and reached one of the input intobj pair.
         If so exit the loop
      */

/*      if((tmp_intobj == p_intobjs[0]->other_intobj_node) ||
         (tmp_intobj == p_intobjs[1]->other_intobj_node))
*/
      if(tmp_intobj == chk_intobj)
      {
	cycled = TRUE;
	break;
      }

      loc = (vert_at_end ?  (rev_connect ?  END : BEGIN) :
                            (rev_connect ?  BEGIN : END));
      inc_info[count].p_intobj = tmp_intobj;
      inc_info[count].location = loc;

      count++;
      if(count >= buf_size)
      {
         buf_size += inc_size;
	 inc_info = (struct EMregen_inc_info *) om$realloc(ptr =
			       (IGRchar *) inc_info, size =
			       buf_size * sizeof(struct EMregen_inc_info));
         EMerr_hndlr(!inc_info, *msg, EMS_E_DynamicMemoryAllocated, ret_end);
      }

      /* Set vert_at_end flag (TRUE/FALSE) for the current incident intobj
         (tmp_intobj) and set p_intobj to its 'other' intobj. If the 'other'
	 intobj is NULL then check if tmp_intobj was degenerate. If so set
	 tmp_intobj to its adjacent intobj. Do this till the 'other_intobj'
	 is not NULL OR tmp_intobj is not degenerate.
      */
      vert_at_end = (loc == END ? TRUE : FALSE);
      p_intobj = tmp_intobj->other_intobj_node;
      while(!p_intobj && (tmp_intobj->props & EMSintobj_xyzdegenerate))
      {
	tmp_intobj = (vert_at_end ? tmp_intobj->bwd : tmp_intobj->fwd);
	if(tmp_intobj == chk_intobj)
        {
	  cycled = TRUE;
	  count--;
	  break;
        }
	p_intobj = tmp_intobj->other_intobj_node;
      }
    } /* while(p_intobj) */

    if(i == FWD)
    {
       *num_inc_fwd = count;
       *fwd_intobjs = inc_info;
    }
    else
    {
       *num_inc_bwd = count;
       *bwd_intobjs = inc_info;
    }

  } /* for(i=FWD, .... */

ret_end:
  if(!(*msg & 1))
  {
    if(*fwd_intobjs) om$dealloc(ptr = *fwd_intobjs);
    if(*bwd_intobjs) om$dealloc(ptr = *bwd_intobjs);
  }
  return;

}

/* ************************************************************************* */
IGRboolean EFis_rev_connect(msg, p_intobj)
/* ************************************************************************* */
IGRlong			*msg;
struct EMSintobj	*p_intobj;
{

  IGRlong		msg_loc, stat_OM;
  IGRboolean		rev_connect=FALSE;
  IGRuchar		sf_props;
  IGRushort		pos_ornt_1, pos_ornt_2;
  struct GRid		surf_1, surf_2;
  struct EMSintobj	*other_intobj;

  *msg = EMS_S_Success;

  if(!p_intobj) return(FALSE);

  other_intobj = p_intobj->other_intobj_node;
  if(!other_intobj) return(FALSE);

  surf_1 = p_intobj->this_obj_node->this_obj;
  surf_2 = other_intobj->this_obj_node->this_obj;

  stat_OM = om$send(msg = message EMSsubbs.EMget_props(&msg_loc, &sf_props),
		    senderid = NULL_OBJID,
		    targetid = surf_1.objid,
	            targetos = surf_1.osnum);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  pos_ornt_1 = (sf_props & EMSIS_NRML_REVERSED ? 0x1 : 0x0);

  stat_OM = om$send(msg = message EMSsubbs.EMget_props(&msg_loc, &sf_props),
		    senderid = NULL_OBJID,
		    targetid = surf_2.objid,
	            targetos = surf_2.osnum);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  pos_ornt_2 = (sf_props & EMSIS_NRML_REVERSED ? 0x1 : 0x0);

  if(pos_ornt_1 ^ pos_ornt_2) rev_connect = FALSE;
  else rev_connect = TRUE;

ret_end:
  return(rev_connect);
}


/* ************************************************************************* */
static void  EFtrim_intobj(msg, p_intobj, end_pt, location, env)
/* ************************************************************************* */
IGRlong			*msg;
struct EMSintobj	**p_intobj;
struct EMSpypoint	*end_pt;
IGRint			location;
struct GRmd_env		*env;

{
  IGRlong	   msg_loc, stat_OM;
  IGRint	   cvs_before, cvs_after;
  IGRchar	   *this_moreinfo, *oth_moreinfo=NULL;
  IGRushort	   atstart, this_rev;
  IGRulong	   this_end_props, oth_end_props=0;
  IGRboolean	   this_iso, oth_iso=FALSE, this_const_u, oth_const_u, 
		   rev_connect=FALSE;
  IGRdouble	   this_iso_par=0.0, oth_iso_par=0.0; /* avoid compiler warngs*/
  struct EMSintobj *this_intobj, *oth_intobj, *this_bwd_intobj,
		   *this_fwd_intobj, *oth_bwd_intobj=NULL, *oth_fwd_intobj=NULL,
		   *p_intobj_fwd;

  extern void	   EMdelintobj();
  *msg = EMS_S_Success;

  this_intobj = *p_intobj;
  oth_intobj = this_intobj->other_intobj_node;

  atstart = (location == BEGIN ? 0x1:0x0);

  this_rev = this_intobj->reversed ? 0x1:0x0;
  this_end_props = (this_intobj->props & EMSintobj_exact_atstart) |
		   (this_intobj->props & EMSintobj_exact_atstop);
  this_bwd_intobj = this_intobj->bwd;
  this_fwd_intobj = this_intobj->fwd;
  this_intobj->bwd = this_bwd_intobj->fwd = NULL;
  this_intobj->fwd = this_fwd_intobj->bwd = NULL;
  this_moreinfo = this_intobj->more_info;
  this_intobj->more_info =  NULL;
  this_iso = (this_intobj->props & EMSintobj_isocurve ? TRUE : FALSE);
  if(this_iso)
  {
     IGRdouble start_uv[2], stop_uv[2];
     this_iso = EFchk_for_iso(&this_intobj->this_uvintobj, NULL,
			      this_intobj->reversed, start_uv, stop_uv, 
			      &this_const_u);
     EMerr_hndlr(!this_iso, *msg, EMS_E_Fail, ret_end);
     if(this_const_u) this_iso_par = start_uv[0];
     else this_iso_par = start_uv[1];
  }
  if(oth_intobj)
  {
    oth_end_props = (oth_intobj->props & EMSintobj_exact_atstart) |
		    (oth_intobj->props & EMSintobj_exact_atstop);
    oth_bwd_intobj = oth_intobj->bwd;
    oth_fwd_intobj = oth_intobj->fwd;
    oth_intobj->bwd = NULL;
    if(oth_bwd_intobj) oth_bwd_intobj->fwd = NULL;
    oth_intobj->fwd = NULL;
    if(oth_fwd_intobj) oth_fwd_intobj->bwd = NULL;
    oth_moreinfo = oth_intobj->more_info;
    oth_intobj->more_info = NULL;
    oth_iso = (oth_intobj->props & EMSintobj_isocurve ? TRUE : FALSE);
    if(oth_iso)
    {
      IGRdouble start_uv[2], stop_uv[2];
      oth_iso = EFchk_for_iso(&oth_intobj->this_uvintobj, NULL,
			       oth_intobj->reversed, start_uv, stop_uv, 
			       &oth_const_u);
      EMerr_hndlr(!oth_iso, *msg, EMS_E_Fail, ret_end);
      if(oth_const_u) oth_iso_par = start_uv[0];
      else oth_iso_par = start_uv[1];
    }
    rev_connect = EFis_rev_connect(&msg_loc, this_intobj);
    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  cvs_before = this_intobj->this_obj_node->num_cvs;
  EMmsplit_sf_intobj_uv(&msg_loc, NULL, &env->md_env, this_intobj, end_pt,
			  NULL, TRUE);
  EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

  cvs_after = this_intobj->this_obj_node->num_cvs;

  if(cvs_after == cvs_before) /* No splitting occured. Check if split point
				 coincides with end point */
  {
     IGRdouble start_pt[2], stop_pt[2];
     struct EMSpartolbasis  par_tol;
     extern IGRlong EMgetendpts_uv();

     EFget_partolbasis(&msg_loc, this_intobj->this_obj_node->this_obj, env, 
		       &par_tol);
     stat_OM = EMgetendpts_uv(&msg_loc, 
		     &this_intobj->this_uvintobj,
		     this_intobj->reversed,
		     1, start_pt, stop_pt);
     EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

     if(EM2ddistptpts(end_pt->point, (atstart ? start_pt : stop_pt)) >
	par_tol.tol * par_tol.tol)
     {
#ifdef DEBUG
printf("EMregen_tpgy: ERROR - Intobj Splitting Failure\n");
#endif
	*msg = EMS_E_Fail;
	goto ret_end;
     }
  }
  else
  {
    /* Retain one piece and delete the other */
    if(atstart ^ this_rev)
    {
       p_intobj_fwd = this_intobj;
       this_intobj = this_intobj->next;
       EMdelintobj(&msg_loc, p_intobj_fwd);
    }
    else
       EMdelintobj(&msg_loc, this_intobj->next);
  }
/* Re-establish correct backward and forward pointers for both 'this_intobj'
   and its 'other' intobj node
*/
  this_intobj->bwd = this_bwd_intobj;
  this_intobj->fwd = this_fwd_intobj;
  if(this_bwd_intobj) this_bwd_intobj->fwd = this_intobj;
  if(this_fwd_intobj) this_fwd_intobj->bwd = this_intobj;
  this_intobj->props  |= (this_end_props | 
			 (location == BEGIN ? EMSintobj_exact_atstart :
					      EMSintobj_exact_atstop));
  this_intobj->more_info = this_moreinfo;
  if(this_iso && this_intobj->this_uvintobj.datatype == EMSdata_poly2d)
  {
    IGRint num_pts, local_loc;
    num_pts = this_intobj->this_uvintobj.data.poly->num_points;
    local_loc = (location == BEGIN ? (this_intobj->reversed ? END : BEGIN) :
				     (this_intobj->reversed ? BEGIN : END));
				     
    if(local_loc == BEGIN)
       if(this_const_u) this_intobj->this_uvintobj.data.poly->points[0] =
							      this_iso_par;
       else this_intobj->this_uvintobj.data.poly->points[1] = this_iso_par;
    else
       if(this_const_u)
	  this_intobj->this_uvintobj.data.poly->points[2*(num_pts-1)] =
							      this_iso_par;
       else this_intobj->this_uvintobj.data.poly->points[2*(num_pts-1)+1] =
							      this_iso_par;
  }

  if(oth_intobj)
  {
    oth_intobj = this_intobj->other_intobj_node;
    oth_intobj->bwd = oth_bwd_intobj;
    oth_intobj->fwd = oth_fwd_intobj;
    if(oth_bwd_intobj) oth_bwd_intobj->fwd = oth_intobj;
    if(oth_fwd_intobj) oth_fwd_intobj->bwd = oth_intobj;
    oth_intobj->props |= (oth_end_props |
		         (location == BEGIN ? (rev_connect ? 
					           EMSintobj_exact_atstop :
					           EMSintobj_exact_atstart) :
					      (rev_connect ?
					           EMSintobj_exact_atstart :
					           EMSintobj_exact_atstop)));
    oth_intobj->more_info = oth_moreinfo;

    if(oth_iso && oth_intobj->this_uvintobj.datatype == EMSdata_poly2d)
    {
      IGRint num_pts, local_loc;
      num_pts = oth_intobj->this_uvintobj.data.poly->num_points;

      local_loc = (location == BEGIN ? (rev_connect ? END : BEGIN) :
				       (rev_connect ? BEGIN : END));

      local_loc = (local_loc == BEGIN ? (oth_intobj->reversed ? END : BEGIN) :
				        (oth_intobj->reversed ? BEGIN : END));

      if(location == BEGIN)
        if(oth_const_u) oth_intobj->this_uvintobj.data.poly->points[0] =
							      oth_iso_par;
        else oth_intobj->this_uvintobj.data.poly->points[1] = oth_iso_par;
      else
        if(oth_const_u)
	  oth_intobj->this_uvintobj.data.poly->points[2*(num_pts-1)] =
							      oth_iso_par;
        else oth_intobj->this_uvintobj.data.poly->points[2*(num_pts-1)+1] =
							      oth_iso_par;
    }

  }

  *p_intobj = this_intobj;
ret_end:
  return;  
}

/* ************************************************************************* */
static void EFrefine_intobjs(msg, env, this_intobjs, this_uv, this_tol, 
			     num_inc_fwd, num_inc_bwd, inc_fwd, inc_bwd, lentol)
/* ************************************************************************* */
IGRlong			*msg, num_inc_fwd, num_inc_bwd;
struct GRmd_env		*env;
struct EMSintobj	*this_intobjs[2];
IGRdouble		this_uv[2];
struct EMSpartolbasis	this_tol;
struct EMregen_inc_info *inc_fwd, *inc_bwd;
IGRdouble		lentol;

{

  IGRlong			i, j, k, rc, msg_loc, stat_OM, num_intobjs, 
				num_sfs, count, knt;
  IGRint			location, loc_locn, uv_size;
  IGRushort			is_spl_tan, ignore_spl_tan;
  struct GRid			sfs[3], sf_id;
  struct IGRbsp_surface		*surf[3];
  struct EMSpartolbasis		par_tol[3], *par_tol_ptr=NULL;
  IGRdouble			surf_uv[3][2], base_point[3], dist,
				cht_tol, *uv_pt_ptr=NULL;
  IGRpoint			xyz_pt;
  IGRboolean			is_succ, rev_connect, free_data, stat_func,
				mem_alloc=FALSE;
  struct EMSintobj		*intobj_pair[2], *other_intobj,
				*tmp_intobj=NULL, *tmp_intobj2=NULL;
  struct EMSdataselect		loc_sf_data;
  struct EMregen_inc_info	sf_vertex[3], *inc_intobjs[2], tmp_vert;

  IGRboolean	EMis_same_dataselect();
  IGRlong	EMsm_get_surface_geom();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  num_sfs = 0;
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  surf[0] = surf[1] = surf[2] = NULL;
  uv_size = 2 * sizeof(IGRdouble);

  inc_intobjs[0] = inc_fwd;
  inc_intobjs[1] = inc_bwd;


  if(!num_inc_fwd && !num_inc_bwd) return;    /* No refinement needed */

  for(knt=START, ignore_spl_tan=0x1; knt<=STOP && num_sfs < 3;
				                  ignore_spl_tan=0x0, knt++)
    for(i=FWD, num_intobjs=num_inc_fwd; i<=BWD && num_sfs < 3;
				      i++, num_intobjs=num_inc_bwd)
    {
      tmp_intobj = this_intobjs[i];
      location = (i==FWD ? END : BEGIN);
      if(!num_intobjs)
      {
        tmp_intobj = tmp_intobj->other_intobj_node;
        rev_connect = EFis_rev_connect(&msg_loc, tmp_intobj);
        location = (location == END ? (rev_connect==TRUE ? BEGIN : END) :
		                      (rev_connect==TRUE ? END   : BEGIN));
      }
      if(i==BWD && num_inc_fwd && num_inc_bwd) tmp_intobj = NULL;
      if(tmp_intobj)
      {
        is_spl_tan = (tmp_intobj->props & EMSintobj_special_tangent ? 0x1:0x0);
        if(is_spl_tan ^ ignore_spl_tan)
        {
          sf_vertex[num_sfs].p_intobj = tmp_intobj;
	  sf_vertex[num_sfs].location = location;
          sfs[num_sfs] = tmp_intobj->this_obj_node->this_obj;
          num_sfs++;
        }
      }
      for(j=0; j<num_intobjs && num_sfs < 3 ; j++)
      {
        tmp_intobj = inc_intobjs[i][j].p_intobj;
        is_spl_tan = (tmp_intobj->props & EMSintobj_special_tangent ? 0x1:0x0);
        if(is_spl_tan ^ ignore_spl_tan)
        {
      	  sf_vertex[num_sfs].p_intobj = inc_intobjs[i][j].p_intobj;
      	  sf_vertex[num_sfs].location = inc_intobjs[i][j].location;
      	  sfs[num_sfs] = sf_vertex[num_sfs].p_intobj->this_obj_node->this_obj;
      	  num_sfs++;
        }
      }
    } /* for(i=FWD,.... */

  loc_sf_data.datatype = EMSdata_object;
  for(i=0; i<num_sfs; i++)
  {
     surf[i] = NULL;
     loc_sf_data.data.object = &sfs[i];
     stat_OM = EMsm_get_surface_geom(&msg_loc, &loc_sf_data, &env->md_env,
				   &surf[i]);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  if(sfs[0].objid == this_intobjs[0]->this_obj_node->this_obj.objid)
  {
     OM_BLOCK_MOVE(this_uv, surf_uv[0], 2*sizeof(IGRdouble));
     BSsfeval(surf[0], surf_uv[0][0], surf_uv[0][1], 0, 
                                                (IGRpoint *)xyz_pt, &rc );
     EMerr_hndlr(rc!=BSSUCC, *msg, EMS_E_Fail, ret_end);
  }
  else
  {
     IGRpoint                pnt;

    /*
     *  Project the uv-point on this surface onto the surface whose
     *  objid is stored in sfs[0].
     */
     stat_OM = om$send(msg = message EMSsubbs.EMptatpr(&msg_loc, 
                                     &env->md_env.matrix_type,
                                     env->md_env.matrix,
                                     this_uv, 2, pnt),
                     senderid = NULL_OBJID,
                     targetid = this_intobjs[0]->this_obj_node->this_obj.objid,
                     targetos = this_intobjs[0]->this_obj_node->this_obj.osnum);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, ret_end);

     if(!BSmdistptsf(&rc, surf[0], pnt, &surf_uv[0][0],
                          &surf_uv[0][1], xyz_pt, &dist))
        EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);

     EFget_partolbasis(&msg_loc, sfs[0], env, &par_tol[0]);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

     EFvalidate_pt_on_seam(&msg_loc, surf[0], NULL, &sf_vertex[0], surf_uv[0],
			   env, par_tol[0].tol);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

     EFvalidate_pt_on_xyzdegen(&msg_loc, surf[0], NULL, &sf_vertex[0], 
                               surf_uv[0], env);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  par_tol[0] = this_tol;
  for(i=1; i<num_sfs; i++)
  {
     EFget_partolbasis(&msg_loc, sfs[i], env, &par_tol[i]);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

     if(!BSmdistptsf(&rc, surf[i], xyz_pt, &surf_uv[i][0],
                          &surf_uv[i][1], base_point, &dist))
        EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);

     EFvalidate_pt_on_seam(&msg_loc, surf[i], NULL, &sf_vertex[i], surf_uv[i],
			   env, par_tol[i].tol);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

     EFvalidate_pt_on_xyzdegen(&msg_loc, surf[i], NULL, &sf_vertex[i], 
                               surf_uv[i], env);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
  }
 
  if(num_sfs == 3)
  {
   /* There are 3 surfaces meeting at a point. Hence perform 3 surface
      iteration.
   */
      BStrpsfiter(surf[0], surf[1], surf[2], par_tol[0].tol, par_tol[1].tol,
                  par_tol[2].tol, &surf_uv[0][0], &surf_uv[0][1],
		  &surf_uv[1][0], &surf_uv[1][1],
		  &surf_uv[2][0], &surf_uv[2][1],
                  xyz_pt, &is_succ, &rc);
      EMerr_hndlr(rc!=BSSUCC, *msg, EMS_E_Fail, ret_end);
  }
  else if(num_sfs == 2)
  {
   /* There are only two participating surfaces. We need to compute the
      exact intersection point on the intersection curve between these two.
      Hence we perform what is called the curve-surface iteration.
   */
      IGRint	 iso = 0;
      IGRdouble  loc_my_uv[2], loc_comm_uv[2], junk_my_uv[2], 
		 junk_comm_uv[2], dist1, dist2;
      IGRpoint   loc_xyz_exact, junk_xyz_exact;

      is_succ = FALSE;
      for(j=0; (j<2) && !is_succ && (iso < 4); j++)
      {
         OM_BLOCK_MOVE(xyz_pt, loc_xyz_exact, 3*sizeof(IGRdouble));
         OM_BLOCK_MOVE(surf_uv[0], loc_my_uv, uv_size);
         OM_BLOCK_MOVE(surf_uv[1], loc_comm_uv, uv_size);
         rc = BSSUCC;
         is_succ = FALSE;
         BScvsfiter(surf[0], surf[1], iso++, surf[0]->u_phy_closed, 
		    surf[0]->v_phy_closed , surf[1]->u_phy_closed,
		    surf[1]->v_phy_closed,
                    par_tol[0].tol, par_tol[1].tol,
		    loc_xyz_exact, &loc_my_uv[0], &loc_my_uv[1],
                    &loc_comm_uv[0], &loc_comm_uv[1], &is_succ, &rc);
         if((rc!=BSSUCC) || !is_succ) {iso++; continue;}

         if(BSdistptpt(&rc, loc_xyz_exact, xyz_pt) < lentol) continue;

         /* Try with the other parameter remaining constant and select the
             closest point.
	 */
         OM_BLOCK_MOVE(xyz_pt, junk_xyz_exact, 3*sizeof(IGRdouble));
         OM_BLOCK_MOVE(surf_uv[0], junk_my_uv, uv_size);
         OM_BLOCK_MOVE(surf_uv[1], junk_comm_uv, uv_size);
         rc = BSSUCC;
         is_succ = FALSE;
         BScvsfiter(surf[0], surf[1], iso++, surf[0]->u_phy_closed, 
		    surf[0]->v_phy_closed , surf[1]->u_phy_closed,
		    surf[1]->v_phy_closed,
                    par_tol[0].tol, par_tol[1].tol,
		    junk_xyz_exact, &junk_my_uv[0], &junk_my_uv[1],
                    &junk_comm_uv[0], &junk_comm_uv[1], &is_succ, &rc);
         if((rc!=BSSUCC) || !is_succ) {iso++; continue;}

         dist1 = BSdistptpt(&rc, xyz_pt, loc_xyz_exact);
         dist2 = BSdistptpt(&rc, xyz_pt, junk_xyz_exact);
         if(dist2 < dist1)
         {
           OM_BLOCK_MOVE(junk_xyz_exact, loc_xyz_exact, 3*sizeof(IGRdouble));
           OM_BLOCK_MOVE(junk_my_uv, loc_my_uv, uv_size);
           OM_BLOCK_MOVE(junk_comm_uv, loc_comm_uv, uv_size);
         }
      } /* for(j=0; (j<2) && .....) */
      EMerr_hndlr(rc!=BSSUCC, *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr(!is_succ, *msg, EMS_I_NoSolution, ret_end);

      OM_BLOCK_MOVE(loc_xyz_exact, xyz_pt, 3*sizeof(IGRdouble));
      OM_BLOCK_MOVE(loc_my_uv, surf_uv[0], uv_size);
      OM_BLOCK_MOVE(loc_comm_uv, surf_uv[1], uv_size);
  } /* else if(num_sfs==2) ... curve-sf iteration */
  else /* num_sfs = 0  or 1 */
    EMerr_hndlr(TRUE, *msg, EMS_I_NoSolution, ret_end);

/* The exact xyz point has been obtained in xyz_pt. The exact uv points have
   also been obtained in surf_uv[][].
   All that remains now is to actually modify the model-space and uv-space
   geometries of all the intobjs incident at this vertex to end 'exactly'
   at the XYZ point and the respective UV point.
   First, set up new arrays to hold the surface par-tol and UV coordinate
   values for all the surfaces participating at the vertex.
*/
  if(num_inc_fwd+num_inc_bwd == 1) /* Maximum 3 surfaces at vertex */
  {
    par_tol_ptr = par_tol;
    uv_pt_ptr = &surf_uv[0][0];
  }
  else
  {
    par_tol_ptr = (struct EMSpartolbasis *) om$malloc(size = 
					    (num_inc_fwd+num_inc_bwd+2) *
					    sizeof(struct EMSpartolbasis));
    uv_pt_ptr = (IGRdouble *) om$malloc(size = (num_inc_fwd+num_inc_bwd+2) *
			      uv_size);
    mem_alloc = TRUE;

    count = 0;
    tmp_vert.p_intobj = this_intobjs[0];
    tmp_vert.location = END;
    sf_id = this_intobjs[0]->this_obj_node->this_obj;
    knt = 0;
    for(is_succ=FALSE; knt<num_sfs; knt++)
/*        if(sf_id.objid == sfs[knt].objid) COMMENTED - Ashok 31-Jan-94 */ 
	if((sf_vertex[knt].p_intobj == this_intobjs[0]) ||
	   (sf_vertex[knt].p_intobj == this_intobjs[1]))
	{
	   is_succ=TRUE;
	   break;
	}
    if(is_succ)
    {
	par_tol_ptr[count] = par_tol[knt];
	uv_pt_ptr[2*count] = surf_uv[knt][0];
	uv_pt_ptr[2*count+1] = surf_uv[knt][1];
    }
    else
    {
     	EFget_partolbasis(&msg_loc, sf_id, env, &par_tol_ptr[count]);
     	EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
	stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg_loc,
						  &env->md_env.matrix_type,
						  env->md_env.matrix, 1,
						  xyz_pt, &uv_pt_ptr[2*count],
						  &dist, base_point),
			   senderid = NULL_OBJID,
			   targetid = sf_id.objid,
			   targetos = sf_id.osnum);
	 EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

if(dist > lentol)
{
  if(dist > 2*cht_tol)
    printf("EMregen - Error:Vertex Not Preserved\n");
#ifdef DEBUG
  else
    printf("EMregen - Warning:Inaccurate Vertex\n");
  printf("                Distance of surface %ld from vertex is %lg\n",
			   (IGRint)sf_id.objid, dist);
  printf("                Number of edges at the vertex = %d\n",
			   2 + num_inc_fwd + num_inc_bwd);
#endif
}
	EMerr_hndlr(dist > 2*cht_tol, *msg, EMS_E_Fail, ret_end);

        EFvalidate_pt_on_seam(&msg_loc, NULL, &sf_id, &tmp_vert,
			      &uv_pt_ptr[2*count], env, par_tol_ptr[count].tol);
        EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

        EFvalidate_pt_on_xyzdegen(&msg_loc, NULL, &sf_id, &tmp_vert,
			      &uv_pt_ptr[2*count], env);
        EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    count++;

    for(i=FWD, num_intobjs=num_inc_fwd; i<=BWD;
				        i++, num_intobjs=num_inc_bwd)
    {
      for(j=0; j<num_intobjs; j++)
      {
        tmp_intobj = inc_intobjs[i][j].p_intobj;
        tmp_vert.p_intobj = tmp_intobj;
        tmp_vert.location = inc_intobjs[i][j].location;
        sf_id = tmp_intobj->this_obj_node->this_obj;
        knt = 0;
        for(is_succ=FALSE; knt<num_sfs; knt++)
/*        if(sf_id.objid == sfs[knt].objid) COMMENTED - Ashok 31-Jan-94 */
	  if(sf_vertex[knt].p_intobj == tmp_intobj)
	  {
	    is_succ=TRUE;
	    break;
	  }
        if(is_succ)
        {
	     par_tol_ptr[count] = par_tol[knt];
	     uv_pt_ptr[2*count] = surf_uv[knt][0];
	     uv_pt_ptr[2*count+1] = surf_uv[knt][1];

             EFvalidate_pt_on_seam(&msg_loc, surf[knt], NULL,
			           &tmp_vert, &uv_pt_ptr[2*count], env,
				   par_tol_ptr[count].tol);
             EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

             EFvalidate_pt_on_xyzdegen(&msg_loc, surf[knt], NULL,
			           &tmp_vert, &uv_pt_ptr[2*count], env);
             EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        else
        {
     	    EFget_partolbasis(&msg_loc, sf_id, env, &par_tol_ptr[count]);
     	    EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
	    stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg_loc,
						  &env->md_env.matrix_type,
						  env->md_env.matrix, 1,
						  xyz_pt, &uv_pt_ptr[2*count],
						  &dist, base_point),
			   senderid = NULL_OBJID,
			   targetid = sf_id.objid,
			   targetos = sf_id.osnum);
	    EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

if(dist > lentol)
{
  if(dist > 2*cht_tol)
    printf("EMregen - Error:Vertex Not Preserved\n");
#ifdef DEBUG
  else
    printf("EMregen - Warning:Inaccurate Vertex\n");
  printf("                Distance of surface %ld from vertex is %lg\n",
			   (IGRint)sf_id.objid, dist);
  printf("                Number of edges at the vertex = %d\n",
			   2 + num_inc_fwd + num_inc_bwd);
#endif
}
	   EMerr_hndlr(dist > 2*cht_tol, *msg, EMS_E_Fail, ret_end);

           EFvalidate_pt_on_seam(&msg_loc, NULL, &sf_id, &tmp_vert,
			      &uv_pt_ptr[2*count], env, par_tol_ptr[count].tol);
           EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

           EFvalidate_pt_on_xyzdegen(&msg_loc, NULL, &sf_id, &tmp_vert,
			      &uv_pt_ptr[2*count], env);
           EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

        } /* else of if(is_succ) */
        count++;
      } /* for(j=0, .... */
      if(num_intobjs && tmp_intobj->other_intobj_node)
      {
	/* Need to process the last surface */
        tmp_intobj = tmp_intobj->other_intobj_node;
        rev_connect = EFis_rev_connect(&msg_loc, tmp_intobj);
        tmp_vert.p_intobj = tmp_intobj;
        tmp_vert.location = (tmp_vert.location== END ?
				      (rev_connect==TRUE ? BEGIN : END) :
		                      (rev_connect==TRUE ? END   : BEGIN));
	tmp_intobj2 = (tmp_vert.location == END ? tmp_intobj->fwd :
						  tmp_intobj->bwd);
        sf_id = tmp_intobj->this_obj_node->this_obj;
        knt = 0;
        for(is_succ=FALSE; knt<num_sfs; knt++)
/*        if(sf_id.objid == sfs[knt].objid) COMMENTED - Ashok 31-Jan-94 */
	  if((sf_vertex[knt].p_intobj == tmp_intobj) ||
	     (sf_vertex[knt].p_intobj == tmp_intobj2))
	  {
	    is_succ=TRUE;
	    break;
	  }
        if(is_succ)
        {
	     par_tol_ptr[count] = par_tol[knt];
	     uv_pt_ptr[2*count] = surf_uv[knt][0];
	     uv_pt_ptr[2*count+1] = surf_uv[knt][1];

             EFvalidate_pt_on_seam(&msg_loc, surf[knt], NULL,
			           &tmp_vert, &uv_pt_ptr[2*count], env,
				   par_tol_ptr[count].tol);
             EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

             EFvalidate_pt_on_xyzdegen(&msg_loc, surf[knt], NULL,
			           &tmp_vert, &uv_pt_ptr[2*count], env);
             EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        else
        {
     	    EFget_partolbasis(&msg_loc, sf_id, env, &par_tol_ptr[count]);
     	    EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
	    stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg_loc,
						  &env->md_env.matrix_type,
						  env->md_env.matrix, 1,
						  xyz_pt, &uv_pt_ptr[2*count],
						  &dist, base_point),
			   senderid = NULL_OBJID,
			   targetid = sf_id.objid,
			   targetos = sf_id.osnum);
	    EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

if(dist > lentol)
{
  if(dist > 2*cht_tol)
    printf("EMregen - Error:Vertex Not Preserved\n");
#ifdef DEBUG
  else
    printf("EMregen - Warning:Inaccurate Vertex\n");
  printf("                Distance of surface %ld from vertex is %lg\n",
			   (IGRint)sf_id.objid, dist);
  printf("                Number of edges at the vertex = %d\n",
			   2 + num_inc_fwd + num_inc_bwd);
#endif
}
	   EMerr_hndlr(dist > 2*cht_tol, *msg, EMS_E_Fail, ret_end);

           EFvalidate_pt_on_seam(&msg_loc, NULL, &sf_id, &tmp_vert,
			      &uv_pt_ptr[2*count], env, par_tol_ptr[count].tol);
           EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

           EFvalidate_pt_on_xyzdegen(&msg_loc, NULL, &sf_id, &tmp_vert,
			      &uv_pt_ptr[2*count], env);
           EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

        } /* else of if(is_succ) */
        count++;
      } /* if(num_intobjs && tmp_intobj->other_intobj_node) */
    } /* for(i=FWD,.... */
  }

   /* Now we are ready to modify all the intobjs incident at the vertex */

   /* Modify the incoming intobj pair */
   count = 0;
   for(i=0; i<2; i++)
   {
     /* If intobj is along an ISO direction check if refinement is needed. If
	needed then the intobj needs to be re-mapped before it cn be refined.
        If not do NOT attempt refinement (because refinement may result in a 
        non-ISO intobj) - Ashok 18/Oct-93
     */

     location = (i==0 ? END : BEGIN);
     if(this_intobjs[i]->props & EMSintobj_special_tangent)
     {
	IGRboolean  refine;
	stat_func = EFmodify_spl_intobj(&msg_loc, this_intobjs[i], location,
				        &uv_pt_ptr[2*count], xyz_pt,
				        par_tol_ptr[count].tol, env, &refine);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
        if(!refine) continue;
     }
     else if(this_intobjs[i]->props & EMSintobj_isocurve)
     {
	IGRboolean  refine;
        if(!(this_intobjs[i]->props & EMSintobj_tangent)) continue;
        stat_func = EFremapped_isocurve(&msg_loc, this_intobjs[i], location,
					&uv_pt_ptr[2*count], xyz_pt, lentol, 
					par_tol_ptr[count].tol, env, &refine);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
        if(!refine) continue;
     }

     location = (this_intobjs[i]->reversed ? (location == END ? BEGIN : END) :
					     (location == END ? END :BEGIN));
     EFmodify_end(&msg_loc, &this_intobjs[i]->this_uvintobj, 2, location,
		  &uv_pt_ptr[2*count], par_tol_ptr[count].tol, TRUE);
     EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

     other_intobj = this_intobjs[i]->other_intobj_node;
     if(other_intobj)
        free_data = !EMis_same_dataselect(&this_intobjs[i]->this_xyzintobj,
					      &other_intobj->this_xyzintobj);
     else free_data = TRUE;
     EFmodify_end(&msg_loc, &this_intobjs[i]->this_xyzintobj, 3, location,
		xyz_pt, lentol, free_data);
     EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
   }
   count++;

   /* Now modify the incident intobjs lying on adjoining surfaces. We traverse
      in a cyclic fasion starting from sfs[1]
   */
   for(k=FWD, num_intobjs=num_inc_fwd; k<=BWD; k++, num_intobjs=num_inc_bwd)
   {
     intobj_pair[1] = (k==FWD ? this_intobjs[START]->other_intobj_node :
				   this_intobjs[STOP]->other_intobj_node);
     for(j=0; j<num_intobjs; count++, j++)
     {
       intobj_pair[0] = inc_intobjs[k][j].p_intobj;
       location = inc_intobjs[k][j].location;
       for(i=0; i<2; i++, location = (location==END ? BEGIN : END))
       {
         if(intobj_pair[i]->props & EMSintobj_special_tangent)
         {
	   IGRboolean  refine;
	   stat_func = EFmodify_spl_intobj(&msg_loc, intobj_pair[i], location,
				           &uv_pt_ptr[2*count], xyz_pt,
				           par_tol_ptr[count].tol, env,&refine);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
           if(!refine) continue;
         }
         else if(intobj_pair[i]->props & EMSintobj_isocurve)
	 {
         /* intobj is marked ISO. check if refining is needed.
	    If needed, remap the intobj's uv-data
         */
	   IGRboolean  refine;
           if(!(intobj_pair[i]->props & EMSintobj_tangent)) continue;
           stat_func = EFremapped_isocurve(&msg_loc, intobj_pair[i], location,
					   &uv_pt_ptr[2*count], xyz_pt, lentol, 
					   par_tol_ptr[count].tol, env,&refine);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
           if(!refine) continue;
	 }

         loc_locn = (intobj_pair[i]->reversed ? (location==END ? BEGIN : END) :
					        location);
         EFmodify_end(&msg_loc, &intobj_pair[i]->this_uvintobj, 2, loc_locn,
		      &uv_pt_ptr[2*count], par_tol_ptr[count].tol, TRUE);
         EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

         other_intobj = intobj_pair[i]->other_intobj_node;  
         if(other_intobj)
            free_data = !EMis_same_dataselect(&intobj_pair[i]->this_xyzintobj,
					      &other_intobj->this_xyzintobj);
         else free_data = TRUE;
         EFmodify_end(&msg_loc, &intobj_pair[i]->this_xyzintobj, 3, 
			 loc_locn, xyz_pt, lentol, free_data);
	 EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
       } /* ith for loop */
       intobj_pair[1] = intobj_pair[0]->other_intobj_node;
     } /* jth for loop */

     /* Now modify the intobj pair on the last surface (if one exists) */
     if(intobj_pair[1] && num_intobjs)  /* last surface needs to be processed */
     {
      intobj_pair[0] = (k==FWD ? this_intobjs[STOP]->other_intobj_node :
				 this_intobjs[START]->other_intobj_node);
      rev_connect = EFis_rev_connect(&msg_loc, intobj_pair[0]);
      location = (k==FWD ? BEGIN : END);
      location = (rev_connect ? (location==END ? BEGIN : END) :
				 location);
      for(i=0; i<2; i++, location = (location==END ? BEGIN : END))
      {
         if(intobj_pair[i]->props & EMSintobj_special_tangent)
	 {
	   IGRboolean  refine;
           stat_func = EFmodify_spl_intobj(&msg_loc, intobj_pair[i], location,
					   &uv_pt_ptr[2*count], xyz_pt,
					   par_tol_ptr[count].tol, env,&refine);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
           if(!refine) continue;
	 }
         if(intobj_pair[i]->props & EMSintobj_isocurve)
	 {
         /* intobj is marked ISO. check if refining is needed.
	    If needed, remap the intobj's uv-data
         */
	   IGRboolean  refine;
           if(!(intobj_pair[i]->props & EMSintobj_tangent)) continue;
           stat_func = EFremapped_isocurve(&msg_loc, intobj_pair[i], location,
					   &uv_pt_ptr[2*count], xyz_pt, lentol, 
					   par_tol_ptr[count].tol, env,&refine);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
           if(!refine) continue;
	 }

         loc_locn = (intobj_pair[i]->reversed ? (location==END ? BEGIN : END) :
					        location);

         EFmodify_end(&msg_loc, &intobj_pair[i]->this_uvintobj, 2, loc_locn,
		      &uv_pt_ptr[2*count], par_tol_ptr[count].tol, TRUE);
         EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

         other_intobj = intobj_pair[i]->other_intobj_node;  
         if(other_intobj)
            free_data = !EMis_same_dataselect(&intobj_pair[i]->this_xyzintobj,
					      &other_intobj->this_xyzintobj);
         else free_data = TRUE;
         EFmodify_end(&msg_loc, &intobj_pair[i]->this_xyzintobj, 3, 
			 loc_locn, xyz_pt, lentol, free_data);
	 EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
      } /* ith for loop */
     } /* if(intobj_pair[1] && num_intobjs) */
   } /* for k=FWD, .... */
ret_end:
   for(i=0; i<num_sfs; i++)
      if(surf[i]) free(surf[i]);
   if(mem_alloc)
   {
      if(par_tol_ptr) om$dealloc(ptr = par_tol_ptr);
      if(uv_pt_ptr) om$dealloc(ptr = uv_pt_ptr);
   }
   return;
}

/* ************************************************************************* */
void EFmodify_end(msg, data_sel, dim, location, extnd_pt, tol, free_dat)
/* ************************************************************************* */
IGRlong			*msg;
struct EMSdataselect	*data_sel;
IGRint			dim, location;
IGRdouble		*extnd_pt, tol;
IGRboolean		free_dat;

/* NOTE: The free_dat currently appears to make sense only if the incoming
         data is EMSdata_curve3d. So it is used only for this data_type.
	 Otherwise, the data gets freed automatically in EMextend_poly.
	 ( Does that mean XYZ polylines are never shared by two intobjs ??)
*/
{
   IGRlong		msg_loc, stat_OM, rc;
   IGRboolean		stat_func;
   enum EMSdatatype	dat_typ;
   struct IGRbsp_curve	*out_cv = NULL;

   extern IGRlong	EMextend_poly(), EMextend_curve();

   *msg = EMS_S_Success;
   stat_OM = OM_S_SUCCESS;

   dat_typ = data_sel->datatype;
   if(dat_typ == EMSdata_poly2d || dat_typ == EMSdata_poly3d)
   {
	 stat_OM = EMextend_poly(&msg_loc, dim, data_sel->data.poly, NULL,
		     extnd_pt, &location, FALSE, NULL, NULL, 
		     tol, FALSE);
	 EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);
   }
   else if(data_sel->datatype == EMSdata_curve3d)
   {
	 stat_OM = EMextend_curve(&msg_loc, &data_sel->data.curve, &out_cv,
		     extnd_pt, &location, tol, dim, FALSE);
	 EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);
	 if(free_dat) stat_func = BSfreecv(&rc, data_sel->data.curve);
	 data_sel->data.curve = out_cv;
	 
   }
   else				/* invalid data-type */
      *msg = EMS_E_Fail;

ret_end:
   return;
}


/* ************************************************************************* */
void EFget_partolbasis(msg, sf_grid, env, partolb)
/* ************************************************************************* */
IGRlong			*msg;
struct GRid		sf_grid;
struct GRmd_env		*env;
struct EMSpartolbasis	*partolb;

{
  IGRlong		stat_OM, msg_loc;
/*  IGRboolean		world=TRUE; */
  struct IGRbsp_surface *loc_srf;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

    EMgetabsg (&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
               sf_grid.osnum, sf_grid.objid, &loc_srf);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    BSsfkttol2 (loc_srf->u_order, loc_srf->v_order,
       loc_srf->u_knots, loc_srf->v_knots, 
       loc_srf->u_num_poles, loc_srf->v_num_poles, loc_srf->poles, 
       loc_srf->weights, &partolb->tol, &msg_loc);

/*
  stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                 &env->md_env.matrix_type,
                                 env->md_env.matrix, &world, TRUE,
                                 &partolb->tol),
			  senderid = NULL_OBJID,
			  targetos = sf_grid.osnum,
                          targetid = sf_grid.objid);
  EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_SurfaceError, 
		 ret_end);
*/
  partolb->in_world = TRUE;
  partolb->is_valid = TRUE;
  partolb->mattyp = &env->md_env.matrix_type;
  partolb->mat = env->md_env.matrix;

ret_end:
  return;
}


/* ************************************************************************* */
static void EFget_split_point(msg, this_intobjs, uvtol, lentol, env, 
			      num_inc_fwd, num_inc_bwd, inc_intobjs, p_pypt1, 
			      p_pypt2, level)
/* ************************************************************************* */
IGRlong			*msg, num_inc_fwd, num_inc_bwd;
struct EMSintobj	*this_intobjs[2];
IGRdouble		uvtol, lentol;
struct GRmd_env		*env;
struct EMregen_inc_info *inc_intobjs[2];
struct EMSpypoint	**p_pypt1, **p_pypt2;
IGRushort               level;

{
  IGRlong		stat_OM, msg_loc, rc, num_inters, num_intobjs,
			i, j, knt;
  IGRboolean		swap = FALSE;
  IGRushort             ignore_spl_tan;
  struct GRid		other_sf_grid, this_sf_grid;
  struct EMSpypoint	*tmp_pypt1=NULL, *tmp_pypt2=NULL;
  struct EMSintobj	*other_intobj, *incident_intobj, *p_intobjs[2];
  struct EMSpartolbasis partolb;

  extern struct EMSpypoint	*EMpypoint_malloc();
  extern void			EFget_intersection_points(), EMpypoint_free();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  num_inters = 0;
  this_sf_grid = this_intobjs[0]->this_obj_node->this_obj;

  for(knt=START, ignore_spl_tan=0x1; knt<=STOP && num_inters==0;
                                                  ignore_spl_tan=0x0, knt++)

   for(i=FWD, num_intobjs = num_inc_fwd; !num_inters && i<=BWD;
				        num_intobjs = num_inc_bwd, i++)
   {
     /* Try for intersection between the incoming intobjs */
     if(i==FWD && (!(this_intobjs[0]->props & EMSintobj_special_tangent) &&
		  !(this_intobjs[1]->props & EMSintobj_special_tangent)))
     {
       if(this_intobjs[0]->this_uvintobj.datatype == EMSdata_curve3d &&
	  this_intobjs[1]->this_uvintobj.datatype == EMSdata_poly2d  &&
          !(this_intobjs[1]->props & EMSintobj_seam)) swap = TRUE;

       EFget_intersection_points(&msg_loc, uvtol, NULL, NULL,
				 swap ? &this_intobjs[1]->this_uvintobj :
					&this_intobjs[0]->this_uvintobj, FALSE,
				 swap ? &this_intobjs[0]->this_uvintobj :
					&this_intobjs[1]->this_uvintobj, FALSE,
                                 &num_inters, swap ? p_pypt2 : p_pypt1,
				 swap ? p_pypt1 : p_pypt2);
       EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
       EFdetect_duplicate(&num_inters, *p_pypt1, *p_pypt2);
#ifdef DEBUG
if(num_inters == 0)
  printf("  EMregen_tpgy: No intersection found between this intobjs pair\n");
#endif
      /* If more than one intersection point has been returned we need to
	 determine the one to keep and discard the others.
      */
       if(num_inters > 1)
       {
             EFretain_the_right_splitpt(&msg_loc, env,
                                  this_intobjs[0], this_intobjs[1], 
				  (num_inc_fwd ? inc_intobjs[FWD][0].p_intobj :
					 	 (num_inc_bwd ? 
						  inc_intobjs[BWD][0].p_intobj:
						  NULL)),
                                  p_pypt1, p_pypt2, uvtol, lentol, level);
             if(EMSerror(msg_loc))
	     {
		msg_loc = EMS_S_Success;
		num_inters = 0;
	     }
       }
     } /* if(i==FWD) */
     other_intobj = (i==FWD ? this_intobjs[0]->other_intobj_node :
			     this_intobjs[1]->other_intobj_node);
     incident_intobj = (i==FWD ? this_intobjs[1] : this_intobjs[0]);

     for(j=0; !num_inters && j<num_intobjs; incident_intobj=other_intobj,
			    other_intobj=p_intobjs[0]->other_intobj_node, j++)
     {
       p_intobjs[0] = (i==FWD ? inc_intobjs[FWD][j].p_intobj :
				inc_intobjs[BWD][j].p_intobj);
       p_intobjs[1] = other_intobj;
       if(ignore_spl_tan)
         if(p_intobjs[0]->props & EMSintobj_special_tangent ||
            p_intobjs[1]->props & EMSintobj_special_tangent) continue;

       other_sf_grid = p_intobjs[0]->this_obj_node->this_obj;
       EFget_partolbasis(&msg_loc, other_sf_grid, env, &partolb);
       swap = FALSE;
       if(p_intobjs[0]->this_uvintobj.datatype == EMSdata_curve3d &&
	  p_intobjs[1]->this_uvintobj.datatype == EMSdata_poly2d) swap = TRUE;

       EFget_intersection_points(&msg_loc, partolb.tol, NULL, NULL,
				 swap ? &p_intobjs[1]->this_uvintobj :
					&p_intobjs[0]->this_uvintobj, FALSE,
				 swap ? &p_intobjs[0]->this_uvintobj :
					&p_intobjs[1]->this_uvintobj, FALSE,
                                 &num_inters, swap ? &tmp_pypt2 : &tmp_pypt1,
				 swap ? &tmp_pypt1 : &tmp_pypt2);
       EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
       EFdetect_duplicate(&num_inters, tmp_pypt1, tmp_pypt2);
#ifdef DEBUG
if(num_inters == 0)
  printf("  EMregen_tpgy: No intersection found between inc. intobjs pair\n");
#endif
      /* If more than one intersection point has been returned we need to
	 determine the one to keep and discard the others.
      */
       if(num_inters > 1)
       {
             EFretain_the_right_splitpt(&msg_loc, env,
                                  p_intobjs[0], p_intobjs[1],
				  incident_intobj, &tmp_pypt1, &tmp_pypt2,
				  partolb.tol, lentol, level);
             if(EMSerror(msg_loc))
	     {
		msg_loc = EMS_S_Success;
		num_inters = 0;
	     }
       }
     } /* for(j=0; !num_inters && j<num_intobjs; j++) */

     /* Try intersecting the intobj pair on the last surface */
     if(!num_inters && i==FWD && other_intobj)
     {
       p_intobjs[0] = this_intobjs[1]->other_intobj_node;
       p_intobjs[1] = other_intobj;
       if(ignore_spl_tan)
         if(p_intobjs[0]->props & EMSintobj_special_tangent ||
            p_intobjs[1]->props & EMSintobj_special_tangent) continue;

       other_sf_grid = p_intobjs[0]->this_obj_node->this_obj;
       EFget_partolbasis(&msg_loc, other_sf_grid, env, &partolb);
       swap = FALSE;
       if(p_intobjs[0]->this_uvintobj.datatype == EMSdata_curve3d &&
	  p_intobjs[1]->this_uvintobj.datatype == EMSdata_poly2d) swap = TRUE;

       EFget_intersection_points(&msg_loc, partolb.tol, NULL, NULL,
				 swap ? &p_intobjs[1]->this_uvintobj :
					&p_intobjs[0]->this_uvintobj, FALSE,
				 swap ? &p_intobjs[0]->this_uvintobj :
					&p_intobjs[1]->this_uvintobj, FALSE,
                                 &num_inters, swap ? &tmp_pypt2 : &tmp_pypt1,
				 swap ? &tmp_pypt1 : &tmp_pypt2);
       EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
       EFdetect_duplicate(&num_inters, tmp_pypt1, tmp_pypt2);
#ifdef DEBUG
if(num_inters == 0)
  printf("  EMregen_tpgy: No intersection found between inc. intobjs pair\n");
#endif
      /* If more than one intersection point has been returned we need to
	 determine the one to keep and discard the others.
      */
       if(num_inters > 1)
       {
             EFretain_the_right_splitpt(&msg_loc, env,
                                  p_intobjs[0], p_intobjs[1],
				  incident_intobj, &tmp_pypt1, &tmp_pypt2,
				  partolb.tol, lentol, level);
             if(EMSerror(msg_loc))
	     {
		msg_loc = EMS_S_Success;
		num_inters = 0;
	     }
       }
     } /* if(!num_inters && i==FWD && other_intobj) */
   } /* for(i==FWD, num_intobjs=num_inc_fwd; .... */

#ifdef DEBUG
if(num_inters == 0)
  printf("EMregen_tpgy: Error - No intersection found between intobj pair\n");
#endif
  EMerr_hndlr ((num_inters == 0), *msg, EMS_E_Fail, ret_end);

  if(tmp_pypt1 && tmp_pypt2)
  {
    /* The split point has been computed using adjoining incident intobj pair
       on a neighbouring surface (other_sf_grid). So compute the same point
       w.r.t the surface containing the incoming intobj pair (this_intobjs)
    */
	IGRdouble		uv[3], dist;
	IGRpoint		xyz_pt, base_pt;
	struct IGRbsp_surface	*other_srf=NULL, *this_srf=NULL;
	extern IGRlong			EMprojectpt();
 
        uv[2] = 0.0;

	EMgetabsg (&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
		   other_sf_grid.osnum, other_sf_grid.objid, &other_srf);
	EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	BSsfeval(other_srf, tmp_pypt1->point[0], tmp_pypt1->point[1], 0,
		 (IGRpoint *)xyz_pt, &rc);
	EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);

	EMgetabsg (&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
		   this_sf_grid.osnum, this_sf_grid.objid, &this_srf);
	EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

	if(!BSmdistptsf(&rc, this_srf, xyz_pt, &uv[0], &uv[1], base_pt, &dist))
        EMerr_hndlr(TRUE, *msg, EMS_E_BSerror, ret_end);

	*p_pypt1 = EMpypoint_malloc(&msg_loc, 1);
	*p_pypt2 = EMpypoint_malloc(&msg_loc, 1);
	stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			      env->md_env.matrix,
			      &this_intobjs[0]->this_uvintobj,
			      1, uv, uvtol, *p_pypt1, &dist);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			      env->md_env.matrix,
			      &this_intobjs[1]->this_uvintobj,
			      1, uv, uvtol, *p_pypt2, &dist);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  } /* if(other_sf_grid.objid != NULL_OBJID) */

ret_end:
  if(tmp_pypt1) EMpypoint_free(tmp_pypt1, MAXINT);
  if(tmp_pypt2) EMpypoint_free(tmp_pypt2, MAXINT);
  return;
}


/* The static function below is a kludge to handle duplicate intersection
   sometimes returned by EFget_intersection_points()
*/
static void EFdetect_duplicate(num_inters, p_pypt1, p_pypt2)
IGRlong			*num_inters;
struct EMSpypoint	*p_pypt1, *p_pypt2;
{
   IGRdouble	*wts = NULL;
   IGRpoint	pts[2];
   IGRboolean	coinc;
   BSrc		rc;

   extern void EMpypoint_free();

   if(*num_inters != 2) return;

   OM_BLOCK_MOVE(&p_pypt1->point[0], pts[0], sizeof(IGRpoint));
   OM_BLOCK_MOVE(&p_pypt1->next->point[0], pts[1], sizeof(IGRpoint));
   pts[0][2] = pts[1][2] = 0.0; /* zap the z-coordinate */
   BScoincdpts( 2, pts, wts, &coinc, &rc );
   if(coinc)
   {
	*num_inters = 1;
	EMpypoint_free(p_pypt1->next, MAXINT);
	p_pypt1->next = NULL;
	EMpypoint_free(p_pypt2->next, MAXINT);
	p_pypt2->next = NULL;
   }
   return;
}

/****************************************************************************/
static IGRboolean EFremapped_isocurve(msg, p_intobj, location, exact_uv,
				      exact_pt, lentol, uvtol, env, refine)
/****************************************************************************/
IGRlong			*msg;      /* O */
struct EMSintobj	*p_intobj; /* I/O */
IGRint			location;  /* I */
IGRdouble		exact_uv[2], exact_pt[3], lentol, uvtol;  /* I */
struct GRmd_env		*env;      /* I */
IGRboolean		*refine;   /* O */
{
  IGRlong		msg_loc, stat_OM;
  IGRboolean		mapped, need_mapping, stat_func, const_u;
  IGRushort		other_end_exact, opt;
  IGRint		tmp_loc;
  IGRdouble		start_pt[3], stop_pt[3], start_uv[2], stop_uv[2],
			set_u, set_v, *end_pt;
  struct EMSdataselect  uv_datasel, xyz_datasel;
  struct EMSinters	*tmp_inters;
  struct EMSintobj	*tmp_intobj;

  extern struct EMSintobj	*EFext_and_prj_cv();
  extern IGRboolean		EMis_same_dataselect();
  extern void			EMinters_free();
  extern IGRlong		EMgetendpts_xyz(), EMgetendpts_uv();

	*refine = need_mapping = mapped = FALSE;

	if(p_intobj->props & EMSintobj_xyzdegenerate) goto ret_end;

	OM_BLOCK_MOVE(&p_intobj->this_xyzintobj, &xyz_datasel,
		      sizeof(struct EMSdataselect));
	OM_BLOCK_MOVE(&p_intobj->this_uvintobj, &uv_datasel,
		      sizeof(struct EMSdataselect));

	end_pt = exact_pt; /* to supress compiler warning */

	/* Get the UV and XYZ end-points of the incoming intobj */

	stat_OM = EMgetendpts_xyz(&msg_loc, &env->md_env.matrix_type,
			            env->md_env.matrix,
				    &p_intobj->this_xyzintobj,
				    p_intobj->reversed,
				    1, start_pt, stop_pt);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

	stat_func = EFchk_for_iso(&p_intobj->this_uvintobj, &uvtol,
				  p_intobj->reversed, start_uv, stop_uv, 
				  &const_u);
	EMerr_hndlr(!stat_func, *msg, EMS_E_Fail,ret_end);

	set_u = start_uv[0];
	set_v = start_uv[1];
	end_pt = (location == BEGIN ? start_uv : stop_uv);
	if(const_u)
	{
	  if(fabs(set_u - exact_uv[0]) > uvtol) need_mapping = TRUE;
	  if(!need_mapping)
	     if(fabs(end_pt[1] - exact_uv[1]) > uvtol)
	     {
	        *refine = TRUE;
		/* since we will refining the iso-intobj itself using the
		   exact_uv[] make sure the constant U value is not changed
		   during refining
		*/
		exact_uv[0] = set_u;
	     }
	}
	else
	{
	  if(fabs(set_v - exact_uv[1]) > uvtol) need_mapping = TRUE;
	  if(!need_mapping)
	     if(fabs(end_pt[0] - exact_uv[0]) > uvtol)
	     {
		*refine = TRUE;
		/* since we will refining the iso-intobj itself using the
		   exact_uv[] make sure the constant V value is not changed
		   during refining
		*/
		exact_uv[1] = set_v;
	     }
	}

	if(need_mapping)
	{
	/* Need to re-map the intobj */

#ifdef DEBUG
printf("  Re-mapping ISO-intobj. ");
if(const_u) printf("%lg > %lg \n", fabs(set_u - exact_uv[0]), uvtol);
else printf("%lg > %lg \n", fabs(set_v - exact_uv[1]), uvtol);
#endif
	  tmp_inters = NULL;
	  opt = EMSExtPrj_NoClip | EMSExtPrj_WantSingleOut;
	  tmp_intobj = EFext_and_prj_cv(&msg_loc,
					p_intobj->this_obj_node->this_obj,
					p_intobj->this_obj_node->this_obj,
					opt, NULL,
					xyz_datasel.data.curve,
                                        FALSE,
					0.0, 0.0,
                                        &env->md_env,
                                        &tmp_inters, FALSE, NULL, NULL);
	  EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	/* Exchange the data of tmp_intobj with that of iso-intobj (p_intobj)
	   and free tmp_inters (which internally will free tmp_intobj).
	*/
	  OM_BLOCK_MOVE(&tmp_intobj->this_uvintobj, &p_intobj->this_uvintobj,
			sizeof(struct EMSdataselect));
	  OM_BLOCK_MOVE(&tmp_intobj->this_xyzintobj, &p_intobj->this_xyzintobj,
			sizeof(struct EMSdataselect));
	  OM_BLOCK_MOVE(&uv_datasel, &tmp_intobj->this_uvintobj,
			sizeof(struct EMSdataselect));
	  if(p_intobj->other_intobj_node && 
	     EMis_same_dataselect(&xyz_datasel,
				  &p_intobj->other_intobj_node->this_xyzintobj)
	    )
	  {
		tmp_intobj->this_xyzintobj.datatype = EMSdata_null;
		tmp_intobj->this_xyzintobj.data.curve = NULL;
	  }
	  else
	        OM_BLOCK_MOVE(&xyz_datasel, &tmp_intobj->this_xyzintobj,
			      sizeof(struct EMSdataselect));
          EMinters_free(tmp_inters, OM_K_MAXINT);

	  /* If the other end of the incoming iso-intobj is exact we
	     need to make sure that this exactness is preserved in the
	     mapped intobj.
	  */
	  other_end_exact = 0x0;
	  other_end_exact = (location == BEGIN ?
			     p_intobj->props & EMSintobj_exact_atstop :
			     p_intobj->props & EMSintobj_exact_atstart);

	  if(other_end_exact)
	  {
	    /* get the location (BEGIN or END) corresponding to the "other-end"
	       in the variable "tmp_loc".
	    */
	    end_pt =  (location == BEGIN ? &stop_uv[0] : &start_uv[0]);
	    tmp_loc = (location == BEGIN ? (p_intobj->reversed ? BEGIN : END) :
					   (p_intobj->reversed ? END : BEGIN));

	    EFmodify_end(&msg_loc, &p_intobj->this_uvintobj, 2, tmp_loc,
		         end_pt, uvtol, TRUE);
	    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	    end_pt =  (location == BEGIN ? &stop_pt[0] : &start_pt[0]);
	    EFmodify_end(&msg_loc, &p_intobj->this_xyzintobj, 3, tmp_loc,
		         end_pt, lentol, TRUE);
	    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
	  }
	  p_intobj->props = p_intobj->props & (~EMSintobj_isocurve);
	  *refine = TRUE;
	  mapped = TRUE;
	}
ret_end:
	return(mapped);
}

/****************************************************************************/
static IGRboolean EFchk_for_iso(uvdata, uvtol, rev, start_uv, stop_uv, const_u)
/****************************************************************************/
struct EMSdataselect	*uvdata;	 /* I */
IGRdouble		*uvtol,		 /* I */
	        start_uv[2], stop_uv[2]; /* O */
IGRboolean	rev,			 /* I */
	        *const_u;		 /* O */

{
   IGRlong		stat_OM, msg_loc;
   IGRboolean		iso_u, iso_v;
   IGRdouble		tol, set_u, set_v;

   extern IGRlong	EMgetendpts_uv();

   stat_OM = OM_S_SUCCESS;
   iso_u = iso_v = TRUE;
   tol = (uvtol ? *uvtol : EMS_HIGH_UVLENTOL);

   stat_OM = EMgetendpts_uv(&msg_loc, uvdata, rev, 1, start_uv, stop_uv);
   EMerr_hndlr(EMSerror(stat_OM & msg_loc), msg_loc, EMS_E_Fail, ret_end);

   set_u = start_uv[0];
   set_v = start_uv[1];

   if (fabs(stop_uv[0] - set_u) > tol)  iso_u = FALSE;
   if (fabs(stop_uv[1] - set_v) > tol)  iso_v = FALSE;

   if (iso_u && iso_v) return FALSE;
   else if (iso_u || iso_v)
   {
     if(iso_u)
     {
       *const_u = TRUE;
       start_uv[0] = (start_uv[0] + stop_uv[0]) / 2.0;
       stop_uv[0] = start_uv[0];
     }
     else
     {
       *const_u = FALSE;
       start_uv[1] = (start_uv[1] + stop_uv[1]) / 2.0;
       stop_uv[1] = start_uv[1];
     }
     return TRUE;
   }
   else return FALSE;
 
ret_end:
  return FALSE;
}


/* ************************************************************************* */
static void EFretain_the_right_splitpt(msg, env, this_intobj, next_intobj,
                               chk_intobj, pypt, pypt_oth, uvtol, lentol, level)
/* ************************************************************************* */
IGRlong			*msg;
struct GRmd_env         *env;
struct EMSintobj	*this_intobj, *next_intobj, *chk_intobj;
struct EMSpypoint	**pypt, **pypt_oth;
IGRdouble		uvtol, lentol;
IGRushort               level;
{

/* Steps:

   If there is no incident intobj, assume that the two incoming intobjs are
   free. Arbitrarily, choose the first split point and return.
   Else
     Project all points onto the incident intobj (chk_intobj)
     Keep all the points which are within "tol" of the incident intobj
     If num_points > 1
      then
       if (this_intobj is exact at start)
         then 
             get the start point
             get the pypt which is closest and greater than the start
              point. This is the required pypt. RETURN.
       else if (next_intobj is exact at end)
         then
             get the end point
             get the pypt which is closest and less than the end point.
             This is the required pypt,. RETURN.
       else
         Find the largest pypt on this_intobj and
              the smallest pypt on the next_intobj
         If these are the same 
           then the intobj has been found, RETURN
         Else
            Get the incident intobjs for the next_intobj
            Get the split points for the next_intobj and
               the next-to-next intobj.
            Call this function for the next intobj and
             the next-to-next intobj.
            If this function returns a count of 1 (new pypt)
             then
                arrange the old pypts and the "new pypt" on the
                next intobj in ascending order and find the
                old pypt which is closest and less than the
                the "new pypt". This is the required pypt. RETURN.
            Else
              Get the incident intobjs for the previous_intobj
              Get the split points for the previous_intobj and
                 this_intobj.
              Call this function for the previous intobj and
               this_intobj.
              If this function returns a count of 1
               then
                  arrange the old pypts and the "new pypt" on 
                  this_intobj in descending order and find the
                  old pypt which is closest and greater than the
                  the "new pypt". This is the required pypt. RETURN.
              Else

                 REPORT FAILURE IN RESOLVING MULTIPLE SPLIT POINTS.

*/
      
  IGRlong		msg_loc, stat_OM;
  IGRdouble		min_dist, *dist=NULL, ndist, span_value, mindist, 
                        min_span_value, this_span_value, oth_span_value,
                        this_value, oth_value /* min_value, max_value */;
  IGRpoint		pnt, start_pt, stop_pt;
  struct EMSpypoint	*p_pypt, *p_pypt_next, *p_pypt_other, *new_pypt,
			*min_dist_pypt[5], *min_dist_oth_pypt[5], tmp_pypt,
                        *max_this_pypt=NULL, *min_oth_pypt=NULL, *oth_pypt;
  IGRshort              *p_mattyp;
  IGRmatrix             mat;
  IGRint                ii, count, min_pypt_count;
  IGRdouble             cht;

  extern IGRlong	EMprojectpt();
  extern void		EMpypoint_free();
  extern IGRlong        EMgetendpts_uv();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  p_mattyp = &env->md_env.matrix_type;
  OM_BLOCK_MOVE(env->md_env.matrix, mat, sizeof(IGRmatrix));

  min_dist = MAXDOUBLE;
  min_pypt_count = 0;
  new_pypt = NULL;
  p_pypt = *pypt;

/* This BLOCK added to arbitrarily keep the first split point if both the
   intersecting intobjs are "free" (TR 119416982) - Ashok Feb-10-94 */

  if(!chk_intobj)
  {
    /* No incident intobj. This means both the incoming intobjs are free.
       Arbitrarily choose the first intersection point and return
    */
    new_pypt = p_pypt;
    goto ret_end;  
  }
/* BLOCK END */

  /* Get count of number of pypts */
  count = 0;
  while(p_pypt)
  {
    count++;
    p_pypt = p_pypt->next;
  }

  dist = (IGRdouble *) om$malloc(size = count * sizeof(IGRdouble));
  EMerr_hndlr(!dist, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

#ifdef DEBUG
 printf("New Function : Trying Resolution of %d split points \n", count);
#endif
  ii = 0;
  p_pypt = *pypt;
  while(p_pypt)
  {
     /* get xyz coordinate corresponding to p_pypt->point */
     stat_OM = om$send(msg = message GRvg.EMptatpr(&msg_loc, p_mattyp, mat,
			             p_pypt->point, 2, pnt),
		       senderid = NULL_OBJID,
		       targetid = this_intobj->this_obj_node->this_obj.objid,
		       targetos = this_intobj->this_obj_node->this_obj.osnum);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, ret_end);

     /* Project the point on to chk_intobj */
     stat_OM = EMprojectpt(&msg_loc, p_mattyp, mat, 
			   &chk_intobj->this_xyzintobj, 1, pnt, lentol, 
			   &tmp_pypt, &dist[ii]);
     if(dist[ii] < min_dist)
     {
        min_dist = dist[ii];
     }
     p_pypt = p_pypt->next;
     ii++;
  }

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);

  min_pypt_count = ii = 0;
  p_pypt = *pypt;
  while(p_pypt)
  {
     if(fabs(dist[ii] - min_dist) <= cht)
     {
        min_dist_pypt[min_pypt_count] = p_pypt;
        min_dist_oth_pypt[min_pypt_count] = 
                           (struct EMSpypoint *) p_pypt->info; 
        min_pypt_count++;
     }
     p_pypt = p_pypt->next;  
     ii++;
  }

  if(dist) om$dealloc(ptr = dist);
  dist = NULL;
#ifdef DEBUG
 printf("New Function : No. of mindist pypts = %d\n", min_pypt_count);
#endif

  if(min_pypt_count > 1)
  {
    if(this_intobj->props & EMSintobj_exact_atstart)
    {
#ifdef DEBUG
 printf("New Function : Trying this exact at start  Code = ** S **\n");
#endif
      stat_OM = EMgetendpts_uv(&msg_loc,
                     &this_intobj->this_uvintobj,
                     this_intobj->reversed,
                     1, start_pt, stop_pt);
      EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

     /* Project the point on to chk_intobj */
      stat_OM = EMprojectpt(&msg_loc, p_mattyp, mat,
                           &this_intobj->this_uvintobj, 1, start_pt, uvtol,
                           &tmp_pypt, &ndist);

      span_value = tmp_pypt.span_inx + tmp_pypt.param;
     
      mindist = MAXDOUBLE; 
      for (ii=0; ii<min_pypt_count; ii++)
      {
        min_span_value = min_dist_pypt[ii]->span_inx + min_dist_pypt[ii]->param;
        if(((!this_intobj->reversed && (min_span_value > span_value)) ||
            (this_intobj->reversed && (min_span_value < span_value)))  && 
                (fabs(min_span_value - span_value) > uvtol)  &&
                (fabs(min_span_value - span_value) < mindist))
        {
          mindist = fabs(min_span_value - span_value);
          new_pypt = min_dist_pypt[ii];
        }
      }
    }
    else if(next_intobj->props & EMSintobj_exact_atstop)
    {
#ifdef DEBUG
 printf("New Function : Trying  other exact at end  Code = ** E **\n");
#endif
      stat_OM = EMgetendpts_uv(&msg_loc,
                     &next_intobj->this_uvintobj,
                     next_intobj->reversed,
                     1, start_pt, stop_pt);
      EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

     /* Project the point on to chk_intobj */
      stat_OM = EMprojectpt(&msg_loc, p_mattyp, mat,
                           &next_intobj->this_uvintobj, 1, stop_pt, lentol,
                           &tmp_pypt, &ndist);

      span_value = tmp_pypt.span_inx + tmp_pypt.param;
     
      mindist = MAXDOUBLE; 
      for (ii=0; ii<min_pypt_count; ii++)
      {
        min_span_value = min_dist_oth_pypt[ii]->span_inx + 
                                      min_dist_oth_pypt[ii]->param;
        if(((!next_intobj->reversed && (min_span_value < span_value)) ||
            (next_intobj->reversed && (min_span_value > span_value)))  && 
                (fabs(min_span_value - span_value) > uvtol) &&
                (fabs(min_span_value - span_value) < mindist))
        {
          mindist = fabs(min_span_value - span_value);
          new_pypt = min_dist_pypt[ii];
        }
      }
    }
    else
    {
      /* Heuristic check for the correct pypoint */
#ifdef DEBUG
 printf("New Function : Trying  heuristic check     Code = ** H **\n");
#endif
      this_value = (this_intobj->reversed ? MAXDOUBLE : -1 *MAXDOUBLE);
      oth_value = (next_intobj->reversed ? -1 * MAXDOUBLE : MAXDOUBLE);
      for (ii=0; ii<min_pypt_count; ii++)
      {
        this_span_value = min_dist_pypt[ii]->span_inx + 
                                            min_dist_pypt[ii]->param;
        if((!this_intobj->reversed && (this_span_value > this_value)) ||
           (this_intobj->reversed && (this_span_value < this_value)) )
        {
          this_value = this_span_value;
          max_this_pypt = min_dist_pypt[ii];
        }
        oth_span_value  = min_dist_oth_pypt[ii]->span_inx + 
                                      min_dist_oth_pypt[ii]->param;
        if((!next_intobj->reversed && (oth_span_value < oth_value)) ||
           (next_intobj->reversed && (oth_span_value > oth_value)) )
        {
          oth_value = oth_span_value;
          min_oth_pypt = min_dist_oth_pypt[ii];
        }
      } 

      /* Check whether the maximum pypt on this_intobj and the
         minimum pypt on the oth_intobj are the same. 
         How about using the ->info to check whether they match */
      
     /*
      if((max_this_pypt->point[0] == min_oth_pypt->point[0]) &&
           (max_this_pypt->point[1] == min_oth_pypt->point[1]))
      */
#ifdef DEBUG
 printf("New Function : Current level is %d\n", level);
#endif
      oth_pypt = (struct EMSpypoint *) max_this_pypt->info;
      if(min_oth_pypt == oth_pypt)
      {
        new_pypt = max_this_pypt;
      }
      else if(level < 1)
      {
        struct EMSintobj   *next_intobjs[2];
        struct EMSpypoint  *new_pypt1 = NULL, *new_pypt2 = NULL;
        IGRlong            num_inc_fwd, num_inc_bwd;
        struct EMregen_inc_info *inc_intobjs[2];


        /* Need to go to the next or the previous intobj for testing */
       
#ifdef DEBUG
 printf("New Function : Trying  next and next-next inters  Code = ** N **\n");
#endif
        next_intobjs[0] = next_intobj;
        next_intobjs[1] = next_intobj->fwd; 
        new_pypt1 = new_pypt2 = NULL;

      /* First get all the incident intobjs at the vertex being formed by
         the intobjs p_intobjs[START] and p_intobjs[STOP]
      */
        inc_intobjs[FWD] = NULL;
        inc_intobjs[BWD] = NULL;
        EFget_incident_intobjs(&msg_loc, next_intobjs, 
                               &num_inc_fwd, &num_inc_bwd,
                               &inc_intobjs[FWD], &inc_intobjs[BWD]);

        EFget_split_point(&msg_loc, next_intobjs, uvtol, lentol, env,
                               num_inc_fwd, num_inc_bwd, inc_intobjs,
                                      &new_pypt1, &new_pypt2, level+1);
       /* EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end); */

        if(EMSerror(msg_loc))
        {
#ifdef DEBUG
 printf("New Function : Trying  previous and this inters  Code = ** P **\n");
#endif
           next_intobjs[0] = this_intobj->bwd;
           next_intobjs[1] = this_intobj;
           new_pypt1 = new_pypt2 = NULL;

        /* First get all the incident intobjs at the vertex being formed by
          the intobjs p_intobjs[START] and p_intobjs[STOP]
        */
           inc_intobjs[FWD] = NULL;
           inc_intobjs[BWD] = NULL;
           EFget_incident_intobjs(&msg_loc, next_intobjs, 
                                &num_inc_fwd, &num_inc_bwd,
                                &inc_intobjs[FWD], &inc_intobjs[BWD]);

           EFget_split_point(&msg_loc, next_intobjs, uvtol, lentol, env,
                              num_inc_fwd, num_inc_bwd, inc_intobjs,
                              &new_pypt1, &new_pypt2, level+1);
           EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

          /* Find the old_pypt on this_intobj which is closest and 
             greater than  'new_pypt2' */
           span_value = new_pypt2->span_inx + new_pypt2->param;
           mindist = MAXDOUBLE;
           for (ii=0; ii<min_pypt_count; ii++)
           {
             min_span_value = min_dist_pypt[ii]->span_inx + 
                                      min_dist_pypt[ii]->param;
             if((!this_intobj->reversed && (min_span_value > span_value) &&
                     (fabs(min_span_value - span_value) < mindist)) ||
                (this_intobj->reversed && (min_span_value < span_value) &&
                     (fabs(min_span_value - span_value) < mindist)) )
             {
               mindist = fabs(min_span_value - span_value);
               new_pypt = min_dist_pypt[ii];
             }
           }
        }
        else
        {
          /* Find the old_pypt on next_intobj which is closest to
             and less than the new_pypt1 */
           span_value = new_pypt1->span_inx + new_pypt1->param;
           mindist = MAXDOUBLE;
           for (ii=0; ii<min_pypt_count; ii++)
           {
             min_span_value = min_dist_oth_pypt[ii]->span_inx + 
                                      min_dist_oth_pypt[ii]->param;
             if((!next_intobj->reversed && (min_span_value < span_value) &&
                     (fabs(min_span_value - span_value) < mindist)) ||
                (next_intobj->reversed && (min_span_value > span_value) &&
                     (fabs(min_span_value - span_value) < mindist)) )
             {
               mindist = fabs(min_span_value - span_value);
               new_pypt = min_dist_pypt[ii];
             }/* if((min... */
           } /* for (ii=0... */
        } /* else .. */
      }
      else     /* of if(recurse_level <= 1).. */
      {
        *msg = EMS_E_Fail;
#ifdef DEBUG
  printf("Unable to resolve between multiple split points Code = ** F ** \n");
#endif
        goto ret_end;
      }
    }
  }  /* if(min_pypt_count > 1)... */
  else
  {
     new_pypt = min_dist_pypt[0];
  }

ret_end:

  if(!new_pypt)
  {
       *msg = EMS_E_Fail;
#ifdef DEBUG
  printf("Unable to resolve between multiple split points  \n");
#endif
  }
  else
  {
    
    /* Get rid of the remaining unwanted pypoints */
    p_pypt = *pypt;
    while(p_pypt)
    {
     p_pypt_next = p_pypt->next;
     if(p_pypt != new_pypt)
     {
       p_pypt_other = (struct EMSpypoint *) p_pypt->info;
       EMpypoint_free(p_pypt, 1);
       EMpypoint_free(p_pypt_other, 1);
     }
     p_pypt = p_pypt_next;
    }
    new_pypt->next = NULL;
    *pypt = new_pypt;
    *pypt_oth = (struct EMSpypoint *) new_pypt->info;
    (*pypt_oth)->next = NULL;
  }
  if(dist) om$dealloc (ptr = dist);
  return;      

}

/****************************************************************************/
static void EFchk_pt_on_seam(surf, tol, uv_pt, on_seam, u_closed)
/****************************************************************************/
struct IGRbsp_surface		*surf;
IGRdouble			tol, *uv_pt;
IGRboolean			*on_seam, *u_closed;
{
	*on_seam = FALSE;
	*u_closed = FALSE;
	if(surf->u_phy_closed)
	{
	  *u_closed = TRUE;  
	  if(uv_pt[0] < tol ||
	     fabs(1.0 - uv_pt[0]) < tol) *on_seam = TRUE;
	}
	else
	  if(uv_pt[1] < tol ||
	     fabs(1.0 - uv_pt[1]) < tol) *on_seam = TRUE;

	return;
}
/****************************************************************************/
static void EFvalidate_pt_on_seam(msg, surf, sf_grid, vertex, uv_pt, env, tol)
/****************************************************************************/
IGRlong			*msg;
struct IGRbsp_surface	*surf;
struct GRid		*sf_grid;
struct EMregen_inc_info	*vertex;
IGRdouble		*uv_pt, tol;
struct GRmd_env		*env;
{
  IGRlong	stat_OM, msg_loc;
  IGRdouble start_pt[2], stop_pt[2], *end_pt;
  IGRboolean on_seam, u_closed;
  struct IGRbsp_surface	*loc_surf=NULL;
  struct EMSdataselect	loc_sf_data;

  IGRlong EMgetendpts_uv(), EMsm_get_surface_geom();

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  if(!surf)
  {
     loc_surf = NULL;
     loc_sf_data.datatype = EMSdata_object;
     loc_sf_data.data.object = sf_grid;
     stat_OM = EMsm_get_surface_geom(&msg_loc, &loc_sf_data, &env->md_env,
				     &loc_surf);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);
     surf = loc_surf;
  }
     if(surf->u_phy_closed || surf->v_phy_closed)
     {
	
        stat_OM = EMgetendpts_uv(&msg_loc, 
		     &vertex->p_intobj->this_uvintobj,
		     vertex->p_intobj->reversed,
		     1, start_pt, stop_pt);

        end_pt = (vertex->location == BEGIN ? start_pt : stop_pt);
	EFchk_pt_on_seam(surf, tol, uv_pt, &on_seam, &u_closed);
	if(on_seam)
	  if(u_closed)
	     if(fabs(end_pt[0] - uv_pt[0]) > 0.5)
		uv_pt[0] = (uv_pt[0] < 0.5 ? 1.0 : 0.0);
	  else     /* closed in v direction */
	     if(fabs(end_pt[1] - uv_pt[1]) > 0.5)
		uv_pt[1] = (uv_pt[1] < 0.5 ? 1.0 : 0.0);
     }
ret_end:
     if(loc_surf) free(loc_surf);
     return;
}

/****************************************************************************/
static void EFvalidate_pt_on_xyzdegen(msg, surf, sf_grid, vertex, uv_pt, env)
/****************************************************************************/
IGRlong			*msg;
struct IGRbsp_surface	*surf;
struct GRid		*sf_grid;
struct EMregen_inc_info	*vertex;
IGRdouble		*uv_pt;
struct GRmd_env		*env;
{
  *msg = EMS_S_Success;

  if (vertex->p_intobj->props & EMSintobj_xyzdegenerate)
  {
    IGRlong stat_OM=OM_S_SUCCESS, msg_loc=EMS_S_Success;
    IGRdouble start_pt[2], stop_pt[2], *end_pt=NULL;
    struct IGRbsp_surface *loc_surf=NULL;
    struct EMSdataselect  loc_sf_data;
  
    IGRlong EMgetendpts_uv(), EMsm_get_surface_geom();

    if(!surf)
    {
      loc_surf = NULL;
      loc_sf_data.datatype = EMSdata_object;
      loc_sf_data.data.object = sf_grid;
      stat_OM = EMsm_get_surface_geom(&msg_loc, &loc_sf_data, &env->md_env,
                                      &loc_surf);
      EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

      surf = loc_surf;
    }

    stat_OM = EMgetendpts_uv(&msg_loc, &vertex->p_intobj->this_uvintobj,
                             vertex->p_intobj->reversed, 1, start_pt, 
                             stop_pt);
    EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

    end_pt = (vertex->location == BEGIN ? start_pt : stop_pt);

    uv_pt[0] = end_pt[0];
    uv_pt[1] = end_pt[1];

    ret_end :
      if (loc_surf) free(loc_surf);
  }

  return;
}

/****************************************************************************/
static IGRboolean EFmodify_spl_intobj(msg, p_intobj, location, exact_uv,
				      exact_pt, uvtol, env, refine)
/****************************************************************************/
IGRlong			*msg;      /* O */
struct EMSintobj	*p_intobj; /* I/O */
IGRint			location;  /* I */
IGRdouble		exact_uv[2], exact_pt[3], uvtol;  /* I */
struct GRmd_env		*env;      /* I */
IGRboolean		*refine;   /* O */
{
  IGRlong		msg_loc;
  IGRboolean		mapped, need_mapping, stat_func, const_u, rev, iso_uorv;
  IGRushort		other_end_exact;
  IGRdouble		start_uv[2], stop_uv[2],
			set_u, set_v, *end_pt;
  struct EMSdataselect  uv_datasel, xyz_datasel;
  struct EMSinters	*tmp_inters;
  struct EMSintobj	*tmp_intobj;

  extern struct EMSintobj	*EFmkint_from_isocurve();
  extern IGRboolean		EMis_same_dataselect();
  extern void			EMinters_free();

	*refine = need_mapping = mapped = FALSE;

	if(p_intobj->props & EMSintobj_xyzdegenerate) goto ret_end;

	tmp_intobj = p_intobj->other_intobj_node;
	if(tmp_intobj)
	   if(!(tmp_intobj->props & EMSintobj_special_tangent))
	   {
		*msg = EMS_E_Fail;
		goto ret_end;
	   }

	OM_BLOCK_MOVE(&p_intobj->this_xyzintobj, &xyz_datasel,
		      sizeof(struct EMSdataselect));
	OM_BLOCK_MOVE(&p_intobj->this_uvintobj, &uv_datasel,
		      sizeof(struct EMSdataselect));

	end_pt = exact_pt; /* to supress compiler warning */

	/* Get the UV end-points of the incoming intobj */

	stat_func = EFchk_for_iso(&p_intobj->this_uvintobj, &uvtol,
				  p_intobj->reversed, start_uv, stop_uv, 
				  &const_u);

	if(!stat_func)  /* not an ISO intobj */
	{
	   *refine = TRUE;
	   if(uv_datasel.datatype != EMSdata_poly2d) *msg = EMS_E_Fail;
	   goto ret_end;
	}

	set_u = start_uv[0];
	set_v = start_uv[1];
	end_pt = (location == BEGIN ? start_uv : stop_uv);
	if(const_u)
	{
	  if(fabs(set_u - exact_uv[0]) > uvtol) need_mapping = TRUE;
	  if(!need_mapping)
	     if(fabs(end_pt[1] - exact_uv[1]) > uvtol)
	     {
	        *refine = TRUE;
		/* since we will refining the iso-intobj itself using the
		   exact_uv[] make sure the constant U value is not changed
		   during refining
		*/
		exact_uv[0] = set_u;
	     }
	}
	else
	{
	  if(fabs(set_v - exact_uv[1]) > uvtol) need_mapping = TRUE;
	  if(!need_mapping)
	     if(fabs(end_pt[0] - exact_uv[0]) > uvtol)
	     {
		*refine = TRUE;
		/* since we will refining the iso-intobj itself using the
		   exact_uv[] make sure the constant V value is not changed
		   during refining
		*/
		exact_uv[1] = set_v;
	     }
	}

	if(need_mapping)
	{
	/* Need to shift the ISO intobj */

	  /* If the other end of the incoming iso-intobj is exact we
	     cannot shift the ISO intobj. Hence error out
	  */
	  other_end_exact = 0x0;
	  other_end_exact = (location == BEGIN ?
			     p_intobj->props & EMSintobj_exact_atstop :
			     p_intobj->props & EMSintobj_exact_atstart);

	  if(other_end_exact)
	  {
	    *msg = EMS_E_Fail;
	    goto ret_end;
	  }

#ifdef DEBUG
printf("  Shifting Special ISO-intobj. ");
if(const_u) printf("%lg > %lg \n", fabs(set_u - exact_uv[0]), uvtol);
else printf("%lg > %lg \n", fabs(set_v - exact_uv[1]), uvtol);
#endif
	  rev = FALSE;
	  if(const_u)
	  {
		iso_uorv = CONST_U;
		if(start_uv[1] > stop_uv[1])
		   rev = TRUE;
	  }
	  else
	  {
		iso_uorv = CONST_V;
		if(start_uv[0] > stop_uv[0])
		   rev = TRUE;
	  }
	  if(p_intobj->reversed)
	     rev = (rev ? FALSE : TRUE);

	  tmp_inters = NULL;
	  tmp_intobj = EFmkint_from_isocurve(&msg_loc,
					     p_intobj->this_obj_node->this_obj,
					     exact_uv, iso_uorv, rev,TRUE,
					     &env->md_env, &tmp_inters);
	  EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	/* Exchange the data of tmp_intobj with that of iso-intobj (p_intobj)
	   and free tmp_inters (which internally will free tmp_intobj).
	*/
	  OM_BLOCK_MOVE(&tmp_intobj->this_uvintobj, &p_intobj->this_uvintobj,
			sizeof(struct EMSdataselect));
	  OM_BLOCK_MOVE(&tmp_intobj->this_xyzintobj, &p_intobj->this_xyzintobj,
			sizeof(struct EMSdataselect));
	  OM_BLOCK_MOVE(&uv_datasel, &tmp_intobj->this_uvintobj,
			sizeof(struct EMSdataselect));
	  if(p_intobj->other_intobj_node && 
	     EMis_same_dataselect(&xyz_datasel,
				  &p_intobj->other_intobj_node->this_xyzintobj)
	    )
	  {
		tmp_intobj->this_xyzintobj.datatype = EMSdata_null;
		tmp_intobj->this_xyzintobj.data.curve = NULL;
	  }
	  else
	        OM_BLOCK_MOVE(&xyz_datasel, &tmp_intobj->this_xyzintobj,
			      sizeof(struct EMSdataselect));
          EMinters_free(tmp_inters, OM_K_MAXINT);

	  *refine = TRUE;
	  mapped = TRUE;
	}
ret_end:
	return(mapped);
}

end implementation EMSsubbs;

