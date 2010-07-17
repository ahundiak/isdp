/* $Id: VRNozHoldi.I,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnozzle / VRNozHoldi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRNozHoldi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
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
# Revision 1.2  1996/01/17  00:12:36  pinnacle
# Replaced: vrnozzle/VRNozHoldi.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add prototypes
 *
 *************************************************************************/

class implementation VRNozHold;

#include "OMmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "maidmx.h"
#define AS_DEBUG	1

/***********************************************************************/

method GRxform(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid )
{

	IGRshort	four=4;
	IGRint		i;
	IGRmatrix	TmpMat;

	*msg = MSSUCC;
	*newobjid = my_id;

	/*A Multiply my matrix and the xform one */

	MAmulmx ( msg, &four, &four, &four, matrix, me->dMatrix, TmpMat );

	/*C set it back in my instances */
	for (i=0; i<16; i++)me->dMatrix[i] = TmpMat[i];

	return OM_S_SUCCESS;

}/* end GRxform */


/***********************************************************************/

method NDcopy(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)

{
	IGRint		status;

	status = 
	om$send (msg = message NDnodein.NDcopy
			(msg,cp_type,fr_env,to_env,newobjid),
		mode = OM_e_wrt_message,
		targetid = my_id );

return status;

}/* end NDcopy */

/***********************************************************************/

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
                       struct GRmd_env *md_env )
{
	IGRint status;

	status = 
	om$send (msg = message NDnodein.NDmove_to_root
			(msg, src_grid, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id );
	src_grid->objid = my_id;
	src_grid->osnum = OM_Gw_current_OS;


return status ;

}/* end NDmove_to_root */

/***********************************************************************/

method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)

{
	IGRlong	   retmsg;

	go->objid = my_id;
	go->osnum = OM_Gw_current_OS;

	if (matrix) 	MAidmx (&retmsg, matrix);

	if (mat_type)
	  if (matrix) 	MAtypemx (&retmsg, matrix, mat_type);
	  else	  	*mat_type = 1;

return OM_S_SUCCESS ;

}/* end ASreturn_go */

/***********************************************************************/

#include "parametric.h"

from	ACrg_collect	import	AClist_attribute;

method NDcompute_node ( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env)
{
	IGRlong			retmsg;
	IGRint			status,i,Index,TotalAttributes=0;
	struct ret_struct	RetStr;

	/* ---------------------- */
	/* -- Store attributes -- */
	/* ---------------------- */

	*msg = MSSUCC;

	/* Once moved to root during place macro, this objects receives
	   another compute ??????? */
	/* So, if no templates are given => return success */
	if ( count <= 0 ) return OM_S_SUCCESS;

	me->NbCollections = count - 1;
	/*" %d collections to store\n", me->NbCollections */

	/* -- Adjust instance size -- */

	if ( om$dimension_of (varray=me->NbAttributes) < me->NbCollections )
	{
		/*" Set vla NbAttributes size to %d\n",me->NbCollections */
		om$vla_set_dimension(	varray 	= me->NbAttributes,
					size 	= me->NbCollections );

	}/* end resize me->NbAttributes */


	/* -- Loop on collections to get attributes list -- */

	/* Get size of each collection */

	for ( i=0; i<me->NbCollections; i++ )
	{
		/* get attributes number */
		status =
		om$send( msg = message ACrg_collect.AClist_attribute
				( &retmsg, 0, NULL, &me->NbAttributes[i] ),
			targetid = list[i].objid,
			targetos = list[i].osnum);
		as$status(action = RET_STATUS);

		/*" Collection[%d] has %d attributes\n", i, me->NbAttributes[i] */

		TotalAttributes += me->NbAttributes[i];

	}/* end loop on collections to get the size */

	/* -- Adjust instances size -- */

	/*" Total = %d attributes\n", TotalAttributes */

	if ( om$dimension_of (varray=me->Attributes) < TotalAttributes )
	{
		/*" Set vla Attributes size to %d\n", TotalAttributes */
		om$vla_set_dimension(	varray 	= me->Attributes,
					size 	= TotalAttributes );

	}/* end resize me->Attributes */

	/* Get attributes from collections */

	for ( i=0 , Index=0; i<me->NbCollections; Index += me->NbAttributes[i], i++ )
	{


		/* get attributes */
		/*"(Start index = %d)\n", Index */
		status =
		om$send( msg = message ACrg_collect.AClist_attribute
				( &retmsg, me->NbAttributes[i],
				&me->Attributes[Index], &me->NbAttributes[i] ),
			targetid = list[i].objid,
			targetos = list[i].osnum);
		as$status(action = RET_STATUS);
		
		/*^
		IGRint kk;
			for( kk=0; kk<me->NbAttributes[i]; kk++ )
			{
				if ( me->Attributes[Index+kk].desc.type == AC_ATTRIB_TEXT )
	 				  printf("attr[%d] = %s\n", Index+kk, me->Attributes[Index+kk].desc.value.att_txt );
				else printf("attr[%d] = %f\n", Index+kk, 
					me->Attributes[Index+kk].desc.value.att_exp );
			}
		*/

		/*" Collection[%d] has %d attributes\n", i, me->NbAttributes[i] */

		TotalAttributes += me->NbAttributes[i];

	}/* end loop on collections to get the attributes */


	/* ------------------ */
	/* -- Store matrix -- */
	/* ------------------ */

	status =
	om$send( msg = message NDnode.NDgive_structure
				( &retmsg, &RetStr, md_env),
		targetid = list[count-1].objid,
		targetos = list[count-1].osnum);
	as$status(action = RET_STATUS);

	for (i=0; i<16; i++) me->dMatrix[i] = RetStr.var.ref_st.t[i];

	/*" O = %f, %f, %f\n",me->dMatrix[3],me->dMatrix[7],me->dMatrix[11]  */
	/*" X = %f, %f, %f\n",me->dMatrix[0],me->dMatrix[4],me->dMatrix[8]  */
	/*" Y = %f, %f, %f\n",me->dMatrix[1],me->dMatrix[5],me->dMatrix[9]  */
	/*" Z = %f, %f, %f\n",me->dMatrix[2],me->dMatrix[6],me->dMatrix[10]  */

return OM_S_SUCCESS;

}/* end NDcompute_node */

