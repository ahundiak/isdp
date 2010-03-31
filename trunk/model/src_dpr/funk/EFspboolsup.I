/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "OMmacros.h"
#include "EMSdef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsimpdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMStpmacros.h"
#include "EMSutlmacros.h"

from EMSboundary import EMget_edges, EMintcopy;
from EMSloopset  import EMsplityourself,EMmake_natural_loopset,EMpt_location;
from EMSsubbs    import EMpartolbasis;

extern OMuword   OPP_EMSloopset_class_id;
extern OMuword   OM_Gw_current_OS;

extern void EMdelintobj_selective();

%safe
static void      EFcheck_inters_trace_groups();
static void      EFget_intobj_trace_group();
%endsafe


/*****************************************************************************/
/*             SUPPORT FUNCTIONS FOR SELECTIVE BOOLEAN CODE                  */
/*****************************************************************************/

/*
 ABSTRACT
This function takes in two intersection lists, their trace information, and 
EITHER an array of points on surfaces appearing in the intersection lists OR
a bitmask that an intobj must have. If sort pts are given, then the points 
define the regions on the surfaces that are to be kept and based on these 
points, all trace groups that are not needed are deleted. We keep the trace
groups which immediately enclose the needed region, and all other trace groups 
that are topologically nested within those trace groups. However, if the 
bitmask is given, it means we keep all trace groups that have this bitmask and 
all other trace groups topologically nested within those trace groups.

"sort" pts are the pts used to decide which part of a surface is retained.
"bad" pts are the ones which are placed in areas of the surface that CANNOT be
part of the result for the given boolean, or pts placed on those surfaces that
do not have any intersections. Such pts are returned to the command object to 
be highlighted.

 HISTORY:

 07/24/92 NP	Creation.
 09/25/92 NP	Use the UV values in the incoming sort point struct, instead of 
		evaluating them from the XYZ values of the sort points. This is
		because the code for trim/extend surfaces to intesection, does
		NOT have XYZ, but DOES have UV values of the sort points.
 11/11/92 NP    Deleted the support functions for the old selective boolean
                code from this file. Created a new file called EFspboolold.I
                for the deleted code, which will hang around till finally
                deemed deletable.
 05/18/93 NP    Memory leak. "cp_info.objid_array" wasn't being deallocated.

 07/28/93 NP    Updated so that function can now be driven by sort points OR
                by intobj bit masks. See description for more information.
                Removed restriction that number of trace groups on both operands
                have to be same. Also added flexibility by allowing only ONE
                set of operands to be passed in (i.e. env2, inters2, tracedata2
                etc. may now be NULL). This is needed for rib features.

 09/09/93 NP    Changed struct EMSsortpt_info to struct EMparms for the intput
                parameters "sortpts" and  "bad_pts". Merged parameters env1 and
                env2 into env. Also, the surfaces on which the sortpts exist
                are assumed to have the same env as the inters list, which makes
                sense, since these surfaces ARE from that list. Removed 
                parameter "num_inters" which was serving no useful purpose.

 12/08/93 NP    Added option "EMImpBnd_DelInvalidLoops" to EMsplityourself
                method. Needed for ribs. Hopefully useful for everybody, since 
                nobody can live with invalid loops.

 MODIFICATIONS TO BE DONE:

        THINGS STILL TO BE HANDLED:

    1.  The case where one of the Operands B has all its intersection deleted.
        Such an object would wrongly be a part of the dpr state, unless 
        explicitly removed from the boolean operation.

        Currently it is assumed that the calling fn. will take care of this.

    2.  Create temporary arrays to hold default amounts of information, 
        instead of always allocating memory for every iteration of the "while"
        loop. Only allocate if needed.

 RETURN CODES

 EMS_E_AllIntersectionsDeleted
	If selection points are placed such that no intersections will be
	kept for the boolean operation (i.e. due to all selection pts being
        invalid, all intersections [are/would have to be] deleted)
 EMS_E_SurfaceError
	If there is an error getting the basis tolerance of a surface or
        if surface does not have a natural boundary.
 EMS_E_LoopsetError
	If there are errors in creating, copying, getting edges from, 
	or splitting a loopset
 EMS_E_LoopError
	If there are errors in getting edges from a loop or creating loops
 EMS_E_PtLocError
	If there is a problem doing a pt location on a loopset
 EMS_E_OMerror
	Error in OM call (getting objects on channel etc.)
 EMS_E_NoDynamicMemory
	If there is a problem allocating memory
 EMS_E_Fail
	Other errors.

 PARAMETERS:

 num_bad_pts  (Output)       Return message code.

 const_list   (Input)        Construct list pointer.

 env          (Input)        Env info for the inters lists.

 tracedata1   (Input)        Trace information on first operand.

 tracedata2   (Input)        Trace information on second operand.(may be NULL)

 options      (Input)        NULL, as of right now.

  The NEXT FOUR arguments are mutually exclusive with the last two that deal
  with intobj properties "check_present" and "check_absent". If the last two
  arguments are non-null, then the next four SHOULD be NULL.
  

 sort_pts     (Input)        The points that will determine which trace groups
                             will be kept (based on the intobjs identified as
                             "to be kept"on the surface that the point lies on).

                             NOTE: The "normal" field of the EMparms struct 
                             ----  need not be filled in. We look only for 
                                   the surface id in "leaf_id" and the "u" & "v"
                                   values. The surface env is assumed to be same
                                   as the "env" parameter above.

                             (may be NULL)

 num_sort_pts (Input)        Number of input sort points. (may be NULL)

 bad_pts      (Output)       Those input sort points that were incorrect (or
                             those input sort points that would have kept the 
                             wrong intobjs on the surface).

                             WARNING: The caller has to deallocate the memory
                             -------  for the bad points.

                             (may be NULL)

 num_bad_pts  (Output)       Number of incorrect input sort points.
                             (may be NULL)

                           
 check_present_bits (Input)  These two bit masks are to identify intobjs, which
 check_absent_bits  (Input)  will aid in deciding which trace groups to keep.
                             After creating loops on surfaces from trace data,
                             we check to see if any edge of a P-Loop has been 
                             created from an intobj that HAS the "check_present"
                             bits and DOES NOT have the "check_absent" bits. 
                             If so, then the trace group to which that intobj 
                             belongs needs to be kept. Also, all trace groups 
                             that have intobjs from the nested C-loops are to be
                             kept.

                             (may be NULL)

                             These two arguments are MUTUALLY EXCLUSIVE from the
                             previous four relating to "sort" pts and "bad" pts.

*/


#argsused
IGRlong EFspbool_modify_trace_groups(
	EFmsg, 
        const_list,
	env,
	inters1, 
	inters2, 
	tracedata1,
	tracedata2,
	options,
	sort_pts,
	num_sort_pts,
        bad_pts,
        num_bad_pts,
        check_present,
        check_absent)
