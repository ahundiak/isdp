/* $Id: FrameSystem.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	smframe/api/FrameSystem.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: FrameSystem.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/08/04  15:07:20  pinnacle
# TR_179801413: Memory fault on Solaris
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/08  16:17:02  pinnacle
# Made changes to SMcreate_frame_system
#
# Revision 1.3  1998/03/27  21:46:42  pinnacle
# CR179800868
#
# Revision 1.2  1998/03/27  19:14:56  pinnacle
# CR_179800868: Replaced smframeapi.h with smAPImacros.h
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/05/29  13:33:20  pinnacle
# Replaced: smframe/api/FrameSystem.I for:  by v240_int for vds.240
#
# Revision 1.6  1996/04/21  14:52:42  pinnacle
# Replaced: smframe/api/FrameSystem.I for:  by v240_int for vds.240
#
# Revision 1.5  1996/04/17  14:51:42  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1996/02/20  20:33:40  pinnacle
# Created: ./smframe/api/FrameSystem.I by azuurhou for vds.240
#
 *
 * History:
 * MM/DD/YY  AUTHOR   DESCRIPTION
 *	     i-paris  creation date
 * 03/27/98  ejm      CR179800868: Replaced smframeapi.h with smAPImacros.h 
 *                    Pointer mismatch errors in modify frame system
 * 03/31/98  ejm      TR179800947: SMcreate_frame_system memory faults.
 *		      Added check for null lyO in 
 *		      CFSsectionInfo; changed Fstr to point to struct frame 
 *		      instead of frame_def in SMcreate_frame_system; allocated
 *		      memory for Frame.sect_info in SMcreate_frame_system;
 *		      inactivated _FREE ( Frame->sect_info) in CFSsectionInfo.
 * 08/04/98  ejm      TR179801413: SMcreate_frame_system memory faults on
 *		      Solaris.
 *		      Set nb_nm_sect to zero, nm_sect_info to NULL.
 ***************************************************************************/

class implementation Root;

#include        <stdio.h>
#include        <math.h>
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "igrdef.h"
#include        "igr.h"
#include        "exdef.h"
#include        "ex.h"
#include        "igrdp.h"
#include        "gr.h"
#include        "growner.h"
#include        "go.h"
#include        "griodef.h"
#include        "grio.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "msdef.h"
#include        "msmacros.h"
#include        "exmacros.h"
#include        "AS_status.h"
#include        "ACrg_collect.h"
#include        "nddef.h"
#include        "asbox.h"
#include        "asmacros.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include        "SMframe.h"
#include        "SMmsg.h"
#include        "smframedef.h"
#include	"smAPImacros.h"
#include        "VDmem.h"

/* External SMAN functions used by SMcreate_frame_system() */
extern	IGRint	SMSetFrame();
extern	IGRint	SMCreateFrame();
extern	IGRint	SMfr_convert_unit_int();

/* External SMAN functions used by SMmodify_frame_system() */
extern	IGRint	SMFillFrmDefInfo();
extern	IGRint	SMModFrame();

/* Imported messages used by SMmodify_frame_system() */
from	GRgraphics	import	GRgetname;
from	NDnode		import	NDget_objects;
from	SMfrm_syst	import	SMfind_frame_objid;

/*	#define	DEBUG	*/
#define EPSILON 0.0001

/* ***** */

IGRboolean CFSaxis	(	struct	frame_def	*Frame,
				IGRint			axis	)
{
	switch (axis) {
		case SM_FA_Xaxis:
			Frame->main_info.axis = 'x';
			return TRUE;
		case SM_FA_Yaxis:
			Frame->main_info.axis = 'y';
			return TRUE;
		case SM_FA_Zaxis:
			Frame->main_info.axis = 'z';
			return TRUE;
		default :
			printf( "CFSaxis : unknown axis <%d>\n",
				axis );
			return FALSE;
	}
}
/* ***** */

