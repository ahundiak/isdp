/* $Id: VSdfltvalsfm.C,v 1.1.1.1 2001/01/04 21:10:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vsio/VSdfltvalsfm.C
 *
 * Description:
 *		Default form functions
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdfltvalsfm.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.5  1996/03/04  08:46:02  pinnacle
 * Replaced: vsio/VSdfltvalsfm.C for:  by msbraju for struct
 *
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "standards.h"
#include <sys/param.h>
#define FALSE 0
#define TRUE  1
#include <FI.h>
#include "vscmddef.h"
#include "vscmd.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "vsglobalmsg.h"
/*
 * Includes of function prototypes
 */
#include "VX_FIproto.h"
#include "vsdefltvalue.h"
#include "vsdfltvalsfm.h"
#include "vsformproto.h"
#include "vsioproto.h"

#define VS_K_DFLTVALS_FORM	"VSdflValues.fm"
/*
 * Gadget labels on form `VS_K_DFLTVALS_FORM'.
 */
#define VS_K_DFLFL_FLD	11	/* Fld: to enter file name		*/
#define VS_K_DFLTS_MCF	13	/* Mcf: names + values			*/
#define VS_K_DFLVL_FLD	16	/* Fld: possible values for one name	*/
#define VS_K_SRCHF_BTN	17	/* Btn: to invoke file-search form	*/
#define VS_K_VLCHC_TXT	18	/* Txt: title of choice for values	*/

/*
 * Column # in MCF 'VS_K_DFLTS_MCF'
 */
#define NAMES_COLUMN	0
#define VALUES_COLUMN	1

static int VSdfltValsFormNotification(
			int formLabel, int gadget, double value, char *pForm ) ;
