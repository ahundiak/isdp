class implementation EMScompsurf;

/*
DESCRIPTION

This method constructs a shell solid from a composite surface. First the
offset of the composite surface is created (by the general 'offset' method)
and then ruled surfaces are created between the corresponding free edges of the
original and the offset. Finally all these surfaces are stitched to form
the shell solid.

RETURN VALUES

constructed_object - The shell-solid constructed from the composite surface.

NOTE

If an error occurs, no object will be returned.

HISTORY
	27 Apr 1993	ashok		Creation
	Sudha      06/21/93     Modified to handle BSprototype ansification
        Sudhakar   29Jul'93     Modified to allow handling of multiple
                                wall thicknesses. Added a new argument to the
                                method 'IGRboolean offset_symmetric'.
        Sudhakar   12Aug'93     Added the option "EMS_SFINT_NOREFINE" to
                                the function call of "EMintersect_surfaces"
                                to avoid refining which is not needed here.
        Sudhakar   17Aug'93     Incorporated Ashok's bug-fix  relating to
                                the generation of a 'single' ruled surface.
        ashok	   19Aug'93     Modified to take care of argument change to
				EFoffset_compsf()
	ashok	   02Sep'93	Modified to call EMsfinttrace() to do the
				trace instead of EMintersect_surfaces() as
				recent changes to the latter make it difficult
				to perform a "pure" trace without processing
				the inters list for duplicated etc....
        Sampath    03Sep'93     Took care of the case where the corresponding
                                edges on the original and the offset surface
                                are of different types (normal vs part-edge OR
                                vice versa). If so, 'generate_id_from_key' is
                                tried again with the other edge type.
	ashok	   07Sep'93	Modified to generate correct key for edges
				of 'reversed loops' in the input surface.
        Sudhakar   02Dec'93     Modified to delete 'xyzdegenerate' free intobjs
                                also along with intobjs with 'other_intobj'
                                before compressing the tree. This fixes 
                                TR# 119312642.
	ashok	   30Dec'93	Provided fix for TR# 119315062.
        Sudhakar   04Jan'94     Added a new "NULL" option arg. to all the
                                occurances of "EFcvt_edge_to_cv()" function
                                calls.
	ashok	   16Jun'94	Integrated "mlk" fixes from EMS 4.
    
        V.Srinivas 30july'96    Handled the case of a composite surface having
                                seam edge causing topology mismatch.
                                Presence of seam edge causes loops to get
                                merge on the offset surface, this was not
                                reflected on original surface. This fix is
                                made for the TR#119528129. For this special 
                                case to get the original surface edges ids
                                after merging, key functions are giving ids
                                wrongly so it needed to increase an argument
                                for the function EFoffset_compsf. I copied
                                this function to EFoffset_compsf_tw with extra
                                argument and made the necessary changes to this
                                function. This problem do not arise for the
                                symmetric offset case so it is skipped for that.
       G.Usha Kiran 12 Nov'97   BSmergarrcv() is giving error status of merging
                                two curves which are collinear, This error is 
                                due to ending point of the curve1 differs great
                                er than the disttol of the system.(It is not fe
                                asible to error out at this level even after
                                correct interslist generation so changed the cod
                                e to break the loop and continue further to crea
                                te two ruled surfaces instead of one, any way
                                surface genrated later will get stiched to the
                                solid and gets converted into a single one. The
                                fix was kept in EFgen_ruled_sf();
                                
                                  
*/

#define  BWD	0
#define  FWD	1

%safe
#include <math.h>
%endsafe
#include "bsvalues.h"
#include "OMmacros.h"
#include "bserr.h"
#include "EMS.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "EMSkey.h"
#include "EMSprop.h"
#include "EMSsplitdef.h"
#include "EMSssprops.h"
#include "bsparameters.h"
#include "bsrev_cv.h"
#include "bsptlngen.h"
#include "bsmergarrcv.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bscvcoplan.h"
#include "bsalloccv.h"

from EMSsubbs import EMget_props;
from EMSgenbs import EMruled_surface;
from EMSedge  import EMconnect_edges;
from EMSsfstitch import EMmake_comp;
from EMSloopset import EMget_loops;
from EMSloopset import EMbounded_uv_range;
from EMSloop import EMget_props;
from EMSdpr import EMmake_primitive1;
from EMSsolid import EMorient_yourself;

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSgencompsf_class_id;
extern OMuword OPP_EMSslstitch_class_id;

%safe
static void EFgen_ruled_sf();
%endsafe

method EMshell(
    IGRlong *msg; 
    IGRushort option;
    IGRshort *mattyp; IGRmatrix mat;
    struct GRvg_construct *construct_list;
    IGRboolean offset_inward;
    IGRboolean offset_symmetric;
    IGRdouble distance;
    IGRint num_spec_thick;
    IGRdouble *val_spec_thick;
    struct GRobjid_set *spec_thick_sf_sets;
    IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
    IGRchar *status_str;
    OM_S_OBJID *constructed_object;
    struct EMSerror_help *errkey_list)
{
IGRlong			sts, msg_loc, maxint=OM_K_MAXINT;
IGRint			i, j, k, numsf, count, num_edges,orgnum_edges, num_loops;
IGRdouble               half_distance=0.0, /* aviod compiler warnings */ 
			*val_half_thick = NULL, tracetol;
GRobjid			object, *obj_ptr, *rule_ids, start_edge=NULL_OBJID, 
			prev_edge=NULL_OBJID, prev_subgrp_edge=NULL_OBJID, 
			first_edge=NULL_OBJID, *surfs,*my_surfs,
			this_edge, nat_edges[4], off_compsf,***edge_map_list;
IGRboolean		subgrp_rev, is_single, rev_ornt, rev_connect, prev_elem,
			prev_subgrp_elem, tr_alloced=FALSE, lp_rev, got_props;
IGRuchar		props;
IGRushort		pos_ornt1, pos_ornt2, lp_props;

IGRint                  cpnum_edges;

struct GRid		my_grid, fcs_grid, sf_grid,*orgsurf_edges,*cpsurf_edges;
struct EMSinters	*off_inters, *sf_inters;
struct EMSintobj	*start_intobj, *curr_intobj, *tmp_intobj,
			*prev_intobj, *prev_subgrp_intobj;
struct GRmd_env		env;
struct EMSsftracedata	trace_out;
struct EMSkey		*key;
OM_S_CHANSELECT		chan_to_loopset;

IGRlong			EFoffset_compsf_tw();
IGRlong			EFoffset_compsf(), EFgenerate_id_from_key(),
			EFgenerate_key_from_id(), EMconvert_into_plane();
extern void             EFcreate_outward_offset_by_half_thickness(),
                        EMsfinttrace(),
			EMsfinttrace_free();

