/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
		
 	This function finds closed paths, given a bunch of edges. The edges
	 the caller passes should form a closed path, hence the function
	 just determines and returns the sequence of edges in the closed
	 path.


NOTES
=====
	
   	The caller takes is responsible for the unreliable behaviour of the
     function if the input edges donot form a closed path.


ARGUMENTS
=========
	
    VARIABLE				MODE	DESCRIPTION
    --------                ----    -----------
	EMmsg					Output  1)EMS_S_Success If all is well.
									2)EMS_E_DynamicMemoryAllocated If no
									 memory allocated.
									3)EMS_E_EdgeError If call EMgetvtxedges()
									  fails.
									4)EMS_E_SurfaceError If number of eds
									 in pathes > num input edges.
									5)EMS_E_OMerror On OM error.

	edges					Input   Pointer to arrary of ed GRid pointers.

	num_edges				Input	Number of edges.

	surf_list				Input	Pointer to array of surface ids contr-
									 buting the edges.

	numed_list				Input	Number of edges in the edges array 
									 contributed by surf in surf_list.

	num_surfs				Input	Number of surfaces contributing eds.

	cap_eds					Output	Refer to EMScap.h in "old_include" for
									 the struct: EMcap_ed_sf.
									 The ed and sf field are filled with
									 the edge id and surface it belongs.

	num_caps				Output	Number of closed paths formed by the 
									 input edges.

	num_edges_in_cap		Output	Number of edges in the closed paths.
									ie: num_edges_in_cap[0]+ .. + num_ed-
									 ges_in_cap[num_caps -1] = number of 
									 edges in cap_eds structure.
		
	our_os					Input   Pointer to object space number.


RETURN VALUE
============

	OM_stat			OM_S_SUCCESS    If all is well.
				    OM_E_ABORT      If any error ( OM or EMS ).


HISTORY
=======
	
	SAM		20-Oct-87	Creation.
    gupta   05/12/88   added arguement to EMgetvtxedges call.
*/

class implementation EMSedge;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "EMScap.h"

%safe
static IGRlong EMgivesfid();
static IGRlong EMkilledge();
static IGRlong EMgiverefedge();
static IGRlong EMcheckconn();
%endsafe

#define DEBUG		1
# if DEBUG
	#include <stdio.h>
#endif

#define ZERO 		0
#define BEG  		0
#define END  		1
#define CAP_INCR	4
#define search_end(ed1par, ed2par, search_par)\
	((ed1par) == (ed2par) ? ((search_par) ? BEG : END) : search_par)

IGRlong EMedfindloop(EMmsg, edges, num_edges, surf_list, numed_list, 
					 num_surfs, cap_eds, num_caps, num_edges_in_cap,
					 our_os)

IGRlong 			*EMmsg;
struct  GRid		**edges;
IGRint				*num_edges, *num_caps,**num_edges_in_cap, *numed_list,
					num_surfs;
