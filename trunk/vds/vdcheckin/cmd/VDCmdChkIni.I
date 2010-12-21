class implementation VDCmdChkIn;

/* 09/10/03  ah      TR8041 - Add call to VDPaimReconnectDAD */

/*
#define vaimDEBUG
#define vaimerrDEBUG
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
#include "vadbgmacros.h"
#include "v_datamacros.h"
#include "VDpdm.h"
#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDship.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "VDobj.h"

#define SUCCESS		1

#define CATALOG         14
#define PART_NAME       15
#define REVISION        16
#define LOCAL_FNAME     17
#define FILE_NAME       22
#define DESIGN_REP      23
#define BATCH_FLG       24
#define MSG_FLD         25
#define LOG_POST        30

/* Sub Form fields */

#define QUEUE_FLD       12
#define EMAIL_FLD       13

#define  VD_SUBFORM             1003
#define FILE_PRINT	if (dm2_log) fprintf

extern int    VD_PDU_present;
extern struct PDUrefresh *refresh;
extern struct PDUuser    *user;

extern VDPGetAimInfo();

from  VDPtrTbl  import VDPtrtblcopy;
from ACrg_collect 	import ACget_named_attribute,
			       ACmod_list_attribute;


#define _start 0
#define _realstart 1
#define _modif_form 2
#define _form_oper1 3

/* ----------------------------------------------
 * Moved these here, don't think they actually
 * get used any more
 */
static IGRboolean first_flg;
static  int       PostStat; /* PME Only ??? */

/* ----------------------------------------------
 * 07 May 2003 - chainsaw refactoring, removed non-pdu support
 *
 * Not positive when this get's called but will find out
 * Appears to only be called during startup
 * Does NOT get called when toggling between PDM and SIR
 */