IGRboolean CFSorient	(	struct	frame_def	*Frame,
				IGRint			orient	)
{
	if (  (orient != SM_FO_Parallel)
	   && (orient != SM_FO_Reversed) ) {
		printf( "CFSorient : unknown orientation <%d>\n",
			orient );
		return FALSE;
	}
	else {	Frame->main_info.orient = orient;
		return TRUE;
	}
}

/* ***** */

IGRboolean CFSrevDist	(	struct	frame_def	*Frame,
				IGRchar			*unit,
				IGRdouble		*revDist	)
{
	if (!revDist) {
		Frame->main_info.rev_dist  = NO_REV_DIST;
	}
	else {	if (*revDist < 0.0) {
			ex$message (msgnumb = SM_I_FrNeedPos);
			return FALSE;
		}
		if (! SMfr_convert_unit_int
			( *revDist, unit, &(Frame->main_info.rev_dist) ) )
			Frame->main_info.rev_dist = *revDist;
	}
	return TRUE;
}

/* ***** */

IGRboolean CFSplnSize	(	IGRdouble	*Size,
				IGRint		size,
				IGRdouble	*value,
				IGRchar		*unit )
{
	switch (size) {
		case SM_FS_Small:
			*Size = -1.0;
			return TRUE;
		case SM_FS_Regular:
			*Size = 0.0;
			return TRUE;
		case SM_FS_Large:
			*Size = -2.0;
			return TRUE;
		case SM_FS_Ems:
			if (value) {
				if (*value < 0.0) {
					ex$message (msgnumb = SM_I_FrNeedPos);
					return FALSE;
				}
				if (  (unit[0] == '\0')
				   || (! SMfr_convert_unit_int
						( *value, unit, Size ) ) )
					*Size = *value;
				return TRUE;
			}
			else	return FALSE;
		default :
printf( "CFSplnSize : unknown regular plane type <%d>\n", size );
			return FALSE;
	}
}

/* ***** */

IGRboolean CFSjustif	(	IGRchar		*Cjust,
				IGRint		Ijust )
{
	switch (Ijust) {
		case SM_FJ_Width_Left:
			*Cjust = 'N';
			return TRUE;
		case SM_FJ_Width_Center:
			*Cjust = 'C';
			return TRUE;
		case SM_FJ_Width_Right:
			*Cjust = 'P';
			return TRUE;
		default :
printf( "CFSjustif : unknown width justification <%d>\n", Ijust );
			return FALSE;
	}
}

/* ***** */

