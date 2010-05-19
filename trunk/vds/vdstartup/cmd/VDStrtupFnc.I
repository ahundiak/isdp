/* $Id: VDStrtupFnc.I,v 1.2 2001/09/07 20:08:03 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/cmd/VDstrupFnc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDStrtupFnc.I,v $
 *	Revision 1.2  2001/09/07 20:08:03  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1  2001/08/30 23:21:01  ad
 *	*** empty log message ***
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      08/30/01        adz             Create seperate file.
 * -------------------------------------------------------------------*/

class implementation VDCmdStrtup ;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <FI.h>
#include <sys/types.h>
#include <dirent.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EXproduct.h"
#include "exmacros.h"
#include "ciexecmacros.h"
#include "msdef.h"
#include "wl.h"
#include "ms.h"
#include "msmacros.h"
#include "grlicense.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "VDmsg.h"
#include "vdprdmacros.h"
#include "v_slc.h"
#include "v_pplslc.h"     /* vd$obj_ppl_exec */

#include "VDtypedef.h"
#include "VDppl1.h"
#include "VDpdm.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "exdate.h"
#include "exvers.h"

extern char EX_version[];
extern char EX_date[];
extern EX_get_version ();
extern IGGetBsVersion();

/*
 * Includes of function prototypes.
 */
%safe
#include <VX_FIproto.h>
%endsafe

#include "VDsaProto.h"


/*
 * "Update dependency of reference files" form.
 */
#define VDS_UPDREFILES_FORM	"VDSupdRefDep"
#define VDS_TEXT1		12
#define VDS_TEXT2		13
#define VDS_TEXT3		14
#define VDS_TEXT4		15
#define VDS_REFFILES_FIELD	16
#define	VDS_REFFILES_WRITE	17

#define	VDS_REFFILES_WRITE_FILE	"ref_list.txt"

#define TEXT_FONT       "-adobe-courier-medium-*-normal-*-15-*-*-*-*-*-*-*"

extern int	UI_error			__(( char * )) ;
extern long	ASsuper_construct		__(( void )) ;
extern void	VDsuper_construct		__(( void )) ;
extern void	VDSet_SUper_construct		__(( void )) ;
extern int	SMAddToPocketMenu		__(( void )) ;
extern int	VDSnopdu_init			__(( void )) ;
extern int	VDSudp_init			__(( void )) ;
extern int	ACcond_CLEAR    		__(( void )) ;

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
int VDSchkRefFilesNotification( form_label, gadget, value, form )

int	form_label ;
int	gadget ;
double	value ;
char	*form ; {

	long		msg, sts ;
	int		i, row, flag, pos, resp;
	double		ddummy;
	int		idummy;
	OMuword		osnum;
	FILE		*fp;
	GRspacenum 	cur_os;
	GRname		path_name;
        unsigned char	osname[OM_K_MAXOSNAME_LEN];
	IGRint		refCount;

	SetProc( VDSchkRefFilesNotification ); Begin

	ddummy = value;
	idummy = form_label;
	fp	= NULL ;

	__DBGpr_int(" gadget ", gadget );

	switch( gadget ) {
		case FI_ACCEPT	:
			VDScheckRefFilesDependency( &msg, TRUE, NULL, NULL );

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */


			/* replace above call with this */
			VDScheckRefFilesDependency( &msg, TRUE,
						    NULL, NULL, NULL, NULL,
						    NULL, NULL, NULL, NULL );
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

/*
			nd$mod_batch( req_mode = ND_IMMEDIATE );
			nd$exec_batch();
*/
			/* No break on purpose */

		case FI_CANCEL	:
			FIf_delete( form ) ;
			resp =  EX_FORM_FINISHED ;
			ex$putque(	msg	= &msg,
					response= &resp ) ;
			break ;

		case VDS_REFFILES_WRITE :

			/*
			 * check all object spaces and print out information.
			 */

			fp = ( FILE * )fopen( VDS_REFFILES_WRITE_FILE, "w" );

			FIfld_get_num_rows( form, VDS_REFFILES_FIELD, &refCount ) ;

			if( refCount ){
			  fprintf(fp, "Modified Reference Files:\n");
			  fprintf(fp, "=======================================================\n");
			}
			for( row = 0 ; row < refCount ; row++ ) {
			  /*
			   * Do get the displayed information from the form.
		 	   */
        		  FIfld_get_text( form, VDS_REFFILES_FIELD, row, 0, 100, osname, &flag, &pos ) ;
			  __DBGpr_str(" From osname", osname );

			  om$os_name_to_number(	osname  = osname, p_osnum = &osnum );
			  __DBGpr_int(" OSnumber ", osnum );

        		  fprintf( fp, "modified  : %d :%s\n",osnum,OM_GA_OSDs[osnum]->name );
			}


	    		sts = ex$get_cur_mod (osnum = &cur_os);
			__DBGpr_int(" current OS ", cur_os );

			fprintf(fp, "\n\nOverview of all Files:\n");
			fprintf(fp, "=======================================================\n");

			for( osnum = 2 ; osnum < OM_Gw_maxOS ; osnum++ ) {
		
			  path_name[0] = '\0';
			  if( OM_GA_OSDs[ osnum ] ){

			    if( osnum == cur_os ){
        			fprintf( fp, "active    : %d :%s\n",osnum,OM_GA_OSDs[osnum]->name );
			    }
			    else{
				/*
				 * check difference between library and reference file.
				 */
			        ACos_to_path( osnum, path_name );
      				if( path_name[0] != '\0' )
        				fprintf( fp, "library   : %d :%s\n",osnum,OM_GA_OSDs[osnum]->name );
				else
        				fprintf( fp, "reference : %d :%s\n",osnum,OM_GA_OSDs[osnum]->name );
			    }
			  }
			}
			fclose ( fp );
			UI_status(" File ref_list.txt created !!");
			break ;

		default		: break ;
	}

	End ;
	return FI_SUCCESS ;

} /* VDSchkRefFilesNotification */
/*----------------------------------------------------------------------------*/
int VDSupdChkRefFilesForm( refCount, refList )