	*msg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	off_inters = NULL;
	surfs = NULL;
	my_surfs = NULL;
	cpsurf_edges = NULL;
	orgsurf_edges = NULL;
        edge_map_list=NULL;

	key = NULL;
	rule_ids = NULL;
	off_compsf = NULL_OBJID;

        env.md_env.matrix_type = *mattyp;
        OM_BLOCK_MOVE(mat, env.md_env.matrix, sizeof(IGRmatrix));
        env.md_id.objid = construct_list->env_info->md_id.objid;
        env.md_id.osnum = construct_list->env_info->md_id.osnum;

	my_grid.objid = my_id;
	my_grid.osnum = fcs_grid.osnum = OM_Gw_current_OS;

      /*
       * Create the first composite surface (FCS)to be used for constructing
       * the 'thinwall from composite surface'. 
       * If the offset is symmetric ('offset_symmetric' = TRUE) 
       *   the FCS is obtained by offsetting original surface outward
       *      by half-distances;
       * If the offset is to_one_side ('offset_symmetric' = FALSE)
       *   the FCS is obtained by copying the original surface in place.
       */

        if(offset_symmetric)
        {
         /* Create the outward 'half' offset composite surface. 
              Modify args of this function .*/
           fcs_grid.objid = my_id;
           EFcreate_outward_offset_by_half_thickness(&msg_loc, construct_list,
                                       distance, num_spec_thick,
                                       val_spec_thick, spec_thick_sf_sets,
                                       &fcs_grid.objid, errkey_list);
           EMerr_hndlr (!(1 & msg_loc), *msg, EMS_E_Fail, ret_end);

         /* Since the original surface has to be offset inward by
            half distances, set up the half distance values. */
           offset_inward = TRUE;
           half_distance = distance/2.0;
           if(num_spec_thick)
           {
             val_half_thick = (IGRdouble *) om$malloc(size =
                                      num_spec_thick * sizeof(IGRdouble));
             EMerr_hndlr(!val_half_thick, *msg, EMS_E_NoDynamicMemory, ret_end);
             
             for(i=0; i<num_spec_thick; i++)
             {
               val_half_thick[i] = val_spec_thick[i]/2.0;
             }
           } /* end of if(num_spec_thick).. */
        }
        else
        {
        /*
         * Create a copy of the original composite surface.
         */
           sts = om$send (msg = message GRgraphics.GRcopy (&msg_loc,
                                             construct_list->env_info,
                                             construct_list->env_info,
                                             &fcs_grid.objid),
                             targetid = my_id);
           EMerr_hndlr (!(1 & msg_loc & sts), *msg, EMS_E_Fail, ret_end);

        }

	sts = om$send(msg = message GRowner.GRget_number_components(
				    &msg_loc, &numsf),
		      targetid = fcs_grid.objid);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

/* Fix for TR 119315062. Commented out this block. Send the message
   EMScompsurf.EMgetedges instead (same as what is used in EFOffCompSf.I)
    - Ashok 30/dec/93.
	surfs = (struct GRid *) om$malloc(size = numsf *
						 sizeof(struct GRid));
	EMerr_hndlr(!surfs, *msg, EMS_E_NoDynamicMemory, ret_end);
	EMerr_hndlr(!surfs, *msg, EMS_E_NoDynamicMemory, ret_end);

	sts = om$send(msg = message GRowner.GRget_components(&msg_loc,
				    construct_list->env_info, surfs, numsf,
				    &count, NULL, OM_K_MAXINT),
		      targetid = fcs_grid.objid);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);
*/
    /** my_surfs holds the objids of the original surface***/

	my_surfs = (GRobjid *) om$malloc(size = numsf *
						 sizeof(GRobjid));
	EMerr_hndlr(!my_surfs, *msg, EMS_E_NoDynamicMemory, ret_end);
	surfs = (GRobjid *) om$malloc(size = numsf * sizeof(GRobjid));
        EMerr_hndlr(!surfs, *msg, EMS_E_NoDynamicMemory, ret_end);
        i = numsf;
        count = num_edges = numsf = 0;

