/* # $Id: VDfileform.C,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $ */
 
/* # -------------------------------------------------------------------
# I/VDS
#
# File: vds/vdpts/vdfileform.C
#
# Description:
#
# Dependencies:
#
# Revision History:
#       $Log: VDfileform.C,v $
#       Revision 1.1.1.1  2001/01/04 21:08:52  cvs
#       Initial import to CVS
#
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/06/17  13:02:36  pinnacle
 * (No comment)
 *
 * Revision 1.1  1997/06/13  17:39:12  pinnacle
 * CR179527294: moved from vdpts to vdio to keep all subform (input/output) utilities together
 *
 * Revision 1.1  1997/05/30  09:11:02  pinnacle
 * initial revision
 *
# History:
#       MM/DD/YY        AUTHOR          DESCRIPTION
#       05/30/97        Sundar          Creation Date
#
# ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#include <unistd.h>
#define FALSE 0
#define TRUE 1
#include <FI.h>
#include "msdef.h"
#include "v_cmd.h"
#include "v_globalmsg.h"
#include "exdef.h"
#include "exmacros.h"
/*
 * Includes of function prototypes
 */
#include "VX_FIproto.h"
#include "v_getmsgkey.h"
#include "v_ioproto.h"      /* VDcreateFileForm */
#include "v_strngproto.h"
#include "VDmem.h"
#include "VDmsg.h"

#define VD_K_FILE_FORM "VDKyInFilNm.fm"
#define VD_K_DIR_FIELD	12
#define VD_K_FILE_FIELD	14
#define VD_K_FILT_FIELD 15
#define VD_K_FORM_TITLE 17

#define VD_K_FILE_ACCEPTED   260
#define VD_K_FILE_CANCELED   261

typedef char	FILENAME[1+FILENAME_MAX] ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VDfileFormNotification( form_label, gadget, value, form )

int	form_label,
	gadget ;
