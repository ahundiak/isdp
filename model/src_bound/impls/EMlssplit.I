/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method splits a loopset into two or more pieces with the
  input loops. Only the areas of the loopset are split. The input loops
  can be trimmed,untrimmed or a mix of the two. 
	The existing loopset is modified by this method. The loopids of all
  the new loops added to the loopset are returned back to the caller. The
  kind of result produced by splitting depends upon the option chosen. If
  the option chosen is 'regular' the the result is what one would expect
   by following the direction of the input loops.Similarly 'reverse' gives
  result by following the input loop in reverse direction. If the option
  specified is 'regular' AND 'reverse' then the result is a union of the 
  results given by the two options individually. 
	If an input loop is trimmed then the caller can supply the 
  'trim_info' for the loop. These are pair of structures
  for each loop(connected by link list) giving information
  about the edge/edge parameter of the loopset against which each endpoint
  of the loop was trimmed(in the order begin end).

  NOTE: The input loops may get trimmed off and their objids should be
  considered invalid after the split is complete unless the option
  EMImpBnd_NoInputDelete is specified.

History
	SM	03/25/87	Creation Date.
    	SM	07-Mar-89   	In case of error, clean up loops created here.
	SM	28-Sep-89	Added some NoMemory checks after some
				mallocs.
	SM	17-Nov-89	Upon error, if all the loops to close
				were point loops, treat the case as if
				all the input loops were in hole.
	SM	11-Mar-92	Support option 'EMImpBnd_NoPrintErrors'
	SM      06-Jun-93       Do not merge any split points. Also mark
	                        the edges of the copied loop (after EMtpcopy)
	                        as subordinate.
        Sudha   07/06/93        modified for BSprototype includes
        NP      12/08/93        Pass on new option "EMImpBnd_DelInvalidLoops" to
                                cleanup as "EMtplydel_DelInvalidLoops". Also
                                removed reference to "EMImpBnd_NoPrintError"
                                which no longer exists.
*/

class implementation EMSloopset;

#include "EMS.h"
#ifndef DEBUG
#define DEBUG	0
#endif

#include "emssfint.h"
#include "OMmacros.h"
#include "emsimpdef.h"
#include "emsgeteddef.h"
#include "emsinterdef.h"
#include "emstplydel.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsmacros.h"
#include "emsextdef.h"
#include "EMStpmacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#if DEBUG
#include <stdio.h>
#endif

#include "bssfeval.h"
#include "bsdistptpt.h"

#define MemoryDealloc(free_ptr)\
	 {\
	   if( (free_ptr) ) \
	    om$dealloc(ptr = (free_ptr) );\
	    (free_ptr) = NULL;\
	 }

#define MemoryRealloc(buf_size, num_loops,loops,trim,flags)\
	 if(!(buf_size))\
	  {\
	    if( (loops) != loops_to_impose_buf)\
	     {\
	      (loops) = (GRobjid *) om$realloc(ptr= ((char *)loops),\
			        size=( (num_loops)+ (BDRY_FACTOR))*\
				sizeof(GRobjid));\
	      (trim) = (struct EMSsfintedpar **) om$realloc(ptr=((char *)trim),\
				size=( (num_loops)+(BDRY_FACTOR))*\
				sizeof(struct EMSsfintedpar *));\
	      (flags) = (IGRboolean *) om$realloc(ptr=((char *)flags),\
				size=( (num_loops) + (BDRY_FACTOR) )*\
				sizeof(IGRboolean));\
	      EMerr_hndlr(!(loops) || !(trim) || !(flags), *EMmsg, \
			EMS_E_NoDynamicMemory, wrapup); \
	     }\
	    else\
	     {\
	      (loops) = (GRobjid *) om$malloc(size=((num_loops)+(BDRY_FACTOR))\
						*sizeof(GRobjid));\
	      (trim) = (struct EMSsfintedpar **) om$malloc(\
				size=( (num_loops)+(BDRY_FACTOR))*\
				sizeof(struct EMSsfintedpar *));\
	      (flags) = (IGRboolean *) om$malloc(\
				size=( (num_loops) + (BDRY_FACTOR) )*\
				sizeof(IGRboolean));\
	      EMerr_hndlr(!(loops) || !(trim) || !(flags), *EMmsg, \
			EMS_E_NoDynamicMemory, wrapup); \
	      OM_BLOCK_MOVE(loops_to_impose_buf, (loops),\
					num_loops * sizeof(GRobjid));\
	      OM_BLOCK_MOVE(trim_info_buf, (trim), num_loops *\
					sizeof(struct EMSsfintedpar *));\
	      OM_BLOCK_MOVE(dealloc_flags_buf, (flags), num_loops *\
						sizeof(IGRboolean));\
	     }\
	    (buf_size) = BDRY_FACTOR;\
	  }

#define IF_BOTH(option) \
	(( ((option) & EMImpBnd_CloseRegular) && \
	   ((option) & EMImpBnd_CloseReverse)) \
	   ? TRUE : FALSE)

#define IF_REGULAR(option) \
	(( (option) & EMImpBnd_CloseRegular) ? TRUE : FALSE)

#define IF_REVERSE(option) \
	(( (option) & EMImpBnd_CloseReverse) ? TRUE : FALSE)


#if DEBUG
#define BDRY_FACTOR	20
#else
#define BDRY_FACTOR	20
#endif

from EMSedge import EMsplityourself,EMgettopedge,EMset_props, EMget_props;
from EMSloop import EMcloseyourself,EMtrimyourself,EMextractyourself;
from EMSedge import EMunsplityourself; 
from EMSloop import EMnext_edge,EMreverse,EMset_props,EMget_props;
from EMSloop import EMtreemod,EMgivenestinfo;
from EMSgraloop import EMglpinit;

from EMSsubbs import GRgetsize, GRgetgeom;
from EMSloop import EMendpts;
from EMSedge import EMextend_geom;

from EMSedge import EMissplit;

extern OMuword	OPP_EMSsplit_class_id, OPP_EMSgraloop_class_id, 
		OPP_EMSptgralp_class_id, OPP_EMSptedge_class_id, 
		OPP_EMSedge_class_id;

extern IGRlong		EMmake_chanselect();
extern int ems_do_print_error_messages;
%safe
static IGRint		EMsm_unsplit_common(), EMfix_dangling();
static IGRboolean	EMmark_multiple_splits();
static IGRint		EMnest_loop(), EMregenerate_point_loop();
static IGRint		EMoverlap_processing();
static void             EMstore_edsplit(), EMorient_cleanup();
%endsafe

extern IGRboolean WANT_POST220_BEHAVIOR;
extern IGRboolean EFisAncestryValid();

method EMsplityourself(IGRlong *EMmsg;
			GRobjid *input_loops;
			IGRint num_input_loops;
			struct EMSsfintedpar **in_trim_info;
			struct EMSsfintedpar ***out_trim_info;
			IGRint *num_out_trim_info;
			GRobjid **output_loops;
			IGRint *num_output_loops;
			IGRushort options;
			IGRint *num_sfs;
			struct EMSownercomp **sfloops;
			struct EMSpartolbasis *partolbasis;
			struct GRmd_env *env)
{
    IGRint   	          	sts,num_loops_to_impose,buf_size,ext_size;
    OM_S_CHANSELECT       	to_edges, to_common_edge, chan_to_split;
    GRobjid			*loops_to_impose,*loopids_ptr,*loops_to_close, 
    				loops_to_impose_buf[BDRY_FACTOR], 
				loops_to_close_buf[BDRY_FACTOR], *ext_loops, 
				loopids,edges[4], 
				static_ext_loops_buf[BDRY_FACTOR];

    struct EMSsfintedpar	**lp_bdrys_ptr,**my_bdrys_ptr, **ele_bdrys, 
    				*static_ele_bdrys_buf[BDRY_FACTOR], 
				**trim_info, *trim_info_buf[BDRY_FACTOR], 
				*lp_bdrys = NULL, *my_bdrys = NULL;

    IGRint			num_trm_loops,*num_bdrys_ptr,trm_buf_size, 
    				num_loops_to_close,num_bdrys,i,j,idx;

    IGRboolean			*dealloc_flags,*nested_p_flags, out_loops, 
				delete_loops,
				*degn_flags = NULL, *was_ptlp = NULL, 
    				dealloc_flags_buf[BDRY_FACTOR], 
				nested_p_flags_buf[BDRY_FACTOR], 
				degn_flags_buf[BDRY_FACTOR], 
				was_ptlp_buf[BDRY_FACTOR];