struct  EMcap_ed_sf *cap_eds;
GRobjid				*surf_list;
GRspacenum			*our_os;
{

GRobjid 			current_edge, ref_edge, *co_edges;
IGRboolean 			*right_vtx, cap_found = FALSE;
IGRlong 			OM_stat, mthd_stat;
IGRint				num_co_edges;
IGRuint		num_cp_eds, ed_num;
IGRushort   opt;



OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

if(*num_edges_in_cap == NULL)
{
	num_cp_eds = ZERO;
	cap_found = TRUE;
	
	*num_edges_in_cap = (IGRint *) om$malloc (size = (unsigned)
		    		     (CAP_INCR * sizeof (IGRint)));

	EMerr_hndlr(!*num_edges_in_cap, *EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
}

while( (*num_edges != num_cp_eds ) || (!cap_found) )
{
if(cap_found)
{
	OM_stat = EMgiverefedge(&ref_edge, edges, num_edges, &ed_num);
	EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

	cap_eds[num_cp_eds].ed = ref_edge;
	OM_stat = EMgivesfid(ed_num, surf_list, numed_list,
						 num_surfs, &(cap_eds[num_cp_eds].sf));
	EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

	num_cp_eds + = 1;
	(*num_edges_in_cap)[*num_caps] = 1;
	current_edge = ref_edge;
	opt = BEG;
	cap_found = FALSE;
}

num_co_edges = ZERO;
OM_stat = om$send(msg = message EMSedge.EMgetvtxedges(
					&mthd_stat,
					EMSvtxedges_nodegenerate,
					opt,
					0,
					&num_co_edges,
					&co_edges,
					&right_vtx),
				  senderid = NULL_OBJID,
				  targetid = current_edge,
				  targetos = *our_os);
EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

if(num_co_edges % 2) 
{
	cap_found = TRUE;
	*num_caps + = 1;
}
else
{
	current_edge = co_edges[num_co_edges -1 ];
	opt = search_end(right_vtx[num_co_edges -1 ], right_vtx[0], opt);
}
if(co_edges)  om$dealloc (ptr = co_edges);
if(right_vtx) om$dealloc (ptr = right_vtx);
co_edges = NULL;
right_vtx = NULL;

if(!cap_found)
{
	if(current_edge == ref_edge)
	{
		cap_found = TRUE;
		*num_caps + = 1;
	}
	else
	{
		EMkilledge(&current_edge, edges, num_edges, &ed_num);
		cap_eds[num_cp_eds].ed = current_edge;
		OM_stat = EMgivesfid(ed_num, surf_list, numed_list,
						 	 num_surfs, &(cap_eds[num_cp_eds].sf));
		EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

		num_cp_eds + = 1;
		(*num_edges_in_cap)[*num_caps] + = 1;
	}
}
if(cap_found)
{
	if(!(*num_caps % CAP_INCR))
	{
	*num_edges_in_cap = (IGRint *) om$realloc (ptr = (IGRchar *)*num_edges_in_cap,
						  size = (unsigned) ((*num_caps + CAP_INCR) *
						   sizeof (IGRint)));

	EMerr_hndlr(!*num_edges_in_cap, *EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
    }
}
		
if(num_cp_eds > *num_edges) 
  EMerr_hndlr(TRUE, *EMmsg, EMS_E_SurfaceError, wrapup);

} /* while */

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSedge.EMedfindloop");
  return(OM_stat);
}

static IGRlong EMgivesfid(ed_num, surf_list, numed_list, num_surfs, sfid)
GRobjid *surf_list, *sfid;
IGRint  *numed_list, num_surfs;
IGRuint ed_num;
{
IGRint i, total_eds;
IGRlong OM_stat = OM_E_ABORT;
 total_eds = 0;
 for(i = ZERO; i<= num_surfs -1; i++)
 {
	total_eds + = numed_list[i];

	if(ed_num <= total_eds)
	 {
		OM_stat = OM_S_SUCCESS;
		*sfid = surf_list[i];
		break;
	 }
 }
if(!(1&OM_stat))
{
	#if DEBUG
		fprintf(stderr, "EMSedge.EMedfindloop.EMgivesfid");
	#endif
}
return(OM_stat);
}


static IGRlong EMgiverefedge(ed_id,scan_address, num_edges, ed_num)
GRobjid *ed_id;
struct GRid **scan_address;
IGRint  *num_edges;
IGRuint *ed_num;
{
IGRint i;
IGRlong OM_stat = OM_E_ABORT;

 for(i = ZERO; i<= *num_edges -1; i++)
 {
	if((*scan_address)[i].objid != NULL_OBJID) 
	 {
		OM_stat = OM_S_SUCCESS;
		*ed_id = (*scan_address)[i].objid;
		(*scan_address)[i].objid = NULL_OBJID;
		*ed_num = i + 1;
		break;
	 }
 }
if(!(1&OM_stat))
{
	#if DEBUG
		fprintf(stderr, "EMSedge.EMedfindloop.EMgiverefedge");
	#endif
}
return(OM_stat);
}



static IGRlong EMkilledge (ed_id, scan_address, num_edges, ed_num)
GRobjid *ed_id;
struct GRid  **scan_address;
IGRint  *num_edges;
IGRuint *ed_num;
{
IGRint i;
IGRlong OM_stat = OM_E_ABORT;

 for(i = ZERO; i<= *num_edges -1; i++)
 {
	if((*scan_address)[i].objid == *ed_id) 
	 {
		OM_stat = OM_S_SUCCESS;
		(*scan_address)[i].objid = NULL_OBJID;
		*ed_num = i + 1;
		break;
	 }
 }
if(!(1&OM_stat))
{
	#if DEBUG
		fprintf(stderr, "EMSedge.EMedfindloop.EMkilledge");
	#endif
}
return(OM_stat);
}


static IGRlong EMcheckconn (msg, ed_id, is_true)
IGRlong *msg;
GRobjid *ed_id;
IGRboolean *is_true;
{
IGRlong 		OM_stat;
OM_S_CHANSELECT 	cm_ed_chan;
IGRint 			count;

*msg = EMS_S_Success;
OM_stat = OM_S_SUCCESS;

*is_true = FALSE;
OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

OM_stat = om$get_channel_count(objid = *ed_id, p_chanselect = &cm_ed_chan,
			 count = (OMuint *)&count);
EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
if(!count) *is_true = TRUE;

wrapup:
		EMWRAPUP(*msg, OM_stat, "EMSedge.EMfindloop.EMcheckconn");
		return(OM_stat);
}

end implementation EMSedge;