IGRlong			*EFmsg;
struct GRvg_construct	*const_list;
struct EMSinters	**inters1, **inters2;
struct GRmd_env     	*env;
struct EMSsftracedata	*tracedata1, *tracedata2;
IGRushort		options;
struct EMparms	        *sort_pts, **bad_pts;
IGRint			*num_sort_pts, *num_bad_pts;
IGRlong                 check_present, check_absent; 
{
extern void		EMsfintedpar_free(), EMinters_data_free();
extern void		EMinters_free();

IGRlong			msg, sts, i, j, k, l, m;
struct GRid		check_surface,this_surface,*orig_intobjs,*cp_intobjs;
IGRboolean		check_this_srf, *trace_group_keep1, *trace_group_keep2; 
IGRboolean		error_condition=FALSE;
IGRint			group_num, num_trace_groups1=0,num_trace_groups2=0;
IGRint			count=0, num_intobjs;
IGRboolean		*trace_group_keep, *other_trace_group_keep;
struct EMSinters	*inters, *cp_inters;
struct EMSintobj	*intobj;
struct EMSsftracedata	*tracedata, *other_tracedata;
OM_S_CHANSELECT		to_edges, to_loops, to_loopset;
OM_S_OBJECT_LINKAGE	*edges, *loop_objects, loopset_obj;
struct GRid             cp_loopset;
struct EMcp_info	cp_info; /*NEEDED??*/
IGRint			loc_num_bad_pts;

/* Variables needed to copy the surface loopset and maintain correspondence 
 * between the edges of the two loopsets. Also, variables needed for 
 * duplicating the inters node.
 */
struct GRid		*orig_edges, *cp_edges;
IGRint			num_orig_edges=0, num_cp_edges=0;
IGRint			orig_ed_array_size=0, cp_ed_array_size=0;
struct EMSsfintedpar	*sfintedpar;
IGRboolean		edge_found=FALSE;
struct EMSinters	*inters_next=NULL;

/* Variables needed for tracing intersections on a surface */
IGRint 			num_grps=0, *num_subgrps_grp, **num_elems_subgrp;
struct EMSintobj 	***elems;
IGRboolean 		**subgrp_rev, ***elem_rev, *grp_closed;
IGRboolean 		**subgrp_closed, sfinttrace_alloced=FALSE;
IGRdouble		xyztracetol, chttol;
 
/* Variables needed to create surface loops out of the intersections */
GRobjid 		**loop_sf=NULL, **endedges=NULL;
struct EMSsfintedpar 	***intparms=NULL;
IGRdouble 		**sfpartolb;
IGRboolean		sfintloops_alloced=FALSE;

/* Variables needed for splitting the loopset */
IGRint			num_trim_loops=0, max_loops=0;
GRobjid			*loop_ids;
struct EMSsfintedpar	**trim_info=NULL;
struct EMSpartolbasis	partolbasis;

/* Variables needed for identifying loops to keep of split loopset */
struct EMSptloc_info 	pt_loc;
IGRdouble		sort_pt_uv[2];
IGRint			num_sort_loops=0;
GRobjid			*sort_loops;
IGRboolean		bad_location=FALSE, redundant_pt=FALSE;

/* Variables needed to identify former intobjs present in resulting loops */
struct GRid		*edges_in_sort_loops;
IGRint			ed_array_size=0, num_edges_in_sort_loops=0;
IGRint			grp_num = -MAXINT;
struct EMSintobj	*intobj_loc=NULL ;

/* Variables needed for deleting unwanted trace groups */
struct EMSintobj	*intobj_del=NULL;

/* Variables needed for cleaning up the inters list */
struct EMSinters	**inters_ptr=NULL;

/*general variables */
IGRboolean              found_intobj, sort_point_mode, single_operand_mode;
IGRboolean              loop_stored;
OMuint                  num_edge_objects, num_loop_objects, lp_count, ed_count;

*EFmsg = EMS_S_Success;
msg    = EMS_S_Success;
sts    = OM_S_SUCCESS;

/* VALIDATION OF INPUT */
if (!inters1 || !tracedata1 || !env )
    EMerr_hndlr (TRUE, *EFmsg, EMS_E_InvalidArg, ret_end);


/* set up all the chan selects */
 ems$make_chanselect( 
             chan_label    = EMSloopset_to_loops,
             chan_selector = &to_loops);

 ems$make_chanselect( 
             chan_label    = EMSsubbs_to_loopset,
             chan_selector = &to_loopset);
   
 ems$make_chanselect( 
             chan_label    = EMSbd_owner_to_comps,
             chan_selector = &to_edges);


/* check if this function is driven by sort pts or by the intobj check bits */

if (sort_pts)
  sort_point_mode = TRUE;
else if (check_present|check_absent)
  sort_point_mode = FALSE;
else
  EMerr_hndlr (TRUE, *EFmsg, EMS_E_InvalidArg, ret_end);

single_operand_mode = (!inters2 || !tracedata2)? TRUE : FALSE;
   
  
if (sort_point_mode)
{
  loc_num_bad_pts = 0; /* assume all points are GOOD at start.*/

  if (num_bad_pts)
    *num_bad_pts = 0; 

  /* No sort pts ==> keep all trace groups => regular boolean */
  if (! *num_sort_pts)
    goto ret_end;
}

/*initialize*/
orig_edges = NULL;
cp_edges   = NULL;


/* Set up arrays to indicate if a trace group is to be kept or not.  Initially
 * mark NONE of the groups as to be kept. Make sure that single operand mode is
 * handled.
 */
 num_trace_groups1 = tracedata1->num_grps;
 num_trace_groups2 = single_operand_mode? 0 : tracedata2->num_grps;
 trace_group_keep1 = (IGRboolean *) alloca ( num_trace_groups1 * 
                                                    sizeof (IGRboolean) );
 trace_group_keep2 = single_operand_mode? NULL : ((IGRboolean *) alloca 
                        ( num_trace_groups2 * sizeof (IGRboolean) ));

/* Mark ALL trace groups as NOT to be kept. As this algorithm progresses, we
 * will mark those trace groups to be kept, as are needed for the
 * selective boolean
 */
for (i=0; i<num_trace_groups1; i++) 
   trace_group_keep1[i] = FALSE;  
  
if (!single_operand_mode)
{ for (i=0; i<num_trace_groups2; i++) 
   trace_group_keep2[i] = FALSE;  
}

error_condition = FALSE;

for (i=0; i<2; i++) /* check both inters lists (i==0? inters1 : inters2)*/
{  
  inters = (i==0? *inters1 : (single_operand_mode? NULL: *inters2)); 
  tracedata = (i==0? tracedata1 : (single_operand_mode? NULL:tracedata2)); 
  other_tracedata = (i==0?(single_operand_mode? NULL:tracedata2) : tracedata1); 
  trace_group_keep = (i==0? trace_group_keep1 : 
                            (single_operand_mode? NULL :trace_group_keep2));
  other_trace_group_keep = (i==0? (single_operand_mode? NULL :trace_group_keep2)
                                : trace_group_keep1);

  /* If in single operand mode, code in this while loop will not be executed for
   * i==1. Therefore, checks for validity of tracedata, trace_group_keep etc 
   * (i.e.checks to see if they are NON-NULL) are minimal inside the while loop,
   * except for "other_tracedata" and "other_trace_group_keep".
   */
  while (inters && inters->num_cvs)
  {
    this_surface.objid 	= inters->this_obj.objid;
    this_surface.osnum 	= inters->this_obj.osnum;
    sfinttrace_alloced  	= FALSE;
    sfintloops_alloced  	= FALSE;
    
    /* make NULL only those pointers that I will allocate memory for */
    cp_loopset.objid		= NULL_OBJID;
    sort_loops           	= NULL;
    cp_inters			= NULL;
    orig_edges          	= NULL;
    cp_edges            	= NULL;
    orig_intobjs		= NULL;
    cp_intobjs			= NULL;
    loop_ids			= NULL; 
    trim_info			= NULL;
    edges_in_sort_loops	        = NULL; /* mem alloced by EMget_edges */
    loop_objects                = NULL;

    /* Important. Needed if loopset of this surface is to be copied */
    cp_info.num_entries         = 0;
    cp_info.array_size          = 0;
    cp_info.objid_array         = NULL;

    /* other misc. initializations */
    num_sort_loops              = 0;


    /* trivial check for sort point mode only */
    if (sort_point_mode)
    {
      /* check only surfaces that have points placed on them */
      check_this_srf=FALSE; /* assume */
      for (j=0; j<*num_sort_pts; j++)   
      { 
        check_surface.objid = sort_pts[j].leaf_id.objid;
        check_surface.osnum = sort_pts[j].leaf_id.osnum;
         
        if ( (check_surface.objid == this_surface.objid) &&
             (check_surface.osnum == this_surface.osnum)     )
        {  check_this_srf = TRUE;
           break;
        }
      }/*for*/
      
      if (!check_this_srf)
         goto while_end; /* move on to next surface */
    }/*if*/
   else
    {
       /* trivially mark those trace groups with intobjs having the correct 
        * bitmask. This is for the non-sort_point_mode only.
        */
       intobj_loc = inters->cvs;
       while (intobj_loc)
       {
          if ((check_present? (intobj_loc->props&check_present):TRUE) &&
              (check_absent ?!(intobj_loc->props&check_absent) :TRUE) )
          {
             EFget_intobj_trace_group (&msg, intobj_loc,tracedata,&group_num);
             EMerr_hndlr (!(msg&1), *EFmsg, EMS_E_Fail, while_end);
   
             trace_group_keep[group_num] = TRUE;

             if (!single_operand_mode)
             { EFget_intobj_trace_group (&msg, intobj_loc->other_intobj_node,
                                                other_tracedata, &group_num);
               EMerr_hndlr (!(msg&1), *EFmsg, EMS_E_Fail, while_end);
   
               other_trace_group_keep[group_num] = TRUE;
             }
          } 

          intobj_loc = intobj_loc->next;
       } 
    }
   
    /* If ALL intobjs on this surface belong to trace groups ALREADY marked 
     * to be kept, do not check this surface.
     */
    check_this_srf = FALSE; /* assume */
    EFcheck_inters_trace_groups (&msg, inters, tracedata, trace_group_keep,
                                 &check_this_srf);
    EMerr_hndlr ( !(msg&1), *EFmsg, EMS_E_Fail, while_end);

    if (!check_this_srf)
      goto while_end; /* move on to next surface */

    /* At this stage we know that the current "inters" node has trace groups on
     * it that are not yet classified as "to keep".  This means we MUST check 
     * this surface. 
     */

    /* STEP 3a: Create a copy of the surface loopset in the same OS*/
    /***************************************************************/

    sts = om$get_channel_objects (objid = inters->this_obj.objid,
				  osnum = inters->this_obj.osnum,
				  p_chanselect = &to_loopset,
				  list = &loopset_obj,
				  size = 1,
				  count = (OMuint *)&count);
    EMerr_hndlr (!(sts&1), *EFmsg, EMS_E_OMerror, while_end);

    cp_loopset.osnum = inters->this_obj.osnum; /* SAME os as surface */

    if (!count)/*create a natural loopset if surface doesnt have a loopset */
    {  
      /* We have an inters list on a surface that has NO boundary? Something
       * smells bad here. Error out...
       */

      EMerr_hndlr (TRUE, *EFmsg, EMS_E_SurfaceError, while_end);

      /*****************
      sts = om$send (msg = message EMSsurface.EMmk_nat_bdry (&msg, 
                  &(env->md_env), NULL),
                  senderid = NULL_OBJID,
                  targetid = inters->this_obj.objid,
                  targetos = inters->this_obj.osnum);
      EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_SurfaceError, while_end);

      sts = om$get_channel_objects (objid = inters->this_obj.objid,
				  osnum = inters->this_obj.osnum,
				  p_chanselect = &to_loopset,
				  list = &loopset_obj,
				  size = 1,
				  count = (OMuint *)&count);
      EMerr_hndlr (!(sts&1), *EFmsg, EMS_E_OMerror, while_end);
      EMerr_hndlr (!count, *EFmsg, EMS_E_SurfaceError, while_end);
      *************/

    }

      /* initializations to "cp_info" done at start of "while" loop */
      sts = om$send (msg=message EMSboundary.EMintcopy (&msg, NULL, 
                             inters->this_obj.osnum, inters->this_obj.osnum,
                             NULL, &(cp_loopset.objid), &cp_info),
		   senderid = NULL_OBJID,
		   targetid = loopset_obj.S_objid,
		   targetos = loopset_obj.osnum);
      EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_LoopsetError, while_end);

    /* STEP 3b: Create a correspondence of edges in the two loopsets */
    /*****************************************************************/
  
    /* get all edges of the original loopset */ 
    orig_ed_array_size=0;
    num_orig_edges=0;
    sts = om$send (msg = message EMSboundary.EMget_edges ( &msg, MAXINT, 
                                 EMS_OPT_ALL,
				 &orig_edges, &orig_ed_array_size, 
				 &num_orig_edges),
			 senderid = NULL_OBJID,
		   	 targetid = loopset_obj.S_objid,
		   	 targetos = loopset_obj.osnum);
    EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_LoopsetError, while_end);

    /* get all edges of the copied loopset */ 
    cp_ed_array_size=0;
    num_cp_edges=0;
    sts = om$send (msg = message EMSboundary.EMget_edges ( &msg, MAXINT, 
                                EMS_OPT_ALL,
				&cp_edges, &cp_ed_array_size, 
				&num_cp_edges),
			senderid = NULL_OBJID,
		   	targetid = cp_loopset.objid,
		   	targetos = cp_loopset.osnum); 
    EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_LoopsetError, while_end);

    EMerr_hndlr (num_orig_edges != num_cp_edges, 
                                *EFmsg, EMS_E_LoopsetError, while_end);


    /* STEP 4: Create a copy of the inters node for this surface */
    /*************************************************************/

    /* A copy of the inters list is made on the same surface (i.e. surface is
     * is not copied). To make sure that only that inters node pertaining to
     * THIS surface is copied , set the "next" pointer to NULL
     * temporarily. Also, since the copied inters node needs to have the
     * sfintedpar info pointing to the edges in the copied loopset (and not
     * to the edges in the original surface loopset), update that information
     * after making a copy of the inters node.
     */ 

    inters_next     = inters->next; /* save */
    inters->next    = NULL;
     
    sts =  EMdupinters(&msg, &inters, &cp_inters, TRUE, FALSE, &this_surface,
              NULL, FALSE, env, const_list, NULL, NULL, 0, NULL, NULL, 0);

    EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_Fail, while_end);

    inters->next    = inters_next; /* reset */
    cp_inters->next = NULL; /* make sure, just in case */


    /* Update the sfintedpar edgeids in the copied inters node to reflect the
     * edge ids in the copied loopset.
     */

     intobj_loc = cp_inters->cvs;
     for (j=0; j<cp_inters->num_cvs; j++)
     {  /* for both edges in sfintedpars of every intobj, get the index of 
         * edge ids in the original edge array and use it to get the edge id
         * of the copy edge. Replace the orig. edge id with the copy edge id.
         */
        for (k=0; k<2; k++)
        {
          sfintedpar = (k==0 ? (struct EMSsfintedpar *)(intobj_loc->more_info):
            ((intobj_loc->more_info) ? 
             ((struct EMSsfintedpar *)(intobj_loc->more_info))->next : NULL));
          
          if (sfintedpar && (sfintedpar->edgeid != NULL_OBJID)) 
          { edge_found = FALSE;
            for (l=0; l<num_orig_edges; l++)
            {  if (sfintedpar->edgeid == orig_edges[l].objid)
               {  /* replace edgeid in intobj with the id of the edge's copy */
                  sfintedpar->edgeid = cp_edges[l].objid;
                  edge_found = TRUE;
                  break;
               }
            }
            EMerr_hndlr (!edge_found, *EFmsg, EMS_E_Fail, while_end);
          }
        }

        intobj_loc = intobj_loc->next;
     }


    /* STEP 5: Create a correspondence array of edges between the inters lists*/
    /**************************************************************************/

    /* make this more efficient later by changing om$malloc to alloca
     * if necessary.
     */
    orig_intobjs = (struct GRid *) om$malloc ( size = (inters->num_cvs) *  
                                                       sizeof (struct GRid)) ;
    EMerr_hndlr (!orig_intobjs, *EFmsg, EMS_E_NoDynamicMemory, while_end);
    cp_intobjs   = (struct GRid *) om$malloc ( size = (inters->num_cvs) *  
                                                       sizeof (struct GRid)) ;
    EMerr_hndlr (!cp_intobjs, *EFmsg, EMS_E_NoDynamicMemory, while_end);

    /* create original inters' intobjs edges array */
    intobj = inters->cvs; /* "pts" do not figure in sf-sf intersections */
    num_intobjs = inters->num_cvs;
    for (j=0; j<num_intobjs; j++)
    {  orig_intobjs[j] = *(intobj->this_uvintobj.data.object);
       intobj = intobj->next;
    }
    /* create copy inters' intobjs edges array */
    intobj = cp_inters->cvs; /* "pts" do not figure in sf-sf intersections */
    num_intobjs = cp_inters->num_cvs; /* same number as above */
    for (j=0; j<num_intobjs; j++)
    {  cp_intobjs[j] = *(intobj->this_uvintobj.data.object);
       intobj = intobj->next;
    }

    /* STEP 6: Run a trace on the copied intobjs in the copied loopset */
    /*******************************************************************/

    /* Get the tolerance for tracing */
    /* DO WE REALLY NEED ALTXYZTOL????*/

    BSEXTRACTPAR (&msg, BSTOLLENVEC, xyztracetol);
    BSEXTRACTPAR (&msg, BSTOLCHRDHT, chttol);

    /* j==0 is regular trace.
     * j==1 is re-trace with larger tolerance.
     */
    for (j=0; j<2; j++) /* Retry second time on failure first time */
    {  if (j==1)
         xyztracetol = chttol * 2.0; /* larger tolerance for double check */ 

       ems$sfinttrace (
                  msg              = &msg,
                  matrixtype       = &(env->md_env.matrix_type),
                  matrix           = env->md_env.matrix,
                  inters           = cp_inters,
                  altxyztol        = &xyztracetol,
                  num_grps         = &num_grps,
                  num_subgrps_grp  = &num_subgrps_grp,
                  num_elems_subgrp = &num_elems_subgrp,
                  elems            = &elems,
                  subgrp_rev       = &subgrp_rev,
                  elem_rev         = &elem_rev,
                  grp_closed       = &grp_closed,
                  subgrp_closed    = &subgrp_closed);   

       sfinttrace_alloced = TRUE;

       if (EMSerror (msg))
       {  if (j==0) /** failure on first try */
          {  /** Free the trace data and retry**/
             ems$sfinttrace_free(
                  msg              = &msg,
                  num_grps         = num_grps,
                  num_subgrps_grp  = num_subgrps_grp,
                  num_elems_subgrp = num_elems_subgrp,
                  elems            = (IGRchar ***)elems,
                  subgrp_rev       = subgrp_rev,
                  elem_rev         = elem_rev,
                  grp_closed       = grp_closed,
                  subgrp_closed    = subgrp_closed);  

             sfinttrace_alloced = FALSE;
          }
          else /* failure on second try, error out */
             EMerr_hndlr (EMSerror (msg), *EFmsg, msg, while_end);
       }
       else
         break; /* => trace is successful */
    }

    /* STEP 7: Make open/closed loops out of the surface intersections */
    /*******************************************************************/

    /* THIS FUNCTION MAY NEED TO HAVE A SURFACE ASSOCIATED WITH THE COPIED
       LOOPSET, SINCE IT RETURNS A "LOOP_SF" ARRAY.
     */
     
    /** EMsfintloops returns an IGRint..problem with SUN etc...??? */ 
    sts = EMsfintloops (&msg, &(env->md_env.matrix_type), env->md_env.matrix, 
                        cp_inters->cvs->this_uvintobj.data.object->osnum, 
                        NULL, num_grps, num_subgrps_grp, num_elems_subgrp,
                        elems, subgrp_rev, elem_rev, grp_closed, subgrp_closed,
                        FALSE, FALSE, &loop_sf, &endedges, &intparms, 
                        &sfpartolb);
    sfintloops_alloced = TRUE;
    EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_LoopError, while_end);

    /* create an array of loop ids for input to "splityourself" */
    max_loops = 0; 
    for (j=0; j<num_grps; j++)
      for (k=0; k<num_subgrps_grp[j]; k++) 
           max_loops++;

    /* allocate array for maximum number of loops */
    loop_ids = (GRobjid *) om$malloc (size = max_loops * sizeof (GRobjid));
    EMerr_hndlr (!loop_ids, *EFmsg, EMS_E_NoDynamicMemory, while_end);

    /* Create a two-dimensional array of "sfintedpar" structures, that will
     * form the end info for the loops. Note here that we cannot simply copy
     * the pointers from the "intparms" array, but must actually copy the
     * contents of the sfintedpar structures as pointed by the intparms array.
     * The "intparms" array points to the sfintedpars of the intobjs in the
     * inters list. Typically, the "intparms[j][k*2]" and "intparms[j][k*2+1]"
     * point to sfintedpars of DIFFERENT intobjs at either end of the loop or
     * subgroup under consideration. But since we need the trim_info as a
     * linked list of sfintedpars, we would be linking up sfintedpars of
     * different intobjs, if we used the sfintedpar structures pointed to by 
     * the "intparms" array.  In order not to screw up the inters list, 
     * therefore, we need to make separate copies of the sfintedpar structures.
     *
     * trim_info[i] --> pointer to the linked list pair of sfintedpars that
     *                  refer to incidence edge info at the ends of the loop "i"
     *
     * trim_info[i][0] -> sfintedpar structure for the start of the loop
     *
     * trim_info[i][1] -> sfintedpar structure for the end   of the loop
     *
     * "trim_info[i][0]"'s next element is "trim_info[i][1]" 
     * "trim_info[i][1]"'s next element is NULL
     *
     *  NOTE: Currently I am not copying the contents pointed to by the "info"
     *        pointer of the "EMSsfintedpar" struct, assuming it is not impt.
     *        I am simply setting this pointer to NULL. This can be changed
     *        at a later date if necessary.
     *
     * UPDATE: We include only those loops in the "loop_ids" array that have
     * ------  a valid "trim_info", by that I mean, either closed loops or
     *         loops that have their endpts lying on existing boundary. This
     *         check is necessary because while creating intersections on rib
     *         feature surfaces, we split intobjs against each other and connect
     *         them up in specific ways, so that there might be dangling
     *         (i.e. subgroups with a free end) subgroups formed during tracing.
     *         These subgroups do not split area and as such do not warrant 
     *         inclusion in the "loop_ids" array.     NP (7/28/93).
     */

    /* allocate size for max. number of loops. We use only the loops with
     * valid trim info.
     */
    trim_info = (struct EMSsfintedpar **) om$malloc 
                    ( size = max_loops * sizeof (struct EMSsfintedpar *) );
    EMerr_hndlr (!trim_info, *EFmsg, EMS_E_NoDynamicMemory, while_end);