    IGRushort			trim_options;
    IGRboolean			in_area =               FALSE,
                                in_hole =               FALSE, 
                                intersect =             FALSE, 
                                coincedent =            FALSE, 
				atleast_one_open_loop = FALSE, 
				dangling =              FALSE;
    GRobjid			*features = NULL;
    IGRint			num_features, EMconnect_split(), max_loops;
    struct IGRbsp_surface	*surface = NULL;
    IGRchar			split_once, multiple_split, *multi, *uni;
    IGRboolean			multi_splits_marked = FALSE;
    IGRboolean			unsplit_on_error = FALSE, 
				undo_on_error = FALSE;
    IGRint			numedsplit = 0;
    GRobjid			*edsplit = NULL, edsplit_buf[BDRY_FACTOR];
    struct EMSownercomp		*owncomps;
    IGRint			numowners;
    IGRushort			cleanup_options = NULL;
    extern IGRint		EMrecord_degeneracy();
    IGRboolean			all_degenerate = TRUE;
    IGRushort			edsplit_options = NULL;
    OMuint			num_edges;
    GRobjid			*ptedges = NULL;
    IGRint			num_ptedges = 0, ptedges_buf = 0;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   multi = &multiple_split;
   uni = &split_once;

   if(options & EMImpBnd_SplitTopology)   
    edsplit_options |= EMSplitEd_SplitTopology;

   if(options & EMImpBnd_MaintainAssoc)   
    edsplit_options |= EMSplitEd_MaintainAssoc;

   if(IF_BOTH(options))
    edsplit_options |= EMSplitEd_ClosureBothSides;

    lp_bdrys_ptr = &lp_bdrys;
    my_bdrys_ptr = &my_bdrys;
    num_bdrys_ptr = &num_bdrys;
    loopids_ptr = &loopids;
    edsplit = edsplit_buf;

    loops_to_impose = loops_to_impose_buf;
    loops_to_close = loops_to_close_buf;
    num_loops_to_impose = 0;
    num_loops_to_close = 0;
    trim_info = trim_info_buf;
    dealloc_flags = dealloc_flags_buf;
    nested_p_flags = nested_p_flags_buf;
    degn_flags = degn_flags_buf;
    was_ptlp = was_ptlp_buf;
    ele_bdrys = static_ele_bdrys_buf;
    ext_loops = static_ext_loops_buf;

    trm_buf_size = 1;
    num_trm_loops = 0;
    buf_size = 0;
    out_loops = output_loops && num_output_loops;
    delete_loops = (num_sfs && sfloops) ? FALSE : TRUE;

    sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
    
   if(num_output_loops) *num_output_loops = 0;

   if(!num_input_loops) 
    {
     *EMmsg = EMS_I_NoIntersection;
     goto wrapup;
    }


   buf_size = BDRY_FACTOR;
   ext_size = BDRY_FACTOR;

/* Now generate the list of loops to be closed. If the input is already
   trimmed, then the loops to be closed will depend on the 'option' only.
   If the input is not trimmed then the loops to be closed will depend on
   the pieces generated after trimming(and the option). In case if the
   option is EMImpBnd_CloseRegular&&EMImpBnd_CloseReverse then each loop to be
   closed is copied and reversed. If the option is EMImpBnd_CloseReverse only,
   then each loop to be closed is just reversed. If the option is
   EMImpBnd_CloseRegular then the loops to be closed are unaffected.
*/
   num_loops_to_impose = 0;

   in_area = TRUE;
   in_hole = TRUE;
   coincedent = TRUE;
   intersect = FALSE;
   trim_options = options & EMImpBnd_PreciseTrim ? EMS_INTER_MOREPRECISE
						 : NULL;
   if(options & EMImpBnd_BdryIsArea) trim_options |= EMS_INTER_BDRYISAREA;

   for(i=0;i<num_input_loops;i++)
    {
	IGRboolean trimmed;
	trimmed = (in_trim_info)? (in_trim_info[i]?TRUE:FALSE) : FALSE;
	
/* If none of the loops are trimmed, the caller
   can specify NULL for this argument. 
*/
         if(trimmed) 
          {
	    loops_to_impose[num_loops_to_impose] = input_loops[i];
	    trim_info[num_loops_to_impose] = in_trim_info[i];
	    dealloc_flags[num_loops_to_impose++] = FALSE;
	    buf_size--;
	    MemoryRealloc(buf_size, num_loops_to_impose,loops_to_impose,
			trim_info,dealloc_flags);
	  }
         else
          {
	    if(options & EMImpBnd_WantStatMsg)
	      ex$message(msgnumb = EMS_S_TrimmingLps);
	
	    if(lp_bdrys)
	     {
		struct EMSsfintedpar	*this;
	      this = lp_bdrys;
	      while(this)
	       {
		if(this->info) om$dealloc(ptr = this->info);
		this->info = NULL;
		this = this->next;
	       }
	      EMsfintedpar_free(lp_bdrys, NULL);
	      lp_bdrys = NULL;
	     }
	    num_trm_loops = 0;
	    trm_buf_size = 1;
	    if(trim_options & EMS_INTER_BDRYISAREA)
	      sts = EMoverlap_processing(EMmsg, &my_id, trim_options,
			&my_bdrys_ptr, &lp_bdrys_ptr, &loopids_ptr, 
			&num_trm_loops, &num_bdrys_ptr, &trm_buf_size, 
			partolbasis, input_loops[i]);
	    else
 	      sts = om$send(msg=message EMSloop.EMtrimyourself
			(EMmsg, &my_id, trim_options, &my_bdrys_ptr,
			 &lp_bdrys_ptr, &loopids_ptr, &num_trm_loops,
			 &num_bdrys_ptr, &trm_buf_size, partolbasis),
			targetid = input_loops[i]);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	    
	
     	    if(*EMmsg == EMS_I_IntersectTrim) 
	      { intersect = TRUE; in_area = FALSE; in_hole = FALSE; 
	        coincedent = FALSE;
              }
     	    else if(*EMmsg == EMS_I_InAreaTrim) 
	      { in_hole = FALSE; coincedent = FALSE;}
     	    else if(*EMmsg == EMS_I_InHoleTrim) 
	      { in_area = FALSE; coincedent = FALSE;}
            else if(*EMmsg == EMS_I_CoincedentTrim)
              { in_area = FALSE; in_hole = FALSE;}
	
	    
/* If the loop is completely in area, do not spend time extracting it.
*/
	    if(lp_bdrys_ptr[0])
	     {
	       if(*EMmsg == EMS_I_InAreaTrim)
	        {
		 IGRushort lpprops;
		
		   ext_loops[0] = input_loops[i];
		   ele_bdrys[0] = my_bdrys;
		   
	         sts = om$send(msg = message EMSloop.EMget_props(EMmsg, 
		       &lpprops), targetid = ext_loops[0]);
		
		 if(/*!WANT_POST220_BEHAVIOR &&*/ !(lpprops & EMLP_OPEN))
	          {
	           ele_bdrys[0]->edgeid = NULL_OBJID;
	           ele_bdrys[0]->next->edgeid = NULL_OBJID;
	          }
		 else if(/*WANT_POST220_BEHAVIOR &&*/ !(lpprops & EMLP_OPEN))
		  {
		   num_edges = 0;
		   sts = om$get_channel_count(objid = ext_loops[0], 
		         p_chanselect = &to_edges, count = &num_edges);
		   /*********
		   if( (num_edges == 1) && (num_bdrys == 1))
		    {
	             ele_bdrys[0]->edgeid = NULL_OBJID;
	             ele_bdrys[0]->next->edgeid = NULL_OBJID;
		    }
		   **********/
		  }
		}
	       else
		{
	          if(num_bdrys > ext_size)
		   {
		     if(ext_loops != static_ext_loops_buf)
		      {
	                ext_loops = (GRobjid *) om$realloc(ptr = (char *)ext_loops,
				size=num_bdrys*sizeof(GRobjid));
	                ele_bdrys = (struct EMSsfintedpar **) om$realloc(
				ptr = (char *)ele_bdrys,
				size=num_bdrys*sizeof(struct EMSsfintedpar *));
		      }
		     else
		      {
    			ext_loops = (GRobjid *) om$malloc(size = num_bdrys*
							sizeof(GRobjid));
    			ele_bdrys = (struct EMSsfintedpar **) om$malloc(size=
				num_bdrys * sizeof(struct EMSsfintedpar *));
		      }
		     EMerr_hndlr(!ext_loops || !ele_bdrys, *EMmsg, 
				    EMS_E_NoDynamicMemory, wrapup);
		     ext_size = num_bdrys;
		   }
	          sts = om$send(msg=message EMSloop.EMextractyourself
			      (EMmsg, lp_bdrys, my_bdrys, num_bdrys,
			       &ext_loops, NULL, &ele_bdrys, TRUE,
				options, partolbasis),
			       targetid = input_loops[i]);
	          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
		}
	       for(j=0;j<num_bdrys;j++)
	        {
		  loops_to_impose[num_loops_to_impose] = ext_loops[j];
		  trim_info[num_loops_to_impose] = ele_bdrys[j];
		  dealloc_flags[num_loops_to_impose++] = TRUE;
		  buf_size--;
	          MemoryRealloc(buf_size, num_loops_to_impose,
			   loops_to_impose,trim_info,dealloc_flags);
	        }
	     } /* If lp_bdrys_ptr[0] */

	    else if (! (options & EMImpBnd_NoInputDelete))
	     {
	      sts = om$send(msg=message Root.delete(TRUE),
			targetid = input_loops[i]);
	      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
 	     }
       }  /* If not trimmed */

    }  /* For i=0; i<num_input_loops; i++ */

