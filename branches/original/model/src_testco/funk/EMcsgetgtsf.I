class implementation ECcsoffset;
/*
HISTORY:

	05/28/93: sampath  : Creation.
	09/17/93: sampath  : Changed function names.
        12/03/93: sudhakar : Added a new function for finding the 
                             average normal for arrow display.
        01/11/94: sudhakar : Modified due to arg. changes to the function
                             "EFget_edge_info()".
*/


#include <stdio.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "exmacros.h"
#include "msdef.h"
#include "emssfintdef.h"
#include "EMSopt.h"
#include "EMSprop.h"

#define XYZ_POINT   1
#define UV_POINT    2

from EMSsurface import 	EMgetedges;
from EMSedge	import	EMchkconvex,EMgetsurface_info;
from EMSboundary import EMget_objid;

from GRowner	import	GRget_number_components, GRget_components;
from EMSloopset	import	EMget_loops;
from EMSsubbs   import  EMget_unit_norm;
/*

	This function returns connected tangent surfaces of a surface.

	Input		surface		Id of the surface.
	Output		new_surfaces	Ids of tangent surfaces.
	Output		*num_new_sfs	Number of tangent surfaces returned.

*/

void EMget_tgt_surfaces(msg,surface,surface_osnum,new_surface,
				num_new_sfs,p_mattyp,matrix)
IGRlong		*msg;
GRobjid		surface, **new_surface;
GRspacenum	surface_osnum;
IGRint  	*num_new_sfs;
IGRshort	*p_mattyp;
IGRmatrix	matrix;

{
	struct list_node
	{
		GRobjid objid;
		struct  list_node *next;
	};
	struct    list_node	*list,*new_node,*p_node,*p_node1;
	int   			node_count = 0;
	OM_S_CHANSELECT		chan_to_cm_ed;
	struct	  GRid		*edges=NULL,comm_surf,comm_ed;
	GRobjid			*new_surfaces=NULL;
	IGRint			num_edges=0,buf_size=0;
	IGRlong			sts,msg_loc;
	int			i;
	IGRboolean		convex = FALSE,
				neutral = FALSE;

	*msg = EMS_S_Success;
	list=NULL;
	sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
				EMS_OPT_STITCHED,
                                &edges, &buf_size, &num_edges,
				NULL,NULL,NULL,NULL),
				senderid = NULL_OBJID,
                           	targetos = surface_osnum,
                           	targetid = surface);

	EMerr_hndlr(!(1&sts&msg_loc),*msg,EMS_E_OMerror,ret_end);

	
	for(i=0;i<num_edges;i++)
	{
		sts  = om$send(msg = message EMSedge.EMchkconvex(&msg_loc,
                                NULL, p_mattyp, matrix,
                                EMS_ZEROANGLE_DEG, &convex,
                                &neutral, NULL),
				senderid = NULL_OBJID,
				targetos = edges[i].osnum,
				targetid = edges[i].objid);
		EMerr_hndlr(! (1 & sts & msg_loc), *msg,
				EMS_E_EdgeError, ret_end);



		if(neutral)
		{
			EMmake_chanselect (EMSedge_to_common_edge,
				&chan_to_cm_ed);
                 	comm_ed.osnum = edges[i].osnum;
                 	sts = om$send(msg = message EMSboundary.EMget_objid(
				&msg_loc,
                                &comm_ed.objid),
                                senderid = edges[i].objid,
                                targetos = edges[i].osnum,
                                p_chanselect = &chan_to_cm_ed);
	                EMerr_hndlr(EMSerror (sts & msg_loc), *msg, 
				EMS_E_EdgeError, ret_end);

                 	comm_surf.osnum = edges[i].osnum;
                 	sts = om$send(msg = message EMSedge.EMgetsurface_info(
				&msg_loc,
				&comm_surf.objid, NULL),
				senderid = NULL,
                              	targetid = comm_ed.objid,
                              	targetos = comm_ed.osnum);
                 	EMerr_hndlr(EMSerror (sts & msg_loc), *msg,
				EMS_E_EdgeError, ret_end);

			new_node = (struct list_node *) om$malloc(size =
				sizeof(struct list_node));
			new_node->objid = comm_surf.objid;
			new_node->next = list;
			list = new_node;
			node_count++;
		}
	}
	*num_new_sfs = node_count;
	if(node_count)
	{
		new_surfaces = (GRobjid *)om$malloc(size =
			node_count*sizeof(GRobjid));
		p_node=list;
		for(i=0;i<node_count;i++)
		{
			new_surfaces[i] = p_node->objid;
/*
			p_node1 = p_node;
*/
			p_node = p_node->next;
/*
			om$dealloc(ptr = p_node1);
*/
		}
	}
	*new_surface = new_surfaces;
