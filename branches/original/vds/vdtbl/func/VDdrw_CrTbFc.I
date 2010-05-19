/* $Id: VDdrw_CrTbFc.I,v 1.2 2002/05/16 16:09:36 ylong Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_CrTbFc.I
 *
 * Description:
 *	Functions used by the "Create/Modify Table" command.
 *		VDdrw_filterListOfObjects
 *		VDdrw_getLocateTypeForBOM
 *		VDdrw_getColumnList
 *		VDdrw_processDbl
 *		VDdrw_sortRecsByColumn
 *		VDdrw_getAdsCrit
 *
 * Dependencies:
 *
 * History:
 *
 *	04/14/95	R. Manem	Creation
 *	04/19/95	R. Manem	Enhanced VDdrw_getFldValue to handle
 *					formatted text expressions.  Fixed bug
 *					in retrieving double values.
 *	05/15/95	R. Manem	Modified VDdrw_getFldValue to 
 *					incorporate new quantity structure 
 *					Added VDdrw_processDbl function
 *	06/15/95	R. Manem	Moved VDdrw_getFldValue to another file
 *	07/14/95	R. Manem	Added VDdrw_getAdsCrit,
 *					VDdrw_setLocateTypeForBOM
 *	08/30/95	R. Manem	Fixed bug in VDdrw_processDbl
 *	09/07/95	R. Manem	Fixed bug in VDdrw_processDbl
 *	09/22/95	R. Manem	Check for NULL_OBJID in parent
 *					of drawing objects.
 *      02/04/00        Ming            CR179901032
 *	05/15/02	ylong		TR6353
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
#include <math.h>

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

#include "vddrwattr.h"
#include "vdparmacros.h"
#include "VDcompmacros.h"

#define BUF_LEN			30
#define BIGBUFLEN		512
#define MIN_DIGITS_IN_DBL	20

#define VD_DRW_2D_MACRO		"VDdrw2d"
#define VD_DRW_3D_MACRO		"VDdrw3d"

extern GRclassid 	OPP_VDdrwObj_class_id;

from GRvg	import	GRgetattr;

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_filterListOfObjects

  Abstract
        Function filters the given list of located objects : drawing
	objects (VDdrw2d and VDdrw3d) are replaced by their respective 
	parent objects.  Duplicates are eliminated.

  Arguments

        IGRlong         	*msg            O       return code
        IGRint       		*nbObjs        	I/O     Number of objects
	struct GRobj_env	**lObjs		I/O	Pointer to list of 
							objects

  Notes/Remarks
	As input, nbObjs gives the number of objects in the list.  As output
	it indicates the number of valid objects in the list.
	The output list lObjs may be bigger than the input one : may happen
	when Route correction objects are replaced by components.

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_filterListOfObjects(	IGRlong			*msg,
					IGRint			*nbObjs,
					struct GRobj_env	**lObjs )
{
    IGRint		i, j, k;
    IGRlong		status = OM_S_SUCCESS;
    VDpartAttr		attr;

    SetProc( VDdrw_filterListOfObjects ); Begin

    *msg = MSSUCC;

#ifdef vdsDEBUG
    printf("\n\tInitial List of Objects\n" );
    for( i = 0 ; i < *nbObjs ; i++ )
        printf("\t\t# %d : [%d, %d]\n", i, (*lObjs)[i].obj_id.objid, 
					  	(*lObjs)[i].obj_id.osnum );
#endif

    /* set up structure for getting parent */

    attr.Iwant = VD_I_drwParentObj;

    /* 
     * replace drawing objects with parent objects 
     */

    for( i = (*nbObjs)-1 ; i >= 0 ; i-- )
    {
	if( vd_$is_ancestry_valid(	object	= &((*lObjs)[i].obj_id),
					classid	= OPP_VDdrwObj_class_id ) )
	{
	    __DBGpr_obj( "Drawing object found", (*lObjs)[i].obj_id );

	    status = 
	    _VD_SEND_OBJN( (*lObjs)[i].obj_id, GRvg.GRgetattr( 	msg, 
							(char *)&attr ) ); 
	    if( (status & *msg & 1) && attr.obj.obj_id.objid != NULL_OBJID )
	    {
		/* replace object */
	
		(*lObjs)[i] = attr.obj;
		__DBGpr_obj( "Replaced with parent object", (*lObjs)[i].obj_id );
	    }
	    else
	    {
		/* could not get parent, remove object from list */

		for( j = i ; j < (*nbObjs)-1 ; j++ )
		    (*lObjs)[j] = (*lObjs)[j+1];
	
		(*nbObjs)--;
	    }
	}
    }

    *msg = MSSUCC; /* Added for TR6353 -yl-, 05-15-02 */

    __DBGpr_int( "Number of objects after drw object processing", *nbObjs );

    /* 
     * eliminate duplicates 
     */

    for( i = (*nbObjs)-1 ; i > 0 ; i-- )
	for( j = 0 ; j < i ; j++ )
	    if( IF_EQ_GRID( (*lObjs)[j].obj_id,  (*lObjs)[i].obj_id ) )
	    {
		/* delete ith object */

		for( k = i ; k < (*nbObjs)-1 ; k++ )
		    (*lObjs)[k] = (*lObjs)[k+1];

		(*nbObjs)--;

		break;
	    }