        /*
         *  get surface ids of the this composite surface for both 
         *  original and copied 
         */
        sts = om$send(msg = message EMScompsurf.EMgetedges(&msg_loc,
                            EMS_OPT_STITCHED, NULL, &count, &num_edges,
                            &my_surfs, NULL, &i, &numsf),
                      targetos = fcs_grid.osnum,
                      targetid = my_id);
        EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);
        i = numsf;
        count = num_edges = numsf = 0;
        sts = om$send(msg = message EMScompsurf.EMgetedges(&msg_loc,
                            EMS_OPT_STITCHED, NULL, &count, &num_edges,
                            &surfs, NULL, &i, &numsf),
                      targetos = fcs_grid.osnum,
                      targetid = fcs_grid.objid);
        EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);
	if(num_edges == 0)
	{
	  /* no stitched edges. Number of components got to be 1 */
	   struct GRid tmp_grid;
           numsf = 1;

           sts = om$send( msg = message GRowner.GRget_components(
                                &msg_loc, construct_list->env_info,
				&tmp_grid, numsf, &numsf, 0, 0),
                        targetid = my_id,
                        targetos = fcs_grid.osnum);
           EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

           my_surfs[0] = tmp_grid.objid;

           numsf = 1;
           sts = om$send( msg = message GRowner.GRget_components(
                                &msg_loc, construct_list->env_info,
				&tmp_grid, numsf, &numsf, 0, 0),
                        targetid = fcs_grid.objid,
                        targetos = fcs_grid.osnum );
           EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

           surfs[0] = tmp_grid.objid;

	}


   /*
    *       call the following function to offset the composite surface
    *       with an extra argument edge_map_list. This variable
    *       collects the edge ids of the surface of this composite surface
    *       for non symmetric case else it 
    *       points to NULL --V.Srinivas
    */
 
        if(!offset_symmetric)
        {
          edge_map_list=(GRobjid ***)malloc(numsf*sizeof(GRobjid));
	  EMerr_hndlr(!edge_map_list, *msg, EMS_E_NoDynamicMemory, ret_end);
        }
	sts = EFoffset_compsf_tw(&msg_loc, my_grid, option, mattyp, mat, 
			      construct_list, offset_inward, 
                              (offset_symmetric ? half_distance : distance), 
			      num_spec_thick, 
                              (offset_symmetric ? val_half_thick : 
                                                    val_spec_thick), 
			      spec_thick_sf_sets, num_nooffsetsfs, nooffsetsfs,
			      status_str, &off_compsf, &off_inters, NULL,
			      NULL, errkey_list,edge_map_list);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

        if(offset_symmetric)
        {
          /* Deallocate the half thicknesses array */
           if(val_half_thick)  om$dealloc (ptr = val_half_thick);
           val_half_thick = NULL;
        }

	EMmake_chanselect(EMSsubbs_to_loopset, &chan_to_loopset);

	sf_inters = off_inters;
	for(i=0; i<numsf; i++, sf_inters=sf_inters->next)
	{
	  if(!sf_inters)
	  {
/* Means the offset has less components than the original composite surface */
#ifdef DEBUG
printf("EMcsshell - Error: Original and Offset surface components mismatch\n");
#endif
	    EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);
	  }



	  /* first get the total number of loops in the surface */
	  j = 0;
	  k = MAXINT;
	  sts = om$send(msg = message EMSloopset.EMget_loops(&msg_loc,
				      0, &k, NULL, NULL, &j, &num_loops),
			senderid = sf_inters->this_obj.objid,
			p_chanselect = &chan_to_loopset);
	  EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	  /* Allocate sufficient (conservative) memory for "key" array */
	  key = NULL;
	  key = (struct EMSkey *) om$malloc(size = (num_loops+2) *
						   sizeof(struct EMSkey));
	  EMerr_hndlr(!key, *msg, EMS_E_NoDynamicMemory, ret_end);

	  /* then process each loop one by one */

	  start_intobj = sf_inters->cvs;

       if(!offset_symmetric)
       {
        /*
         *    This is for the special case where in the seam edge 
         *    caused the loops to get merged and is for non symmetric
         */

          orgsurf_edges=NULL; 
          cpsurf_edges=NULL; 
          orgnum_edges=0;
          cpnum_edges=0;
          count = 0;
         /*** get the edge ids list of the copied surface***/

           sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
                            EMS_OPT_ALL, &cpsurf_edges, &count, &cpnum_edges,
                            NULL, NULL, NULL, NULL),
                      targetos = OM_Gw_current_OS,
                      targetid = surfs[i]);
           EMerr_hndlr(! (1 & sts & msg_loc), *msg,
                                                          EMS_E_Fail, ret_end);
               count=0;
         /*** get the edge ids list of the original surface***/

          sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
                            EMS_OPT_ALL, &orgsurf_edges, &count, &orgnum_edges,
                            NULL, NULL, NULL, NULL),
                      targetos = OM_Gw_current_OS,
                      targetid = my_surfs[i]);
                   EMerr_hndlr(! (1 & sts & msg_loc), *msg,
                                                         EMS_E_Fail, ret_end);
            if(orgnum_edges != cpnum_edges)
            {
              printf(" ERROR IN COPYING THE COMPOSITE SURFACE\n");
               goto ret_end;
            }
        }

	  for(j=0; j<num_loops; j++, start_intobj=curr_intobj)
	  {
             int tmp_k=0;
	    got_props = FALSE;
	    lp_rev = FALSE;
	    /* first get the total number of edges in the jth loop */

	    curr_intobj = start_intobj;
	    for(k=0, num_edges=0;; k++, curr_intobj=curr_intobj->fwd)
	    {
	      num_edges++;
	      if(!curr_intobj->fwd || curr_intobj->fwd == start_intobj)
		 break;
	    }

	    /* then process each edge in the jth loop */

	    curr_intobj = start_intobj;

	    for(k=0; k<num_edges; k++, curr_intobj=curr_intobj->next)
	    {
	      if(!curr_intobj->other_intobj_node) /* Free edge! */
	      {						
		/* Get the corresponding free edge from original composite */


                if(!offset_symmetric)
                {
                 int tmp_var;

             /*
              *   get the edge index of the original surface edge
              *   and using this get the corresponding edge of the copy
              *   surface edge
              */
 
                  for(tmp_var=0;tmp_var<orgnum_edges;++tmp_var)
                  {
                   if(edge_map_list[i][j][tmp_k]==orgsurf_edges[tmp_var].objid)
                   {
                    object=cpsurf_edges[tmp_var].objid;
		    this_edge = curr_intobj->this_uvintobj.data.object->objid;
                    break;
                   }
                  }

                }
                else
                {   
		this_edge = curr_intobj->this_uvintobj.data.object->objid;
								 /* created */
		object = sf_inters->this_obj.objid; /* creator */
		count = 0;

		/* Get the key for the edge on the offset */
		sts = EFgenerate_key_from_id(&msg_loc, this_edge, 
			OM_Gw_current_OS, object, &count, &key, 0, 0);
		EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

  	    /* Check if the corresponding loop on FCS is reversed. The
	       loop on the offset can never be reversed (implemented
	       that way). If FCS loop is reversed then, the key to the edge
	       is to be set correctly. Of course, this check is not required
	       if the FCS itself is created by offsetting the original
	       composite. We get the FCS loop object using the same 'key' 
	       array but with 'count' decremented by 1.
	    */
		if(!offset_symmetric && !got_props)
		{
		   /* get the FCS's loop id */
		   sts = EFgenerate_id_from_key(&msg_loc, surfs[i],
			 OM_Gw_current_OS, count-1, key, &object, 0);
		   EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

		   sts = om$send(msg = message EMSloop.EMget_props(&msg_loc,
					                           &lp_props),
				 targetid =  object);
		   EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);
		   got_props = TRUE;
		   if(lp_props & EMLP_REVERSED) lp_rev = TRUE;
		}
		if(lp_rev)
		      key[count-1].chan_index = key[count-1].chan_count - 1 -
						key[count-1].chan_index;

		/* Get the corresponding edge on FCS using the same key */
		sts = EFgenerate_id_from_key(&msg_loc, surfs[i],
			OM_Gw_current_OS, count, key, &object, 0);
		EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

                /* Sometimes, the original edge could be a 'normal' edge
                   and the corresponding edge on the offset surface could
                   be a 'part' edge OR vice-versa. In either of these cases
                   the above routine returns 'NULL_OBJID'. So try again with
                   the other edge type.
                 */
               }

                if(msg_loc==EMS_I_NotFound && object==NULL_OBJID)
                {
                   if(key[count-1].sub_item_type == EMSkey_EDGE)
                        key[count-1].sub_item_type = EMSkey_PARTEDGE;
                   else if(key[count-1].sub_item_type == EMSkey_PARTEDGE)
                        key[count-1].sub_item_type = EMSkey_EDGE;

                   sts = EFgenerate_id_from_key(&msg_loc, surfs[i],
                        OM_Gw_current_OS, count, key, &object, 0);
                   EMerr_hndlr(! (1 & sts & msg_loc), *msg,
                                                         EMS_E_Fail, ret_end);
                   EMerr_hndlr((msg_loc==EMS_I_NotFound || object==NULL_OBJID),
                            *msg, EMS_E_Fail, ret_end);
                }

		obj_ptr = NULL;
		obj_ptr = (GRobjid *) om$malloc(size = sizeof(GRobjid));
		EMerr_hndlr(!obj_ptr, *msg, EMS_E_NoDynamicMemory, ret_end);
		*obj_ptr = object;
		curr_intobj->more_info = (IGRchar *) obj_ptr;
                ++tmp_k;
	      } /* if( Free edge ) */
	    } /* for(k=0.... */
	  } /* for(j=0.... */

	  if(key) om$dealloc(ptr = key);
	} /* for(i=0.... */

	/* The 'off_compsf' is oriented in the same direction as 
	     the 'FCS'. In order to create a shell reverse its orientation.
	*/
	sts = om$send(msg = message EMSsurface.EMrevorient(&msg_loc),
		      targetid = off_compsf);
	EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	/* Retain only Free edges (intobjs) which are not degenerate 
           in the inters list. Delete the rest.
	*/
	sf_inters = off_inters;
	for(i=0; i<numsf; i++, sf_inters=sf_inters->next)
	  for(curr_intobj=sf_inters->cvs; curr_intobj;)
	  {
	    tmp_intobj = curr_intobj->next;
	    if(curr_intobj->other_intobj_node)
		EMdelintobj(&msg_loc, curr_intobj);
           /* Check for degenerate free edges and delete them */
            else if(curr_intobj->props & EMSintobj_xyzdegenerate)
            {
               /* Reset the 'more_info' field before calling 'EMdelintobj'. */
                if(curr_intobj->more_info)
                {
                    om$dealloc(ptr = curr_intobj->more_info);
                    curr_intobj->more_info = NULL;
                }
		EMdelintobj(&msg_loc, curr_intobj);
            }
	    curr_intobj = tmp_intobj;
	  }

	/* Compress the inters list before tracing i.e weed out all inters
	   nodes that have no intobjs.
	*/
	EMcmpinters(&msg_loc, &off_inters);
	if(msg_loc == EMS_I_NoMore || (!off_inters) ) goto ret_end;

	/* Perform trace on the 'free' intobjs left on the inters list.
	   The result should be a set of closed groups (in XYZ)
	*/

	BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, tracetol);
  	tracetol += tracetol;

	trace_out.num_grps = 0;
	trace_out.num_subgrps_grp = NULL;
	trace_out.num_elems_subgrp = NULL;
	trace_out.elems = NULL;
	trace_out.subgrp_rev = NULL;
	trace_out.elem_rev = NULL;
	trace_out.grp_closed = NULL;
	trace_out.subgrp_closed = NULL;

	EMsfinttrace(&msg_loc, mattyp, mat, off_inters, NULL, &tracetol,
		     &trace_out.num_grps, &trace_out.num_subgrps_grp,
		     &trace_out.num_elems_subgrp, &trace_out.elems,
		     &trace_out.subgrp_rev, &trace_out.elem_rev,
		     &trace_out.grp_closed, &trace_out.subgrp_closed);
	EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);

	tr_alloced = TRUE;