   if(ext_loops != static_ext_loops_buf)
    {
     MemoryDealloc(ext_loops);
     MemoryDealloc(ele_bdrys);
    }

/* If all the input loops got trimmed off then exit from here.
*/
   if(!num_loops_to_impose) goto wrapup;


/* At this point there is a list of all
   the loops to be imposed with their 'trim_info'. This super list has the
   trim info passed in (if any) for a trimmed loop as well as the trim
   info generated here, for untrimmed input loops. The 'dealloc_flags'
   for each loop to be imposed indicates which memory was allocated by the
   caller(so that it is not deallocated upon exit from this method).
	Since the number of loops to be impose is now known, we can safely
   allocate space for output loops,knowing that the maximum number of
   output loops will be twice this number.
*/

   max_loops = IF_BOTH(options) ? 2 * num_loops_to_impose :
					 num_loops_to_impose;
   if(out_loops)
    {
      *output_loops = (GRobjid *) om$malloc(size=
				max_loops*sizeof(GRobjid));
      EMerr_hndlr(!(*output_loops), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      *num_output_loops = 0;
    }

/* If the caller requires the trim_info back transfer the appropriate
   addresses into the buffer.
*/
   if(out_trim_info)
    {
      *out_trim_info = (struct EMSsfintedpar **) om$malloc(size=
			num_loops_to_impose*sizeof(struct EMSsfintedpar *));
      EMerr_hndlr(!*out_trim_info,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
      *num_out_trim_info = 0;
      for(i=0;i<num_loops_to_impose;i++)
       if(dealloc_flags[i])
         OM_BLOCK_MOVE(&trim_info[i],&(*out_trim_info)[(*num_out_trim_info)++],
			sizeof(struct EMSsfintedpar *));
    }
   

 sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 sts = EMmake_chanselect (EMSedge_to_owner, &chan_to_split);


 /* Validation check for open, dangling pieces */

 atleast_one_open_loop = FALSE;
 dangling = FALSE;
 for(i=0; i<num_loops_to_impose; i++)
  {
   IGRushort props, edprops;

   sts = om$send(msg=message EMSloop.EMget_props(EMmsg,&props),
			targetid = loops_to_impose[i]);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
   if(!(props & EMLP_OPEN)) continue;

   /* If the loop has only one edge, and it is degenerate, consider the
      loop to be closed and continue.
   */
   sts = om$get_channel_count(objid = loops_to_impose[i], 
         p_chanselect = &to_edges, count = &num_edges);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
   if(num_edges == 1)
    {
     sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
           senderid = loops_to_impose[i], p_chanselect = &to_edges);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
     if(edprops & EMED_DEGENERATE)
      {
       sts = om$send(msg = message EMSloop.EMset_props(EMmsg, EMLP_OPEN, 
             EMS_O_OFF), targetid = loops_to_impose[i]);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
       continue;
      }
    }

   atleast_one_open_loop = TRUE;
      
   /* Attempt to fix the dangling intersections */

   if(IF_NULL_OBJID(trim_info[i]->edgeid))
    {
     sts = EMfix_dangling(EMmsg, trim_info[i], env, loops_to_impose[i], 
			     my_id, &surface, partolbasis, TRUE);
     if(*EMmsg == EMS_I_NoSolution) dangling = TRUE;
    }
   if(IF_NULL_OBJID(trim_info[i]->next->edgeid))
    {
     sts = EMfix_dangling(EMmsg, trim_info[i]->next, env, 
		  loops_to_impose[i], my_id, &surface, partolbasis, FALSE);
     if(*EMmsg == EMS_I_NoSolution) dangling = TRUE;
    }
  }

 if(dangling && !(options & EMImpBnd_DegenerateBdrys)) 
  {*EMmsg = EMS_E_IntersectTrim; sts = OM_S_SUCCESS; goto wrapup;}

   if(max_loops > BDRY_FACTOR)
    {
     loops_to_close = (GRobjid *) om$malloc(size=
				max_loops*sizeof(GRobjid));
     nested_p_flags = (IGRboolean *) om$malloc(size = 
				max_loops*sizeof(IGRboolean));
     degn_flags = (IGRboolean *) om$malloc(size = 
				max_loops*sizeof(IGRboolean));
     was_ptlp = (IGRboolean *) om$malloc(size = 
				max_loops*sizeof(IGRboolean));
    }
   EMerr_hndlr(!loops_to_close || !nested_p_flags || !degn_flags || !was_ptlp,
               *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   num_loops_to_close = 0;

 all_degenerate = TRUE;
 for(i=0; (i<num_loops_to_impose) && all_degenerate; i++)
  all_degenerate = EFisAncestryValid(EMmsg, loops_to_impose[i], 
			OM_Gw_current_OS, OPP_EMSptgralp_class_id, TRUE);

 for(i=0; i<num_loops_to_impose; i++)
  was_ptlp[i] = EFisAncestryValid(EMmsg, loops_to_impose[i], 
			OM_Gw_current_OS, OPP_EMSptgralp_class_id, TRUE);

 sts = EMrecord_degeneracy(EMmsg, num_loops_to_impose, loops_to_impose, 
			   trim_info, degn_flags, options, OM_Gw_current_OS, 
			    partolbasis, my_id);
 if(!(1&*EMmsg&sts))
  {*EMmsg = EMS_E_IntersectTrim; sts = OM_S_SUCCESS; goto wrapup;}


/*Based on the option chosen by the caller, copy and reverse the loop to
  impose if necessary.
*/
   if( IF_BOTH(options) || IF_REVERSE(options) )
    {
     for(i=0;i<num_loops_to_impose;i++)
     {
      loops_to_close[num_loops_to_close++] = loops_to_impose[i];
      if(degn_flags[i]) continue;

      if( IF_BOTH(options) )
       {
	 IGRushort cp_options;
	 
	 cp_options = EMS_COPY_ONCOMMON  | 
		      ( (options & EMImpBnd_NoDummyEdges) ? 
				NULL : EMS_COPY_INTO_DUMMYEDGE);
	 sts = om$send(msg=message EMSboundary.EMtpcopy
		     (EMmsg,NULL,OM_Gw_current_OS,OM_Gw_current_OS,cp_options,
				&loops_to_close[num_loops_to_close]),
			targetid = loops_to_impose[i]);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	 sts = om$send(msg=message EMSloop.EMreverse(EMmsg),
		   targetid=loops_to_close[num_loops_to_close]);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	
	 /* Make all the edges of the copied loop as subordinate edges, as
	    they are now connected to the edges of the original loop.
	 */
	 sts = om$send(msg = message EMSedge.EMset_props(EMmsg,
	       EMED_SUBORDINATE, EMS_O_ON), 
	       senderid = loops_to_close[num_loops_to_close],
	       p_chanselect = &to_edges);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);	
	
	 num_loops_to_close++;
       }
      else if( IF_REVERSE(options))
       {
	 sts = om$send(msg=message EMSloop.EMreverse(EMmsg),
			targetid = loops_to_impose[i]);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
       }
      }
    }
   else
    {
      num_loops_to_close = num_loops_to_impose;
      OM_BLOCK_MOVE(loops_to_impose,loops_to_close,num_loops_to_close*
			sizeof(GRobjid));
    }


   if(!num_loops_to_close)
    {
      *EMmsg = EMS_I_InHoleTrim;
      goto wrapup;
    }


	
				
 if((options & EMImpBnd_WantStatMsg) && atleast_one_open_loop)
  ex$message(msgnumb = EMS_S_SplittingArea);


 multi_splits_marked = EMmark_multiple_splits(trim_info, num_loops_to_impose, 
			uni, multi);

 /* Each loop will split atmost two existing edges */

 if(num_loops_to_impose * 2 > BDRY_FACTOR)
  edsplit = (GRobjid *) om$malloc(size = 2 * num_loops_to_impose * 
					sizeof(GRobjid));
 EMerr_hndlr(!edsplit, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 numedsplit = 0;
 idx = 0;
 i = 0;
 unsplit_on_error = TRUE;

 while(idx<num_loops_to_close)
  {
    if( !IF_NULL_OBJID(trim_info[i]->edgeid) &&
	!IF_NULL_OBJID(trim_info[i]->next->edgeid))
     {
       GRobjid svtx[2],to_split,to_connect[2];
       IGRint direction[2];
       struct EMSsfintedpar *split_info[2];
       IGRboolean already_split = FALSE;

       svtx[0] = svtx[1] = NULL_OBJID;
       split_info[1] = NULL;

       if(IF_BOTH(options) && !degn_flags[i])
	{

/* Begin point of the regular loop.
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  if(multi_splits_marked && 
	     (trim_info[i]->info == uni))
	   to_split = trim_info[i]->edgeid;
	  else
	   {
	    sts = om$send(msg=message EMSedge.EMgettopedge
		   (EMmsg,&trim_info[i]->edgepar,partolbasis,&to_split),
			targetid = trim_info[i]->edgeid);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	    EMerr_hndlr(*EMmsg==EMS_I_OutOfBounds,*EMmsg,EMS_E_EdgeError,
			wrapup);
	   }
	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_First,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  
	  direction[0] = OUTGOING;
	  split_info[0] = trim_info[i];
	  sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options, 
			 svtx,edges,to_connect,direction,
			NULL,partolbasis,env, &ptedges, &num_ptedges, 
			&ptedges_buf),
			targetid = to_split);
	  already_split = (*EMmsg == EMS_I_AlreadySplit) ? TRUE : FALSE;
	  if(*EMmsg == EMS_I_IntersectOrient)
	   {
	    EMorient_cleanup(EMmsg, &loops_to_close[idx]);
            nested_p_flags[idx] = FALSE;
	    nested_p_flags[idx+1] = FALSE;
	    i++;
	    idx +=2;
	    continue;
	   }
	  if(trim_info[i]->intloc == EMScvint_middle)
	  EMstore_edsplit(&numedsplit, edsplit, trim_info[i]->edgeid);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
		
/* End point of the reverse copy
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_Last,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx+1]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  if(already_split)
	   {
	    direction[0] = INCOMING;
	    sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options, 
			 svtx,edges,to_connect,direction,
			NULL,partolbasis,env, &ptedges, &num_ptedges, 
			&ptedges_buf),
			targetid = edges[1]);
	    if(*EMmsg == EMS_I_IntersectOrient)
	     {
	      EMorient_cleanup(EMmsg, &loops_to_close[idx]);
              nested_p_flags[idx] = FALSE;
	      nested_p_flags[idx+1] = FALSE;
	      i++;
	      idx +=2;
	      continue;
	     }
	   }
	  else
	    sts = EMconnect_split(EMmsg, to_connect[0], edges[1], svtx[0], 
				&to_edges, &chan_to_split);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	

/* End point of the regular loop
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  if(multi_splits_marked &&
	    (trim_info[i]->next->info == uni))
	   to_split = trim_info[i]->next->edgeid;
	  else
	   {
	    sts = om$send(msg=message EMSedge.EMgettopedge
		   (EMmsg,&trim_info[i]->next->edgepar,partolbasis,&to_split),
			targetid = trim_info[i]->next->edgeid);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	    EMerr_hndlr(*EMmsg==EMS_I_OutOfBounds,*EMmsg,EMS_E_EdgeError,
			wrapup);
	   }

	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_Last,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  direction[0] = INCOMING;
	  split_info[0] = trim_info[i]->next;
	  sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options,
			 svtx, edges, to_connect, direction,
			 NULL,partolbasis,env, &ptedges, &num_ptedges, 
			 &ptedges_buf),
			targetid = to_split);
	  already_split = (*EMmsg == EMS_I_AlreadySplit) ? TRUE : FALSE;
	
          if(*EMmsg == EMS_I_IntersectOrient)
	   {
	    EMorient_cleanup(EMmsg, &loops_to_close[idx]);
            nested_p_flags[idx] = FALSE;
	    nested_p_flags[idx+1] = FALSE;
	    i++;
	    idx +=2;
	    continue;
	   }
	  if(trim_info[i]->next->intloc == EMScvint_middle)
	  EMstore_edsplit(&numedsplit, edsplit, trim_info[i]->next->edgeid);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	
/* Begin point of the reverse copy
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_First,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx+1]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  if(already_split)
	   {
	    direction[0] = OUTGOING;
	    sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options, 
			 svtx,edges,to_connect,direction,
			NULL,partolbasis,env, &ptedges, &num_ptedges, 
			&ptedges_buf),
			targetid = edges[1]);
            if(*EMmsg == EMS_I_IntersectOrient)
	     {
	      EMorient_cleanup(EMmsg, &loops_to_close[idx]);
              nested_p_flags[idx] = FALSE;
	      nested_p_flags[idx+1] = FALSE;
	      i++;
	      idx +=2;
	      continue;
	     }
	   }
	  else
	  sts = EMconnect_split(EMmsg, edges[1], to_connect[0], svtx[0], 
				&to_edges, &chan_to_split);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

          nested_p_flags[idx] = FALSE;
	  nested_p_flags[idx+1] = FALSE;
	  i++;
	  idx +=2;
	}
       else if(IF_REVERSE(options) && !degn_flags[i])
	{
/* begin point of the reversed loop
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  if(multi_splits_marked &&
	    (trim_info[i]->next->info == uni))
	   to_split = trim_info[i]->next->edgeid;
	  else
	   {
	    sts = om$send(msg=message EMSedge.EMgettopedge
		   (EMmsg,&trim_info[i]->next->edgepar,partolbasis,&to_split),
			targetid = trim_info[i]->next->edgeid);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	    EMerr_hndlr(*EMmsg==EMS_I_OutOfBounds,*EMmsg,EMS_E_EdgeError,
				wrapup);
	   }
	
	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_First,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  direction[0] = OUTGOING;
	  split_info[0] = trim_info[i]->next;
	  sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options,
			 svtx, edges, to_connect, direction,
			 NULL,partolbasis,env, &ptedges, &num_ptedges, 
			 &ptedges_buf),
			targetid = to_split);
          if(*EMmsg == EMS_I_IntersectOrient)
	   {
	    EMorient_cleanup(EMmsg, &loops_to_close[idx]);
            nested_p_flags[idx] = FALSE;
	    i++;
	    idx++;
	    continue;
	   }
	  if(trim_info[i]->next->intloc == EMScvint_middle)
	  EMstore_edsplit(&numedsplit, edsplit, trim_info[i]->next->edgeid);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
		
/* end point of the reversed loop.
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  if(multi_splits_marked &&
	    (trim_info[i]->info == uni))
	   to_split = trim_info[i]->edgeid;
	  else
	   {
	    sts = om$send(msg=message EMSedge.EMgettopedge
		   (EMmsg,&trim_info[i]->edgepar,partolbasis,&to_split),
			targetid = trim_info[i]->edgeid);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	    EMerr_hndlr(*EMmsg==EMS_I_OutOfBounds,*EMmsg,EMS_E_EdgeError,
				wrapup);
	   }
	
	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_Last,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  direction[0] = INCOMING;
	  split_info[0] = trim_info[i];
	  sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options,
			 svtx,edges,to_connect,direction,
			 NULL,partolbasis,env, &ptedges, &num_ptedges, 
			 &ptedges_buf),
			targetid = to_split);
          if(*EMmsg == EMS_I_IntersectOrient)
	   {
	    EMorient_cleanup(EMmsg, &loops_to_close[idx]);
            nested_p_flags[idx] = FALSE;
	    i++;
	    idx++;
	    continue;
	   }
	  if(trim_info[i]->intloc == EMScvint_middle)
	  EMstore_edsplit(&numedsplit, edsplit, trim_info[i]->edgeid);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
          nested_p_flags[idx] = FALSE;
	  i++;
	  idx++;
	}
       else if(IF_REGULAR(options) || degn_flags[i])
	{
/* Begin point of the regular loop.
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  if(multi_splits_marked &&
	    (trim_info[i]->info == uni))
	   to_split = trim_info[i]->edgeid;
	  else
	   {
	    sts = om$send(msg=message EMSedge.EMgettopedge
		   (EMmsg,&trim_info[i]->edgepar,partolbasis,&to_split),
			targetid = trim_info[i]->edgeid);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	    EMerr_hndlr(*EMmsg==EMS_I_OutOfBounds,*EMmsg,EMS_E_EdgeError,
					wrapup);
	   }
	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_First,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  direction[0] = OUTGOING;
	  split_info[0] = trim_info[i];
	  sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options,
			 svtx,edges,to_connect,direction,
			 NULL,partolbasis,env, &ptedges,  &num_ptedges, 
			 &ptedges_buf),
			targetid = to_split);
          if(*EMmsg == EMS_I_IntersectOrient)
	   {
	    EMorient_cleanup(EMmsg, &loops_to_close[idx]);
            nested_p_flags[idx] = FALSE;
	    i++;
	    idx++;
	    continue;
	   }
	  if(trim_info[i]->intloc == EMScvint_middle)
	  EMstore_edsplit(&numedsplit, edsplit, trim_info[i]->edgeid);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

/* End point of the regular loop
*/
	  om$construct(classid=OPP_EMSsplit_class_id,p_objid=svtx);
	  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	  if(multi_splits_marked &&
	    (trim_info[i]->next->info == uni))
	   to_split = trim_info[i]->next->edgeid;
	  else
	   {
	    sts = om$send(msg=message EMSedge.EMgettopedge
		   (EMmsg,&trim_info[i]->next->edgepar,partolbasis,&to_split),
			targetid = trim_info[i]->next->edgeid);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	    EMerr_hndlr(*EMmsg==EMS_I_OutOfBounds,*EMmsg,EMS_E_EdgeError,
					wrapup);
	   }
	
	  sts = om$send(msg=message EMSloop.EMnext_edge
			(EMmsg,EMGetEd_Last,NULL_OBJID,to_connect),
			targetid = loops_to_close[idx]);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  direction[0] = INCOMING;
	  split_info[0] = trim_info[i]->next;
	  sts = om$send(msg=message EMSedge.EMsplityourself
			(EMmsg, split_info, edsplit_options,
			 svtx,edges,to_connect,direction,
			 NULL,partolbasis,env, &ptedges,  &num_ptedges, 
			 &ptedges_buf),
			targetid = to_split);
          if(*EMmsg == EMS_I_IntersectOrient)
	   {
	    EMorient_cleanup(EMmsg, &loops_to_close[idx]);
            nested_p_flags[idx] = FALSE;
	    i++;
	    idx++;
	    continue;
	   }
	  if(trim_info[i]->next->intloc == EMScvint_middle)
	  EMstore_edsplit(&numedsplit, edsplit, trim_info[i]->next->edgeid);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
          nested_p_flags[idx] = FALSE;
	  i++;
	  idx++;
	}
       else
	{
	   *EMmsg = EMS_E_InvalidArg;
	   goto wrapup;
	}

    } /* if( !IF_NULL_OBJID(trim_info[i]->edgeid) &&
	!IF_NULL_OBJID(trim_info[i]->next->edgeid))
      */

   else
    {
	if(IF_BOTH(options) && !degn_flags[i])
	 {
	   nested_p_flags[idx] = TRUE;
	   nested_p_flags[idx+1] = TRUE;
	   idx += 2;
	 }
	else 
	 {
	   nested_p_flags[idx] = FALSE;
	   idx++;
	 }
	i++;
    }
  }  /*end While */


 if(multi_splits_marked)
  {
   for(i=0; i<num_loops_to_impose; i++)
    {
     trim_info[i]->info = NULL;
     trim_info[i]->next->info = NULL;
    }
  }

/* At this point all the loops to be imposed have performed the split
   operation on the loopset. A 'close' message is sent to each of those
   loops. If a loop is closed then it is put into the list of output
   loops. Also send down the loopset id to the loop, so that after 
   successfully closing itself, the loop nests itself into the loopset.
	If the loop is already closed and if the option is BOTH(the caller
   is just splitting area), then the original loop and its reversed copy
   need to behave as a single unit. The nesting of such loops needs to
   always be P inside a C and the C inside some other P. This is to
   avoid nested P or C problem.
*/
 if((options & EMImpBnd_WantStatMsg) && atleast_one_open_loop)
  ex$message(msgnumb = EMS_S_ClosingArea);
 
   idx = 0;
 undo_on_error = TRUE;

   while(idx < num_loops_to_close)
    {
      IGRboolean		closed;

      if(!nested_p_flags[idx])
       {
	if(IF_NULL_OBJID(loops_to_close[idx]))
	 closed = FALSE;
	else
	 {
	  IGRint save_flag;
	
	  save_flag = ems_do_print_error_messages;
	  ems_do_print_error_messages = FALSE;
          sts = om$send(msg=message EMSloop.EMcloseyourself
			(EMmsg, &my_id, &closed, partolbasis),
			targetid = loops_to_close[idx]);
	  ems_do_print_error_messages = save_flag;
	
	  /* In case of orientation problems arising from degenerate point
	     loops, retain such loops as point loops rather than
     	     aborting.
          */
          if( (*EMmsg == EMS_E_IntersectOrient) && was_ptlp[idx])
           sts = EMregenerate_point_loop(EMmsg, loops_to_close[idx], 
                 partolbasis, &my_id, &closed);

          if(!(1&*EMmsg&sts)) goto wrapup;
         }
         if(closed)
	  {
	   if(out_loops)
	    (*output_loops)[(*num_output_loops)++] = loops_to_close[idx];
 	   sts = om$send(msg=message EMSloop.EMset_props
		       (EMmsg,EMLP_NEW,EMS_O_ON),targetid=loops_to_close[idx]);
	   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	  }
	 else loops_to_close[idx] = NULL_OBJID;
	 idx++;
       }
      else
       {
	 struct EMSnest_info	nesting;
	 IGRushort	props;
	 IGRint			parent,child;
	 

	 sts = om$send(msg=message EMSloop.EMget_props(EMmsg,&props),
			targetid = loops_to_close[idx]);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	 if(props & EMLP_PLOOP)
	  {
	    parent = idx + 1;
	    child = idx;
	  }
	 else
	  {
	    parent = idx;
	    child = idx + 1;
	  }
	 sts = EMnest_loop(EMmsg, loops_to_close[parent], my_id, NULL_OBJID, 
			&nesting, partolbasis);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
	 sts = EMnest_loop(EMmsg, loops_to_close[child], my_id, 
			loops_to_close[parent], &nesting, partolbasis);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
	
	 if(out_loops)
	  { 
	    (*output_loops)[(*num_output_loops)++] = 
					loops_to_close[parent];
	    (*output_loops)[(*num_output_loops)++] = 
					loops_to_close[child];
	  }
         sts = om$send(msg=message EMSloop.EMset_props
		       (EMmsg,EMLP_NEW | EMLP_DUMMY_CLOOP,EMS_O_ON),
			targetid=loops_to_close[parent]);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	 sts = om$send(msg=message EMSloop.EMset_props
		       (EMmsg,EMLP_NEW,EMS_O_ON),
			targetid=loops_to_close[child]);
	 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	 idx += 2;
       }

    }

/* If the delete loops flag is FALSE then the caller wishes to have the
   existing loops left intact. In that case send a 'unsplit' message to
   all the newly closed loops so that all the existing loops which were
   modified(split) are returned to their original state.
	If delete loops flag is TRUE then do not go through all this 
   trouble because the modified (split) existing loops are going to get
   deleted anyway. Just set all the split bits off in the edges of the
   newly formed loops.
*/

   sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
				
   if(!delete_loops)
    {
      for(i=0; i<numedsplit; i++)
       {
	if(IF_NULL_OBJID(edsplit[i]))
	 continue;

	if(!EFisAncestryValid(EMmsg, edsplit[i], OM_Gw_current_OS, 
	   OPP_EMSedge_class_id, TRUE))
	 {
	  edsplit[i] = NULL_OBJID;
	  continue;
         }
	sts = om$send(msg = message EMSedge.EMunsplityourself(EMmsg, NULL), 
				targetid = edsplit[i]);
	EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	sts = EMsm_unsplit_common(EMmsg, trim_info, num_loops_to_impose, 
			edsplit[i], &to_common_edge);
	EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
       }
    }

   unsplit_on_error = FALSE;

/* Cleanup all the unwanted regions. If delete flag is true, the cleanup
   message will actually delete all the split loops. If the flag is 
   FALSE, it will extract the deleteable loops and return the list
   of such loopids. Since there is a single surface involved the 
   'numowners' and 'owncomps' are meaningless.
*/

   if (options & EMImpBnd_WantStatMsg) 
    ex$message(msgnumb = EMS_S_Cleanup);
	
   if(delete_loops) cleanup_options |= EMtplydel_DeleteElems;
   cleanup_options |= EMtplydel_NoCommonEdge;
   if(options & EMImpBnd_MaintainSplit) 
     cleanup_options |= EMtplydel_MaintainSplit;
   if(options & EMImpBnd_DelInvalidLoops)
     cleanup_options |= EMtplydel_DelInvalidLoops;

   owncomps = NULL;
   numowners = 0;
   sts = om$send(msg=message EMSloopset.EMlscleanup
				(EMmsg,num_sfs,sfloops,&numowners,
				 &owncomps,cleanup_options),targetid=my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* If the loopset had any features they need to be updated, unless specified
      otherwise by the caller.
   */

   features = NULL;
   num_features = 0;
   if(!(options & EMImpBnd_NoFeatureUpdate))
    {     
     sts = om$send(msg = message EMSloopset.EMupdate_features
				(EMmsg, &features, &num_features, 
				 num_sfs, sfloops, 
				 &numowners, &owncomps, TRUE, partolbasis), 
				targetid = my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(num_features && out_loops)
      {
       *output_loops = (GRobjid *) om$realloc(ptr = (char *)*output_loops, 
				size = (*num_output_loops + num_features) * 
      					sizeof(GRobjid));
       EMerr_hndlr(!(*output_loops), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       OM_BLOCK_MOVE(features, &(*output_loops)[*num_output_loops], 
			sizeof(GRobjid) * num_features);
       (*num_output_loops) += num_features;
      }
    }

/* Cleanup all the degenerate edges, if they were created here.
*/
for(i=0; i<num_ptedges; i++)
 {
  IGRlong rc;

  if(!EFisAncestryValid(&rc, ptedges[i], OM_Gw_current_OS, 
      OPP_EMSedge_class_id, TRUE))
   continue;

  (void) om$send(mode = OM_e_wrt_message, msg = message Root.delete(TRUE), 
         targetid = ptedges[i]);
 }

wrapup:
 /* In case of error clean up */
 if(!(1&*EMmsg&sts))
  {
   IGRlong		msg;
   GRobjid		loopid;
   struct EMSnest_info	nesting;
   IGRint		i, j, dumsts;

   dumsts = EMsplit_graceful_exit(&msg, numedsplit, edsplit, 
		num_loops_to_close, loops_to_close);
   for(i=0; i<numedsplit; i++)
     dumsts = EMsm_unsplit_common(&msg, trim_info, num_loops_to_impose, 
			edsplit[i], &to_common_edge);
   
   if(sfloops && *sfloops)
    {
     for(i=0; i<(*sfloops)->num_comps; i++)
      {
       loopid = (*sfloops)->comps[i];
       if((dumsts = om$is_objid_valid(objid = loopid)) != OM_S_SUCCESS) 
				continue;
       dumsts = om$send(msg = message EMSloop.EMset_props(&msg, EMLP_ACTIVE, 
					EMS_O_ON), targetid = loopid);
       dumsts = EMnest_loop(&msg, loopid, my_id, NULL_OBJID, &nesting, 
				partolbasis);
      }

     } /* if(sfloops) */

   /* Delete the loops created here.
   */
   for(i=0; i<num_input_loops; i++)
    for(j=0; j<num_loops_to_impose; j++)
     if(IF_EQ_OBJID(input_loops[i], loops_to_impose[j]))
      loops_to_impose[j] = NULL_OBJID;

   if(*EMmsg == EMS_E_IntersectOrient)
    {
     printf("All degenerate = %d\n", all_degenerate);
     if(all_degenerate) 
      {*EMmsg = EMS_I_InHoleTrim; sts = OM_S_SUCCESS;in_hole=TRUE;}
    }

   if(out_loops)
    {
     for(i=0; i<num_input_loops; i++)
      for(j=0; j<*num_output_loops; j++)
       if(IF_EQ_OBJID(input_loops[i], (*output_loops)[j]))
        (*output_loops)[j] = NULL_OBJID;

     for(i=0; i<*num_output_loops; i++)   
      dumsts = om$send(msg = message Root.delete(TRUE), 
		targetid = (*output_loops)[i]);
     *num_output_loops = 0;
     if(*output_loops) om$dealloc(ptr = *output_loops);
     *output_loops = NULL;
    }

   for(i=0; i<num_input_loops; i++)
    for(j=0; j<num_loops_to_close; j++)
     if(IF_EQ_OBJID(input_loops[i], loops_to_close[j]))
      loops_to_close[j] = NULL_OBJID;

   /* Ignore errors during delete */

   for(i=0; i<num_loops_to_impose; i++)   
    dumsts = om$send(msg = message Root.delete(TRUE), 
		targetid = loops_to_impose[i]);
   for(i=0; i<num_loops_to_close; i++)   
    dumsts = om$send(msg = message Root.delete(TRUE), 
		targetid = loops_to_close[i]);
		

  } /* if(!(1&*EMmsg&sts)) */

 if(!out_trim_info)
  {
   for(i=0;i<num_loops_to_impose;i++)
    {
     if(dealloc_flags[i])
     EMsfintedpar_free(trim_info[i],2);
    }
  }

 if(lp_bdrys)
  {
   struct EMSsfintedpar		*this;
   this = lp_bdrys;
   while(this)
    {
     if(this->info) om$dealloc(ptr = this->info);
     this->info = NULL;
     this = this->next;
    }
   EMsfintedpar_free(lp_bdrys, NULL);
   lp_bdrys = NULL;
  }

 if(ext_loops != static_ext_loops_buf)
  {
   if(ext_loops) om$dealloc(ptr = ext_loops);
   if(ele_bdrys) om$dealloc(ptr = ele_bdrys);
  }

 if(loops_to_impose != loops_to_impose_buf)
  {
   if(loops_to_impose) om$dealloc(ptr = loops_to_impose);
   if(trim_info) om$dealloc(ptr = trim_info);
   if(dealloc_flags) om$dealloc(ptr = dealloc_flags);
  }

 if(loops_to_close != loops_to_close_buf)
  {
   if(loops_to_close) om$dealloc(ptr = loops_to_close);
   if(nested_p_flags) om$dealloc(ptr = nested_p_flags);
   if(degn_flags) om$dealloc(ptr = degn_flags);
   if(was_ptlp) om$dealloc(ptr = was_ptlp);
  }

 if(features) om$dealloc(ptr = features);
 if(edsplit && (edsplit != edsplit_buf)) om$dealloc(ptr = edsplit);

 if (options & EMImpBnd_WantStatMsg)
  {
   if(!(1&*EMmsg&sts)) ex$message(msgnumb = EMS_S_ClearStatusField)
   else ex$message(msgnumb = EMS_S_Done)
  }
     
 if(surface) om$dealloc(ptr = surface);
 if(ptedges) om$dealloc(ptr = ptedges);

/* Convey the info as to whether the input boundaries were intersecting this
   loopset, were completely in area/hole or were coincedent with this
   loopset. By 'intersection' only the 'cutting intersection' is
   implied.
*/
 if( (1&*EMmsg&sts) && (*EMmsg != EMS_I_NoIntersection) )
  {
   if(in_area) *EMmsg = EMS_I_InAreaTrim;
   else if(in_hole) *EMmsg = EMS_I_InHoleTrim;
   else if(intersect) *EMmsg = EMS_I_IntersectTrim;
   else if(coincedent) *EMmsg = EMS_I_CoincedentTrim;
  }

 EMWRAPUP(*EMmsg,sts,"In EMSloopset.EMsplityourself");
 return(sts);   
}




/* Send unsplit message to the common edge, only if it is a seam and the
   common edge id is not in the trim_info list.
*/
static IGRint EMsm_unsplit_common(EMmsg, trim_info, num_trim_info, edgeid, 
				  to_common_edge)
IGRlong			*EMmsg;
struct EMSsfintedpar	**trim_info;
IGRint			num_trim_info;
GRobjid			edgeid;
OM_S_CHANSELECT		*to_common_edge;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRushort	props = NULL;
 IGRint			i;
 OMuint                 count = 0;
 OM_S_OBJECT_LINKAGE	junk;
 GRobjid		comm_id = NULL_OBJID;

 *EMmsg = EMS_S_Success;

 if(IF_NULL_OBJID(edgeid) || (!EFisAncestryValid(EMmsg, edgeid, 
    OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)))
  goto wrapup;

 sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &props), 
				targetid = edgeid, senderid = edgeid);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

 if( !(props & EMED_SEAM)) goto wrapup;

 sts = om$get_channel_objects(objid = edgeid, p_chanselect = to_common_edge, 
				list = &junk, size = 1, count = &count);
 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

 if(count) comm_id = junk.S_objid;
 else goto wrapup;

 for(i=0; i<num_trim_info; i++)
  {
    if(IF_EQ_OBJID(trim_info[i]->edgeid, comm_id)) goto wrapup;
    if(trim_info[i]->next && IF_EQ_OBJID(trim_info[i]->next->edgeid, comm_id))
	goto wrapup;
  }

 sts = om$send(msg = message EMSedge.EMunsplityourself(EMmsg, NULL), 
			targetid = comm_id, senderid = comm_id);

wrapup:
return(sts);
}





static IGRint EMfix_dangling(EMmsg, trim_info, env, loopid, loopsetid, 
			     surface, partolbasis, atstart)
IGRlong	*EMmsg;
struct EMSsfintedpar *trim_info;
struct GRmd_env *env;
GRobjid loopid, loopsetid;
struct IGRbsp_surface **surface;
struct EMSpartolbasis *partolbasis;
IGRboolean atstart;
{
 IGRlong		sts, rc;
 GRobjid		surfid = NULL_OBJID;
 struct IGRbsp_surface  *loc_surface = NULL;
 IGRdouble		tol, uvpts[2][2], xyzpts[2][3];
 IGRlong		num_bytes;
 IGRdouble		dist;

 if(!(*surface))
  {
   sts = om$send(msg = message EMSloopset.EMgetsurface_info(EMmsg, &surfid, 
			NULL), targetid = loopsetid, senderid = loopsetid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
   if(IF_NULL_OBJID(surfid)) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
	
   sts = om$send(msg = message EMSsubbs.GRgetsize(EMmsg, 
                &env->md_env.matrix_type, env->md_env.matrix, &num_bytes),
               senderid = surfid, targetid = surfid);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_Fail,wrapup);
   loc_surface = (struct IGRbsp_surface *) om$malloc(size = num_bytes);
   EMerr_hndlr(!loc_surface,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

  /* Get the surface geometry.
  */
   sts = om$send(msg = message EMSsubbs.GRgetgeom(EMmsg, 
                &env->md_env.matrix_type, env->md_env.matrix, 
                (IGRchar *) loc_surface),
               senderid = surfid, targetid = surfid);
   if (!(1 & sts)) goto wrapup;
  }
 else loc_surface = (struct IGRbsp_surface *) *surface; 

 /* A bdrys within cht tol in model space from the nearest edge will be
    considered ok and fixed.
 */
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, tol);
 sts = om$send(msg = message EMSloop.EMendpts(EMmsg, 
		atstart ? uvpts[0] : NULL, atstart ? NULL : uvpts[0], 
		NULL, NULL), 
		targetid = loopid, senderid = loopid);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

 if(trim_info && IF_NULL_OBJID(trim_info->edgeid))
  {
   struct EMSptloc_info	loc;
   loc.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_LS_INFINITE |
                 EMS_PTLOC_CLOSEST_EDGE;
   sts = om$send(msg = message EMSloopset.EMpt_location(EMmsg, 
		uvpts[0], &loc, partolbasis), 
		targetid = loopsetid, senderid = loopsetid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
   if (loc.location == EMS_L_INHOLE || loc.location == EMS_L_INAREA)
    {
     OM_BLOCK_MOVE (loc.edge[0].nst_pt.proj_pt, uvpts[1],
     			2 * sizeof (IGRdouble));
     BSsfeval(loc_surface, uvpts[0][0], uvpts[0][1], 0, (IGRpoint *)xyzpts[0], &rc);
     EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSsfeval(loc_surface, uvpts[1][0], uvpts[1][1], 0, (IGRpoint *)xyzpts[1], &rc);
     dist = BSdistptpt (&rc, xyzpts[0], xyzpts[1]);

     if(dist <= tol)
      {
       GRobjid	edgeid = NULL_OBJID;
       IGRint	extnd_loc = UNKNOWN;
       struct GRid junk;

       sts = om$send(msg = message EMSloop.EMnext_edge
		(EMmsg, atstart ? EMGetEd_First : EMGetEd_Last, 
		 NULL, &edgeid), targetid = loopid, senderid = loopid);
       if(1&*EMmsg&sts)
        {
	 /* The extnd_loc variable was being set by looking at the begin/end
	    of the input loop. Since the edge to be extended can be reversed, 
	    this causes problems. The extension location is to be wrt the
	    actual geometry of the edge.
	    SM 5/5/93.
	 */
	 extnd_loc = /*atstart ? BEGIN : END;*/ UNKNOWN;
	
	 junk.objid = surfid;
	 junk.osnum = OM_Gw_current_OS;
	 sts = om$send(msg = message EMSedge.EMextend_geom(EMmsg, 
			uvpts[1], &extnd_loc, FALSE, NULL, NULL, 
			NULL, partolbasis, NULL, &junk, loc_surface, 
			env->md_env.matrix, &env->md_env.matrix_type), 
		targetid = edgeid, senderid = edgeid);
	 if(!(1&*EMmsg&sts))
	  {
	   *EMmsg = EMS_S_Success; 
	   sts = OM_S_SUCCESS;
	  }
        }
       loc.location = EMS_L_ONEDGE;
      }

    }

   /* If ok fix, else return the bad uv point in the structure */

   if (loc.location == EMS_L_ONEDGE || loc.location == EMS_L_ONVRTX)
    {
     trim_info->intloc = loc.edge[0].nst_pt.location;
     trim_info->edgeid = loc.edge[0].edge_id;
     trim_info->edgepar = loc.edge[0].nst_pt.param;
     OM_BLOCK_MOVE (loc.edge[0].nst_pt.proj_pt, trim_info->point,
     			2 * sizeof (IGRdouble));
    }
   else OM_BLOCK_MOVE(uvpts[0], trim_info->point, 2 * sizeof(IGRdouble));

  }

wrapup:
 /* method will deallocate memory */
 *surface = (struct IGRbsp_surface *) loc_surface;

 if(!(1&*EMmsg&sts) || IF_NULL_OBJID(trim_info->edgeid))
   *EMmsg = EMS_I_NoSolution;
 return(OM_S_SUCCESS);		

}

/*
History
	DLB	9/23/91		Modified trim_info->info check of next
				ptr to first see if next is not NULL. 
				This causes a crash on the SUN.
*/

static IGRboolean EMmark_multiple_splits(trim_info, 
				num_trim_info, split_once, multi_split)
struct EMSsfintedpar **trim_info;
IGRint num_trim_info;
IGRchar *split_once, *multi_split;
{
 IGRint			i, j;
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_comm;

 for(i=0; i<num_trim_info; i++)
 {
		            /*DLB added check for NULL ptr. -SUN */
   if(trim_info[i]->info || !trim_info[i]->next || trim_info[i]->next->info)
    return(FALSE);
 }

 for(i=0; i<num_trim_info; i++)
  {
   for(j=0; j<num_trim_info; j++)
    {
     if( (trim_info[i] != trim_info[j]) && 
	IF_EQ_OBJID(trim_info[i]->edgeid, trim_info[j]->edgeid))
	trim_info[i]->info = trim_info[j]->info = multi_split;
	
     if( (trim_info[i]->next != trim_info[j]) && 
        IF_EQ_OBJID(trim_info[i]->next->edgeid, trim_info[j]->edgeid))
	trim_info[i]->next->info = trim_info[j]->info = multi_split;
	
     if( (trim_info[i] != trim_info[j]->next) && 
	IF_EQ_OBJID(trim_info[i]->edgeid, trim_info[j]->next->edgeid))
	trim_info[i]->info = trim_info[j]->next->info = multi_split;

     if( (trim_info[i]->next != trim_info[j]->next) && 
	IF_EQ_OBJID(trim_info[i]->next->edgeid, trim_info[j]->next->edgeid))
	trim_info[i]->next->info = trim_info[j]->next->info = multi_split;
    }
  }

 sts = EMmake_chanselect (EMSedge_to_common_edge, &to_comm);
			
 for(i=0; i<num_trim_info; i++)
  {
   OMuint	count = 0;
   if(!trim_info[i]->info && !IF_NULL_OBJID(trim_info[i]->edgeid))
    {
     sts = om$get_channel_count(objid = trim_info[i]->edgeid, count = &count, 
			p_chanselect = &to_comm);
     if(count || !(1&sts))
      trim_info[i]->info = multi_split;
     else trim_info[i]->info = split_once;
    }
   if(!trim_info[i]->next) continue;

   if(!trim_info[i]->next->info && !IF_NULL_OBJID(trim_info[i]->next->edgeid))
    {
     if(!IF_EQ_OBJID(trim_info[i]->edgeid, trim_info[i]->next->edgeid))
      {
       count = 0;
       sts = om$get_channel_count(objid = trim_info[i]->next->edgeid, 
			p_chanselect = &to_comm, count = &count);
      }
     if(count || !(1&sts))
      trim_info[i]->next->info = multi_split;
     else trim_info[i]->next->info = split_once;
    }
   
  }

return(TRUE);
}


static void EMstore_edsplit(numedsplit, edsplit, newedsplit)
IGRint		*numedsplit;
GRobjid		*edsplit, newedsplit;
{
 IGRboolean	present = FALSE;
 IGRint		i;

 for(i=0; i<*numedsplit; i++)
  {
   if(IF_EQ_OBJID(edsplit[i], newedsplit))
    { present = TRUE; break;}
  }

 if(!present)
  edsplit[(*numedsplit)++] = newedsplit;

}


static IGRint	EMnest_loop(EMmsg, loopid, loopsetid, parent, nesting, 
				partolbasis)
IGRlong			*EMmsg;
GRobjid			loopid, loopsetid, parent;
struct EMSnest_info	*nesting;
struct EMSpartolbasis	*partolbasis;
{
 IGRlong		sts;

 sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg, nesting),
			targetid = loopid, senderid = loopid);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(IF_NULL_OBJID(parent))
  {
   sts = om$send(msg=message EMSloopset.EMnesting
			(EMmsg, nesting, partolbasis),
		targetid= loopsetid, senderid = loopsetid);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   nesting->parent = parent;
   if(IF_EQ_OBJID(parent, loopsetid))
    sts = om$send(msg = message EMSloopset.EMget_props
			(EMmsg, (IGRushort *)&nesting->parent_props), 
		targetid = parent, senderid = parent);
   else
    sts = om$send(msg = message EMSloop.EMget_props
			(EMmsg, (IGRushort *)&nesting->parent_props), 
		targetid = parent, senderid = parent);

   if(!(1&*EMmsg&sts)) goto wrapup;

  }

 if(IF_EQ_OBJID(nesting->parent, loopsetid))
  sts = om$send(msg=message EMSloopset.EMtreemod
			(EMmsg, nesting, ADD_CHILD, partolbasis),
			targetid = loopsetid, senderid = loopsetid);
 else
  sts = om$send(msg=message EMSloop.EMtreemod
			(EMmsg, nesting, ADD_CHILD, partolbasis),
			targetid = nesting->parent, senderid = loopsetid);

wrapup:
return(sts);
}



static IGRint	EMoverlap_processing(EMmsg, against, options, against_bdrys, 
				     lp_bdrys, loopids, num_loops, num_bdrys, 
				     buf_size, partolbasis, loopid)
IGRlong 		*EMmsg;
GRobjid 		*against;
IGRushort 	options;
struct EMSsfintedpar	***against_bdrys, ***lp_bdrys;
GRobjid			**loopids;
IGRint			*num_loops,**num_bdrys,*buf_size;
struct EMSpartolbasis	*partolbasis;
GRobjid			loopid;
{
 IGRlong			sts, rc;
 IGRushort		loc_options;
 struct EMSsfintedpar		**lsbdrys_ptr = NULL, *lsbdrys = NULL;
 struct EMSsfintedpar		**lpbdrys_ptr = NULL, *lpbdrys = NULL;
 GRobjid			lpid, *lpid_ptr;
 IGRint				numlp = 0, locnumbdrys = 0, *locnumbdrys_ptr, 
				loc_buf_size = 1, i, j;
 IGRdouble			lentol;
 extern IGRboolean		EFextract_par();
 extern struct EMSsfintedpar	*EMsfintedpar_malloc();
 struct EMSsfintedpar		*locthis_bdry, *this_bdry, *last_lp, 
				*last_ls, *locls_bdry;
 IGRboolean			include_thisbdry = FALSE, added = FALSE;
 IGRlong			savecode;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 lsbdrys_ptr = &lsbdrys;
 lpbdrys_ptr = &lpbdrys;
 lpid_ptr = &lpid;
 locnumbdrys_ptr = &locnumbdrys;
 sts = EFextract_par(BSTOLLENVEC, partolbasis->tol, &lentol, &rc);

 /* Consider two sets of boundaries -
    1) Those obtained with option BDRYISAREA
    2) Those obtained with bdry as hole.
 For every bdry in 1, which does not have a corresponding bdry in 2, introduce
 a degenerate bdry. This degenerate bdry will produce a point loop
 later.
 */

 loc_options = options;
 options &= ~EMS_INTER_BDRYISAREA;
 sts = om$send(msg=message EMSloop.EMtrimyourself
	(EMmsg, against, options, against_bdrys, lp_bdrys, loopids, 
	 num_loops, num_bdrys, buf_size, partolbasis), targetid = loopid, 
	 senderid = loopid);
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
 savecode = *EMmsg;

 if( !(loc_options & EMS_INTER_BDRYISAREA)) goto wrapup;

 options |= EMS_INTER_BDRYISAREA;
 sts = om$send(msg=message EMSloop.EMtrimyourself
	(EMmsg, against, options, &lsbdrys_ptr, &lpbdrys_ptr, &lpid_ptr, 
	 &numlp, &locnumbdrys_ptr, &loc_buf_size, partolbasis), 
	 targetid = loopid, senderid = loopid);
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);


