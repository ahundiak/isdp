/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#include <unistd.h>
#define FALSE 0
#define TRUE 1
#include <FI.h>
#include "msdef.h"
#include "vscmddef.h"
#include "vscmd.h"
#include "vsglobalmsg.h"
#include "exdef.h"
#include "exmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes
 */
#include "VX_FIproto.h"
#include "vsformproto.h"
#include "vsgetmsgkey.h"
#include "vsioproto.h"
#include "vsstrngproto.h"

#define VS_K_FILE_FORM "VSKyInFilNm.fm"
#define VS_K_DIR_FIELD	12
#define VS_K_FILE_FIELD	14
#define VS_K_FILT_FIELD 15
#define VS_K_FORM_TITLE 17

typedef char	FILENAME[1+FILENAME_MAX] ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VSfileFormNotification( form_label, gadget, value, form )

int	form_label,
	gadget ;
double	value ;
char	*form ; {

	VSfileFormInfo	*info ;
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
			info->callBack( info->parentForm, VS_K_FILE_CANCELED ) ;
		} else {
			pos = VS_K_FILE_CANCELED ;
			ex$putque( msg = &msg, response = &pos ) ;
		}
		FIf_delete( form ) ;
		listFiles = FALSE ;
		break ;

	case FI_ACCEPT		:

		if( f = VSopenFile( &msg, info->pathName, info->openMode ) ) {

			fclose( f ) ;
			if( info->callBack ) {
				info->callBack( info->parentForm, VS_K_FILE_ACCEPTED ) ;
			} else {
				pos = VS_K_FILE_ACCEPTED ;
				ex$putque( msg = &msg, response= &pos ) ;
			}
			FIf_delete( form ) ;
			listFiles = FALSE ;
		} else {
			VSfi_msgkey( form, VSgetMsgKey( msg ) ) ;
			FIg_set_state_off( form, FI_ACCEPT ) ;
		}
		break ;

	case VS_K_DIR_FIELD	:
		FIfld_get_text( form, VS_K_DIR_FIELD , 0, 0, MAXPATHLEN+1,
				(unsigned char *) info->curPATH, &sel, &pos ) ;
		if( !VSisReadableUNIXDir( info->curPATH ) ) {
			VSfi_msgkey( form, VS_gW_NoSuchDir ) ;
			strcpy( info->curPATH, "." ) ;
			FIfld_set_text( form, VS_K_DIR_FIELD, 0, 0,
						info->curPATH, FALSE ) ;
		}
		listFiles = TRUE ;
		break ;

	case VS_K_FILE_FIELD	:
		FIfld_get_text( form, VS_K_FILE_FIELD, 0, 0, FILENAME_MAX+1,
				(unsigned char *) info->curNAME, &sel, &pos ) ;
		sprintf( info->pathName, "%s/%s", info->curPATH, info->curNAME ) ;

		if ( info->curNAME[0] && info->openMode[0] == 'w' && 
		     !access(info->pathName, F_OK) )
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
				  "Warning : File Exists", FALSE );
		else
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0, "", FALSE ) ;
		break ;

	case VS_K_FILT_FIELD	:
		FIfld_get_text( form, VS_K_FILT_FIELD , 0, 0, VS_K_MAX_RGXP,
				(unsigned char *) info->curRGXP, &sel, &pos ) ;
		if( !VSmatchRE( info->curRGXP, NULL ) ) {
			/* Invalid regular expression */
			VSfi_msgkey( form, VS_gW_InvRegExp ) ;
			strcpy( info->curRGXP, "*" ) ;
			FIfld_set_text( form, VS_K_FILT_FIELD, 0, 0,
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

			VSls( &msg, info->curPATH, info->curRGXP, VSisASCIIFile,
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
				VSstrcmpByPtrs ) ;
			}
			VSfld_set_list( form, VS_K_FILE_FIELD, count, list ) ;
			if( count ) {
				if( !ptr ) ptr = list[0] ;
				FIfld_set_text( form, VS_K_FILE_FIELD, 0, 0,
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
				FIfld_set_text( form, VS_K_FILE_FIELD, 0, 0,
						"", FALSE ) ;
			}
#undef MAX
	}


	return FI_SUCCESS ;

} /* VSfileFormNotification */
/*----------------------------------------------------------------------------*/
char *VScreateFileForm( x, y, info ) int x, y ; VSfileFormInfo *info ; {

	int	rc ;
	char	*form = NULL ;
	long	msg ;

	rc = FIf_new( 1, VS_K_FILE_FORM, VSfileFormNotification, &form ) ;

	if( FI_SUCCESS == rc ) {
		sprintf( info->pathName, "%s/%s", info->curPATH, info->curNAME ) ;

		FIf_set_user_pointer( form, (char *) info ) ;
		FIf_set_location( form, x, y ) ;
		FIf_set_collapse_location( form, x, y ) ;

		FIfld_set_text( form, VS_K_DIR_FIELD , 0, 0, info->curPATH, FALSE ) ;
		FIfld_set_text( form, VS_K_FILE_FIELD, 0, 0, info->curNAME, FALSE ) ;
		FIfld_set_text( form, VS_K_FILT_FIELD, 0, 0, info->curRGXP, FALSE ) ;

		if(info->openMode[0] == 'w')
		  FIg_set_text( form, VS_K_FORM_TITLE, "Write to file");
		else if(info->openMode[0] == 'r')
		  FIg_set_text( form, VS_K_FORM_TITLE, "Read from file");
		else if(info->openMode[0] == 'a')
		  FIg_set_text( form, VS_K_FORM_TITLE, "Append to file");

		if ( info->curNAME[0] && info->openMode[0] == 'w' && 
		     !access(info->pathName, F_OK) )
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
				  "Warning : File Exists", FALSE );
		else
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0, "", FALSE ) ;
/*
		FIfld_pos_cursor( form, VS_K_DIR_FIELD, 0, 0, 0, 0, 0, 0 ) ;
		FIf_set_start_seq( form, VS_K_DIR_FIELD ) ;
*/
		FIf_display( form ) ;
	 {
			int		count	= 0 ;
			FILENAME	*files	= NULL ;
			int		i ;
#define MAX 100
			char		*list[MAX] ;
			char		*ptr ;

			VSls( &msg, info->curPATH, info->curRGXP, VSisASCIIFile,
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
				VSstrcmpByPtrs ) ;
			}
			VSfld_set_list( form, VS_K_FILE_FIELD, count, list ) ;
			if ( count ) _FREE( files ) ;
#undef MAX
	 }
	} else	form = NULL ;

	return form ;

} /* VScreateFileForm */
/*----------------------------------------------------------------------------*/
