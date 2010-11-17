/* $Id: VDrowOver2.I,v 1.3.2.2 2003/05/15 17:06:11 ylong Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDrowOver2.I
 *
 * Description:
 *	Implementation of the following overridden methods  for VDdrwTblRow :
 *		ACmplace_from_def
 *		ACconstruct_feet
 *		VDcreate
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	04/25/95	R. Manem	Autowrapping, color symbology
 *	05/15/95	R. Manem	Quantity computation.
 *	06/16/95	R. Manem	Lineouts, forced newlines in texts,
 *					autowrapping at word boundaries,
 *					integration of rg-collector functions
 *	07/06/95	R. Manem	Font type changed from int to string
 *	07/14/95	R. Manem	Att driven symbols
 *	09/13/95	R. Manem	Support for removing line out
 *	09/28/95	R. Manem	Truncate extra long fixed-text strings
 *					Handle cases where the user overridden
 *					string length for fixed texts, exceeds 
 *					VD_DRWLO_CHR_TEXT
 *	04/03/96	R. Manem	Fixed bugs related to calling
 *					vd$placeBOM... with 0 elements.  This
 *					macro returns failure when given count=0
 *					and hence compute would abort, 
 *					corrupting BOM table
 * 	11/27/97	vini 		Place cell in BOM table
 *	02/05/01	Rama Rao	Modification in ACconstruct_feet().
 *	06/05/02	ylong		CR6391
 *  11/17/10  ah      SOL10
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblRow;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "nddef.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwtbl.h"
#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"

#include "gotextdef.h"
#include "vdcolldef.h"

#include "VDdrwgrProto.h"
#include "VDdrwgrMacro.h"

#include "vddlodef.h"
#include "vddlomacros.h"
#include "VDobj.h"

#include "grdpb.h"
#include "grdpbmacros.h"

#define LINEOUT_LEN_INCREASE	0.05
#define SMALL_BUF_LEN		20

extern GRclassid	OPP_GRowner_class_id;

from VDdrwTblHdr	import	VDgetRowConstructInfo,
				VDgetRowHeight,
				VDnewRowHeight;
from VDdrwSet		import	VDgetSetObjects;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract
        Place an occurence of the macro in the design file.
	Needs to be overridden because the class has instance data.

  Arguments
      int               *rc             O       0 FAILED 1 SUCCESS
      int               prop            I       see macro.h
      char              rep             I       navsea representation
      char              *macro_name     I       the macro to place
      int               numb_obj        I       the number of real template
      struct GRid       *uplist         I       the list of templates
      struct GRid       *def_occ        I       transfer context has to be
                                                performed from this default
                                                occurence
      struct GRmd_env   *mod_env        I       module env

  Status/Return Code
     OM_S_SUCCESS       if success;
     OM_E_ABORT         if fails

 -------------------------------------------------------------------------
-mo*/

method ACmplace_from_def(       int             *rc,
                                                prop;
                                char            rep;
                                char            *macro_name;
                                int             num_temp;
                                struct GRid     *temp_list;
                                struct GRid     *def_occ;
                                struct GRmd_env *md_env )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.ACmplace_from_def ); Begin

    *rc = MSSUCC;

    /* simply invoke the parent class method */

    status =
    _VD_SEND_WRT_M( my_id, ACncpx.ACmplace_from_def( rc,
                                                     prop,
                                                     rep,
                                                     macro_name,
                                                     num_temp,
                                                     temp_list,
                                                     def_occ,
                                                     md_env ));
     __CheckRC( status, *rc, "ACncpx.ACmplace_from_def", wrapup ) ;
    
wrapup :
    End
    return status;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACconstruct_feet from ACncpx

  Abstract
        Generates the resultant feet set, given the compute parameters.
        A NULLOBJID or a short list in feet_list are considered as temporary
        missing feet. A corresponding error is given to give foot access.


  Arguments

        IGRlong         *msg;            O      MSSUCC if success, MSFAIL
                                                if not.
        IGRint          cn_type;         I      reserved for future use
        IGRint          count;           I      number of roots
        struct GRid     list[];          I      list of roots the element is
                                                depending.
        struct GRmd_env *md_env;         I      current md_env
        IGRint          *fcount;         O      Number of feet (can be less
                                                than declared)
        struct GRid     *feet_list      I/O     This array array is initialized
                                                at input to the nb of declared
                                                feet. The method fills the
                                                array.

  Status/Return Code
     OM_S_SUCCESS       if success;
     OM_E_ABORT         if fails

 -------------------------------------------------------------------------
-mo*/

method  ACconstruct_feet(       IGRlong         *msg;
                                IGRint          cn_type;
                                IGRint          count;
                                struct GRid     list[];
                                struct GRmd_env *md_env;
                                IGRint          *fcount;
                                struct GRid     *feet_list )
{
    IGRint			i, j, ind,
				len,
				nbObjs,
				nbSym, nbCrit = 0,
				nbLines, nbTexts,
				nbExtRecs = 0,
				totalNbLines, nbOvfLines,
				nbExtraLines;
    OMuint			cnt = 0;
    IGRshort			nbDatRecs,
				nbFixRecs,
				lineoutFlag = 0,
				*results = NULL,
				resBuf[SMALL_BUF_LEN],
				tblOrient, tblLevel,
				defColor, userDefColor,
				attColor, overColor;
    IGRchar			footName[10],
				attName[80],
				*procStr = NULL,
				*datValue = NULL,
				adsTblName[VD_DRWLO_CHR_IDFLD], 
				tblLoName[VD_DRWLO_CHR_IDFLD];
    IGRdouble			xLo, yLo,
				xHi, yHi,
				rowWidth, rowHeight, extraLen,
				height,
				cornerPnt[3];
    IGRlong			status = OM_S_SUCCESS;
    GRobjlink			obj;
    OM_S_CHANSELECT		compChan,
				toHdrChan;
    enum GRdpmode		dpmode = GRbehe;
    struct GRid			hdrId,
				myGrid,
				ownerId,
				csId,
				cpyCollId,
				prev_foot[2],
				*lineIds = NULL,
				*textIds = NULL;
    struct GRobj_env		*lObjs = NULL;
    struct VDdrwlo_apifix	*fixRecs = NULL,
				lineOutRec,
				*fixDatRecs = NULL,
				*adsDatRecs = NULL,
				adsDatBuf[SMALL_BUF_LEN];
    struct VDdrwlo_data		*datRecs = NULL;
    VD_drwLoInfo		info;
    struct VDdrwlo_qtyExp	qty;
    struct VDdrwlo_extrec	*extRecs = NULL;
    struct VDadsym_rec		*lCrit = NULL;
			
