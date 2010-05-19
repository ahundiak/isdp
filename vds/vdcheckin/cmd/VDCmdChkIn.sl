/* $Id: VDCmdChkIn.sl,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/cmd / VDCmdChkIn.sl
 *
 * Description:
 *
 *   Algorithm for PME Batch Posting:
 *     1. Verify prevoius postings are successfully completed.
 *     2. If not display a message on the form that the old jobs are not 
 *        completed. Accept to continue or Cancel to exit the command.
 *     3. If user wants to continue i.e repost old data, posting uses 
 *        PMTransListSav.       
 *     4. if the previous postings are successfully completed, it uses
 *        PMTransList.
 *     5. If Batch toggle is selected - Pops up the form Batch Posting.
 *     6. The User may optionally specify the email address.
 *     7. The proceeds with the processing of the Transaction list or
 *        (either the PMtransListSav or PMtransList ) + Ascii file 
 *        generation.
 *     8. If the previous Batch posting completed successfully or new file
 *        copy current transaction list to transaction list sav.
 *        Delete the current transaction list after submitting the request
 *        to queue.
 *        if the previous posting in progress. If user wants to override 
 *        that Uses the PMTransListSav to generate Ascii file.
 *        If the previous posting is unsuuccessfull. Submit Ascii file
 *        with PMTransListSav. If PMTransListSav does not exist. Submit
 *        file with PMTransList and copy TransList to TransListSav.
 *        Delete the current TransList.
 *     9. Set the flag in Pmfile object as Batch job Submitted.
 *    10. Submit the job.
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdChkIn.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.10  1999/09/28  05:58:54  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by ssranade for vds
#
# Revision 1.9  1999/08/26  08:24:00  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by ssranade for vds
#
# Revision 1.8  1998/11/25  05:33:40  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by ssranade for vds
#
# Revision 1.7  1998/09/30  06:19:42  pinnacle
# TR #:179801711  
# commented ex$save_module
#
# Revision 1.6  1998/09/30  06:12:54  pinnacle
# TR #:179801711  

# commented ex$save_module
#
# Revision 1.5  1998/09/04  19:49:12  pinnacle
# Changed False to FALSE
#
# Revision 1.4  1998/08/19  11:21:22  pinnacle
# Removed a syntax error
#
# Revision 1.3  1998/08/11  09:38:18  pinnacle
# For SIR
#
# Revision 1.2  1998/08/07  08:31:00  pinnacle
# Modified form_notification to respect SIR
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.10  1997/02/20  22:49:32  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by lawaddel for vds.241
#
# Revision 1.9  1997/02/05  11:17:02  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by rgade for vds.241
#
# Revision 1.8  1996/10/18  14:08:10  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by msmanem for vds.241
#
# Revision 1.7  1996/10/06  04:41:10  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by msmanem for vds.241
#
# Revision 1.3  1996/03/09  17:13:34  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by msmanem for pmevds
#
# Revision 1.2  1996/03/07  20:24:48  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by msmanem for pmevds
#
# Revision 1.2  1995/08/07  21:19:08  pinnacle
# Replaced: vdcheckin/cmd/VDCmdChkIn.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/30/96        slj             Removed info for gadget 23. It is
 *                                      no longer being used. Ref TR#179601795.
 *      05/01/96        slj             Replaced free, malloc, calloc with
 *                                      vds memory calls.
 *      05/10/96        slj             Removed FIf_delete as it was causing
 *                                      a crash in solaris. Initialize several
 *                                      variables to NULL
 *      05/30/96        tlb             Replace VDS_CHECKIN_MODEL by REP_MODEL
 *	09/17/96	msm		Modified such that old form is displayed
 *					when PME is not enabled.
 *	10/03/06	msm		Disallow posting if file is frozen or
 *					revised.
 *	10/17/96	msm		Set DBserver to PDM if PME is not 
 *					enabled.
 *      11/05/96        Ravi            Added the Batch posting notification.
 *
 *      12/05/96        law             New prompt as per TR#179603950.
 *      Aug 07 1998     SSR             Modified form_notification for SIR
 *      09/04/98        ah              Changed False to FALSE for clix
 *      Sep30 1998      SSR             Commented ex$save_module,TR#179801711
 *      AUG 26 99	SSR		New funcction calls to allow CM in AIM
 *      SEP 28 99	SSR		Removed Syntax errors from
 *      				form_notification
 * -------------------------------------------------------------------*/

  

command_string  VDC_M_CheckIn, 0, VDPsAtTDb
class           VDCmdChkIn
super_class     VDS_LOCATE
product_name    "$VDS"
command_table   "vds.cmd"
options         "SITC"

/* used forms */
form            "VDPostToDb.O",0,0,"-1","-1"
form            "VDPostToDb",1,0,"-1","-1"
form            "VDSubPostDb",2,0,"-1","-1"

start_state     start

specification

#define FP_POSTOLD       me^^CEO.forms[0].form_ptr
#define FP_POST          me^^CEO.forms[1].form_ptr
#define FP_SUB           me^^CEO.forms[2].form_ptr

#define FILE_PRINT      if (dm2_log) fprintf

#include "OMlimits.h"

instance
{
  char catalog[81];
  char partid[81];
  char revision[81];
  char filename[81];
  char cur_filename[OM_K_MAXOSNAME_LEN];
  char in_key[20];
  char designRep[15];
  char DBserver[5];

  short idx_form;
  short processmode;
}

