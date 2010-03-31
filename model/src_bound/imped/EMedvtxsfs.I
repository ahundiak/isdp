class implementation EMSedge;

/*
 * This method would return the number of surfaces and ids of the 
 * surfaces at a vertex. It also retunrs a flag indicating whether the vertex
 * has got any open side. 

 *Inputs:- 
          EMmsg             return code.
          options           an ption argument - not used at present.
          is_stop_end       TRUE if the vertex at the stop end of the edge,
			    FALSE otherwise.
          
 * Outputs :- 
	  num_surfaces      number of surfaces returned, MUST BE initialised
			    to zero before calling. 
          sf_ids            array of surface ids.(memmory is allocated inside
			    the method, caller has the reposibility of 
			    'free'-ing it.
          is_vtx_closed     flag indicating if the vertex has got any 'open'
			    side. (e.g. for a solid  "is_vtx_closed" will 
			    always be TRUE).
          
 * History :-

   Inasu : 05/16/91     : Creation.
 
 */

#include  "OMmacros.h"
#include  "EMSprop.h"
#include  "EMSopt.h"

/*imports   */


#define    BUFF_INCR    8
/* macros, if any */

method EMget_vtx_sfs(  IGRlong      *EMmsg;
                       IGRushort options;
		       IGRboolean   is_stop_end;
		       IGRint       *num_surfaces;
		       GRobjid     **sf_ids;
		       IGRboolean   *is_vtx_closed)
{
 IGRlong msg, om_stat;
 IGRint i, num;
 IGRint num_skipped,num_return;
 GRobjid surface_id;
 OM_S_CHANSELECT to_comm_edge;
 IGRboolean  is_right_vtx;
 IGRushort my_props, next_props;
 GRobjid current_edge,next_edge;


  *EMmsg = EMS_S_Success;
  om_stat = OM_S_SUCCESS;

  EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);

  is_right_vtx = is_stop_end;
  current_edge = my_id;
  my_props     = ME.EMSedge->ed_props;

  /* check the incoming data and allocate or reallocate memory if required.*/ 

   
      if ( !(*num_surfaces % BUFF_INCR) )
      {
       if ( *num_surfaces == 0 ) /* first in the recursive call */
         *sf_ids = (GRobjid *) om$malloc (size = BUFF_INCR * sizeof(GRobjid));
       else
        *sf_ids = (GRobjid *) om$realloc (ptr = (IGRchar *)*sf_ids, 
			 size= (*num_surfaces + BUFF_INCR) * sizeof(GRobjid));
       EMerr_hndlr( !(*sf_ids), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
   
      /* Get the surface id of myself */

      om_stat = om$send (msg = message EMSboundary.EMgetsurface_info( &msg,
					&surface_id,NULL),
        		      targetid = my_id);
      EMerr_hndlr( !(1&om_stat&msg), *EMmsg, EMS_E_EdgeError, wrapup);

      /* add the surface id to the array, if it is not already in the list */   

     for(i=0; i < *num_surfaces; i++)
      if(IF_EQ_OBJID((*sf_ids)[i],surface_id))  goto wrapup;

         (*sf_ids)[*num_surfaces] = surface_id;
         (*num_surfaces)++;
 
      /* get the next edge in the loop at the vertex */

      om_stat = EMgetnxtedges(&msg ,(options = EMSvtxedges_nodegenerate),
			    current_edge, OM_Gw_current_OS, is_right_vtx,
			    1, &num_return, &next_edge,&next_props,
			    &num_skipped);
      EMerr_hndlr( !(1&om_stat&msg), *EMmsg, EMS_E_EdgeError, wrapup);

      /* get the common edge of the next edge  */
     
      num = 0;
      om_stat = om$get_channel_count( osnum = OM_Gw_current_OS,
				    objid = next_edge,
				    p_chanselect = &to_comm_edge,
				    count        = (OMuint *)&num  );
      EMerr_hndlr( !(1&om_stat&msg), *EMmsg, EMS_E_OMerror, wrapup);

      if(num)
      {
         if( !(next_props & EMED_REVERSE_CONNECT))
            is_right_vtx =  ! is_right_vtx;
       
         /* send the message across the common edge_channel */

         om_stat = om$send (msg = message EMSedge.EMget_vtx_sfs(&msg,
						options,
						is_right_vtx,
						num_surfaces,
						sf_ids,
						is_vtx_closed ),
			     senderid      = next_edge,
			     p_chanselect = &to_comm_edge);
	                   	
       }
        else  { *is_vtx_closed = FALSE; goto wrapup; }

wrapup:

 return(om_stat);
}

end implementation EMSedge;
