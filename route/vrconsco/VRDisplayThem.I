/* $Id: VRDisplayThem.I,v 1.2 2002/04/19 21:44:21 anand Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrconsco/VRDisplayThem.I
 *
 * Description:
 *			      Ad's Magic! ;-)
 *
 *      This file has routines to display ALL the Locked Planes and
 *      Fitting-to-Fitting constraints in a file. These are called from the
 *      wakeup states of 6 commands (related to locked-planes/Fitting
 *      constraints)
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRDisplayThem.I,v $
 *	Revision 1.2  2002/04/19 21:44:21  anand
 *	TR 6286. Clicking any of the 3 lock plane related
 *	command crashed.
 *	
 *	Revision 1.1  2001/05/23 00:34:49  anand
 *	*** empty log message ***
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	05/16/01	Anand		creation
 *	04/19/02	Anand		TR 6286
 *
 ***************************************************************************/

class implementation Root;

#include "VDobj.h"
#include "igrdef.h"	// contains definition for IGRPS
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"

#include "VRdimdef.h"	// contains definition for VR_MAX_CPTS
#include "VRcordef.h"	// contains definition for VR_FIT_TO_FIT

#include "VDmem.h"
#include "vrdbgmacros.h"

extern GRclassid  OPP_VRplane_class_id;

from    VRplane         import  VRget_plane_state;
from    GRgraphics      import  GRdisplay;
from	VRGeneric	import	VRGetCorrections, VRGetCptGeom;
from	VRCorrection	import	VRget_state, VRGetCptIndex;

/******************************************************************************/

IGRint VRinfo_DisplayPlanes(struct GRmd_env *ModuleInfo)
{
    IGRint	i, status, plnCount = 0, PlaneState;
    IGRlong	msg;
    IGRint	PlaneFound = 0;
    IGRchar	buffer[100];

    enum  GRdpmode	mode;
    GRclassid		classid;
    OM_S_OBJID		*list=NULL;
    OMuword		curOS;

    SetProc( VRinfo_DisplayPlanes ); Begin

	/* msg argument of dp$erase_hilite requires a pointer to a long.
	 * Otherwise, it ... <you guessed it> ... CRASHES!!!
	 * 					- Anand for TR 6286 */
    dp$erase_hilite ( msg = &msg );

    ex$get_cur_mod( osnum = &curOS );
    __DBGpr_int( " curOS ", curOS );

    /*
     * Get all the planes in the design file.
     */
    classid = OPP_VRplane_class_id;
    VDpms_findall_ancestryobjects ( curOS, 1, &classid, &plnCount, NULL );

    /*
     * Allocate memory for planes.
     */ 
    __DBGpr_int(" plnCount0 ", plnCount );
    if(plnCount == 0)
	goto wrapup;

    list =  _CALLOC( plnCount , OM_S_OBJID ) ;
    VDpms_findall_ancestryobjects( curOS, 1, &classid, &plnCount, list );

    __DBGpr_int(" plnCount1 ", plnCount );
    if(plnCount == 0)
	goto wrapup;

    /*
     * Check all planes.
     */
    for( i=0; i<plnCount; i++ )
    {
	status = om$send( msg = message VRplane.VRget_plane_state(&PlaneState),
		     senderid = NULL_OBJID,
		     targetid = list[i],
		     targetos = curOS );
	CheckRC( status, 1 );

	if( PlaneState )
	{
	    PlaneFound++ ;
	    __DBGpr_int( " PlaneId [osnum:2]", list[i] );

	    /*
	     * GRdisplay as the Module Info seems to have some
	     * matrix problem when selecting elements in view
	     */ 

	    mode = GRhhd;
	    status = om$send( msg      = message GRgraphics.GRdisplay
				    ( &msg, &(ModuleInfo->md_env.matrix_type),
				      ModuleInfo->md_env.matrix, &mode, 
				      &(ModuleInfo->md_id) ),
			      senderid = NULL_OBJID,
			      targetid = list[i],
			      targetos = curOS );
	    CheckRC( status, msg );
	}
    }

    if( ! PlaneFound ) 
    {
	sprintf(buffer,"No Fixed Planes found" );
    }
    else
    {
	sprintf(buffer, "Number of Fixed Planes : %d ", PlaneFound );
	__DBGpr_int(" PlaneFound ", PlaneFound );
    }

    UI_status(buffer);

wrapup:

    _FREE( list );
    End;
    return OM_S_SUCCESS;
}
 


/******************************************************************************/