implementation
/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <FI.h>
#include "PDUerror.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"
#include "OMlimits.h"
#include "vdbmacros.h"
#include "PDUstr.h"
#include "PDUuser.h" 
#include "VDScheckin.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "VDmem.h"
#include "VDPdm2.h"
#include "execmsg.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "VDPdef.h"

#define SUCCESS		1

#define CATALOG         14
#define PART_NAME       15
#define REVISION        16
#define LOCAL_FNAME     17
#define FILE_NAME       22
#define DESIGN_REP      23
#define BATCH_FLG       24
#define MSG_FLD         25

/* Sub Form fields */

#define QUEUE_FLD       12
#define EMAIL_FLD       13

#define  VD_SUBFORM             1003

extern int VD_PDU_present;
extern struct PDUrefresh *refresh;
extern struct PDUuser *user;

from  VDPtrTbl  import VDPtrtblcopy;

state_table

#include	"VDmsg.h"
#define  VD_SUBFORM             1003

state start

	message_key	VD_M_CheckIn

	on ELSE	
		do maincheckin
				on ERROR			state terminate
		do local_display_form				state modif_form
state realstart

        message_key     VD_M_CheckIn

        on ELSE
                do local_display_form                           state modif_form


state modif_form

	message_key	VD_M_CheckIn
        prompt  "Review parameters"

/*	prompt_key	VD_P_MdPrm changed by law for TR179603950 */
        status          ""

        filter          get_event

        on EX_DATA or EX_RJT_MOVEON                             state .
        on EX_BACK_UP
                do erase_form 1                                 state terminate
        on GR_UNKNOWN_TYPE.VD_SUBFORM                           state form_oper1
        on EX_FORM_FINISHED                                     state terminate
state  form_oper1
        erase_form      1
        display_form    2
        message_key     VD_M_CheckIn
        prompt  "Review parameters"
/*      prompt_key      VD_P_MdPrm changed by law for TR179603950 */
        status          ""

        filter          get_event

        on EX_DATA or EX_RJT_MOVEON                             state .
        on EX_BACK_UP
                do erase_form 2                                 state realstart
        on EX_FORM_FINISHED                                     state terminate



