/* $Id: VDdrw_attVal.I,v 1.3 2001/10/20 18:43:56 ramarao Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_attVal.I
 *
 * Description:
 *	Functions used for retrieving attribute/field values
 *		VDdrw_getFldValue
 *		VDdrw_getAttFromColl
 *
 * Dependencies:
 *
 * History:
 *
 *	06/15/95	R. Manem	Creation
 *	06/23/95	R. Manem	Added rowId argument to getFldValue
 *					function
 *	07/14/95	R. Manem	VDdrw_getFldValue adapted to return
 *					values when nbObjs = 0;  ==> item number
 *					for rows with implied materials will
 *					be returned correctly
 *	07/21/95	R. Manem	Integrated expression and quantity
 *					evaluation
 *	08/25/95	R. Manem	Change checking status for 
 *					VD_Return_Attr into check for attr type
 *	09/07/95	R. Manem	Ignore return status and msg for
 *					VD_Return_Attr
 *	09/20/95	R. Manem	Fixed bug in computation of qty expr.
 *	05/31/96	tlb		Added flag to VD_Return_Attr
 *      04/22/98        Ming            TR179801028
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

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
#include "VDtblCmdDef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vdparmacros.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "VDattrexp.h"
#include "VDCmdSSC.h"
#include "vdtblmacros.h"
#include "exmacros.h"

#define BIGBUFLEN		512
#define MIN_DIGITS_IN_DBL	25

#define	WARNING		"ERROR IN EXPRESSION"
#define	WARNING_LEN	30

extern GRclassid 	OPP_VDdrwTblHdr_class_id,
			OPP_VDdrwTblRow_class_id,
			OPP_VDdrwlo_occ_class_id,
			OPP_VDcrsrt_class_id,
			OPP_VDcrsum_class_id;

from VDdrwTblRow	import VDgetItemNumber;
from VDcrexp            import VDcrexp_gdata;
from VDcrexp            import VDcrexp_gtab;

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getFldValue

  Abstract
        Function returns the value of a particular field, given the data
	record information as defined in the layout.

  Arguments

        IGRlong         	*msg            O       return code
        IGRint       		nbObjs        	I	Number of objects
	struct GRobj_env	*lObjs		I	List of objects
	struct VDdrwlo_data	datRec		I 	Data record
	struct VDdrwlo_qtyExp	qty		I	Quantity info
	struct GRid		*rowId		I	Row grid
	IGRchar			**fldVal	O	Value of the field

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong	VDdrw_getFldValue(	IGRlong			*msg,
				IGRint			nbObjs,
				struct GRobj_env	*lObjs,
				struct VDdrwlo_data	datRec,
				struct VDdrwlo_qtyExp	qty,
				struct GRid		*rowId,
				IGRchar			**fldVal )
{
    IGRint		i, 
			len,
                        status0,
			found = TRUE,
			match = TRUE;
    IGRlong		status = OM_S_SUCCESS,
			locMsg = MSSUCC;
    IGRchar		format[10] = "",
			tmpBuf1[BIGBUFLEN], 	/* note : BIGBUFLEN must be
					   	   > than VD_DRWLO_CHR_TEXT */
			tmpBuf2[BIGBUFLEN],
			maxString[DI_PATH_MAX],
    			*attNamePtr = NULL,
    			c[2] = " ";
    struct ACrg_coll	att,
			firstAtt;
    VD_execRes		expVal;
    IGRint		expinfo_len;
    IGRchar		*expinfo = NULL;

    SetProc( VDdrw_getFldValue ); Begin

    *msg = MSSUCC;

    __DBGpr_int( "nbObjs", nbObjs );

    if( !fldVal )
	return status;

    *fldVal = NULL;

    __DBGpr_int( "Data record type ", datRec.rectyp );

    switch( datRec.rectyp )
    {
	case VD_DRWLO_EN_QUANTITY :

	    __DBGpr_com( "Computing QUANTITY" );

	    if( !nbObjs )
		goto wrapup;

	    if( qty.nSflag == VD_DRWLO_EN_COUNT )
	    {
	        *fldVal = _MALLOC( 7, IGRchar );

	        if( !*fldVal )
	            vd_$mem_fail( sts = status );

	        (*fldVal)[0] = '\0';
	        sprintf( *fldVal, "%d", nbObjs );

		__DBGpr_str( "*fldVal for QUANTITY", *fldVal );
	    }
	    else
	    {
	        __DBGpr_str( "Expression to evaluate", qty.szExp );
	        __DBGpr_int( "Expression length", strlen( qty.szExp ) );
	        status = VD_expParse(	qty.szExp,
					TRUE,
					VD_EXP_SILENT,
					nbObjs,
					lObjs,
					&expVal );
	        CheckRC( status, 1);

#ifdef vdsDEBUG
    printf( "\tExpression value : ");
    if( expVal.type == VD_int )
	printf( "int = %d\n", expVal.v.ival );
    else if( expVal.type == VD_double )
	printf( "double = %g\n", expVal.v.dval );
    else if( expVal.type == VD_string )
	printf( "string = %s\n", expVal.v.sval );
#endif

		if( status & 1 )
		{
	            if( expVal.type == VD_string )
	    	        len = strlen( expVal.v.sval ) + 1;
	            else if( expVal.type == VD_int || expVal.type == VD_double )
	            {
		        len = datRec.numchr+1;
		        if( len < MIN_DIGITS_IN_DBL )
			    len = MIN_DIGITS_IN_DBL;
	            }
	            else
		        len = 2;
		}
		else
		    len = 2;

	        __DBGpr_int( "Length of text", len );

	        /* allocate space */

	        *fldVal = _MALLOC( len, IGRchar );
	        if( !*fldVal )
		    vd_$mem_fail( sts = status );

	        (*fldVal)[0] = '\0';

	        /* copy value */
	        if( status & 1 )
	        {
	            if( expVal.type == VD_string )
	    	        strcpy( *fldVal, expVal.v.sval );
	            else if( expVal.type == VD_int || expVal.type == VD_double )
	            {
			/* 
			 * len-2 = number of significant digits.  Subtract 2,	
			 * from length of fldVal : 1 for decimal point, and 
			 * 1 for null char
			 */

		        sprintf( format, "%c.%dg%c", '%', len-2, '\0' );
		        __DBGpr_str( "Format string", format );
	    	        sprintf( *fldVal, format, (expVal.type == VD_int) ?
					(double)expVal.v.ival : expVal.v.dval );
		        VDdrw_processDbl( *fldVal, len, datRec.decplace );
	            }
		    else
		        strcpy( *fldVal, "" );
	        }
	        else
		    strcpy( *fldVal, "" );

	        __DBGpr_str( "*fldVal for QUANTITY", *fldVal );

		status = OM_S_SUCCESS;
	    }
	    break;

	case VD_DRWLO_EN_ATTRIBUTE :

	    __DBGpr_com( "Computing ATTRIBUTE value" );

	    if( !nbObjs )
		found = match = 0;

	    for( i = 0 ; i < nbObjs ; i++ )
	    {
		strcpy( tmpBuf1, datRec.ExAtt );

	    	/* loop through list of names */

	    	__DBGpr_str( "full attribute id ", tmpBuf1 );

	    	attNamePtr = strtok( tmpBuf1, c );
	    
	    	while( attNamePtr )
	    	{
	            strcpy( att.name, attNamePtr );
	            __DBGpr_str( "attribute name ", att.name );

	            VD_Return_Attr(	&locMsg,
					1,
					&lObjs[i].obj_id,
					&att,
					&lObjs[i].mod_env,
					TRUE );

		    if( att.desc.type != AC_ATTRIB_TYPE_NOT_DEF )
		        break;

		    attNamePtr = strtok( NULL, c );
	        }

		if( att.desc.type == AC_ATTRIB_TYPE_NOT_DEF )
	        {
		    /* attribute not found  : use default text */

		    *msg = MSSUCC;
		    found = FALSE;
		    break;
	        }
	        else
	        {
		    if( i == 0 )
		    {
			/* it is the first object : store the found value */

			firstAtt = att;
		    }
		    else
		    {
			/*
			 * the object is not the first one.  Compare its 
			 * value with the first object's attribute value
			 */

			if( !(att.desc.type == firstAtt.desc.type 
			    && ( ( att.desc.type == AC_ATTRIB_TEXT &&
		  			!strcmp( att.desc.value.att_txt, 
					 	firstAtt.desc.value.att_txt ) )
			         || ( att.desc.type == AC_ATTRIB_DOUBLE &&
					att.desc.value.att_exp ==
					firstAtt.desc.value.att_exp ) )) )
			{
			    /* both are not equal */
	
			    match = FALSE;
			    break;
			}
		    }
		}
	    }

	    __DBGpr_int( "Value of found", found );
	    __DBGpr_int( "Value of match", match );

	    if( found && match )
	    {
	        if( att.desc.type == AC_ATTRIB_TEXT )
	    	    len = strlen( att.desc.value.att_txt ) + 1;
	        else if( att.desc.type == AC_ATTRIB_DOUBLE )
		{
		    len = datRec.numchr+1;
		    if( len < MIN_DIGITS_IN_DBL )
			len = MIN_DIGITS_IN_DBL;
		}
		else
		    len = 2;
	    }
	    else
	    {
		len = strlen( datRec.Text ) + 1;
	    }

	    __DBGpr_int( "Length of text", len );

	    /* allocate space */

	    *fldVal = _MALLOC( len, IGRchar );
	    if( !*fldVal )
		vd_$mem_fail( sts = status );

	    (*fldVal)[0] = '\0';

	    /* copy value */

	    if( found && match )
	    {
	        if( att.desc.type == AC_ATTRIB_TEXT )
	    	    strcpy( *fldVal, att.desc.value.att_txt );
	        else if( att.desc.type == AC_ATTRIB_DOUBLE )
	        {
		    sprintf( format, "%c.%dg%c", '%', len-2, '\0' );
		    __DBGpr_str( "Format string", format );
	    	    sprintf( *fldVal, format, att.desc.value.att_exp );
		    VDdrw_processDbl( *fldVal, len, datRec.decplace );
	        }
		else
		    strcpy( *fldVal, "" );
	    }
	    else
		strcpy( *fldVal, datRec.Text );

	    __DBGpr_str( "*fldVal for ATTRIBUTE", *fldVal );

	    break;

	case VD_DRWLO_EN_FORMTEXT :

	    __DBGpr_com( "Computing Formatted text expression" );

	    /* evaluate formatted text expr from parameter list and format */

	    __DBGpr_str( "Parameter list", datRec.Text );
	    __DBGpr_str( "Format string ", datRec.ExAtt );

	    /* initialize tmpBuf1, for case of nbObjs = 0 */

	    tmpBuf1[0] = '\0';

	    for( i = 0 ; i < nbObjs ; i++ )
	    {
	        status = VDcreate_text2( 	datRec.ExAtt, 
						datRec.Text, 
						&lObjs[i].mod_env,
						&lObjs[i].obj_id,
						tmpBuf2 );
	        CheckRC( status, 1 );

		if( i == 0 )
		    strcpy( tmpBuf1, tmpBuf2 );
		else
		    if( strcmp( tmpBuf1, tmpBuf2 ) )
		    {
			/* put default empty string for the output */

			strcpy( tmpBuf1, " ? " );
			break;
		    }
	    }

	    len = strlen( tmpBuf1 ) + 1;
	    __DBGpr_int( "Length of tmpBuf1", len );

	    *fldVal = _MALLOC( len, IGRchar );
	    if( !*fldVal )
		vd_$mem_fail( sts = status );

	    strcpy( *fldVal, tmpBuf1 );
	    __DBGpr_str( "FormTextExpr value", *fldVal );

	    break;

	case VD_DRWLO_EN_ITEMNO :

	    if( rowId )
	    {
		__DBGpr_obj( "Row Id", *rowId );
		
		/* get length of buffer needed */

		status =
		_VD_SEND_OBJN( *rowId, VDdrwTblRow.VDgetItemNumber( 
								msg, 
								&len,
								NULL ) );
		__CheckRC( status, *msg, "VDdrwTblRow.VDgetItemNumber", wrapup );
		__DBGpr_int( "Length of item number string", len );

		/* allocate memory */

	    	*fldVal = _MALLOC( len, IGRchar );
									
		/* get item number */

		status =
		_VD_SEND_OBJN( *rowId, VDdrwTblRow.VDgetItemNumber(
								msg, 
								&len,
								*fldVal ) );
		__CheckRC( status, *msg, "VDdrwTblRow.VDgetItemNumber", wrapup );
		__DBGpr_str( "Item number value", *fldVal );

	    }

	    break;

	case VD_DRWLO_EN_EXPRESSION :

	    __DBGpr_com( "Computing EXPRESSION value" );

	    __DBGpr_str( "Expression to evaluate", datRec.Text );
	    __DBGpr_int( "Expression length", strlen( datRec.Text ) );
	    status = VD_expParse(	datRec.Text,
					TRUE,
					VD_EXP_SILENT,
					nbObjs,
					lObjs,
					&expVal );
	    CheckRC( status, 1);

#ifdef vdsDEBUG
    printf( "\tExpression value : ");
    if( expVal.type == VD_int )
	printf( "int = %d\n", expVal.v.ival );
    else if( expVal.type == VD_double )
	printf( "double = %g\n", expVal.v.dval );
    else if( expVal.type == VD_string )
	printf( "string = %s\n", expVal.v.sval );
#endif

	    if( status & 1 )
	    {
	        if( expVal.type == VD_string )
	    	    len = strlen( expVal.v.sval ) + 1;
	        else if( expVal.type == VD_int || expVal.type == VD_double )
	        {
		    len = datRec.numchr+1;
		    if( len < MIN_DIGITS_IN_DBL )
			    len = MIN_DIGITS_IN_DBL;
	        }
	        else
		    len = 2;
	    }
	    else
	    {
		// len = strlen( datRec.Text ) + 1;
		len = WARNING_LEN + 1;
	    }

	    __DBGpr_int( "Length of text", len );

	    /* allocate space */

	    *fldVal = _MALLOC( len, IGRchar );
	    if( !*fldVal )
		vd_$mem_fail( sts = status );

	    (*fldVal)[0] = '\0';

	    /* copy value */
	    if( status & 1 )
	    {
	        if( expVal.type == VD_string )
	    	    strcpy( *fldVal, expVal.v.sval );
	        else if( expVal.type == VD_int || expVal.type == VD_double )
	        {
		    sprintf( format, "%c.%dg%c", '%', len-2, '\0' );
		    __DBGpr_str( "Format string", format );
	    	    sprintf( *fldVal, format, (expVal.type == VD_int) ?
					(double)expVal.v.ival : expVal.v.dval );
		    VDdrw_processDbl( *fldVal, len, datRec.decplace );
	        }
		else
		    strcpy( *fldVal, "" );
	    }
	    else
		strcpy( *fldVal, WARNING );

	    __DBGpr_str( "*fldVal for ATTRIBUTE", *fldVal );

	    status = OM_S_SUCCESS;

	    break;

	case VD_DRWLO_EN_EXPR_TABLE :

	    __DBGpr_com( "Computing TABLE EXPRESSION value" );

	    __DBGpr_str( "Expression name to evaluate", datRec.Text );

            status0 = VDdrw_loadExpr( &expinfo_len,
				      datRec.Text,
				      &expinfo );
            if( !(status0) || !(expinfo) ) goto wrapup;

	    status = VD_expParse(	expinfo,
					TRUE,
					VD_EXP_SILENT,
					nbObjs,
					lObjs,
					&expVal );
	    CheckRC( status, 1);

#ifdef vdsDEBUG
    printf( "\tExpression value : ");
    if( expVal.type == VD_int )
	printf( "int = %d\n", expVal.v.ival );
    else if( expVal.type == VD_double )
	printf( "double = %g\n", expVal.v.dval );
    else if( expVal.type == VD_string )
	printf( "string = %s\n", expVal.v.sval );
#endif

	    if( status & 1 )
	    {
	        if( expVal.type == VD_string )
	    	    len = strlen( expVal.v.sval ) + 1;
	        else if( expVal.type == VD_int || expVal.type == VD_double )
	        {
		    len = datRec.numchr+1;
		    if( len < MIN_DIGITS_IN_DBL )
			    len = MIN_DIGITS_IN_DBL;
	        }
	        else
		    len = 2;
	    }
	    else
	    {
		// len = expinfo_len + 1;
		len = WARNING_LEN ;
	    }

	    __DBGpr_int( "Length of text", len );

	    /* allocate space */

	    *fldVal = _MALLOC( len, IGRchar );
	    if( !*fldVal )
		vd_$mem_fail( sts = status );

	    (*fldVal)[0] = '\0';

	    /* copy value */
	    if( status & 1 )
	    {
	        if( expVal.type == VD_string )
	    	    strcpy( *fldVal, expVal.v.sval );
	        else if( expVal.type == VD_int || expVal.type == VD_double )
	        {
		    sprintf( format, "%c.%dg%c", '%', len-2, '\0' );
		    __DBGpr_str( "Format string", format );
	    	    sprintf( maxString, format, (expVal.type == VD_int) ?
					(double)expVal.v.ival : expVal.v.dval );
		    strncpy( *fldVal, maxString, len-1 );
		    (*fldVal)[(len-1)] = '\0';
		    VDdrw_processDbl( *fldVal, len, datRec.decplace );
	        }
		else
		    strcpy( *fldVal, "" );
	    }
	    else
		strcpy( *fldVal, WARNING );

	    __DBGpr_str( "*fldVal for ATTRIBUTE", *fldVal );

	    status = OM_S_SUCCESS;
            _FREE( expinfo );

	    break;

	case VD_DRWLO_EN_OVERFLOW :

	case VD_DRWLO_EN_AUTOWRAP :

	case VD_DRWLO_EN_USERDEFINED :

	default :
	    break;
    }

