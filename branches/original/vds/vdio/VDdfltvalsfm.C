/* $Id: VDdfltvalsfm.C,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdio/VDdfltvalsfm.C
 *
 * Purpose:    
 *		Default form functions ("default" refers to user attributes
 *		read from an ascii file)
 * Description: 
 *		These functions handle the creation and manipulation of the
 *		subform brought up when the "Read from file" button is 
 *		selected on the parent form. VDdflValues.fm appears like this:
 *
 *		     ---------------------
 *		File _____________________        | Search |
 *
 *		Name            Value             Choices
 *
 *		-------------------------- _____  ------------
 *		|         |  |           | || ||  |          |
 *		|         |  |           | || ||  |          |
 *		|         |  |           | || ||  |          |
 *		|         |  |           | ||_||  |          |
 *		|         |  |           | ||-||  |          |
 *		|         |  |           | ||_||  |          |
 *		-------------------------- -----  ------------
 *
 *		----------------------------------------------
 *		----------------------------------------------
 *
 *		The attribute type, either "txt" or "dbl" is automatically
 *		determined and entered between the name and value columns.
 *
 * History:
 *   MM/DD/YY   AUTHOR  DESCRIPTION
 *   06/10/97	EJM	CR#179527294  Add "Read from File" capability
 *				
 *			This file adapted from Struct file of same name
 *			in struct/vsio. Default refers to ascii file 
 *			input data, namely, attribute names and their
 *			values. The no-title subform, VDdflValues.fm,
 *			collects these values and passes them on to it's 
 *			parent form, VDmodUsrAtt, into the New 
 *			Attributes multi-column field. If help is needed
 *			to search for the ascii file, the subform,
 *			VDKyInFilNm.fm, is called from VDdflValues.fm. 
 *
 *   07/25/97	EJM	CR#179602470  Add "Copy Attributes" capability
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "standards.h"
#include <sys/param.h>
#define FALSE 0
#define TRUE  1
#include <FI.h>
#include "v_cmd.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "v_globalmsg.h"
#include "v_getmsgkey.h"
#include "VDmsg.h"
#include "VDCmdDef.h"       /* defines VD_FORM_CANCEL */
#include "exdef.h"
#include "exmacros.h"       /* defines ex$putque      */

/*
 * Includes of function prototypes
 */
#include "VX_FIproto.h"

#include "vddefltvalue.h"       /* struct VDdefaultValues */
#include "vddfltvalsfm.h"       /* struct VDdfltValsInfo, gadget labels */
#include "VDusrAtt.h"           /* defines VD_K_COPY_ATTRS_BTN */

#include "v_ioproto.h"

/* From vscmddef.h */
#define VD_K_FILE_ACCEPTED      260
#define VD_K_FILE_CANCELED      261

/* subform with Name Value Choices fields filled in from ascii file */
#define VD_K_DFLTVALS_FORM	"VDdflValues.fm"


static int VDdfltValsFormNotification(
			int formLabel, int gadget, double value, char *pForm ) ;

