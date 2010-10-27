/* $Id: VDdrw_tblSum.I,v 1.9 2002/03/31 18:20:30 ylong Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_tblSum.I
 *
 * Description:
 *	Functions used for summarizing objects in a table.
 *		VDdrw_getSumCriteria
 *		VDdrw_checkSumCritOnObj
 *		VDdrw_checkMatchCritOnObjs
 *		VDdrw_summarizeObjs
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *	06/26/95	R. Manem	Creation
 *	08/25/95	R. Manem	If sum criteria not retrievable
 *					return success.
 *	09/07/95	R. Manem	Print warning msg, if sum. criteria
 *					cannot be retrieved
 *	09/21/95	R. Manem	Even if list has only one object,
 *					summarize it. Necessary for getting
 *					the right expression for quantity
 *	10/10/95	R. Manem	Change last argument from 0 to 1,
 *					to get macro name, in view of 
 *					VD_drwGetACcpxInfo argument checking
 *	02/29/96	ADZ		Invalid initialization VDdrw_summ.
 *      03/15/00	Ming		For TR179901203
 *      08/24/00	Ming		For TR179901533
 *      10/25/00	Ming		For TR179902124
 *      06/19/01	ylong		TR5325
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "EMSmsgdef.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vddrwattr.h"
#include "vdpardef.h"
#include "vdparmacros.h"
#include "VDcompmacros.h"
#include "VDobj.h"

#define	BUF_SIZE		20

extern GRclassid	OPP_VDdrwObj_class_id;
extern GRclassid	OPP_ACconst_class_id;
extern GRclassid	OPP_VDatNode_class_id;
extern GRclassid	OPP_VDct1Base_class_id;

from ACcpx		import	find_macro;
from ACcpx_defn		import	ACgive_name;
from GRvg		import	GRgetattr;

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getSumCriteria

  Abstract
        This Function gets the list of summarization criteria for a table.

  Arguments

	IGRchar			*tblName	I	Name of summarization 
							table
        IGRshort          	*nbCrit 	O 	Nb of criteria
	struct VDdrwlo_sqty	**lCrit		O	List of criteria
	struct VDdrw_listInfo	**lmInfo	O	List of match records
							info
	IGRshort		*nbMatch	O	Nb of match records
	struct VDdrwlo_smatch	**lMatch	O	List of match records

  Remarks
	Memory will be allocated for the output lists and has to be freed
	by the caller
	The output size of mInfo list is same as that of lCrit (*nbCrit)

  Returns
	OM_S_SUCCESS	if success
	OM_E_NODYNMEM	If no memory
	OM_E_ABORT	if some other error

 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_getSumCriteria( 	IGRchar			*tblName,
				IGRshort		*nbCrit,
				struct VDdrwlo_sqty	**lCrit,
				struct VDdrw_listInfo	**lmInfo,
				IGRshort		*nbMatch,
				struct VDdrwlo_smatch	**lMatch )
{
    IGRint		i, 
			ind, prevInd;
    IGRshort		count;
    IGRlong		msg,
			status = OM_S_SUCCESS;

    SetProc( VDdrw_getSumCriteria ); Begin

    /* initialize output */

    *nbCrit = *nbMatch = 0;
    *lCrit = NULL;
    *lmInfo = NULL;
    *lMatch = NULL;

    __DBGpr_str( "Sum criteria table name", tblName );
    if( !strlen( tblName ) )
	goto wrapup;

    /* get the number of criteria */

    status = VD_crsum_gsqty( &msg, tblName, NULL, NULL, nbCrit, NULL );
    if( !(status & msg & 1) )
    {
	UI_status( "WARNING: Could not retrieve summ. criteria" );
	status = OM_S_SUCCESS;
	msg = MSSUCC;
	goto wrapup;
    }

    __DBGpr_int( "Number of sum. criteria", *nbCrit );

    if( !(*nbCrit) )
	goto wrapup;

    /* allocate output buffer */

    (*lCrit) = _MALLOC( *nbCrit, struct VDdrwlo_sqty );
    if( !( *lCrit ) )
	vd_$mem_fail( sts = status, msg = &msg );

    (*lmInfo) = _MALLOC( *nbCrit, struct VDdrw_listInfo );
    if( !( *lmInfo ) )
	vd_$mem_fail( sts = status, msg = &msg );

    /* get the list of criteria */

    status = VD_crsum_gsqty( &msg, tblName, NULL, NULL, nbCrit, *lCrit );
    __CheckRC( status, msg, "VD_crsum_gsqty", wrapup );

    __DBGpr_int( "Number of sum. criteria", *nbCrit );

    /* 
     * for each criteria, get number of match records, 
     * compute total number of match records
     */

    *nbMatch = 0;
    for( i = 0 ; i < *nbCrit ; i++ )
    {
	__DBGpr_int( "Loop index", i );
	status = VD_crsum_gsmtc( 	&msg, 
					tblName, 
					(*lCrit)[i].szCat,
					(*lCrit)[i].szSub,
					VD_DRWLO_EN_ALL,
					&count,
					NULL );
	__CheckRC( status, msg, "VD_crsum_gsmtc", wrapup );

	__DBGpr_int( "\tCurrent Number of match records", count );

	*nbMatch += count;
    }

    __DBGpr_int( "Total number of match records", *nbMatch );

    if( !(*nbMatch) )
	goto wrapup;

    /* allocate memory for the match records */

    *lMatch = _MALLOC( *nbMatch, struct VDdrwlo_smatch );
    if( !( *lMatch ) )
	vd_$mem_fail( sts = status, msg = &msg );

    /* get the list of match records */

    (*lmInfo)[0].startIndex = 0;
    (*lmInfo)[0].count = 0;
    prevInd = 0;

    for( i = 0 ; i < *nbCrit ; i++ )
    {
	ind = (*lmInfo)[i].startIndex = (*lmInfo)[prevInd].count + 
						(*lmInfo)[prevInd].startIndex;
	__DBGpr_int( "Loop index", i );
	__DBGpr_int( "Start index", ind );

	status = VD_crsum_gsmtc( 	&msg, 
					tblName, 
					(*lCrit)[i].szCat,
					(*lCrit)[i].szSub,
					VD_DRWLO_EN_ALL,
					&count,
					&(*lMatch)[ind] );
	__CheckRC( status, msg, "VD_crsum_gsmtc", wrapup );

	__DBGpr_int( "\tCurrent Number of match records", count);
	(*lmInfo)[i].count = count;

	prevInd = i;
    }

