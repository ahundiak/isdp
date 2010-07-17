class implementation Root;

/* -------------------------------------------------------------------------
   Doc : SFmeshAndPlaceMatPrp

   Description : This function meshes a given curve according to the given
		 input and places material and property on the FEM beam
		 elements.
   Notes:

   Memory for bmMeshList is allocated by this function. Caller should free
   the memory by -     if ( bmMeshList )  free (bmMeshList);

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */

#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "OMerrordef.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "gr.h"
#include  "igr.h"
#include  "grdpbdef.h"
#include  "grdpbmacros.h"

#include  "APdef.h"
#include  "MHmeshmac.h"
#include  "FEmacros.h"

#include  "vsdef.h"
#include  "vs.h"

%safe
#include  "alloca.h"
#include  "stdlib.h"
%endsafe


extern OM_S_CHANSELECT  APmesh_to_elem_CS;
extern OM_S_CHANSELECT  APmesh_to_node_CS;

from  VSpart  import VSgetSupports;
from  VSbeam  import VSgetCrossSectionCS;


long  SFmeshAndPlaceMatPrp (
  long			*msg,		/* O - return message		*/
  struct  GRid		beam,		/* I - beam object		*/
  struct  GRmd_env	*beamEnv,	/* I - beam mod_env		*/
  struct  GRid		crv_obj,	/* I - curve representing axis of beam
					       that is used for FEM beams */
  struct  GRmd_env	*crv_env,	/* I - curve mod_env		*/
  int			elem_type,	/* I - LINE2 or LINE3		*/
  int			nb_elems,	/* I - no. of FEM beams into which
					       the curve to be meshed   */
  double		weight,		/* I - weight to be used while meshing
					       curve			*/
  char			*MatName,	/* I - material name		*/
  char			*PrpName,	/* I - property name		*/
  struct GRid		*mesh_grid,	/* O - mesh object		*/
  struct GRid		**bmMeshList	/* O - objids of FEM beams
					 *     Memory allocated in this function
					 *     Caller should free memory
					 *     = NULL, if not needed
					 */
)
{

  long			sts;
  int			nb_nodes;
  struct  IGRbsp_curve	*crv_geom;
  double		*param = NULL,
			*coord = NULL;
  struct IGRpolyline    crv_poly;
  int			count;
  OM_S_OBJECT_LINKAGE   *bmObjLinkage = NULL;
  long			*bmUidList = NULL;
  int			nb_bm, ii;
  VSsuppList		bmSupports;
  struct GRid		prflDef;	/* unused */
  IGRmatrix		prflCS;
  double		mid_param;
  IGRvector		yaxis;
  struct GRid		*MeshListLoc = NULL;


  *msg = 1;

  if ( nb_elems <= 0 )  return OM_S_SUCCESS;
  if ( weight <= 0 ) return OM_S_SUCCESS;

  /*  get the geometry of the curve  */
  sts = EMgetvggeom( msg, &crv_env->md_env.matrix_type,
		     crv_env->md_env.matrix, &crv_obj,
		     &crv_geom, NULL );

  if ( !(sts & *msg & 1 ) )
  {
     printf("SFmeshAndPlaceMatPrp : Can not get geometry of the curve\n");
     goto wrapup;
  }

  if ( elem_type == LINE2 )
      nb_nodes = nb_elems +  1;
  else if ( elem_type == LINE3 )
      nb_nodes = nb_elems * 2 + 1;
  else
  {
      printf("SFmeshAndPlaceMatPrp : Invalid element type\n");
      goto wrapup;
  }

  /* stroke the edge curve */
  param = (double *) alloca( nb_nodes * sizeof(double) );
  coord = (double *) alloca( 3 * nb_nodes * sizeof(double) );

  sts = MHstroke_curve( crv_geom, nb_nodes, param, coord, 0.0, 1.0, weight );
  if ( ! sts & 1 )
  {
	printf("SFmeshAndPlaceMatPrp : Can not stroke curve\n");
	goto wrapup;
  }

  crv_poly.num_points = nb_nodes;
  crv_poly.points = coord;

  /* create the mesh */
  mesh_grid->objid = NULL_OBJID;
  sts = fe$mesh_line_elems( edge = &crv_poly,
			    el_type = elem_type,
			    mesh = mesh_grid,
			    check_for_stop = FALSE );
  if ( ! sts & 1 )
  {
	printf("SFmeshAndPlaceMatPrp : fe$mesh_line_elems failure\n");
	goto wrapup;
  }

#ifdef SF_BEAM_DBG
  printf("mesh_grid : [%d,%d]\n", mesh_grid->objid, mesh_grid->osnum);
#endif

  sts = om$get_channel_count(	  osnum           = mesh_grid->osnum,
				  objid           = mesh_grid->objid,
				  p_chanselect    = &APmesh_to_elem_CS,
				  count           = (OMuint *) &count ) ;
  if( !( sts & 1 ) )
  {
	printf("SFmeshAndPlaceMatPrp : Can not get APmesh_to_elem_CS count\n");
	goto wrapup;
  }

#ifdef SF_BEAM_DBG
  printf("count = [%d]\n", count);
#endif

  if ( count <= 0 )
  {
	printf("SFmeshAndPlaceMatPrp : count on APmesh_to_elem_CS <= 0\n");
	goto wrapup;
  }

  /* allocate memory for object ids and user ids */
  bmObjLinkage = (OM_S_OBJECT_LINKAGE *) malloc ( sizeof(OM_S_OBJECT_LINKAGE)
							* count );

  MeshListLoc   = ( struct GRid *) malloc ( sizeof(struct GRid) * count );
  bmUidList  = (long *) malloc( sizeof(long) * count );

  if ( !bmObjLinkage || ! MeshListLoc || !bmUidList )
  {
	printf("Can not allocate memory for beam grids and uids\n");
	goto wrapup;
  }

  sts = om$get_channel_objects (  osnum		= mesh_grid->osnum,
				  objid		= mesh_grid->objid,
				  p_chanselect	= &APmesh_to_elem_CS,
				  list		= bmObjLinkage,
				  size		= count,
				  count		= (OMuint *)&nb_bm );
  if ( !(sts & 1) )
  {
	printf("SFmeshAndPlaceMatPrp : Can not get channel objects\n");
	goto wrapup;
  }

  /* additional check to make sure things are fine */
  if ( nb_bm != nb_elems )
  {
	printf(
	"SFmeshAndPlaceMatPrp : No. of FEM beams requested and created do not match\n");
	goto wrapup;
  }


  for ( ii=0; ii<nb_elems; ii++)
  {
	(MeshListLoc)[ii].objid = bmObjLinkage[ii].S_objid;
	(MeshListLoc)[ii].osnum = bmObjLinkage[ii].osnum;
  }

  if ( bmObjLinkage )  { free ( bmObjLinkage ); bmObjLinkage = NULL; }

  sts = fe$grids_to_uids ( ndel_uids  = bmUidList,
			   ndel_grids = MeshListLoc,
			   num_ndel   = nb_elems );
  if ( !(sts & 1) )
  {
	printf("SFmeshAndPlaceMatPrp : fe$grids_to_uids failure\n");
	goto wrapup;
  }

  sts = fe$place_material( name      = MatName,
			   el_grids  = MeshListLoc,
			   num_elem  = nb_elems  );
  if ( !(sts & 1) )
  {
	printf("SFmeshAndPlaceMatPrp : fe$place_material failure\n");
	goto wrapup;
  }

  sts = fe$place_property( name      = PrpName,
			   el_grids  = MeshListLoc,
			   num_elem  = nb_elems  );

  if ( !(sts & 1) )
  {
	printf("SFmeshAndPlaceMatPrp : fe$place_property failure\n");
	goto wrapup;
  }

  /* get y-axis of beam at center of each FEM beam element, place beam
   * orientation symbol for the property on each beam.
   */
  sts = om$send(msg     = message VSpart.VSgetSupports(
				msg, beamEnv, &count, bmSupports ),
			targetid= beam.objid,
			targetos= beam.osnum,
			senderid= NULL_OBJID ) ;
  if ( !(sts & *msg & 1) )
  {
	printf("SFmeshAndPlaceMatPrp : VSpart.VSgetSupports failure\n");
	goto wrapup;
  }

  for ( ii=0; ii<nb_elems; ii++)
  {
      if ( elem_type == LINE2 )
	mid_param = (param[ii] + param[ii+1]) / 2.0;
      else
	mid_param = param[ii*2+1];

      sts = om$send(  msg     = message VSbeam.VSgetCrossSectionCS(
								msg,
								beamEnv,
								bmSupports + 0,
								bmSupports + 1,
								mid_param,
								&prflDef,
								prflCS ),
			targetid= beam.objid,
			targetos= beam.osnum,
			senderid= NULL_OBJID ) ;
      if ( !(sts & 1) )
      {
	printf("SFmeshAndPlaceMatPrp : VSbeam.VSgetCrossSectionCS failure\n");
	continue;
      }

      /*  from examples, it is concluded that following represent vertical axis
       *  of a beam.
       */

      yaxis[0] = prflCS[1];
      yaxis[1] = prflCS[5];
      yaxis[2] = prflCS[9];

      sts = FEconst_bmornt_sym( yaxis, &bmUidList[ii], 1, ELEM );

      if ( ! sts & 1 )
	printf("SFmeshAndPlaceMatPrp : FEconst_bmornt_sym failure\n");

  }

wrapup :

  if ( bmObjLinkage ) free ( bmObjLinkage );
  if ( crv_geom ) free ( crv_geom );
  if ( bmUidList ) free ( bmUidList );
  if ( bmMeshList )
	*bmMeshList = MeshListLoc;
  else
	free ( MeshListLoc );
  return sts;

}

end implementation Root;
