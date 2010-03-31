/* ###################   APOGEE COMPILED   ################## */
/* 
Notes
    This method imposes a set of boundaries on the loopset. The 
boundaries are input as a set of loops(open or closed). A point is input
specifying which region of the modified loopset is to be an area. The rest
of the regions in the loopset are made holes or areas based on toggling.

Assumptions
    The boundaries are imposed with the convention that P loops are
nested only inside C loops and vice versa.

History
    SM  03/30/87    Creation date.
    RC  11/10/87    Modified arguments to message EMmake_natural_loopset
    SM  31-Dec-87   Avoid mallocs wherever possible by using local static
		    buffers.
    Sm	07-Dec-88   Optimisation for a loopset with single P loop and 
		    modifications to allow imposition of trimmed boundaries
		    on such a loopset.
    SM	07-Mar-89   In case of error, clean up loops created here.
    SM  11-Mar-92   Removed option 'EMImpBnd_TrimmedBdrys'. Support option
		    'EMImpBnd_NoPrintError'.
    NP  13-Dec-93   Since we dont support the option 'EMImpBnd_NoPrintError' any
                    more, removed reference to it. The same functionality as
                    'EMImpBnd_NoPrintError' can be achieved by setting the
                    global variable "OM_Gf_verbose_warning" to FALSE.
*/

class implementation EMSloopset;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsimpdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#define ORNT_LOOPS_BUF	20

extern OMuword OPP_EMSloopset_class_id;

from EMSloop import EMtoggle_type, EMget_props, EMgivenestinfo, EMtreemod, 
		    EMset_props;