/*
At this stage all the 'free' edges have been traced. Now re-inforce the
connectivity between the intobjs in a group using the 'fwd' and 'bwd'
pointers.
Also, error out if any of the groups is not closed      OR
		if the tracer reversed the orientation of any intobj
*/
	for(i=0; i<trace_out.num_grps; i++)
	{
#ifdef DEBUG
if(!trace_out.grp_closed[i])
  printf("EMcsshell : Error - Traced Group Not Closed\n");
#endif
	   EMerr_hndlr(!trace_out.grp_closed[i], *msg, EMS_E_Fail, ret_end);
	   for(j=0,start_intobj=NULL, prev_subgrp_intobj=NULL;
			j<trace_out.num_subgrps_grp[i]; 
				j++)
	   {
#ifdef DEBUG
printf("sub-group reversed = %d\n", trace_out.subgrp_rev[i][j]);
#endif
	      subgrp_rev = trace_out.subgrp_rev[i][j];
	      
	      for(k=0, prev_intobj=NULL, curr_intobj=trace_out.elems[i][j]; 
		       k<trace_out.num_elems_subgrp[i][j]; 
			      k++, curr_intobj=curr_intobj->next)
	      {
		EMerr_hndlr(trace_out.elem_rev[i][j][k], *msg, 
			    EMS_E_IntersectOrient, ret_end);

		/* Mark the intobj as 'reversed' if its edge object has to be 
		   looked in a direction opposite to its logical (loop)
	 	   direction while tracing the group.
		*/
		curr_intobj->reversed = (subgrp_rev ? TRUE : FALSE);

		if(prev_intobj)
		{
		  if(subgrp_rev)
		  {
		     prev_intobj->bwd = curr_intobj;
/*		     prev_intobj->bwd->fwd = prev_intobj->bwd; ??Ashok 12/93 */
		     prev_intobj->bwd->fwd = prev_intobj;
		  }
		  else
		  {
		     prev_intobj->fwd = curr_intobj;
		     prev_intobj->fwd->bwd = prev_intobj;
		  }
		}
		prev_intobj = curr_intobj;

	      } /* end of k for loop */

	      /* Now connect the last intobj in the previous sub-grp with the
		 first intobj of the current (jth) sub-grp
	      */
	      if(prev_subgrp_intobj)
	      {
		prev_subgrp_intobj->fwd = (subgrp_rev ? 
					   prev_intobj : trace_out.elems[i][j]);
		prev_subgrp_intobj->fwd->bwd = prev_subgrp_intobj;
	      }
	      else
		start_intobj = (subgrp_rev ? prev_intobj : 
					     trace_out.elems[i][j]);

	      prev_subgrp_intobj = (subgrp_rev ?
				    trace_out.elems[i][j] : prev_intobj);
	   } /* end of jth for loop */

	   /* Now connect the first and last elements in the group
	      (only if number of elements in the group is > 1)
	    */
	   if(start_intobj)
	   {
	      prev_subgrp_intobj->fwd = start_intobj;
	      prev_subgrp_intobj->fwd->bwd = prev_subgrp_intobj;
	   }
	} /* for(i=0; i<trace_out.num_grps; i++) */

