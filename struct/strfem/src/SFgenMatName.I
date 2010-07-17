class implementation Root;
/* -------------------------------------------------------------------------
   Doc : SFgetMatName

   Description : This function generates material feature descriptor
		 for a given material grade and type. It first checks if
		 a material FD already exists for the given grade and type.
		 If found, that FD is returned. If else, it creates a new FD.

   Return Status :  1 - Success

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "msdef.h"
#include "msmacros.h"

#include "stdio.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "grdpbmacros.h"

#include "APunitdef.h"
#include "FElimits.h"
#include "FEmacros.h"
#include "FDdef.h"
#include "FEfddef.h"
#include "FDstruct.h"
#include "FEfdstruct.h"

#include "VDDbDef.h"
#include "vdbmacros.h"

#include "SFmsg.h"

%safe
#include "stdlib.h"
%endsafe

extern  struct  GRid	 FE_mpman_grid;
extern  OM_S_CHANSELECT  FEmpman_to_mat_CS;
long    APu_value_to_dbase();

#define  SF_ZERO		1E-30
#define  SF_COLUMNS		15
#define  SF_ISOMAT_TABLE	"isomat"

from	FEfd	import	match_fd;
from	FEgenmp import	xpose_name;
from	FEmpman	import	match_name;

long   SFgetMatName(
 long *msg,			/* O - return status */
 char MatType[],		/* I - Material type, aluminium, steel etc. */
 char MatGrade[],		/* I - Material Grade, 1100, 5456 P etc. */
 char MatName[],		/* O - name of FEM material property	*/
 char *MatCreateFlag		/* O - TRUE, FEM material created	*/
)
{
double		var_data[MAX_ISO_VAR];
unsigned long	match_mask;
FD_INFO		fd_info;
struct   GRid	match_grid,
		fd_grid;
long		listCount = 0;
long		sts1, ii;
char		match,
		type,
		found,
		*table=NULL,
		*select=NULL,
		search[MAX_WHERE_SIZE],
		**buff,
		units;
int		rows;
double		elastic_mod, poisson_rat, shear_mod, th_exp_coeff, density,
		max_tension, max_compress, max_shear, yield_stress,
		ulti_stress, damp_coeff, specific_heat, thermal_cond,
		emissivity;

#ifdef SF_DBG
     printf("Entered SFgetMatName - MatType : [%s], MatGrade : [%s]\n",
	    MatType, MatGrade);
#endif


     *msg = 1;
     /* query from database from 'isomat' table for MatType,
	MatGrade and get the material properties */
     table = SF_ISOMAT_TABLE;
     select="elastic_mod,poisson_rat,shear_mod,th_exp_coeff,density,max_tension,max_compress,max_shear,yield_stress,ulti_stress,damp_coeff,specific_heat,thermal_cond,emissivity,unit";
     sprintf( search, "n_itemname = '%s' and n_itemrev = '%s'", MatType,
								MatGrade );
     sts1 = vdb$RisSelect (	select 	   = select,
				table_name = table,
				where	   = search,
				numselect  = SF_COLUMNS,
				p_numrows  = &rows,
				p_buffer   = &buff  );
     if ( !(sts1 & 1) )
     {
	printf("SFgetMatName : vds$RisSelect failure\n" );
	goto wrapup;
     }
     if ( !rows )
     {
	char  msgbuff[80];

	ex$message (	 buff		= msgbuff,
			 msgnumb	= SF_E_NoMatPrp,
			 type		= "%s%s",
			 var		= `MatType,MatGrade`);

	ex$message (	 field		= ERROR_FIELD,
			 justification	= CENTER_JUS,
			 in_buff	= msgbuff	);
	printf("%s\n", msgbuff );
	*msg = 0;
	goto wrapup;
     }
/*
printf(" buff[3] = [%s]\n", buff[3] );
*/

     elastic_mod  = atof( buff[0] );
     poisson_rat  = atof( buff[1] );
     shear_mod    = atof( buff[2] );
     th_exp_coeff = atof( buff[3] );
     density      = atof ( buff[4] );
     max_tension  = atof ( buff[5] );
     max_compress = atof ( buff[6] );
     max_shear    = atof ( buff[7] );
     yield_stress = atof ( buff[8] );
     ulti_stress  = atof ( buff[9] );
     damp_coeff   = atof ( buff[10] );
     specific_heat= atof ( buff[11] );
     thermal_cond = atof ( buff[12] );
     emissivity   = atof ( buff[13] );
     units        = buff[14][0];
     /* calculate shear modulus if poisson_rat is defined and shear_mod not
      * defined.  G = E/(2*(1+u))
      */
     if ( elastic_mod != UNDEFINED_DBL && poisson_rat != UNDEFINED_DBL  &&
	  shear_mod   == UNDEFINED_DBL  )
	shear_mod = elastic_mod / ( 2 * (1 + poisson_rat) );

     /* calculate poisson_rat if shear_mod is defined and poisson_rat not
      * defined.  u = (E/(2*G)) -1
      */
     if ( elastic_mod != UNDEFINED_DBL && poisson_rat == UNDEFINED_DBL &&
	  shear_mod != UNDEFINED_DBL  )
	poisson_rat = elastic_mod/( 2 * shear_mod ) - 1.0;

     /* convert values to database units */
     if ( units == 'E' || units == 'e' || units == 'I' || units == 'i' )
     {
       if ( elastic_mod != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_PRESSURE, elastic_mod, "psi",
				    &elastic_mod ) )   goto wrapup;

       if ( shear_mod != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_PRESSURE, shear_mod, "psi",
				    &shear_mod ) )   goto wrapup;

       if ( th_exp_coeff != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_COEF_THERMAL_EXPANSION,
				    th_exp_coeff, "pf",
				    &th_exp_coeff ) )   goto wrapup;

       if ( density != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_DENSITY, density, "pci",
				    &density ) )   goto wrapup;

       if ( max_tension != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, max_tension, "psi",
				    &max_tension ) )   goto wrapup;

       if ( max_compress != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, max_compress, "psi",
				    &max_compress ) )   goto wrapup;

       if ( max_shear != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, max_shear, "psi",
				    &max_shear ) )   goto wrapup;

       if ( yield_stress != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, yield_stress, "psi",
				    &yield_stress ) )   goto wrapup;

       if ( ulti_stress != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, ulti_stress, "psi",
				    &ulti_stress ) )   goto wrapup;

       if ( specific_heat != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_HEAT_CAPACITY, specific_heat,
				    "btuplbmf", &specific_heat ) ) goto wrapup;

       if ( thermal_cond != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_THERMAL_CONDUCTIVITY,
				    thermal_cond, "btuphff",
				    &thermal_cond ) )   goto wrapup;
     }
     else if ( units == 'M' || units == 'm' )
     {
       if ( elastic_mod != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_PRESSURE, elastic_mod, "mpa",
				    &elastic_mod ) )   goto wrapup;

       if ( shear_mod != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_PRESSURE, shear_mod, "mpa",
				    &shear_mod ) )   goto wrapup;

       if ( th_exp_coeff != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_COEF_THERMAL_EXPANSION,
				    th_exp_coeff, "pc",
				    &th_exp_coeff ) )   goto wrapup;

       if ( density != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_DENSITY, density, "kgpcm",
				    &density ) )   goto wrapup;

       if ( max_tension != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, max_tension, "mpa",
				    &max_tension ) )   goto wrapup;

       if ( max_compress != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, max_compress, "mpa",
				    &max_compress ) )   goto wrapup;

       if ( max_shear != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, max_shear, "mpa",
				    &max_shear ) )   goto wrapup;

       if ( yield_stress != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, yield_stress, "mpa",
				    &yield_stress ) )   goto wrapup;

       if ( ulti_stress != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_STRESS, ulti_stress, "mpa",
				    &ulti_stress ) )   goto wrapup;

       if ( specific_heat != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_HEAT_CAPACITY, specific_heat,
				    "btuplbmf", &specific_heat ) ) goto wrapup;

       if ( thermal_cond != UNDEFINED_DBL )
	if ( ! APu_value_to_dbase ( msg, GRIO_THERMAL_CONDUCTIVITY,
				    thermal_cond, "btuphff",
				    &thermal_cond ) )   goto wrapup;
     }
     else
     {
	printf("SFgetMatName : Unknown units\n");
	goto wrapup;
     }

     for ( ii=0; ii<MAX_ISO_VAR; ii++)
	var_data[ii] = UNDEFINED_DBL;
     if ( elastic_mod   != UNDEFINED_DBL ) var_data[ISO_E]     = elastic_mod;
     if ( poisson_rat   != UNDEFINED_DBL ) var_data[ISO_V]     = poisson_rat;
     if ( shear_mod     != UNDEFINED_DBL ) var_data[ISO_G]     = shear_mod;
     if ( th_exp_coeff  != UNDEFINED_DBL ) var_data[ISO_ALPH]  = th_exp_coeff;
     if ( density       != UNDEFINED_DBL ) var_data[ISO_DENS]  = density;
     if ( max_tension   != UNDEFINED_DBL ) var_data[ISO_MAXT]  = max_tension;
     if ( max_compress  != UNDEFINED_DBL ) var_data[ISO_MAXC]  = max_compress;
     if ( max_shear     != UNDEFINED_DBL ) var_data[ISO_MAXS]  = max_shear;
     if ( yield_stress  != UNDEFINED_DBL ) var_data[ISO_FY]    = yield_stress;
     if ( ulti_stress   != UNDEFINED_DBL ) var_data[ISO_FU]    = ulti_stress;
     if ( damp_coeff    != UNDEFINED_DBL ) var_data[ISO_DAMP]  = damp_coeff;
     if ( specific_heat != UNDEFINED_DBL ) var_data[ISO_SPH]   = specific_heat;
     if ( thermal_cond  != UNDEFINED_DBL ) var_data[ISO_THCON] = thermal_cond;
     if ( emissivity    != UNDEFINED_DBL ) var_data[ISO_EMIS]  = emissivity;

     fd_info.category  = MAT_CATEGORY;
     fd_info.type      = ISOMAT_TYPE;
     fd_info.var_count = MAX_ISO_VAR;
     match_mask = FD_CAT | FD_TYP | FD_VAR ;

     /* try to match fd */
     match = FALSE;
     sts1 = om$send ( msg = message FEfd.match_fd (
					msg, match_mask, &fd_info,
					NULL, var_data, &match, &match_grid ),
		      senderid     = FE_mpman_grid.objid,
		      targetos     = FE_mpman_grid.osnum,
		      p_chanselect = &FEmpman_to_mat_CS);
     if ( ! ( sts1 & *msg & 1 ) )
     {
	printf("SFgetMatName : Error FEfd.match_fd\n");
	goto wrapup;
     }