#ifdef vdsDEBUG
    printf("\n\tFinal List of Objects\n" );
    for( i = 0 ; i < *nbObjs ; i++ )
        printf("\t\t# %d : [%d, %d]\n", i, (*lObjs)[i].obj_id.objid, 
					  	(*lObjs)[i].obj_id.osnum );
#endif

wrapup:
    End
    return OM_S_SUCCESS;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getLocateTypeForBOM

  Abstract
	This function gets the locate type for as$start_fence, using
	the list of valid component categories.

  Arguments

        IGRchar         **locType  	O       Locate type

  Notes/Remarks
	Memory for the buffer will be allocated by the function and must
	be freed by the caller.

  Returns
        OM_S_SUCCESS    = if success
	OM_E_NODYNMEM	if no memory
 -------------------------------------------------------------------------
-fe*/

IGRlong	VDdrw_getLocateTypeForBOM( IGRchar	**locType )
{
    IGRint		i,
			len, ind,
			nbCat;
    char		*lCat = NULL,
			macName[BUF_LEN],
			*ptr = macName;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrw_getLocateTypeForBOM ); Begin

    /* get list of categories */

    VD_compGetCompNames( BUF_LEN, &nbCat, &lCat );
    __DBGpr_int( "Number of component categories", nbCat );

    /* allocate memory for output buffer :  locType */

    *locType = NULL;
    *locType = _MALLOC( nbCat * BUF_LEN, IGRchar );
    if( !(*locType) )
    {
	status = OM_E_NODYNMEM;
	goto wrapup;
    }

    (*locType)[0] = '\0';

    /* add drawing macros */

    sprintf( *locType, "%s|%s|", VD_DRW_2D_MACRO, VD_DRW_3D_MACRO );

    /* get macro name for each category and concatenate in output buffer */

    ind = 0;
    for( i = 0 ; i < nbCat ; i++ )
    {
	__DBGpr_str( "Comp category name", &lCat[ind] );

	VD_compGetMacroFromComp( &lCat[ind], BUF_LEN, &ptr );
	__DBGpr_str( "macro name", macName );

	if( strlen( macName ) )
	{
	    strcat( *locType, macName );
	    strcat( *locType, "|" );
	}

	ind += BUF_LEN;
    }

    /* remove the last | char */

    len = strlen( *locType );
    (*locType)[len-1] = '\0';
    __DBGpr_str( "Locate type", *locType );

wrapup :
    _FREE( lCat );
    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getColumnList

  Abstract
        This function returns the list of column info, giving the number of
	columns, and for each column, the number of lines per row and the title.

  Arguments

        IGRlong         	*msg            O       return code
        IGRint       		nbFixRecs      	I 	Number of fixed records
        IGRint       		nbDatRecs      	I	Number of data records
	struct VDdrwlo_apifix	*fixRecs	I	List of fixed records
	struct VDdrwlo_data	*datRecs	I	List of data records
	IGRint			*nbCols		O	Number of columns
	IGRint			*maxLinesPerRow	O	Max. lines per row
	struct VDdrw_colInfo	**colRecs	O	List of column info

  Notes/Remarks
	Max lines per row is the maximum value of number of lines per row 
	for all the columns.
	Memory for colRecs will be allocated by the function and has to be
	freed by the caller

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_getColumnList(	IGRlong			*msg,
                                IGRint                  nbFixRecs,
                                IGRint                  nbDatRecs,
                                struct VDdrwlo_apifix   *fixRecs,
                                struct VDdrwlo_data     *datRecs,
				IGRint			*nbCols,
				IGRint			*maxLinesPerRow,
				struct VDdrw_colInfo	**colRecs )
{
    IGRint			i, j,
				col, line,
				oldLineMax, newLineMax;
    IGRlong			status = OM_S_SUCCESS;

