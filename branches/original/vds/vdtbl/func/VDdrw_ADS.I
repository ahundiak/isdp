/* $Id: VDdrw_ADS.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_ADS.I
 *
 * Description:
 *	Functions for attribute driven symbols :  
 *		VDdrw_getAdsCrit
 *		VDdrw_checkAttRelOnObjs
 *		VDdrw_checkAdsCritOnObjs
 *
 * Dependencies:
 *
 * History:
 *
 *	07/11/95	R. Manem	Creation
 *	09/07/95	R. Manem	Fixed TR # 179527408
 *      03/18/98        Ming            Fixed TR # 179800592
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

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"

#include "gr.h"
#include "godef.h"
#include "grdpbdef.h"

#include "EMSmsgdef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vdpardef.h"
#include "vdparmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"


IGRlong VDdrw_checkStr( IGRlong                 *msg,
                        IGRchar                 *str );
/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getAdsCrit

  Abstract
        This Function gets the attribute driven symbol criteria, given the
      	ads table name.

  Arguments
	
	IGRlong			*msg		O	Return code
	IGRchar			*adsTblName	I	Att driven symbol
							table name
	IGRshort		*nbCrit		O	Number of criteria
	struct VDadsym_rec	**lCrit		O	List of criteria

  Notes/Remarks
	Memory for output list will be allocated by the function and must
	be freed by the caller.

  Returns
        OM_S_SUCCESS    = if success
        OM_E_NODYNMEM   = if no memory
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_getAdsCrit(	IGRlong			*msg,
				IGRchar			*adsTblName,
				IGRshort		*nbCrit,
				struct VDadsym_rec	**lCrit )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrw_getAdsCrit ); Begin

    *nbCrit = 0;
    *lCrit = NULL;

    __DBGpr_str( "ADS table name", adsTblName );

    /* get the number of criteria */

    status = VD_adsym_grec( msg, adsTblName, NULL, NULL, nbCrit, NULL );
    __CheckRC( status, *msg, "VD_adsym_grec", wrapup );
    __DBGpr_int( "Number of criteria", *nbCrit );

    if( !( *nbCrit ) )
	goto wrapup;

    /* allocate memory */

    (*lCrit) = _MALLOC( *nbCrit, struct VDadsym_rec );
    if( !( *lCrit ) )
	vd_$mem_fail( sts = status );

    /* get the list of criteria */

    status = VD_adsym_grec( msg, adsTblName, NULL, NULL, nbCrit, *lCrit );
    __CheckRC( status, *msg, "VD_adsym_grec", wrapup );