/*----------------------------------------------------------------------------*/
void VDdeleteDftlValsForm( char *pForm ) {

  VDdfltValsInfo	*info ;


  FIf_get_user_pointer( pForm, (char **) &info ) ;

  if( info->fileForm ) {
    FIf_delete( info->fileForm ) ;
    info->fileForm = NULL ;
  }
/*  delete needs to be fixed in EMS because it causes a crash on Solaris */
/*  FIf_delete( pForm ) ; */
    FIf_erase ( pForm ) ;

} /* VDdeleteDftlValsForm */
/*----------------------------------------------------------------------------*/
static void VDdfltValsFormCallBack( char *form, int exitType ) {

	/* This is the call-back from the form created by `VDcreateFileForm'
	 * called when its Abort or Dismiss-Execute button has been pressed.
	 * `info->fileInfo->curPATH' & `info->fileInfo->curNAME' may have
	 * been updated by this form.
	 */
	 VDdfltValsInfo	*info ;
	 FIf_get_user_pointer( form, (char **) &info ) ;

	switch( exitType ) {

	  case VD_K_FILE_ACCEPTED : {
	      char	pathName[MAXPATHLEN+1] ;
	      int	label ;
	      sprintf( pathName, "%s/%s", info->fileInfo.curPATH,
					  info->fileInfo.curNAME ) ;
	      FIfld_set_text( form, VD_K_DFLFL_FLD, 0, 0, pathName, FALSE ) ;
	      /*
	       * Fake an event in form's field to provoke the
	       * execution of the action associated with it.
	       */
	      FIf_get_label( form, &label ) ;
	      VDdfltValsFormNotification( label, VD_K_DFLFL_FLD, 0., form ) ;
            }
	    break ;

	  case VD_K_FILE_CANCELED :
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

} /* VDdfltValsFormCallBack */

/*-----------------------------------------------------------------------------
 * Handles subform gadget selection
 */

/*ARGSUSED*/
#argsused
static int VDdfltValsFormNotification(
			int formLabel, int gadget, double value, char *pForm ) {

  VDdfltValsInfo	*info ;

  FIf_get_user_pointer( pForm, (char **) &info ) ;

  switch( gadget ) {

    case FI_RESET  :
      info->callBack( pForm, info->parentForm, gadget ) ;
      break ;

    case FI_CANCEL : {
      int resp;
      long msg;

      info->callBack( pForm, info->parentForm, gadget ) ;
      VDdeleteDftlValsForm( pForm ) ;   /* cleanUp */
/*    _put_response( resp=VD_FORM_CANCEL );  * go back to state getAttr */
      resp = VD_FORM_CANCEL;
      ex$putque( msg = &msg, response = &resp );
      break ;
      }

    case FI_ACCEPT :
      info->callBack( pForm, info->parentForm, gadget ) ;
      VDdeleteDftlValsForm( pForm ) ;   /* cleanUp */
      break ;

    case VD_K_DFLFL_FLD	: {
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

        if( f = VD_openFile( &msg, (char *) pathName, "r" ) ) {
          int             i ;
	  VDdefaultValues *dflts = info->defaultValues ;
 	  char            text[MS_MAX_MSG_LENGTH+1] ;

          info->numDefaults = VDreadDefaultValues( f, info->maxNumDefaults, dflts ) ;
          FIfld_set_num_rows( pForm, VD_K_DFLTS_MCF, info->numDefaults ) ;

          for( i = 0 ; i < info->numDefaults ; i++ ) {
            FIfld_set_text( pForm, VD_K_DFLTS_MCF, i, NAMES_COLUMN,
			    dflts[i].attrName, FALSE ) ;
	    if( !dflts[i].count ) {
	       strcpy( dflts[i].attrValues[0], "?" ) ;
	       dflts[i].count = 1 ;
	    }
	    FIfld_set_text( pForm, VD_K_DFLTS_MCF, i, VALUES_COLUMN,
			    dflts[i].attrValues[0], FALSE ) ;
          }
          fclose( f ) ;
          ex$message( msgnumb = VD_I_AttributesFound,
		      type    = "%d",
		      var     = `info->numDefaults`,
		      buff    = text ) ;
          VDfi_msg( pForm, text ) ;
        } else {
          /* VDfi_msgkey( pForm, VD_getMsgKey( msg ) ) ; */
          VDfi_msgkey( pForm, VD_I_EmptyMessage ) ;     /* was VD_gI */
        }
      }
      break ;  /* process returns to top of this module */

    case VD_K_DFLTS_MCF	: {
        VDdefaultValues	*dflts = info->defaultValues ;
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

		/* curVal of 1 = selected,  curVal of -1 = not selected */

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
                    VDfi_prompt( pForm, "All selected: deselect before reselecting" ) ;
                    FIfld_set_select( pForm, gadget, row, col, FALSE ) ;
                  } else {
                    dflts[row].curVal = sel ? pos : - pos ;
                    info->currentDefault = row ;
                    VDfi_prompt( pForm, "" ) ;
                  }
                } else {
                  dflts[row].curVal = sel ? pos : - pos ;
                  info->currentDefault = row ;
                  VDfi_prompt( pForm, "" ) ;
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
        FIfld_set_num_rows( pForm, VD_K_DFLVL_FLD, dflts[row].count ) ;
        for( i = 0 ; i < dflts[row].count ; i++ ) {
	  FIfld_set_text( pForm, VD_K_DFLVL_FLD, i, 0,
				  dflts[row].attrValues[i], FALSE ) ;
        }
        if( dflts[row].count != 0 ) {
          /* Don't want these messages for Copy Attributes button */
          ex$message( msgnumb = VD_I_ValuesForAttr,
		      type    = "%d%s",
		      var     = `dflts[row].count, dflts[row].attrName`,
		      buff    = text ) ;
          VDfi_msg( pForm, text ) ;
          ex$message( msgnumb = VD_I_ChoicesFor,
		      type    = "%s",
		      var     = `dflts[row].attrName`,
		      buff    = text ) ;
          FIg_set_text( pForm, VD_K_VLCHC_TXT, text ) ;
        }
      }
      break ;

    case VD_K_DFLVL_FLD	: {
        int             row    = (int) value ;
	int		sel ;
	int		pos ;
        VDdefaultValues	*dflts = info->defaultValues ;
        /*
         * Set this value as the current value for attribute #row.
         */
        sel = dflts[info->currentDefault].curVal > 0 ;
        FIfld_set_text(	pForm, VD_K_DFLTS_MCF, info->currentDefault,
		        VALUES_COLUMN,
                        dflts[info->currentDefault].attrValues[row], FALSE );
	pos = row + 1 ;
        dflts[info->currentDefault].curVal = sel ? pos : - pos ;
     }
     break ;

   case VD_K_SELCT_BTN : {
	int	nbRows, i;
        VDdefaultValues	*dflts = info->defaultValues ;

	FIfld_get_num_rows( pForm, VD_K_DFLTS_MCF, &nbRows );
	for( i = 0 ; i < nbRows ; i++ ) {

	  /* highlights */
	  FIfld_set_select( pForm, VD_K_DFLTS_MCF, i, 0, TRUE );

          dflts[i].curVal = 1; /* 1 = attribute (row) selected */

          /* curVal is checked under case FI_ACCEPT in VDmodAttrCallBack, */
          /* which will set text in New Attributes field of parent form.  */
          }
     }
     break ;


   case VD_K_UNSEL_BTN : {
	int	nbRows, i;
        VDdefaultValues	*dflts = info->defaultValues ;

	FIfld_get_num_rows( pForm, VD_K_DFLTS_MCF, &nbRows );
	for( i = 0 ; i < nbRows ; i++ ) {
	  FIfld_set_select( pForm, VD_K_DFLTS_MCF, i, 0, FALSE );
          dflts[i].curVal = -1; /* -1 = attribute (row) unselected */
        }
     }
     break ;


   case VD_K_SRCHF_BTN : {
       int x, y ;
       strcpy( info->fileInfo.openMode, "r" ) ;
       info->fileInfo.callBack   = VDdfltValsFormCallBack ;
       info->fileInfo.parentForm = pForm ;
       FIf_get_location( pForm, &x, &y ) ;
       info->fileForm = VDcreateFileForm( x, y, &info->fileInfo ) ;
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

} /* VDdfltValsFormNotification */

/*----------------------------------------------------------------------------
 *
 *  Create subform to handle input from ascii file, namely, Name, Value, 
 *  Choices.
 */

char *VDcreateDefaultValuesForm( int x, int y, VDdfltValsInfo *info, int gLabel ) {

  int rc ;
  char *pForm = NULL ;

  rc = FIf_new( 15352, VD_K_DFLTVALS_FORM, VDdfltValsFormNotification, &pForm ) ;
  if( FI_SUCCESS == rc ) {

    info->numDefaults = 0 ;
    /*
     * Zero out pointer to 'Input File Name' form.
     */
    info->fileForm = NULL ;

    if( gLabel == VD_K_COPY_ATTRS_BTN )
    {
      /* Erase filename,choices fields, labels, search button */

      FIg_erase( pForm, VD_K_DFLFL_FLD );
      FIg_erase( pForm, VD_K_DFLFL_TTL );
      FIg_erase( pForm, VD_K_SRCHF_BTN );
      FIg_erase( pForm, VD_K_VLCHC_TXT );
      FIg_erase( pForm, VD_K_DFLVL_FLD );

      FIg_disable(  pForm, VD_K_RESET_BTN );
      FIg_erase   ( pForm, VD_K_DFL_TITLE );
      FIg_set_text( pForm, VD_K_DFL_TITLE, "Copy User Attributes" );
      FIg_display ( pForm, VD_K_DFL_TITLE );
      FIg_display ( pForm, VD_K_SELCT_BTN );
      FIg_display ( pForm, VD_K_UNSEL_BTN );

      VDfi_msgkey ( pForm, VD_I_SelObjToGetAttr );
    }
    else
    {
      FIg_erase   ( pForm, VD_K_DFL_TITLE );
      FIg_set_text( pForm, VD_K_DFL_TITLE, "Read User Attributes" );
      FIg_display ( pForm, VD_K_DFL_TITLE );


      /*
       * Propose a default pathname for file to read.
       */
      sprintf( info->fileInfo.pathName, "%s/%s",
               info->fileInfo.curPATH, info->fileInfo.curNAME ) ;
      FIfld_set_text( pForm, VD_K_DFLFL_FLD, 0, 0, info->fileInfo.pathName, FALSE ) ;
      VDfi_msgkey( pForm, VD_I_HitCRToReadFile ) ;
    }

    /*
     * Adjust form's location, store information and display.
     */
    FIf_set_location( pForm, x, y ) ;
    FIf_set_collapse_location( pForm, x, y ) ;
    FIf_set_user_pointer( pForm, (char *) info ) ;

    if( 1 == info->numDefaultsWanted ) {
      FIfld_set_mode( pForm, VD_K_DFLTS_MCF, 0, FI_SINGLE_SELECT ) ;
    }
    FIf_display( pForm ) ;

  } else pForm = NULL ;

  return pForm ;

} /* VDcreateDefaultValuesForm */
/*----------------------------------------------------------------------------*/
void VDexplainDefaultValuesForm( char *pForm, int label ) {
	long m ;
        switch( label ) {
      	  case VD_K_DFLFL_FLD : m = VD_I_KyInFileForAttrs ; break ;
      	  case VD_K_SRCHF_BTN : m = VD_I_SearchForFile    ; break ;
      	  case VD_K_DFLTS_MCF : m = VD_I_SelAttrToKeep    ; break ;
      	  case VD_K_DFLVL_FLD : m = VD_I_PickValForAttr   ; break ;
      	  default	      : m = VD_I_EmptyMessage     ; break ;
        }
        VDfi_prompt( pForm, VDmsgkey2string( m ) ) ;

} /* VDexplainDefaultValuesForm */
/*----------------------------------------------------------------------------*/