/**********
    MOVED THIS INTO THE FOR LOOP BELOW SO THAT EXACT AMOUT OF MEMORY IS 
    ALLOCATED AND FREED CORRECTLY LATER. (NP).
    for (j=0; j<num_trim_loops; j++)
    {
      trim_info[j] = NULL;
      trim_info[j] = (struct EMSsfintedpar *) om$malloc 
                     (size = 2 * sizeof (struct EMSsfintedpar) );
      EMerr_hndlr (!trim_info[j], *EFmsg, EMS_E_NoDynamicMemory, while_end);
    }
*************/


    num_trim_loops=0; 
    for (j=0; j<num_grps; j++)
      for (k=0; k<num_subgrps_grp[j]; k++) 
      {  
         /* check if the current loop (==subgrp) has VALID trim info */
         if ( ((intparms[j][k*2]->edgeid   == NULL_OBJID) || 
               (intparms[j][k*2+1]->edgeid == NULL_OBJID))     
                      &&
              (!subgrp_closed[j][k])) 
         {
           continue;  /* Skip this loop. It has invalid trim info.*/
         }

         trim_info[num_trim_loops]= (struct EMSsfintedpar *) om$malloc 
                                          (size=2*sizeof(struct EMSsfintedpar));
         EMerr_hndlr (!trim_info[num_trim_loops], *EFmsg, EMS_E_NoDynamicMemory,
                       while_end);

         OM_BLOCK_MOVE (intparms[j][k*2],   &(trim_info[num_trim_loops][0]),
                                            sizeof (struct EMSsfintedpar) );
         OM_BLOCK_MOVE (intparms[j][k*2+1], &(trim_info[num_trim_loops][1]),
                                            sizeof (struct EMSsfintedpar) );
         trim_info[num_trim_loops][0].next = & (trim_info[num_trim_loops][1]); 
         trim_info[num_trim_loops][1].next = NULL;
         trim_info[num_trim_loops][0].info = (IGRchar *)NULL;
         trim_info[num_trim_loops][1].info = (IGRchar *)NULL;
         loop_ids [num_trim_loops]         = loop_sf [j][k*2]; 
         num_trim_loops++;
      }
   
    /* STEP 8: Split the loopset using the copied intersection list */
    /****************************************************************/

    /* Get the basis tolerance from this surface and use it in the 
     * method below. This is because the cp loopset is not connected to this
     * surface and therefore the  "EMsplityourself" method may not be able to 
     * get it.
     */
    sts = om$send (msg = message EMSsubbs.EMpartolbasis ( &msg,
                    &(env->md_env.matrix_type), env->md_env.matrix,
                    FALSE /*not used*/, TRUE/*OR FALSE??*/, &(partolbasis.tol)),
                  targetid = this_surface.objid,
                  targetos = this_surface.osnum,
                  senderid = NULL_OBJID);
    EMerr_hndlr(!(1&msg&sts),*EFmsg,EMS_E_SurfaceError,while_end);

    partolbasis.is_valid = TRUE; 
    partolbasis.in_world = FALSE; 
    partolbasis.mattyp   = &(env->md_env.matrix_type);
    partolbasis.mat      = env->md_env.matrix;

    /* The loop_ids that we are passing in HAVE their trim info available and 
     * hence we do not want "EMsplityourself" to do any trimming of input loops.
     * Therefore no trimming options are passed into the method such as
     * "EMImpBnd_BdryIsArea". Coincident intobjs are assumed to be taken care of
     * during "EMintersect_surfaces", so that they are properly split/pushed
     * across common edges as necessary. In short, any loop that lies along
     * the boundary (i.e. a loop that was formerly a coincident intobj) of the 
     * cp_loopset , is also assumed to have valid trim info.
     * ( If trimming HAD to be done within "EMsplityourself", then we would 
     *   have had to modify "EMsplityourself" with a new option so that 
     *   "overlap_processing was NOT done and trimming WAS done with the 
     *   "EMImpBnd_BdryIsArea" option, for the purpose of taking care of 
     *   coincidence. All this is not required, however).
     */
    
     sts = om$send (msg = message EMSloopset.EMsplityourself(
                           &msg, loop_ids, num_trim_loops, trim_info,
                           NULL, NULL, NULL, NULL,
                           EMImpBnd_NoInputDelete | EMImpBnd_CloseRegular |
                           EMImpBnd_DelInvalidLoops,
                           NULL, NULL, &partolbasis, env),
                      targetid = cp_loopset.objid,
                      targetos = cp_loopset.osnum,
                      senderid = NULL_OBJID);
     EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_LoopsetError, while_end);
 
    /* STEP 9: Now we need to identify the loops from this loopset that will 
     *         lead to the correct trace groups. This algorithm depends on the
     *         mode under which we are using this function.
     *
     *         sort_point_mode:
     *           Do a point location on the resulting loopset with ALL points 
     *           placed on this surface, to identify the innermost loops within
     *           which the points lie. 
     *
     *         non sort_point_mode (i.e. check present/absent bits used):
     *           Here we check if any of the edges of a loop was created 
     *           from an intobj that HAD the check_present bits and DID NOT have
     *           the check_absent bits. If there were no such loops, we proceed
     *           to the next surface. 
     *
     *        If there were ANY such sort loops, then we look for all their 
     *        nested loops too. The trace groups that the intobjs (that created
     *        the edges of these loops) belong to shall be marked as "to keep".
     **************************************************************************/

  num_sort_loops = 0; /* At start. Move this to start of while loop?*/

  if (sort_point_mode)
  {
    /* array to store loops which contain sort point */
    sort_loops = (GRobjid *)om$malloc (size = *num_sort_pts * sizeof (GRobjid));
    EMerr_hndlr (!sort_loops, *EFmsg, EMS_E_NoDynamicMemory, while_end);

    /* go through every sort point */
    for (j=0; j<*num_sort_pts; j++)   
    { 
      bad_location = FALSE; /** assume the point is validly placed **/
      check_surface.objid = sort_pts[j].leaf_id.objid;
      check_surface.osnum = sort_pts[j].leaf_id.osnum;
       
      /* if "sort_pts[j]" placed on this surface */
      if ( (check_surface.objid == this_surface.objid) &&
           (check_surface.osnum == this_surface.osnum)     )
      { 
         /* Use the UV values from the sort point struct */
	  sort_pt_uv[0]=sort_pts[j].u;
          sort_pt_uv[1]=sort_pts[j].v;
 
         /* use SAME partolbasis as above??*/
         pt_loc.options = EMS_PTLOC_BOXCHECK; 
         sts = om$send (msg = message EMSloopset.EMpt_location ( 
                               &msg, sort_pt_uv, &pt_loc, &partolbasis),
                       senderid = NULL_OBJID,
                       targetid = cp_loopset.objid,
                       targetos = cp_loopset.osnum);
         EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_PtLocError, while_end);

         bad_location =  (pt_loc.location != EMS_L_ONEDGE) &&  
                         (pt_loc.location != EMS_L_ONVRTX) &&  
                         (pt_loc.location != EMS_L_INAREA) ;
       
         /* Store all the bad points for passing back to the calling function
          * if necessary. The memory allocated in here for "*bad_pts_info" 
          * will HAVE to be deallocated by the CALLING FUNCTION.
          */
         if (bad_location)
         {  

            if (bad_pts)
            { 
              if (!loc_num_bad_pts) 
              { /* allocate max. needed space for the array */
                *bad_pts = (struct EMparms *) om$malloc 
			  (size = *num_sort_pts*sizeof(struct EMparms));
                EMerr_hndlr(!(*bad_pts),*EFmsg,EMS_E_NoDynamicMemory,ret_end);
              }
              /* store bad pt information for display later.*/
              OM_BLOCK_MOVE(&sort_pts[j], &((*bad_pts)[loc_num_bad_pts]),
                                               sizeof(struct EMparms));
            }

            loc_num_bad_pts++; /*local counter to check if all pts are bad */

            if (num_bad_pts)
              *num_bad_pts = loc_num_bad_pts;
         }
         else
         {  redundant_pt = FALSE; 
            for (k=0; k<num_sort_loops; k++)
            {  if (sort_loops[k] == pt_loc.loop_id)
               {  redundant_pt = TRUE;
                  break;
               }
            }
            if (!redundant_pt)
               sort_loops [num_sort_loops++] = pt_loc.loop_id;

         }/*if (!bad_location) */

      }/* if */

    }/*for*/

    /* If ALL points are invalid, exit with error. If all pts are invalid, 
     * they would not lead to ANY trace group and hence ALL trace groups 
     * would be deleted, which in turn means that we would not have ANY
     * intersections left. Therefore, we set the code accordingly 
     * to EMS_E_AllIntersectionsDeleted.
     */

    if (*num_sort_pts == loc_num_bad_pts)
    {  
       *EFmsg = EMS_E_AllIntersectionsDeleted;
       goto while_end;
    }


  }/*if, sort_point_mode*/
  else /* ELSE, intobj bits need to be checked */
  {
    /* 1. Get a list of all loops in the loopset.
     * 2. Get the edges of each loop.
     * 3. For every edge, check if the edge corresponds with an intobj in the
     *    original inters list that has the input bitmask.
     * 4. If any intobj so matches, put this loop into the "sort loops" array.
     */


    sts = om$get_channel_count(objid        = cp_loopset.objid,
                               osnum        = cp_loopset.osnum,
                               p_chanselect = &to_loops,
                               count        = &lp_count);
    EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, while_end);

    /* array to store sort loops (the ones we are interested in). We allocate
     * the maximum size needed.
     */
    sort_loops = (GRobjid *)om$malloc (size = lp_count * sizeof (GRobjid));
    EMerr_hndlr (!sort_loops, *EFmsg, EMS_E_NoDynamicMemory, while_end);

    loop_objects = (OM_S_OBJECT_LINKAGE *) om$malloc (size = lp_count *
                                       sizeof(OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!loop_objects, *EFmsg, EMS_E_NoDynamicMemory, while_end);

    sts = om$get_channel_objects (objid        = cp_loopset.objid,
                                  osnum        = cp_loopset.osnum,
                                  p_chanselect = &to_loops,
                                  list         = loop_objects,
                                  size         = lp_count,
                                  count        = &num_loop_objects);
    EMerr_hndlr(!(1&sts)||(num_loop_objects!=lp_count),*EFmsg,EMS_E_OMerror,
                                                while_end);

    /* check each loop to see if any edge corresponds to an intobj with the
     * required bitmask.
     */
    for (j=0; j<num_loop_objects; j++)
    {
       edges       = NULL;
       loop_stored = FALSE;

      /* get all the edges of this loop */
       sts = om$get_channel_count(objid        = loop_objects[j].S_objid,
                                  osnum        = loopset_obj.osnum,
                                  p_chanselect = &to_edges,
                                  count        = &ed_count);
       EMerr_hndlr (!(1&sts) || !ed_count, *EFmsg, EMS_E_OMerror, while_end);

       edges = (OM_S_OBJECT_LINKAGE *) alloca (ed_count *
                                       sizeof(OM_S_OBJECT_LINKAGE));
       sts = om$get_channel_objects (objid        = loop_objects[j].S_objid,
                                     osnum        = loopset_obj.osnum,
                                     p_chanselect = &to_edges,
                                     list         = edges,
                                     size         = ed_count,
                                     count        = &num_edge_objects);
       EMerr_hndlr(!(1&sts)||(num_edge_objects!=ed_count),*EFmsg,EMS_E_OMerror,
                      while_end);

       /* check each edge of loop to see if it corresponds to an intobj in the
        * original list. If it does, check if the intobj is marked as desired.
        * If it is, store this loop in the "sort_loops" array. Keep checking 
        * edges of loop until either there are no edges left OR we determine 
        * that this loop is a "sort_loop".
        */

       for (k=0; k<ed_count && !loop_stored ; k++)
       {  
         /* if any edge id appears in the cp_intobjs list, then use this edge to
          * get its counterpart in the original inters list and hence obtain
          * a pointer to the intobj.
          */
          found_intobj=FALSE;
          for (l=0; l<num_intobjs && !found_intobj; l++)
          {  if ( (edges[k].S_objid == cp_intobjs[l].objid) &&
                  (edges[k].osnum   == cp_intobjs[l].osnum) )
             {  
                /*get a pointer to this intobj*/
                intobj_loc = inters->cvs;
                for (m=0; m<inters->num_cvs; m++)
                {  
                   if ((intobj_loc->this_uvintobj.data.object->objid ==
                                                         orig_intobjs[l].objid)
                                          &&
                      (intobj_loc->this_uvintobj.data.object->osnum ==
                                                         orig_intobjs[l].osnum))
                   {
                      found_intobj=TRUE;

                      if((check_present?(intobj_loc->props&check_present):TRUE)
                                                    &&
                         (check_absent?!(intobj_loc->props&check_absent):TRUE) )
                      {
                         /*This edge is created from an intobj (actually a copy
                          * of the intobj) that is marked as needed. This means
                          * we need to store the loop in "sort_loops" array for
                          * later processing (to mark trace groups).
                          */
                          loop_stored = TRUE;
                          sort_loops [num_sort_loops++]=loop_objects[j].S_objid;
                      }

                      /* Break. We have found intobj corresp. to this edge.
                       * Goto next edge if "loop_stored" is FALSE, else goto 
                       * next loop.
                       */

                      break;  /* get out of "for, m" loop */

                   }/*if*/
                   intobj_loc = intobj_loc->next;
                }/*for,m*/
   
                /* we HAVE to have found the intobj within this IF statement */
                if (!found_intobj)
                  EMerr_hndlr (TRUE, *EFmsg, EMS_E_Fail, while_end);
             }/*if*/
          }/*for,l*/  
       }/*for,k*/
    }/*for,j*/

    /*deallocate the "loop_objects" array*/
    if (loop_objects)
       {om$dealloc(ptr=loop_objects);loop_objects=NULL;}
       
  }/* if !sort_point_mode*/

    /* By now we have an array of loops, whose edges will possibly lead us to
     * the intobjs in the copied inters list which need to be kept, and after
     * mapping these intobjs to the original inters list, will let us know 
     * which trace groups will need to be kept.
     */

    /* do for every sort loop in the array above */
    for (j=0; j<num_sort_loops; j++)
    {  /* get ids of all the edges in THIS loop and in ALL its nested loops*/
       ed_array_size            = 0;
       edges_in_sort_loops     = NULL;
       num_edges_in_sort_loops = 0;

       sts = om$send (msg=message EMSboundary.EMget_edges (&msg, MAXINT, 
                              EMS_OPT_ALL,
		              &edges_in_sort_loops, &ed_array_size, 
			      &num_edges_in_sort_loops),
                      senderid = NULL_OBJID,
		      targetid = sort_loops[j],
		      targetos = loopset_obj.osnum); 
       EMerr_hndlr (!(sts&msg&1), *EFmsg, EMS_E_LoopError, while_end);

       /* Check every edge to see if it is an intobj from cp_inters. 
        * Use of cp_inters list is avoided, since it may not be reliable after
        * the call to "sfintloops" (use "num_intobjs" from earlier step).
        */
       for (k=0; k<num_edges_in_sort_loops; k++)
       {  
         /* if any edge id appears in the cp_inters list, then use this edge to
          * get its counterpart in the original inters list and hence determine
          * the trace group to keep. Mark that group accordingly.
          */
          for (l=0; l<num_intobjs; l++)
          {  if ( (edges_in_sort_loops[k].objid == cp_intobjs[l].objid)
                                    &&
                  (edges_in_sort_loops[k].osnum == cp_intobjs[l].osnum) )
             {  
                /* Mark trace group of THIS intobj. "THIS" intobj is the
                 * intobj (i.e. orig_intobjs[l]) whose copy is "cp_intobjs[l]". 
                 * "orig_intobjs[l]" gives us the edge id of the needed intobj, 
                 * but to mark the trace group, we need a pointer to it.
                 */
                intobj_loc = inters->cvs;
                for (m=0; m<inters->num_cvs; m++)
                {  
                   if ((intobj_loc->this_uvintobj.data.object->objid ==
                                                         orig_intobjs[l].objid)
                                          &&
                      (intobj_loc->this_uvintobj.data.object->osnum ==
                                                         orig_intobjs[l].osnum))
                           break;/* this is the intobj pointer we need */
                   intobj_loc = intobj_loc->next;
                }

                EFget_intobj_trace_group (&msg, intobj_loc,tracedata,&grp_num);
                EMerr_hndlr (!(msg&1), *EFmsg, EMS_E_Fail, while_end);
                trace_group_keep[grp_num] = TRUE; 

                if (!single_operand_mode)
                { 
                  /* mark corresponding trace group of OTHER intobj. This code
                   * assumes "other_intobj" is ALWAYS on the OTHER inters list.
                   * This is not always so (in features, rounding etc., intobjs
                   * from the SAME list are counterparts). Therefore, the "if"
                   * check above prevents optimization in those cases. What the
                   * heck!!!
                   */
                  EFget_intobj_trace_group (&msg, intobj_loc->other_intobj_node, 
                                                 other_tracedata, &grp_num);
                  EMerr_hndlr (!(msg&1), *EFmsg, EMS_E_Fail, while_end);
                 
                  other_trace_group_keep[grp_num] = TRUE; 
                }

                break; /* we have processed intobj corresp. to this edge */
             }
          }
       }

      /* Free array of edges (of the loops with points) */

      if (edges_in_sort_loops)
      {  om$dealloc (ptr = edges_in_sort_loops); 
         /* set to NULL, else will attempt to be freed again at while_end,
          * after the last iteration of this for loop.
          */
         edges_in_sort_loops = NULL;
      }

    }
    while_end:

      /* check if an error condition has occured above, in which case, the
       * while loop should be broken out of, AFTER freeing necessary data 
       */
      if (!(msg&1) || !((*EFmsg)&1))
        error_condition = TRUE;

      /* Free array of edges in the loops with points */
      if (edges_in_sort_loops)
      { om$dealloc (ptr = edges_in_sort_loops); 
        edges_in_sort_loops = NULL;
      }

      /* Free the array that holds loops which contain sort points */
      if (sort_loops)
      {  om$dealloc(ptr = sort_loops);
         sort_loops = NULL;
      }

      /* free the array that holds sfintedpars structures for the ends of 
       * the loops formed from the subgroups of "cp_inters".
       */
      if (trim_info)
      {  for (j=0; j<num_trim_loops; j++)
         { om$dealloc (ptr = trim_info[j]);
           trim_info[j] = NULL;
         }
         om$dealloc (ptr = trim_info);
         trim_info = NULL;
      }

      /* Free the temporary loop info on the surface */
      if (sfintloops_alloced)
      {
         ems$sfintloops_data_free (
                 num_grps        = num_grps,
                 num_subgrps_grp = num_subgrps_grp,
                 loop_sf         = loop_sf,
                 loop_os   = cp_inters->cvs->this_uvintobj.data.object->osnum);            
         ems$sfintloops_free (
                 loop_sf     = loop_sf,
                 endedges    = endedges,
                 intparms    = intparms,
                 partolbasis = sfpartolb);

         if (loop_ids)
         {  om$dealloc (ptr = loop_ids);
            loop_ids = NULL;
         }
      }

      /* Free the temporary trace info on this surface */
      if (sfinttrace_alloced){
         ems$sfinttrace_free(
                msg              = &msg,
                num_grps         = num_grps,
                num_subgrps_grp  = num_subgrps_grp,
                num_elems_subgrp = num_elems_subgrp,
                elems            = (IGRchar ***)elems,
                subgrp_rev       = subgrp_rev,
                elem_rev         = elem_rev,
                grp_closed       = grp_closed,
                subgrp_closed    = subgrp_closed);
      }

      /* Free orig_intobjs and cp_intobjs */
      if (cp_intobjs)
      {  om$dealloc (ptr = cp_intobjs); 
         cp_intobjs = NULL;
      }

      if (orig_intobjs)
      {  om$dealloc (ptr = orig_intobjs); 
         orig_intobjs = NULL;
      }

      /* Free orig_edges and cp_edges */
      if (cp_edges)
      {  om$dealloc (ptr = cp_edges); 
         cp_edges = NULL;
      }

      if (orig_edges)
      {  om$dealloc (ptr = orig_edges); 
         orig_edges = NULL;
      } 

      /* Free cp_inters */
      if (cp_inters)
      {  EMinters_data_free (&msg, cp_inters, 1, NULL, EMsfintedpar_free);
         EMinters_free (cp_inters, 1);
         cp_inters = NULL;
      }
  
      /* Deallocate temporary array created while copying loopset */
      if (cp_info.objid_array)
      {  om$dealloc (ptr = cp_info.objid_array);
         cp_info.objid_array = NULL;
      }

      /* Delete the copied loopset along with all its loops and edges */
      if (cp_loopset.objid != NULL_OBJID)
      {
         sts = om$send(msg = message Root.delete(TRUE),
                        senderid = NULL_OBJID,
                        targetid = cp_loopset.objid,
                        targetos = cp_loopset.osnum);
         EMerr_hndlr (!(sts&1), *EFmsg, EMS_E_LoopsetError, ret_end);
         cp_loopset.objid = NULL_OBJID;
      }
      
      /*dealloc the "loop_objects" (array holding ids of loops of "cp_loopset)*/
      if (loop_objects)
       {om$dealloc(ptr=loop_objects);loop_objects=NULL;}

      if (error_condition)
        break;
      else
        inters = inters->next;

  }/* while (inters) */
 
}/*for*/