/* Now process each group to create ruled surfaces between corresponding
   edges on composite surface and its offset. Make sure to merge
   contiguous co-planar edges on each composite in order to create a single 
   ruled surface from them instead of contiguous co-planar ruled surfaces.

   Create a composite surface out of all the ruled surfaces created for
   each group. To this end, first construct as many EMSgencompsf header 
   objects as the number of groups.
*/
	rule_ids = (GRobjid *) om$malloc(size = trace_out.num_grps *
						sizeof(GRobjid));
	EMerr_hndlr(!rule_ids, *msg, EMS_E_NoDynamicMemory, ret_end);

	for(i=0; i<trace_out.num_grps; i++)
	{
	  sts = om$construct(classid = OPP_EMSgencompsf_class_id,
			     p_objid = &rule_ids[i],
			     osnum = env.md_id.osnum);
	  EMerr_hndlr(! (1 & sts), *msg, EMS_E_Fail, ret_end);
	}

	sf_grid.osnum = env.md_id.osnum;

	for(i=0; i<trace_out.num_grps; i++)
	{
  	   sf_grid.objid = rule_ids[i];

           /* initialize is_single to TRUE. Meaning only one ruled surface
              is created from this group. is_single will get set to FALSE
              below the moment more than one ruled-surfaces are created.
           */
           is_single = TRUE;

	   for(j=0, prev_subgrp_elem=FALSE; 
			j<trace_out.num_subgrps_grp[i]; 
				    j++)
	   {
	      subgrp_rev = trace_out.subgrp_rev[i][j];
	      curr_intobj = trace_out.elems[i][j];

	      sts = om$send(msg = message EMSsubbs.EMget_props(&msg_loc,
					                          &props),
			       targetid = 
				  curr_intobj->this_obj_node->this_obj.objid,
			       targetos = 
				  curr_intobj->this_obj_node->this_obj.osnum);
	      EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);

	      pos_ornt1 = (props & EMSIS_NRML_REVERSED ? 0x1 : 0x0);

	      for(k=0, prev_elem=FALSE; k<trace_out.num_elems_subgrp[i][j]; 
			           k++, curr_intobj=curr_intobj->next)
	      {
		 if(curr_intobj->props & EMSintobj_tmpmarked) continue;

	         /* Create the ruled surface */
		 EFgen_ruled_sf(&msg_loc, curr_intobj, &env, &object,
				OM_Gw_current_OS, construct_list);
		 EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);
		 /* Get its edges */
		 sts = om$send(msg = message EMSsurface.EMmk_nat_bdry(&msg_loc,
				     &env.md_env, nat_edges),
			       targetid = object,
			       targetos = env.md_id.osnum);
		 EMerr_hndlr(! (1 & msg_loc & sts), *msg, EMS_E_Fail, ret_end);

		 /* set the orienation of logical normal of the ruled sf */

		 rev_connect = (curr_intobj->reversed ? FALSE : TRUE);

		 sts = om$send(msg = message EMSsubbs.EMget_props(&msg_loc,
					                          &props),
			       targetid = object,
			       targetos = env.md_id.osnum);
		 EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);

		 pos_ornt2 = (props & EMSIS_NRML_REVERSED ? 0x1 : 0x0);

		 rev_ornt = (rev_connect ? (pos_ornt1 ^ pos_ornt2 ? 
							      TRUE : FALSE) :
			                   (pos_ornt1 ^ pos_ornt2 ? 
							      FALSE : TRUE));

		 if(rev_ornt) /* reverse the normal orientation */
		 {
		    sts = om$send(msg = message EMSsubbs.EMrevorient(&msg_loc),
				  targetid = object,
				  targetos = env.md_id.osnum);
		    EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
		 }

		 /* Add the ruled surface to the composite rule_ids[i] */
		 sts = om$send(msg = message GRvg.GRrigidconn(&msg_loc,
				     &sf_grid, &maxint),
			       targetid = object,
			       targetos = env.md_id.osnum);
		 EMerr_hndlr(!(1 & msg_loc & sts), *msg, EMS_E_Fail, ret_end);

		 if(!prev_elem)
		 {
		    start_edge = (subgrp_rev ? nat_edges[2] : nat_edges[0]);
		    prev_edge  = (subgrp_rev ? nat_edges[0] : nat_edges[2]);
		    prev_elem = TRUE;
		 }
		 else
		 {
		    this_edge = (subgrp_rev ? nat_edges[2] : nat_edges[0]);
		    sts = om$send(msg = message EMSedge.EMconnect_edges(
					&msg_loc, EMED_REVERSE_CONNECT, FALSE,
					this_edge, NULL_OBJID, NULL_OBJID,
					&env.md_env),
				  targetid = prev_edge,
				  targetos = env.md_id.osnum);
		    EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);

		    prev_edge  = (subgrp_rev ? nat_edges[0] : nat_edges[2]);
                    is_single = FALSE;  /* More than one ruled surfaces have
                                           been created for the current group.
                                        */
		 } /* else of if(!prev_elem) */
	      } /* end of kth for-loop */

	      /* If no ruled surface was created using this sub-grp, then move
		 on to process the next sub-grp.
	      */
 	      if(!prev_elem) continue;

	      if(!prev_subgrp_elem)
	      {
	       /* This is the first sub-grp to be processed for the ith group.
		  Store the very first edge (to be later stitched with the
		  very last edge for the group.)
		*/
		first_edge = (subgrp_rev ? prev_edge : start_edge);
		prev_subgrp_elem = TRUE;
	      }
	      else
	      {
	      /* connect the prev_subgrp_edge with the start_edge of this
		 sub-group
	      */
		    this_edge = (subgrp_rev ? prev_edge : start_edge);
		    sts = om$send(msg = message EMSedge.EMconnect_edges(
					&msg_loc, EMED_REVERSE_CONNECT, FALSE,
					this_edge, NULL_OBJID, NULL_OBJID,
					&env.md_env),
				  targetid = prev_subgrp_edge,
				  targetos = env.md_id.osnum);
		    EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
                    is_single = FALSE;  /* More than one ruled surfaces have
                                           been created for the current group.
                                        */
	      }
	      prev_subgrp_edge = (subgrp_rev ? start_edge : prev_edge);
	   } /* end of jth for-loop */

	   if(!is_single)
	   {
	      /* connect the first ruled surface of this group with the last 
		 ruled surface of this group.
	      */
		 
	      sts = om$send(msg = message EMSedge.EMconnect_edges(
				  &msg_loc, EMED_REVERSE_CONNECT, FALSE,
				  first_edge, NULL_OBJID, NULL_OBJID,
				  &env.md_env),
			    targetid = prev_subgrp_edge,
			    targetos = env.md_id.osnum);
	      EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
	   }
	   /* else a single closed surface resulted from the ith group. This
	           surface would have two seam edges that are alredy common-
		   edge connected.
	   */

	   sts = EMconvert_into_plane(&msg_loc, NULL, NULL, NULL, NULL, NULL,
				      NULL, NULL, &env, sf_grid.objid,
				      env.md_id.osnum);
	   EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	} /* end of i for-loop */

	/* Now stitch the fcs, my offset (off_compsf) and all the ruled 
	   surfaces to create the shell solid
	*/

	count = trace_out.num_grps + 2;
	rule_ids = (GRobjid *) om$realloc(ptr = (IGRchar *) rule_ids,
					  size = count * sizeof(GRobjid));
	EMerr_hndlr(!rule_ids, *msg, EMS_E_NoDynamicMemory, ret_end);

	rule_ids[count - 2] = fcs_grid.objid;
	rule_ids[count - 1] = off_compsf;

	sts = om$construct(classid = OPP_EMSslstitch_class_id,
			   p_objid = &object,
			   osnum = construct_list->env_info->md_id.osnum,
			   msg = message EMSsfstitch.EMmake_comp(&msg_loc,
					 count, rule_ids, &env, NULL, NULL,
					 0, NULL, 0));
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