#ifdef  SF_DBG
     printf("\tmatch fd: [%d]\n", match );
#endif

     if ( match )
     {
	sts1 = om$send ( msg = message FEgenmp.xpose_name(
						msg,
						ISOMAT_TYPE,
						1,
						&MatName,
						&type,
						&listCount),
			 targetid = match_grid.objid,
			 targetos = match_grid.osnum,
			 senderid = NULL_OBJID );
	if ( ! ( sts1 & *msg & 1 ) )
	{
	  printf("SFgetMatName : Error FEgenmp.xpose_name\n");
	  goto wrapup;
	}

	*MatCreateFlag = FALSE;
     }
     else
     {
	/* generate a new name */
	found = TRUE;
	ii=0;
	while ( found )
	{
	   ii++;
	   sprintf( MatName,"%s_%s_%d",MatType,MatGrade,ii);
	   sts1 = om$send ( msg = message FEmpman.match_name( msg,
			MAT_CATEGORY, ISOMAT_TYPE, MatName,
			&found, &fd_grid),
			senderid = NULL_OBJID,
			targetid = FE_mpman_grid.objid,
			targetos = FE_mpman_grid.osnum);
	   if ( ! ( sts1 & *msg & 1 ) )
	   {
		printf("SFgetMatName : Error FEmpman.match_name\n");
		goto wrapup;
	   }
	}

	/* create a new FD with the name */
	sts1 = fe$create_iso_material ( name     = MatName,
					iso_data = var_data );
	if ( sts1 != 1 )
	{
	   printf("SFgetMatName : fe$create_iso_material failed\n");
	   goto wrapup;
	}
	*MatCreateFlag = TRUE;
     }

#ifdef SF_DBG
     printf("\tMatName : [%s]\n", MatName );
#endif

wrapup :
     if ( buff ) vdb$RisFreeBuffer (  buffer  =  buff,
				      size    =  SF_COLUMNS * rows );
     return sts1;
}

end implementation Root;

