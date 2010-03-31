/* -----------------
 * FOR EMS 4.0
 * Creation : Sanjay
 * -----------------
 */

class implementation EMSsfboolean;

#include "OMmacros.h"
#include "EMSdef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsimpdef.h"
#include "addrmopts.h"
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
%endsafe

#define    KEEP_TRACE_GROUP              0x01
#define    DELETE_TRACE_GROUP            0x02
#define    STOP_AFTER_PROCESSING_FIRST   0x04

#argsused

IGRlong EFaddrm_modify_trace_groups(
	EFmsg, 
	options,
        cons_list,
	md_env,
	inters1, 
	inters2, 
	tracedata1,
	tracedata2,
	num_sort_pts,
	sort_pts,
        num_bad_pts,
        bad_pts,
        check_present,
        keep_grps1,
        keep_grps2)
IGRlong			*EFmsg;
IGRushort		options;
struct GRvg_construct	*cons_list;
struct EMSinters	**inters1, **inters2;
struct GRmd_env     	*md_env;
struct EMSsftracedata	*tracedata1, *tracedata2;
IGRint			*num_sort_pts, *num_bad_pts;
struct EMparms	        *sort_pts, **bad_pts;
IGRlong                 check_present;
IGRboolean              *keep_grps1, *keep_grps2;
{
extern void		EMsfintedpar_free(), EMinters_data_free();
extern void		EMinters_free();

IGRlong			msg, sts, i, j, k, l, m;
struct GRid		check_surface,this_surface,*orig_intobjs,*cp_intobjs;
IGRboolean		check_this_srf, *trace_group_keep1, *trace_group_keep2; 
IGRboolean		error_condition=FALSE;
IGRint			num_trace_groups1=0,num_trace_groups2=0;
IGRint			count=0, num_intobjs;
IGRboolean		*trace_group_keep, *other_trace_group_keep;
struct EMSinters	*inters = NULL, *cp_inters = NULL;
struct EMSintobj	*intobj = NULL;
struct EMSsftracedata	*tracedata = NULL, *other_tracedata = NULL;
OM_S_CHANSELECT		to_edges, to_loops, to_loopset;
OM_S_OBJECT_LINKAGE	*edges = NULL, *loop_objects = NULL, loopset_obj;
struct GRid             cp_loopset;
struct EMcp_info	cp_info; /*NEEDED??*/
IGRint			loc_num_bad_pts;

/* Variables needed to copy the surface loopset and maintain correspondence 
 * between the edges of the two loopsets. Also, variables needed for 
 * duplicating the inters node.
 */
struct GRid		*orig_edges = NULL, *cp_edges = NULL;
IGRint			num_orig_edges=0, num_cp_edges=0;
IGRint			orig_ed_array_size=0, cp_ed_array_size=0;
struct EMSsfintedpar	*sfintedpar = NULL;
IGRboolean		edge_found=FALSE;
struct EMSinters	*inters_next=NULL;

/* Variables needed for tracing intersections on a surface */
IGRint 			num_grps=0, *num_subgrps_grp = NULL, **num_elems_subgrp = NULL;
struct EMSintobj 	***elems = NULL;
IGRboolean 		**subgrp_rev = NULL, ***elem_rev = NULL, *grp_closed = NULL;
IGRboolean 		**subgrp_closed, sfinttrace_alloced=FALSE;
IGRdouble		xyztracetol, chttol;
 
/* Variables needed to create surface loops out of the intersections */
GRobjid 		**loop_sf=NULL, **endedges=NULL;
struct EMSsfintedpar 	***intparms=NULL;
IGRdouble 		**sfpartolb = NULL;
IGRboolean		sfintloops_alloced=FALSE;

/* Variables needed for splitting the loopset */
IGRint			num_trim_loops=0, max_loops=0;
GRobjid			*loop_ids = NULL;
struct EMSsfintedpar	**trim_info=NULL;
struct EMSpartolbasis	partolbasis;

/* Variables needed for identifying loops to keep of split loopset */
struct EMSptloc_info 	pt_loc;
IGRdouble		sort_pt_uv[2];
IGRint			num_sort_loops=0;
GRobjid			*sort_loops = NULL;
IGRboolean		bad_location=FALSE, redundant_pt=FALSE;

/* Variables needed to identify former intobjs present in resulting loops */
struct GRid		*edges_in_sort_loops = NULL;
IGRint			ed_array_size=0, num_edges_in_sort_loops=0;
IGRint			grp_num = -MAXINT;
struct EMSintobj	*intobj_loc=NULL ;

/* Variables needed for deleting unwanted trace groups */
struct EMSintobj	*intobj_del=NULL;

/* Variables needed for cleaning up the inters list */
struct EMSinters	**inters_ptr=NULL;

/*general variables */
IGRboolean              sort_point_mode, bit_mode, single_operand_mode;
IGRboolean              loop_stored, found_intobj = FALSE;
OMuint                  num_edge_objects, num_loop_objects, lp_count, ed_count;

  *EFmsg = EMS_S_Success;
  msg    = EMS_S_Success;
  sts    = OM_S_SUCCESS;

  edges = NULL;

  /* VALIDATION OF INPUT */
  if( !inters1 || !tracedata1 || !md_env )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFaddrm_modify_trace_groups : Invalid Arguments",
          action = GOTO_VALUE, value = ret_end );   

  sort_point_mode = FALSE;
  bit_mode = FALSE;
  single_operand_mode = FALSE;

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

  if( num_sort_pts && *num_sort_pts && sort_pts )
  {
      single_operand_mode = ((tracedata1 && tracedata2) ? FALSE : TRUE);
      sort_point_mode = TRUE;
  }
  else if( check_present )
  {
      single_operand_mode = ((tracedata1 && tracedata2) ? FALSE : TRUE);
      bit_mode = TRUE;
  }
  else if( keep_grps1 || keep_grps2 )
  {
      single_operand_mode = ((keep_grps1 && keep_grps2) ? FALSE : TRUE);
      trace_group_keep1 = keep_grps1;
      trace_group_keep2 = keep_grps2;
      goto  MARK_FOR_DELETION;
  }
  else
  {
     add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
         str = "EFaddrm_modify_trace_groups : Invalid Arguments",
         action = GOTO_VALUE, value = ret_end );   
  }

  if( sort_point_mode )
  {
      loc_num_bad_pts = 0; /* assume all points are GOOD at start.*/

      if( num_bad_pts )
         *num_bad_pts = 0; 

      /* No sort pts ==> keep all trace groups => regular boolean */
      if(! *num_sort_pts)
          goto ret_end;
  }

  /*initialize*/
  orig_edges = NULL;
  cp_edges   = NULL;

  /* 
   * Set up arrays to indicate if a trace group is to be kept or not. 
   */
  num_trace_groups1 = tracedata1->num_grps;
  num_trace_groups2 = single_operand_mode? 0 : tracedata2->num_grps;
  trace_group_keep1 = (IGRboolean *) alloca ( num_trace_groups1 * 
                                              sizeof (IGRboolean) );
  trace_group_keep2 = single_operand_mode? NULL : ((IGRboolean *) alloca 
                      ( num_trace_groups2 * sizeof (IGRboolean) ));

  /* 
   * Mark ALL trace groups as NOT TO BE kept, if options is KEEP_TRACE_GROUP 
   * otherwise TO BE kept. As this algorithm progresses, we will mark those 
   * trace groups TO BE / NOT TO BE kept, as are needed for the selective 
   * boolean
   */
  for( i=0; i<num_trace_groups1; i++ ) 
  {
     if( options & KEEP_TRACE_GROUP ) 
     {
         if( keep_grps1 && keep_grps1[i] )
            trace_group_keep1[i] = TRUE;
         else
            trace_group_keep1[i] = FALSE;  
     }
     else if( options & DELETE_TRACE_GROUP )
     {
         if( keep_grps1 && keep_grps1[i] )
            trace_group_keep1[i] = FALSE;
         else  
            trace_group_keep1[i] = TRUE;
     }
  }

  
  if( !single_operand_mode )
  { 
      for( i=0; i<num_trace_groups2; i++ ) 
      {
         if( options & KEEP_TRACE_GROUP )
         {
             if( keep_grps2 && keep_grps2[i] )
                trace_group_keep2[i] = TRUE;
             else
                 trace_group_keep2[i] = FALSE;
         }
         else if( options & DELETE_TRACE_GROUP )
         {
             if( keep_grps2 && keep_grps2[i] )
                trace_group_keep2[i] = FALSE;
             else
                 trace_group_keep2[i] = TRUE;
         }
      }
  }

  error_condition = FALSE;

  for(i=0; i<2; i++) /* check both inters lists 
                                           (i==0? inters1 : inters2) */
  {  
    inters = (i==0? *inters1 : (single_operand_mode? NULL: *inters2)); 
    tracedata = (i==0? tracedata1 : (single_operand_mode? NULL:tracedata2)); 
    other_tracedata = (i==0?(single_operand_mode? NULL:tracedata2):tracedata1); 
    trace_group_keep = (i==0? trace_group_keep1 : 
                            (single_operand_mode? NULL :trace_group_keep2));
    other_trace_group_keep = (i==0? (single_operand_mode? NULL :
                                     trace_group_keep2) : trace_group_keep1);

    /* 
     * If in single operand mode, code in this while loop will not be executed 
     * for i==1. Therefore, checks for validity of tracedata, trace_group_keep 
     * etc * (i.e.checks to see if they are NON-NULL) are minimal inside the 
     * while loop, except for "other_tracedata" and "other_trace_group_keep".
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
      cp_inters                 = NULL;
      orig_edges          	= NULL;
      cp_edges            	= NULL;
      orig_intobjs		= NULL;
      cp_intobjs		= NULL;
      loop_ids			= NULL; 
      trim_info			= NULL;
      edges_in_sort_loops	= NULL; /* mem alloced by EMget_edges */
      loop_objects              = NULL;

      /* Important. Needed if loopset of this surface is to be copied */
      cp_info.num_entries         = 0;
      cp_info.array_size          = 0;
      cp_info.objid_array         = NULL;

      /* other misc. initializations */
      num_sort_loops              = 0;

      if( sort_point_mode )
      {
         /* check only surfaces that have points placed on them */
         check_this_srf=FALSE; /* assume */
         for (j=0; j<*num_sort_pts; j++)   
         { 
           check_surface.objid = sort_pts[j].leaf_id.objid;
           check_surface.osnum = sort_pts[j].leaf_id.osnum;
            
           if ( (check_surface.objid == this_surface.objid) &&
                (check_surface.osnum == this_surface.osnum)     )
           {  
              check_this_srf = TRUE;
              break;
           }
         }/*for*/
         
         if (!check_this_srf)
            goto while_end; /* move on to next surface */
      }
      else
      {
         /* trivially mark those trace groups with intobjs having the correct
          * bitmask. This is for the non-sort_point_mode only.
          */
         intobj_loc = inters->cvs;
         while (intobj_loc)
         {
            if( intobj_loc->props&check_present ) 
            {
               EFget_trace_group_from_intobj(&msg, intobj_loc,tracedata,
                                             &grp_num);
               add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
                   str = "EFaddrm_modify_trace_groups : EFget_trace_group_from_intobj",
                   action = GOTO_VALUE, value = while_end );

               if( options & KEEP_TRACE_GROUP )
                   trace_group_keep[grp_num] = TRUE;
               else if( options & DELETE_TRACE_GROUP )
                   trace_group_keep[grp_num] = FALSE;
  
               if (!single_operand_mode)
               { 
                 EFget_trace_group_from_intobj (&msg, 
                                                intobj_loc->other_intobj_node,
                                                other_tracedata, &grp_num);
                 add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
                   str = "EFaddrm_modify_trace_groups : EFget_trace_group_from_intobj",
                   action = GOTO_VALUE, value = while_end );

                 if( options & KEEP_TRACE_GROUP )
                     other_trace_group_keep[grp_num] = TRUE;
                 else if( options & DELETE_TRACE_GROUP )
                     other_trace_group_keep[grp_num] = FALSE;
               }
            }
            intobj_loc = intobj_loc->next;
         }
      }
   
      /* 
       * If ALL intobjs on this surface belong to trace groups ALREADY marked 
       * to be kept, do not check this surface.
       */
      check_this_srf = FALSE; /* assume */
      EFcheck_inters_trace_groups( &msg, options,inters, tracedata, 
                                   trace_group_keep, &check_this_srf);
      add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFaddrm_modify_trace_groups : EFcheck_inters_trace_groups error",
          action = GOTO_VALUE, value = while_end );   

      if( !check_this_srf )
         goto while_end; /* move on to next surface */

      /* 
       * At this stage we know that the current "inters" node has trace groups 
       * on it that are not yet classified as "to keep".  This means we MUST  
       * check this surface. 
       */

      /* STEP 3a: Create a copy of the surface loopset in the same OS*/
      /***************************************************************/

      sts = om$get_channel_objects (objid = inters->this_obj.objid,
    				    osnum = inters->this_obj.osnum,
				    p_chanselect = &to_loopset,
				    list = &loopset_obj,
				    size = 1,
				    count = (OMuint *)&count);
      add$status( test = !(sts&1), msg = *EFmsg, code = EMS_E_OMerror,
          str = "EFaddrm_modify_trace_groups : om$get_channel_objects error",
          action = GOTO_VALUE, value = while_end );   

      cp_loopset.osnum = inters->this_obj.osnum; /* SAME os as surface */

      if (!count)/*create a natural loopset if surface doesnt have a loopset */
      {  
         /* 
          * We have an inters list on a surface that has NO boundary? Something
          * smells bad here. Error out...
          */
         add$status( test = TRUE, msg = *EFmsg, code = EMS_E_SurfaceError,
          str = "EFaddrm_modify_trace_groups : Inters list on surface that has NO boundary",
          action = GOTO_VALUE, value = while_end );   
      }

      /* initializations to "cp_info" done at start of "while" loop */
      sts = om$send (msg=message EMSboundary.EMintcopy (&msg, NULL, 
                             inters->this_obj.osnum, inters->this_obj.osnum,
                             NULL, &(cp_loopset.objid), &cp_info),
		   senderid = NULL_OBJID,
		   targetid = loopset_obj.S_objid,
		   targetos = loopset_obj.osnum);
      add$status( test = !(1&sts&msg), msg = *EFmsg, code = EMS_E_LoopsetError,
          str = "EFaddrm_modify_trace_groups : EMintcopy error",
          action = GOTO_VALUE, value = while_end );   

      /* STEP 3b: Create a correspondence of edges in the two loopsets */
      /*****************************************************************/
  
      /* get all edges of the original loopset */ 
      orig_ed_array_size=0;
      num_orig_edges=0;
      sts = om$send( msg = message EMSboundary.EMget_edges ( &msg, MAXINT, 
                                   EMS_OPT_ALL,
				   &orig_edges, &orig_ed_array_size, 
				   &num_orig_edges),
                     senderid = NULL_OBJID,
		     targetid = loopset_obj.S_objid,
		     targetos = loopset_obj.osnum);
      add$status( test = !(1&sts&msg), msg = *EFmsg, code = EMS_E_LoopsetError,
          str = "EFaddrm_modify_trace_groups : EMget_edges error",
          action = GOTO_VALUE, value = while_end );   

      /* get all edges of the copied loopset */ 
      cp_ed_array_size=0;
      num_cp_edges=0;
      sts = om$send( msg = message EMSboundary.EMget_edges ( &msg, MAXINT, 
                                   EMS_OPT_ALL,
                                   &cp_edges, &cp_ed_array_size, 
				   &num_cp_edges),
	             senderid = NULL_OBJID,
		     targetid = cp_loopset.objid,
		     targetos = cp_loopset.osnum); 
      add$status( test = !(1&sts&msg), msg = *EFmsg, code = EMS_E_LoopsetError,
          str = "EFaddrm_modify_trace_groups : EMget_edges error",
          action = GOTO_VALUE, value = while_end );   

      add$status( test = num_orig_edges != num_cp_edges, msg = *EFmsg, 
          code = EMS_E_LoopsetError,
          str = "EFaddrm_modify_trace_groups : original edges are not equal to copied edges error",
          action = GOTO_VALUE, value = while_end );   


      /*
       * store the inters_next pointer and also the sfintedpar structures 
       * and the edges will be replaced by the edges in the copied loopset
       * as the copied loop set will be split with the edges sfintedpar 
       * structure information.
       */
      inters_next     = inters->next; /* save */
      inters->next    = NULL;
      
      sts =  EMdupinters(&msg, &inters, &cp_inters, TRUE, FALSE, &this_surface,
              NULL, FALSE, md_env, cons_list, NULL, NULL, 0, NULL, NULL, 0);
      add$status( test = !(1&sts&msg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFaddrm_modify_trace_groups : EMget_edges error",
          action = GOTO_VALUE, value = while_end );   

      inters->next    = inters_next; /* reset */
      cp_inters->next = NULL; /* make sure, just in case */

      /* Update the sfintedpar edgeids in the copied inters node to reflect the
       * edge ids in the copied loopset.
       */
      intobj_loc = cp_inters->cvs;
      
      for (j=0; j<cp_inters->num_cvs; j++)
      {  
        /* 
         * for both edges in sfintedpars of every intobj, get the index of 
         * edge ids in the original edge array and use it to get the edge id
         * of the copy edge. Replace the orig. edge id with the copy edge id.
         */
        for (k=0; k<2; k++)
        {
          sfintedpar = (k==0 ? (struct EMSsfintedpar *)(intobj_loc->more_info):
            ((intobj_loc->more_info) ? 
             ((struct EMSsfintedpar *)(intobj_loc->more_info))->next : NULL));
          
          if( sfintedpar && (sfintedpar->edgeid != NULL_OBJID) ) 
          { 
            edge_found = FALSE;
            for (l=0; l<num_orig_edges; l++)
            {  
               if (sfintedpar->edgeid == orig_edges[l].objid)
               {  
                  /* replace edgeid in intobj with the id of the edge's copy */
                  sfintedpar->edgeid = cp_edges[l].objid;
                  edge_found = TRUE;
                  break;
               }
            }
            add$status( test = !edge_found, msg = *EFmsg, code = EMS_E_Fail,
                str = "EFaddrm_modify_trace_groups : edge not found",
                action = GOTO_VALUE, value = while_end );   
          }
        }
        intobj_loc = intobj_loc->next;
     }

     

     /* STEP 5: 
             Create a correspondence array of edges between the inters lists */
     /************************************************************************/

     /* 
      * make this more efficient later by changing om$malloc to alloca
      * if necessary.
      */
     orig_intobjs = (struct GRid *) om$malloc ( size = (inters->num_cvs) *  
                                                       sizeof (struct GRid)) ;
     add$status( test = !orig_intobjs,msg = *EFmsg,code = EMS_E_NoDynamicMemory,
         str = "EFaddrm_modify_trace_groups : Insufficient Memory",
         action = GOTO_VALUE, value = while_end );   

     cp_intobjs   = (struct GRid *) om$malloc ( size = (inters->num_cvs) *
                                                       sizeof (struct GRid)) ;
     add$status( test = !cp_intobjs,msg = *EFmsg,code = EMS_E_NoDynamicMemory,
         str = "EFaddrm_modify_trace_groups : Insufficient Memory",
         action = GOTO_VALUE, value = while_end );   

     /* create original inters' intobjs edges array */
     intobj = inters->cvs; /* "pts" do not figure in sf-sf intersections */
     num_intobjs = inters->num_cvs;
     for (j=0; j<num_intobjs; j++)
     {  
        orig_intobjs[j] = *(intobj->this_uvintobj.data.object);
        intobj = intobj->next;
     }

     /* create copy inters' intobjs edges array */
     intobj = cp_inters->cvs; /* "pts" do not figure in sf-sf intersections */
     num_intobjs = cp_inters->num_cvs; /* same number as above */
     for (j=0; j<num_intobjs; j++)
     {  
        cp_intobjs[j] = *(intobj->this_uvintobj.data.object);
        intobj = intobj->next;
     }

     /* STEP 6: Run a trace on the originalintobjs in the copied loopset */
     /********************************************************************/

     /* Get the tolerance for tracing */
     /* DO WE REALLY NEED ALTXYZTOL????*/

     BSEXTRACTPAR (&msg, BSTOLLENVEC, xyztracetol);
     BSEXTRACTPAR (&msg, BSTOLCHRDHT, chttol);

     /* j==0 is regular trace.
      * j==1 is re-trace with larger tolerance.
      */
     for (j=0; j<2; j++) /* Retry second time on failure first time */
     {  
       if (j==1)
         xyztracetol = chttol * 2.0; /* larger tolerance for double check */ 

       ems$sfinttrace (
                  msg              = &msg,
                  matrixtype       = &(md_env->md_env.matrix_type),
                  matrix           = md_env->md_env.matrix,
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
            add$status( test = EMSerror (msg), msg = *EFmsg, code = msg,
                str = "EFaddrm_modify_trace_groups : ems$sfinttrace error",
                action = GOTO_VALUE, value = while_end );   
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
     sts = EMsfintloops( &msg, &(md_env->md_env.matrix_type), 
                         md_env->md_env.matrix, 
                         cp_inters->cvs->this_uvintobj.data.object->osnum, 
                         NULL, num_grps, num_subgrps_grp, num_elems_subgrp,
                         elems, subgrp_rev, elem_rev, grp_closed, subgrp_closed,
                         FALSE, FALSE, &loop_sf, &endedges, &intparms, 
                         &sfpartolb);
     sfintloops_alloced = TRUE;
     add$status( test = !(sts&msg&1), msg = *EFmsg, code = EMS_E_LoopError,
         str = "EFaddrm_modify_trace_groups : EMsfintloops error",
         action = GOTO_VALUE, value = while_end );   

     /* create an array of loop ids for input to "splityourself" */
     max_loops = 0; 
     for (j=0; j<num_grps; j++)
       for (k=0; k<num_subgrps_grp[j]; k++) 
            max_loops++;

     /* allocate array for maximum number of loops */
     loop_ids = (GRobjid *) om$malloc (size = max_loops * sizeof (GRobjid));
     add$status( test = !loop_ids,msg = *EFmsg,code = EMS_E_NoDynamicMemory,
         str = "EFaddrm_modify_trace_groups : Insufficient Memory",
         action = GOTO_VALUE, value = while_end );   

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
      *                 refer to incidence edge info at the ends of the loop "i"
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
      * ------ a valid "trim_info", by that I mean, either closed loops or
      *        loops that have their endpts lying on existing boundary. This
      *        check is necessary because while creating intersections on rib
      *        feature surfaces, we split intobjs against each other and connect
      *        them up in specific ways, so that there might be dangling
      *        (i.e. subgroups with a free end) subgroups formed during tracing.
      *         These subgroups do not split area and as such do not warrant 
      *         inclusion in the "loop_ids" array.     NP (7/28/93).
      */

     /* 
      * allocate size for max. number of loops. We use only the loops with
      * valid trim info.
      */
     trim_info = (struct EMSsfintedpar **) om$malloc 
                    ( size = max_loops * sizeof (struct EMSsfintedpar *) );
     add$status( test = !trim_info,msg = *EFmsg,code = EMS_E_NoDynamicMemory,
         str = "EFaddrm_modify_trace_groups : Insufficient Memory",
         action = GOTO_VALUE, value = while_end );   


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
         add$status( test = !trim_info[num_trim_loops], msg = *EFmsg,
             code = EMS_E_NoDynamicMemory,
             str = "EFaddrm_modify_trace_groups : Insufficient Memory",
             action = GOTO_VALUE, value = while_end );   

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
   
     /* STEP 8: Split the copied loopset using the intersection list */
     /****************************************************************/

     /* 
      * Get the basis tolerance from this surface and use it in the 
      * method below. This is because the cp loopset is not connected to this
      * surface and therefore the  "EMsplityourself" method may not be able to 
      * get it.
      */
     sts = om$send(msg = message EMSsubbs.EMpartolbasis ( &msg,
                    &(md_env->md_env.matrix_type), md_env->md_env.matrix,
                    FALSE /*not used*/, TRUE/*OR FALSE??*/, &(partolbasis.tol)),
                  targetid = this_surface.objid,
                  targetos = this_surface.osnum,
                  senderid = NULL_OBJID);
     add$status( test = !(sts&msg&1), msg = *EFmsg, code = EMS_E_SurfaceError,
         str = "EFaddrm_modify_trace_groups : EMpartolbasis error",
         action = GOTO_VALUE, value = while_end );   

     partolbasis.is_valid = TRUE; 
     partolbasis.in_world = FALSE; 
     partolbasis.mattyp   = &(md_env->md_env.matrix_type);
     partolbasis.mat      = md_env->md_env.matrix;

     /* The loop_ids that we are passing in HAVE their trim info available and 
      * hence we do not want "EMsplityourself" to do any trimming of input
      * loops. Therefore no trimming options are passed into the method such as
      * "EMImpBnd_BdryIsArea". Coincident intobjs are assumed to be taken care 
      * of during "EMintersect_surfaces", so that they are properly split/pushed
      * across common edges as necessary. In short, any loop that lies along
      * the boundary (i.e. a loop that was formerly a coincident intobj) of the 
      * cp_loopset , is also assumed to have valid trim info.
      * ( If trimming HAD to be done within "EMsplityourself", then we would 
      *   have had to modify "EMsplityourself" with a new option so that 
      *   "overlap_processing was NOT done and trimming WAS done with the 
      *   "EMImpBnd_BdryIsArea" option, for the purpose of taking care of 
      *   coincidence. All this is not required, however).
      */
    
     sts = om$send( msg = message EMSloopset.EMsplityourself(
                           &msg, loop_ids, num_trim_loops, trim_info,
                           NULL, NULL, NULL, NULL,
                           EMImpBnd_NoInputDelete | EMImpBnd_CloseRegular |
                           EMImpBnd_DelInvalidLoops,
                           NULL, NULL, &partolbasis, md_env),
                    targetid = cp_loopset.objid,
                    targetos = cp_loopset.osnum,
                    senderid = NULL_OBJID);
     add$status( test = !(sts&msg&1), msg = *EFmsg, code = EMS_E_LoopsetError,
         str = "EFaddrm_modify_trace_groups : EMsplityourself error",
         action = GOTO_VALUE, value = while_end );   
 
     /* STEP 9: Now we need to identify the loops from this loopset that will 
      *         lead to the correct trace groups. This algorithm depends on the
      *         mode under which we are using this function.
      *
      *       sort_point_mode:
      *         Do a point location on the resulting loopset with ALL points 
      *         placed on this surface, to identify the innermost loops within
      *         which the points lie. 
      *
      *       non sort_point_mode (i.e. check present/absent bits used):
      *         Here we check if any of the edges of a loop was created
      *         from an intobj that HAD the check_present bits and DID NOT have
      *         the check_absent bits. If there were no such loops, we proceed
      *         to the next surface.
      *
      *       If there were ANY such sort loops, then we look for all their 
      *       nested loops too. The trace groups that the intobjs (that created
      *       the edges of these loops) belong to shall be marked as "to keep".
      ************************************************************************/

     num_sort_loops = 0; /* At start. Move this to start of while loop?*/

     if( sort_point_mode )
     {
        /* array to store loops which contain sort point */
        sort_loops = (GRobjid *)om$malloc (size = *num_sort_pts * 
                                                  sizeof (GRobjid));
        add$status( test = !sort_loops, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFaddrm_modify_trace_groups : Insufficient Memory",
            action = GOTO_VALUE, value = while_end );   
   
        memset( sort_loops, 0, *num_sort_pts * sizeof(GRobjid) );
   
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
            add$status( test = !(sts&msg&1), msg = *EFmsg, code = EMS_E_PtLocError,
                str = "EFaddrm_modify_trace_groups : EMpt_location error",
                action = GOTO_VALUE, value = while_end );   
   
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
                   add$status( test = !(*bad_pts), msg = *EFmsg, 
                       code = EMS_E_NoDynamicMemory,
                       str = "EFaddrm_modify_trace_groups : Insufficient Memory",
                       action = GOTO_VALUE, value = ret_end );   
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
            {  
               redundant_pt = FALSE; 
               for (k=0; k<num_sort_loops; k++)
               {  if (sort_loops[k] == pt_loc.loop_id)
                  {  redundant_pt = TRUE;
                     break;
                  }
               }
               if (!redundant_pt)
                  sort_loops [num_sort_loops++] = pt_loc.loop_id;
   
            }/*if (!bad_location) */
   
          }/* if( check_surface ...) */
   
        }/*for*/
   
        /* 
         * If ALL points are invalid, exit with error. If all pts are invalid, 
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
     }
     else
     {
        /* 1. Get a list of all loops in the loopset.
         * 2. Get the edges of each loop.
         * 3. For every edge, check if the edge corresponds with an intobj in 
         *    the original inters list that has the input bitmask.
         * 4. If any intobj so matches, put this loop into the "sort loops" 
         *    array.
         */

        sts = om$get_channel_count(objid        = cp_loopset.objid,
                                   osnum        = cp_loopset.osnum,
                                   p_chanselect = &to_loops,
                                   count        = &lp_count);
        EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, while_end);
    
        /* array to store sort loops (the ones we are interested in). We 
         * allocate the maximum size needed.
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
           EMerr_hndlr(!(1&sts) || !ed_count, *EFmsg, EMS_E_OMerror, while_end);
    
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
    
           /* check each edge of loop to see if it corresponds to an intobj in 
            * the original list. If it does, check if the intobj is marked as 
            * desired. If it is, store this loop in the "sort_loops" array. 
            * Keep checking edges of loop until either there are no edges left 
            * OR we determine that this loop is a "sort_loop".
            */
    
           for (k=0; k<ed_count && !loop_stored ; k++)
           {
             /* if any edge id appears in the cp_intobjs list, then use this 
              * edge to get its counterpart in the original inters list and 
              * hence obtain a pointer to the intobj.
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
    
                          if( intobj_loc->props&check_present )
                          {
                             /* This edge is created from an intobj (actually a 
                              * copy of the intobj) that is marked as needed. 
                              * This means we need to store the loop in 
                              * "sort_loops" array for later processing (to 
                              * mark trace groups).
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
    
                    /* we HAVE to have found the intobj within this IF 
                       statement */
                    if (!found_intobj)
                          EMerr_hndlr (TRUE, *EFmsg, EMS_E_Fail, while_end);
                 }/*if*/
              }/*for,l*/
           }/*for,k*/
        }/*for,j*/
    
        /*deallocate the "loop_objects" array*/
        if (loop_objects)
           {om$dealloc(ptr=loop_objects);loop_objects=NULL;}
     }

    /* By now we have an array of loops, whose edges will possibly lead us to
     * the intobjs in the copied inters list which need to be kept, and after
     * mapping these intobjs to the original inters list, will let us know 
     * which trace groups will need to be kept.
     */

    /* do for every sort loop in the array above */
    for (j=0; j<num_sort_loops; j++)
    {  
       /* get ids of all the edges in THIS loop and in ALL its nested loops*/
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
       add$status( test = !(sts&msg&1), msg = *EFmsg, code = EMS_E_LoopError,
           str = "EFaddrm_modify_trace_groups : EMget_edges error",
           action = GOTO_VALUE, value = while_end );   

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
         {  
             if ( (edges_in_sort_loops[k].objid == cp_intobjs[l].objid)
                                    &&
                  (edges_in_sort_loops[k].osnum == cp_intobjs[l].osnum) )
             {  
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

                EFget_trace_group_from_intobj (&msg, intobj_loc,tracedata,&grp_num);
                add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
                    str = "EFaddrm_modify_trace_groups : EFget_trace_group_from_intobj error",
                    action = GOTO_VALUE, value = while_end );   

                if( options & KEEP_TRACE_GROUP )
                    trace_group_keep[grp_num] = TRUE; 
                else if( options & DELETE_TRACE_GROUP )
                    trace_group_keep[grp_num] = FALSE;

                if (!single_operand_mode)
                { 
                  /* mark corresponding trace group of OTHER intobj. This code
                   * assumes "other_intobj" is ALWAYS on the OTHER inters list.
                   * This is not always so (in features, rounding etc., intobjs
                   * from the SAME list are counterparts). Therefore, the "if"
                   * check above prevents optimization in those cases. What the
                   * heck!!!
                   */
                  EFget_trace_group_from_intobj (&msg, intobj_loc->other_intobj_node, 
                                                 other_tracedata, &grp_num);
                  add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
                      str = "EFaddrm_modify_trace_groups : EFget_trace_group_from_intobj error",
                      action = GOTO_VALUE, value = while_end );   
                 
                  if( options & KEEP_TRACE_GROUP )
                      other_trace_group_keep[grp_num] = TRUE; 
                  else if( options & DELETE_TRACE_GROUP )
                      other_trace_group_keep[grp_num] = FALSE;
                }

                break; /* we have processed intobj corresp. to this edge */
             }
         }
       }

       /* Free array of edges (of the loops with points) */

       if (edges_in_sort_loops)
       {  
         om$dealloc (ptr = edges_in_sort_loops); 
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
                 loop_os   = inters->cvs->this_uvintobj.data.object->osnum);            
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

      if (cp_intobjs)
      {  om$dealloc (ptr = cp_intobjs);
         cp_intobjs = NULL;
      }

      if (orig_intobjs)
      {  
         om$dealloc (ptr = orig_intobjs); 
         orig_intobjs = NULL;
      }

      /* Free orig_edges and cp_edges */
      if (cp_edges)
      {  
         om$dealloc (ptr = cp_edges); 
         cp_edges = NULL;
      }

      if (orig_edges)
      {  
         om$dealloc (ptr = orig_edges); 
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
      {  
         om$dealloc (ptr = cp_info.objid_array);
         cp_info.objid_array = NULL;
      }

      /* Delete the copied loopset along with all its loops and edges */
      if (cp_loopset.objid != NULL_OBJID)
      {
         sts = om$send(msg = message Root.delete(TRUE),
                        senderid = NULL_OBJID,
                        targetid = cp_loopset.objid,
                        targetos = cp_loopset.osnum);
         add$status( test = !(sts&1), msg = *EFmsg, code = EMS_E_LoopsetError,
             str = "EFaddrm_modify_trace_groups : Root.delete error",
             action = GOTO_VALUE, value = ret_end );   
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

    if( options & STOP_AFTER_PROCESSING_FIRST ) break;
 
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
   * the other inters list MAY be invalidated by the deletions on the first list
   * we instead simply MARK intobjs for deletion,, instead of deleting them 
   * here. Once both sets of trace data have been processed, we delete all s 
   * intojbs marked for deletion.
   * ASSSUMPTION: No intobj coming into this function has an EMSintobj_delete 
   *              bit set. This can be easily enforced here, by simply unseting
   *              these bits first.
   */


MARK_FOR_DELETION : 
     
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
        add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFaddrm_modify_trace_groups : EMdelintobj_selective error",
            action = GOTO_VALUE, value = ret_end );   
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
     {  
      /* Copy ALL the sort points into the "bad pts" array for passing back to
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
         add$status( test = !(*bad_pts), msg = *EFmsg, 
                    code = EMS_E_NoDynamicMemory,
                    str = "EFaddrm_modify_trace_groups : Insufficient Memory",
                    action = GOTO_VALUE, value = ret_end );   
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
               matrixtype       = &(md_env->md_env.matrix_type),
               matrix           = md_env->md_env.matrix,
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
            add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
                str = "EFaddrm_modify_trace_groups : ems$sfinttrace error",
                action = GOTO_VALUE, value = ret_end ); /*error out*/
       }
       else
          break; /* successful */
     }

   }/*if, inters is not NULL*/
  
  }
  
ret_end:

/* All locally allocated memory has been freed above, in "while_end" */

EMWRAPUP (*EFmsg, sts, "In EFaddrm_modify_trace_groups");
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
        options,
	inters, 
	tracedata, 
	trace_group_keep,
	check_this_surface)
IGRlong			*EFmsg;
IGRushort               options;
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
      EFget_trace_group_from_intobj (&msg, intobj, tracedata, &group_num);
      add$status( test = !(msg&1), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFcheck_inters_trace_groups : EFget_trace_group_from_intobj error",
          action = GOTO_VALUE, value = ret_end ); 
    
      if( (options & KEEP_TRACE_GROUP) ? 
                   (trace_group_keep[group_num] == FALSE) : 
                   (trace_group_keep[group_num] == TRUE) )
      {
        *check_this_surface = TRUE;
        break;
      }
      intobj = intobj->next;
  }


ret_end:
  EMWRAPUP (*EFmsg, sts, "In EFcheck_inters_trace_groups"); 
}

end implementation EMSsfboolean;