    SetProc( VDdrwTblRow.ACconstruct_feet ); Begin
    *msg = MSSUCC;
    cpyCollId.objid = NULL_OBJID;

    __DBGpr_objlist( "List of roots", count, list );

    /* initialize output feet */

    *fcount = 2;

    for( i = 0 ; i < 2 ; i++ )
    {
	feet_list[i].osnum = OM_Gw_current_OS;
	feet_list[i].objid = NULL_OBJID;
    }

    myGrid.objid = my_id;
    myGrid.osnum = OM_Gw_current_OS;

    /* 
     * get the drawing layout parameters 
     */

    /* table level */

    status = vd$drw_layout_info(	msg	= msg,
					type	= VD_K_drwLO_tblLevel,
					info	= &info );
    CheckRC( status, *msg );
    tblLevel = info.val.sValue;
    __DBGpr_int( "Table level", tblLevel );

    /* default table color : for texts and lines */

    status = vd$drw_layout_info(	msg	= msg,
					type	= VD_K_drwLO_tblColor,
					info	= &info );
    CheckRC( status, *msg );
    defColor = info.val.sValue;
    __DBGpr_int( "Default table color", defColor );

    /* user defined text color */

    status = vd$drw_layout_info(	msg	= msg,
					type	= VD_K_drwLO_tblTextColor,
					info	= &info );
    CheckRC( status, *msg );
    userDefColor = info.val.sValue;
    __DBGpr_int( "User defined text color", userDefColor );

    /* attribute color */

    status = vd$drw_layout_info(	msg	= msg,
					type	= VD_K_drwLO_tblAttColor,
					info	= &info );
    CheckRC( status, *msg );
    attColor = info.val.sValue;
    __DBGpr_int( "Attribute color", attColor );

    /* overridden text color */

    status = vd$drw_layout_info(	msg	= msg,
					type	= VD_K_drwLO_tblModColor,
					info	= &info );
    CheckRC( status, *msg );
    overColor = info.val.sValue;
    __DBGpr_int( "Overridden text color", overColor );

    /* select the components channel */

    status =
    ems$make_chanselect(	chan_label	= GRcmpowner_to_components,
				chan_selector	= &compChan );
    __CheckRC( status, 1, "make_chanselect", wrapup );

    /* select the toHdr channel */

    status =
    om$make_chanselect(	channame	= "VDdrwTblRow.to_tblHdr",
			p_chanselect	= &toHdrChan );
    __CheckRC( status, 1, "selecting toHdrChan", wrapup );

    /* determine lineoutFlag */

    if( me->rowInfo & VD_ROW_LINEOUT )
    {
	VDtblSetRowCollFromFeet(&myGrid, &cpyCollId);
	lineoutFlag = 1;
    }
    __DBGpr_int( "Lineout flag ", lineoutFlag );

    /* Added by Rama Rao to give proper feet count */
    if( !lineoutFlag )   *fcount = 1;

    status = _VD_SEND_MY( VDdrwTblRow.VDgetQtyExpr( msg, &qty ) );
    CheckRC( status, *msg );

    for( i = 0 ; i < 2 ; i++ )
    {
	if( i == 0 )
	    strcpy( footName, "geom" );
	else
	    strcpy( footName, "misc" );

	/* get the owner feet */

	prev_foot[i].objid = ownerId.objid = NULL_OBJID;

	status =
	_VD_SEND_MY( NDmacro.ACreturn_foot(	msg,
						footName,
						&ownerId,
						NULL, NULL ) );
	__DBGpr_obj( "Owner id", ownerId );

	/* 
	 * if no line out is needed, just continue 
	 * 
	 *
	 * if( i == 1 && !lineoutFlag )
	 *   	continue;
	 * 
	 * Above two lines removed : must delete existing line if present :
	 * to be able to remove line out for the row and reconstruct feet
	 *		09/13/95
	 */

	if( !(status & *msg & 1) || ownerId.objid == NULL_OBJID )
	{
	    /* construct the owner if required */

	    if( i == 0 || ( i == 1 && lineoutFlag ) )
	    {
	    	ownerId.osnum = OM_Gw_current_OS;
	    	ownerId.objid = NULL_OBJID;

	    	status =
	    	om$construct(	classid	= OPP_GRowner_class_id,
				osnum	= ownerId.osnum,
				p_objid = &ownerId.objid );
	    	__CheckRC( status, 1, "GRowner construction", wrapup );

	    	__DBGpr_obj( "New GRowner id ", ownerId );
	    }
	}
	else
	{
	    /* owner already exists : delete its components if required */

	    if(1) /* if( !lineoutFlag  ) replaced for CR6391 */
	    {
		/* 
		 * erase row before deleting : needed to erase the
		 * the line out
		 */

		status =
		_VD_SEND_MY( GRgraphics.GRdisplay(
						msg, 
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&dpmode,
						&md_env->md_id ) );
		CheckRC( status, *msg );
							
	        status =
	        om$send(	msg		= message GRgraphics.GRdelete(
								msg,
								md_env ),
				senderid	= ownerId.objid,
				p_chanselect	= &compChan );
	        CheckRC( status, *msg );
	    }

	    /* Store the foot to disconnect */
	    prev_foot[i] = ownerId;
	}
	feet_list[i] = ownerId;
    }

    /* Disconnect is done outside the above loop - Rama Rao */
    /* disconnect the foot */
    for( i = 0 ; i < 2 ; i++ )
    {
       if( prev_foot[i].objid != NULL_OBJID )
       {
           status =
           _VD_SEND_OBJ( prev_foot[i], GRconnector.GRdisconn( msg,
                                                         &myGrid ) );
           __CheckRC( status, *msg, "GRconnector.GRdisconn", wrapup );
       }
    }