/* TBD ? check for free edges. If so error out */

	sts = om$send(msg = message EMSdpr.EMmake_primitive1(&msg_loc, &env, 
							     &fcs_grid),
		      targetid = object,
		      targetos = construct_list->env_info->md_id.osnum);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);


	/* Make sure the normals of the solid are pointing inwards */
	sts = om$send(msg = message EMSsolid.EMorient_yourself(&msg_loc, NULL,
							       &env),
		      targetid = fcs_grid.objid,
		      targetos = fcs_grid.osnum);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);


	*constructed_object = fcs_grid.objid;

ret_end:

#ifndef KEEP_SURFS_ON_ERR
	if(EMSerror(*msg))
	{
	  if(off_compsf != NULL_OBJID)
	     sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
						    construct_list->env_info),
			   targetid = off_compsf);

	  if(rule_ids)
	     for(i=0; i<trace_out.num_grps; i++)
	         sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
					     construct_list->env_info),
			       targetid = rule_ids[i]);
	}
#endif

/* 
      Free allocated memory....
*/
	for(sf_inters = off_inters; sf_inters; sf_inters=sf_inters->next)
	  for(curr_intobj=sf_inters->cvs; curr_intobj; 
					  curr_intobj=curr_intobj->next)
	    if(curr_intobj->more_info) 
	    {
		om$dealloc(ptr = curr_intobj->more_info);
		curr_intobj->more_info = NULL;
	    }

	if(surfs) om$dealloc(ptr = surfs);
	if(off_inters)
	{
	  EMinters_data_free(&msg_loc, off_inters, MAXINT, NULL, NULL);  
	  EMinters_free(off_inters, MAXINT);
	}
	if(rule_ids) om$dealloc(ptr = rule_ids);
        if(val_half_thick) om$dealloc(ptr = val_half_thick);
	if(tr_alloced)
	   EMsfinttrace_free(&msg_loc, trace_out.num_grps,
			     trace_out.num_subgrps_grp,
			     trace_out.num_elems_subgrp,
			     trace_out.elems,
			     trace_out.subgrp_rev,
			     trace_out.elem_rev,
			     trace_out.grp_closed,
			     trace_out.subgrp_closed);
	return(sts);
}