/* The rest of the code is executed only if there is no error above. */

if(error_condition) 
{
   goto ret_end;
}

/* STEP 10: Delete intobjs in trace groups that are not to be kept */
/*******************************************************************/

/* Now, we need to delete the intobjs from trace groups marked for deletion.
 * Since deleting intobjs from trace groups on one inters list also deletes
 * intobjs from the another list (even if it is not passed into this fn) due
 * to a possibly existing "other_intobj_node" pointer. Since the trace info on
 * the other inters list MAY be invalidated by the deletions on the first list,
 * we instead simply MARK intobjs for deletion,, instead of deleting them here.
 * Once both sets of trace data have been processed, we delete all intobjs 
 * marked for deletion.
 * ASSSUMPTION: No intobj coming into this function has an EMSintobj_delete bit
 *              set. This can be easily enforced here, by simply unseting these
 *              bits first.
 */

for (i=0; i<2; i++)
{
  tracedata = (i==0? tracedata1 : (single_operand_mode? NULL:tracedata2)); 
  trace_group_keep = (i==0? trace_group_keep1 : 
                            (single_operand_mode? NULL :trace_group_keep2));

  if (tracedata && trace_group_keep)
  {
     for (j=0; j<tracedata->num_grps; j++)
     {  
        if (trace_group_keep[j] != TRUE)
        { 
          for (k=0; k<tracedata->num_subgrps_grp[j]; k++)
          {  intobj_del = tracedata->elems[j][k];
             for (l=0; l<tracedata->num_elems_subgrp[j][k]; l++)
             {   intobj_del->props |= EMSintobj_deletable;
                 intobj_del         = intobj_del->next;
             }
          }
        }



     } 
  }
}