    /* get the header id from the to_tblHdr channel */

    status =
    om$get_channel_objects(	objid		= my_id,
				p_chanselect	= &toHdrChan,
				size		= 1,
				list		= &obj,
				count		= &cnt );
    __CheckRC( status, 1, "get_channel_objects", wrapup );

    if( cnt != 1 )
    {
	status = OM_E_ABORT;
	__DBGpr_com( "Cound not get header object from the channel" );
	goto wrapup;
    }

    hdrId.objid = obj.S_objid;
    hdrId.osnum = obj.osnum;
    __DBGpr_obj( "Header id", hdrId );

    /* get the row construct information from the header */

    status =
    _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDgetRowConstructInfo( 	msg,
								me->rowNumber,
								tblLoName,
								&tblOrient,
								&csId,
								cornerPnt,
								adsTblName ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetRowConstructInfo", wrapup );

    __DBGpr_int( "tblOrient", tblOrient );
    __DBGpr_vec( "Corner point", cornerPnt );
    __DBGpr_str( "Table layout name", tblLoName );
    __DBGpr_obj( "Coordinate system", csId );
    __DBGpr_str( "ADS Table name", adsTblName );
 
    /* construct line out if necessary */

#if 0	/* remove this part for CR6391, make lined out row editable */
    if( lineoutFlag )
    {
	/* get row height */

	status = 
	_VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDgetRowHeight(	msg,
								me->rowNumber,
								&rowHeight ) );
        __CheckRC( status, *msg, "VDdrwTblHdr.VDgetRowHeight", wrapup );

	__DBGpr_dbl( "Row height", rowHeight );

        status = VD_drwlo_grect(msg, 
				tblLoName,
				VD_DRWLO_EN_DATA,
				VD_DRWLO_EN_ALL,
				NULL,
				0, NULL,
				&xLo, &yLo, &xHi, &yHi );
        __CheckRC( status, *msg, "VD_drwlo_grect", wrapup );

    	/* compute actual corner point */

    	if( tblOrient == VD_DRWLO_EN_DESCEND )
	    cornerPnt[1] = cornerPnt[1] - rowHeight;
  
    	__DBGpr_vec( "Row corner point", cornerPnt );

#ifdef vdsDEBUG
    printf( "\txLo = %g, yLo = %g, xHi = %g, yHi = %g\n", xLo, yLo, xHi, yHi );
#endif
	rowWidth = xHi - xLo;
	extraLen = rowWidth * LINEOUT_LEN_INCREASE;
	__DBGpr_dbl( "Extra length for line-out line", extraLen );

	lineOutRec.rectyp = VD_DRWLO_EN_LINE;
	lineOutRec.symb.level = tblLevel;
	lineOutRec.symb.display_attr.weight = 0;
	lineOutRec.symb.display_attr.style = 0;
	lineOutRec.symb.display_attr.color = defColor;

	/* line-out line */

	lineOutRec.VD.ln.x1 = cornerPnt[0] - extraLen;
	lineOutRec.VD.ln.y1 = cornerPnt[1] + (rowHeight/2.0);
	lineOutRec.VD.ln.x2 = cornerPnt[0] + rowWidth + extraLen;
	lineOutRec.VD.ln.y2 = cornerPnt[1] + (rowHeight/2.0);

	/* construct the line out line */

	status = vd$placeBOMline(	count	= 1,
					array	= &lineOutRec,
					p_env	= md_env,
					p_rcs	= &csId,
					l_opt	= TRUE,
					p_nln	= &nbLines,
					p_lin	= &lineIds,
					p_msg	= msg );
	__CheckRC( status, *msg, "vd$placeBOMline", wrapup );

	/*
	__DBGpr_int( "No of lineout lines", nbLines );
	__DBGpr_objlist( "List of lines", nbLines, lineIds );
	*/

	status = VD_drwtb_addComponents( msg, md_env, nbLines, lineIds, 
							feet_list[1] );

	_FREE( lineIds );

	goto wrapup;
    }
#endif	/* remove this part for CR6391, make lined out row editable */

    /* 
     * construct the row components  (comes here only when there is no lineout)
     */

    /* get the number of replacable components */

    status = VD_drwlo_gdata( 	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				0, 0,
				0, NULL,
				&height,
				&nbDatRecs,
				NULL );

    /* 
     * if there are no data records, skip some tasks 
     * (should never happen though)
     */
				
    if( !nbDatRecs )
	goto CONT;

    /* allocate space */

    datRecs = _MALLOC( nbDatRecs, struct VDdrwlo_data );

    if( !datRecs )
	vd_$mem_fail( sts = status );

    /* get the list of replacable components */
    
    status = VD_drwlo_gdata( 	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				0, 0,
				0, NULL,
				&height,
				&nbDatRecs,
				datRecs );

    __DBGpr_int( "Number of data records", nbDatRecs );
    __DBGpr_dbl( "\n\n\t\tHEIGHT without extn records", height );

    /* sort the list */
 
    VDdrw_sortRecsByColumn( 0, nbDatRecs, NULL, datRecs );

    /* get the list of model objects */

    if( count == 1 )
	nbObjs = 0;
    else
    {
    	status = _VD_SEND_OBJ( list[1], VDdrwSet.VDgetSetObjects( msg,
								&nbObjs,
								NULL ) );
	__CheckRC( status, *msg, "VDdrwSet.VDgetSetObjects", wrapup );
	__DBGpr_int( "Number of objects in set", nbObjs );
	
	if( nbObjs )
	{
	    lObjs = _MALLOC( nbObjs, struct GRobj_env );
	    if( !lObjs )
		vd_$mem_fail( sts = status );

    	    status = _VD_SEND_OBJ( list[1], VDdrwSet.VDgetSetObjects(
								msg,
								&nbObjs,
								lObjs ) );
	    __CheckRC( status, *msg, "VDdrwSet.VDgetSetObjects", wrapup );

#ifdef vdsDEBUG
    printf("\n\tList of objects\n" );
    for( i = 0 ; i < nbObjs ; i++ )
	printf("\t\t# %d : [%d, %d]\n", i, lObjs[i].obj_id.osnum,
					   lObjs[i].obj_id.objid );
#endif
	}
    }
	
