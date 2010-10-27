/* $Id: VDhdrOver2.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDhdrOver2.I
 *
 * Description:
 *	Implementation of the following overridden methods  for VDdrwTblHdr :
 *		ACmplace_from_def
 *		ACconstruct_feet
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	04/25/95	R. Manem	Handled color symbology
 *	06/16/95	R. Manem	Turned off line optimization
 *	09/28/95	R. Manem	Truncate extra long fixed-text strings
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblHdr;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "vds.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwtbl.h"
#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "gotextdef.h"

#include "VDdrwgrProto.h"
#include "VDdrwgrMacro.h"

#include "vddlodef.h"
#include "vddlomacros.h"

#include "grdpb.h"
#include "grdpbmacros.h"

extern GRclassid	OPP_GRowner_class_id;

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

    SetProc( VDdrwTblHdr.ACmplace_from_def ); Begin

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

method ACconstruct_feet(	IGRlong		*msg;
				IGRint		cn_type;
				IGRint		count;
				struct GRid	list[];
				struct GRmd_env	*md_env;
				IGRint		*fcount;
				struct GRid	*feet_list )
{
    IGRint			i, j,
				vlaSize,
				len,
				rowNo,
				nbLines,
				nbTexts;
    IGRshort			recCount,
				tblLevel, defColor,
				hdrTrlType = 0;
    IGRchar			footName[10];
    IGRdouble			height,	
				cornerPnt[3];
    IGRlong			status = OM_S_SUCCESS;
    OM_S_CHANSELECT		compChan;
    struct GRid			ownerId,
				csId,
				myGrid,
				*lineIds = NULL,
				*textIds = NULL;
    struct VDdrwlo_apifix	*fldRecs = NULL;
    VD_drwLoInfo		info;
    
    SetProc( VDdrwTblHdr.ACconstruct_feet ); Begin
 
    *msg = MSSUCC;
    
    myGrid.objid = my_id;
    myGrid.osnum = OM_Gw_current_OS;

    /* 
     * get table level and default color 
     */

    status = vd$drw_layout_info(        msg     = msg,
                                        type    = VD_K_drwLO_tblLevel,
                                        info    = &info );
    CheckRC( status, *msg );
    tblLevel = info.val.sValue;
    __DBGpr_int( "Table level", tblLevel );

    status = vd$drw_layout_info(        msg     = msg,
                                        type    = VD_K_drwLO_tblColor,
                                        info    = &info );
    CheckRC( status, *msg );
    defColor = info.val.sValue;
    __DBGpr_int( "Default table color", defColor );

    /* initialize output feet */

    *fcount = 3;
    for( i = 0 ; i < 3 ; i++ )
    {
	feet_list[i].osnum = OM_Gw_current_OS;
	feet_list[i].objid = NULL_OBJID;
    }

    __DBGpr_objlist( "List of roots", count, list );

    /* get the coordinate system id */

    status =
    _VD_SEND_OBJ( list[1], NDmacro.ACreturn_foot(	msg,
							"",
							&csId,
							NULL, NULL ) );
    __CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );

    __DBGpr_obj( "Coordinate system id", csId );

    /* select the components channel */

    status =
    ems$make_chanselect( chan_label      = GRcmpowner_to_components,
                         chan_selector   = &compChan );
    __CheckRC( status, 1, "make_chanselect", wrapup );

    for( i = 0 ; i < 3 ; i++ )
    {
        if( i == 0  )
	{
	    strcpy( footName, "header" );
	    hdrTrlType = me->headerType;
	}
	else if( i == 1 )
	{
	    strcpy( footName, "trailer" );
	    hdrTrlType = me->trailerType;
	}
	else
	{
	    strcpy( footName, "misc" );
	}

	if( i == 2 )
	    break;

	__DBGpr_int( "Index i", i );
	__DBGpr_int( "me->toConstructType ", me->toConstructType );

        /* get the owner feet */

        ownerId.objid = NULL_OBJID;

        status =
        _VD_SEND_MY( NDmacro.ACreturn_foot(	msg,
						footName,
						&ownerId,
						NULL,
						NULL ) );

	__DBGpr_obj( "Owner id", ownerId );

        if( !(status & *msg & 1) || ownerId.objid == NULL_OBJID )
	{
	    if( (i == 0 && ( me->toConstructType == VD_DRW_CNST_HDR || 
			me->toConstructType == VD_DRW_CNST_BOTH ) )
		|| (i == 1 && ( me->toConstructType == VD_DRW_CNST_TRLR || 
			me->toConstructType == VD_DRW_CNST_BOTH )  ) 
		|| (i == 2) )
	    {
                ownerId.osnum = OM_Gw_current_OS;

                status =
	        om$construct( 	classid	= OPP_GRowner_class_id,
				osnum	= ownerId.osnum,
				p_objid	= &ownerId.objid );
                __CheckRC( status, 1, "GRowner construction", wrapup );
				
	        __DBGpr_obj( "New GRowner", ownerId );
	    }
	    status = OM_S_SUCCESS;
	    *msg = MSSUCC;
	}
	else
        {
            /* owner already exists : delete its components if required */

	    if( (i == 0 && ( me->toConstructType == VD_DRW_CNST_HDR || 
			me->toConstructType == VD_DRW_CNST_BOTH ) )
		|| (i == 1 && ( me->toConstructType == VD_DRW_CNST_TRLR || 
			me->toConstructType == VD_DRW_CNST_BOTH )  ) 
		|| (i == 2) )

	    {
	    	status =
            	om$send(	msg		= message GRgraphics.GRdelete( 
								msg, 
								md_env ),
				senderid	= ownerId.objid,
				p_chanselect	= &compChan );
            	CheckRC( status, *msg );
            }

	    /* disconnect the foot */

	    status =
	    _VD_SEND_OBJ( ownerId, GRconnector.GRdisconn(	msg,
								&myGrid ) );
	    __CheckRC( status, *msg, "GRconnector.GRdisconn", wrapup );

	    feet_list[i] = ownerId;
	}

	if( i == 0 && !( me->toConstructType == VD_DRW_CNST_HDR) && 
			!(me->toConstructType == VD_DRW_CNST_BOTH ) )
	    continue;

	if( i == 1 && !( me->toConstructType == VD_DRW_CNST_TRLR) && 
			!(me->toConstructType == VD_DRW_CNST_BOTH ) )
	    continue;

        /* 
         * now construct the components 
         */
    
        /* get the number of fixed components */

	__DBGpr_int( "Header trailer type", hdrTrlType );

        status =
	VD_drwlo_gfix(	msg,
			me->tblLayoutName,
			hdrTrlType,
			0, 0,
			0, NULL,
			&height,	
			&recCount,
			NULL );
        CheckRC( status, *msg );

	if( !(status & *msg & 1) )
	{
	    status = OM_S_SUCCESS;
	    *msg = MSSUCC;
	    continue;
	}

	__DBGpr_int( "No of fixed components", recCount );

	if( !recCount )
	    continue;

	__DBGpr_dbl( "row height", height );

	/* compute the corner point and update height */

	if( i == 0 )
	{
	    for( j = 0 ; j < 3 ; j++ )
	    	cornerPnt[j] = me->headerCornerPoint[j];
	    me->rowHeights[0] = height;
	}

	if( i == 1 )
	{
	    vlaSize = om$dimension_of( varray = me->rowHeights );
	    me->rowHeights[vlaSize-1] = height;
	  
	    rowNo = vlaSize - 2 + me->startRowNo;
	    __DBGpr_int( "row number for trailer", rowNo );

	    status =
	    _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow(	msg,
								rowNo,
								cornerPnt ) );
	    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetCornerPntForRow", 
								wrapup );

	    if( me->tblOrient == VD_DRWLO_EN_DESCEND )
		cornerPnt[1] = cornerPnt[1] - height;
	}

	__DBGpr_vec( "Corner point", cornerPnt );

        /* allocate space for the records */

	_FREE( fldRecs );
        fldRecs = _MALLOC( recCount, struct VDdrwlo_apifix );

        if( !fldRecs )
            vd_$mem_fail( sts = status );
			
        /* get the list of fixed components */

        status =
	VD_drwlo_gfix(	msg,
			me->tblLayoutName,
			hdrTrlType,
			cornerPnt[0], cornerPnt[1],
			0, NULL,
			&height,	
			&recCount,
			fldRecs );
        __CheckRC( status, *msg, "VD_drwlo_gfix : list", wrapup );

	__DBGpr_int( "No of fixed components", recCount );