/***********************************************************************/

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                            struct GRmd_env *md_env )
{
	IGRint	i;
	IGRshort four=4;

	str->type = ref_generic;

	for (i=0; i<16; i++) str->var.ref_st.t[i] = me->dMatrix[i];

	*msg = MSSUCC;
	str->type = ref_generic;

	if (md_env)
	{
		MAmulmx(msg,&four,&four,&four,
			md_env->md_env.matrix, me->dMatrix,
			str->var.ref_st.t);
	}
 	else
	{
		for (i=0; i<16; i++) str->var.ref_st.t[i] = me->dMatrix[i];
	}


	return OM_S_SUCCESS;

}/* end NDgive_structure */

/***********************************************************************/

method VRGiveAttributes ( 	IGRlong *msg;
				IGRint CollectionsSize;IGRint AttributesSize;
				IGRint *NbCollections; IGRint NbAttributes[];
				struct ACrg_coll Attributes[] )
{

	IGRint	i;

*msg = MSSUCC;


	/* Return number of collections */
	if ( NbCollections ) *NbCollections = me->NbCollections;

	/* Return number of attributes per collection */
	if ( NbAttributes )
	{
		if (CollectionsSize < me->NbCollections) *msg = MSFAIL;

		for (i=0; i<CollectionsSize && i<me->NbCollections; i++)
			NbAttributes[i] = me->NbAttributes[i];

	}/* end return number attributes */

	/* Return attributes */
	if ( Attributes )
	{
		IGRint	TotalAttributes=0;

		for (i=0; i<me->NbCollections; i++)
			TotalAttributes += me->NbAttributes[i];

		if (AttributesSize < TotalAttributes) *msg = MSFAIL;

		for (i=0; i<AttributesSize && i<TotalAttributes; i++)
			Attributes[i] = me->Attributes[i];

	}/* end return number attributes */


return OM_S_SUCCESS;

}/* end VRGiveAttributes */

/***********************************************************************/

method VRSetInstance ( 	IGRlong *msg; IGRint Product;
				IGRchar *szTagNumber; IGRchar *szNotes;
				IGRdouble dAngle )
{
	/*"Product    = %s\n", Product */
	/*"Tag Number = %s\n", szTagNumber */
	/*"Notes      = %s\n", szNotes */
	/*"Angle      = %f\n", dAngle */

*msg = MSSUCC;

	me->Product	 = Product;
	strcpy (me->szNumber, szTagNumber);
	strcpy (me->szNotes, szNotes);
	me->dAngle	 = dAngle;

return OM_S_SUCCESS;

}/* end VRSetInstance */

/***********************************************************************/

method VRGetInstance ( 	IGRlong *msg; IGRint *Product;
				IGRchar szTagNumber[]; IGRchar szNotes[];
				IGRdouble *dAngle )
{
	/*"Product    = %s\n", me->Product */
	/*"Tag Number = %s\n", me->szNumber */
	/*"Notes      = %s\n", me->szNotes */
	/*"Angle      = %f\n", me->dAngle */

*msg = MSSUCC;

	*Product = me->Product;
	strcpy (szTagNumber, me->szNumber);
	strcpy (szNotes, me->szNotes);
	*dAngle	 = me->dAngle;


return OM_S_SUCCESS;

}/* end VRGetInstance */

/***********************************************************************/

end implementation VRNozHold;