    /* 
     * for each field,
     *	get the value
     *	if the value does not fit in the field
     *		determine number of lines needed 
     *		if this field is the last one in column or it is followed by
     *							only by overflow lines
     *			number of extn recd = no of extra lines -
     *						no of ovf lines
     *		else field has to be truncated to this + any ovf lines
     *						following it.
     */
    
    for( i = 0 ; i < nbDatRecs ; i++ )
    {

	if( datRecs[i].rectyp == VD_DRWLO_EN_OVERFLOW )
	    continue;

	/* first look if value is present in collector */

	attName[0] = '\0';
	sprintf( attName, "%d %d", datRecs[i].colno, datRecs[i].lineno );

	_FREE( datValue );
	status = VDdrw_getAttFromColl(	msg, list[0], attName, &datValue );

	if( lineoutFlag && (!(status & *msg & 1) || !datValue) )
	{
	    _FREE( datValue );
	   status = VDdrw_getAttFromColl(msg, cpyCollId, attName, &datValue );
	   if( (status&*msg&1) && datValue )
	   {
		status = VDputAttInColl( msg, list[0], attName, datValue );
	   }
	}

	if( status & *msg & 1 )
	{
	    /* attribute present in collector */

	    __DBGpr_str( "Attribute value in collector ", datValue );
	}
	else
	{
	    status = OM_S_SUCCESS;
	    *msg = MSSUCC;

	    /* 
             * not in collector :  get actual value 
             */

	    _FREE( datValue );
	    status = VDdrw_getFldValue(	msg,
					nbObjs,
					lObjs,
					datRecs[i],
					qty,
					&myGrid,
					&datValue );
	    __CheckRC( status, *msg, "VDdrw_getFldValue", wrapup );
	}

	if( !datValue || !( len = strlen(datValue) ) ) 
	    continue;

	__DBGpr_int( "Data value length", len );
	__DBGpr_str( "Data value ", datValue );
	
	if( datRecs[i].numchr >= VD_DRWLO_CHR_TEXT )
	{
	    status = OM_E_ABORT;
	    __DBGpr_com( "Invalid data format : numchr >= VD_DRWLO_CHR_TEXT" );
	    goto wrapup;	
	}

	/* compute number of extra lines */

	if( !datRecs[i].numchr )
	{
	    status = OM_E_ABORT;
	    *msg = MSFAIL;
	    __DBGpr_com( "Invalid layout : numchr cannot be 0" );
	    goto wrapup;
	}

	/* get number of lines needed */

	_FREE( procStr );
	status = VDdrw_getNbLines(	datRecs[i].numchr,
					datValue,
					&totalNbLines,
					&procStr );
	__CheckRC( status, 1, "VDdrw_getNbLines", wrapup );
	__DBGpr_int( "Total number of Lines", totalNbLines );
					
	nbExtraLines =  totalNbLines - 1;
	__DBGpr_int( "Number of extra Lines", nbExtraLines );

	if( nbExtraLines <= 0 )
	    continue;

	/* count number of overflow lines */

	nbOvfLines = 0;
	for( j = i+1 ; j < nbDatRecs && 
	   		datRecs[j].colno == datRecs[j-1].colno &&
			datRecs[j].lineno == datRecs[j-1].lineno+1 ; j++ )
	    if( datRecs[j].rectyp == VD_DRWLO_EN_OVERFLOW )
	        nbOvfLines++;
	    else
	        break;

	__DBGpr_int( "Number of overflow lines", nbOvfLines );

	/* 
	 * calculate number of extension lines 
	 */

	if( !( j < nbDatRecs && datRecs[j].colno == datRecs[j-1].colno &&
				datRecs[j].lineno == datRecs[j-1].lineno + 1) )
	    nbExtraLines -= nbOvfLines;
	else
	    continue;

	/* 
	 * if nbOvfLines is more than required, then nbExtnLines will 
	 * become -ve
	 */

	if( nbExtraLines <= 0 )
	    continue;

	/* update the extension record list */

	if( !nbExtRecs )
	{
	    extRecs = _MALLOC( 1, struct VDdrwlo_extrec );
	    if( !extRecs )
		vd_$mem_fail( sts = status );
	}
	else
	{
	    /* realloc */

	    extRecs = _REALLOC( extRecs, nbExtRecs+1, struct VDdrwlo_extrec );
	    if( !extRecs )
		vd_$mem_fail( sts = status );
	}
	    
	extRecs[nbExtRecs].excol = datRecs[i].colno;
	extRecs[nbExtRecs].exlin = nbExtraLines;

	__DBGpr_int( "column number", datRecs[i].colno );
	__DBGpr_int( "number of extn lines in col",  nbExtraLines );

	nbExtRecs++;
    }

#ifdef vdsDEBUG
    printf( "\n\n\tTotal number of extn records : %d\n", nbExtRecs );
    printf( "\tList of records : \n");
    for( i = 0 ; i < nbExtRecs ; i++ )
	printf("\t\tExt rec [ %d ] : excol = %d, exlin = %d\n", i,
				extRecs[i].excol,
				extRecs[i].exlin );
    printf( "\n\n" );
#endif 
   

    /* free up the data records */

    _FREE( datRecs );

CONT :
    /* get the data row size using the number of extension records */
    
    status = VD_drwlo_grect(	msg, 
				tblLoName,
				VD_DRWLO_EN_DATA,
				VD_DRWLO_EN_ALL,
				NULL,
				nbExtRecs,
				extRecs,
				&xLo, &yLo, &xHi, &yHi );
    __CheckRC( status, *msg, "VD_drwlo_grect", wrapup );

#ifdef vdsDEBUG
    printf( "\txLo = %g, yLo = %g, xHi = %g, yHi = %g\n", xLo, yLo, xHi, yHi );
#endif

    /* 
     * compute the actual corner point for the row based on table 
     * orientation, and the rectangle size
     * if ascending : corner point same as got from VDgetRowConstructInfo
     * if descending : corner point's y coordinate is to be shifted below
     */

