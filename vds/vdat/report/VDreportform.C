/* $Id: VDreportform.C,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdat/report/VDreportform.C
 *
 * Description:
 *	This file contains routines to control the interaction with the 
 *	reporting forms.
 *
 * Dependencies:
 *	Class 	VDCmdReport.
 *
 * Revision History:
 *	$Log: VDreportform.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  2000/02/03  21:36:32  pinnacle
 * Replaced: vdat/report/VDreportform.C for:  by impd252 for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/12/31  13:47:44  pinnacle
 * Moved from vdastree
 *
 * Revision 1.2  1997/12/05  09:27:44  pinnacle
 * Replaced: vdastree/report/VDreportform.C for:  by ksundar for vds
 *
 * Revision 1.1  1997/11/04  17:42:02  pinnacle
 * Created: vdastree/report/VDreportform.C by v250_int for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/24/97	adz		creation date
 *	12/30/97	ah		moved to vdat
 *  02/03/00    adz     CR179900809 Add -S option into process.
 ***************************************************************************/

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
#include "v_cmddef.h"
#include "v_globalmsg.h"
#include "exdef.h"
#include "exmacros.h"
#include "vdsmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes
 */
#include "VX_FIproto.h"
#include "v_getmsgkey.h"
#include "v_ioproto.h"      /* VDrp_createFileForm */
#include "v_strngproto.h"
#include "VDmem.h"
#include "VDmsg.h"

/*
 * FORM GADGETS.
 */
#define VD_K_FILE_FORM "VDGenReport"
#define VD_K_DIR_FIELD	12
#define VD_K_FILE_FIELD	14
#define VD_K_FILT_FIELD 15
#define VD_K_FORM_TITLE 17
#define VD_K_REP_FIELD  19
#define VD_K_REPF_FIELD 21
#define VD_K_TITLE_FIELD 22

typedef char	FILENAME[1+FILENAME_MAX] ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VDrp_fileFormNotification( form_label, gadget, value, form )

int	form_label,
	gadget ;