wrapup :

    if( *fldVal == NULL )
    {
	*fldVal = _MALLOC( 1, IGRchar );
	if( *fldVal )
	    strcpy( *fldVal, "");
	else
	    status = OM_E_NODYNMEM;
    }

    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getAttFromColl

  Abstract
        Function gets the value of a given attribute, from the collector.
	The attribute value can be of unlimited length, and hence the
	memory for the output value is allocated by the function.

  Arguments

        IGRlong         	*msg            O       return code
	struct GRid		collId		I	rg-collector id
	IGRchar			*attName	I	attribute name
	IGRchar			**attVal	O	attribute value

  Notes/Remarks
	output buffer must be freed by the caller

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error

	*msg = MSFAIL, if attribute is not found in the collector
 -------------------------------------------------------------------------
-fe*/

IGRlong	VDdrw_getAttFromColl(	IGRlong		*msg,
				struct GRid	collId,
				IGRchar		*attName,
				IGRchar		**attVal )
{
    IGRint		len,	
			nbStr;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrw_getAttFromColl ); Begin
    *msg = MSSUCC;
    *attVal = NULL;

    __DBGpr_str( "Attribute name", attName );
    __DBGpr_obj( "Collector id", collId );

    /* get attribute length */

    status = VDgetAttLenFromColl( msg, collId, attName, &len, &nbStr );
    if( !(status & *msg & 1) )
	goto wrapup;

    __DBGpr_int( "Length of attribute value", len );

    /* allocate output buffer */
 
    *attVal = _MALLOC( len+1, IGRchar );

    if( !(*attVal) )
	vd_$mem_fail( sts = status );

    /* get the attribute value */

    status = VDgetAttFromColl( msg, collId, attName, *attVal, len+1, &nbStr );
    __CheckRC( status, *msg, "VDgetAttFromColl", wrapup );

    __DBGpr_str( "Attribute value", *attVal );
					