ret_end:
	if(edges)
		om$dealloc(ptr = edges);
	if(list)
	{
		p_node = list;
		while(p_node!=NULL)
		{
			p_node1 = p_node;
			p_node = p_node->next;
			om$dealloc(ptr = p_node1);
		}
	}

}


/*
	This funcion attaches array new_surface to end of array 
	surface eliminating duplicate values in the resulting array.
	Number of added values to array is returned in *added_sfs.
	num_sfs and num_new_sfs are sizes of surface and new_surface
	respectively.

	if num_new_sfs == 0 the effect is undefined.
*/

void EMattach_surfaces(surface1,num_sfs,new_surface,num_new_sfs,added_sfs)
GRobjid 	**surface1, *new_surface;
IGRint  	num_sfs, num_new_sfs, *added_sfs;
{
	int 	count=0,found=0;
	int 	i,j;
	GRobjid	*surface;

	surface = *surface1;
	for(i=0;i<num_new_sfs;i++)
		for(j=0;j<num_sfs;j++)
			if(new_surface[i]==surface[j])
				count++;
	count = num_new_sfs - count;
	surface = (GRobjid * ) om$realloc(ptr = (char *) surface ,
			size = (num_sfs + count)*sizeof(GRobjid));
	*added_sfs = count;
	count = num_sfs;
	for(i=0;i<num_new_sfs;i++)
	{
		for(j=0;j<num_sfs;j++)
			if(new_surface[i]==surface[j])
			{
				found = 1;
				break;
			}
		if(found) 
			found = 0;
		else
			surface[count++]=new_surface[i];
	}
	*surface1 = surface;
}

/*
	This function tests whether the given composite surface 
	has any c loops on its surfaces.

	is_c_loop	1 if c loop is present 0 otherwise (out put).
	compsf		composite surface (input).
*/

void EMtest_any_c_loops(msg,compsf,is_c_loop,mod_env)
IGRlong		*msg;
struct	GRid	compsf;
IGRboolean	*is_c_loop;
struct GRmd_env	*mod_env;

{

	IGRint		numsf,num_loops;
	IGRlong		msg_loc,sts;
	struct	GRid	*surfs = NULL;
	GRobjid		*loop_ids=NULL;
	IGRushort	*props;
	IGRint		depth;
	OM_S_CHANSELECT	chan_to_loopset;
	IGRint		sfcount,buff_size;
	int		i,j;
	OMuint		count,num_loopset;
	OM_S_OBJECT_LINKAGE  *owner_comps=NULL;


	*is_c_loop = 0;
	EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
	sts = om$send( msg = message GRowner.GRget_number_components(
			&msg_loc, &numsf ),
			senderid = NULL_OBJID,
			targetos = compsf.osnum,
			targetid = compsf.objid );
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	surfs =	(struct	GRid *)	om$malloc(size = numsf * sizeof(struct GRid));
	EMerr_hndlr(!surfs, *msg, EMS_E_NoDynamicMemory,
			ret_end);


	sts = om$send( msg = message GRowner.GRget_components( &msg_loc,
			mod_env, surfs, numsf, &sfcount,
			NULL, OM_K_MAXINT ),
			senderid = NULL_OBJID,
			targetos = compsf.osnum,
			targetid = compsf.objid );
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	for(i=0;i<numsf;i++)
	{
                owner_comps = NULL;   /* added by Sudhakar */
		loop_ids = NULL;
		depth = MAXINT;
		buff_size = 0;
		props = NULL;
		count = 0;


		om$get_channel_count (objid = surfs[i].objid, osnum =
			surfs[i].osnum, p_chanselect = &chan_to_loopset,
			count = &count);

		if(count)
		{
		owner_comps = (OM_S_OBJECT_LINKAGE *) malloc
			(count * (sizeof (OM_S_OBJECT_LINKAGE)));
		om$get_channel_objects (objid = surfs[i].objid,
			osnum = surfs[i].osnum, p_chanselect =
			&chan_to_loopset, count = &num_loopset, size = count,
			list = owner_comps);

		sts = om$send(msg = message EMSloopset.EMget_loops( &msg_loc,
			EMS_OPT_CLOOP, &depth, &loop_ids, &props,
			&buff_size, &num_loops),
			senderid = NULL_OBJID,
			targetos = owner_comps->osnum,
			targetid = owner_comps->S_objid);
		EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopsetError,
			ret_end);
		for(j=0;j<num_loops;j++)
		{
		    	/* c loops encountered */
			*is_c_loop = 1;
#ifdef DEBUG
printf("surface id %d c loop found\n",surfs[i].objid);
#endif
		}
		} /* if count */
		if(owner_comps)
			free(owner_comps);
		if(loop_ids)
			om$dealloc(ptr = loop_ids);
                /* fix for mlk */
                if(props)
		 {
		 om$dealloc(ptr = props);
		 props = NULL;
		 }
	}