/* delete all deletable intobjs */
for (i=0; i<2; i++)
{
   inters = (i==0? *inters1 : (single_operand_mode? NULL: *inters2)); 

   if (inters)
   {
      EMdelintobj_selective(&msg, NULL, inters, EMSintobj_deletable, NULL);
      EMerr_hndlr (!(msg&1), *EFmsg, EMS_E_Fail, ret_end);
   }
}


/* STEP 11: Update the inters list, deleting any inters nodes that do 
 *          not have any intersections. 
 ************************************************************************/

for (i=0; i<2; i++)
{
  inters_ptr = (i==0 ? inters1 : (single_operand_mode?NULL:inters2));  

  if (inters_ptr)
     (void) EMcmpinters (&msg, inters_ptr);
}


/* check for NULL inters list. This means that ALL intersections have been
 * deleted, since ALL trace groups were marked "FALSE" (or "TO DELETE"), which
 * is in turn due to invalid selection points. Trap this error condition.
 */

if (!(*inters1) || (single_operand_mode?FALSE : !(*inters2)))
{
  if (sort_point_mode)
  {  /* Copy ALL the sort points into the "bad pts" array for passing back to
      * the calling function. 
      */
     if (bad_pts)
     {
       if (!loc_num_bad_pts)
       { /* allocate max. needed space for the array. If "loc_num_bad_pts" is 
          * NOT zero, it means that the space has already been allocated.
          */
         *bad_pts = (struct EMparms *) om$malloc
                    (size = *num_sort_pts * sizeof (struct EMparms));
         EMerr_hndlr(!(*bad_pts),*EFmsg,EMS_E_NoDynamicMemory,ret_end);
       }
       if (num_bad_pts)
         *num_bad_pts = *num_sort_pts; /* 'cos ALL points are bad*/
    
       for (i=0; i<*num_sort_pts; i++)
       {
         /* store bad pt information for display later.*/
         OM_BLOCK_MOVE(&sort_pts[i], &((*bad_pts)[i]),
                      sizeof(struct EMparms));
       }
     } 
  }

  /* what about the case when only ONE of the lists is NULL????*/

  *EFmsg = EMS_E_AllIntersectionsDeleted;

  goto ret_end;
}