action maincheckin
{
  char 			cur_filedescr[OM_K_MAXOSNAME_LEN];
  char 			project[81], username[81], passwd[81], environ[81];
  char 			**catalogs, **part_names;
  char 			string[81];
  unsigned char 	cRep;
  struct   GRsymbology 	Symb;
  int  			n_cat, n_part, rev_flag;
  int  			row;

  SetProc (maincheckin); Begin

  status = OM_S_SUCCESS ;

  *sts = OM_S_SUCCESS;

  me->idx_form = 0;

  if(IsPmeEnabled())
  {
    me->idx_form = 1 ;
    strcpy(me->DBserver,"PME");
  }
  else
  {
    me->idx_form = 0 ;
    strcpy(me->DBserver,"PDM");
  }
  me->processmode = 1;

  if( VDSverify_login() != PDM_S_SUCCESS )
  {
    UI_status( "User not logged in to Database" );
    *sts = OM_E_ABORT;
    return OM_S_SUCCESS;
  }

  strcpy( me->catalog, "" );
  strcpy( me->partid, "" );
  strcpy( me->revision, "" );
  strcpy( me->filename, "" );
  strcpy( me->designRep, REP_MODEL );

  /* hard coded */
  strcpy( me->in_key, REG_CHECKIN );

  /* Get current filename */
  ex$filename( name=cur_filedescr, len=OM_K_MAXOSNAME_LEN );
  strcpy( me->cur_filename,
	  (char *)(strrchr(cur_filedescr,'/') + sizeof(char)) );

  if( !VD_PDU_present )
  {
    UI_status( "Searching for part..." );
    if( !get_catalog_candidates( me->cur_filename,
                                 &catalogs,
                                 &n_cat) )
    {
      UI_status( "Failed to get catalog candidates" );
      *sts = OM_E_ABORT;
      return OM_S_SUCCESS;
    }

    if( n_cat > 0 )
    {
      if( !get_first_part_candidate(me->cur_filename, catalogs[0], me->partid,
                                    me->revision, me->filename) )
      {
        UI_status( "Failed to get part name and revision" );
        *sts = OM_E_ABORT;
        return OM_S_SUCCESS;
      }
      strcpy( me->catalog, catalogs[0] );
    }
  }
  else
  {
    if( VdsDatabaseAccess(username, passwd, project, me->catalog, me->partid,
			  me->revision, me->filename, &rev_flag) != SUCCESS )
    {
      *sts = OM_E_ABORT;
      return OM_S_SUCCESS;
    }
  }

  UI_status( "" );

  if( !VD_PDU_present )
  {
    if( n_cat <= 0 )
    {
      /* None of the catalogs contain parts with local filename =
      cur_filename. Disable gadgets.*/
      FIg_disable( me->forms[me->idx_form].form_ptr, CATALOG );
      FIg_disable( me->forms[me->idx_form].form_ptr, PART_NAME );
      FIg_disable( me->forms[me->idx_form].form_ptr, FI_ACCEPT );
      FIg_disable( me->forms[me->idx_form].form_ptr, FI_RESET );
      sprintf( string, "No catalogs contain part with filename = %s",
	       me->cur_filename );
      FIg_set_text( me->forms[me->idx_form].form_ptr, FI_MSG_FIELD, string );
    }
    else
    {
      /* Update catalogs associated list */
      if( FIfld_set_list_num_rows(me->forms[me->idx_form].form_ptr, CATALOG, 0, n_cat)
          != FI_SUCCESS )
      {
        UI_status( "Failed to set number of rows in catalog list" );
        *sts = OM_E_ABORT;
        return OM_S_SUCCESS;
      }

      for( row=0; row < n_cat; ++row )
      {
        if( VDfld_set_list_text(me->forms[me->idx_form].form_ptr, CATALOG, row, 0,
				catalogs[row], 1) != FI_SUCCESS )
        {
          UI_status( "Failed to set text in catalog list" );
          *sts = OM_E_ABORT;
          return OM_S_SUCCESS;
        }
      }/*for*/

      vdb$RisFreeBuffer( buffer  =    catalogs,
                         size    =    n_cat );

      /* Update part names associated list */
      if( !get_part_candidates(me->cur_filename, me->catalog, &part_names,
                               &n_part) )
      {
        UI_status( "Failed to get valid parts" );
        *sts = OM_E_ABORT;
        return OM_S_SUCCESS;
      }

      if( n_part <= 0 )
      {
        sprintf( string,
		 "Catalog %s does not contain parts with filename = %s",
                 me->catalog, me->cur_filename );
        FIg_set_text( me->forms[me->idx_form].form_ptr, FI_MSG_FIELD, string );
      }
      else
      {
        if( FIfld_set_list_num_rows(me->forms[me->idx_form].form_ptr, PART_NAME, 0,
				    n_part) != FI_SUCCESS )
        {
          FIg_set_text( me->forms[me->idx_form].form_ptr, FI_MSG_FIELD,
                        "Failed to set number of rows in part name list" );
        }

        for( row=0; row < n_part; ++row )
        {
          if( VDfld_set_list_text(me->forms[me->idx_form].form_ptr, PART_NAME, row, 0,
				  part_names[row], 1) != FI_SUCCESS )
          {
            FIg_set_text( me->forms[me->idx_form].form_ptr, FI_MSG_FIELD,
                          "Failed to set text in part name list" );
          }
        }

        vdb$RisFreeBuffer( buffer = part_names,
                           size   = n_part );

      }/*else*/
    }/*else*/
  }/*if*/
  else
  {
    /* Disable gadgets for PDU version */
    FIg_disable( me->forms[me->idx_form].form_ptr, CATALOG );
    FIg_disable( me->forms[me->idx_form].form_ptr, PART_NAME );
    FIg_disable( me->forms[me->idx_form].form_ptr ,REVISION );
  }

  VDSget_login_defaults( username, environ, project );
  ACget_def_NVrep( &cRep, &Symb );

/*  if( cRep == 0x6 )
   FIg_set_state_off( me->forms[me->idx_form].form_ptr, DESIGN_REP );
*/

  FIfld_set_text( me->forms[me->idx_form].form_ptr, CATALOG, 0, 0, me->catalog, 0 );
  FIfld_set_text( me->forms[me->idx_form].form_ptr, PART_NAME, 0, 0, me->partid, 0 );
  FIfld_set_text( me->forms[me->idx_form].form_ptr, REVISION, 0, 0, me->revision, 0 );
  FIfld_set_text( me->forms[me->idx_form].form_ptr, LOCAL_FNAME, 0, 0, me->filename, 0 );
  FIg_set_text( me->forms[me->idx_form].form_ptr, FILE_NAME, cur_filedescr );
  FIg_disable( me->forms[me->idx_form].form_ptr, REVISION );

  End

  goto quit ;
}