wrapup :

    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkAttRelOnObjs

  Abstract
        This Function checks if the given attribute relationship is
	satisfied by the list of objects

  Arguments
	
	IGRlong			*msg		O	Return code
	struct ACrg_coll	att		I	Attribute info
	IGRshort		rel		I	Relationship
	IGRint			nbObjs		I	Number of objects
	struct GRobj_env	*lObjs		I	List of objects
	IGRshort		*result		O	Output result :
							1 = satisfied
							0 = not satisfied
  Notes/Remarks
	If rel == VD_cnt_qry_NONE, existence of attribute for the objects is
	checked.
	If nbObjs = 0, it is treated as if the relationship is not satisfied
	by the list of objects, and result is set to 0

  Returns
        OM_S_SUCCESS always
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_checkAttRelOnObjs(IGRlong			*msg,
				struct ACrg_coll	att,
				IGRshort		rel,
				IGRint			nbObjs,
				struct GRobj_env	*lObjs,
				IGRshort		*result )
{
    IGRint		i,
			cmpRes;
    IGRlong		status = OM_S_SUCCESS;
    struct ACrg_coll	tmpAtt;

    SetProc( VDdrw_checkAttRelOnObjs ); Begin

    __DBGpr_str( "Attribute name", att.name );
    __DBGpr_int( "Attribute type", att.desc.type );
    __DBGpr_int( "Relationship", rel );
    __DBGpr_int( "Number of objects", nbObjs );

#ifdef vdsDEBUG
    printf( "\n\tList of objects\n" );
    for( i = 0 ; i < nbObjs ; i++ )
	printf( "\t\t# %d : [%d, %d]\n", i, lObjs[i].obj_id.objid,
					    lObjs[i].obj_id.osnum );
#endif

    if( !nbObjs )
    {
	*result = 0;
	goto wrapup;
    }

    *result = 1;

    for( i = 0 ; i < nbObjs ; i++ )
    {
	tmpAtt = att;

	status =
	vd$review_params(	pMsg		= msg,
				pComponent	= &lObjs[i].obj_id,
				pMdEnv		= &lObjs[i].mod_env,
				pList		= &tmpAtt,
				NbParams	= 1 );
	if( !(status & *msg & 1) || tmpAtt.desc.type == AC_ATTRIB_TYPE_NOT_DEF )
	{
	    *result = 0;
	    goto wrapup;
	}

	if( rel == VD_cnt_qry_NONE )
	    continue;

        if( att.desc.type == VD_DRWLO_EN_CELL ||
            att.desc.type == VD_DRWLO_EN_SYMBOL )
        {
            att.desc.type = tmpAtt.desc.type;
            if( tmpAtt.desc.type == AC_ATTRIB_DOUBLE )
            {
               status = VDdrw_checkStr( msg, att.desc.value.att_txt );
               if( !(status&*msg&1) )
               {
                  *result = 0;
                  goto wrapup;
               }

               att.desc.value.att_exp = atof( att.desc.value.att_txt );
               __DBGpr_dbl( "Att str value", att.desc.value.att_exp );
            } 
        }

	/* validate relationship */

	if( att.desc.type == AC_ATTRIB_TEXT )
	{
	    __DBGpr_str( "Specified attribute value", att.desc.value.att_txt );

	    /* check type */

	    if( tmpAtt.desc.type != AC_ATTRIB_TEXT )
	    {
		*result = 0;
		goto wrapup;
	    }

	    __DBGpr_str( "Attribute value", tmpAtt.desc.value.att_txt );

	    cmpRes = strcmp( tmpAtt.desc.value.att_txt, att.desc.value.att_txt );
	    __DBGpr_int( "cmpRes", cmpRes );

	    switch( rel )
	    {
	        case VD_cnt_qry_EQUAL :
		    if( cmpRes )
		        *result = 0;
	            break;

	        case VD_cnt_qry_N_EQUAL :
		    if( !cmpRes )
		        *result = 0;
	            break;

	        default :
		    *result = 0;
	    }
        }
	else if( att.desc.type == AC_ATTRIB_DOUBLE )
	{
	    __DBGpr_dbl( "Specified attribute value", att.desc.value.att_exp );

	    /* check type */

	    if( tmpAtt.desc.type != AC_ATTRIB_DOUBLE )
	    {
		*result = 0;
		goto wrapup;
	    }

	    __DBGpr_dbl( "Attribute dbl value", tmpAtt.desc.value.att_exp );

	    switch( rel )
	    {
	        case VD_cnt_qry_G_THAN :
		    if( tmpAtt.desc.value.att_exp <= att.desc.value.att_exp )
		        *result = 0;
	    	    break;

	        case VD_cnt_qry_L_THAN :
		    if( tmpAtt.desc.value.att_exp >= att.desc.value.att_exp )
		        *result = 0;
	    	    break;

	        case VD_cnt_qry_G_EQUAL :
		    if( tmpAtt.desc.value.att_exp < att.desc.value.att_exp )
		        *result = 0;
	    	    break;

	        case VD_cnt_qry_L_EQUAL :
		    if( tmpAtt.desc.value.att_exp > att.desc.value.att_exp )
		        *result = 0;
	    	    break;

	        case VD_cnt_qry_EQUAL :
		    if( tmpAtt.desc.value.att_exp != att.desc.value.att_exp )
		        *result = 0;
	    	    break;

	    	case VD_cnt_qry_N_EQUAL :
		    if( tmpAtt.desc.value.att_exp == att.desc.value.att_exp )
		        *result = 0;
	    	    break;

	    	default :
		    *result = 0;
	    }
	}

	if( *result == 0 )
	    goto wrapup;
    }

wrapup :

    __DBGpr_int( "result value", *result );

    *msg = MSSUCC;

    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkAdsCritOnObjs

  Abstract
        This Function checks if the given criteria is satisfied
	by the list of objects

  Arguments
	
	IGRlong			*msg		O	Return code
	IGRshort		nbCrit		I	Number of criteria
	struct VDadsym_rec	*lCrit		I	List of criteria
	IGRint			nbObjs		I	Number of objects
	struct GRobj_env	*lObjs		I	List of objects
	IGRshort		*results	O	list of result for
							each criteria check :
							1 = satisfied by objs,
							0 = not satisfied
  Notes/Remarks
	Memory for output 'results' must be allocated by the caller.

  Returns
        OM_S_SUCCESS    = if success
        OM_E_NODYNMEM   = if no memory
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_checkAdsCritOnObjs(	IGRlong			*msg,
					IGRshort		nbCrit,
					struct VDadsym_rec	*lCrit,
					IGRint			nbObjs,
					struct GRobj_env	*lObjs,
					IGRshort		*results )
{
    IGRint		i;
    IGRlong		status = OM_S_SUCCESS;
    struct ACrg_coll	att;

    SetProc( VDdrw_checkAdsCritOnObjs ); Begin

    __DBGpr_int( "Number of criteria", nbCrit );

    for( i = 0 ; i < nbCrit ; i++ )
    {
	__DBGpr_int( "Loop index", i );

	/* set up the collector */

	strcpy( att.name, lCrit[i].szAtt );
	__DBGpr_str( "Att name ", att.name );

	if( lCrit[i].nDattyp == VD_DRWLO_EN_ASCII )
	{
	    att.desc.type = AC_ATTRIB_TEXT;
	    strcpy( att.desc.value.att_txt, lCrit[i].szAttval );
	    __DBGpr_str( "Att str value", att.desc.value.att_txt );
	}
	else if( lCrit[i].nDattyp == VD_DRWLO_EN_NUMERIC )
	{
	    att.desc.type = AC_ATTRIB_DOUBLE;
	    att.desc.value.att_exp = lCrit[i].dAttval;
	    __DBGpr_dbl( "Att dbl value", att.desc.value.att_exp );
	}
        else if( lCrit[i].nDattyp == VD_DRWLO_EN_CELL ||
                 lCrit[i].nDattyp == VD_DRWLO_EN_SYMBOL )
        {
            att.desc.type = lCrit[i].nDattyp;
            strcpy( att.desc.value.att_txt, lCrit[i].szAttval );
            __DBGpr_str( "Att str value", att.desc.value.att_txt );
        }

	status = VDdrw_checkAttRelOnObjs( 	msg, 
						att, lCrit[i].nnREL, 
						nbObjs, lObjs, 
						&results[i] );
	CheckRC( status, *msg );

	__DBGpr_int( "Result", results[i] );
    }

    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkStr

  Abstract
        This Function checks if the given string can be converted to a 
        double variable.	

  Arguments
	
	IGRlong			*msg		O	Return code
        IGRchar                 *str            I       Input string
 -------------------------------------------------------------------------
-fe*/
IGRlong VDdrw_checkStr( IGRlong			*msg,
			IGRchar			*str )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRchar		*temp_str = NULL;
    IGRint		len = 0;
    IGRint		i, j;

 
    *msg = MSSUCC;

    if( !str ) 
    {
      *msg = MSFAIL;
      return status;
    }

    len = strlen( str );
    temp_str = _MALLOC( len + 1, IGRchar );
    if( temp_str == NULL ) 
    {
      *msg = MSFAIL;
      return status;
    }

    j = 0;
    for( i = 0 ; str[i] != '\0' ; ++i )
    {
      if( str[i] != ' ' && str[i] != '\n' && str[i] != '\t' )
      {
        temp_str[j] = str[i];
        ++j;
      }
    }
    temp_str[j] = '\0';


    for( i = 0 ; temp_str[i] != '\0' ; ++i )
    {
      if( temp_str[i] < '0' || temp_str[i] > '9' )
      {
         *msg = MSFAIL;
         goto wrapup;
      }
    }

    strcpy( str, temp_str );
 
    wrapup:
    return status;
}

end implementation Root;
