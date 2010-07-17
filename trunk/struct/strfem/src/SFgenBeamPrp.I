class implementation  Root;
/* -------------------------------------------------------------------------
   Doc : SFgenBeamProperty

   Description : This function generates property feature descriptor for a
		 given beam. It first checks if a property FD already exists
		 with the properties of given beam. If found, that FD is
		 returned. If else, it creates a new FD.

   Return Status :  1 - Success

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"

#include "msdef.h"
#include "msmacros.h"

#include "FElimits.h"
#include "FEmacros.h"

#include "APunitdef.h"
#include "FDdef.h"
#include "FEfddef.h"
#include "FDstruct.h"
#include "FEfdstruct.h"
#include "FEfdstruct.h"

#include "VDDbDef.h"
#include "vdbmacros.h"

#include "vsoptdef.h"
#include "vsattr.h"
#include "vsbeam.h"

#include "SFmsg.h"

%safe
#include "stdlib.h"
%endsafe

#define SF_COLUMNS  	10
#define SF_BEAM_TABLE	"prism_beam"
#define SF_ZERO		1E-30

extern  struct  GRid		FE_mpman_grid;
extern	OM_S_CHANSELECT		FEmpman_to_prop_CS;

from	FEfd	import	match_fd;
from	FEgenmp import	xpose_name;
from	FEmpman	import	match_name;
from	GRvg	import  GRgetattr;


long  SFgenBeamProperty (
  long			*msg,
  struct  GRid		beam,
  char			PrpName[],
  char			*PrpCreateFlag
)

{

double			var_data[MAX_BM_VAR];
struct   bmprop_unif	unif_data;
unsigned long		match_mask = FD_CAT | FD_TYP | FD_VAR | FD_UNF;
FD_INFO			fd_info;
char			match;
struct   GRid		match_grid;
char			PrpType;
long			listCount = 0;
char			found;
struct	 GRid		fd_grid;
long			sts1, ii;
VSpartAttr		attr ;
VSbeamAttr		info ;
char			*table=NULL,
			*select=NULL,
			search[MAX_WHERE_SIZE],
			**buff=NULL,
			units;
int			rows;
double			cs_area, izz, iyy, izy, jxy, tors_const, shear_y,
			shear_z, warp_coeff;

#ifdef SF_BEAM_DBG
     printf("Entered SFgenBeamProperty\n");
#endif

     *msg = 1;

     attr.Iwant		= VS_m_All;
     attr.specific	= (void *) &info;
     sts1 = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
			targetid= beam.objid,
			targetos= beam.osnum,
			senderid= NULL_OBJID ) ;
     if ( !(sts1 & *msg & 1 ) )
     {
	printf("SFgenBeamProperty : GRvg.GRgetattr failure\n");
	goto wrapup;
     }	
/*
     printf("beam family = [%s], partnum = [%s]\n",
		attr.info.family, attr.info.partNum );	
*/
     table = SF_BEAM_TABLE;
     select="cs_area,izz,iyy,izy,jxy,tors_const,shear_y,shear_z,warp_coeff,unit";
     sprintf( search,"n_itemname = '%s' and n_itemrev = '%s'", attr.info.family,
							attr.info.partNum );
     sts1 = vdb$RisSelect (	select 	   = select,
				table_name = table,
				where	   = search,
				numselect  = SF_COLUMNS,
				p_numrows  = &rows,
				p_buffer   = &buff  );
     if ( !(sts1 & 1) )
     {
	
	printf("SFgetBeamProperty : vds$RisSelect faiulre\n" );
	goto wrapup;
     }
     if ( !rows )
     {
	char  msgbuff[80];

	ex$message (	buff		= msgbuff,
			msgnumb		= SF_E_NoBmPrp,
			type		= "%s%s",
			var		= `attr.info.family,attr.info.partNum`);

	ex$message (	field		= ERROR_FIELD,
			justification	= CENTER_JUS,
			in_buff		= msgbuff	);

	printf("%s\n", msgbuff);

	*msg = 0;
	goto wrapup;
     }

     cs_area     = atof ( buff[0] );
     izz         = atof ( buff[1] );
     iyy         = atof ( buff[2] );
     izy         = atof ( buff[3] );
     jxy	 = atof ( buff[4] );
     tors_const  = atof ( buff[5] );
     shear_y     = atof ( buff[6] );
     shear_z     = atof ( buff[7] );
     warp_coeff  = atof ( buff[8] );
     units        = buff[9][0];

     /* convert values to database units */
     if ( units == 'E' || units == 'e' || units == 'I' || units == 'i' )
     {
       if ( cs_area != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_AREA, cs_area, "sq_inches",
				    &cs_area ) ) goto wrapup;

       if ( izz != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, izz,
				    "in_fourth", &izz ) ) goto wrapup;

       if ( iyy != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, iyy,
				    "in_fourth", &iyy ) ) goto wrapup;

       if ( izy != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, izy,
				    "in_fourth", &izy ) ) goto wrapup;

       if ( jxy != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, jxy,
				    "in_fourth", &jxy ) ) goto wrapup;

       if ( tors_const != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA,tors_const,
				    "in_fourth", &tors_const ) ) goto wrapup;

       if ( shear_y != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_DISTANCE, shear_y, "inches",
				    &shear_y ) ) goto wrapup;

       if ( shear_z != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_DISTANCE, shear_z, "inches",
				    &shear_z ) ) goto wrapup;
     }
     else if ( units == 'M' || units == 'm' )
     {
       if ( cs_area != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_AREA, cs_area, "sq_mms",
				    &cs_area ) ) goto wrapup;

       if ( izz != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, izz,
				    "mm_fourth", &izz ) ) goto wrapup;

       if ( iyy != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, iyy,
				    "mm_fourth", &iyy ) ) goto wrapup;

       if ( izy != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, izy,
				    "mm_fourth", &izy ) ) goto wrapup;

       if ( jxy != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA, jxy,
				    "mm_fourth", &jxy ) ) goto wrapup;

       if ( tors_const != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_SECOND_MOMENT_OF_AREA,tors_const,
				    "mm_fourth", &tors_const ) ) goto wrapup;

       if ( shear_y != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_DISTANCE, shear_y, "millimeter",
				    &shear_y ) ) goto wrapup;

       if ( shear_z != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_DISTANCE, shear_z, "millimeter",
				    &shear_z ) ) goto wrapup;
     }
     else
     {
	printf("SFgenBeamProperty : Unknown units\n");
	goto wrapup;
     }

     for ( ii=0; ii<MAX_BM_VAR; ii++)
	var_data[ii] = UNDEFINED_DBL;

     /* get the properties of beam */
     if ( cs_area    != UNDEFINED_DBL ) var_data[BM_AREA]  = cs_area;
     if ( izz        != UNDEFINED_DBL ) var_data[BM_IZZ]   = izz;
     if ( iyy        != UNDEFINED_DBL ) var_data[BM_IYY]   = iyy;
     if ( izy        != UNDEFINED_DBL ) var_data[BM_IYZ]   = izy;
     if ( jxy        != UNDEFINED_DBL ) var_data[BM_JXX]   = jxy;
     /* hard coded as in FEM */
     var_data[BM_SHRAZ] = 0.83;
     var_data[BM_SHRAY] = 0.83;
     if ( shear_y    != UNDEFINED_DBL ) var_data[BM_SHCTZ] = shear_z;
     if ( shear_z    != UNDEFINED_DBL ) var_data[BM_SHCTY] = shear_y;
     if ( warp_coeff != UNDEFINED_DBL ) var_data[BM_WARP]  = warp_coeff;
     if ( tors_const != UNDEFINED_DBL ) var_data[BM_TORCON]= tors_const;

     unif_data.relative_area = TRUE;

     fd_info.category   = PROP_CATEGORY;
     fd_info.type       = BMPROP_TYPE;
     fd_info.var_count  = MAX_BM_VAR;
     fd_info.unif_count = MAX_BM_UNIF;

     /* try to match fd */
     match = FALSE;
     sts1 = om$send ( msg = message FEfd.match_fd (
					msg, match_mask, &fd_info,
					(char *)&unif_data, var_data, &match,
					&match_grid ),
		      senderid     = FE_mpman_grid.objid,
		      targetos     = FE_mpman_grid.osnum,
		      p_chanselect = &FEmpman_to_prop_CS);
     if ( ! ( sts1 & *msg & 1 ) )
     {
	printf("SFgenBeamProperty : FEfd.match_fd failure\n");
	goto wrapup;
     }

