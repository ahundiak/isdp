class implementation Root;

/* -------------------------------------------------------------------------
   Doc : 

   Description :

     For each of the FE beam, beam end offsets are calculated and placed
     as follows :

     o  The beam curve is stroked into no. of elements. This gives the
        nodal coordinates.

     o  Coordinate systems are generated at near and far ends of the FE beam.

     o  Offsets in lateral directions are found out with respect to the
	coordinate systems.

     o  Feature desrciptor with the offsets is placed on the FE beam.

   History :

------------------------------------------------------------------------- */

#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "OMerrordef.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "msdef.h"
#include  "gr.h"
#include  "igr.h"

#include  "EMSmsgdef.h"
#include  "vderrmacros.h"

#include  "APdef.h"
#include  "APlcdef.h"
#include  "FEfddef.h"
#include  "FDdef.h"
#include  "FDstruct.h"
#include  "FEfdstruct.h"

#include  "vsdef.h"
#include  "vs.h"

%safe
#include  "alloca.h"
#include  "stdlib.h"
%endsafe

extern	struct	GRid	FE_struct_grid;
extern	OM_S_CHANSELECT	FEstructure_to_fd_CS;
extern	OMuword		OPP_FEfdbeamofs_class_id;
extern	OMuword		OPP_FEbmoffdsym_class_id;

from   VSpart	  import  VSgetSupports;
from   VSbeam	  import  VSgetCrossSectionCS;
from   FEfd	  import  fd_init;
from   FEfd	  import  place_fd;