double	value ;
char	*form ; {

	VD_fileFormInfo	*info ;
	int		sel,
			pos ;
	FILE		*f ;
	long		msg ;
	int		listFiles = FALSE ;

	FIf_get_user_pointer( form, (char **) &info ) ;

	switch( gadget ) {

	case FI_CANCEL		:
		*info->pathName = '\0' ;
		if( info->callBack ) {
			info->callBack( info->parentForm, VD_K_FILE_CANCELED ) ;
		} else {
			pos = VD_K_FILE_CANCELED ;
			ex$putque( msg = &msg, response = &pos ) ;
		}
		FIf_delete( form ) ;
		listFiles = FALSE ;
		break ;

	case FI_ACCEPT		:

		if( f = VD_openFile( &msg, info->pathName, info->openMode ) ) {

			fclose( f ) ;
			if( info->callBack ) {
				info->callBack( info->parentForm, VD_K_FILE_ACCEPTED ) ;
			} else {
				pos = VD_K_FILE_ACCEPTED ;
				ex$putque( msg = &msg, response= &pos ) ;
			}
			FIf_delete( form ) ;
			listFiles = FALSE ;
		} else {
			/*
			VDfi_msgkey( form, VD_getMsgKey( msg ) ) ;
			*/
			FIg_set_state_off( form, FI_ACCEPT ) ;
		}
		break ;

	case VD_K_DIR_FIELD	:
		FIfld_get_text( form, VD_K_DIR_FIELD , 0, 0, MAXPATHLEN+1,
				(unsigned char *) info->curPATH, &sel, &pos ) ;
		if( !VD_isReadableUNIXDir( info->curPATH ) ) {
			/* VDfi_msgkey( form, VD_gW_NoSuchDir ) ; */
			strcpy( info->curPATH, "." ) ;
			FIfld_set_text( form, VD_K_DIR_FIELD, 0, 0,
						info->curPATH, FALSE ) ;
		}
		listFiles = TRUE ;
		break ;

	case VD_K_FILE_FIELD	:
		FIfld_get_text( form, VD_K_FILE_FIELD, 0, 0, FILENAME_MAX+1,
				(unsigned char *) info->curNAME, &sel, &pos ) ;
		sprintf( info->pathName, "%s/%s", info->curPATH, info->curNAME ) ;

		if ( info->curNAME[0] && info->openMode[0] == 'w' && 
		     !access(info->pathName, F_OK) )
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
				  "Warning : File Exists", FALSE );
		else
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0, "", FALSE ) ;
		break ;

	case VD_K_FILT_FIELD	:
		FIfld_get_text( form, VD_K_FILT_FIELD , 0, 0, VD_K_MAX_RGXP,
				(unsigned char *) info->curRGXP, &sel, &pos ) ;
		if( !VD_matchRE( info->curRGXP, NULL ) ) {
			/* Invalid regular expression */
			/* VDfi_msgkey( form, VD_gW_InvRegExp ) ; */
			strcpy( info->curRGXP, "*" ) ;
			FIfld_set_text( form, VD_K_FILT_FIELD, 0, 0,
						info->curRGXP, FALSE ) ;
		}
		listFiles = TRUE ;
		break ;

	default			:
		break ;
	}

	if( listFiles ) {
			int		count	= 0 ;
			FILENAME	*files	= NULL ;
			int		i ;
#define MAX 100
			char		*list[MAX] ;
			char		*ptr ;

			VD_ls( &msg, info->curPATH, info->curRGXP, VD_isASCIIFile,
				&count, &files ) ;
			if( count > MAX ) count = MAX ;

			ptr = NULL ;
			for( i = 0 ; i < count ; i++ ) {
				list[i] = &files[i][0] ;
				if( !strcmp( list[i], info->curNAME ) ) {
					ptr = list[i] ;
				}
			}
			if( count > 1 ) {
				qsort( list, count, sizeof *list,
				VD_strcmpByPtrs ) ;
			}
			VDfld_set_list( form, VD_K_FILE_FIELD, count, list ) ;
			if( count ) {
				if( !ptr ) ptr = list[0] ;
				FIfld_set_text( form, VD_K_FILE_FIELD, 0, 0,
						ptr, FALSE ) ;
				sprintf( info->pathName, "%s/%s", info->curPATH,
					 ptr ) ;

				if ( info->curNAME[0] && 
				     info->openMode[0] == 'w' && 
				     !access(info->pathName, F_OK) )
					FIfld_set_text( form, FI_MSG_FIELD, 0,
					0, "Warning : File Exists", FALSE );
				else
					FIfld_set_text( form, FI_MSG_FIELD, 0,
					0, "", FALSE ) ;
				_FREE( files ) ;
			} else {
				FIfld_set_text( form, VD_K_FILE_FIELD, 0, 0,
						"", FALSE ) ;
			}
#undef MAX
	}


	return FI_SUCCESS ;

} /* VDfileFormNotification */
/*----------------------------------------------------------------------------*/
char *VDcreateFileForm( x, y, info ) int x, y ; VD_fileFormInfo *info ; {

	int	rc ;
	char	*form = NULL ;
	long	msg ;

	rc = FIf_new( 1, VD_K_FILE_FORM, VDfileFormNotification, &form ) ;

	if( FI_SUCCESS == rc ) {
		sprintf( info->pathName, "%s/%s", info->curPATH, info->curNAME ) ;
		

		FIf_set_user_pointer( form, (char *) info ) ;
		FIf_set_location( form, x, y ) ;
		FIf_set_collapse_location( form, x, y ) ;

		FIfld_set_text( form, VD_K_DIR_FIELD , 0, 0, info->curPATH, FALSE ) ;
		FIfld_set_text( form, VD_K_FILE_FIELD, 0, 0, info->curNAME, FALSE ) ;
		FIfld_set_text( form, VD_K_FILT_FIELD, 0, 0, info->curRGXP, FALSE ) ;

		if(info->openMode[0] == 'w')
		  FIg_set_text( form, VD_K_FORM_TITLE, "Write to file");
		else if(info->openMode[0] == 'r')
		  FIg_set_text( form, VD_K_FORM_TITLE, "Read from file");
		else if(info->openMode[0] == 'a')
		  FIg_set_text( form, VD_K_FORM_TITLE, "Append to file");

		if ( info->curNAME[0] && info->openMode[0] == 'w' && 
		     !access(info->pathName, F_OK) )
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
				  "Warning : File Exists", FALSE );
		else
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0, "", FALSE ) ;
/*
		FIfld_pos_cursor( form, VD_K_DIR_FIELD, 0, 0, 0, 0, 0, 0 ) ;
		FIf_set_start_seq( form, VD_K_DIR_FIELD ) ;
*/
		FIf_display( form ) ;
	 {
			int		count	= 0 ;
			FILENAME	*files	= NULL ;
			int		i ;
#define MAX 100
			char		*list[MAX] ;
			char		*ptr ;

			VD_ls( &msg, info->curPATH, info->curRGXP, VD_isASCIIFile,
				&count, &files ) ;
			if( count > MAX ) count = MAX ;

			ptr = NULL ;
			for( i = 0 ; i < count ; i++ ) {
				list[i] = &files[i][0] ;
				if( !strcmp( list[i], info->curNAME ) ) {
					ptr = list[i] ;
				}
			}
			if( count > 1 ) {
				qsort( list, count, sizeof *list,
				VD_strcmpByPtrs ) ;
			}
			VDfld_set_list( form, VD_K_FILE_FIELD, count, list ) ;
			if ( count ) _FREE( files ) ;
#undef MAX
	 }
	} else	form = NULL ;

	return form ;

} /* VDcreateFileForm */
/*----------------------------------------------------------------------------*/