action form_notification( int form_label; int gadget_label; double value;
                          char *form_ptr )
{
  char 		string[81], err_msg[256], io_status[3], checkin_user[15],
       		checkout_user[15], checkout_node[31], checkout_dir[81];
  char 		project[81], username[81], environ[81];
  char 		**part_names=NULL, **revisions=NULL;
  char 		*text=NULL;
  char 		**tempFileName = NULL;
  IGRchar       FileName[257], TmpFileName[270];
  time_t        ltime;
  IGRchar       *token;
  FILE          *dm2_log = NULL;
  IGRboolean 	fileFlag ;
  IGRint	fileState=0;
  OMuword     	curOs;
  IGRlong	msg;
  int  		text_size = 0;
  int  		n_part, n_revision;
  int  		row, sts,ii,count;
  int  		state, num=0, i;
  IGRboolean    TrSavExist=TRUE;
  char   	stsMsg[DI_PATH_MAX],
         	qname[DI_PATH_MAX];
  FILE   	*fp = NULL;
  char   	pipe_queue[DI_PATH_MAX],mail_path[DI_PATH_MAX],
		DirName[DI_PATH_MAX],ListName[DI_PATH_MAX];
  struct GRid  	TrTblId,SaTrTblId;
  static  IGRboolean  first_flg = TRUE;
  static  int         PostStat = 0;

  SetProc(form_notification); Begin
  status = OM_S_SUCCESS ;

  text_size = 81;
  text = _MALLOC( text_size, char);
  _CheckAlloc(text, "text", sts, FALSE, quit);

 if ( form_ptr == FP_POSTOLD || form_ptr == FP_POST )
 {

  switch( gadget_label )
  {
    case FI_CANCEL:
     if( !VD_PDU_present )
     {
       VdsPtrStrcpy( &refresh->rev_catalog, "" );
       VdsPtrStrcpy( &refresh->rev_partid, "" );
       VdsPtrStrcpy( &refresh->rev_revision, "" );
       VdsPtrStrcpy( &refresh->rev_filename, "" );
     }
     first_flg = TRUE;
     _put_response( resp = EX_FORM_FINISHED );
     break;

    case FI_RESET:
     if( !VD_PDU_present )
     {
       VdsPtrStrcpy( &refresh->rev_catalog, "" );
       VdsPtrStrcpy( &refresh->rev_partid, "" );
       VdsPtrStrcpy( &refresh->rev_revision, "" );
       VdsPtrStrcpy( &refresh->rev_filename, "" );

       FIg_set_text( form_ptr, CATALOG, "" );
       FIg_set_text( form_ptr, PART_NAME, "" );
       FIg_set_text( form_ptr, REVISION, "" );
       FIg_set_text( form_ptr, LOCAL_FNAME, "" );

       FIg_disable( form_ptr, PART_NAME );
       FIg_disable( form_ptr, REVISION );
       FIg_disable( form_ptr, LOCAL_FNAME );

       FIfld_pos_cursor( form_ptr, CATALOG, 0, 0, 0, 0, 1, 1 );
     }
     first_flg = TRUE;
     break;

    case FI_ACCEPT:
     if( first_flg == FALSE )
        goto step0;
     if( !VDSverify_catalog(me->catalog) )
     {
       sprintf( string, "Catalog %s does not exist", me->catalog );
       FIg_set_text( form_ptr, FI_MSG_FIELD, string );
       FIg_set_state_off( form_ptr, FI_ACCEPT );
       break;
     }

     if( !VDSverify_part(me->catalog, me->partid, me->revision) )
     {
       sprintf( string, "Part %s rev %s does not exist in catalog %s",
                me->partid, me->revision, me->catalog );
       FIg_set_text( form_ptr, FI_MSG_FIELD, string );
       FIg_set_state_off( form_ptr, FI_ACCEPT );
       break;
     }

     if( !get_local_fname2(me->catalog, me->partid, me->revision, &num,
                         &tempFileName ) )
     {
       FIg_set_text( form_ptr, FI_MSG_FIELD,
                    "Unable to get local file name from RDB" );
       FIg_set_state_off( form_ptr, FI_ACCEPT );
       break;
     }

     fileFlag = FALSE ;
     for(i=0;i<num;i++) {
        if( (strcmp(me->cur_filename, tempFileName[i]))==0 ) {
                fileFlag = TRUE ;
                break;
        }
     }

     _LOOPFREE (tempFileName, num);

     if( ! fileFlag )
     {
       FIg_set_text( form_ptr, FI_MSG_FIELD,
                     "Part local file name not same as current file name" );
       FIg_set_state_off( form_ptr, FI_ACCEPT );
       break;
     }

step0:

   if(!strcmp(me->DBserver,"PDM"))
   {
     if( VdsRetrievePartAttributes(me->catalog, me->partid, me->revision,
                                   io_status, checkin_user, checkout_user,
                                   checkout_node, checkout_dir, err_msg)
				   != SUCCESS )
     {
       FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
       FIg_set_state_off( form_ptr, FI_ACCEPT );
       break;
     }

     if( io_status[0] != NULL )
     {
       if( strcmp(io_status, "O") && strcmp(io_status, "S") )
       {
         sprintf( err_msg, "Part %s rev %s is not checked out",
                  me->partid, me->revision );
         FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
         FIg_set_state_off( form_ptr, FI_ACCEPT );
         break;
       }
       else if( strcmp(checkout_node, user->wrkst_node) ||
	        strcmp(checkout_dir, user->wrkst_cwd)   ||
		strcmp(checkout_user, user->username) )
       {
         sprintf( err_msg, "Part %s rev %s is checked out by %s",
                  me->partid, me->revision, checkout_user );
         FIg_set_text( form_ptr, FI_PROMPT_FIELD, err_msg );
         sprintf( err_msg, "to %s on node %s",
                  checkout_dir, checkout_node );
         FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
         FIg_set_state_off( form_ptr, FI_ACCEPT );
         break;
       }
     }

     VDSset_login_defaults( username, environ, project );

     if( !VD_PDU_present )
     {
       VdsPtrStrcpy( &refresh->rev_catalog, me->catalog );
       VdsPtrStrcpy( &refresh->rev_partid, me->partid );
       VdsPtrStrcpy( &refresh->rev_revision, me->revision );
       VdsPtrStrcpy( &refresh->rev_filename, me->filename );
     }

     FIf_erase( form_ptr );
     // FIf_delete( form_ptr );

     if( !strcmp(me->in_key, REG_CHECKIN) )
      UI_status( "Regular checkin in progress" );
     else
      UI_status( "Drawing checkin in progress" );

     if( VdsCheckIn(me->in_key, 0, me->designRep) == SUCCESS )
      UI_status( "Successful completion" );

   }
   else
   {
    int         inlen,code,index=0,
                outlen=0,dstat,mfail;
    char        inbuf[80];
    char        *outbuf, *errmsg=0;
    char        str[200];
    char        FileId[VDPOBID_LEN], DefDirName[DI_PATH_MAX];
    IGRboolean  TrSav=FALSE;
    struct GRid DefDat;


    if ( first_flg == FALSE )
    {
        first_flg= TRUE;
        goto step1;
    }
    ex$get_cur_mod( osnum = &curOs );

    if( WhichAim( ) == SIR )
      goto step1;

    sts = VDPGetFileState( &msg, curOs, &fileState );
    __CheckRC( sts, msg, "VDPGetFileState", wrapup );
    if( fileState == VDP_FILE_REVISED )
    {
           strcpy(err_msg,"The current design file is revised in PME. \n It \
					should also be revised in PDU. ");
           ex$message( msgnumb = EX_F_Var1, type = "%s", var=err_msg );
	   me->state = _terminate;
           goto quit;
    }
    else if( fileState == VDP_FILE_FROZEN )
    {
           strcpy(err_msg,"The current design file is frozen in PME. \n It\
		 should be revised before further executing PME commands ");
           ex$message( msgnumb = EX_F_Var1, type = "%s", var=err_msg );
	   me->state = _terminate;
           goto quit;
    }
    /* Verify the previous posting status */
    for ( i=0; i<80; i++ )
        inbuf[i]='\0';
    code = VDP_VERIFY_PREV_POST;
    ex$get_cur_mod( osnum = &curOs );
    UI_status( "Processing....Please wait" );
    dstat = VDPGetFileId ( &msg,curOs,FileId );
    if ( ! dstat & 1 )
    {
       __DBGpr_int( "VDPGetFileId failed at  ", __LINE__ );
       UI_status( "Failed to get the FileId" );
       break;
    }
    __DBGpr_str( "FileId: ", FileId );
    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));


    inlen += sizeof(int);
    strcpy( &inbuf[inlen], FileId );
    inlen = inlen + strlen( FileId )+1;
    UI_status( "Processing........" );

    dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
                                        inbuf,
                                        &outlen,
                                        &outbuf,
                                        &mfail,
                                        &errmsg );

    if(dstat || mfail)
        /* outbuf[outlen-1] = '\0'; Outbuf len may be 0 */
    {
        if(!errmsg || (errmsg && !errmsg[0]))
            errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
        UI_status( errmsg );
        break;
    }

    /* Read the output buffer */
    index = 0;
    memcpy( &PostStat, &outbuf[index], sizeof(int));
    __DBGpr_int( "Poststat = :: ", PostStat );
    if( ! ( PostStat == 1 || PostStat == 2 ||  PostStat == 3 )  )
    {
       UI_status( "Invalid previous posting status" );
       FIg_set_text( form_ptr,FI_MSG_FIELD,"Invalid previous posting status" );
       FIg_set_state_off( form_ptr, FI_ACCEPT );
       break;
    }

    if ( first_flg & PostStat == 2 ) {

      /* Posting in progress */
      first_flg = FALSE;
      sprintf(str,"%s%s%s","WARNING:Previous posting is incomplete. please",
                " verify if the previous job is still in the queue.",
                " 'Accept' to continue or 'X' to cancel" );
      FIg_set_text( form_ptr, MSG_FLD,str );
      SMVA_disable( form_ptr, 2,DESIGN_REP, BATCH_FLG );
      FIg_display(form_ptr,MSG_FLD);
      FIg_set_state_off( form_ptr, FI_ACCEPT );
      break;


    } else if ( first_flg & PostStat == 3 ) {

      /* Posting was  unsuccessfull*/

      first_flg= FALSE;
      sprintf(str,"%s\n%s\n%s","WARNING:Previous posting was unsuccessful",
                        "Do you want to post the previuos transaction list?",
                        "Accept to Continue or X to Exit" );
      FIg_set_text( form_ptr, MSG_FLD,str );
      SMVA_disable( form_ptr, 2, DESIGN_REP, BATCH_FLG );
      FIg_display(form_ptr,MSG_FLD);
      FIg_set_state_off( form_ptr, FI_ACCEPT );

      break;

    }
step1:
     /* 1- for Interactive 0-for Batch */
     if ( me->processmode )
     {

        /* Save OS to disc */
        /* SSR 23 sep TR # 179801711
       sts = ex$save_module( ftype = EX_visible, filename = me->filename );
       if (sts != 1)
       {
         UI_status("WARNING!! Design file not saved ");
       }
        SSR 23 sep TR # 179801711*/
       __DBGpr_com( " first save commented ");

       /* Check for Default data setting if not exit
	* Begin CM AIM changes SSR 26 AUG 99 */
       status = di$give_pathname( osnum            = curOs,
                                  pathname        = DirName );
       sprintf(DefDirName,"%s%s%s\0", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA);
       status = di$translate(objname = DefDirName,
                        p_objid = &DefDat.objid,
                        p_osnum = &DefDat.osnum );
       if ( DefDat.objid == NULL_OBJID)
       {
	 UI_status ( "AIM Default Data not Set.");
	 __DBGpr_com("AIM Default Data not Set. ");
	 goto wrapup;
       }
       __DBGpr_com( " first save commented ");
       __DBGpr_com( "first save commented ");
       /* Opening a log file * */
       
       FileName[0] = '\0';
       TmpFileName[0] = '\0';
       get_local_fname(refresh->act_catalog,
             refresh->act_partid,
             refresh->act_revision,
             FileName ); 
       
       token = strtok ( FileName, "." );
       sprintf ( TmpFileName, "%s", token );
       strcat ( TmpFileName, "_post.log" );
       __DBGpr_str( " file ", TmpFileName );
       time ( &ltime );
       dm2_log = (FILE *)fopen(TmpFileName,"a");
       if( dm2_log == NULL )
	 __DBGpr_str( "Cannot open file", TmpFileName); 
       
       FILE_PRINT( dm2_log, "\n\n\t---------------------------------------------------------------" );
       FILE_PRINT( dm2_log, "\n\tPosting ISDP Objects to AIM server on %s", ctime(& ltime));
       printf("\n\n\t---------------------------------------------------------------" );
       printf("\n\tPosting ISDP Objects to AIM server on %s", ctime(& ltime)); 
       
       if( IsPmeEnabled() == FALSE )
       {
	 UI_status("AIM server connection required");
	 me->state = _terminate;
	 return status;
       } 
       
       __DBGpr_com( "Checking UID for ISDP Objects");
       status = CheckUid ( &msg, dm2_log );
       CheckRC ( status, msg );
       __DBGpr_com( " Checking SrDetectFileRev" );
       status = SrDetectFileRev( dm2_log );
       CheckRC ( status,1 );
       if(status != OM_S_SUCCESS)
       {
	 _put_response( resp = EX_FORM_FINISHED ); 
	 goto wrapup;
       }
       __DBGpr_com("Calling VDPUpdateDiaglist");
       status = VDPUpdateDiaglist( dm2_log );
       CheckRC ( status, 1 );

       /* End changes for CM for AIM changes*/
       if ( PostStat == 1 )
       {
           /* Continue posting with PMtranslist object */

           TrSav = FALSE;
           sts = VDPmeCheckin(&msg, TrSav );

       }

	   if ( PostStat == 0 )
	   {
		   TrSav = FALSE;
		   sts = VDPmeCheckin(&msg, TrSav );
	   }
	   
	   else if ( PostStat == 3 ) {

           /*
           Previous posting failed case.
           Continue posting with PMtranslist.sav object
           */

           TrSav = TRUE;
           sts = VDPmeCheckin(&msg, TrSav );

       } else if ( PostStat == 2 ) {

           /* Previous posting work is in progress.
             choose the batch mode */

           sprintf(str,"%s",
                "qstat -p | awk -F@ '/@/{ print $1 }'>/usr/tmp/.QList" );
           system( str);
           /* get count of queues */
           fp = fopen ( "/usr/tmp/.QList", "r" );
           if( fp == NULL )
           {
                FIg_set_text ( FP_POST, FI_MSG_FIELD,
                                        "Error getting pipe queue list" );
                msg = MSFAIL;
                break;
           }

           /* count no. of lines */
           count = 0;
           while ( fgets( stsMsg, 80, fp ) ) count++;

           rewind ( fp );

           FIfld_set_list_num_rows ( FP_SUB, QUEUE_FLD, 0, count );
           for ( ii=0; ii<count; ii++ )
           {
                fscanf( fp, "%s", qname );
                VDfld_set_list_text ( FP_SUB, QUEUE_FLD, ii, 0, qname,
                                      FALSE );
           }
           fclose(fp);
           SMVA_enable( form_ptr, 2, DESIGN_REP, BATCH_FLG );
           FIg_set_state_off( form_ptr, FI_ACCEPT );
           FIg_erase(form_ptr,MSG_FLD);
           FIg_display(form_ptr,FI_MSG_FIELD);

           _put_response ( resp = VD_SUBFORM);

           break;

       }

       /* Chenges for AIM CM begin 26 AUG 99 SSR */
       __DBGpr_com(" About to VDPWriteDiagramList ");
       fflush(stdout);
       status = VDPWriteDiagramList();
       //FILE_PRINT ( dm2_log, "\nPosting of Parts not supported; No Parts posted." );
       /* update the NFM attributes for CM workflow */
       status = SrVDUpdCMattrs( refresh->act_catalog, refresh->act_partid,
                                refresh->act_revision, "p_incpartrpt", "Y");
       if(status)
         printf("\n problem in updating NFM attrs");
       /* Chenges for AIM Cm END */

       if (sts != OM_S_SUCCESS )
       {
	  UI_status(" Posting to AIM server failed");
       }
       else
       {
	 __DBGpr_com (" After AIM Checkin " );

           /* Design file needs to be saved again because all the PME data has 
	    * been deleted from the design file 
	    */

	 sts = ex$save_module( ftype = EX_visible, filename = me->filename );
	 if (sts != 1)
	 {
	   UI_status("WARNING!! Design file not saved");
	 }
       }
       _put_response( resp = EX_FORM_FINISHED ); 
       break;
     }
     else
     { 
           /* get available pipe queues and set them in submit form */
           sprintf(str,"%s",
                "qstat -p | awk -F@ '/@/{ print $1 }'>/usr/tmp/.QList" );
           system( str);

           /* get count of queues */
           fp = fopen ( "/usr/tmp/.QList", "r" );
           if( fp == NULL )
           {
                FIg_set_text ( FP_POST, FI_MSG_FIELD,
                                        "Error getting pipe queue list" );
                msg = MSFAIL;
                break;
           }

           /* count no. of lines */
           count = 0;
           while ( fgets( stsMsg, 80, fp ) ) count++;

           rewind ( fp );

           FIfld_set_list_num_rows ( FP_SUB, QUEUE_FLD, 0, count );
           for ( ii=0; ii<count; ii++ )
           {
                fscanf( fp, "%s", qname );
                VDfld_set_list_text ( FP_SUB, QUEUE_FLD, ii, 0, qname,
                                      FALSE );
           }
           fclose(fp);
           SMVA_enable( form_ptr, 2, DESIGN_REP, BATCH_FLG );
           FIg_set_state_off( form_ptr, FI_ACCEPT );
           FIg_erase(form_ptr,MSG_FLD);
           FIg_display(form_ptr,FI_MSG_FIELD);

           _put_response ( resp = VD_SUBFORM);

           break;
     }

    }

    case CATALOG:
     /* Button disabled for PDU version */
     sts = VDchk_Get_text( form_ptr, gadget_label, &text, &text_size );

     if( sts != FI_SUCCESS )
      break;

     if( !VDSverify_catalog(text) )
     {
       sprintf( string, "Catalog %s does not exist", text );
       FIg_set_text( form_ptr, FI_MSG_FIELD, string );
       break;
     }

     strcpy( me->catalog, text );

     if( !get_part_candidates(me->cur_filename, me->catalog, &part_names,
                              &n_part) )
     {
       FIg_set_text( form_ptr, FI_MSG_FIELD, "Failed to get valid parts" );
       break;
     }

     if( n_part <= 0 )
     {
       sprintf( string,
		"Catalog %s does not contain parts with filename = %s",
                me->catalog, me->cur_filename );
       FIg_set_text( form_ptr, FI_MSG_FIELD, string );
       break;
     }
     else
     {
       if( FIfld_set_list_num_rows(form_ptr, PART_NAME, 0, n_part)
                       != FI_SUCCESS )
       {
         FIg_set_text( form_ptr, FI_MSG_FIELD,
                       "Failed to set number of rows in part name list" );
         break;
       }

       for( row=0; row < n_part; ++row )
       {
         if( VDfld_set_list_text( form_ptr, PART_NAME, row, 0,
                                  part_names[row], 1) != FI_SUCCESS )
         {
           FIg_set_text( form_ptr, FI_MSG_FIELD,
                         "Failed to set text in part name list" );
           break;
         }
       }

       vdb$RisFreeBuffer( buffer = part_names, size = n_part );
     }/* else */

     if( !get_first_part_candidate(me->cur_filename, me->catalog,
				   me->partid, me->revision,
				   me->filename) )
     {
       FIg_set_text(form_ptr, FI_MSG_FIELD,
                    "Failed to get part name and revision" );
       break;
     }

     FIfld_set_text( form_ptr, PART_NAME, 0, 0, me->partid, 0 );
     FIfld_set_text( form_ptr, REVISION, 0, 0, me->revision, 0 );
     FIfld_set_text( form_ptr, LOCAL_FNAME, 0, 0, me->filename, 0 );

     FIg_disable( form_ptr, REVISION );

     break;

    case PART_NAME:
     /* Button disabled for PDU version */
     sts = VDchk_Get_text( form_ptr, gadget_label, &text, &text_size );

     if( !get_revision_candidates(me->cur_filename, me->catalog,
                                  text, &revisions, &n_revision ))
     {
       FIg_set_text( form_ptr, FI_MSG_FIELD,
		     "Failed to get valid revisions" );
       break;
     }

     if( n_revision <= 0 )
     {
       sprintf( string,
		"Part %s does not contain revisions with filename = %s",
                text, me->cur_filename );
       FIg_set_text( form_ptr, FI_MSG_FIELD, string );
       break;
     }
     else
     {
       if( FIfld_set_list_num_rows(form_ptr, REVISION, 0, n_revision)
           != FI_SUCCESS )
       {
         FIg_set_text( form_ptr, FI_MSG_FIELD,
                       "Failed to set number of rows in revision list" );
         break;
       }

       for( row=0; row < n_revision; ++row )
       {
         if( VDfld_set_list_text(form_ptr, REVISION, row, 0,
                                 revisions[row], 1) != FI_SUCCESS )
         {
           FIg_set_text( form_ptr, FI_MSG_FIELD,
                         "Failed to set text in revision list" );
           break;
         }
       }

       vdb$RisFreeBuffer( buffer = revisions, size = n_revision );

     }/* else */

     strcpy( me->partid, text );

     strcpy( me->revision, revisions[0] );
     FIfld_set_text( form_ptr, REVISION, 0, 0, me->revision, 0 );
     FIfld_set_text( form_ptr, LOCAL_FNAME, 0, 0, me->filename, 0 );

     FIg_enable( form_ptr, REVISION );

     break;

    case REVISION:
     /* Button disabled for PDU version */
     sts = VDchk_Get_text( form_ptr, gadget_label, &text, &text_size );
     strcpy( me->revision, text );

     if( !VDSverify_part(me->catalog, me->partid, me->revision) )
     {
       sprintf( string, "Part %s rev %s does not exist in catalog %s",
                me->partid, me->revision, me->catalog );
       FIg_set_text( form_ptr, FI_MSG_FIELD, string );
       break;
     }

     if( !get_local_fname(me->catalog, me->partid, me->revision,
			  me->filename) )
     {
       FIg_set_text( form_ptr, FI_MSG_FIELD,
                     "Unable to get local file name from RDB" );
       break;
     }

     FIg_set_text( form_ptr, LOCAL_FNAME, me->filename );

     if( strcmp(me->cur_filename, me->filename) )
     {
       FIg_set_text( form_ptr, FI_MSG_FIELD,
                     "Part local file name not same as current file name" );
       break;
     }

     break;

    case DESIGN_REP:
    FIg_get_state( form_ptr, DESIGN_REP, &state );

    if( state )
    {
     strcpy( me->DBserver,"PDM" );
     /* If VDS-NFM server enabled, change to interactive and disable
        the Batch gadget -Ravi  */
      FIg_set_state_on( form_ptr, BATCH_FLG );
      FIg_disable( form_ptr,  BATCH_FLG );
    } else {
      strcpy( me->DBserver,"PME" );
      FIg_enable( form_ptr,  BATCH_FLG );
    }
    break;
    case BATCH_FLG:
    FIg_get_state( form_ptr, BATCH_FLG, &state );
    if ( state )
        me->processmode = 1;
     else
        me->processmode = 0;

  }
 }
 else if ( form_ptr == FP_SUB )
 {
    switch ( gadget_label )
    {

        case FI_ACCEPT :

             FIg_get_text ( FP_SUB, QUEUE_FLD, pipe_queue );
             FIg_get_text ( FP_SUB, EMAIL_FLD, mail_path );

             if ( pipe_queue[0] == '\0' ){
                FIg_set_text( FP_SUB, FI_MSG_FIELD, "Queue name not defined" );
                FIg_set_state_off( form_ptr, FI_ACCEPT );
                break;
             }
             if (  PostStat == 3 ||  PostStat == 2)
             {
                TrTblId.objid = NULL_OBJID;
                ex$get_cur_mod( osnum = &curOs );

                status = di$give_pathname( osnum           = curOs,
                                             pathname        = DirName );

                sprintf( ListName,"%s%s%s\0", DirName, PME_GLOBAL_DIR,
                                                        PME_TRANS_LIST_SAV );
                __DBGpr_str( "Transaction List Name", ListName );

                status =
                di$translate (  objname = ListName,
                                p_objid = &TrTblId.objid,
                                p_osnum = &TrTblId.osnum );
                /* If TransListSav does not exist. copy Translist to Translist
                   sav. Submit Ascii file with Translist. Delete the Translist.
                 */
                if ( status == DIR_W_NAME_NOT_FOUND  && PostStat == 3 )
                {
                        TrSavExist = FALSE;
                }

             }
             if (  PostStat == 1 || ! TrSavExist ) {

                /* Copy PMTranslist to PMTranslist.sav */
                TrTblId.objid = NULL_OBJID;
                ex$get_cur_mod( osnum = &curOs );

                status = di$give_pathname(      osnum           = curOs,
                                                pathname        = DirName );

                sprintf( ListName,"%s%s%s\0", DirName, PME_GLOBAL_DIR,
                                                        PME_TRANS_LIST );
                __DBGpr_str( "Transaction List Name", ListName );

                status =
                di$translate (  objname = ListName,
                                p_objid = &TrTblId.objid,
                                p_osnum = &TrTblId.osnum );
                if ( status != DIR_S_SUCCESS )
                {
                  UI_status("Transaction list does not exist" );
                  _put_response ( resp = EX_FORM_FINISHED );
                  break;
                }
                sprintf( ListName,"%s%s%s\0", DirName, PME_GLOBAL_DIR,
                                                        PME_TRANS_LIST_SAV );
                status =
                di$translate (  objname = ListName,
                                p_objid = &SaTrTblId.objid,
                                p_osnum = &SaTrTblId.osnum );
                if ( status == DIR_S_SUCCESS )
                {
                        /* Delete the existing PMEtanslistsav object */
                        status = om$send( msg = message Root.delete(0),
                                                targetid = SaTrTblId.objid,
                                                targetos = SaTrTblId.osnum );
                }

                __DBGpr_obj( "Tr TblId", TrTblId );
                if ( TrTblId.objid != NULL_OBJID )
                {
                       /* Copy Translist to TranslistSav */

                        sprintf( ListName,"%s%s%s\0", DirName, PME_GLOBAL_DIR,
                                                        PME_TRANS_LIST_SAV );
                        SaTrTblId.osnum = TrTblId.osnum;
                        __DBGpr_obj( "TrTblId ::",TrTblId );

                        status =
                        om$send( msg = message VDPtrTbl.VDPtrtblcopy( &msg,
                                                &SaTrTblId.objid ),
                                                targetid = TrTblId.objid,
                                                targetos = TrTblId.osnum );
                        __DBGpr_obj( "SaTrTblId ::",SaTrTblId );
                        status =
                        di$add_name (   objname = ListName,
                                        osnum   = SaTrTblId.osnum,
                                        objid   = SaTrTblId.objid );
                        if ( status != DIR_S_SUCCESS )
                        {
                         UI_status( "Failed to copy Translist to TranslistSav");
                         break;
                        }
                }


             }
             /* batch_post_file( PMTranslist or PMtranslist_sav ); */
             status = batch_post_file( &msg, &TrTblId, pipe_queue,mail_path );
             if( PostStat == 1 || !TrSavExist )
             {
                /* Delete the Translist */
                status = om$send( msg = message Root.delete(0),
                                        targetid = TrTblId.objid,
                                        targetos = TrTblId.osnum );
             }

             /*Save the file */
             sts = ex$save_module(ftype = EX_visible, filename= me->filename);
             if (sts != 1)
             {
                UI_status("WARNING!! Design file not saved");
             }

             /* remove the QList file */
             unlink("/usr/tmp/.QList");
             _put_response ( resp = EX_FORM_FINISHED );
             break;

        case FI_CANCEL :
             unlink("/usr/tmp/.QList");
             _put_response ( resp = EX_FORM_FINISHED );
    }
 }


wrapup:
  _FREE(text);

  End

  goto quit ;
}

action local_display_form
{
  FIf_display(me->forms[me->idx_form].form_ptr);
  *sts = OM_S_SUCCESS;

   status = OM_S_SUCCESS;
  goto quit;
}