{
    IGRint	j;
    IGRchar	txt[1024];

    __DBGpr_com("\nList of sum criteria :" );
    for( i = 0 ; i < *nbCrit ; i++ )
    {
	__DBGpr_com("\n\tCategory, Sub-category, qty flag, qty expr\n" );
	sprintf(txt,"# %d : %s, %s, %d, %s", i, (*lCrit)[i].szCat, 
		(*lCrit)[i].szSub, (*lCrit)[i].nSflag, (*lCrit)[i].szExp );
	__DBGpr_str("", txt);

	ind = (*lmInfo)[i].startIndex;
	count = (*lmInfo)[i].count;
	sprintf(txt,"\tstartIndex = %d, nb match recs = %d", ind, count );
	__DBGpr_str("", txt);
	__DBGpr_com("SNo, attName, rel, datatype, valExpr\n" );
	for( j = ind ; j < ind + count ; j++ )
	    sprintf(txt,"\t\t#%d : %d, %s, %d, %d, %s", j, 
				(*lMatch)[j].nsIndex,
				(*lMatch)[j].szAtt, (*lMatch)[j].nnREL, 
				(*lMatch)[j].nDattyp, (*lMatch)[j].szExp );
	    __DBGpr_str("", txt);
    }
}

#ifdef vdsDEBUG
{
    IGRint	j;

    printf("\n\tList of sum criteria :\n" );
    for( i = 0 ; i < *nbCrit ; i++ )
    {
	printf("\n\tCategory, Sub-category, qty flag, qty expr\n\n" );
	printf("\t# %d : %s, %s, %d, %s\n", i, (*lCrit)[i].szCat, 
		(*lCrit)[i].szSub, (*lCrit)[i].nSflag, (*lCrit)[i].szExp );

	ind = (*lmInfo)[i].startIndex;
	count = (*lmInfo)[i].count;
	printf("\tstartIndex = %d, nb match recs = %d\n", ind, count );
	printf("\t\tSNo, attName, rel, datatype, valExpr\n\n" );
	for( j = ind ; j < ind + count ; j++ )
	    printf( "\t\t#%d : %d, %s, %d, %d, %s\n", j, (*lMatch)[j].nsIndex,
				(*lMatch)[j].szAtt, (*lMatch)[j].nnREL, 
				(*lMatch)[j].nDattyp, (*lMatch)[j].szExp );
    }
}
#endif
						