    SetProc( VDdrw_getColumnList ); Begin

    *msg = MSSUCC;

    *nbCols = 0;
    *colRecs = NULL;
    *maxLinesPerRow = 0;

    /*
     * NOTE : the lineno and colno info in the fixed and variable recorde
     * start from 1, not 0
     */

    /* determine the highest column number */

    *nbCols = 0;
    for( i = 0 ; i < nbDatRecs ; i++ )
        if( datRecs[i].colno > *nbCols )
	    *nbCols = datRecs[i].colno ;

    for( i = 0 ; i < nbFixRecs ; i++ )
	if( fixRecs[i].VD.tx.colno > *nbCols )
	    *nbCols = fixRecs[i].VD.tx.colno ;

    __DBGpr_int( "Maximum column number", *nbCols );

    if( !*nbCols )
	goto wrapup;

    /* allocate memory for output buffer and initialize the contents */

    *colRecs = _MALLOC( *nbCols, struct VDdrw_colInfo );
    if( !*colRecs )
    {
	status = OM_E_NODYNMEM;
        goto wrapup;
    }

    for( i = 0 ; i < *nbCols ; i++ )
    {
	(*colRecs)[i].nbLines = 0;
	(*colRecs)[i].nbChars = 0;
	(*colRecs)[i].colTitles = NULL;
    }

    /* scan the list of data records and update info in output list */

    for( i = 0 ; i < nbDatRecs ; i++ )
    {
	col = datRecs[i].colno - 1;
	line = datRecs[i].lineno;

	/* update the number of lines */

	if( line > (*colRecs)[col].nbLines )
	{
	    oldLineMax = (*colRecs)[col].nbLines;

	    newLineMax = (*colRecs)[col].nbLines = line;

	    /* allocate memory for the column titles */

	    if( !( (*colRecs)[col].colTitles ) )
	    {
		/* malloc */

	    	(*colRecs)[col].colTitles = 
	    	( IGRchar (*)[VD_DRWLO_CHR_DESC]) malloc( line * 
							VD_DRWLO_CHR_DESC );
	    	if( !( (*colRecs)[col].colTitles ) )
	    	{
			status = OM_E_NODYNMEM;
        		goto wrapup;
    	    	}
	    }
	    else
	    {
		/* realloc */

	    	(*colRecs)[col].colTitles = 
	    	( IGRchar (*)[VD_DRWLO_CHR_DESC]) realloc( 
				(*colRecs)[col].colTitles,
				line * VD_DRWLO_CHR_DESC );
	    }

	    /* initialize the new titles to NULL string */

	    for( j = oldLineMax ; j < newLineMax ; j++ )
		(*colRecs)[col].colTitles[j][0] = '\0';
	}

	/* update number of characters in column */

	if( datRecs[i].numchr > (*colRecs)[col].nbChars )
	    (*colRecs)[col].nbChars = datRecs[i].numchr;

	/* set up the title for the corresponding line in this column */

        /* Modified by Ming for CR179901032 */
	switch( datRecs[i].rectyp )
	{
	    case VD_DRWLO_EN_ATTRIBUTE :

	    case VD_DRWLO_EN_ITEMNO :

	    case VD_DRWLO_EN_QUANTITY :

	    case VD_DRWLO_EN_USERDEFINED :

	    case VD_DRWLO_EN_OVERFLOW :

	    case VD_DRWLO_EN_EXPRESSION :

	    case VD_DRWLO_EN_EXPR_TABLE :
	        strcpy( (*colRecs)[col].colTitles[line-1], datRecs[i].ExAtt );
		break;

	    case VD_DRWLO_EN_FORMTEXT :
	        strcpy( (*colRecs)[col].colTitles[line-1], datRecs[i].Text );
	        break;
	}
    }

    /* scan the list of fixed records and update info in output list */