/*----------------------------------------------------------------------------*/
int VRDisplay_FitToFitting(struct GRmd_env *ModuleInfo)
{
    IGRint		i, j, l, status, state, NbCor, NumOfDisplayPoint=0;
    IGRlong		ret_code;
    IGRboolean		Continue;
    struct GRid		CorIds[VR_MAX_CPTS] ;
    IGRshort		Index ;
    IGRdouble		DispPt[3] ;
    struct IGRpointset	pointset ;
    struct DPele_header	DispBuffer ;
    OMuword		curOS;
    OM_S_OBJID		*list = NULL;
    IGRchar		buffer[100];
    IGRint		vrCount, objCount = 0 ;
    struct GRid		curObj, *objList = NULL ;
    GRclassid		classids;
    struct IGRdisplay	DisplaySymb;

    SetProc( VRDisplay_FitToFitting ); Begin

    dp$erase_hilite ( msg = &status );

    ex$get_cur_mod( osnum = &curOS );
    __DBGpr_int( " curOS ", curOS );

    /*
     * Get all components (VRGeneric and derived classes) in the design file.
     */
    classids = OPP_VRGeneric_class_id ;
    VDpms_findall_ancestryobjects ( curOS, 1, &classids, &vrCount, NULL );

    /*
     * Allocate memory for planes.
     */
    __DBGpr_int(" vrCount0 ", vrCount );
    if(vrCount == 0)
	goto wrapup;

    list =  _CALLOC( vrCount , OM_S_OBJID );
    __CheckPtr( list, "Calloc of list failed!", wrapup);

    objList =  _CALLOC( vrCount , struct GRid ); // Conservative or Excessive?
    __CheckPtr( list, "CALLOC OF objList FAILED!", wrapup);

    VDpms_findall_ancestryobjects( curOS, 1, &classids, &vrCount, list );

    curObj.osnum = curOS ;

    for( i=0; i<vrCount; i++ )
    {
	curObj.objid = list[i];
	__DBGpr_obj(" Getting num corrections in",curObj);

	status = om$send( msg	   = message VRGeneric.VRGetCorrections(
								   &ret_code,
								   VR_MAX_CPTS,
								   CorIds,
								   &NbCor ),
			  senderid = NULL_OBJID,
			  targetid = curObj.objid,
			  targetos = curObj.osnum ) ;
	CheckRC( status, ret_code);

	if( !( 1&status&ret_code))
	    continue ;

	__DBGpr_int("Number of correction:", NbCor );

	for( j=0; j<NbCor; j++ )
	{
	    /*
	     * Eliminate Duplicates corrections (ones already examined)
	     */
	    Continue = FALSE ;
	    for( l=0; l<objCount; l++ ) 
		if( CorIds[j].objid == objList[l].objid )
		{
		    Continue = TRUE ;
		    break ;
		}

	    if( Continue )
		continue ;

	    objList[objCount] = CorIds[j] ;
	    objCount++;

	    __DBGpr_obj("New Correction to investigate for FTF: ", CorIds[j] );
	    __DBGpr_int("Correction index", j );

	    status =
	    om$send( msg      = message VRCorrection.VRget_state( &state ),
		     senderid = NULL_OBJID,
		     targetid = CorIds[j].objid,
		     targetos = CorIds[j].osnum ) ;
	    CheckRC( status,1 );

	    if( !(1&status) || !(state&VR_FIT_TO_FIT) )
		continue ;

	    ++NumOfDisplayPoint;

	    status =
	    om$send( msg      = message VRCorrection.VRGetCptIndex( &ret_code,
								    &curObj,
								    &Index ),
		     senderid = NULL_OBJID,
		     targetid = CorIds[j].objid,
		     targetos = CorIds[j].osnum ) ;
	    CheckRC( status, ret_code );
	    if( ! (1&status&ret_code) )
		continue ;

	    __DBGpr_int("Correction point", Index );

	    status =
	    om$send(msg	     = message VRGeneric.VRGetCptGeom( &ret_code,
							       Index,
							       DispPt,
							       NULL,
							       NULL,
							       ModuleInfo ),
		    senderid = NULL_OBJID,
		    targetid = curObj.objid,
		    targetos = curObj.osnum ) ;
	    CheckRC( status, ret_code );
	    if( ! (1&status&ret_code) )
		continue ;

	    __DBGpr_vec("Disp Pt ", DispPt );

	    pointset.num_points = 1 ;
	    pointset.points     = DispPt ;

	    // Preferred to hard code these. It's all cosmetic anyway.
	    DisplaySymb.weight = 3;
	    DisplaySymb.color  = 149;
	    DisplaySymb.style  = 0;

	    dp$build_dis_buffer( buffer	 = &DispBuffer,
				 type	 = IGRPS,
				 display_att = &DisplaySymb,
				 geometry    = &pointset );

	    dp$display( msg    = &ret_code,
			buffer = &DispBuffer,
			mode   = GRhhd );

	} /* for( j=0; j<NbCor; j++ ) */
    } /* for vrCount */ 


    __DBGpr_int(" # display points", NumOfDisplayPoint );

    if( ! NumOfDisplayPoint )
    {
	sprintf(buffer,"No Fitting-To-Fitting found" );
    }
    else
    {
	sprintf( buffer, "Number of Fitting-To-Fitting constraints: %d",
							   NumOfDisplayPoint );
	__DBGpr_int(" NumOfDisplayPoint ", NumOfDisplayPoint );
    }

    UI_status(buffer);

wrapup:
    _FREE( list );
    _FREE( objList );
    End
    return OM_S_SUCCESS;
}

end implementation Root;