wrapup:
    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkSumCritOnObj

  Abstract
        This Function checks if an object satisfies the main summarization
	criteria : the component category and the attribute relationships.

  Arguments

	IGRlong			*msg		O	Return code
	struct GRobj_env	obj		I	Input object
	struct VDdrwlo_sqty	crit		I	Sum Criteria
	IGRshort		nbMatch		I	Nb of match records
	struct VDdrwlo_smatch	*lMatch		I	List of match records

  Remarks

  Returns
	OM_S_SUCCESS	if success
	OM_E_ABORT	if some error

  	*msg = 	MSSUCC, if match
		MSFAIL, if mismatch

 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_checkSumCritOnObj(	IGRlong			*msg,
					struct GRobj_env	obj,
					struct VDdrwlo_sqty	crit,
					IGRshort		nbMatch,
					struct VDdrwlo_smatch	*lMatch )
{
    IGRint		i;
    IGRlong		status = OM_S_SUCCESS;
    IGRshort		result;
    char		compName[BUF_SIZE],
			macBuf[80],
			*ptr = NULL,
			*cName = NULL;
    IGRchar		*macName = NULL;	/* do not free this, since
						   ACgive_name returns internal
						   buffer */
    struct ACrg_coll 	att;
    VDpartAttr		attr;

    SetProc( VDdrw_checkSumCritOnObj ); Begin
    *msg = MSSUCC;

    /* 
     * check component category 
     */

    /* get macro name */

    /* special processing for drawing objects (section cut objects) */

    if( vd_$is_ancestry_valid(	object	= &obj.obj_id,
				classid	= OPP_VDdrwObj_class_id ) )
    {
	__DBGpr_obj( "Drawing object", obj.obj_id );

	attr.Iwant = VD_I_drwMacroInfo;
	attr.aString[0] = '\0';

	status =
	_VD_SEND_OBJN( obj.obj_id, GRvg.GRgetattr( msg, (char *)&attr ) );
	__CheckRC( status, *msg, "GRvg.GRgetattr", wrapup );

	macName = (IGRchar *)(&attr.aString);
	__DBGpr_str( "Drawing object's macro name", macName );
    } 
    /* Added by Ming for TR179902124 */
    else if( !strcmp("stage", crit.szCat) )
    {
      if( !vd_$is_ancestry_valid(object  = &obj.obj_id,
                                 classid = OPP_VDatNode_class_id) &&
	  !vd_$is_ancestry_valid(object  = &obj.obj_id,
                                 classid = OPP_VDct1Base_class_id) )
      {
	*msg = MSFAIL;
        goto wrapup;
      }
    }
    else
    {
	/* get macro name */
	
	macBuf[0] = '\0';
	status = VD_drwGetACcpxInfo( &obj.obj_id, macBuf, 1 );
	CheckRC( status, 1 );

	macName = macBuf;
    }

    if( macName ) __DBGpr_str( "Macro name", macName );

    /* get category name */

    /* added by Ming for TR179901533 */
    /* Modified by Ming for TR179902124 */
    if( strcmp("Macro", crit.szCat) && strcmp("stage", crit.szCat) )
    {
      cName = compName;
      status = VD_compGetCompFromMacro( macName, BUF_SIZE, &cName );
      __CheckRC( status, 1, "VD_compGetCompFromMacro", wrapup );
      __DBGpr_str( "Component name", cName );
      __DBGpr_str( "Criteria category name", crit.szCat );

      /* validate comp category */

      /* Modified by Ming for TR179901203 */
      if( strcmp("structure", crit.szCat) )
      {
        if( strcmp( compName, crit.szCat ) )
        {
	  *msg = MSFAIL;
	  goto wrapup;
        }
      }
      else
      {
        if( strcmp("beam", compName) && 
	    strcmp("plate", compName) &&
	    strcmp("stiffener", compName) )
        {
          *msg = MSFAIL;
          goto wrapup;
        }
      }
    }