    for( i = 0 ; i < nbFixRecs ; i++ )
    {
	col = fixRecs[i].VD.tx.colno - 1;
	line = fixRecs[i].VD.tx.lineno;

	/* update the number of lines */

	if( line > (*colRecs)[col].nbLines )
	{
	    oldLineMax = (*colRecs)[col].nbLines;

	    newLineMax = (*colRecs)[col].nbLines = line;

	    /* allocate memory for the column titles */

	    if( !( (*colRecs)[col].colTitles ) )
	    {
		/* malloc */

	    	(*colRecs)[col].colTitles = 
	    	( IGRchar (*)[VD_DRWLO_CHR_DESC]) malloc( line * 
							VD_DRWLO_CHR_DESC );
	    	if( !( (*colRecs)[col].colTitles ) )
	    	{
			status = OM_E_NODYNMEM;
        		goto wrapup;
    	    	}
	    }
	    else
	    {
		/* realloc */

	    	(*colRecs)[col].colTitles = 
	    	( IGRchar (*)[VD_DRWLO_CHR_DESC]) realloc( 
				(*colRecs)[col].colTitles,
				line * VD_DRWLO_CHR_DESC );
	    }


	    /* initialize the new titles to NULL string */

	    for( j = oldLineMax ; j < newLineMax ; j++ )
		(*colRecs)[col].colTitles[j][0] = '\0';
	}

	/* update number of characters in column */

	if( fixRecs[i].VD.tx.numchr > (*colRecs)[col].nbChars )
	    (*colRecs)[col].nbChars = fixRecs[i].VD.tx.numchr;

	/* set up the title for the corresponding line in this column */

	strcpy( (*colRecs)[col].colTitles[line-1], VD_DRW_FIXEDTEXT_TITLE );
    }

    /* compute maxLinesPerRow */

    for( i = 0 ; i < *nbCols ; i++ )
        if( (*colRecs)[i].nbLines > *maxLinesPerRow )
	    *maxLinesPerRow = (*colRecs)[i].nbLines;

#ifdef vdsDEBUG
    printf("\n\tList of column Info : ");
    for( i = 0 ; i < *nbCols ; i++ )
    {
	printf("\n\n\t%d lines, %d chars ", 	(*colRecs)[i].nbLines,
						(*colRecs)[i].nbChars );
	for( j = 0 ; j < (*colRecs)[i].nbLines ; j++ )
	    printf("%s ", (*colRecs)[i].colTitles[j] );
    }
#endif

wrapup :

    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_processDbl

  Abstract
        This Function process the double value printed in a string.  It 
	scans the string for a decimal point, and then rounds off the value
	to the specified precision (number of digits after the decimal 
	point)

  Arguments

	IGRchar			*str		I/O	Input string having
							the double value
							As output, the value
							is rounded off
        IGRint                  len  		I 	Length of string
	IGRint			prec		I	Precision.

  Returns
	None