static void EFgen_ruled_sf(msg, in_intobj, env, rule_id, curr_osnum, cons)
IGRlong			*msg;
struct EMSintobj	*in_intobj;
struct GRmd_env		*env;
GRobjid			*rule_id;
GRspacenum		curr_osnum;
struct GRvg_construct	*cons;
{
	IGRlong			sts, msg_loc, rc;
	IGRint			pt_size, i, type;
	IGRdouble		dotp, dottol;
	IGRboolean		stat_func, co_plan, co_pn1;
	IGRpoint		cvs_end_pt[2];
	IGRvector		unit_norm1, unit_norm2;
	struct GRid		ed_grid[2];
	struct IGRbsp_curve	*ed_crv[2], *curve1, *curve2, *merged_cv, *ln,
				*cv_array[2], **cv_array_ptr;
	struct EMSintobj	*p_intobj;

	void			EFcvt_edge_to_cv();

	*msg = EMS_S_Success;
        cv_array_ptr = cv_array;
	ed_crv[0] = ed_crv[1] = curve1 = curve2 = ln = merged_cv = NULL;
	pt_size = 3 * sizeof(IGRdouble);
	dottol = cos ((90.0 - EMS_ZEROANGLE_DEG) * (M_PI/180.0));

	ed_grid[0].objid = in_intobj->this_uvintobj.data.object->objid;
	ed_grid[0].osnum = in_intobj->this_uvintobj.data.object->osnum;
	ed_grid[1].objid = * (GRobjid *) in_intobj->more_info;
	ed_grid[1].osnum = curr_osnum;