    /* check attribute relationships */

    for( i = 0 ; i < nbMatch ; i++ )
    {
	if( lMatch[i].nnREL != VD_cnt_qry_NONE )
	{
	    strcpy( att.name, lMatch[i].szAtt );

	    if( lMatch[i].nDattyp == VD_DRWLO_EN_ASCII )
	    {
	        att.desc.type = AC_ATTRIB_TEXT;
		strcpy( att.desc.value.att_txt, lMatch[i].szExp );
		__DBGpr_str( "Att str value", att.desc.value.att_txt );
	    }
	    else if( lMatch[i].nDattyp == VD_DRWLO_EN_NUMERIC )
	    {
	        att.desc.type = AC_ATTRIB_DOUBLE;
		__DBGpr_str( "Unconverted dbl value", lMatch[i].szExp );
		att.desc.value.att_exp = strtod( lMatch[i].szExp, &ptr );
		__DBGpr_dbl( "Att dbl value", att.desc.value.att_exp );
	    }

	    VDdrw_checkAttRelOnObjs(	msg,
					att,
					lMatch[i].nnREL,
					1,
					&obj,
					&result );
	    if( result )
		*msg = MSSUCC;
	    else
	    {
		*msg = MSFAIL;
		goto wrapup;
	    }
	}
    }

wrapup :

    if( !(status & *msg & 1) )
	*msg = MSFAIL;

    __DBGpr_int( "msg value", *msg );

    End
    return status;
}

				
/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkMatchCritOnObjs_0

  Abstract
        This Function checks if two objects satisfy the matching attribute
	criteria.

  Arguments

	IGRlong			*msg		O	Return code
	IGRshort		nbMatch		I	Nb of match records
	struct VDdrwlo_smatch   *lMatch         I       List of match records
	struct ACrg_coll	*attrList1	I	Attribute list of obj1
	struct ACrg_coll	*attrList2	I	Attribute list of obj2

  Remarks

  Returns
	OM_S_SUCCESS	always 

  	*msg = 	MSSUCC, if match
		MSFAIL, if mismatch

 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_checkMatchCritOnObjs_0( IGRlong		      *msg,
				      IGRshort		      nbMatch,
				      struct VDdrwlo_smatch   *lMatch,
				      struct ACrg_coll        *attrList1,
				      struct ACrg_coll        *attrList2 )
{
    IGRint		i;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrw_checkMatchCritOnObjs_0 ); Begin
    *msg = MSSUCC;

    __DBGpr_int( "Number of match criteria", nbMatch );

    for( i = 0 ; i < nbMatch ; i++ )
    {
      if( lMatch[i].nnREL == VD_cnt_qry_NONE )
      {
        if( attrList1[i].desc.type == AC_ATTRIB_TYPE_NOT_DEF || 
            attrList2[i].desc.type == AC_ATTRIB_TYPE_NOT_DEF ||
	    attrList1[i].desc.type != attrList2[i].desc.type )
        {
	  __DBGpr_com("Type NOT defined or two types are not equal");
	  *msg = MSFAIL;
	  goto wrapup;
        }
	   

        if( (attrList1[i].desc.type == AC_ATTRIB_TEXT &&
	     strcmp (	attrList1[i].desc.value.att_txt, 
			attrList2[i].desc.value.att_txt ) )  ||
            (attrList1[i].desc.type == AC_ATTRIB_DOUBLE  &&
	     attrList1[i].desc.value.att_exp != 
	     attrList2[i].desc.value.att_exp) )
        {
	  /* attributes do not match */
		
	  __DBGpr_com( "Attribute values of obj1 and obj2 do not match" );
	  *msg = MSFAIL;
	  goto wrapup;
        }
      }
    }