 -------------------------------------------------------------------------
-fe*/

void VDdrw_processDbl( 	IGRchar		*str,
			IGRint		len,
			IGRint		prec )
{
    IGRint		i, j,
			actLen,
			nbDec;
    IGRdouble		dblVal;
    IGRchar		*ptr = NULL,
			format[10];

    SetProc( VDdrw_processDbl ); Begin

    if( !str || !len )
    {
	__DBGpr_com( "Invalid arguments" );
	goto wrapup;
    }

    __DBGpr_str( "Input string value ", str );
    __DBGpr_int( "Input buffer length ", len );
    __DBGpr_int( "Precision ", prec );

    /* actual length of the string */
  
    actLen = strlen( str );
    __DBGpr_int( "Actual length", actLen );

    /* look for the decimal point */

    i = 0;
    while( i < actLen && str[i] != '.' )
	i++;

    /* if no decimal point is found, return */

    if( i >= actLen )
	goto wrapup; 

    __DBGpr_int( "Decimal point at", i );

    /* current number of decimal digits */

    nbDec = actLen - i - 1;
    __DBGpr_int( "nbDec", nbDec );

    /* 
     * if nbDec is 0, return (it should not happen normally, it can happen
     * only if there is a decimal point not followed by any digits )
     * OR, if nbDec == precision, return
     */

    if( nbDec <= 0 || nbDec == prec )
	goto wrapup;

    /* if nbDec is > than precision, round off the value */

    if( nbDec > prec )
    {
	if( prec > 0 )
	    if( str[i+prec+1] >= '5' )
	    {
		str[i+prec+1] = '\0';
		dblVal = strtod( str, &ptr );
		__DBGpr_dbl( "Dbl Val before rounding", dblVal );

		dblVal += pow( 10, -prec );
		__DBGpr_dbl( "Dbl Val after rounding", dblVal );

		sprintf( format, "%c.#%dg%c", '%', i + prec, '\0' );
		str[0] = '\0';
		sprintf( str, format, dblVal );
	    }
	str[i+prec+1] = '\0';
    }

    /* if nbDec is < than precision, try to pad as much as possible with 0's */

    if( nbDec < prec )
    {
	j = i+1+nbDec;
	while( j < (len-1) && j < (i+1+prec-nbDec) )
	    str[j++] = '0';
	str[j] = '\0';
    }

    __DBGpr_str( "Final string value ", str );

wrapup:
    End
    return;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_sortRecsByColumn

  Abstract
        Function sorts the given list of fixed and data records in the order
	of columns and lines within a column.

  Arguments

        IGRint       		*nbFixRecs     	I	Number of fixed records
        IGRint       		*nbDatRecs     	I	Number of data records
	struct VDdrwlo_apifix	*fixRecs	I	List of fixed records
	struct VDdrwlo_data	*datRecs	I	List of data records

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_sortRecsByColumn(	IGRint			nbFixRecs,
				IGRint			nbDatRecs,
				struct VDdrwlo_apifix	*fixRecs,
				struct VDdrwlo_data	*datRecs )
{
    IGRint			i, j;
    struct VDdrwlo_apifix	tmpFix;
    struct VDdrwlo_data		tmpDat;

    SetProc( VDdrw_sortRecsByColumn ); Begin
    
#ifdef vdsDEBUG
    printf( "\n\tInitial list of fixed records :\n");
    for( i = 0 ; i < nbFixRecs ; i++ )
	if( fixRecs[i].rectyp == VD_DRWLO_EN_TEXT )
	    printf( "\t\tcolno : %d, lineno : %d\n", fixRecs[i].VD.tx.colno,
						 fixRecs[i].VD.tx.lineno );

    printf( "\n\tInitial list of data records :\n");
    for( i = 0 ; i < nbDatRecs ; i++ )
	printf( "\t\tcolno : %d, lineno : %d\n", datRecs[i].colno,
						 datRecs[i].lineno );
#endif

    /* sort fixed records first by column number */

    for( i = 0 ; i < nbFixRecs ; i++ )
	for( j = i+1 ; j < nbFixRecs ; j++ )
	    if( fixRecs[i].rectyp == VD_DRWLO_EN_TEXT )
	        if( fixRecs[j].VD.tx.colno < fixRecs[i].VD.tx.colno )
	        {
		    tmpFix = fixRecs[j];
		    fixRecs[j] = fixRecs[i];
		    fixRecs[i] = tmpFix;
	        }

    /* sort the line numbers within column */

    for( i = 0 ; i < nbFixRecs ; )
    {
	for( j = i+1 ; 	j < nbFixRecs && 
			fixRecs[j].VD.tx.colno == fixRecs[i].VD.tx.colno ; j++ )
	    if( fixRecs[j].VD.tx.lineno < fixRecs[i].VD.tx.lineno )
	    {
		tmpFix = fixRecs[j];
		fixRecs[j] = fixRecs[i];
		fixRecs[i] = tmpFix;
	    }
	i = j;
    }

    /* sort data records first by column number */

    for( i = 0 ; i < nbDatRecs ; i++ )
	for( j = i+1 ; j < nbDatRecs ; j++ )
	    if( datRecs[j].colno < datRecs[i].colno )
	    {
		tmpDat = datRecs[j];
		datRecs[j] = datRecs[i];
		datRecs[i] = tmpDat;
	    }

    /* sort the line numbers within column */

    for( i = 0 ; i < nbDatRecs ; )
    {
	for( j = i+1 ; j < nbDatRecs && datRecs[j].colno == datRecs[i].colno ; 
						j++ )
	    if( datRecs[j].lineno < datRecs[i].lineno )
	    {
		tmpDat = datRecs[j];
		datRecs[j] = datRecs[i];
		datRecs[i] = tmpDat;
	    }
	i = j;
    }

#ifdef vdsDEBUG
    printf( "\n\tFinal list of fixed records :\n");
    for( i = 0 ; i < nbFixRecs ; i++ )
	printf( "\t\tcolno : %d, lineno : %d\n", fixRecs[i].VD.tx.colno,
						 fixRecs[i].VD.tx.lineno );

    printf( "\n\tFinal list of data records :\n");
    for( i = 0 ; i < nbDatRecs ; i++ )
	printf( "\t\tcolno : %d, lineno : %d\n", datRecs[i].colno,
						 datRecs[i].lineno );
#endif

    End
    return OM_S_SUCCESS;
}


/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getAdsCrit

  Abstract
        This Function gets the attribute driven symbol criteria, given the
	ads table name.

  Arguments

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_NODYNMEM   = if no memory
 -------------------------------------------------------------------------
-fe*/

end implementation Root;