    if( tblOrient == VD_DRWLO_EN_DESCEND )
	cornerPnt[1] = cornerPnt[1] + yLo - yHi;
  
    __DBGpr_vec( "Row corner point", cornerPnt );

    /* 
     * get the list of fixed components with proper coordinates; construct them
     */

    status = VD_drwlo_gfix(	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				cornerPnt[0], cornerPnt[1],
				nbExtRecs, extRecs,
				&height,	
				&nbFixRecs,
				NULL );
    __CheckRC( status, *msg, "VD_drwlo_gfix", wrapup );
    
    __DBGpr_int( "No of fixed components", nbFixRecs );
    __DBGpr_dbl( "\n\n\t\tHEIGHT with extn records", height );

    if( !nbFixRecs )
        goto GETDATA;

    fixRecs = _MALLOC( nbFixRecs, struct VDdrwlo_apifix );

    if( !fixRecs )
	vd_$mem_fail( sts = status );

    status = VD_drwlo_gfix(	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				cornerPnt[0], cornerPnt[1],
				nbExtRecs, extRecs,
				&height,	
				&nbFixRecs,
				fixRecs );
    __CheckRC( status, *msg, "VD_drwlo_gfix", wrapup );
    __DBGpr_int( "Number of fixed records ", nbFixRecs );
    
    /*
     * set up symbology
     */

    for( i = 0 ; i < nbFixRecs ; i++ )
    {
	fixRecs[i].symb.level = tblLevel;
	fixRecs[i].symb.display_attr.color = defColor;

	if( fixRecs[i].rectyp == VD_DRWLO_EN_TEXT )
	{
	    /* get overwritten value, if any */

    	    attName[0] = '\0';
    	    sprintf( attName, "%d %d", fixRecs[i].VD.tx.colno,
						fixRecs[i].VD.tx.lineno );

	    _FREE( datValue );
	    status = VDdrw_getAttFromColl( msg, list[0], attName, &datValue );

	    if( status & *msg & 1 )
	    {
		__DBGpr_str( "Collector value ", datValue );

		if( fixRecs[i].VD.tx.numchr > VD_DRWLO_CHR_TEXT )
		    len = VD_DRWLO_CHR_TEXT;
		else
		    len = fixRecs[i].VD.tx.numchr;

		__DBGpr_int( "Length of user overridden text to copy", len );

		strncpy( fixRecs[i].VD.tx.Text, datValue, len );
		fixRecs[i].VD.tx.Text[len] = '\0';
	        fixRecs[i].VD.tx.numchr = strlen( fixRecs[i].VD.tx.Text ) + 1;

		fixRecs[i].symb.display_attr.color = overColor;
	    }
	    else
	    {
		/* must truncate extra long strings */

		len = strlen( fixRecs[i].VD.tx.Text ) + 1;
		__DBGpr_int( "Original length+1 of text", len );
		
		if( len < fixRecs[i].VD.tx.numchr )
		    fixRecs[i].VD.tx.numchr = len;
		else if( len > fixRecs[i].VD.tx.numchr )
		{
		    fixRecs[i].VD.tx.Text[ fixRecs[i].VD.tx.numchr ] = '\0';
		    fixRecs[i].VD.tx.numchr++;
		}
	    }
	    
#ifdef vdsDEBUG
	    printf( "\t# %d, numchr = %d, text = %s\n", i, 
			fixRecs[i].VD.tx.numchr, fixRecs[i].VD.tx.Text );
	    printf( "\t\tch_wdth = %g, ch_hgt = %g\n", fixRecs[i].VD.tx.ch_wdt,
						fixRecs[i].VD.tx.ch_hgt );
	    printf("\t\tcolor = %hd, weight = %c, style = %c\n", 
			fixRecs[i].symb.display_attr.color,
			fixRecs[i].symb.display_attr.weight,
			fixRecs[i].symb.display_attr.style );
#endif

	}
    }

    status = vd$placeBOMelem(	count	= nbFixRecs,
				array	= fixRecs,
				p_env	= md_env,
				p_rcs	= &csId,
				l_opt	= FALSE,
				p_nln	= &nbLines,
				p_lin	= &lineIds,
				p_ntx	= &nbTexts,
				p_txt	= &textIds,
				p_msg	= msg );
    __CheckRC( status, *msg, "vd$placeBOMelem", wrapup );

    __DBGpr_int( "No of lines", nbLines );
    __DBGpr_int( "No of texts", nbTexts );

    /*
    __DBGpr_objlist( "List of line ids", nbLines, lineIds );
    __DBGpr_objlist( "List of text ids", nbTexts, textIds );
    */

    status = VD_drwtb_addComponents( msg, md_env, nbTexts, textIds, 
								feet_list[0] );
    __CheckRC( status, *msg, "VD_drwtb_addComponents", wrapup );

    status = VD_drwtb_addComponents( msg, md_env, nbLines, lineIds, 
								feet_list[0] );
    __CheckRC( status, *msg, "VD_drwtb_addComponents", wrapup );

    _FREE( lineIds );
    _FREE( textIds );

GETDATA :

    /* 
     * get the list of data components with proper coordinates; construct them
     */

    status = VD_drwlo_gdata( 	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				cornerPnt[0], cornerPnt[1],
				nbExtRecs, extRecs,
				&height,
				&nbDatRecs,
				NULL );

    __DBGpr_int( "Number of data records", nbDatRecs );

    if( !nbDatRecs )
	goto ADS;

    /* allocate space */

    datRecs = _MALLOC( nbDatRecs, struct VDdrwlo_data );

    if( !datRecs )
	vd_$mem_fail( sts = status );

    /* get the list of replacable components */
    
    status = VD_drwlo_gdata( 	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				cornerPnt[0], cornerPnt[1],
				nbExtRecs, extRecs,
				&height,
				&nbDatRecs,
				datRecs );

    __DBGpr_int( "Number of data records", nbDatRecs );

    /* sort the list */

    VDdrw_sortRecsByColumn( 0, nbDatRecs, NULL, datRecs );

    /* 
     * allocate space for fixed data records : all elements will be texts
     * This array needs to be set up to call vd$placeBOMelem
     */