wrapup :
    End
    return OM_S_SUCCESS;
} /* VDdrw_checkMatchCritOnObjs_0 */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkMatchCritOnObjs

  Abstract
        This Function checks if two objects satisfy the matching attribute
	criteria.

  Arguments

	IGRlong			*msg		O	Return code
	struct GRobj_env	obj1		I	First object
	struct GRobj_env	obj2		I	Second object
	IGRshort		nbMatch		I	Nb of match records
	struct VDdrwlo_smatch	*lMatch		I	List of match records

  Remarks

  Returns
	OM_S_SUCCESS	always 

  	*msg = 	MSSUCC, if match
		MSFAIL, if mismatch

 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_checkMatchCritOnObjs(	IGRlong			*msg,
					struct GRobj_env	obj1,
					struct GRobj_env	obj2,
					IGRshort		nbMatch,
					struct VDdrwlo_smatch	*lMatch )
{
    IGRint		i;
    IGRlong		status = OM_S_SUCCESS;
    struct ACrg_coll	att1, att2;

    SetProc( VDdrw_checkMatchCritOnObjs ); Begin
    *msg = MSSUCC;

    __DBGpr_obj( "Object 1", obj1.obj_id );
    __DBGpr_obj( "Object 2", obj2.obj_id );
    __DBGpr_int( "Number of match criteria", nbMatch );

    for( i = 0 ; i < nbMatch ; i++ )
    {
	if( lMatch[i].nnREL == VD_cnt_qry_NONE )
	{
	    __DBGpr_str( "Match attribute name", lMatch[i].szAtt );

	    strcpy( att1.name, lMatch[i].szAtt );
	    strcpy( att2.name, lMatch[i].szAtt );
	    
	    status =
	    vd$review_params(	pMsg		= msg,
				pComponent	= &obj1.obj_id,
				pMdEnv		= &obj1.mod_env,
				pList		= &att1,
				NbParams	= 1 );
	    if( !(status & *msg & 1) || 
			att1.desc.type == AC_ATTRIB_TYPE_NOT_DEF )
	    {
		*msg = MSFAIL;
		goto wrapup;
	    }

	    status =
	    vd$review_params(	pMsg		= msg,
				pComponent	= &obj2.obj_id,
				pMdEnv		= &obj2.mod_env,
				pList		= &att2,
				NbParams	= 1 );
	    if( !(status & *msg & 1) ||
			att2.desc.type == AC_ATTRIB_TYPE_NOT_DEF ) 
	    {
		*msg = MSFAIL;
		goto wrapup;
	    }

	    if( att1.desc.type != att2.desc.type ||
		( att1.desc.type == AC_ATTRIB_TEXT &&
		strcmp( att1.desc.value.att_txt, att2.desc.value.att_txt ) )
		|| ( att1.desc.type == AC_ATTRIB_DOUBLE  &&
			att1.desc.value.att_exp != att2.desc.value.att_exp ) )
	    {
		/* attributes do not match */
		
		__DBGpr_com( "Attribute values of obj1 and obj2 do not match" );
		*msg = MSFAIL;
		goto wrapup;
	    }
	}
    }

wrapup :
    End
    return OM_S_SUCCESS;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_summarizeObjs

  Abstract
        This Function summarizes a given list of objects

  Arguments

	IGRlong			*msg		O	Return code
	IGRchar			*tblName	I	Name of summarization 
							table
        IGRint          	*nbRows 	I/O 	Nb of rows
	struct VDdrw_rowInfo	*lRows		I/O	List of row info
	struct GRobj_env	*lObjs		I/O	List of objects

  Remarks
	input nbRows is same as number of objects
	output nbRows = number of summarized rows.
	Output lRows will give the row info after summarization
	lObjs will be rearranged using the summarization criteria

  Returns
	OM_S_SUCCESS	if success
	OM_E_NODYNMEM	If no memory
	OM_E_ABORT	if some other error

 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_summarizeObjs(	IGRlong			*msg,
				IGRchar			*tblName,
				IGRint			*nbRows,
				struct VDdrw_rowInfo	*lRows,
				struct GRobj_env	*lObjs )
{
    IGRint			i, j, k, m,
				bytes, ind1, ind2,
				nbObjs,
				nbTotObjs,
				nbSumObjs,
				objInd, rowInd, 
				curAttrIndex, curObjIndex,
				refObjInd, curObjInd;
    IGRshort			nbMatch = 0,
				nbCrit = 0;
    IGRlong			status = OM_S_SUCCESS;
    struct GRobj_env		tmpObj;
    struct VDdrwlo_sqty		*lCrit = NULL;	
    struct VDdrw_listInfo	*lmInfo = NULL;
    struct VDdrwlo_smatch	*lMatch = NULL;
    struct ACrg_coll		*attrList = NULL;
    //struct ACrg_coll		*tmpAttrList = NULL;
    struct ACrg_coll		tmpAttr;
    IGRchar			szmsg[200];