IGRboolean CFSdistToNumb (	struct  sect_dist       *Fdist,
				IGRint                  *lyO,
				struct  frame_def       *Frame )	{
	IGRint	i, index=-1;

	/* Find section containing frame 0 */
	for ( i=0; i<Frame->nb_sect; i++ ) {

		/* Verify that sections definitions is correct */
		if (  (Fdist[i].Xa == NO_DIST)
		   || (Fdist[i].Xb == NO_DIST)
		   || (Fdist[i].Xa >= Fdist[i].Xb)
		   || (Fdist[i].nb <= 0) ) {
			ex$message ( msgnumb = SM_E_FrNotDef,
				     type    = "%d",
				     var     = `i` );
			return FALSE;
		}

		/* Search frame 0 */
		if ( (Fdist[i].Xa <= 0.0) && (Fdist[i].Xb >= 0.0) ) {
			index = i;
			i = Frame->nb_sect;
		}
	}

	/* Work on section including frame 0 */
	if (  (index == -1)
	   || (Fdist[index].nb <= 0)
	   || (Fdist[index].Xb <= Fdist[index].Xa) )
		return FALSE;
	else {  IGRdouble	fr, to, e1, e2, e3 , e4;

		Frame->sect_info[index].spacing
		= (Fdist[index].Xb - Fdist[index].Xa)
		/ (IGRdouble) Fdist[index].nb;
		if (Frame->sect_info[index].spacing <= 0.0)	return FALSE;

		to = Fdist[index].Xb / Frame->sect_info[index].spacing;
		e1 = to - floor(to);
		e2 = ceil(to) - to;

		fr = Fdist[index].Xa / Frame->sect_info[index].spacing;
		e3 = fr - floor(fr);
		e4 = ceil(fr) - fr;

		if (  (e1 > EPSILON && e2 > EPSILON)
		   || (e3 > EPSILON && e4 > EPSILON) ) {
			ex$message ( msgnumb = SM_E_FrZeroSect );
			return FALSE;
		}
		else {	Frame->sect_info[index].fr
			= e3 < e4 ? (IGRint) floor(fr) : (IGRint) ceil(fr);
			Frame->sect_info[index].to
                        = e1 < e2 ? (IGRint) floor(to) : (IGRint) ceil(to);
			Frame->sect_info[index].offset  = (IGRshort) lyO[index];
		}
	}

	/* Compute "positive" sections */
	for ( i=index+1; i<Frame->nb_sect; i++ ) {

		Frame->sect_info[i].spacing
		= (Fdist[i].Xb - Fdist[i].Xa) / (IGRdouble) Fdist[i].nb;
		if (Frame->sect_info[i].spacing <= 0.0)	return FALSE;

		if ( fabs ( Fdist[i].Xa - Fdist[i-1].Xb ) > EPSILON ) {
			ex$message ( msgnumb = SM_E_FrAdjSect,
				     type    = "%d %d",
				     var     = `i-1,i` );
			return FALSE;
		}
		else {	Frame->sect_info[i].fr = Frame->sect_info[i-1].to;
			Frame->sect_info[i].to = Frame->sect_info[i].fr
					       + Fdist[i].nb;
			Frame->sect_info[i].offset = (IGRshort) lyO[i];
		}
	}

	/* Compute "negative" sections */
	for ( i=index-1; i>=0; i-- ) {

		Frame->sect_info[i].spacing
		= (Fdist[i].Xb - Fdist[i].Xa) / (IGRdouble) Fdist[i].nb;
		if (Frame->sect_info[i].spacing <= 0.0)	return FALSE;

		if ( fabs ( Fdist[i].Xb - Fdist[i+1].Xa ) > EPSILON ) {
			ex$message ( msgnumb = SM_E_FrAdjSect,
				     type    = "%d %d",
				     var     = `i,i+1` );
			return FALSE;
		}
		else {	Frame->sect_info[i].to = Frame->sect_info[i+1].fr;
			Frame->sect_info[i].fr = Frame->sect_info[i].to
					       - Fdist[i].nb;
			Frame->sect_info[i].offset = (IGRshort) lyO[i];
		}
	}

	return TRUE;
}

/* ***** */