 locthis_bdry = lpbdrys;
 locls_bdry = lsbdrys;
 for(i=0; i< 2 * locnumbdrys; i++)
  {
   include_thisbdry = TRUE;
   this_bdry = (*lp_bdrys)[0];
   for(j=0; j<2 * (*num_bdrys)[0]; j++)
    {
     if(EM2ddistptpt(locthis_bdry->point, this_bdry->point) < lentol)
      {include_thisbdry = FALSE; break;}
     if(this_bdry) this_bdry = this_bdry->next;
    }

   if(include_thisbdry)
    {
     struct EMSsfintedpar	*junk, *new_bdry;
     IGRushort		*extopt = NULL;

     last_lp = (*lp_bdrys)[0];
     for(j=0; j<2 * (*num_bdrys)[0] - 1; j++)
      last_lp = last_lp->next;

     last_ls = (*against_bdrys)[0];
     for(j=0; j<2 * (*num_bdrys)[0] - 1; j++)
      last_ls = last_ls->next;

     new_bdry = EMsfintedpar_malloc(EMmsg, 2);
     if(!(1&*EMmsg)) goto wrapup;
     junk = new_bdry->next;
     OM_BLOCK_MOVE(locthis_bdry, new_bdry, sizeof(struct EMSsfintedpar));
     new_bdry->next = junk;
     OM_BLOCK_MOVE(locthis_bdry, new_bdry->next, sizeof(struct EMSsfintedpar));
     new_bdry->next->next = NULL;
     if(last_lp) last_lp->next = new_bdry;
     else (*lp_bdrys)[0] = new_bdry;
     extopt = (IGRushort *)om$malloc(size = sizeof(IGRushort));
     if(!extopt){*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
     (*extopt) = EMLpExtrct_SinglePoint;
     new_bdry->info = (IGRchar *)extopt;

     (*num_bdrys)[0]++;

     new_bdry = EMsfintedpar_malloc(EMmsg, 2);
     if(!(1&*EMmsg)) goto wrapup;
     junk = new_bdry->next;
     OM_BLOCK_MOVE(locls_bdry, new_bdry, sizeof(struct EMSsfintedpar));
     new_bdry->next = junk;
     OM_BLOCK_MOVE(locls_bdry, new_bdry->next, sizeof(struct EMSsfintedpar));
     new_bdry->next->next = NULL;
     if(last_ls) last_ls->next = new_bdry;
     else (*against_bdrys)[0] = new_bdry;
     added = TRUE;
    }

   if(locthis_bdry) locthis_bdry = locthis_bdry->next;
   if(locls_bdry) locls_bdry = locls_bdry->next;
  }
 if(added) *EMmsg = EMS_I_IntersectTrim;
 else *EMmsg = savecode;

wrapup:
if(lsbdrys) EMsfintedpar_free(lsbdrys, NULL);
if(lpbdrys) EMsfintedpar_free(lpbdrys, NULL);

return(sts);
}




static void EMorient_cleanup(EMmsg, loop)
IGRlong	*EMmsg;
GRobjid *loop;
{
 IGRlong		sts;
 OM_S_CHANSELECT	to_edges;
 GRobjid		oldsplit[2];
 IGRushort              split;
 IGRint			i;
 OMuint                 numed       = 0;

 *EMmsg      = EMS_S_Success;
 /* Delete any previously connected split objects for the edges of this loop
    Then delete the loop.
 */
 sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

 sts = om$get_channel_count(objid = *loop, p_chanselect = &to_edges, 
			    count = &numed);
 for(i=0; i<numed; i++)			
  {
   split = NULL;
   sts = om$send(msg = message EMSedge.EMissplit(EMmsg, &split, oldsplit), 
		senderid = *loop, p_chanselect = &to_edges, from = i, to= i);
   if(split & EMSedge_BeginSplit)
    sts = om$send(msg = message Root.delete(TRUE), senderid = *loop, 
			targetid = oldsplit[0]);
   if(split & EMSedge_EndSplit)
    sts = om$send(msg = message Root.delete(TRUE), senderid = *loop, 
			targetid = oldsplit[1]);
  }
 sts = om$send(msg = message Root.delete(TRUE), senderid = *loop, 
			targetid = *loop);
 *loop = NULL_OBJID;
}


/* In case of an IntersectOrient error, this function will regenerate a point
   loop since the error indicates inability to close the point loop
   using existing topology, because of the orientations of other new loops
   on the surface. The input loopid is assumed to be point loop
   originally.
*/
static EMregenerate_point_loop(EMmsg, loopid, partolbasis, lsid, closed)
IGRlong *EMmsg;
GRobjid loopid, *lsid;
struct EMSpartolbasis *partolbasis;
IGRboolean *closed;
{
 IGRlong		sts;
 OM_S_CHANSELECT	to_edges, to_owners;
 IGRint			i;
 OMuint                 num_edges = 0;
 GRobjid		pted;
 IGRushort              props = NULL;
 extern IGRboolean      EFisAncestryValid ();
 *EMmsg = EMS_S_Success;
 sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &props), 
       targetid = loopid, senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);


 sts = om$get_channel_count(objid = loopid, p_chanselect = &to_edges, 
       count = &num_edges);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<num_edges; i++)
  {
   /* Get the point edge. Disconnect all edges except the point edge.
   */
   sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &pted), 
         senderid = loopid, p_chanselect = &to_edges, from = i, to = i);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(EFisAncestryValid(EMmsg, pted, OM_Gw_current_OS, 
      OPP_EMSptedge_class_id, TRUE))
    break;
  }
  
  sts = om$send(msg = message Root.wild_disconnect(to_edges), 
        targetid = loopid, senderid = NULL_OBJID);
  if(!(1&sts)) goto wrapup;

  sts = om$change_class(objid = loopid,  osnum = OM_Gw_current_OS, 
                        classname = "EMSptgralp", 
                        sd_override = OM_K_change_class_sd_override);
  if(!(1&sts)) goto wrapup;

  sts = om$send(msg = message Root.connect(to_owners, NULL,
	loopid, OM_Gw_current_OS, to_edges, NULL),
	targetid = pted, senderid = loopid);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);


  sts = om$send(msg = message EMSgraloop.EMglpinit(EMmsg, props, 
	partolbasis, NULL_OBJID), targetid = loopid, senderid = NULL_OBJID);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$send(msg=message EMSloop.EMcloseyourself
	(EMmsg, lsid, closed, partolbasis),
	targetid = loopid, senderid = NULL_OBJID);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);

wrapup:
return(sts);
}
end implementation EMSloopset;