/* STEP 12: Perform a retrace on the updated inters list.
 *******************************************************/

BSEXTRACTPAR (&msg, BSTOLLENVEC, xyztracetol);
BSEXTRACTPAR (&msg, BSTOLCHRDHT, chttol);

for (i=0; i<2; i++)
{ 
   tracedata = (i==0 ? tracedata1 : (single_operand_mode?NULL:tracedata2));
   inters    = (i==0 ? (*inters1) : (single_operand_mode?NULL:(*inters2)));
 
   /* j==0 is regular trace.
    * j==1 is re-trace with larger tolerance.
    */
   if (inters)
   {
     for (j=0; j<2; j++) /* double check if necessary */
     {
       if (j==1)
         xyztracetol = chttol * 2.0; /* larger tolerance for  double check */ 
  
       /* free the old trace info on original inters */
        ems$sfinttrace_free(
               msg              = &msg,
               num_grps         = tracedata->num_grps,
               num_subgrps_grp  = tracedata->num_subgrps_grp,
               num_elems_subgrp = tracedata->num_elems_subgrp,
               elems            = (IGRchar ***)tracedata->elems,
               subgrp_rev       = tracedata->subgrp_rev,
               elem_rev         = tracedata->elem_rev,
               grp_closed       = tracedata->grp_closed,
               subgrp_closed    = tracedata->subgrp_closed);
  
       /* re-trace on modified inters */
       ems$sfinttrace (
               msg              = &msg,
               matrixtype       = &(env->md_env.matrix_type),
               matrix           = env->md_env.matrix,
               inters           = inters,
               altxyztol        = &xyztracetol,
               num_grps         = &(tracedata->num_grps),
               num_subgrps_grp  = &(tracedata->num_subgrps_grp),
               num_elems_subgrp = &(tracedata->num_elems_subgrp),
               elems            = &(tracedata->elems),
               subgrp_rev       = &(tracedata->subgrp_rev),
               elem_rev         = &(tracedata->elem_rev),
               grp_closed       = &(tracedata->grp_closed),
               subgrp_closed    = &(tracedata->subgrp_closed) );
       /* do we need to free sfinttrace info on error in this function? */
  
       if (EMSerror (msg))
       {  if (j==0)
            continue; /* try second time with different chord height */
          else
            EMerr_hndlr (!(msg&1), *EFmsg, EMS_E_Fail, ret_end); /*error out*/
       }
       else
          break; /* successful */
     }

   }/*if, inters is not NULL*/
  
 }
  