    SetProc( VDdrw_summarizeObjs ); Begin

    UI_status( "Starting of Summarization ..." );

    *msg = MSSUCC;

    __DBGpr_str( "Sum criteria table name", tblName );
    __DBGpr_int( "Nb objects", *nbRows );

    if( *nbRows == 0 ) 
	goto wrapup;

    nbTotObjs = *nbRows;

    /* initialize output data */

    for( i = 0 ; i < nbTotObjs ; i++ )
    {
	lRows[i].startIndex = i;
	lRows[i].nbObjs = 1;
	lRows[i].qty.nSflag = VD_DRWLO_EN_COUNT;
	lRows[i].qty.szExp[0] = '\0';
    }

    __DBGpr_com("\nInitial list of objects:" );
    for( i = 0 ; i < *nbRows ; i++ )
    {
	sprintf(szmsg,"# %d : [%d, %d]\n", i, lObjs[i].obj_id.objid,
						lObjs[i].obj_id.osnum );
	__DBGpr_str("", szmsg);
    }
    szmsg[0] = '\0';

#ifdef vdsDEBUG
    printf("\n\tInitial list of objects\n" );
    for( i = 0 ; i < *nbRows ; i++ )
	printf("\t\t# %d : [%d, %d]\n", i, lObjs[i].obj_id.objid,
						lObjs[i].obj_id.osnum );
#endif

    /* get the summarization criteria */

    status = VDdrw_getSumCriteria( 	tblName,
					&nbCrit,
					&lCrit,
					&lmInfo,
					&nbMatch,
					&lMatch );
    __CheckRC( status, 1, "VDdrw_getSumCriteria", wrapup );

    __DBGpr_int( "nb criteria", nbCrit );
    __DBGpr_int( "nb match criteria", nbMatch );


    /* 
     * for each criteria 
     *	    go through remaining list of unsummarized objects, and pick up
     *	    the ones that satisfy the category and attribute relationships.
     *	    Move these upward, at the end of the summarized list of objects.
     *		For this set of objects,
     *		    set up reference object as first object in this set
     *		    not already summarized.
     *		    Go through remaining objects in this set, and pick and
     *		    move up those objs whose attributes match the reference 
     *		    object's attributes.
     *		    Set up the summarized row info in the output list
     */

    objInd = 0; 	/* start of unsummarized/unprocessed object list */
    rowInd = 0;		/* row info index, for the next summarized row */