#ifdef vdsDEBUG
    printf("\tTable layout name = <%s>\n", me->tblLayoutName );
    printf("\tGroup type = %d\n\n", hdrTrlType );
    for( j = 0 ; j < recCount ; j++ )
    {
        printf("\n\tRecord # %d : Type = %s\n", j,
		(fldRecs[j].rectyp == VD_DRWLO_EN_LINE ? "line" : "text") );
	if( fldRecs[j].rectyp == VD_DRWLO_EN_LINE )
	    printf("\t\tPt1 = (%g, %g), Pt2 = (%g, %g)\n", 
			fldRecs[j].VD.ln.x1, fldRecs[j].VD.ln.y1,
			fldRecs[j].VD.ln.x2, fldRecs[j].VD.ln.y2 );
	else
	    printf("\t\ttext <%s>, numchr %d, Pnt (%g,%g), wdth %g, hgt %g, spc %g, just %d, font %s\n", 
			fldRecs[j].VD.tx.Text, fldRecs[j].VD.tx.numchr,
			fldRecs[j].VD.tx.xcor, fldRecs[j].VD.tx.ycor,
			fldRecs[j].VD.tx.ch_wdt, fldRecs[j].VD.tx.ch_hgt,
			fldRecs[j].VD.tx.ch_spc, fldRecs[j].VD.tx.justif,
			fldRecs[j].VD.tx.font );
    }