IGRboolean CFSsectionInfo (	IGRint			opt,
				IGRchar			*unit,
				IGRint			*frN,
				IGRint			*toN,
				IGRdouble		*spN,
				IGRdouble		*frD,
				IGRdouble		*toD,
				IGRint			*nmD,
				IGRint			*lyO,
				struct	frame_def	*Frame	) {

	IGRboolean	ret=FALSE;
	IGRint		i;
struct	sect_dist	*Fdist;

	/* Initialize */
	Fdist = NULL;

	/* Allocate memory for sections */
	Frame->sect_info = 
		_REALLOC ( Frame->sect_info, Frame->nb_sect,struct sect_info );
	 if (! Frame->sect_info)	goto wrapup;; 

	if (opt == SM_FD_Number) {

		/* Sections defined by NUMBER */
		for ( i=0; i<Frame->nb_sect; i++) {
			Frame->sect_info[i].fr		= frN[i];
			Frame->sect_info[i].to		= toN[i];
			if (! SMfr_convert_unit_int
				( spN[i], unit, &Frame->sect_info[i].spacing ) )
				Frame->sect_info[i].spacing = spN[i];
			if( lyO )
			  Frame->sect_info[i].offset	= (IGRshort) lyO[i];
		}

	}
	else if (opt == SM_FD_Distance) {

		/* Allocate memory for distance defined sections */
		Fdist = 
		_CALLOC ( Frame->nb_sect,struct sect_dist );

		/* Sections defined by DISTANCE */
		for ( i=0; i<Frame->nb_sect; i++) {
			if (! SMfr_convert_unit_int
				( frD[i], unit, &Fdist[i].Xa ) )
				Fdist[i].Xa = frD[i];
			if (! SMfr_convert_unit_int
				( toD[i], unit, &Fdist[i].Xb ) )
				Fdist[i].Xb = toD[i];
			Fdist[i].nb = nmD[i];

} /* Convert distance defined sections to number defined ones */
		if (! CFSdistToNumb ( Fdist, lyO, Frame ) ) {
			printf( "CFSdistToNumb : error\n" );
			goto wrapup;
		}
	}

	/* Verify results */
	for ( i=0; i<Frame->nb_sect; i++) {
		if (  (Frame->sect_info[i].fr      != NO_NUMBER)
		   && (Frame->sect_info[i].to      != NO_NUMBER)
		   && (Frame->sect_info[i].spacing != NO_SPACING)
		   && (Frame->sect_info[i].offset  != NO_OFFSET) )
		{
			ret = TRUE;
			goto wrapup;
		}
	}
wrapup:

#ifdef DEBUG
for ( i=0; i<Frame->nb_sect; i++)
printf( "Section %d : from %2d to %2d, spacing=%g, offset=%d\n",
	i, Frame->sect_info[i].fr, Frame->sect_info[i].to,
	Frame->sect_info[i].spacing, Frame->sect_info[i].offset );
#endif

	if (Fdist) _FREE ( Fdist);
/* WHY? needed by SMSetFrame!!! 
	if (Frame->sect_info) _FREE ( Frame->sect_info);
*/
	return (ret);
}

/* ***** */