        EFcvt_edge_to_cv(&msg_loc, NULL, ed_grid[0], NULL,
                                                 &ed_crv[0], &env->md_env);
        EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);
        EFcvt_edge_to_cv(&msg_loc, NULL, ed_grid[1], NULL,
                                                 &ed_crv[1], &env->md_env);
	EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);

	if(in_intobj->reversed)
	{
	  BSrev_cv(&rc, ed_crv[0]);
	  EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
	  BSrev_cv(&rc, ed_crv[1]);
	  EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
	}

	for(i=0; i<3; i++)
	{
	   cvs_end_pt[0][i] = (ed_crv[0]->rational ? 
			       ed_crv[0]->poles[i]/ed_crv[0]->weights[0] :
			       ed_crv[0]->poles[i]);
	   cvs_end_pt[1][i] = (ed_crv[1]->rational ? 
			       ed_crv[1]->poles[i]/ed_crv[1]->weights[0] :
			       ed_crv[1]->poles[i]);
	}
	BSalloccv(2, 2, FALSE, (IGRshort)0, &ln, &rc);
	EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
	stat_func = BSptlngen(&rc, cvs_end_pt[0], cvs_end_pt[1], ln, &type);
	EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
	co_plan = BScvcoplan(&rc, ed_crv[0], ln, unit_norm1);

	curve1 = ed_crv[0];
	curve2 = ed_crv[1];

	in_intobj->props |= EMSintobj_tmpmarked;

	if(co_plan)
	{
	/* Now chain the incoming intobj with its backward and forward intobjs
	   should they be co-planar with "ln"
	*/
	  for(i=BWD; i<=FWD; i++)
	    for(p_intobj=(i==BWD ? in_intobj->bwd:in_intobj->fwd); 
			!(p_intobj->props & EMSintobj_tmpmarked);
				p_intobj=(i==BWD ? p_intobj->bwd:p_intobj->fwd))
	    {
		ed_grid[0].objid = p_intobj->this_uvintobj.data.object->objid;
		ed_grid[0].osnum = p_intobj->this_uvintobj.data.object->osnum;
		ed_grid[1].objid = * (GRobjid *) p_intobj->more_info;
		ed_grid[1].osnum = curr_osnum;

                EFcvt_edge_to_cv(&msg_loc, NULL, ed_grid[0], NULL, &ed_crv[0],
                                 &env->md_env);
		EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);
		if(p_intobj->reversed)
		{
	  	  BSrev_cv(&rc, ed_crv[0]);
	  	  EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
		}
		co_pn1 = BScvcoplan(&rc, ed_crv[0], curve1, unit_norm2);
                if(co_pn1)
		{
		   /* Curves are Co-planar ! */
		   dotp = fabs(BSdotp(&rc, unit_norm1, unit_norm2));
		   if(( 1.0 - dotp ) < dottol)
		   { 
		   /* The ruled surfaces from these two curves will be coplanar.
		      Merge ed_crv[0] with curve1 and ed_crv[1] with curve2.
		   */

                     EFcvt_edge_to_cv(&msg_loc, NULL, ed_grid[1], NULL,
                                      &ed_crv[1], &env->md_env);
		     EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);
		     if(p_intobj->reversed)
		     {
	  	       BSrev_cv(&rc, ed_crv[1]);
	  	       EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
		     }
		     cv_array[0] = (i==BWD ? ed_crv[0] : curve1);
		     cv_array[1] = (i==BWD ? curve1 : ed_crv[0]);

		     merged_cv = NULL;
		     BSmergarrcv(2, cv_array_ptr, &merged_cv, &rc);
                     if(BSERROR(rc)) break;
		     /* EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end); */

		  /* Deallocate curve1 and ed_crv[0] */
		     om$dealloc(ptr = ed_crv[0]->poles);
		     om$dealloc(ptr = ed_crv[0]->knots);
		     if(ed_crv[0]->rational)om$dealloc(ptr = ed_crv[0]->weights);
		     om$dealloc(ptr = curve1->poles);
		     om$dealloc(ptr = curve1->knots);
		     if(curve1->rational)om$dealloc(ptr = curve1->weights);
		     om$dealloc(ptr = ed_crv[0]);
		     om$dealloc(ptr = curve1);
		     ed_crv[0] = NULL;

		     curve1 = merged_cv;

		     cv_array[0] = (i==BWD ? ed_crv[1] : curve2);
		     cv_array[1] = (i==BWD ? curve2 : ed_crv[1]);
		     merged_cv = NULL;
		     BSmergarrcv(2, cv_array_ptr, &merged_cv, &rc);
		     EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);

		  /* Deallocate curve2 and ed_crv[1] */
		     om$dealloc(ptr = ed_crv[1]->poles);
		     om$dealloc(ptr = ed_crv[1]->knots);
		     if(ed_crv[1]->rational)om$dealloc(ptr = ed_crv[1]->weights);
		     om$dealloc(ptr = curve2->poles);
		     om$dealloc(ptr = curve2->knots);
		     if(curve2->rational)om$dealloc(ptr = curve2->weights);
		     om$dealloc(ptr = ed_crv[1]);
		     om$dealloc(ptr = curve2);
		     ed_crv[1] = NULL;

		     curve2 = merged_cv;
		  } /* if( (1.0 - dotp) < dottol ) */
		  else
		     break;  /* Stop Chaining */
		}
		else
		   break;     /* Not co-planar! Stop chaining. */

		p_intobj->props |= EMSintobj_tmpmarked;
	   } /* for(p_intobj=in_intobj......) */
	} /* if(co_plan) */

/*  Curves are oriented correctly. No need to pass the end-point info.
    Hence commented out.... Ashok 07-Sep-93.
	OM_BLOCK_MOVE(&curve1->poles[0], cvs_end_pt[0], pt_size);
	OM_BLOCK_MOVE(&curve2->poles[0], cvs_end_pt[1], pt_size);
*/
	sts = om$construct(classid = OPP_EMSgenbs_class_id,
		       p_objid = rule_id, osnum = env->md_id.osnum,
		       msg = message EMSgenbs.EMruled_surface(
			     curve1, NULL, curve2, NULL, 0, NULL, NULL,
			     /* cvs_end_pt */ NULL,
			     TRUE, /* orientation flag */
			     FALSE, FALSE, /* not reversed -- keep direction */
			     FALSE, FALSE, /* not used */
			     cons, &msg_loc) );
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);


ret_end:
/* Deallocate curve1 and curve2. Free ln */
	if(curve1)
	{
	   if(curve1->poles) om$dealloc(ptr = curve1->poles);
	   if(curve1->knots)om$dealloc(ptr = curve1->knots);
	   if(curve1->rational)om$dealloc(ptr = curve1->weights);
	   om$dealloc(ptr = curve1);
	}
	if(curve2)
	{
	   if(curve2->poles) om$dealloc(ptr = curve2->poles);
	   if(curve2->knots)om$dealloc(ptr = curve2->knots);
	   if(curve2->rational)om$dealloc(ptr = curve2->weights);
	   om$dealloc(ptr = curve2);
	}

	if(ln) BSfreecv(&rc, ln);

	return;
}
end implementation EMScompsurf;

