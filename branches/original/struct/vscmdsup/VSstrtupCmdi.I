/* $Id: VSstrtupCmdi.I,v 1.1.1.1 2001/01/04 21:10:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:       vscmdsup/VSstrtupCmdi.I 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSstrtupCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:30  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/01/27  16:58:08  pinnacle
# (No comment)
#
# Revision 1.2  1998/11/08  14:47:02  pinnacle
# ah
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.4  1996/03/05  10:51:24  pinnacle
# Replaced: vscmdsup/VSstrtupCmdi.I for:  by msbraju for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *    --     AF      creation
 * 11/08/98  ah      Call ppl during file startup
 * 01/27/00  RR	     Added VSapps.lib
 ***************************************************************************/

class implementation VSstrtupCmd ;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <FI.h>
#include "exmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "grlicense.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "vdprdmacros.h"
#include "vsglobalmsg.h"
#include "vsproductdef.h"
#include "vsdpbdef.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vsbeamdef.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "exproto.h"
#include "super_parai.h"
#include "vsioproto.h"
#include "vsupdreffdep.h"

#include "VDtypedef.h"
#include "VDppl1.h"

#define VSfeatures		"VSfeatures.mc"
#define VS_SESSION_STARTUP	0
#define VS_DGNFILE_STARTUP	1

/*
 * "Update dependency of reference files" form.
 */
#define VS_UPDREFILES_FORM	"VSupdRefFls.fm"
#define VS_TEXT1		12
#define VS_TEXT2		13
#define VS_TEXT3		14
#define VS_TEXT4		15
#define VS_REFFILES_FIELD	16

extern long	VSaddStructuralPocketMenu	__(( void )) ;
extern void	VSresetMacLibsOfPalInterface	__(( void )) ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSchkRefFilesNotification( form_label, gadget, value, form )

int	form_label ;
int	gadget ;
double	value ;
char	*form ; {

	long	msg ;
	int	resp ;

	switch( gadget ) {
		case FI_ACCEPT	:
			VScheckRefFilesDependency( &msg, TRUE, NULL, NULL ) ;
			/* No break on purpose */

		case FI_CANCEL	:
			FIf_delete( form ) ;
			resp =  EX_FORM_FINISHED ;
			ex$putque(	msg	= &msg,
					response= &resp ) ;
			break ;

		default		: break ;
	}

	return FI_SUCCESS ;

} /* VSchkRefFilesNotification */
/*----------------------------------------------------------------------------*/
int VSupdChkRefFilesForm( refCount, refList )