/*----------------------------------------------------------------------------*/
void VSdeleteDftlValsForm( char *pForm ) {

  VSdfltValsInfo	*info ;

  FIf_get_user_pointer( pForm, (char **) &info ) ;

  if( info->fileForm ) {
    FIf_delete( info->fileForm ) ;
    info->fileForm = NULL ;
  }
  FIf_delete( pForm ) ;

} /* VSdeleteDftlValsForm */
/*----------------------------------------------------------------------------*/
static void VSdfltValsFormCallBack( char *form, int exitType ) {

	/* This is the call-back from the form created by `VScreateFileForm'
	 * called when its Abort or Dismiss-Execute button has been pressed.
	 * `info->fileInfo->curPATH' & `info->fileInfo->curNAME' may have
	 * been updated by this form.
	 */
	 VSdfltValsInfo	*info ;
	 FIf_get_user_pointer( form, (char **) &info ) ;

	switch( exitType ) {

	  case VS_K_FILE_ACCEPTED : {
	      char	pathName[MAXPATHLEN+1] ;
	      int	label ;
	      sprintf( pathName, "%s/%s", info->fileInfo.curPATH,
					  info->fileInfo.curNAME ) ;
	      FIfld_set_text( form, VS_K_DFLFL_FLD, 0, 0, pathName, FALSE ) ;
	      /*
	       * Fake an event in form's field to provoke the
	       * execution of the action associated with it.
	       */
	      FIf_get_label( form, &label ) ;
	      VSdfltValsFormNotification( label, VS_K_DFLFL_FLD, 0., form ) ;
            }
	    break ;

	  case VS_K_FILE_CANCELED :
	    break ;
	}
	/*
         * Re-enable all gadgets in Default Values form.
         */
	VDgrp_callback(	form, FI_FORM_GROUP, (void (*)()) FIg_enable, NULL ) ;

	/*
         * Zero out pointer to 'Input File Name' form, since it has been
	 * deleted when its Abort or Dismiss-Execute button was pressed.
         */
	info->fileForm = NULL ;

} /* VSdfltValsFormCallBack */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VSdfltValsFormNotification(
			int formLabel, int gadget, double value, char *pForm ) {

  VSdfltValsInfo	*info ;

  FIf_get_user_pointer( pForm, (char **) &info ) ;

  switch( gadget ) {

    case FI_RESET  :
      info->callBack( pForm, info->parentForm, gadget ) ;
      break ;

    case FI_CANCEL :
    case FI_ACCEPT :
      info->callBack( pForm, info->parentForm, gadget ) ;
      VSdeleteDftlValsForm( pForm ) ;
      break ;

    case VS_K_DFLFL_FLD	: {
        unsigned char	pathName[MAXPATHLEN+1] ;
        char		*ptr ;
        long		msg ;
        int             sel, pos ;
	FILE		*f = NULL ;

        FIfld_get_text( pForm, gadget, 0, 0, MAXPATHLEN+1, pathName, &sel, &pos );

        if( ptr = strrchr( (char *) pathName, '/' ) ) {
          *ptr = '\0' ;
          strcpy( info->fileInfo.curPATH, (char *) pathName ) ;
          strcpy( info->fileInfo.curNAME, ptr + 1 ) ;
          *ptr = '/' ;
        } else {
          strcpy( info->fileInfo.curPATH, "." ) ;
          strcpy( info->fileInfo.curNAME, (char *) pathName ) ;
        }

        if( f = VSopenFile( &msg, (char *) pathName, "r" ) ) {
          int             i ;
	  VSdefaultValues *dflts = info->defaultValues ;
 	  char            text[MS_MAX_MSG_LENGTH+1] ;

          info->numDefaults = VSreadDefaultValues( f, info->maxNumDefaults, dflts ) ;
          FIfld_set_num_rows( pForm, VS_K_DFLTS_MCF, info->numDefaults ) ;

          for( i = 0 ; i < info->numDefaults ; i++ ) {
            FIfld_set_text( pForm, VS_K_DFLTS_MCF, i, NAMES_COLUMN,
			    dflts[i].attrName, FALSE ) ;
	    if( !dflts[i].count ) {
	       strcpy( dflts[i].attrValues[0], "?" ) ;
	       dflts[i].count = 1 ;
	    }
	    FIfld_set_text( pForm, VS_K_DFLTS_MCF, i, VALUES_COLUMN,
			    dflts[i].attrValues[0], FALSE ) ;
          }
          fclose( f ) ;
          ex$message( msgnumb = VS_gI_n_AttributesFound,
		      type    = "%d",
		      var     = `info->numDefaults`,
		      buff    = text ) ;
          VSfi_msg( pForm, text ) ;
        } else {
          VSfi_msgkey( pForm, VSgetMsgKey( msg ) ) ;
        }
      }
      break ;

    case VS_K_DFLTS_MCF	: {
        VSdefaultValues	*dflts = info->defaultValues ;
 	char		text[MS_MAX_MSG_LENGTH+1] ;
	int		row = (int) value ;
	int		i ;
	int		checkNumber = FALSE ;

	switch( info->numDefaultsWanted ) {
	  default : checkNumber = TRUE ; /* No break intentionally */
	  case -1 : { /* No limit */
              int col, pos ;
              FImcf_get_active_col( pForm, gadget, &col, &pos ) ;
 
              if( NAMES_COLUMN == col ) {
                /*
                 * If selected, de-select ; if not selected, select.
                 */
                int sel ;
                int pos = dflts[row].curVal ;
                if( pos < 0 ) pos = -pos ;
                FIfld_get_select( pForm, gadget, row, col, &sel ) ;
                if( sel && checkNumber ) {
                  int nbSelected = 0 ;
                  for( i = 0 ; i < info->numDefaults ; i++ ) {
                     if( dflts[i].curVal > 0 ) nbSelected++ ;
                  }
                  if( nbSelected >= info->numDefaultsWanted ) {
                    VSfi_prompt( pForm, "All selected: deselect before reselecting" ) ;
                    FIfld_set_select( pForm, gadget, row, col, FALSE ) ;
                  } else {
                    dflts[row].curVal = sel ? pos : - pos ;
                    info->currentDefault = row ;
                    VSfi_prompt( pForm, "" ) ;
                  }
                } else {
                  dflts[row].curVal = sel ? pos : - pos ;
                  info->currentDefault = row ;
                  VSfi_prompt( pForm, "" ) ;
                }
              }
            }
            break ;
	  case  1 :
	      info->currentDefault = row ;
	      break ;
        }			
        /*
         * Propose all possible values for this default.
         */
        FIfld_set_num_rows( pForm, VS_K_DFLVL_FLD, dflts[row].count ) ;
        for( i = 0 ; i < dflts[row].count ; i++ ) {
	  FIfld_set_text( pForm, VS_K_DFLVL_FLD, i, 0,
				  dflts[row].attrValues[i], FALSE ) ;
        }
        ex$message( msgnumb = VS_gI_n_ValuesForAttr,
		    type    = "%d%s",
		    var     = `dflts[row].count, dflts[row].attrName`,
		    buff    = text ) ;
        VSfi_msg( pForm, text ) ;
        ex$message( msgnumb = VS_gI_ChoicesFor,
		    type    = "%s",
		    var     = `dflts[row].attrName`,
		    buff    = text ) ;
        FIg_set_text( pForm, VS_K_VLCHC_TXT, text ) ;
      }
      break ;

    case VS_K_DFLVL_FLD	: {
        int             row    = (int) value ;
	int		sel ;
	int		pos ;
        VSdefaultValues	*dflts = info->defaultValues ;
        /*
         * Set this value as the current value for attribute #row.
         */
        sel = dflts[info->currentDefault].curVal > 0 ;
        FIfld_set_text(	pForm, VS_K_DFLTS_MCF, info->currentDefault,
		        VALUES_COLUMN,
                        dflts[info->currentDefault].attrValues[row], FALSE );
	pos = row + 1 ;
        dflts[info->currentDefault].curVal = sel ? pos : - pos ;
     }
     break ;

   case VS_K_SRCHF_BTN : {
       int x, y ;
       strcpy( info->fileInfo.openMode, "r" ) ;
       info->fileInfo.callBack   = VSdfltValsFormCallBack ;
       info->fileInfo.parentForm = pForm ;
       FIf_get_location( pForm, &x, &y ) ;
       info->fileForm = VScreateFileForm( x, y, &info->fileInfo ) ;
       FIg_set_state_off( pForm, gadget ) ;
       /*
        * Disable all gadgets on the Default Values form.
        */
       if( info->fileForm ) {
         VDgrp_callback( pForm, FI_FORM_GROUP, (void (*)()) FIg_disable, NULL );
       }
    }
    break ;
  }
  return FI_SUCCESS ;

} /* VSdfltValsFormNotification */
/*----------------------------------------------------------------------------*/
char *VScreateDefaultValuesForm( int x, int y, VSdfltValsInfo *info ) {

  int rc ;
  char *pForm = NULL ;

  rc = FIf_new( 15352, VS_K_DFLTVALS_FORM, VSdfltValsFormNotification, &pForm ) ;
  if( FI_SUCCESS == rc ) {

    info->numDefaults = 0 ;
    /*
     * Zero out pointer to 'Input File Name' form.
     */
    info->fileForm = NULL ;
    /*
     * Propose a default pathname for file to read.
     */
    sprintf( info->fileInfo.pathName, "%s/%s",
             info->fileInfo.curPATH, info->fileInfo.curNAME ) ;
    FIfld_set_text( pForm, VS_K_DFLFL_FLD, 0, 0, info->fileInfo.pathName, FALSE ) ;
    VSfi_msgkey( pForm, VS_gI_HitCRToReadFile ) ;

    /*
     * Adjust form's location, store information and display.
     */
    FIf_set_location( pForm, x, y ) ;
    FIf_set_collapse_location( pForm, x, y ) ;
    FIf_set_user_pointer( pForm, (char *) info ) ;

    if( 1 == info->numDefaultsWanted ) {
      FIfld_set_mode( pForm, VS_K_DFLTS_MCF, 0, FI_SINGLE_SELECT ) ;
    }
    FIf_display( pForm ) ;

  } else pForm = NULL ;

  return pForm ;

} /* VScreateDefaultValuesForm */
/*----------------------------------------------------------------------------*/
void VSexplainDefaultValuesForm( char *pForm, int label ) {
	long m ;
        switch( label ) {
      	  case VS_K_DFLFL_FLD : m = VS_gI_KyInFileForAttrs ; break ;
      	  case VS_K_SRCHF_BTN : m = VS_gI_SearchForFile    ; break ;
      	  case VS_K_DFLTS_MCF : m = VS_gI_SelAttrToKeep    ; break ;
      	  case VS_K_DFLVL_FLD : m = VS_gI_PickValForAttr   ; break ;
      	  default	      : m = VS_gI_EmptyMessage     ; break ;
        }
        VSfi_prompt( pForm, VSmsgkey2string( m ) ) ;

} /* VSexplainDefaultValuesForm */
/*----------------------------------------------------------------------------*/

