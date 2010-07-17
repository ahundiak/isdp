class implementation  Root;

/* -------------------------------------------------------------------------
   Doc : SFgenPlateProperty

   Description : This function generates property feature descriptor for a
		 given plate. It first checks if a property FD already exists
		 with the properties of given plate. If found, that FD is
		 returned. If else, it creates a new FD.

   Return Status :  1 - Success

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "parametric.h"

#include "vsoptdef.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsplate.h"

#include "FElimits.h"
#include "FEmacros.h"

#include "FDdef.h"
#include "FEfddef.h"
#include "FDstruct.h"
#include "FEfdstruct.h"

#include "vderrmacros.h"

extern  struct  GRid		FE_mpman_grid;
extern	OM_S_CHANSELECT		FEmpman_to_prop_CS;

from	FEfd	import	match_fd;
from	FEgenmp import	xpose_name;
from	FEmpman	import	match_name;
from	NDmacro import  ACgive_structure;
from    GRvg    import  GRgetattr;

long SFgenPlatePropFromThk (
  long			*msg,		 /* O - return status */
  double		thk,		 /* I - thickness of plate for which
						plate property is required */
  char			prefix[],	 /* I - prefix to be used for prop
						name when prop is generated */
  char			PrpName[],	 /* O - FEM property name	   */
  char			*PrpCreateFlag   /* O - TRUE : property created,
						FALSE : property not created */
)
{
double			var_data[MAX_PAN_VAR];
struct   panprop_unif	unif_data;
unsigned long		match_mask = FD_CAT | FD_TYP | FD_VAR; /* FD_UNF */
FD_INFO			fd_info;
struct   GRid		match_grid,
			fd_grid;
char			match,
			PrpType,
			found;
long			listCount = 0,
			sts1, ii;


     for ( ii=0; ii<MAX_PAN_VAR; ii++)
	var_data[ii] = UNDEFINED_DBL;
     var_data[PAN_THK]  = thk;
     var_data[PAN_SHTH] = 0.833333;
     var_data[PAN_FSTF] = 0.02;
     var_data[PAN_TREC] = 1.0;
     var_data[PAN_BREC] = 1.0;


     unif_data.opts         = 3;
     unif_data.recdist_flag = 1;
/*   check the following 2 assignments with FEM code */
     unif_data.high_order   = 0;
     unif_data.avg_type     = TRUE;



     fd_info.category   = PROP_CATEGORY;
     fd_info.type       = PANPROP_TYPE;
     fd_info.var_count  = MAX_PAN_VAR;
     fd_info.unif_count = MAX_PAN_UNIF;

     /* try to match fd */
     match = FALSE;
     sts1 = om$send ( msg = message FEfd.match_fd (
					msg, match_mask, &fd_info,
					NULL, var_data, &match,
					&match_grid ),
		      senderid     = FE_mpman_grid.objid,
		      targetos     = FE_mpman_grid.osnum,
		      p_chanselect = &FEmpman_to_prop_CS);
     if ( ! ( sts1 & *msg & 1 ) )
     {
	printf("SFgenPlateProperty : Error FEfd.match_fd\n");
	goto wrapup;
     }

#ifdef SF_PLATE_DBG
     printf("\tmatch fd: [%d]\n", match );
#endif

     if ( match )
     {
	sts1 = om$send ( msg = message FEgenmp.xpose_name(
						msg,
						PANPROP_TYPE,
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
	  printf("SFgenPlateProperty : Error FEgenmp.xpose_name\n");
	  goto wrapup;
	}
     }
     else
     {

	/*
	 * generate a new name
	 */

	found = TRUE;
	ii=0;
	while ( found )
	{
	   ii++;
	   sprintf( PrpName,"%s_%d", prefix, ii);
	   sts1 = om$send ( msg = message FEmpman.match_name( msg,
			PROP_CATEGORY, PANPROP_TYPE, PrpName,
			&found, &fd_grid),
			senderid = NULL_OBJID,
			targetid = FE_mpman_grid.objid,
			targetos = FE_mpman_grid.osnum);
	   if ( ! ( sts1 & *msg & 1 ) )
	   {
		printf("SFgenPlateProperty : Error FEmpman.match_name\n");
		goto wrapup;
	   }
	}

	/* create a new FD with the name */
	sts1 = fe$create_plate_property ( 
				name            = PrpName,
				thickness       = var_data[PAN_THK],
				str_rec_dis_rel = unif_data.recdist_flag,
				top_str_rec_dis = var_data[PAN_TREC],
				bot_str_rec_dis = var_data[PAN_BREC],
				plate_behavior  = unif_data.opts,
				shear_thk_ratio = var_data[PAN_SHTH],
				in_plane_stiff  = var_data[PAN_FSTF]  );
	if ( sts1 != 1 )
	{
	   printf("SFgenPlateProperty : Error creating plate_property\n");
	   goto wrapup;
	}
	*PrpCreateFlag = TRUE;
     }

#ifdef SF_PLATE_DBG
     printf("\tPrpName : [%s]\n", PrpName );
#endif

wrapup :
     return sts1;
}

long  SFgenPlateProperty (
  long			*msg,
  struct  GRid		plate,
  struct  GRmd_env	*plateEnv,
  char			PrpName[],
  char			*PrpCreateFlag
)
{
long			sts1;
int			index = -1; /* unused ASSOC flag */
struct   ret_struct	rs;
VSpartAttr		attr;
VSplateAttr		info;


#ifdef SF_PLATE_DBG
     printf("Entered SFgenPlateProperty\n");
#endif

     *msg = 1;

     /*  get the thickness of plate */
     sts1 = om$send( msg = message NDmacro.ACgive_structure(
				(int *)msg, &index, VS_K_plThcknsAttr, &rs,
				plateEnv ),
			targetid = plate.objid,
			targetos = plate.osnum,
			senderid = NULL_OBJID );
     VDS_ERR_HNDLR ( "NDmacro.ACgive_structure", sts1, *msg,
		     VD_VERBOSE, wrapup );

      /* get family name of the plate */
      attr.Iwant	= VS_m_PartFam;
      attr.specific	= (void *) &info;
      sts1 = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
			targetid= plate.objid,
			targetos= plate.osnum,
			senderid= NULL_OBJID ) ;
      if ( !(sts1 & *msg & 1 ) )
      {
	    printf("SFgenPlateProperty : GRvg.GRgetattr failure\n");
	    goto wrapup;
      }

/*
     sts1 = (long) APu_getTypeDefaultUnit ( GRIO_DISTANCE, DefUnitName );
     printf ( "\tDefault unit name : [%s]\n", DefUnitName );
*/

#ifdef SF_PLATE_DBG
     printf ( "\tPlate Thickness : [%f]\n", rs.var.root_pm_st.value );
#endif

     sts1 = SFgenPlatePropFromThk ( msg, rs.var.root_pm_st.value,
				    attr.info.family,
				    PrpName, PrpCreateFlag );
     VDS_ERR_HNDLR ( "SFgenPlatePropFromThk", sts1, *msg,
		     VD_VERBOSE, wrapup );

wrapup:
   return sts1;

}

end implementation  Root;