method EMimpose_boundaries(IGRlong *EMmsg;
               GRobjid *bdrys;
               IGRint num_bdrys;
               IGRdouble *in_point;
	       IGRboolean in_point_in_area;
               GRobjid **output_loops;
               IGRint *num_output_loops;
               struct EMSsfintedpar ***out_trim_info;
               IGRint *num_out_trim_info;
               IGRint *num_sfs;
               struct EMSownercomp **sfloops;
               struct EMSpartolbasis *partolbasis;
               struct GRmd_env *env;
	       GRobjid *working_ls;
	       IGRushort options)
{
  IGRlong		sts;
  GRobjid		loc_work_ls, *exist_loops;
  GRobjid		loc_ornt_loops[ORNT_LOOPS_BUF];
  GRobjid		*ornt_loops, sfid, *delloops;
  IGRint		i, num_exist_loops;
  IGRint		buf_size, depth, num_inters, num_ornt_loops;
  IGRushort	props,*lp_props;
  IGRushort	togtype_options;
  struct EMSnest_info	nesting;
  struct EMSptloc_info  location;
  IGRboolean		intersect, list_ext, delete_loops, 
			me_natural, single_area;
  void          	EMmkownlist();
  OM_S_CHANSELECT   	to_edges;
  IGRint		numdelloops = 0, num_ploops = 0;
  IGRint		loc_num_output_loops = 0, num_features = 0;
  GRobjid		*loc_output_loops = NULL;
  IGRboolean		out_loops = FALSE, update_features = FALSE;
  GRobjid		*features = NULL;
  struct EMSownercomp	*owncomps = NULL;
  IGRint		numowners = 0;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  exist_loops = NULL;
  ornt_loops = NULL;
  lp_props = NULL;
  num_exist_loops = 0;
  num_ornt_loops = 0;
  buf_size = 0;
  delloops = NULL;
  numdelloops = 0;
  delete_loops = !(num_sfs && sfloops);
  me_natural = ME.EMSloopset->ls_props & EMLS_NATURAL ? TRUE : FALSE;
  out_loops = output_loops && num_output_loops ? TRUE : FALSE;

  update_features = options & EMImpBnd_NoFeatureUpdate ? FALSE : TRUE;

  /* This method accepts the responsibilty of updating the feature loops
     after the loopset has been modified. The same options variable is passed
     on to EMSloopset.EMsplityourself which also tries to update features.
  */

  options |= EMImpBnd_NoFeatureUpdate;

  if(!num_bdrys) 
   {
     *EMmsg = EMS_I_NoIntersection;
     goto wrapup;
   }
    
   single_area = FALSE;
   depth = MAXINT;
   sts = om$send(msg = message EMSloopset.EMget_loops(EMmsg, 
		EMS_OPT_PLOOP, &depth, NULL, NULL, NULL, &num_ploops), 
		targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
   /*if(num_ploops == 1)*/
     single_area = TRUE;

   /**************
   else if(options & EMImpBnd_TrimmedBdrys)
    EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
   **************/

  if( (!in_point) && (!(options & EMImpBnd_AutoNest)))
   sts = om$send(msg=message EMSloopset.EMsplityourself
            (EMmsg, bdrys, num_bdrys, NULL, out_trim_info, num_out_trim_info, 
             output_loops, num_output_loops,
             options | EMImpBnd_CloseRegular | EMImpBnd_CloseReverse |
	     	       EMImpBnd_SplitTopology, 
             num_sfs, sfloops, partolbasis, env), 
            targetid = my_id);
  else
   {
    sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

    if(!delete_loops)
     {
       sts = om$send(msg=message EMSboundary.EMgetsurface_info
                (EMmsg,&sfid,NULL),targetid=my_id);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
     }

    /* Validation for auto nesting */

    if(options & EMImpBnd_AutoNest)
     {
      for(i=0;i<num_bdrys;i++)
       {
        sts = om$send(msg=message EMSloop.EMget_props(EMmsg,&props),
                targetid = bdrys[i]);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
        EMerr_hndlr(props&EMLP_OPEN, *EMmsg, EMS_E_InvalidArg, wrapup);
       }

     }/* if(options & EMImpBnd_AutoNest) */

/* Create a working LS with natural loop. If the existing loopset is natural
   and all the incoming loops are closed then we do not need a working
   loopset. Also if working loopset is supplied, use it.
*/
    if(working_ls) loc_work_ls = *working_ls;
    else if(single_area) loc_work_ls = my_id;
    else 
     {
      sts = om$construct(classid = OPP_EMSloopset_class_id,
            		 p_objid = &loc_work_ls, 
			 msg = message EMSloopset.EMmake_natural_loopset
            			(EMmsg,NULL,NULL,NULL));
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     }
    
/* split the working LS.
*/
    if( (options & EMImpBnd_WantStatMsg) && (options & EMImpBnd_AutoNest))
     ex$message (msgnumb = EMS_S_AutoNesting)
    else if(options & EMImpBnd_WantStatMsg) 
     ex$message (msgnumb = EMS_S_ImpOrntBdrys);

    if(IF_EQ_OBJID(loc_work_ls, my_id))
     sts = om$send(msg=message EMSloopset.EMsplityourself
            (EMmsg, bdrys, num_bdrys, 
	    NULL, out_trim_info, num_out_trim_info, 
	    out_loops ? &loc_output_loops : NULL, 
	    out_loops ? &loc_num_output_loops : NULL, 
	    options | EMImpBnd_CloseRegular | EMImpBnd_CloseReverse |
	    EMImpBnd_NoDummyEdges | EMImpBnd_SplitTopology, 
            num_sfs, sfloops, partolbasis, env),
            targetid = loc_work_ls);
    else
     sts = om$send(msg=message EMSloopset.EMsplityourself
            (EMmsg, bdrys, num_bdrys, 
	    NULL, NULL, NULL, NULL, NULL, 
	    EMImpBnd_CloseRegular | EMImpBnd_CloseReverse |
	    EMImpBnd_NoDummyEdges , 
            NULL, NULL, partolbasis, env),
            targetid = loc_work_ls);
    if(!(1&*EMmsg&sts)) {sts = OM_S_SUCCESS; goto wrapup;}

/* Find the innermost loop inside which the input point lies and send a 
   'toggle_type' message to that loop. If the option calls for auto nesting
   then the outermost loops simply become P loops (C loops if CloseRevese is 
   specified)and toggling in each branch takes place. Since we have nested all
   input loops in a natural loopset, the natural loop becomes a C loop
   (P loop if CloseReverse is specified).
   Exclusive existence is required for adjacent loops. The working loopset
   was split into maximum possible regions by the input boundaries. The
   decesion as to which regions are deletable is decided by the input
   point. Between adjacent loops the delete flag will be toggled.
*/  
   delloops = NULL;
   numdelloops = 0;

   if(options & EMImpBnd_AutoNest)
    {
     OM_S_CHANSELECT  to_loops;
     IGRboolean	      outermost_p;

     sts = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
     EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);
     togtype_options = EMTogType_SendInner | EMTogType_ExclusiveAdjacency | 
		       EMTogType_SendAdjacent | EMTogType_NoAction;
     outermost_p = (options & EMImpBnd_CloseReverse) ? TRUE : FALSE;
     sts = om$send(msg = message EMSloop.EMtoggle_type
		(EMmsg, outermost_p, !outermost_p, my_id, togtype_options, 
		 NULL, NULL, &numdelloops, &delloops, NULL, NULL),
                        senderid = loc_work_ls, p_chanselect=&to_loops);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
    }
   else
    {
     location.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP;
     sts = om$send(msg=message EMSloopset.EMpt_location
            (EMmsg,in_point,&location,partolbasis),
            targetid = loc_work_ls);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_PtLocError,wrapup);
     togtype_options = EMTogType_SendInner | EMTogType_SendOuter |
		       EMTogType_SendAdjacent | EMTogType_SendExternalSiblings;
     if(single_area) togtype_options |= EMTogType_NoAction;
     sts = om$send(msg=message EMSloop.EMtoggle_type
		(EMmsg, in_point_in_area, !in_point_in_area, my_id, 
		togtype_options, NULL, NULL, &numdelloops, &delloops, 
		NULL, NULL),
            targetid = location.loop_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
    }

/* Take each loop of this loopset and find its nesting inside the natural
   LS. If it is nested inside a C loop, delete it. This is required to
   be done only if there were disjoint areas on the surface. If there are
   disjoint areas then deletion of existing unwanted loops needs to be
   achieved via the split working loopset.
*/
    if(!single_area)
     {
      if(options & EMImpBnd_WantStatMsg) 
       ex$message ( msgnumb = EMS_S_PartialClnup);
      
      buf_size = 0;
      exist_loops = NULL;
      lp_props = NULL;
      depth = MAXINT;
      sts = om$send(msg=message EMSloopset.EMget_loops
                  (EMmsg,EMS_OPT_ALL,&depth,&exist_loops,&lp_props,
                       &buf_size,&num_exist_loops),
                  targetid = my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
      for(i=0;i<num_exist_loops;i++)
       {
        intersect = FALSE;
        num_inters = 0;
        sts = om$send(msg = message EMSloopset.EMobint(EMmsg,partolbasis,
                exist_loops[i],partolbasis,EMS_INTER_CUTTING,&num_inters,
                                NULL,NULL),targetid=loc_work_ls);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Intersect,wrapup);

        if(!num_inters)
         {
          sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg,&nesting),
                   targetid = exist_loops[i]);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
          sts = om$send(msg=message EMSloopset.EMnesting
                   (EMmsg,&nesting,partolbasis),
                   targetid = loc_work_ls);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
          if( (!IF_EQ_OBJID(nesting.parent,loc_work_ls))&&
              (!(nesting.parent_props&EMLP_PLOOP)) )
           {
            if(delete_loops)
             {
              sts = om$send(msg=message EMSloop.EMtreemod
                        (EMmsg,&nesting,DELETE,partolbasis),
                         targetid = exist_loops[i]);
              EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_TreeModError,
								wrapup);
            }
           else
            {
             sts = om$send(msg=message EMSloop.EMtreemod
                       (EMmsg,&nesting,EXTRACT,partolbasis),
            		targetid = exist_loops[i]);
             EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_TreeModError,
								wrapup);
             EMmkownlist(EMmsg,sfloops,sfid,NULL,exist_loops[i],FALSE,
                    			&list_ext);
       	     EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
             (*num_sfs)++;
	     sts = om$send(msg = message EMSloop.EMset_props
		    (EMmsg, EMLP_ACTIVE, EMS_O_OFF),targetid = exist_loops[i]);
            }
           }

          }/* if(!num_inters) */

        } /* For i< num_exist_loops*/

      } /* if(!single_area)*/