int	refCount ;
OMuword *refList ; {

	char		*form ;
	int		rc,
			i ,
			j ,
			row ;
        char		osname[OM_K_MAXOSNAME_LEN],
        		previous[OM_K_MAXOSNAME_LEN],
			msg_buff[81] ;

	SetProc( VDSupdChkRefFilesForm ); Begin

	rc = FIf_new(	1,
			VDS_UPDREFILES_FORM,
			VDSchkRefFilesNotification,
			&form ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

        ex$message ( msgnumb = VD_I_UpdRff_Tx1, buff = msg_buff );
	FIg_set_text( form, VDS_TEXT1, msg_buff ) ;

        ex$message ( msgnumb = VD_I_UpdRff_Tx2, buff = msg_buff );
	FIg_set_text( form, VDS_TEXT2, msg_buff ) ;

        ex$message ( msgnumb = VD_I_UpdRff_Tx3, buff = msg_buff );
	FIg_set_text( form, VDS_TEXT3, msg_buff ) ;

        ex$message ( msgnumb = VD_I_UpdRff_Tx4, buff = msg_buff );
	FIg_set_text( form, VDS_TEXT4, msg_buff ) ;

	rc = FIfld_set_num_rows( form, VDS_REFFILES_FIELD, refCount ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	*previous = '\0' ;
	for( i = 0 , row = 0 ; i < refCount ; i++ ) {
		/*
		 * Do not display same name of reference file, in case we have
		 * a multiple attachment of the same file.
		 */
		om$os_number_to_name(	osnum   = refList[i],
        				osname  = osname ) ;
		for( j=0; j<i; j++ ) {
			om$os_number_to_name( osnum   = refList[j],
					      osname  = previous );
			if( !strcmp( previous, osname ) ) break ;
		}
		if( j<i ) continue;
        	FIfld_set_text(	form,
				VDS_REFFILES_FIELD,
				row++,
				0,
				osname,
				FALSE ) ;
        	strcpy( previous, osname ) ;
	}
	rc = FIfld_set_num_rows( form, VDS_REFFILES_FIELD, row ) ;
	/*
	 * NOTE: FIf_display will fail if the quiet mode is ON, eg. I/VDS
	 * is run in batch mode.
	 */
	rc = FIf_display( form ) ;

	wrapup :
		if( rc != FI_SUCCESS ) {
			if( form ) FIf_delete( form ) ;
			rc = FALSE ;
		} else	rc = TRUE ;

		End ;
		return rc ;

} /* VDSupdChkRefFilesForm */

/*----------------------------------------------------------------------------*/

end implementation VDCmdStrtup ;