IGRlong	SMcreate_frame_system (	IGRlong			*msg,
				IGRchar			*name,
				IGRint			frameDisplay,
				struct	GRid		*csId,
				IGRint			axis,
				IGRint			orientation,
				IGRdouble		*revDistance,
				IGRint			regulSize,
				IGRdouble		*regulValue,
				IGRint			reinfSize,
				IGRdouble		*reinfValue,
				IGRchar			*annotation,
				IGRdouble		originOffset,
				IGRint			wJustif,
				IGRint			hJustif,
				IGRint			sectionNumber,
				IGRchar			*distanceUnit,
				IGRint			sectionOption,
				IGRint			*frNumber,
				IGRint			*toNumber,
				IGRdouble		*spacing,
				IGRdouble		*frDistance,
				IGRdouble		*toDistance,
				IGRint			*frameNumber,
				IGRint			*layerOffset,
				IGRchar			*reinforce,
				IGRchar			*reverse,
				struct	GRid		*frameSystemId	) {

	IGRlong			sts=OM_S_SUCCESS;
struct	frame_def		Frame;
struct  frame			*Fstr=NULL;
	IGRint			Fnum, Flow, Fhig, Fbad=0;

	/* Initialize */
	*msg = MSFAIL;
	frameSystemId->objid = NULL_OBJID;
	Frame.sect_info = NULL;
        Frame.nb_nm_sect = 0;
        Frame.nm_sect_info = NULL;


        /* Without this, REALLOC fails in function CFSsectionInfo */
        Frame.sect_info = _CALLOC ( NB_MAX_SECTION, struct sect_info);
        *msg = MSFAIL;
        if (! Frame.sect_info)       goto wrapup;;

	/* Fill buffer with sections' number */
	Frame.nb_sect = sectionNumber;

	/* Verify consistency */
	if (Frame.nb_sect <= 0)	goto wrapup;

	if	(sectionOption == SM_FD_Number)
		if (  (! frNumber) || (! toNumber) || (! spacing) )
			goto wrapup;
	else if (sectionOption == SM_FD_Distance)
		if (  (! frDistance) || (! toDistance) || (! frameNumber) )
			goto wrapup;
	else {	printf( "SMcreate_frame_system : unknown Frame.nb_sect <%d>\n",
			Frame.nb_sect );
		goto wrapup;
	}

	/* Fill structure with axis */
	if (! CFSaxis ( &Frame, axis ) )
		goto wrapup;

	/* Fill structure with orientation */
	if (! CFSorient ( &Frame, orientation ) )
		goto wrapup;

	/* Fill structure with justification */
	if (! CFSjustif ( &(Frame.main_info.justif[0]), wJustif ) )
		goto wrapup;
	if (! CFSjustif ( &(Frame.main_info.justif[1]), hJustif ) )
		goto wrapup;
	Frame.main_info.justif[2] = '\0';

	/* Fill structure with annotation */
	strncpy ( Frame.main_info.annot, annotation, 10 );

	/* Fill structure with revDistance */
	if (! CFSrevDist ( &Frame, distanceUnit, revDistance ) )
		goto wrapup;

	/* Fill structure with regulSize */
	if (! CFSplnSize ( &Frame.main_info.plane_size,
			   regulSize, regulValue, distanceUnit ) )
		goto wrapup;

	/* Fill structure with reinfSize */
	if (! CFSplnSize ( &Frame.main_info.plane_size,
			   reinfSize, reinfValue, distanceUnit ) )
		goto wrapup;

	/* Fill structure with originOffset */
	if (! SMfr_convert_unit_int ( originOffset, distanceUnit,
                                      &Frame.main_info.offset_dist ) )
		Frame.main_info.offset_dist = originOffset;

	/* Fill structure with reinforced frame expression */
	strncpy ( Frame.main_info.reinfstr, reinforce, NB_CUT_STR * ATTR_TXT );

	/* Fill structure with reversed frame expression */
	strncpy ( Frame.main_info.revstr, reverse, NB_CUT_STR * ATTR_TXT );

	/* Fill structure with unit */
	strncpy ( Frame.main_info.unit, distanceUnit, ATTR_TXT );

	/* Fill structure with type name */
	if	(frameDisplay == SM_FD_Number)
		Frame.main_info.name_type = NAME_BY_NUMBER;
	else if	(frameDisplay == SM_FD_Distance)
		Frame.main_info.name_type = NAME_BY_DIST;
	else {	printf( "SMcreate_frame_system() : unknown frameDisplay = %d\n",
			frameDisplay );
		goto wrapup;	}

	/* Fill info structure for regular sections */
	if (! CFSsectionInfo ( sectionOption, distanceUnit,
			       frNumber, toNumber, spacing,
			       frDistance, toDistance, frameNumber,
			       layerOffset,
			       &Frame ) )	goto wrapup;

	/* Generate the frame structure */
	sts = SMSetFrame ( &Frame, &Fnum, &Fstr, &Flow, &Fhig, &Fbad );
	if (sts != 1) {
                printf( "Error %d in SMSetFrame()\n", sts );
                goto wrapup;
        }

	/* Generate the frame objects */
	sts = SMCreateFrame ( name, csId, &Frame, Fnum, Fstr, Flow, Fhig,
			      frameSystemId, &Fbad );	      
	if (sts != 1) {
		printf( "Error %d in SMCreateFrame()\n", sts );
		goto wrapup;
	}

	/* Successful completion */
	*msg = MSSUCC;

wrapup:
	if (Frame.sect_info) {
		_FREE ( Frame.sect_info);	
		/* Frame.sect_info = NULL; */
	}
	return sts;
}

/* ***** */