wrapup :
    End
    return status;
}

IGRint VDdrw_loadExpr(       IGRint		     *exp_len,
			     IGRchar		     *expnam,
                             IGRchar                 **expinfo )
{
    IGRint                status = OM_S_SUCCESS;
    GRspacenum            My_OS;
    struct GRid           lGRID;
    IGRchar               szMsg[80];
    IGRint                i, j, NbExpDat;
    struct VDdrwexp_tab   SSID_exp;
    struct VDdrwexp_data  *expdata;
    IGRshort              nExprData;
    IGRlong		  msg;
    IGRchar		  temp_str[VD_DRWLO_CHR_IDFLD];
    IGRchar		  *temp_ptr = NULL;


    SetProc( VDdrw_loadExpr ); Begin

    msg         = MSSUCC;
    NbExpDat    = 0;
    nExprData   = 0;
    expdata     = NULL;
    temp_str[0] = '\0';

    ex$get_cur_mod( osnum = &My_OS );

    temp_ptr = strchr( expnam, ',' );
    *temp_ptr = '\0';
    ++temp_ptr;

    vd$tblexp_old( msg     = &msg,
                   osnum   = My_OS,
                   tabnam  = temp_ptr,
                   GRid    = &lGRID );

    if( lGRID.objid == NULL_OBJID )
    {
      sprintf( szMsg, VD_CREXP_EMSG_NSYM, expnam );
      UI_status( szMsg );
      goto quit;
    }
    else
    {
      status =
      om$send( msg      = message VDcrexp.VDcrexp_gtab(&msg,
                                                       &SSID_exp,
                                                       &NbExpDat,
                                                       NULL),
               senderid = NULL_OBJID,
               targetid = lGRID.objid,
               targetos = lGRID.osnum );

      status =
      om$send( msg = message VDcrexp.VDcrexp_gdata(&msg,
                                                   (IGRint *)&nExprData,
                                                   &expdata),
               senderid = NULL_OBJID,
               targetid = lGRID.objid,
               targetos = lGRID.osnum );
      __DBGpr_int( "in load, No. of data records", nExprData );

      *expinfo = _MALLOC( nExprData * VD_CREXP_CHR_INFO, IGRchar );
      (*expinfo)[0] = '\0';

      for( i = 0 ; i < nExprData ; i++ )
      {
        for( j = 0 ; j < nExprData ; j++ )
        {
          if( expdata[j].Datsegn == i )
          {
            strcat( *expinfo, expdata[j].Datinfo );
            break;
          }
        }
      }

      *exp_len = strlen( *expinfo );

    }

    quit:
    _FREE( expdata );
    End
    return status;
}
end implementation Root;