    fixDatRecs = _MALLOC( nbDatRecs, struct VDdrwlo_apifix );

    if( !fixDatRecs )
	vd_$mem_fail( sts = status );

    /* initialize the array */
 
    for( i = 0 ; i < nbDatRecs ; i++ )
    {
	fixDatRecs[i].rectyp = VD_DRWLO_EN_TEXT;
	strcpy( fixDatRecs[i].VD.tx.font, "default" );
	fixDatRecs[i].VD.tx.ch_spc = 1;
	fixDatRecs[i].VD.tx.Text[0] = '\0';
	fixDatRecs[i].symb.level = tblLevel;
	fixDatRecs[i].symb.display_attr.weight = 0;
	fixDatRecs[i].symb.display_attr.style = 0;
    }

    /*
     * for each field in list
     * 		get the value and set up the fixed data records
     *		construct only non NULL text objects
     * construct the components and add to the GRowner foot
     */

    ind = 0;
    for( i = 0 ; i < nbDatRecs ; )
    {
#ifdef vdsDEBUG
    	printf( "\t\tch_width = %g, ch_height = %g\n", datRecs[i].ch_wdt,
						datRecs[i].ch_hgt );
#endif

	_FREE( datValue );

	/* first look if value is present in collector */

	attName[0] = '\0';
	sprintf( attName, "%d %d", datRecs[i].colno, datRecs[i].lineno );

	_FREE( datValue );
	status = VDdrw_getAttFromColl(	msg, list[0], attName, &datValue );

	if( status & *msg & 1 )
	{
	    if( datRecs[i].rectyp == VD_DRWLO_EN_USERDEFINED )
	        fixDatRecs[ind].symb.display_attr.color = userDefColor;
	    else
	        fixDatRecs[ind].symb.display_attr.color = overColor;
	}
	else
	{
	    status = OM_S_SUCCESS;
	    *msg = MSSUCC;

	    /* 
             * not in collector :  get actual value 
             */

	    _FREE( datValue );
	    status = VDdrw_getFldValue(	msg,
					nbObjs,
					lObjs,
					datRecs[i],
					qty,
					&myGrid,
					&datValue );
	    __CheckRC( status, *msg, "VDdrw_getFldValue", wrapup );

	    fixDatRecs[ind].symb.display_attr.color = attColor;
	}

	if( !datValue || !( len = strlen(datValue) ) )
	{ 
	    i++;
	    continue;
	}

	__DBGpr_int( "Data value length", len );
	__DBGpr_str( "Data value ", datValue );
	
	fixDatRecs[ind].VD.tx.numchr = datRecs[i].numchr+1;
	fixDatRecs[ind].VD.tx.ch_wdt = datRecs[i].ch_wdt;
	fixDatRecs[ind].VD.tx.ch_hgt = datRecs[i].ch_hgt;
	fixDatRecs[ind].VD.tx.ch_spc = datRecs[i].ch_spc;
	fixDatRecs[ind].VD.tx.justif = datRecs[i].justif;
	strcpy( fixDatRecs[ind].VD.tx.font, datRecs[i].font );
	fixDatRecs[ind].VD.tx.xcor = datRecs[i].xcor;
	fixDatRecs[ind].VD.tx.ycor = datRecs[i].ycor;
	fixDatRecs[ind].symb.display_attr.weight = datRecs[i].weight;

#ifdef vdsDEBUG
    	printf( "\t\tch_wdth = %g, ch_hgt = %g\n", fixDatRecs[ind].VD.tx.ch_wdt,
						fixDatRecs[ind].VD.tx.ch_hgt );
	    printf("\t\tcolor = %hd, weight = %c, style = %c\n", 
			fixDatRecs[ind].symb.display_attr.color,
			fixDatRecs[ind].symb.display_attr.weight,
			fixDatRecs[ind].symb.display_attr.style );
	printf("\t\t\txcor = %g, ycor = %g\n", fixDatRecs[ind].VD.tx.xcor,
						fixDatRecs[ind].VD.tx.ycor );
	printf("\t\t\tfont = %d\n", datRecs[i].font );
#endif

	/* get number of lines needed */

	_FREE( procStr );
	status = VDdrw_getNbLines(	datRecs[i].numchr,
					datValue,
					&totalNbLines,
					&procStr );
	__CheckRC( status, 1, "VDdrw_getNbLines", wrapup );
	__DBGpr_int( "total number of lines", totalNbLines );

	nbExtraLines = totalNbLines - 1;
	__DBGpr_int( "number of extra lines", nbExtraLines );
					
	if( totalNbLines == 1 )
	{
	    strcpy( fixDatRecs[ind].VD.tx.Text, datValue );
	    i++;
	    ind++;
	}
	else
	{
	    /* must wrap text */

	    __DBGpr_com( "Must process text for autowrapping" );

	    status = VDdrw_getNthLine(	1,
					procStr,
					fixDatRecs[ind].VD.tx.Text );
	    __CheckRC( status, 1, "VDdrw_getNthLine", wrapup );

	    __DBGpr_str( "First Line value", fixDatRecs[ind].VD.tx.Text );

	    ind++;
	    i++;

	    /* compute number of extra lines */

	    if( !datRecs[i].numchr )
	    {
	        status = OM_E_ABORT;
	        *msg = MSFAIL;
	        __DBGpr_com( "Invalid layout : numchr cannot be 0" );
	        goto wrapup;
	    }

	    nbExtraLines =  totalNbLines - 1;
	    __DBGpr_int( "Number of extra Lines", nbExtraLines );

	    for( j = i ; j < i+nbExtraLines ; j++ )
	    {
		if( (datRecs[j].lineno == datRecs[j-1].lineno+1) && 
			( datRecs[j].rectyp == VD_DRWLO_EN_OVERFLOW ||
			  datRecs[j].rectyp == VD_DRWLO_EN_AUTOWRAP ) )
		{
		    /* 
		     * line number starts from 2 now, since 1 is already got
		     */

		    status = VDdrw_getNthLine(	j-i+2,
						procStr,
						fixDatRecs[ind].VD.tx.Text );
		    __CheckRC( status, 1, "VDdrw_getNthLine", wrapup );

		    __DBGpr_int( "Line ", j-i+1 );
		    __DBGpr_str( "Line string value", fixDatRecs[ind].VD.tx.Text );
		    fixDatRecs[ind].VD.tx.Text[datRecs[i].numchr] = '\0';
		    fixDatRecs[ind].VD.tx.numchr = datRecs[i].numchr+1;

		    fixDatRecs[ind].VD.tx.ch_wdt = datRecs[j].ch_wdt;
		    fixDatRecs[ind].VD.tx.ch_hgt = datRecs[j].ch_hgt;
		    fixDatRecs[ind].VD.tx.ch_spc = datRecs[j].ch_spc;
		    fixDatRecs[ind].VD.tx.justif = datRecs[j].justif;
		    strcpy( fixDatRecs[ind].VD.tx.font, datRecs[j].font );
		    fixDatRecs[ind].VD.tx.xcor = datRecs[j].xcor;
		    fixDatRecs[ind].VD.tx.ycor = datRecs[j].ycor;
		    fixDatRecs[ind].symb.display_attr.color = 
				fixDatRecs[ind-1].symb.display_attr.color;
		    fixDatRecs[ind].symb.display_attr.weight = 
				fixDatRecs[ind-1].symb.display_attr.weight;

#ifdef vdsDEBUG
	printf( "\t\tch_wdth = %g, ch_hgt = %g\n", fixDatRecs[ind].VD.tx.ch_wdt,
						fixDatRecs[ind].VD.tx.ch_hgt );
	printf("\t\t\txcor = %g, ycor = %g\n", fixDatRecs[ind].VD.tx.xcor,
						fixDatRecs[ind].VD.tx.ycor );
#endif
		    ind++;
		}
		else
		    break;
	    }
	    i = j;
	}
	__DBGpr_int( "\n\tAt end of loop, value of i ", i );
	__DBGpr_int( "\n\tAt end of loop, value of index ", ind );

    }