method maincheckin ( long * sts )
{
  int   status = OM_S_SUCCESS;

  char  cur_filedescr[OM_K_MAXOSNAME_LEN];
  char  project [81];
  char  username[81]; 
  char  passwd  [81];

  int   rev_flag;
  int   row;
  char  aim_user[50], aim_server[25], aim_env[15];

  /* Init */
  status = OM_S_SUCCESS ;
  *sts   = OM_S_SUCCESS;
  me->idx_form = 0;

  /* Static Init */
  first_flg = TRUE;
  PostStat = 0;

  /* Abort if no pdu */
  if (!VD_PDU_present)
  {
    UI_status("Must have PDU to post");
    *sts = OM_E_ABORT;
    return OM_S_SUCCESS;
  }

  /* Some requested cleanup */
  VDPaimDeleteItemCache();
  VDPaimDeleteFSIExpressions();

  /* Database selection */
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
  if (VDPaimIsPartCheckedOut() == 0)
  {
    UI_status("Part is not checked out");
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

  /* Database file info */
  if (VdsDatabaseAccess(username, passwd, project, 
                        me->catalog,  me->partid,
			me->revision, me->filename, &rev_flag) != SUCCESS )
  {
    *sts = OM_E_ABORT;
    return OM_S_SUCCESS;
  }
  UI_status( "" );

  /* Disable gadgets for PDU version */
  FIg_disable( me->forms[me->idx_form].form_ptr, CATALOG );
  FIg_disable( me->forms[me->idx_form].form_ptr, PART_NAME );
  FIg_disable( me->forms[me->idx_form].form_ptr ,REVISION );

  FIfld_set_text( me->forms[me->idx_form].form_ptr, CATALOG,     0, 0, me->catalog,  0 );
  FIfld_set_text( me->forms[me->idx_form].form_ptr, PART_NAME,   0, 0, me->partid,   0 );
  FIfld_set_text( me->forms[me->idx_form].form_ptr, REVISION,    0, 0, me->revision, 0 );
  FIfld_set_text( me->forms[me->idx_form].form_ptr, LOCAL_FNAME, 0, 0, me->filename, 0 );

  if (me->idx_form == 1)
  {
    FIg_set_text(me->forms[me->idx_form].form_ptr, 9,        cur_filedescr);
  }
  else
  {
    FIg_set_text(me->forms[me->idx_form].form_ptr, FILE_NAME,cur_filedescr);
  }
/* added code Pullabhotla 04/08/2000 */
  VDPGetAimInfo(aim_user, aim_server, aim_env);
  
  FIfld_set_text( me->forms[me->idx_form].form_ptr, 27, 0, 0, 
                  aim_server, 0 );
  
  FIfld_set_text( me->forms[me->idx_form].form_ptr, 29, 0, 0, 
                  aim_env, 0 );
   
  FIg_disable( me->forms[me->idx_form].form_ptr, 27 );
  FIg_disable( me->forms[me->idx_form].form_ptr, 29 );

  FIg_disable( me->forms[me->idx_form].form_ptr, REVISION );

  /* Master data collection */
  VDPaimChangeMtoDM();
  VDPaimReconnectDAD(NULL);
  VDPaimFIInitFileInfoNode(NULL_OSNUM);
 
quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label; int gadget_label; double value;
                          char *form_ptr )
{
  int		  status = OM_S_SUCCESS;

  char 		string[81], err_msg[256], io_status[3], checkin_user[15],
       		checkout_user[15], checkout_node[31], checkout_dir[81];
  char 		project[81], username[81], environ[81];
  char 		**part_names=NULL, **revisions=NULL;

  char 		**tempFileName = NULL;
  IGRchar       FileName[257], TmpFileName[270];
  time_t        ltime;
  IGRchar       *token;
  FILE          *dm2_log = NULL;
  IGRboolean 	fileFlag ;
  IGRint	fileState=0;
  OMuword     	curOs;
  IGRlong	msg;

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

  char          aim_user[50], aim_server[25], aim_env[15];
  
  int cmdIsDone = 0;
  domNode fileInfoNode;

  int numPosted = 0;
  int numErrors = 0;

  SetProc(form_notification); Begin
  status = OM_S_SUCCESS ;

  /* Main Form */
  if ( form_ptr == FP_POSTOLD || form_ptr == FP_POST )
  {
    switch( gadget_label )
    {
      case FI_CANCEL:
        cmdIsDone = 1;
        goto wrapup;
        break;

      case FI_RESET:
        first_flg = TRUE;
        break;

      case FI_ACCEPT:

        /* PDM Posting */
        if(!strcmp(me->DBserver,"PDM"))
        {
          if(VdsRetrievePartAttributes(me->catalog, 
                                       me->partid, 
                                       me->revision,
                                       io_status, 
                                       checkin_user, 
                                       checkout_user,
                                       checkout_node, 
                                       checkout_dir, 
                                       err_msg) != SUCCESS)
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
            else if(strcmp(checkout_node, user->wrkst_node) ||
                    strcmp(checkout_dir,  user->wrkst_cwd)   ||
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
          /* Part is verified to have been checked out */
          VDSset_login_defaults(username, environ, project);

          FIf_erase( form_ptr );
          // FIf_delete( form_ptr );

          if( !strcmp(me->in_key, REG_CHECKIN))
            UI_status( "Regular checkin in progress");
          else
            UI_status( "Drawing checkin in progress");

          if(VdsCheckIn(me->in_key, 0, me->designRep) == SUCCESS )
            UI_status( "Successful completion" );

        } /* End of PDM Checkin Process */

        /* ------------------------------------------
         * The SIR Check Process
         */
        else
        {
          IGRchar     logFileName[128];
          IGRchar    *p;
          IGRchar     str[200];
          IGRboolean  TrSav=FALSE;

          IGRint     fileType;
          TGRid      dadID;
          TVDpdmInfo pdmInfo;
          IGRint     logPost;

          /* ----------------------------------------------
           * I think this might be the actual processor?
           */

          /* 1- for Interactive 0-for Batch */
          if ( me->processmode )
          {

            /* Check for Default data setting if not exit
             * Begin CM AIM changes SSR 26 AUG 99 */
     
            /* Opening a log file * */
            VDpdmGetPdmInfo(NULL_OSNUM,&pdmInfo);

            strcpy(logFileName,pdmInfo.filename);
            p = strrchr(logFileName,'.');
            if (p) strcpy(p,          "_post.log");
            else   strcat(logFileName,"_post.log");
            __DBGpr_str( " file ", logFileName );

            dm2_log = (FILE *)fopen(logFileName,"a");
            if( dm2_log == NULL )
	      __DBGpr_str( "Cannot open file", logFileName); 
       
            time ( &ltime );
            FILE_PRINT( dm2_log, "\n\n\t---------------------------------------------------------------" );
            FILE_PRINT( dm2_log, "\n\tPosting ISDP Objects to AIM server on %s", ctime(& ltime));

            if( IsPmeEnabled() == FALSE )
            {
	      UI_status("AIM server connection required");
	      cmdIsDone = 1;
              goto wrapup;
            } 

            /* DAD Collector */
            VDPaimGetDADCollector(NULL_OSNUM,0,&dadID);
            if (dadID.objid == NULL_OBJID)
            {
	      UI_status ( "AIM Default Data not Set.");
	      cmdIsDone = 1;
	      goto wrapup;   
            }
/* ----------------------------------------------
 * This is a real bullshit piece of code
 * I think it's all been superseeded
 * skip for now as part of the enhancements
 *
 * Nope: still bs but it handles updating the mdc_id
 * in the collector when a part is revved.
 */            
            status = OM_S_SUCCESS;
#if 1
            __DBGpr_com( " Checking SrDetectFileRev" );
            status = SrDetectFileRev( dm2_log ); /* ah - Always returns success */
#endif
            if(status != OM_S_SUCCESS)
            {
	      UI_status("SrDetectFileRev Failed");
	      cmdIsDone = 1;
              goto wrapup;
            }

	    ///// TLS 2/26/02 - if this is a AMDC file stop
            VDcollGetIntAttr(&dadID,SIR_FILE_TYP,&fileType);
            __DBGpr_com( "Checking if AMDC");
 	    __DBGpr_str( "File Type:", fileType ); 

	    if(fileType == VDP_ASIR_FILE_TYPE_ASM)
  	    {
              UI_status("This is an Assembly File. Can Not Post FSI's");
              cmdIsDone = 1;
              goto wrapup;	
	    }
            if (VDshipDoDiagrams()) {
	      if(fileType == VDP_ASIR_FILE_TYPE_DM)
  	      {
                UI_status("Should not have DM File Types. Can Not Post FSI's");
                cmdIsDone = 1;
                goto wrapup;	
	      }
            }
            else {
	      if(fileType == VDP_ASIR_FILE_TYPE_MODEL)
  	      {
                UI_status("This is an Model File. Can Not Post FSI's");
                cmdIsDone = 1;
                goto wrapup;	
	      }
	      if(fileType == VDP_ASIR_FILE_TYPE_DIAGRAM)
  	      {
                UI_status("This is a Diagram File. Can No Longer Post FSI's");
                cmdIsDone = 1;
                goto wrapup;	
	      }
            }
/* ----------------------------------------------
 * From here, branch to the new posting code
 */
#if 1
  fileInfoNode = VDPaimFIGetFileInfoNode();
  VDPaimCmdPostObjects(dm2_log,fileInfoNode,&numPosted,&numErrors);

  VDfrmGetState(form_ptr,LOG_POST,&logPost);
  if (logPost)
  {
    VDPaimCreateDoomFromTree(fileInfoNode,NULL);
  }
 #endif
#if 0
/* Beg of original posting code */
/* 27 Feb 2004 - Don't call anymore, see the code for details */
	    ////TLS
            __DBGpr_com( "Checking UID for ISDP Objects");
            status = CheckUid ( &msg, dm2_log );
            CheckRC ( status, msg );
            //TLS - 02-13-02 - TR#6016 Make sure the code exits if there is an error.
#endif
#if 0
#if 0
status = OM_E_ABORT;
#endif
            if(status != OM_S_SUCCESS)
            {
              UI_status("CheckUid Failed");
              cmdIsDone = 1;
	      goto wrapup;
            }
/* ----------------------------------------------
 * SIR_PE Skip this because the whole concept of
 * linking to diagam entities in another file is gone.
 *
 * Checked again and it does appear to only work with
 * diagram reference files.
 */
#if o
            __DBGpr_com("Calling VDPUpdateDiaglist");
            status = VDPUpdateDiaglist( dm2_log );
            if (!(status & 1))
            {
              UI_status("VDPUpdateDiaglist Failed");
              cmdIsDone = 1;
	      goto wrapup;
            }
#endif  
            TrSav = FALSE;
            __DBGpr_com("Calling VDPmeCheckin");
            sts = VDPmeCheckin(&msg, TrSav );

            /* End changes for CM for AIM changes
             * SSR 3 NOV No need to check PostStat, in PME it was retrieved from
	     * PME. SIR doesn't have equivalent code 
             */

            /* Chenges for AIM CM begin 26 AUG 99 SSR */
            __DBGpr_com(" About to VDPWriteDiagramList ");
            fflush(stdout);
            status = VDPWriteDiagramList();

/* End of original posting code */
#endif
            //FILE_PRINT ( dm2_log, "\nPosting of Parts not supported; No Parts posted." );
            /* update the NFM attributes for CM workflow */
            status = SrVDUpdCMattrs(pdmInfo.catalog, pdmInfo.part,pdmInfo.rev, 
                                   "p_incpartrpt", "Y");
            if(status)
              printf("\n problem in updating NFM attrs");
            /* Chenges for AIM Cm END */

	    __DBGpr_str( " file ", me->filename);
	    __DBGpr_com (" After AIM Checkin " );

            /* Design file needs to be saved again because all the PME data has 
	     * been deleted from the design file 
	     */
	    sts = ex$save_module( ftype = EX_visible, filename = me->filename );
	    __DBGpr_int( " sts ", sts);
	    if (sts != 1)
	    {
	      __DBGpr_com( " WARNING!! Design file not saved");
	      UI_status("WARNING!! Design file not saved");
	    }
            /* Update timestamp and blob */
            if (logPost)
            {
              VDPaimUpdatePostTimestamp(fileInfoNode,numErrors,1);
            }
	    /* -------------------------------------------
	     * Close this here instead of in the diag list routine?
	     */
	    if (dm2_log) fclose(dm2_log);
	    dm2_log = NULL;

            cmdIsDone = 1;
            goto wrapup;

          } // END Interactive

     else
     {
/* ----------------------------------------------
 * This appears to pop up the batch form
 * But only pme is supported
 */ 
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
     } // END Batch

    } // End Else server = AIM

    case DESIGN_REP: /* This is the db toggle */
    FIg_get_state( form_ptr, DESIGN_REP, &state );

    if( state )
    {
     strcpy( me->DBserver,"PDM" );
     /* If VDS-NFM server enabled, change to interactive and disable
        the Batch gadget -Ravi  */
      FIg_set_state_on( form_ptr, BATCH_FLG );
      FIg_disable( form_ptr,  BATCH_FLG );

   /* added code Pullabhotla 04/08/2000 */  
      FIg_erase( form_ptr, 26 );
      FIg_erase( form_ptr, 27 );
      FIg_erase( form_ptr, 28 );
      FIg_erase( form_ptr, 29 );
      
    } else {
      strcpy( me->DBserver,"PME" );
      FIg_enable( form_ptr,  BATCH_FLG );
    /*  added code Pullabhotla 04/08/200 */

      FIg_display( form_ptr, 26 );
      FIg_display( form_ptr, 27 );
      FIg_display( form_ptr, 28 );
      FIg_display( form_ptr, 29 );

     VDPGetAimInfo(aim_user, aim_server, aim_env);
  
     FIfld_set_text( form_ptr, 27, 0, 0, aim_server, 0 );
  
     FIfld_set_text( form_ptr, 29, 0, 0, aim_env, 0 );
     FIg_disable( form_ptr, 27 );
     FIg_disable( form_ptr, 29 );
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
  if (cmdIsDone)
  {
    VDPaimFIFreeFileInfoNode();
    me->state = _terminate;
    _put_response( resp = EX_FORM_FINISHED );
  }
    
  End
quit:
  return OM_S_SUCCESS;
}

#if 0
static int PostStat;

/* ----------------------------------------------
 * This looks like PME Stuff
 * Should probably never be called under SIR
 */
static int form_notify_sub(Form form, int gadget)
{
  char pipe_queue[DI_PATHMAX];
  char mail_queue[DI_PATHMAX];

  TGRid TrTblId;
  TGRid transListID;
  TGRid savedTransListID;

  int TrSavExist;

  /* Make sure right form */
  if (form != FP_SUB) return 0;

  switch ( gadget_label )
  {
    case FI_ACCEPT :

      FIg_get_text ( FP_SUB, QUEUE_FLD, pipe_queue );
      FIg_get_text ( FP_SUB, EMAIL_FLD, mail_path );

      if (pipe_queue[0] == '\0' ){
        FIg_set_text( FP_SUB, FI_MSG_FIELD, "Queue name not defined" );
        FIg_set_state_off( form_ptr, FI_ACCEPT );
        return 0;
      }
      if (PostStat == 3 ||  PostStat == 2)
      {
        /* Get the saved transaction list */
        VDPaimGetSavedTransactionListObject(NULL_OSNUM,0,&savedTransListID);
        if ((savedTransListID.objid == NULL_OBJID) && (PostStat == 3))
        {
          /* If TransListSav does not exist. copy Translist to Translist
             sav. Submit Ascii file with Translist. Delete the Translist.
           */
          TrSavExist = FALSE;
        }
      }
      if (PostStat == 1 || ! TrSavExist) 
      {
        /* Copy PMTranslist to PMTranslist.sav */
        VDPaimGetTransactionListObject(NULL_OSNUM,0,&transListID);
        if (transListID.objid == NULL_OBJID)
        {
          UI_status("Transaction list does not exist" );
          _put_response ( resp = EX_FORM_FINISHED );
          return 0;
        }
        /* Delete the existing PMEtanslistsav object */
        VDPaimGetSavedTransactionListObject(NULL_OSNUM,0,&savedTransListID);
        if (savedTransListID.objid != NULL_OBJID)
        {
          vdobj$Delete(objID = &savedTransListID);
        }
        /* Copy Translist to TranslistSav */

        sprintf( ListName,"%s%s%s\0", DirName, PME_GLOBAL_DIR,
                                                        PME_TRANS_LIST_SAV );
        SaTrTblId.osnum = TrTblId.osnum;

        status =
        om$send( msg = message VDPtrTbl.VDPtrtblcopy( &msg,&SaTrTblId.objid ),
                 targetid = TrTblId.objid,
                 targetos = TrTblId.osnum );
                      
        status =
        di$add_name(objname = ListName,
                    osnum   = SaTrTblId.osnum,
                    objid   = SaTrTblId.objid );
        if ( status != DIR_S_SUCCESS )
        {
          UI_status( "Failed to copy Translist to TranslistSav");
          break;
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
      break;

  }
  return;
}
#endif

method local_display_form ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  FIf_display(me->forms[me->idx_form].form_ptr);
  *sts = OM_S_SUCCESS;

   status = OM_S_SUCCESS;
  goto quit;
quit:
  return OM_S_SUCCESS;
}

end implementation VDCmdChkIn;
