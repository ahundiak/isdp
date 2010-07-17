/* $Id: VRPNinfo.I,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRPNinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPNinfo.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/01/17  19:30:46  pinnacle
# Replaced: vrprdcmp/VRPNinfo.I for:  by r240_int for route240
#
# Revision 1.3  1995/12/17  18:07:38  pinnacle
# Replaced: ./vrprdcmp/VRPNinfo.I for:  by azuurhou for route240
#
 *
 * History:
 *	12/17/95    adz		VDObjDef structure error.
 *	01/17/96    tlb		Add prototypes
 *
 ***************************************************************************/
class implementation VRPNozz;

#include "VRparamdef.h"
#include "VRattr_def.h"
#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "vrpdu_pto.h"


/***********************************************************************/

method VRGetDefName ( IGRlong	*msg; IGRchar *sMacroName )

{

  *msg = MSSUCC;

  strcpy ( sMacroName, "PPcndef" );

  return ( OM_S_SUCCESS );

}/* end method VRGetDefName */

/***********************************************************************/

method VRGetSearch ( 	IGRlong *msg;
                        struct GRid *PbId;
			IGRint ListSize;
			IGRint *NbParams;
			struct VRSelectAttr *ParamList;
			IGRchar *szSearch;
			struct GRmd_env *md_env)

{
	IGRlong			retmsg;
	IGRint			status;
	IGRchar			tmp[20];
	IGRint			FootIndex=-1;
	struct ret_struct	AttrRst;

if ( !szSearch )
{
	/*| ERROR : Null pointer given as argument */
	*msg = MSFAIL;
	return ( OM_E_INVARG );
}

	*msg = MSSUCC;

	strcpy (szSearch, VR_PIPING_DIR);
	strcat (szSearch, ":");


	/* NPD_G */
	status = 
	om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_GDIAMETER_DB,
				  &AttrRst, md_env ),
		  targetid = my_id);
		  as$status ( action = RET_STATUS );

	if ( retmsg&1 )
	{
		sprintf( tmp,"%.3lf",AttrRst.var.root_pm_st.value );
		strcat ( szSearch, tmp );
		strcat ( szSearch, "-");
	}

	/* End Preparation  */
		status = 
		om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_PREPS_G_IN,
				  &AttrRst, md_env ),
			targetid = my_id);
		as$status ( action = RET_STATUS );
	
	if ( retmsg&1 )
	{
		strcat ( szSearch, AttrRst.var.text_st.text_string );
		strcat ( szSearch, "-");
	}

	/* Pressure Rating */
	status = 
	om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_RATINGS_G_DB,
				  &AttrRst, md_env ),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	if ( retmsg&1 )
	{
		strcat ( szSearch, AttrRst.var.text_st.text_string );
		strcat ( szSearch, "-");
	}

	/* End Standard */
	status = 
	om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_END_STD_G_IN,
				  &AttrRst, md_env ),
		  targetid = my_id);
	as$status ( action = RET_STATUS );

	if ( retmsg&1 )
	{
		strcat ( szSearch, AttrRst.var.text_st.text_string );
	}

	/*" Search string = %s\n",szSearch*/

	return ( OM_S_SUCCESS );

}/* end VRGetSearch */

/***********************************************************************/

method VRGetSpecComp ( 	IGRlong *msg;
			IGRint NbParams ;
			struct VRSelectAttr *ParamList;
			struct GRid *PbId;
			struct GRmd_env *md_env )

{
	IGRlong			retmsg;
	IGRint			status;
	IGRchar			szPrepEnd[9], szRating[9], szStandard[9];
	IGRdouble		dDiam1;

	*msg = MSSUCC;

	{/* KLUDGE : Wait for full modifications */
		IGRint			FootIndex=-1;
		struct ret_struct	AttrRst;

		/* -- Initialize search parameters -- */

		/* End Preparation  */
		status = 
		om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_PREPS_G_IN,
				  &AttrRst, md_env ),
			targetid = my_id);
		as$status ( action = RET_STATUS );

		if ( retmsg&1 )
		strcpy( szPrepEnd, AttrRst.var.text_st.text_string );

		/* Pressure Rating */
		status = 
		om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_RATINGS_G_DB,
				  &AttrRst, md_env ),
			targetid = my_id);
		as$status ( action = RET_STATUS );

		if ( retmsg&1 )
		strcpy ( szRating, AttrRst.var.text_st.text_string );
		else
		szRating[0] = 0;

		/* End Standard */
		status = 
		om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_END_STD_G_IN,
				  &AttrRst, md_env ),
			targetid = my_id);
		as$status ( action = RET_STATUS );

		if ( retmsg&1 )
		strcpy ( szStandard, AttrRst.var.text_st.text_string );
		else
		szStandard[0] = 0;


		/* NPD_G */
		status = 
		om$send ( msg = message ACncpx.ACgive_structure
				( (IGRint *)&retmsg, &FootIndex, VR_N_GDIAMETER_DB,
				  &AttrRst, md_env ),
			targetid = my_id);
		as$status ( action = RET_STATUS );

		if (retmsg&1)	dDiam1= AttrRst.var.root_pm_st.value;
		else		dDiam1= 0.0;

		/*" End Prepa    : %s\n", szPrepEnd */
		/*" Press Rating : %s\n", szRating */
		/*" End Standard : %s\n", szStandard */
		/*" npd_g        : %f\n", dDiam1 */

	}/* end get search attributes */

	/* -- acces pdm/pdu to get the component's attributes -- */

	PbId->osnum = md_env->md_id.osnum;

	status=
	VRaccess_noz_db ( &retmsg, dDiam1, szPrepEnd,
			  szRating, szStandard, PbId, NULL );
	
	if ( !( status & 1 ))
	{
		/*| ERROR -> SPEC ACCESS FAILED */
		*msg=MSFAIL;
		return ( status );
	}

	return ( OM_S_SUCCESS );

}/* end VRGetSpecComp */

/***********************************************************************/

/*--------------------------------------------------------------------------*/
method VDgetObjDef( long *msg; VDobjDef *myDef )
{
  long	sts;


  myDef->info	= VR_I_ObjPipeNozz ;
  myDef->type	= 0 ;

  sts		= OM_S_SUCCESS ;
  *msg		= MSSUCC ;

  return sts ;
}
/*--------------------------------------------------------------------------*/

end implementation VRPNozz;
