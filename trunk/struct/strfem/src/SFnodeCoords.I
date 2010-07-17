class implementation  Root;
/* -------------------------------------------------------------------------
   Doc : SFgetNodalCoords

   Description : This function gets the coordinates of nodes on a
		 given mesh.
   History :
   06-20-1994	Raju	Creation

   Note :  Memory is allocated by this function for 'coords'. It should be
	   freed by the caller using

	   if ( coords )  free ( coords );
------------------------------------------------------------------------- */

#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "msdef.h"
#include  "OMerrordef.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "gr.h"

#include  "vderrmacros.h"
#include  "EMSmsgdef.h"

%safe
#include  "stdlib.h"
%endsafe



extern OM_S_CHANSELECT  APmesh_to_node_CS;

from  APnode   import	get_coord;

long  SFgetNodalCoords (
  long		*msg,			/* O - return status		*/
  struct  GRid  *mesh_grid,		/* I - mesh object 		*/
  int		*nb_nodes,		/* O - No. of nodes on the mesh */
  double	**coords		/* O - coordinates of nodes     */
)
{
  long		sts;
  int		nb_nd, ii;
  OM_S_OBJECT_LINKAGE   *ndObjLinkage = NULL;


  *msg = MSSUCC;

  sts = om$get_channel_count(	  osnum           = mesh_grid->osnum,
				  objid           = mesh_grid->objid,
				  p_chanselect    = &APmesh_to_node_CS,
				  count           = (OMuint *) nb_nodes ) ;
  VDS_ERR_HNDLR ( "APmesh_to_node_CS count", sts, MSSUCC, VD_VERBOSE, wrapup );

  if ( *nb_nodes <= 0 )  goto wrapup;  /* no new nodes created */

  /*
   * allocate memory for object ids and user ids
   */
  ndObjLinkage = (OM_S_OBJECT_LINKAGE *) malloc ( sizeof(OM_S_OBJECT_LINKAGE)
							* (*nb_nodes) );

  *coords = ( double *) malloc ( sizeof ( double ) * (*nb_nodes) * 3 );

  if ( !ndObjLinkage || !(*coords) )
  {
	*msg = EMS_E_NoDynamicMemory;
	sts  = OM_E_NODYNMEM;
	goto wrapup;
  }

  sts = om$get_channel_objects (  osnum		= mesh_grid->osnum,
				  objid		= mesh_grid->objid,
				  p_chanselect	= &APmesh_to_node_CS,
				  list		= ndObjLinkage,
				  size		= *nb_nodes,
				  count		= (OMuint *)&nb_nd );
  VDS_ERR_HNDLR ( "Getting nodes on mesh channel", sts, MSSUCC, VD_VERBOSE,
		   wrapup );

  for ( ii=0; ii<*nb_nodes; ii++ )
  {
	sts = om$send ( msg = message APnode.get_coord ( msg,
							  &(*coords)[ii*3]
							),
			targetid = ndObjLinkage[ii].S_objid,
			targetos = ndObjLinkage[ii].osnum,
			senderid = NULL_OBJID );
	VDS_ERR_CONTINUE("APnode.get_coord", sts, *msg, VD_VERBOSE);

#ifdef  VDS_DBG
	printf("Coords : [%lf,%lf,%lf]\n",  (*coords)[ii*3], (*coords)[ii*3+1],
					    (*coords)[ii*3+2] );
#endif

  }


wrapup :
  if ( ndObjLinkage ) free ( ndObjLinkage );
  return sts;
}

end implementation Root;