    __DBGpr_int( "Nb of fixDatRecs ", nbDatRecs );
    __DBGpr_int( "Nb of valid fixDatRecs ", ind );

    if( !ind )
	goto ADS;

    status = vd$placeBOMelem(	count	= ind,
				array	= fixDatRecs,
				p_env	= md_env,
				p_rcs	= &csId,
				l_opt	= FALSE,
				p_nln	= &nbLines,
				p_lin	= &lineIds,
				p_ntx	= &nbTexts,
				p_txt	= &textIds,
				p_msg	= msg );
    __CheckRC( status, *msg, "vd$placeBOMelem", wrapup );

    __DBGpr_int( "No of lines", nbLines );
    __DBGpr_int( "No of texts", nbTexts );

    /*
    __DBGpr_objlist( "List of line ids", nbLines, lineIds );
    __DBGpr_objlist( "List of text ids", nbTexts, textIds );
    */

    status = VD_drwtb_addComponents( msg, md_env, nbTexts, textIds, 
								feet_list[0] );
    __CheckRC( status, *msg, "VD_drwtb_addComponents", wrapup );

    status = VD_drwtb_addComponents( msg, md_env, nbLines, lineIds, 
								feet_list[0] );
    __CheckRC( status, *msg, "VD_drwtb_addComponents", wrapup );

    _FREE( lineIds );
    _FREE( textIds );

ADS :

    /* generate attribute driven symbols if any */

    __DBGpr_str( "adsTblName", adsTblName );

    if( !strlen( adsTblName ) )
	goto LAST_TASK;

    /* get the list of criteria */

    status = VDdrw_getAdsCrit( msg, adsTblName, &nbCrit, &lCrit );
    CheckRC( status, *msg );

    if( status == OM_E_NODYNMEM )
	goto wrapup;
    else if( !(status & *msg & 1) )
    {
	/* probably ADS table has not been defined : it is OK to continue  */

	status = OM_S_SUCCESS;
	*msg = MSSUCC;
	goto LAST_TASK;
    }

    __DBGpr_int( "Number of ADS criteria", nbCrit );

    /* set up buffers */

    if( nbCrit <= SMALL_BUF_LEN )
    {
	results = resBuf;
	adsDatRecs = adsDatBuf;
    }
    else
    {
	/* must allocate memory */

	results = _MALLOC( nbCrit, IGRshort );
	if( !results )
	    vd_$mem_fail( sts = status );

	adsDatRecs = _MALLOC( nbCrit, struct VDdrwlo_apifix );
	if( !adsDatRecs )
	    vd_$mem_fail( sts = status );
    }

    /* check the criteria on objects */

    VDdrw_checkAdsCritOnObjs( msg, nbCrit, lCrit, nbObjs, lObjs, results );

    /* set up the data records for construction */

    nbSym = 0;
    for( i = 0 ; i < nbCrit ; i++ )
    {
	if( results[i] )
	{
	    adsDatRecs[nbSym].rectyp = VD_DRWLO_EN_TEXT;

	    adsDatRecs[nbSym].VD.tx.ycor = cornerPnt[1] + ( yHi - yLo ) / 2;

	    if( lCrit[i].nnSide == VD_DRWLO_EN_LEFT )
	    {
	    	adsDatRecs[nbSym].VD.tx.xcor = cornerPnt[0] - lCrit[i].dOffset;
    		adsDatRecs[nbSym].VD.tx.justif = RIGHT_CENTER;
	    }
	    else
	    {
	    	adsDatRecs[nbSym].VD.tx.xcor = cornerPnt[0] + (xHi - xLo) + 
							lCrit[i].dOffset;
    		adsDatRecs[nbSym].VD.tx.justif = LEFT_CENTER;
	    }

	if ( lCrit[i].nDattyp == VD_DRWLO_EN_CELL  ){ adsDatRecs[nbSym].rectyp = VD_DRWLO_EN_CELL; }
	else 
	  if ( lCrit[i].nDattyp == VD_DRWLO_EN_SYMBOL ) { adsDatRecs[nbSym].rectyp = VD_DRWLO_EN_SYMBOL; }

/*
	    adsDatRecs[nbSym].VD.tx.ch_wdt = lCrit[i].dCharhgt;
	    adsDatRecs[nbSym].VD.tx.ch_hgt = lCrit[i].dCharwdt;
*/

            adsDatRecs[nbSym].VD.tx.ch_wdt = lCrit[i].dCharwdt;
            adsDatRecs[nbSym].VD.tx.ch_hgt = lCrit[i].dCharhgt;

	    adsDatRecs[nbSym].VD.tx.ch_spc = lCrit[i].dCharspc;
	    strcpy( adsDatRecs[nbSym].VD.tx.font, lCrit[i].font );
	    adsDatRecs[nbSym].VD.tx.numchr = strlen( lCrit[i].Symbol ) + 1;
	    strcpy( adsDatRecs[nbSym].VD.tx.Text, lCrit[i].Symbol );
	    adsDatRecs[nbSym].symb.level = tblLevel;

//	    adsDatRecs[nbSym].symb.display_attr.weight = 0;
	    adsDatRecs[nbSym].symb.display_attr.weight = lCrit[i].nCharwgt;

	    adsDatRecs[nbSym].symb.display_attr.style = 0;
	    adsDatRecs[nbSym].symb.display_attr.color = defColor;

	    nbSym++;
	}
    }