IGRboolean MFSsectionInfo (     IGRint                  *opt,
				IGRchar			*unit,
                                IGRint                  *frN,
                                IGRint                  *toN,
                                IGRdouble               *spN,
                                IGRdouble               *frD,
                                IGRdouble               *toD,
                                IGRint                  *nmD,
                                IGRint                  *lyO,
                                struct  frame_def       *old,
                                struct  frame_def       *new    )       {

	IGRboolean	ret=FALSE;
	IGRint		i, *fN, *tN, *lO;
	IGRdouble	*sN;
struct	sect_dist	*Fdist;

	/* Initialize */
	fN = tN = lO = NULL;
	sN = NULL;
	Fdist = NULL;

	/* Exit if no sectionOption available */
	if (!opt) {
		ret = TRUE;
		goto wrapup;
	}

	/* Check all data sections defined by distance */
	if (  (*opt == SM_FD_Distance)
	   && ( (!frD) || (!toD) || (!nmD) ) ) {
printf( "Error : <frDistance>, <toDistance> and <frameNumber> must be defined\n" );
			goto wrapup;
	}

	/* Check all data if number of sections change */
	if (  (old->nb_sect != new->nb_sect)
	   && (*opt == SM_FD_Number)
	   && ( (!frN) || (!toN) || (!spN) ) ) {
printf( "Error : <frNumber>, <toNumber> and <spacing> must be defined\n" );
			goto wrapup;
	}

	/* Allocate memory to layerOffset */
	lO = _CALLOC ( new->nb_sect,IGRint );

	/* Fill layerOffset buffer */
	for ( i=0; i<new->nb_sect; i++ ) {
		if (lyO)	lO[i] = lyO[i];
		
		else if (old->nb_sect == new->nb_sect)
				lO[i] = (IGRint) new->sect_info[i].offset;
		else		lO[i] = 0;
	}

	/* Sections defined by NUMBER */
	if ( (opt) && (*opt == SM_FD_Number) ) {

		/* Allocate memory for buffers */
		fN = _CALLOC ( new->nb_sect,IGRint );
		tN = _CALLOC ( new->nb_sect,IGRint );
		sN = _CALLOC ( new->nb_sect, IGRdouble );

		/* Fill buffers */
		for ( i=0; i<new->nb_sect; i++ ) {

			if (frN)	fN[i] = frN[i];
			else		fN[i] = new->sect_info[i].fr;

			if (toN)	tN[i] = toN[i];
			else		tN[i] = new->sect_info[i].to;

			if (spN)	sN[i] = spN[i];
			else		sN[i] = new->sect_info[i].spacing;
		}

		/* Fill structure with buffers */
		ret = CFSsectionInfo ( *opt, unit,
				       fN, tN, sN, NULL, NULL, NULL, lO,
				       new );
		goto wrapup;
	}

	/* Sections defined by DISTANCE */
	else if ( (opt) && (*opt == SM_FD_Distance) ) {

		/* Allocate memory for structure */
		Fdist = _CALLOC ( new->nb_sect, struct sect_dist );

		/* Fill buffers */
		for ( i=0; i<new->nb_sect; i++ ) {
			if (! SMfr_convert_unit_int
				( frD[i], unit, &Fdist[i].Xa ) )
				Fdist[i].Xa = frD[i];
			if (! SMfr_convert_unit_int
				( toD[i], unit, &Fdist[i].Xb ) )
				Fdist[i].Xb = toD[i];
			Fdist[i].nb = nmD[i];
		}

		/* Fill structure with buffers */
		ret = CFSdistToNumb ( Fdist, lO, new );
		goto wrapup;
	}

	/* Nothing happens ! */
	ret = TRUE;

wrapup:
	if (fN) _FREE (fN);
	if (tN) _FREE (tN);
	if (sN) _FREE (sN);
	if (lO) _FREE (lO);
	if (Fdist) _FREE (Fdist);

	return (ret);
}
/* ***** */