ret_end:

/* All locally allocated memory has been freed above, in "while_end" */

EMWRAPUP (*EFmsg, sts, "In EMSsfboolean.EFspbool_modify_trace_groups");
return (sts);

} /* EFspbool_modify_trace_groups() */

/*****************************************************************************/

/* This function checks to see if there is ANY intobj that does NOT belong to a
 * trace group that has already been marked to be kept.  If there is at least
 * one such intobj, then, this functions returns a "TRUE" value for the
 * "check_this_surface" parameter. The function takes in the information about
 * which trace groups are "marked to keep" via the array "trace_group_keep".
 * Also, only the given "inters" node is checked and not any others in the
 * linked list after it.
 */
static void EFcheck_inters_trace_groups (
	EFmsg, 
	inters, 
	tracedata, 
	trace_group_keep,
	check_this_surface)
IGRlong			*EFmsg;
struct EMSinters	*inters;
struct EMSsftracedata	*tracedata;
IGRboolean		*trace_group_keep;
IGRboolean		*check_this_surface;
{
IGRlong			msg, sts;
IGRint			i, group_num; 
IGRlong			num_intobjs; /*Should be IGRlong(see struct EMSintobj)*/
struct EMSintobj	*intobj;

*EFmsg = EMS_S_Success;
msg    = EMS_S_Success;
sts    = OM_S_SUCCESS;


  *check_this_surface = FALSE; /* at start */

  num_intobjs = inters->num_cvs;
  intobj      = inters->cvs;
  for (i=0; i<num_intobjs; i++)
  {
      EFget_intobj_trace_group (&msg, intobj, tracedata, &group_num);
      EMerr_hndlr (!(msg&1), *EFmsg, EMS_E_Fail, ret_end);
    
      if (trace_group_keep[group_num] == FALSE)
      {
        *check_this_surface = TRUE;
        break;
      }
      intobj = intobj->next;
  }


ret_end:
EMWRAPUP (*EFmsg, sts, "In EMSsfboolean.EFcheck_inters_trace_groups"); 
}