int	refCount ;
OMuword *refList ; {

	char		*form ;
	int		rc,
			i,
			j,
			row ;
        char		osname[OM_K_MAXOSNAME_LEN],
        		previous[OM_K_MAXOSNAME_LEN] ;

	rc = FIf_new(	1,
			VS_UPDREFILES_FORM,
			VSchkRefFilesNotification,
			&form ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	FIg_set_text( form, VS_TEXT1, VSmsgkey2string( VS_gI_UpdRff_Tx1 ) ) ;
	FIg_set_text( form, VS_TEXT2, VSmsgkey2string( VS_gI_UpdRff_Tx2 ) ) ;
	FIg_set_text( form, VS_TEXT3, VSmsgkey2string( VS_gI_UpdRff_Tx3 ) ) ;
	FIg_set_text( form, VS_TEXT4, VSmsgkey2string( VS_gI_UpdRff_Tx4 ) ) ;

	rc = FIfld_set_num_rows( form, VS_REFFILES_FIELD, refCount ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	*previous = '\0' ;
	for( i = 0, row = 0 ; i < refCount ; i++ ) {
		/*
		 * Do not display same name of reference file, in case we have
		 * a multiple attachment of the same file.
		 */
		om$os_number_to_name( osnum  = refList[i],
        			      osname = osname ) ;
		for( j=0; j<i; j++ ) {
			om$os_number_to_name( osnum  = refList[j],
        				      osname = previous ) ;
			if( !strcmp( previous, osname ) ) break ;
        	}
		if( j<i ) continue ;	
        	FIfld_set_text( form, 
        			VS_REFFILES_FIELD, 
        			row++, 
        			0, 
        			osname, 
        			FALSE ) ;
	}
	/*
	 * NOTE: FIf_display will fail if the quiet mode is ON, eg. I/STRUCT
	 * is run in batch mode.
	 */
	rc = FIf_display( form ) ;

	wrapup :
		if( rc != FI_SUCCESS ) {
			if( form ) FIf_delete( form ) ;
			rc = FALSE ;
		} else	rc = TRUE ;

		return rc ;

} /* VSupdChkRefFilesForm */
/*----------------------------------------------------------------------------*/
method init( int type ; char *s ) {

	me->mytype = type ;
	return OM_S_SUCCESS ;

} /* method init */
/*----------------------------------------------------------------------------*/
method execute(	int *response ; char *response_data ; int pos ) {

	long	msg ;

	nd$mod_broadcast(	request     = ND_SET,
				req_mode    = ND_NO_BROAD_DEL ) ;

	if( me->mytype == VS_SESSION_STARTUP ) {

		/*
		 * Session startup. See if user has a license to use I/STRUCT.
		 */
#ifdef HAVE_LICENCE
		gr$get_license(	product_id	= VS_K_PRODUCT_NUMBER,
				run_name	= VS_K_PRODUCT_RUNNAME ) ;
#endif

		/*
		 * Add button to the pocket menu.
		 */
		msg = VSaddStructuralPocketMenu() ;

		/*
		 * load all patches from $STRUCT/config/dload/corrections dir.
		 *
		 * 11/08/98 Why is this here and not in the dgnfile_startup like
		 * the rest of the products? ah
		 */
		msg = vd$prd_load_corrections( run_name = VD_PROD_NAME_STRUCT );


	} else if( me->mytype == VS_DGNFILE_STARTUP ) {

		OM_S_OBJID	stamp ;
		/*  Commented as per TR 179528396 
		int		nbModRef ;
		OMuword		*modRefList = NULL, */

		OMuword 	modOs ;
		OM_S_OBJID	STRUCTdpb ;

		TGRid   pplID;
		IGRint  pplRET;
		IGRchar pplProduct[16];

		// Inform the ppl about to start
		strcpy(pplProduct,"struct");
		vdppl$Load(pplID = &pplID, name = "VDstartup.u");
		vdppl$SetData(pplID = &pplID, 
			      name  = "PRODUCT", 
			      size  = 16, 
			      data  = pplProduct);

		vdppl$Run(pplID = &pplID, name = "startup1", ret = &pplRET);

		VSresetMacLibsOfPalInterface() ;

		/*
		 * File startup.
		 * Create I/STRUCT's Default Parameter Block in file.
		 * Make sure a version stamp object will exist in file.
		 * and initialize Associative Geometry
		 */
		VSget_dpb( &STRUCTdpb, &modOs ) ;

		ex$get_cur_mod( osnum = &modOs ) ;
		vs$getVersionStampId(	osnum	= modOs,
					stampId	= &stamp ) ;
		ASsuper_construct() ;

		/*
		 * Load library of macro definitions of STRUCT objects.
		 */
		if( !( ac$construct_path(	mode	= AC_ADD_PATH,
						name	= VSfeatures ) & 1 ) ) {
			char ErrBuf[MS_MAX_MSG_LENGTH] ;

			ex$message(	msgnumb	= VS_gE_NoMacLib,
					type	= "%s",
					var	= `VSfeatures`,
					buff	= ErrBuf ) ;
			UI_error( ErrBuf ) ;
		}

		VDSloadMacroLibrary( "VSapps.lib" );

		/*
		 * Add STRUCT's sub-representations to the global collection
		 * of possible representation, if they are not already there.
		 */
		ac$add_representation(	name	= VS_K_Struct2dRep,
					value	= VS_m_2dSurface ) ;

		ac$add_representation(	name	= VS_K_FilletedBeamRep,
					value	= VS_m_3dWFillet ) ;

		/*
		 * Should this file reference other files, see if this file
		 * has structural elements depending upon objects in the other
		 * files; if so perform update of dependent elements in this
		 * file if parent objects in the reference files have been
		 * modified. Also if objects in this file consume elements
		 * in reference files, reconsume them since they come up
		 * as not consumed.
		 */
                /*
                 * Commenting the Code for TR179523396 Start
                 */
#if 0

		nbModRef = 0 ;
		if( !ex$is_batch() ) {

			/*
			 * `EX_MAX_INVIS_MODULE' is not a constant but a
			 * global, hence we must allocate the memory.
			 */
			modRefList = _MALLOC( EX_MAX_INVIS_MODULES, OMuword ) ;

			if( modRefList ) {
				VScheckRefFilesDependency(	&msg,
								FALSE,
								&nbModRef,
								modRefList ) ;
			}
		}

		if( nbModRef ) {
			int rc ;
			rc = VSupdChkRefFilesForm( nbModRef, modRefList ) ;
			if( !rc ) {
				/*
				 * Form creation failed: force update anyway.
				 */
				VScheckRefFilesDependency( &msg, TRUE,
							   NULL, NULL ) ;
			} else {
				do {
					ex$wait_for_input(
						response= response,
						buffer	= response_data,
						mode	= EX_ALL_ASCII_MODE,
						byte	= &rc ) ;

				} while( *response != EX_FORM_FINISHED ) ;
			}
		}
		_FREE( modRefList ) ;
#endif
                /*
                 * Commenting the Code for TR179523396 End
                 */
 
		vdppl$Run(pplID = &pplID, name = "startup2", ret = &pplRET);
		vdppl$Delete(pplID = &pplID);

	} /* Else any other type may be used to have some .o file
	     dynamically loaded.
	   */

	*response = TERMINATE ;
	return OM_S_SUCCESS ;

} /* method execute */
/*----------------------------------------------------------------------------*/

end implementation VSstrtupCmd ;