    __DBGpr_int( "No of ADS symbols to place", nbSym );

    if( !nbSym )
	goto LAST_TASK;

    /* construct the texts */

    status = vd$placeBOMtext(	count	= nbSym,
				array	= adsDatRecs,
				p_env	= md_env,
				p_rcs	= &csId,
				p_ntx	= &nbTexts,
				p_txt	= &textIds,
				p_msg	= msg );


    __CheckRC( status, *msg, "vd$placeBOMtext", wrapup );

    __DBGpr_int( "NUmber of ADS texts placed", nbTexts );

    status = VD_drwtb_addComponents( msg, md_env, nbTexts, textIds, 
								feet_list[0] );
    __CheckRC( status, *msg, "VD_drwtb_addComponents", wrapup );

    _FREE( textIds );

LAST_TASK :

    /*
     *	This conditional block is added for CR6391 
     */
    if( lineoutFlag )
    {
	rowWidth = xHi - xLo;
	extraLen = rowWidth * LINEOUT_LEN_INCREASE;
	__DBGpr_dbl( "Extra length for line-out line", extraLen );

	lineOutRec.rectyp = VD_DRWLO_EN_LINE;
	lineOutRec.symb.level = tblLevel;
	lineOutRec.symb.display_attr.weight = 0;
	lineOutRec.symb.display_attr.style = 0;
	lineOutRec.symb.display_attr.color = defColor;

	/* line-out line */

	lineOutRec.VD.ln.x1 = cornerPnt[0] - extraLen;
	lineOutRec.VD.ln.y1 = cornerPnt[1] + (height/2.0);
	lineOutRec.VD.ln.x2 = cornerPnt[0] + rowWidth + extraLen;
	lineOutRec.VD.ln.y2 = cornerPnt[1] + (height/2.0);

	/* construct the line out line */

	status = vd$placeBOMline(	count	= 1,
					array	= &lineOutRec,
					p_env	= md_env,
					p_rcs	= &csId,
					l_opt	= TRUE,
					p_nln	= &nbLines,
					p_lin	= &lineIds,
					p_msg	= msg );
	__CheckRC( status, *msg, "vd$placeBOMline", wrapup );

	/*
	__DBGpr_int( "No of lineout lines", nbLines );
	__DBGpr_objlist( "List of lines", nbLines, lineIds );
	*/

	status = VD_drwtb_addComponents( msg, md_env, nbLines, lineIds, 
							feet_list[1] );
	_FREE( lineIds );
    }

/* notify header of new row height */

    status = _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDnewRowHeight( 	msg,
								me->rowNumber,
								height ) );
    CheckRC( status, *msg );

wrapup :

    _FREE( extRecs );
    _FREE( datValue );
    _FREE( fixDatRecs );

    /* ????? if some error occurred, must delete all the objects created */

    _FREE( fixRecs );
    _FREE( datRecs );
    _FREE( lObjs );
    _FREE( procStr );
    _FREE( lCrit );

    if( results != resBuf )
	_FREE( results );
    if( adsDatRecs != adsDatBuf )
	_FREE( adsDatRecs );
    if( cpyCollId.objid != NULL_OBJID )
    {
	gr$delete_object( msg = msg, object_id = &cpyCollId );
    }

    End
    return status;
}


/*+me
-------------------------------------------------------------------------

  Public Message VDcreate

  Abstract
        This message fills all the parameters of the macro and
        place it.
	Overridden to avoid setting state to ND_DONT_MVRT.  Object should not
	be deleted if any parent is deleted.

  Arguments
        IGRlong         *msg            O : Completion code.
        IGRint          nbAttr          I : nb attributes in the ACrg_coll
        struct ACrg_coll *Attr          I : the attributes
        IGRchar         *macroName      I : Name of macro.
        IGRint          prop            I : Compute properties.
        IGRint          nbParents       I : number of graphical parent objects
        struct GRid     *parents        I : the surface

  Status/Return Code
        OM_S_SUCCESS    if success;
        OM_E_ABORT      if fails


 -------------------------------------------------------------------------
-me*/

method VDcreate(IGRlong                 *msg;
                IGRint                  nbAttr;
                struct ACrg_coll        *Attr;
                IGRchar                 *macroName;
                IGRint                  prop;
                IGRint                  nbParents;
                struct GRid             *parents )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDcreate ); Begin

    *msg = MSSUCC;

/*
????? Must check the ifdef vds_30 in the parent class method
*/

    status =
    _VD_SEND_WRT_M( my_id, VDSroot.VDcreate(    msg,
                                                nbAttr,
                                                Attr,
                                                macroName,
                                                prop,
                                                nbParents,
                                                parents ) );
    __CheckRC( status, *msg, "VDSroot.VDcreate", wrapup );

    status =
    _VD_SEND_MY( NDnode.NDchg_state( ND_DEFAULT, ND_DEFAULT ) );
    __CheckRC( status, 1, "NDnode.NDchg_state", wrapup );

wrapup :
    End
    return status;
}

end implementation VDdrwTblRow;