/*****************************************************************************/

/* This function returns the trace group that the "intobj" belongs to,
 * using the trace information passed in through "tracedata".  
 */

static void EFget_intobj_trace_group (
	EFmsg, 
	intobj, 
	tracedata, 
	group_number)
IGRlong			*EFmsg;
struct EMSintobj	*intobj;
struct EMSsftracedata	*tracedata;
IGRint			*group_number;
{
IGRint			i, j, k; 
IGRboolean		group_found;
GRobjid			intobj_id;
GRspacenum		intobj_os;
struct EMSintobj	*intobj_loc;

*EFmsg = EMS_S_Success;

group_found   = FALSE;
intobj_id     = intobj->this_uvintobj.data.object->objid;
intobj_os     = intobj->this_uvintobj.data.object->osnum;

for (i=0; i<tracedata->num_grps; i++)
{  for (j=0; j<tracedata->num_subgrps_grp[i]; j++)
   {  
      intobj_loc = tracedata->elems[i][j];

      for (k=0; k<tracedata->num_elems_subgrp[i][j]; k++)
      {  
         if (( intobj_id == intobj_loc->this_uvintobj.data.object->objid) &&
             (intobj_os  == intobj_loc->this_uvintobj.data.object->osnum) )
            {  group_found   = TRUE;
               *group_number = i;
               break;
            }
         intobj_loc = intobj_loc->next;
      }
      if (group_found)
         break;
   }
   if (group_found)
      break;
}

EMerr_hndlr (!group_found, *EFmsg, EMS_E_Fail, ret_end);

ret_end:
EMWRAPUP (*EFmsg, *EFmsg, "In EMSsfboolean.EFget_intobj_trace_group"); 
}


end implementation EMSsfboolean;