IGRdouble	value ;
char	*form ; {

	VD_fileFormInfo	*info ;
	IGRchar firstDir[FILENAME_MAX],
			thenDir[FILENAME_MAX],
			absPath[FILENAME_MAX],
			relPath[FILENAME_MAX];
	int		sel,
			pos ;
	FILE		*f = NULL ;
	long		msg ;
	int		listFiles = FALSE ,
			listReports = FALSE ;

	SetProc( VDrp_fileFormNotification ); Begin 

	FIf_get_user_pointer( form, (char **) &info ) ;

	__DBGpr_int(" Gadget " , gadget );

	switch( gadget ) {

	case FI_CANCEL		:
		*info->pathName = '\0' ;
		if( info->callBack ) {
			info->callBack( info->parentForm, VD_K_FILE_CANCELED ) ;
		} else {
			pos = VD_K_FILE_CANCELED ;
			ex$putque( msg = &msg, response = &pos ) ;
		}

		FIg_set_state_off( form, FI_CANCEL ) ;
		FIf_delete( form ) ;
		break ;

	case FI_ACCEPT		:

		/*
		 * check if the report input file exist.
		 */
		FIfld_get_text( form, VD_K_REP_FIELD, 0, 0, FILENAME_MAX+1,
				(unsigned char *) info->repNAME, &sel, &pos ) ;

		__DBGpr_str(" Report File", info->repNAME );

		strcpy( firstDir, "." );
		strcpy( thenDir, "config/reports" );
		strcpy( relPath, info->repNAME ); 

	    VD_findFileInDirOrProductPaths( &msg, relPath, firstDir, thenDir,
											absPath );
	    __DBGpr_str(" Report Path", absPath );

		if( msg & 1 ){
			/*
			 * Path found 
			 */
			FIg_set_state_off( form, FI_ACCEPT ) ;
		}

		/*
		 * Check of the Output File will be accepted.
		 */
		__DBGpr_str(" Output File", info->pathName );

		if( f = VD_openFile( &msg, info->pathName, info->openMode ) ) {

			fclose( f ) ;
			if( info->callBack ) {
				info->callBack( info->parentForm,
						VD_K_FILE_ACCEPTED ) ;
			} else {
				pos = VD_K_FILE_ACCEPTED ;
				ex$putque( msg = &msg, response= &pos ) ;
			}
			FIf_delete( form ) ;
		} else {
			FIg_set_state_off( form, FI_ACCEPT ) ;
		}
		break ;

	case VD_K_DIR_FIELD	:
		FIfld_get_text( form, VD_K_DIR_FIELD , 0, 0, MAXPATHLEN+1,
				(unsigned char *) info->curPATH, &sel, &pos ) ;
		if( !VD_isReadableUNIXDir( info->curPATH ) ) {
			strcpy( info->curPATH, "." ) ;
			FIfld_set_text( form, VD_K_DIR_FIELD, 0, 0,
						info->curPATH, FALSE ) ;
		}
		listFiles = TRUE ;
		break ;

	case VD_K_FILE_FIELD	:
		FIfld_get_text( form, VD_K_FILE_FIELD, 0, 0, FILENAME_MAX+1,
				(unsigned char *) info->curNAME, &sel, &pos ) ;
		sprintf( info->pathName, "%s/%s", info->curPATH,info->curNAME);

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
			strcpy( info->curRGXP, "*" ) ;
			FIfld_set_text( form, VD_K_FILT_FIELD, 0, 0,
						info->curRGXP, FALSE ) ;
		}
		listFiles = TRUE ;
		break ;

	case VD_K_REP_FIELD	:
		FIfld_get_text( form, VD_K_REP_FIELD, 0, 0, FILENAME_MAX+1,
				(unsigned char *) info->repNAME, &sel, &pos ) ;

		strcpy( firstDir, "." );
		strcpy( thenDir, "config/reports" );
		strcpy( relPath, info->repNAME ); 

	    VD_findFileInDirOrProductPaths( &msg, relPath, firstDir, thenDir,
											absPath );
	    __DBGpr_str(" Report Path", absPath );

		if( msg & 1 ){
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0, "", FALSE ) ;
		}
		else{
		  FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
                                  "Warning : File doesn't exists", FALSE );
		}

		break ;

	case VD_K_REPF_FIELD	:
		FIfld_get_text( form, VD_K_FILT_FIELD , 0, 0, VD_K_MAX_RGXP,
				(unsigned char *) info->repRGXP, &sel, &pos ) ;
		if( !VD_matchRE( info->repRGXP, NULL ) ) {
			/* Invalid regular expression */
			strcpy( info->curRGXP, "*" ) ;
			FIfld_set_text( form, VD_K_FILT_FIELD, 0, 0,
						info->curRGXP, FALSE ) ;
		}
		listReports = TRUE ;
		break ;
	case VD_K_TITLE_FIELD	:
		FIfld_get_text( form, VD_K_TITLE_FIELD , 0, 0, MAXPATHLEN,
				(unsigned char *) info->repTITLE, &sel, &pos ) ;
		__DBGpr_str(" Report Title ", info->repTITLE );
		break ;

	default			:
		break ;
	}

	/*
	 * Generate the list of ASCII files for output reports
	 */
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
			qsort( list, count, sizeof *list, VD_strcmpByPtrs ) ;
		}
		VDfld_set_list( form, VD_K_FILE_FIELD, count, list ) ;
		if( count ) {
			if( !ptr ) ptr = list[0] ;
			FIfld_set_text( form, VD_K_FILE_FIELD, 0, 0,
						ptr, FALSE ) ;
			sprintf( info->pathName, "%s/%s", info->curPATH, ptr ) ;

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
	} /* listFiles */

	/*
	 * Generate the list of ASCII files for reports layout files.
	 */
	if( listReports ) {
		int		count	= 0 ;
		FILENAME	*files	= NULL ;
		int		i ;
#define MAX 100
		char		*list[MAX] ;
		char		*ptr ;

		VD_ls( &msg, info->curPATH, info->repRGXP, VD_isASCIIFile,
			&count, &files ) ;
		if( count > MAX ) count = MAX ;

		ptr = NULL ;
		for( i = 0 ; i < count ; i++ ) {
			list[i] = &files[i][0] ;
			if( !strcmp( list[i], info->repNAME ) ) {
				ptr = list[i] ;
			}
		}
		if( count > 1 ) {
			qsort( list, count, sizeof *list, VD_strcmpByPtrs ) ;
		}
		VDfld_set_list( form, VD_K_REP_FIELD, count, list ) ;
		if( count ) {
			if( !ptr ) ptr = list[0] ;
			FIfld_set_text( form, VD_K_REP_FIELD, 0,0,ptr,FALSE ) ;

			if ( vd$openfile(file_name	= ptr,
					product_name	= "Vds",
					sub_path	= "config/reports",
					cur_dir		= TRUE,
					p_file		= &f  )){
		  		fclose( f );
				FIfld_set_text( form, FI_MSG_FIELD, 0,
					0, "Warning : File Exists", FALSE );
			}
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

	End
	return FI_SUCCESS ;

} /* VDrp_fileFormNotification */
/*----------------------------------------------------------------------------*/
char *VDrp_createFileForm( x, y, info ) int x, y ; VD_fileFormInfo *info ; {

	int	rc ;
	char	*form = NULL ;
	long	msg ;

	SetProc( VDrp_createFileForm ); Begin

	rc = FIf_new( 1, VD_K_FILE_FORM, VDrp_fileFormNotification, &form ) ;

	if( FI_SUCCESS == rc ) {
		sprintf( info->pathName, "%s/%s", info->curPATH,
						  info->curNAME ) ;

		FIf_set_user_pointer( form, (char *) info ) ;
		FIf_set_location( form, x, y ) ;
		FIf_set_collapse_location( form, x, y ) ;

		FIfld_set_text(form,VD_K_DIR_FIELD ,0,0,info->curPATH,FALSE) ;
		FIfld_set_text(form,VD_K_FILE_FIELD,0,0,info->curNAME,FALSE) ;
		FIfld_set_text(form,VD_K_FILT_FIELD,0,0,info->curRGXP,FALSE) ;
		FIfld_set_text(form,VD_K_REP_FIELD ,0,0,info->repNAME,FALSE) ;
		FIfld_set_text(form,VD_K_REPF_FIELD,0,0,info->curRGXP,FALSE) ;
		FIfld_set_text(form,VD_K_TITLE_FIELD,0,0,info->repTITLE,FALSE) ;

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
			qsort( list, count, sizeof *list, VD_strcmpByPtrs ) ;
		}
		VDfld_set_list( form, VD_K_FILE_FIELD, count, list ) ;
		if ( count ) _FREE( files ) ;
#undef MAX
	 }

	/*
	 * Generate the list of ASCII files for reports layout files.
	 */
	 {
		int		count	= 0 ;
		FILENAME	*files	= NULL ;
		int		i ;
#define MAX 100
		char		*list[MAX] ;
		char		*ptr ;

		VD_ls( &msg, info->curPATH, info->repRGXP, VD_isASCIIFile,
			&count, &files ) ;
		if( count > MAX ) count = MAX ;

		ptr = NULL ;
		for( i = 0 ; i < count ; i++ ) {
			list[i] = &files[i][0] ;
			if( !strcmp( list[i], info->repNAME ) ) {
				ptr = list[i] ;
			}
		}
		if( count > 1 ) {
			qsort( list, count, sizeof *list, VD_strcmpByPtrs ) ;
		}
		VDfld_set_list( form, VD_K_REP_FIELD, count, list ) ;
		if( count ) _FREE( files ) ;
#undef MAX
	 }
	} else	form = NULL ;

	End
	return form ;

} /* VDrp_createFileForm */
/*----------------------------------------------------------------------------*/