IGRlong	SMmodify_frame_system (	IGRlong			*msg,
				struct	GRid		*frameSystemId,
				IGRchar			*name,
				IGRint			*frameDisplay,
				struct	GRid		*csId,
				struct	GRmd_env	*csEnv,
				IGRint			*axis,
				IGRint			*orientation,
				IGRdouble		*revDistance,
				IGRint			*regulSize,
				IGRdouble		*regulValue,
				IGRint			*reinfSize,
				IGRdouble		*reinfValue,
				IGRchar			*annotation,
				IGRdouble		*originOffset,
				IGRint			*wJustif,
				IGRint			*hJustif,
				IGRint			*sectionNumber,
				IGRchar			*distanceUnit,
				IGRint			*sectionOption,
				IGRint			*frNumber,
				IGRint			*toNumber,
				IGRdouble		*spacing,
				IGRdouble		*frDistance,
				IGRdouble		*toDistance,
				IGRint			*frameNumber,
				IGRint			*layerOffset,
				IGRchar			*reinforce,
				IGRchar			*reverse )	{

	IGRlong			sts=OM_S_SUCCESS;
	struct	GRid		frameZero, frameRoot[4], newCs;
	IGRint			cnt=0, Fbad=-1;
	struct	frame_def	oldFrame, newFrame;
	IGRchar			newName[DI_PATH_MAX];

	/* Initialize */
	oldFrame.sect_info = NULL;
	newFrame.sect_info = NULL;
	frameZero.objid = frameRoot[0].objid = frameRoot[1].objid
	= frameRoot[2].objid = frameRoot[3].objid = NULL_OBJID;

	/* Retrieve frame 0 */
	sts = om$send ( msg = message SMfrm_syst.SMfind_frame_objid
					( msg, 0, &frameZero ),
			senderid = NULL_OBJID,
			targetid = frameSystemId->objid,
			targetos = frameSystemId->osnum );
	as$status ( sts    = sts,
                    msg    = "SMfrm_syst.SMfind_frame_objid",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve roots */
	sts = om$send ( msg = message NDnode.NDget_objects
				( ND_ROOT, frameRoot, 4, NULL, 0, 3, &cnt ),
			senderid = NULL_OBJID,
			targetid = frameZero.objid,
			targetos = frameZero.osnum );
	*msg = MSFAIL;
	as$status ( sts    = sts,
                    msg    = "NDnode.NDget_objects",
                    test   = ((sts != OM_S_SUCCESS) || (cnt != 4)),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef DEBUG
for (i=0;i<cnt;i++)
printf( "Root %d is [%d|%d]\n", i, frameRoot[i].objid, frameRoot[i].osnum );
#endif

	/* Get new name */
	if ( (!name) || (name[0] == '\0') ) {
		/* Get old name */
		sts = om$send ( msg = message GRgraphics.GRgetname
						( msg, newName ),
				senderid = NULL_OBJID,
				targetid = frameSystemId->objid,
				targetos = frameSystemId->osnum );
		as$status ( sts    = sts,
	                    msg    = "GRgraphics.GRgetname",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		di$split ( pathname = newName, name = newName );
	}
	else	strncpy ( newName, name, DI_PATH_MAX );

	/* Get new coordinate system */
	if ( (!csId) || (csId->objid == NULL_OBJID) ) {
		/* Get old coordinate system */
		newCs.objid = frameRoot[0].objid;
		newCs.osnum = frameRoot[0].osnum;
	}
	else if (csEnv) {
		/* Make source object of located coordinate system */
		sts = as$make_source ( go_grid = *csId,
				       mod_env = csEnv,
				       as_grid = &newCs );
		as$status ( sts    = sts,
                    	    msg    = "as$make_source()",
                    	    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}
	else {	printf( "csId cannot be given without csEnv\n" );
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Allocate memory from old frame structure */
	oldFrame.sect_info = _CALLOC ( NB_MAX_SECTION, struct sect_info);
	*msg = MSFAIL;
	if (! oldFrame.sect_info)	goto wrapup;;

	/* Fill old frame structure */
	sts = SMFillFrmDefInfo ( &frameRoot[2], NB_MAX_SECTION, &oldFrame );
	*msg = MSFAIL;
	as$status ( sts    = sts,
                    msg    = "SMFillFrmDefInfo(old)",
                    test   = (sts != 1),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory from new frame structure */
	newFrame.sect_info = _CALLOC ( NB_MAX_SECTION, struct sect_info);
	*msg = MSFAIL;
	if (! newFrame.sect_info)	goto wrapup;;

	/* Fill new frame structure */
	sts = SMFillFrmDefInfo ( &frameRoot[2], NB_MAX_SECTION, &newFrame );
	*msg = MSFAIL;
	as$status ( sts    = sts,
                    msg    = "SMFillFrmDefInfo(new)",
                    test   = (sts != 1),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Fill new frame structure with type name */
	if 	( (frameDisplay) && (*frameDisplay == SM_FD_Number) )
		newFrame.main_info.name_type = NAME_BY_NUMBER;
	else if ( (frameDisplay) && (*frameDisplay == SM_FD_Distance) )
		newFrame.main_info.name_type = NAME_BY_DIST;

	/* Fill new frame structure with axis */
	if (axis)	CFSaxis ( &newFrame, *axis );

	/* Fill new frame structure with orientation */
	if (orientation)	CFSorient ( &newFrame, *orientation );

	/* Fill new frame structure with distanceUnit */
	if (distanceUnit)	strncpy ( newFrame.main_info.unit,
					  distanceUnit, ATTR_TXT );

	/* Fill new frame structure with revDistance */
	if (revDistance)	CFSrevDist ( &newFrame, newFrame.main_info.unit,
					     revDistance );

	/* Fill new frame structure with regulSize */
	if (regulSize)	CFSplnSize ( &newFrame.main_info.plane_size,
				     *regulSize, regulValue,
				     newFrame.main_info.unit );

	/* Fill new frame structure with reinfSize */
	if (reinfSize)	CFSplnSize ( &newFrame.main_info.plane_size,
				     *reinfSize, reinfValue,
				     newFrame.main_info.unit );

	/* Fill new frame structure with annotation */
	if (annotation)		strncpy ( newFrame.main_info.annot,
					  annotation, 10 );

	/* Fill new frame structure with originOffset */
	if (originOffset) {
		if (! SMfr_convert_unit_int ( *originOffset,
					      newFrame.main_info.unit,
                                      	      &newFrame.main_info.offset_dist ))
			newFrame.main_info.offset_dist = *originOffset;
	}

	/* Fill new frame structure with wJustif */
	if (wJustif)	CFSjustif ( &(newFrame.main_info.justif[0]), *wJustif );

	/* Fill new frame structure with hJustif */
	if (hJustif)	CFSjustif ( &(newFrame.main_info.justif[1]), *hJustif );

	/* Fill new frame structure with sectionNumber */
	if (sectionNumber)	newFrame.nb_sect = *sectionNumber;

	/* Fill new frame structure with sections info */
	if (! MFSsectionInfo ( sectionOption, newFrame.main_info.unit,
			       frNumber, toNumber, spacing,
			       frDistance, toDistance, frameNumber,
			       layerOffset, &oldFrame,
			       &newFrame ) )	goto wrapup;

	/* Fill new frame structure with reinforced frame expression */
	if (reinforce)
		strncpy ( newFrame.main_info.reinfstr,
			  reinforce,
			  NB_CUT_STR * ATTR_TXT );

	/* Fill new frame structure with reversed frame expression */
	if (reverse)
		strncpy ( newFrame.main_info.revstr,
			  reverse,
			  NB_CUT_STR * ATTR_TXT );
			       
	/* Modify frame system */
	sts = SMModFrame ( newName, frameSystemId, &frameRoot[0], &newCs,
			   &frameRoot[2], &frameRoot[3],
			   &oldFrame, &newFrame, &Fbad );
	if (sts != 1) {
		ex$message ( msgnumb = SM_E_FrBadDefFr,
			     type = "%d", var = `Fbad`);
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Successful completion */
	*msg = MSSUCC;

wrapup:
	/* Dealloc old frame structure */
	if (oldFrame.sect_info) 
		_FREE (oldFrame.sect_info);

	/* Dealloc new frame structure */
	if (newFrame.sect_info) 
		_FREE (newFrame.sect_info);

	return sts;
}

/* ***** */

end implementation Root;