#endif

	/* set up color */

	for( j = 0 ; j < recCount ; j++ )
	{
	    fldRecs[j].symb.level = tblLevel;
	    fldRecs[j].symb.display_attr.color = defColor;

	    if( fldRecs[j].rectyp == VD_DRWLO_EN_TEXT )
	    {

		/* truncate extra long strings */

		/* 
		 * not necessary to check if len exceeds VD_DRWLO_CHR_TEXT,
		 * because, form input restricts user input to this many
		 * number of characters.
		 * And input in form cannot be overridden later in "Place
		 * Table Header" command
		 */

		len = strlen( fldRecs[j].VD.tx.Text) + 1;
		__DBGpr_int( "Original Length+1 of text", len );

		if( len < fldRecs[j].VD.tx.numchr )
		    fldRecs[j].VD.tx.numchr = len;
		else if( len > fldRecs[j].VD.tx.numchr )
		{
		    fldRecs[j].VD.tx.Text[ fldRecs[j].VD.tx.numchr ] = '\0';
		    fldRecs[j].VD.tx.numchr++;
		}

#ifdef vdsDEBUG
    printf( "\tNew length === %d, text = %s\n", fldRecs[j].VD.tx.numchr,
						fldRecs[j].VD.tx.Text );
#endif
	    }
	}

        /* construct the graphics and connect the components */

	status =
	vd$placeBOMelem(	count	= recCount,
				array	= fldRecs,
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

	__DBGpr_objlist( "List of line ids", nbLines, lineIds );
	__DBGpr_objlist( "List of text ids", nbTexts, textIds );

	status = 
	VD_drwtb_addComponents(msg, md_env, nbLines, lineIds, ownerId );
	__CheckRC( status, *msg, "VD_drwtb_addComponents", wrapup );

	status =
	VD_drwtb_addComponents(	msg, md_env, nbTexts, textIds, ownerId );
	__CheckRC( status, *msg, "VD_drwtb_addComponents", wrapup );

	_FREE( lineIds );
	_FREE( textIds );
	lineIds = NULL;
	textIds = NULL;

        /* 
         *	?????
	 * get the replaceable components 
	 */

	if( i == 0 )
	{
	    /* new height for header */

            status =
            _VD_SEND_MY( VDdrwTblHdr.VDnewRowHeight(	msg,
							0,
							height ) );
            CheckRC( status, *msg );
	}
	feet_list[i] = ownerId;
    }

wrapup :
    _FREE( fldRecs );
    _FREE( lineIds );
    _FREE( textIds );
   
    End
    return status;
}

end implementation VDdrwTblHdr;