ret_end :
	if(surfs)
		om$dealloc(ptr = surfs);

}

/****************************************************************

NAME:
   EFfind_average_arrow_normal

ALGORITHM:

          To display an average arrow direction:
           a) obtain nearest edge,
           b) check whether it has a common edge.
              if(common edge present)
                 get the surface normal(surf_nor2) of the other surface
                 compute the average surface normal based on surf_nor and
                   surf_nor2.
              else
                 take surf_nor as the average surface normal.
********************************************************************/

IGRlong EFfind_average_arrow_normal(msg, mdenv, object, surf_grid, pt_on_surf, 
                                                            avg_normal)
IGRlong          *msg;
struct GRmd_env  *mdenv;
struct GRid      object, surf_grid;
IGRpoint         pt_on_surf;
IGRvector        avg_normal;
{

   IGRlong      stat_OM, msg_loc;
   IGRpoint     this_edge_point;
   struct GRid  edge, comm_ed, comm_surf;
   IGRushort    ed_props, cm_ed_props;
   IGRboolean   is_free, neutral, convex, out_solid, near_edge;
   IGRdouble    surf_nor1[3], surf_nor2[3];
   IGRint       ii;

   extern IGRlong EFget_edge_near_point_on_sf();
   extern IGRlong          EFget_edge_info();

   *msg = EMS_S_Success;
   stat_OM = OM_S_SUCCESS;

  /* Find the nearest edge on the surface */
   near_edge = FALSE;
   edge.osnum = surf_grid.osnum;
   stat_OM = EFget_edge_near_point_on_sf(&msg_loc, mdenv,
                                          surf_grid,
                                          XYZ_POINT,
                                          pt_on_surf,
                                          &near_edge,
                                          &edge.objid, NULL,
                                          (IGRdouble *) this_edge_point);
   EMerr_hndlr (EMSerror (stat_OM & msg_loc),
                                    *msg, EMS_E_EdgeError, ret_end);

   if(near_edge)
      for(ii=0; ii<3; ii++)
          pt_on_surf[ii] = this_edge_point[ii];

  /* Obtain the edge properties, and the common-edge and surface 
     if they exist or if the common surface is relevant. */
   if((object.objid != surf_grid.objid) && near_edge)
   {
     IGRboolean   spec_tan;

     comm_surf.osnum = comm_ed.osnum = surf_grid.osnum;
     stat_OM = EFget_edge_info(&msg_loc,
                              &mdenv->md_env.matrix_type,
                              mdenv->md_env.matrix, 
                              edge, &comm_ed, &comm_surf, &ed_props,
                              &is_free, &convex, &neutral, &spec_tan, NULL,
                              NULL, &cm_ed_props);
     EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg,EMS_E_EdgeError,ret_end);
   }

  /* Get the surface normal of this surface at the appropriate point
     on the edge. */

   out_solid = FALSE;
   stat_OM = om$send (msg = message EMSsubbs.EMget_unit_norm
                    (&msg_loc, out_solid, NULL,
                     &mdenv->md_env,
                     (IGRdouble *)this_edge_point,
                     &surf_nor1[0]),
             senderid = NULL_OBJID,
             targetid = surf_grid.objid,
             targetos = surf_grid.osnum);

   EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

   if(is_free || neutral || (object.objid == surf_grid.objid) || !near_edge)
   {
      for(ii=0; ii<3; ii++)
           avg_normal[ii] = surf_nor1[ii];
#ifdef DEBUG
  printf("Is Free or Neutral or Single Surface :\n");
  for(ii=0; ii<3; ii++)
     printf("avg_normal[ii] = %lg\n", avg_normal[ii]); 
#endif
   }

  /* Get the surface normal of other surface at the appropriate point
     on the edge. */

   else if(comm_surf.objid != NULL_OBJID && comm_ed.objid != NULL_OBJID)
   {
     
      out_solid = FALSE;
      stat_OM = om$send (msg = message EMSsubbs.EMget_unit_norm
                    (&msg_loc, out_solid, NULL,
                     &mdenv->md_env,
                     (IGRdouble *)this_edge_point,
                     &surf_nor2[0]),
                senderid = NULL_OBJID,
                targetid = comm_surf.objid,
                targetos = comm_surf.osnum);
      
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

      for(ii=0; ii<3; ii++)
           avg_normal[ii] = (surf_nor1[ii] + surf_nor2[ii])/2.0;
#ifdef DEBUG
  printf("Common_surf :\n");
  for(ii=0; ii<3; ii++)
     printf("avg_normal[ii] = %lg\n", avg_normal[ii]); 
#endif

   }
   else
   {
      *msg = EMS_E_Fail;
      goto ret_end;
   }

   /* Normalize the output vector */

   BSnorvec(&msg_loc, avg_normal);

ret_end:

 return(stat_OM);

}

end implementation ECcsoffset;