    for( i = 0 ; i < nbCrit ; i++ )
    {
	__DBGpr_int( "Outer criteria loop : i = ", i );
	__DBGpr_int( "objInd ", objInd );

	curObjInd = objInd;
	for( j = objInd ; j < *nbRows ; j++ )
	{
	    /* 
	     * check if obj satisfies category and attribute relationships 
	     * in current criteria
	     */

	    VDdrw_checkSumCritOnObj(	msg,
					lObjs[j],
					lCrit[i],
					lmInfo[i].count,
					&lMatch[lmInfo[i].startIndex] );

	    if( *msg & 1 )
	    {
		/* move object up */

		if( curObjInd != j )
		{
		    __DBGpr_obj( "Moving object up", lObjs[j].obj_id );
		    __DBGpr_int( "\tto curObjInd", curObjInd );

		    tmpObj = lObjs[curObjInd];
		    lObjs[curObjInd] = lObjs[j];
	 	    lObjs[j] = tmpObj;
		}
		curObjInd++;
	    }
	    else
		*msg = MSSUCC;
	}

	__DBGpr_int( "Current object index", curObjInd );
	
	nbObjs = curObjInd - objInd;
	__DBGpr_int( "Current number of objects in set", nbObjs );

	/* if there are no objects for this criteria, continue with next one */

	if( !nbObjs )
	    continue;

	/* group according to matching criteria */

	refObjInd = objInd;	/* reference object index */
	__DBGpr_int( "Reference object index", refObjInd );
	__DBGpr_obj( "Reference object id", lObjs[refObjInd].obj_id );

	/* go through objects in this set, to group ones that match attrs */

	/* Modified by Ming for TR */

	/* Allocate memory for all attributes of all objects */
 	if( ((nbObjs) > 0) && (lmInfo[i].count > 0) ) 	
	{
	  attrList = _MALLOC( (nbObjs)*(lmInfo[i].count), struct ACrg_coll );
	  if( !attrList ) 
	  {
	    printf("Memory allocation failed!\n");
 	    goto wrapup;
 	  }
	  /*
	  tmpAttrList = _MALLOC(lmInfo[i].count, struct ACrg_coll);
	  if( !tmpAttrList ) 
	  {
	    printf("Memory allocation failed!\n");
	    goto wrapup;
	  }
	  */
	}

	/* Retrieve all the attributes for all the objects */
	for( j = objInd ; j < objInd+nbObjs ; j++ )
	{
	  for( k = 0 ; k < lmInfo[i].count ; k++ )
	  {
	    curAttrIndex = lmInfo[i].startIndex + k;
	    curObjIndex = j * lmInfo[i].count + k;
	    if( lMatch[curAttrIndex].nnREL == VD_cnt_qry_NONE )
	    {
	      __DBGpr_obj("vd$review_params for", lObjs[j].obj_id);
	      __DBGpr_str( "Attribute name", lMatch[curAttrIndex].szAtt );

	      strcpy( attrList[curObjIndex].name, lMatch[curAttrIndex].szAtt );
	
	      status =
              vd$review_params(   pMsg            = msg,
                                  pComponent      = &lObjs[j].obj_id,
                                  pMdEnv          = &lObjs[j].mod_env,
                                  pList           = &attrList[curObjIndex],
                                  NbParams        = 1 );
	      if( !(status&*msg&1) )
	      {
		attrList[curObjIndex].desc.type = AC_ATTRIB_TYPE_NOT_DEF;
		__DBGpr_com("attr type not defined !!");
	      }
	      else if( attrList[curObjIndex].desc.type == AC_ATTRIB_TEXT )
	      {
		__DBGpr_str("txt attr", 
			attrList[curObjIndex].desc.value.att_txt);
	      }
	      else
	      {
		__DBGpr_dbl("dbl attr", 
			attrList[curObjIndex].desc.value.att_exp);
	      }
	    }
	  }
	} 

	__DBGpr_com( "End of Retrieving Attributes for Summarization..." );

	while( refObjInd < objInd+nbObjs )
	{
	    curObjInd = refObjInd+1;
	    for( j = refObjInd+1 ; j < objInd+nbObjs ; j++ )
	    {
                /* commented by Ming for TR
	        status = VDdrw_checkMatchCritOnObjs(
						msg,
						lObjs[refObjInd],
						lObjs[j],
						lmInfo[i].count,
						&lMatch[lmInfo[i].startIndex] );
	        */

	        status = VDdrw_checkMatchCritOnObjs_0(
					msg,
					lmInfo[i].count,
					&lMatch[lmInfo[i].startIndex],
					&attrList[refObjInd*(lmInfo[i].count)],
					&attrList[j*(lmInfo[i].count)] ); 

	        if( status & *msg & 1 )
	        {
		    /* move object up */

		    __DBGpr_com("Move object up ...");

		    if( j != curObjInd )
		    {
		    	tmpObj = lObjs[curObjInd];
		    	lObjs[curObjInd] = lObjs[j];
		    	lObjs[j] = tmpObj;


			/*
			 * Use loop swap to replace Ming's segment swap 
			 * for TR5325. Reason? Not clear yet.
			 */
			bytes	= sizeof(struct ACrg_coll);
			ind1	= curObjInd*(lmInfo[i].count);
			ind2	= j*(lmInfo[i].count);
			for( m = 0; m < lmInfo[i].count; m++ )
			{
			  memset( &tmpAttr, 0, bytes );
			  memcpy( &tmpAttr, &attrList[ind1+m], bytes );
			  memcpy( &attrList[ind1+m], &attrList[ind2+m], bytes );
			  memcpy( &attrList[ind2+m], &tmpAttr, bytes );
			}

			/* Added by Ming for Tr
			memcpy( (char *)tmpAttrList,
			        (char *)&attrList[curObjInd*(lmInfo[i].count)],
				(lmInfo[i].count)*sizeof(struct ACrg_coll) );

			memcpy( (char *)&attrList[curObjInd*(lmInfo[i].count)],
			        (char *)&attrList[j*(lmInfo[i].count)],
				(lmInfo[i].count)*sizeof(struct ACrg_coll) );

			memcpy( (char *)&attrList[j*(lmInfo[i].count)],
			        (char *)tmpAttrList,
				(lmInfo[i].count)*sizeof(struct ACrg_coll) );

			*/
		    }
		    curObjInd++;
		}
		else
		{
		    status = OM_S_SUCCESS;
		    *msg = MSSUCC;
		}
	    }
	    nbSumObjs = curObjInd - refObjInd;
	    __DBGpr_int( "\nNumber of objects in summarized row", nbSumObjs );

	    /* update rowInfo entry */

	    lRows[rowInd].startIndex = refObjInd;
	    lRows[rowInd].nbObjs = nbSumObjs;
	    lRows[rowInd].qty.nSflag = lCrit[i].nSflag;
	    strcpy( lRows[rowInd].qty.szExp, lCrit[i].szExp );
	
	    refObjInd = curObjInd;
	    rowInd++;
	}

	_FREE( attrList );
	//_FREE( tmpAttrList );
	objInd += nbObjs;
    }