long  SFbmEndOffsets (
 long			*msg,
 struct GRid		*BmCrvId,
 struct GRmd_env	*BmCrvEnv,
 struct GRmd_env	*cstEnv,
 struct GRid		*beamId,
 struct GRmd_env	*beamEnv,
 struct GRid		*BmMeshList,
 int			elem_type,
 int			nb_elems,
 double			weight,
 char			placeOffsets,
 double			*offsets
)
{
long			sts, nb_pts;
int			nb_nodes, ii,
			count;
short			dim;
struct IGRbsp_curve	*BmCrvGeom;
double			*param = NULL,
			*CrvCoord = NULL;
VSsuppList		bmSupports;
struct GRid		prflDef;	/* unused */
IGRmatrix		prflCS;
double			near_end_param,
			far_end_param,
			near_offsets[3],
			far_offsets[3];

long			domain_type,
			num_domains;
FD_INFO			fd_info;
char			*unif_fd_data = NULL;
double			var_data[MAX_BMOFS_VAR];
OM_S_OBJID		fd_objid;
struct GRid		cs_id, tmp_grid;


  sts = OM_S_SUCCESS;
  *msg = MSSUCC;

  /*
   * check arguments
   */
  if ( (nb_elems < 1) ||
       (weight <= 0.0) ||
       (elem_type != LINE2 && elem_type != LINE3 )
     )
  {
      return EMS_E_InvalidArg;
  }

  if ( elem_type == LINE2 )
      nb_nodes = nb_elems +  1;
  else
      nb_nodes = nb_elems * 2 + 1;

  /*
   * get the geometry of the beam curve
   */
  sts = EMgetvggeom( msg, &BmCrvEnv->md_env.matrix_type,
		     BmCrvEnv->md_env.matrix, BmCrvId,
		     &BmCrvGeom, NULL );
  VDS_ERR_HNDLR ( "EMgetvggeom", sts, *msg, VD_VERBOSE, wrapup );

  /*
   * stroke the beam curve
   */
  param     = (double *) alloca( nb_nodes * sizeof(double) );
  CrvCoord = (double *) alloca( 3 * nb_nodes * sizeof(double) );

  sts = MHstroke_curve( BmCrvGeom, nb_nodes, param, CrvCoord,
			0.0, 1.0, weight);
  VDS_ERR_HNDLR ( "MHstroke_curve", sts, MSSUCC, VD_VERBOSE, wrapup );


  fd_info.category = NONMP_CATEGORY;
  fd_info.type = BMOFS_TYPE;
  fd_info.dimension = 1;
  fd_info.unif_count = MAX_BMOFS_UNIF;
  fd_info.var_count = MAX_BMOFS_VAR;
  fd_info.lcase_id = NULL_FDCASE_ID;
  fd_info.props = FD_IS_ELEM_BASED; 

  cs_id.objid    = NULL_OBJID;
  tmp_grid.objid = NULL_OBJID;

  sts = om$send(msg     = message VSpart.VSgetSupports(
				msg, beamEnv, &count, bmSupports ),
			targetid= beamId->objid,
			targetos= beamId->osnum,
			senderid= NULL_OBJID );
  VDS_ERR_HNDLR( "VSpart.VSgetSupports", sts, *msg, VD_VERBOSE, wrapup );

  /*
   * find end offsets for each of the FEM beams and place offsets
   */

  /* initialize the constants */
  dim = 4;
  nb_pts = 1;
  domain_type = (long ) AP_LC_ELEM1D;
  num_domains  =  1;

  for ( ii=0; ii<nb_elems; ii++)
  {
    __DBGpr_int ( "FEM element", ii);

    /*
     * find offsets at near end
     */

    if ( elem_type == LINE2 )
	near_end_param = param[ii];
    else
	near_end_param = param[ii*2];

    sts = om$send(  msg     = message VSbeam.VSgetCrossSectionCS(
								msg,
								beamEnv,
								bmSupports + 0,
								bmSupports + 1,
								near_end_param,
								&prflDef,
								prflCS ),
			targetid= beamId->objid,
			targetos= beamId->osnum,
			senderid= NULL_OBJID );
    VDS_ERR_CONTINUE( "VSbeam.VSgetCrossSectionCS", sts, *msg, VD_VERBOSE);

    /*
     * Inverse coordinate system matrix to get world_to_lcl xformation mat.
     */
    MAinvmx ( msg, &dim, prflCS, prflCS );
    VDS_ERR_CONTINUE ( "Inverse profile CS matrix", OM_S_SUCCESS,
			  *msg, VD_VERBOSE );

    if ( elem_type == LINE2 )
	MAptsxform ( msg, &nb_pts, prflCS, &CrvCoord[ii*3], near_offsets );
    else
	MAptsxform ( msg, &nb_pts, prflCS, &CrvCoord[ii*6], near_offsets );

    __DBGpr_vec("near_offsets", near_offsets );

    /*
     * find offsets at far end
     */

    if ( elem_type == LINE2 )
	far_end_param = param[ii+1];
    else
	far_end_param = param[ii*2+2];

    sts = om$send(  msg     = message VSbeam.VSgetCrossSectionCS(
								msg,
								beamEnv,
								bmSupports + 0,
								bmSupports + 1,
								far_end_param,
								&prflDef,
								prflCS ),
			targetid= beamId->objid,
			targetos= beamId->osnum,
			senderid= NULL_OBJID );
    VDS_ERR_CONTINUE(	"VSbeam.VSgetCrossSectionCS", sts, *msg, VD_VERBOSE);

    /*
     * Inverse coordinate system matrix to get world_to_lcl xformation mat.
     */
    MAinvmx ( msg, &dim, prflCS, prflCS );
    VDS_ERR_CONTINUE ( "Inverse profile CS matrix", OM_S_SUCCESS,
			  *msg, VD_VERBOSE );

    if ( elem_type == LINE2 )
	MAptsxform ( msg, &nb_pts, prflCS, &CrvCoord[ii*3+3], far_offsets );
    else
	MAptsxform ( msg, &nb_pts, prflCS, &CrvCoord[ii*6+6], far_offsets );

    __DBGpr_vec("far_offsets", far_offsets );

    /*
     * near_offsets[1]  is offset in beam y-dir.
     * near_offsets[0]  is offset in beam z-dir.
     */

    var_data[0] = near_offsets[1];
    var_data[1] = near_offsets[0];
    var_data[2] = far_offsets[1];
    var_data[3] = far_offsets[0];

    if ( placeOffsets )
    {
	sts = om$construct( classid = OPP_FEfdbeamofs_class_id,
			    msg	= message FEfd.fd_init
					( msg, fd_info, unif_fd_data, var_data,
					 cs_id),
			    osnum = cstEnv->md_id.osnum,
			    p_objid = &fd_objid);
	VDS_ERR_CONTINUE("FEfd.fd_init", sts, *msg, VD_VERBOSE);

	/*
	 * place fd
	 */

	sts = om$send ( msg = message FEfd.place_fd ( msg, &BmMeshList[ii],
				num_domains, domain_type, 1, 1, 
				OPP_FEbmoffdsym_class_id, -1, &tmp_grid, 
				FE_struct_grid, FEstructure_to_fd_CS, NULL ),
			senderid = NULL_OBJID,
			targetid = fd_objid,
			targetos = cstEnv->md_id.osnum);
	VDS_ERR_CONTINUE("FEfd.place_fd", sts, *msg, VD_VERBOSE );
    }

  } /* for ( ii=0; ii<nb_elems; ii++) */

  if ( offsets )
  {
      offsets[0] = var_data[0];
      offsets[1] = var_data[1];
      offsets[2] = var_data[2];
      offsets[3] = var_data[3];
  }

wrapup:

  return sts;
}

end implementation Root;

