class implementation  Root;

/* -------------------------------------------------------------------------
   Doc : SFplaceMatOnGeom

   Description : This function places given material property on the
		 given geometry.
   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "APlcdef.h"
#include "FEfddef.h"
#include "FDstruct.h"
#include "FEfdstruct.h"
#include "FDdef.h"

extern  struct GRid	 FE_mpman_grid;
extern  struct GRid	 FE_struct_grid;

extern  OMuword		 OPP_FEgrpmatsym_class_id;
extern  OMuword		 OPP_EMSsurface_class_id;
extern  OM_S_CHANSELECT  FEstructure_to_fd_CS;

from  FEmpman	import  match_name;
from  FEfd	import  place_fd;

long  SFplaceMatOnGeom (
  long		*msg,		/* O - return status 		*/
  char		MatName[],	/* I - material property name	*/
  struct GRid   loc_obj		/* I - geometry object		*/
)
{
struct  GRid	fd_grid;
char		found;
long		sts1;
struct	GRid	*domain_grids = NULL;
long		num_domains ;
long		domain_type = AP_LC_STITCHSURF;
char		dimension = 2;
OMuword		symbol_classid = OPP_FEgrpmatsym_class_id;
char		gflag = 0;
long		loop_count, jj;
GRobjid		*loop_objids;

	*msg = 1;

	sts1 = om$send ( msg = message FEmpman.match_name( msg,
			 MAT_CATEGORY, ISOMAT_TYPE, MatName,
			 &found, &fd_grid),
		senderid = NULL_OBJID,
		targetid = FE_mpman_grid.objid,
		targetos = FE_mpman_grid.osnum);

	if ( !( sts1 & *msg & 1 ) )
	{
	  printf( "SFplaceMatOnGeom : Error FEmpman.match_name\n" );
	  goto wrapup;
	}

	if ( !found )
	{
	  printf( "SFplaceMatOnGeom : Material [%s] does not exist\n",
								MatName );
	  *msg = 0;
	  goto wrapup;
	}

#ifdef  SF_DEBUG
	printf( " fd_grid : [%d,%d]\n", fd_grid.objid, fd_grid.osnum );
#endif

	num_domains = 0;
	if ( EFisAncestryValid ( msg, loc_obj.objid, loc_obj.osnum,
				 OPP_EMSsurface_class_id, FALSE )   )
	{
	   loop_count = 0;
	   loop_objids = NULL;
	   sts1 = AP_get_loops ( loc_obj, &loop_count, &loop_objids );

	   domain_grids = (struct GRid *) malloc ( loop_count *
						   sizeof( struct GRid ) );
	   if ( domain_grids == NULL )
	   {
		printf("SFplaceMatOnGeom : Can not allocate memory\n");
		*msg = 0;
		goto wrapup;
	   }

	   for ( jj=0; jj < loop_count; jj++ )
	   {
		domain_grids[num_domains].objid = loop_objids[jj];
		domain_grids[num_domains].osnum = loc_obj.osnum;
		num_domains++;
	   }
	   if ( loop_objids ) free ( loop_objids );
	}

	/*	place fd		*/
	sts1 = om$send ( msg = message	 FEfd.place_fd (msg, domain_grids,
				num_domains, domain_type, dimension, gflag, 
				symbol_classid, -1, NULL, 
				FE_struct_grid, FEstructure_to_fd_CS, NULL ),
			senderid = NULL_OBJID,
			targetid = fd_grid.objid,
			targetos = fd_grid.osnum);

	if ( domain_grids )  free ( domain_grids );

	if ( !( sts1 & *msg & 1 ) )
	{ 
	  printf("SFplaceMatOnGeom : Error FEfd.place_fd\n");
	  goto wrapup;
	}

wrapup:
	return sts1;

}

end implementation   Root;