/* Delete all the loops deemed deletable by toggling traversal. */
   for(i=0; i<numdelloops; i++)
    {
     if(!single_area)
      {
       sts = om$send(msg=message EMSloop.EMtreemod
             (EMmsg,&nesting,DELETE,partolbasis),
                targetid = delloops[i]);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_TreeModError, wrapup);
      }
     else
      {
       IGRboolean new_loop = FALSE;
       IGRint j;

       for(j=0; j<loc_num_output_loops; j++)
        if(IF_EQ_OBJID(loc_output_loops[j], delloops[i])) 
	 {
	  new_loop = TRUE; 
	  loc_output_loops[j] = NULL_OBJID;
	  break;
         } 
		
       sts = om$send(msg=message EMSloop.EMtreemod
              (EMmsg, &nesting, 
		new_loop || delete_loops || !out_loops? DELETE : EXTRACT, 
		partolbasis), targetid = delloops[i]);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_TreeModError, wrapup);
       if(!new_loop && !delete_loops)
	{
         EMmkownlist(EMmsg, sfloops, sfid, NULL, delloops[i],FALSE, &list_ext);
         EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
         (*num_sfs)++;
         sts = om$send(msg = message EMSloop.EMset_props
		 (EMmsg, EMLP_ACTIVE, EMS_O_OFF),targetid = delloops[i]);
	}
      }     
    }

   
   /* If the loopset had single area, no futher action need be taken. However
      if there were disjoint areas, we only achieved oientation and partial
      cleanup of the disjoint loopset. So reimpose the oriented boundaries
      on the partially cleaned, disjoint loopset. In case of a single area
      loopset we still have to output the loops fianlly created by this
      operation .
   */
   if(single_area && output_loops && num_output_loops)
    {
     IGRint	num = 0;

     for(i=0; i<loc_num_output_loops; i++) 
      if(!IF_NULL_OBJID(loc_output_loops[i])) num++;

     *output_loops = (GRobjid *) om$malloc(size = num * sizeof(GRobjid));
     *num_output_loops = 0;
     for(i=0; i<loc_num_output_loops; i++)
      if(!IF_NULL_OBJID(loc_output_loops[i])) 
	(*output_loops)[(*num_output_loops)++] = loc_output_loops[i];
    }
   else if(!single_area)
    {
     depth = MAXINT;
     if(2*num_bdrys > ORNT_LOOPS_BUF)
      {
       ornt_loops = NULL;
       buf_size = 0;
      }
     else
      {
       ornt_loops = loc_ornt_loops;
       buf_size = ORNT_LOOPS_BUF;
      }

     sts = om$send(msg=message EMSloopset.EMget_loops
        (EMmsg, EMS_OPT_ALL, &depth, &ornt_loops, NULL, &buf_size, 
	&num_ornt_loops), targetid = loc_work_ls);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);

     /* loopset disconnections are done through treemod so that things like
	gradata being deleted, loop properties like EMLP_EXTERNAL etc.
	are taken care of at the cost of little more processing as opposed
	to wild disconnects of 'to_inner' and 'to_outter' channels.
     */
     for(i=0; i<num_ornt_loops; i++)
      {
       sts = om$send(msg=message EMSloop.EMtreemod
                (EMmsg, &nesting, EXTRACT, partolbasis),
            	targetid = ornt_loops[i]);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_TreeModError,wrapup);
      }

     /* Delete the working loopset(if different from my_id and was constructed
        here)
     */
     if(!IF_EQ_OBJID(loc_work_ls, my_id) && !working_ls)
      {
       sts = om$send( msg=message Root.delete(TRUE), targetid = loc_work_ls);
       EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
      }

     /* Now there is a list of oriented loops. Impose them with the option
        EMImpBnd_CloseRegular on the existing loop. Upto this point the 
	existing
        loopset was not modified(except for partial cleanup).
     */  
     if( (options & EMImpBnd_WantStatMsg) && !(options & EMImpBnd_AutoNest))
        ex$message ( msgnumb = EMS_S_ImpOrntBdrys);

      sts = om$send(msg=message EMSloopset.EMsplityourself
            (EMmsg, ornt_loops, num_ornt_loops, NULL, 
	     out_trim_info, num_out_trim_info, output_loops, num_output_loops, 
	    options | EMImpBnd_CloseRegular | EMImpBnd_SplitTopology |
	    EMImpBnd_NoDummyEdges,
	    num_sfs, sfloops, partolbasis,env), targetid = my_id);
      if(!(1&*EMmsg&sts)) {sts = OM_S_SUCCESS; goto wrapup;}
    } /* else if(!single_area) */

   } /* If in_point */