#ifdef SF_BEAM_DBG
     printf("\tmatch fd: [%d]\n", match );
#endif

     if ( match )
     {
	sts1 = om$send ( msg = message FEgenmp.xpose_name(
						msg,
						BMPROP_TYPE,
						1,
						&PrpName,
						&PrpType,
						&listCount),
			 targetid = match_grid.objid,
			 targetos = match_grid.osnum,
			 senderid = NULL_OBJID );
	*PrpCreateFlag = FALSE;

	if ( ! ( sts1 & *msg & 1 ) )
	{
	  printf("SFgenBeamProperty : FEgenmp.xpose_name failure\n");
	  goto wrapup;
	}
     }
     else
     {
	/* generate a new name */
	found = TRUE;
	ii=0;
	while ( found )
	{
	   ii++;
	   sprintf( PrpName, "%s_%d", attr.info.partNum, ii);
	   sts1 = om$send ( msg = message FEmpman.match_name( msg,
			PROP_CATEGORY, BMPROP_TYPE, PrpName,
			&found, &fd_grid),
			senderid = NULL_OBJID,
			targetid = FE_mpman_grid.objid,
			targetos = FE_mpman_grid.osnum);
	   if ( ! ( sts1 & *msg & 1 ) )
	   {
		printf("SFgenBeamProperty : FEmpman.match_name failure\n");
		goto wrapup;
	   }
	}

	/* create a new FD with the name */
	sts1 = fe$create_beam_property ( 
				name            = PrpName,
				relative_area   = TRUE,
				beam_props	= var_data );
	if ( sts1 != 1 )
	{
	   printf("SFgenBeamProperty : fe$create_beam_property failure\n");
	   goto wrapup;
	}
	*PrpCreateFlag = TRUE;
     }

#ifdef SF_BEAM_DBG
     printf("\tPrpName : [%s]\n", PrpName );
#endif

wrapup :
     if ( buff ) vdb$RisFreeBuffer (  buffer  =  buff,
				      size    =  SF_COLUMNS * rows );
     return sts1;

}

end implementation Root;