    /* set up rowInfo for all remaining objects that have not been summarized */

    __DBGpr_int( "Unsummarized row list starts from index ", objInd );

    for( i = objInd ; i < *nbRows ; i++ )
    {
	lRows[rowInd].startIndex = i;
	lRows[rowInd].nbObjs = 1;
	lRows[rowInd].qty.nSflag = VD_DRWLO_EN_COUNT;
	lRows[rowInd++].qty.szExp[0] = '\0';
    }

    *nbRows = rowInd;
    __DBGpr_int( "Output number of summarized rows", *nbRows );


    __DBGpr_com( "\nList of rowInfo:" );
    for( i = 0 ; i < *nbRows ; i++ )
    {
	sprintf(szmsg, "\t# %d : startIndex = %d, nbObjs = %d", i,
				lRows[i].startIndex, lRows[i].nbObjs );
	__DBGpr_str("", szmsg);
	sprintf(szmsg, "\t\tqty type = %d, exp = %s", lRows[i].qty.nSflag,
						lRows[i].qty.szExp );
	__DBGpr_str("", szmsg);
    }
				
    nbObjs = lRows[*nbRows-1].startIndex + lRows[*nbRows-1].nbObjs;
    __DBGpr_int( "Number of objects", nbObjs );

    __DBGpr_com("\nFinal list of objects" );
    for( i = 0 ; i < nbTotObjs ; i++ ) {
	sprintf(szmsg,"# %d : [%d, %d]", i, lObjs[i].obj_id.objid,
						lObjs[i].obj_id.osnum );
	__DBGpr_str("", szmsg);
    }
    szmsg[0] = '\0';

#ifdef vdsDEBUG
    printf( "\n\tList of rowInfo\n" );
    for( i = 0 ; i < *nbRows ; i++ )
    {
	printf( "\t\t# %d : startIndex = %d, nbObjs = %d\n", i,
				lRows[i].startIndex, lRows[i].nbObjs );
	printf( "\t\t\tqty type = %d, exp = %s\n", lRows[i].qty.nSflag,
						lRows[i].qty.szExp );
    }
				
    nbObjs = lRows[*nbRows-1].startIndex + lRows[*nbRows-1].nbObjs;
    __DBGpr_int( "Number of objects", nbObjs );

    printf("\n\tFinal list of objects\n" );
    for( i = 0 ; i < nbTotObjs ; i++ )
	printf("\t\t# %d : [%d, %d]\n", i, lObjs[i].obj_id.objid,
						lObjs[i].obj_id.osnum );
#endif

    UI_status( "End of Summarization ..." );

wrapup :

    _FREE( lCrit );
    _FREE( lmInfo );
    _FREE( lMatch );
    _FREE( attrList );
    //_FREE( tmpAttrList );

    End
    return status;
}

end implementation Root;