wrapup:

  /* If everything proceeded ok, the loopset now reflects the new state.
     update all the features on the loopset, at this point.
  */
  if( (1 & *EMmsg & sts) && update_features)
   {
    IGRlong locsts, locmsg;

    locsts = om$send(msg = message EMSloopset.EMupdate_features
				(&locmsg, &features, &num_features, 
				 num_sfs, sfloops, 
				 &numowners, &owncomps, TRUE, partolbasis), 
				targetid = my_id);
    if(num_features && out_loops)
     {
      *output_loops = (GRobjid *) om$realloc(ptr = (char *)*output_loops, 
				size = (*num_output_loops + num_features) * 
      					sizeof(GRobjid));
      EMerr_hndlr(!(*output_loops), *EMmsg, EMS_E_NoDynamicMemory, finish);
      OM_BLOCK_MOVE(features, &(*output_loops)[*num_output_loops], 
			sizeof(GRobjid) * num_features);
      (*num_output_loops) += num_features;
     }

   }
  else if(!(1&*EMmsg&sts))
   {
    IGRint i, j, dumsts;

    for(i=0; i<num_bdrys; i++)
     for(j=0; j<num_ornt_loops; j++)
      if(IF_EQ_OBJID(bdrys[i], ornt_loops[j])) ornt_loops[j] = NULL_OBJID;
    for(i=0; i<num_ornt_loops; i++)
     dumsts = om$send(msg = message Root.delete(TRUE), 
				targetid = ornt_loops[i]);
   }

finish:
  if(features) om$dealloc(ptr = features);
  if(delloops) om$dealloc(ptr = delloops);
  if(exist_loops) om$dealloc(ptr=exist_loops);

  if(lp_props) om$dealloc(ptr=lp_props);

  if(loc_output_loops)	 om$dealloc(ptr = loc_output_loops);

  if( (2*num_bdrys > ORNT_LOOPS_BUF) && ornt_loops)
    om$dealloc(ptr = ornt_loops);

  EMWRAPUP(*EMmsg,sts,"In EMSloopset.EMimpose_boundaries");
  return(sts);
}

end implementation EMSloopset;
