class implementation TRsav;

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include "UMS.h"
#include "TR_msg.h"
#include "FI.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "exdef.h"
#include "exmacros.h"
#include "expriv.h"
#include "msmacros.h"
#include "TRprod_type.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "ex.h"
#include "gr.h"

#define TRSAV_FORM    111

#define TRSAV_SUCCESS	0
#define TRSAV_ERROR	1

#define L_CHECK			1
#define L_DELETE        	4
#define L_PRODUCT		13
#define L_STATUS_FIELD  	15
#define L_OUTPUT_FILE_NAME	17
#define L_DIRECTORY_PATH	19
#define L_DIRECTORIES		21
#define L_LOG_FILE_NAME		23
#define L_OPTIONS		25

#define L_W_CANCEL	13
#define L_W_OK		14

#define EMSVOP_FORM    99
/* Gadget labels on EMS part save options form */
#define ORIG_MCF 	11
#define NEW_MCF		17

static 	Form TRsav_form;

 int    	format;
 char   	prod_path[NUM_TR_PROD][256];
 char    key_buf[256];

static char	file_name[OM_K_MAXOSNAME_LEN];
static char	file_name_noext[OM_K_MAXOSNAME_LEN];
static char	out_file_name[OM_K_MAXOSNAME_LEN];
static char	abs_out_file_name[OM_K_MAXOSNAME_LEN];
static char	log_file_name[OM_K_MAXOSNAME_LEN];
static char	abs_log_file_name[OM_K_MAXOSNAME_LEN];

%safe
static char	dir_path[256]={""};
int    num_row=0, num_dir_row=0; 
%endsafe

static int    sav_sel_options[NUM_TR_PROD];
static int    prod_type, sel_index;

extern int    TRprod_load[NUM_TR_PROD];
extern char   *TRprod_name[NUM_TR_PROD];
extern char   pwd[];
extern int    msg_load[NUM_TR_PROD];
extern char   *GRTRchange_extension();
extern int    GRTRget_product_data_field();
extern int    GRTRload_prod();
extern int    GRTR_find_prod_type();
extern char   *EXgetcwd();

method execute( IGRint *response; IGRchar *response_data; IGRint pos )
{
  int   status;
  char  *sp;
  char	msg_file[256];
  IGRboolean aflag = 0;

  if(aflag =  pwIsActivationOn() )
    {
     ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);
     *response = TERMINATE;
     return (OM_S_SUCCESS);
    } 

  format = EMS;
  GRTRget_product_data_field ("Ems", 5, prod_path[EMS]);

  /*
   * Initialize UMS message system 
   */
	 
  GRTRget_product_data_field ("Grnuc", 5, msg_file);
  strcat ( msg_file, "/config/english/messages/TR_msg.msg" );
  UMSInitMsg ( msg_file, UMS_INDEX );

  if (!dir_path[0])
    EXgetcwd( dir_path, 256);


  status = ex$filename( name= file_name, len= OM_K_MAXOSNAME_LEN );
  sp = strrchr(file_name, '/');
  if (sp)
    strcpy(file_name_noext, sp+1);
  else
    strcpy(file_name_noext, file_name);
 
  prod_type = 0;
  sel_index = -1;

  TRSAV_form_setup();

quit:
  *response = TERMINATE;
  return (OM_S_SUCCESS);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++ TRSAV_process_form */
TRSAV_process_form ( form_label, gadget_label, value )
int     form_label;
int     gadget_label;
double  value;
{
  int   i, rpos, sel_flag, accept, sts;
  char  prod_str[64], msg_str[256], msg_file[256], str[256];
  int   argc=0;
  char  *argv[50], trans_prod_name[80], *sp;
  IGRint        response;
  IGRlong       nbytes, ret_msg; 
  char		buffer[256];
  char		msgbuf[500];
  struct GRid partid;
  
  TRSAV_status_out("");

  if ( form_label == TRSAV_FORM )    {
    switch ( gadget_label ) {
	case L_PRODUCT:
		for ( i = 0; i < num_row; i++ )
		{
		  FIfld_get_select( TRsav_form, L_PRODUCT, i, 0, &sel_flag );
		  if (sel_flag == TRUE)
		    break;
		}
		if (i < num_row)
		{
		  FIfld_get_text( TRsav_form, L_PRODUCT, i, 0, 64, prod_str, &sel_flag, &rpos);
		  GRTR_find_prod_type(prod_str, &prod_type);
		  sel_index = i;
		}
		else
		{
		  prod_type = -1;
		}

		switch ( prod_type ) {
		    case EMS:
			strcpy(out_file_name, file_name_noext);
  			FIfld_set_text( TRsav_form, L_LOG_FILE_NAME, 0, 0, "", FALSE );
            FIg_disable(TRsav_form, L_OPTIONS);
			break;
		    case IGES:
		    case CIGES:
		    case VDAIS:
            FIg_enable(TRsav_form, L_OPTIONS);
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "igs"));
			break;
		    case DXF:
            FIg_enable(TRsav_form, L_OPTIONS); 
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "dxf"));
			break;
		    case VDAFS:
            FIg_enable(TRsav_form, L_OPTIONS);
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "vda"));
			break;
		    case FST:
            FIg_enable(TRsav_form, L_OPTIONS);
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "fst"));
			break;
		    case CGM:
            FIg_enable(TRsav_form, L_OPTIONS); 
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "cgm"));
			break;
		    case EMSMSTN:
            FIg_enable(TRsav_form, L_OPTIONS); 
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "dgn"));
			break;
		    case CADDS:
            FIg_enable(TRsav_form, L_OPTIONS);
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "_pd"));
			break;
            case CATIA:
            FIg_enable(TRsav_form, L_OPTIONS);
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "cat"));
			break;
		    case TV:
		    {
			char *cp1;
			int len;
			cp1 = strrchr(file_name_noext, '.');
			len = (int)(cp1 - file_name_noext);
            FIg_enable(TRsav_form, L_OPTIONS);
			strncpy(out_file_name, file_name_noext, len);
			out_file_name[len] = '\0';
			break;
		    }
		    case EMSDDN:
            FIg_enable(TRsav_form, L_OPTIONS);
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "ddn"));
			break;
		    case EMSSTEP:
            FIg_enable(TRsav_form, L_OPTIONS);
			strcpy(out_file_name, GRTRchange_extension(file_name_noext, "stp"));
			break;
		    default:
			strcpy(out_file_name, "");
			break;
		}
		FIfld_set_text( TRsav_form, L_OUTPUT_FILE_NAME, 0, 0, out_file_name, FALSE);
		if ( prod_type != EMS )
		{
 		    strcpy(log_file_name, GRTRchange_extension(file_name_noext, "log"));
		    FIfld_set_text( TRsav_form, L_LOG_FILE_NAME, 0, 0, log_file_name, FALSE );
		}

		break;
	case L_OUTPUT_FILE_NAME:
		FIfld_get_text( TRsav_form, L_OUTPUT_FILE_NAME, 0, 0, OM_K_MAXOSNAME_LEN, out_file_name, &sel_flag, &rpos);
		break;
	case L_LOG_FILE_NAME:
		FIfld_get_text( TRsav_form, L_LOG_FILE_NAME, 0, 0, OM_K_MAXOSNAME_LEN, log_file_name, &sel_flag, &rpos);
		break;
	case L_DIRECTORY_PATH:
		FIfld_get_text( TRsav_form, L_DIRECTORY_PATH, 0, 0, OM_K_MAXOSNAME_LEN, dir_path, &sel_flag, &rpos);
		TRSAV_set_directories();
		break;
	case L_DIRECTORIES:
		for ( i = 0; i < num_dir_row; i++ )
		{
		  FIfld_get_select( TRsav_form, L_DIRECTORIES, i, 0, &sel_flag );
		  if (sel_flag == TRUE)
		    break;
		}
		if (i < num_dir_row)
		{
		  FIfld_get_text( TRsav_form, L_DIRECTORIES, i, 0, 64, str, &sel_flag, &rpos);
		  if (strcmp(str, ".") == 0)
		    FIfld_set_select(TRsav_form, L_DIRECTORIES, i, 0, FALSE);
		  else if (strcmp(str, "..") == 0)
		  {
		    char *sp;
		    if (strcmp(dir_path, "/") != 0)
		    {
		      sp = strrchr(dir_path, '/');
		      if (sp)
		      {
			if (sp == dir_path)	/* already be root directory */
			  strcpy(dir_path, "/");
			else
		          sp[0] = '\0';
		      }
		      TRSAV_set_directories();
		    }
		    else
		      FIfld_set_select(TRsav_form, L_DIRECTORIES, i, 0, FALSE);
		  }
		  else
		  {
		    if (strcmp(dir_path, "/") == 0)
		      sprintf(dir_path, "%s%s", dir_path, str);
		    else
		      sprintf(dir_path, "%s/%s", dir_path, str);
		    TRSAV_set_directories();
		  }
		  FIfld_set_text( TRsav_form, L_DIRECTORY_PATH, 0, 0, dir_path, FALSE );
		}
		break;
        case FI_HELP:
		break;

	case L_DELETE:
		TRSAVexit ( TRsav_form );
		break;
	case L_CHECK:
		if (prod_type >= 0)
		{
		  sprintf(abs_out_file_name, "%s/%s", dir_path, out_file_name);
		  sprintf(abs_log_file_name, "%s/%s", dir_path, log_file_name);
		  
                  /*--- Check for validity of output file name ---*/
		  if ( ! EX_invalid_char_in_filename (abs_out_file_name) )
		  {
	   		FIg_set_state_off(TRsav_form, L_CHECK);
    			UMSGetByNum (msgbuf, TR_E_InvChar, "%s", out_file_name);
			TRSAV_status_out(msgbuf);
			break;
		  }
		  if ( strlen(out_file_name) > 14  )
		  {
	   		FIg_set_state_off(TRsav_form, L_CHECK);
    			UMSGetByNum (msgbuf, TR_E_FilNamLong, "%s", out_file_name);
			TRSAV_status_out(msgbuf);
			break;
		  }
		  if ( strlen(log_file_name) > 14  )
		  {
	   		FIg_set_state_off(TRsav_form, L_CHECK);
    			UMSGetByNum (msgbuf, TR_E_FilNamLong, "%s", log_file_name);
			TRSAV_status_out(msgbuf);
			break;
		  }

                  /*--- Check for existance of output file ---*/
   	          if ( (access(abs_out_file_name, 0) == 0) )
		  {
	   		  FIg_set_state_off(TRsav_form, L_CHECK);
    			  UMSGetByNum (msgbuf, TR_E_FileEx, "%s", out_file_name);
			  TRSAV_status_out(msgbuf);
    			  UMSGetByNum (msgbuf, TR_P_FileExOvwr, "%s", out_file_name);
			  /** UI_prompt (msgbuf); **/
			  sts = GRconfirm_box(msgbuf);
			  if ( ! sts )
                          {
			      UMSGetByNum (msgbuf, TR_I_ChgFileName, 0);
			      TRSAV_status_out(msgbuf);
			      break;
			  }
		  }
		  switch(prod_type) {
		    case EMS:
			FIf_erase ( TRsav_form );
            sts = EMget_file_part( &ret_msg, NULL, &partid );
            if( sts & ret_msg & 1 )
            {
             char *numb, rev[1], desc[1];
             char tmp_file_name[OM_K_MAXOSNAME_LEN];
             rev[0] = '\0';
             desc[0] = '\0';

             numb = strrchr(abs_out_file_name, '/');
             if (numb)
             {
              strcpy(tmp_file_name , numb+1);
              EMsave_newprt(abs_out_file_name, tmp_file_name, rev, desc);
             }
             else
             {
              EMsave_newprt(abs_out_file_name, abs_out_file_name, rev, desc);
             }
            }
            else
            {
			 EX_saveas1(abs_out_file_name);
            }

			TRSAVexit ( TRsav_form );
			break;
		    case IGES:
		    case CIGES:
		    case VDAIS:
		    case DXF:
		    case VDAFS:
		    case FST:
		    case CGM:
		    case EMSMSTN:
		    case CADDS:
		    case CATIA:
		    case EMSDDN:
		    case EMSSTEP:
		    case TV:
/* ### */
			if ( !TRprod_load[prod_type] )
			  GRTRload_prod(TRprod_name[prod_type]);
			if ( TRprod_load[prod_type] )
			{
			  FIf_erase ( TRsav_form );

			 /*
			  * Save Object Space before conversion 
                          */
   	          	  if ( (access(file_name, 2) != 0) && 
				! access (file_name, 0) )
			  {
			      /* No write permission -- deny translation */
			      sp = (sp = strrchr ( file_name, '/' )) ? (sp + 1) : file_name;
			      UMSGetByNum (msgbuf, TR_E_NoWritePer, "%s", sp);
			      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
			      TRSAVexit ( TRsav_form );
			      break;
			  }
		       
			  UMSGetByNum (msgbuf, TR_E_ConfirmSave, 0);
			  sts = GRconfirm_box(msgbuf);
			  if ( ! sts )
			  {
			      TRSAVexit ( TRsav_form );
			      break;
			  }

			  sts = EX_save1 ( file_name );
			  if  ( ! sts )
                          {
			      TRSAVexit ( TRsav_form );
			      break;
			  }
	  
		  	  /*--- Remove output filename before translation ---*/
   	          	  if ( (access(abs_out_file_name, 0) == 0) )
			  {
				unlink (abs_out_file_name);
			  }

			  /*  Begin translation */

	  	       	  UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			  UI_status(msgbuf);

		  	  argc = 1;
			  argv[argc] = (char *)malloc(strlen("-d")+1);
		  	  strcpy(argv[argc++], "-d");
		  	  argv[argc] = (char *)malloc(strlen("out")+1);
		  	  strcpy(argv[argc++], "out");
			  if (prod_type != TV)
			  {
		  	    argv[argc] = (char *)malloc(strlen("-i")+1);
		  	    strcpy(argv[argc++], "-i");
		  	    argv[argc] = (char *)malloc(strlen(abs_out_file_name)+1);
		  	    strcpy(argv[argc++], abs_out_file_name);
			  }
			  else
			  {
		  	    argv[argc] = (char *)malloc(strlen("-a")+1);
		  	    strcpy(argv[argc++], "-a");
		  	    argv[argc] = (char *)malloc(strlen("SCR")+1);
		  	    strcpy(argv[argc++], "SCR");
		  	    argv[argc] = (char *)malloc(strlen("-p")+1);
		  	    strcpy(argv[argc++], "-p");
		  	    argv[argc] = (char *)malloc(strlen(out_file_name)+1);
		  	    strcpy(argv[argc++], out_file_name);
			  }
		  	  argv[argc] = (char *)malloc(strlen("-o")+1);
		  	  strcpy(argv[argc++], "-o");
		  	  argv[argc] = (char *)malloc(strlen(file_name)+1);
		  	  strcpy(argv[argc++], file_name);
		  	  argv[argc] = (char *)malloc(strlen("-l")+1);
		  	  strcpy(argv[argc++], "-l");
		  	  argv[argc] = (char *)malloc(strlen(abs_log_file_name)+1);
		  	  strcpy(argv[argc++], abs_log_file_name);
		  	  argv[argc] = (char *)malloc(strlen("-Y")+1); /* For interactive activaion */
		  	  strcpy(argv[argc++], "-Y");
			  switch (prod_type) {
		    	    case IGES:
	  			if (!msg_load[IGES])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/iges_msg.msg", prod_path[IGES]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[IGES]++;
	  	        	}

/*------------------------------------------------------------------------------
	CR# 159525568
	The following code (after else) is added for IGES translator command 
	line so as to maintain consistency with the batch mode whose command
	line has these options.
	-b	: break solids to surfaces
	-j 2	: outpur associative dimensions
	-F	: out trimmed surfaces as boundary entities (143/141)
	These have been made default options as other systems may not
	support solids or trimmed entities (144/142).
	
	It is added for case CIGES also.
					- K S Ganapathy	   29th June 1995.
------------------------------------------------------------------------------*/

				argv[0] = (char *)malloc(strlen("iges")+1);
				strcpy(argv[0], "iges");

				if(sav_sel_options[IGES])
				  IGESdummy(TRprod_name[prod_type],
				   DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				else
				{
  				  argv[argc] = (char *)malloc(strlen("-b")+1);
  				  strcpy(argv[argc++], "-b");
  				  argv[argc] = (char *)malloc(strlen("-j 2")+1);
  				  strcpy(argv[argc++], "-j 2");
  				  argv[argc] = (char *)malloc(strlen("-F")+1); 
  				  strcpy(argv[argc++], "-F");
				}

				IGESdummy(TRprod_name[prod_type],
				   DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				/* run filter part */
			        if(sav_sel_options[IGES])
				{
	  	       		   UMSGetByNum (msgbuf, TR_I_TranProg, 0);
				   UI_status(msgbuf);
				   IGESdummy(TRprod_name[prod_type],
				   DUMMY_FILTER, &argc, argv, 0, 0, &accept);
				}
				break;
		    	    case CIGES:
	  			if (!msg_load[CIGES])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/iges_msg.msg", prod_path[CIGES]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[CIGES]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("iges")+1);
				strcpy(argv[0], "iges");
				if(sav_sel_options[CIGES])
				  IGESdummy(TRprod_name[prod_type],
				   DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				else
				{
  				  argv[argc] = (char *)malloc(strlen("-b")+1);
  				  strcpy(argv[argc++], "-b");
  				  argv[argc] = (char *)malloc(strlen("-j 2")+1);
  				  strcpy(argv[argc++], "-j 2");
  				  argv[argc] = (char *)malloc(strlen("-F")+1); 
  				  strcpy(argv[argc++], "-F");
				}

				IGESdummy(TRprod_name[prod_type],
				   DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				/* run filter part */
			        if(sav_sel_options[CIGES])
				{
	  	       		   UMSGetByNum (msgbuf, TR_I_TranProg, 0);
				   UI_status(msgbuf);
				   IGESdummy(TRprod_name[prod_type],
				   DUMMY_FILTER, &argc, argv, 0, 0, &accept);
				}
				break;
		    	    case VDAIS:
	  			if (!msg_load[VDAIS])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/iges_msg.msg", prod_path[VDAIS]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[VDAIS]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("iges")+1);
				strcpy(argv[0], "iges");
				if(sav_sel_options[VDAIS])
				  IGESdummy(TRprod_name[prod_type],
				   DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				IGESdummy(TRprod_name[prod_type],
				   DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				/* run filter part */
			        if(sav_sel_options[VDAIS])
				{
	  	       		   UMSGetByNum (msgbuf, TR_I_TranProg, 0);
				   UI_status(msgbuf);
				   IGESdummy(TRprod_name[prod_type],
				   DUMMY_FILTER, &argc, argv, 0, 0, &accept);
				}
				break;
		            case DXF:
	  			if (!msg_load[DXF])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/dxf_msg.msg", prod_path[DXF]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[DXF]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("dxf")+1);
				strcpy(argv[0], "dxf");
				if(sav_sel_options[DXF])
				  DXFdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				DXFdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
		            case VDAFS:
	  			if (!msg_load[VDAFS])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/vdafs_msg.msg", prod_path[VDAFS]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[VDAFS]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("vdafs")+1);
				strcpy(argv[0], "vdafs");
				if(sav_sel_options[VDAFS])
				  VDAFSdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	       		UMSGetByNum (msgbuf, TR_I_TranProg, 0);
				UI_status(msgbuf);
				VDAFSdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
		            case FST:
	  			if (!msg_load[FST])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/fst_msg.msg", prod_path[FST]);
	    			  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[FST]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("fst")+1);
				strcpy(argv[0], "fst");
				if(sav_sel_options[FST])
				  FSTdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				FSTdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
		            case CGM:
	  			if (!msg_load[CGM])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/icgm_msg.msg", prod_path[CGM]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[CGM]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("cgm")+1);
				strcpy(argv[0], "cgm");
				if(sav_sel_options[CGM])
				  CGMdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				CGMdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
		            case EMSMSTN:
	  			if (!msg_load[EMSMSTN])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/emsmstn.msg", prod_path[EMSMSTN]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[EMSMSTN]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("emsmstn")+1);
				strcpy(argv[0], "emsmstn");
				if(sav_sel_options[EMSMSTN])
				  EMSMSdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				EMSMSdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
		            case CADDS:
			    {
				char set_export[512];
				set_export[0] = '\0';
	  
	  			if (!msg_load[CADDS])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/emscadds.msg", prod_path[CADDS]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[CADDS]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("convert")+1);
				strcpy(argv[0], "convert");
				if(sav_sel_options[CADDS])
                                {
				 CADDSdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept,set_export,CADDS);
				}
				CADDSdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept,NULL,CADDS);
				break;
			    }
		            case CATIA:
		            {
                                char set_export[512];
                                set_export[0] = '\0';
	   
	  			if (!msg_load[CATIA])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/emscatia.msg", prod_path[CATIA]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[CATIA]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("convert")+1);
				strcpy(argv[0], "convert");
				if(sav_sel_options[CATIA])
				{
				  CATIAdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept,set_export,CADDS);
				}
				CATIAdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept,NULL,CATIA);
				break;
			    }
			    case TV:
			    {
				char driver[256];

	  			if (!msg_load[TV])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/emstv.msg", prod_path[TV]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[TV]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("emstv")+1);
				strcpy(argv[0], "emstv");
				if(sav_sel_options[TV])
				  TVdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
			        sprintf(driver, "%s/bin/TVdriver &", prod_path[TV]);
			        system(driver);
				TVdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
			    }
		            case EMSDDN:
	  			if (!msg_load[EMSDDN])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/emsddn.msg", prod_path[EMSDDN]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[EMSDDN]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("emsddn")+1);
				strcpy(argv[0], "emsddn");
				if(sav_sel_options[EMSDDN])
				  EMSDDNdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				EMSDDNdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
		            case EMSSTEP:
	  			if (!msg_load[EMSSTEP])
	  			{
	    	  	  	  sprintf(msg_file, "%s/config/english/messages/emsstep.msg", prod_path[EMSSTEP]);
    				  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  	  msg_load[EMSSTEP]++;
	  	        	}
				argv[0] = (char *)malloc(strlen("emsstep")+1);
				strcpy(argv[0], "emsstep");
				if(sav_sel_options[EMSSTEP])
				  EMSSTEPdummy(DUMMY_OUT_GETOPT_STRING, &argc, argv, 0, 0, &accept);
				EMSSTEPdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
				break;
			    default:
				break;
			  }
			  fflush (stderr);
			  UI_status(" ");
		  	  for (i = 0; i < argc; i++)
		    	    free(argv[i]);

			 /* 
			  * Need to Retrieve the original EMS file since
			  * the translation could have modifyed it
                          */	   

			  response = EX_STRING;
	    		  nbytes = strlen(file_name)+1;
	    
	    		  ex$putque(msg = &ret_msg,
		      		    pos = FRONT,
		      		    response = &response,
		      		    byte = &nbytes,
		      		    buffer = file_name);
	    
			  response = EX_STRING;
	    		  strcpy(buffer,"n"); /* Do not save current file */
	    		  nbytes = strlen(buffer)+1;
	    
	    		  ex$putque(msg = &ret_msg,
		      		    pos = FRONT,
		      		    response = &response,
		      		    byte = &nbytes,
		      		    buffer = buffer);
	    
	 		  response = EX_CMD_KEY;
	    		  strcpy(buffer,"EXRtFl"); /* Retrieve */
	    		  nbytes = strlen(buffer)+1;
	    
	    		  ex$putque(msg = &ret_msg,
		      		    pos = FRONT,
		      		    response = &response,
		      		    byte = &nbytes,
		      		    buffer = buffer);

			  /*TRexit ( TRsav_form );*/
			}
			else
			{
  		          GRTRget_product_data_field (TRprod_name[prod_type], 2, trans_prod_name);
    			  UMSGetByNum (msgbuf, TR_E_ProdNoLoad, "%s", trans_prod_name);
			  TRSAV_status_out(msgbuf);
			  sel_flag = FALSE;
			  FIfld_set_select ( TRsav_form, L_PRODUCT, sel_index, 0, sel_flag);
			  prod_type = sel_index = -1;
			}
			break;
		    default:
			break;
		  }
		}
		FIg_set_state_off(TRsav_form, L_CHECK);
		break;
	case L_OPTIONS:
		/* pwd is a global variable used by all products option forms */
		strcpy (pwd, dir_path);
		if (prod_type > 0)    /* is not EMS */
		{
/* ### */
		  if ( !TRprod_load[prod_type] )
		    GRTRload_prod(TRprod_name[prod_type]);
		  if ( TRprod_load[prod_type] )
		  {
		    switch(prod_type) {
		      case IGES:
			IGESdummy(TRprod_name[prod_type],
				   DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[IGES], &accept);
			break;
		      case CIGES:
			IGESdummy(TRprod_name[prod_type],
				   DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[CIGES], &accept);
			break;
		      case VDAIS:
			IGESdummy(TRprod_name[prod_type],
				   DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[VDAIS], &accept);
			break;
		      case DXF:
			DXFdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[DXF], &accept);
			break;
		      case VDAFS:
			VDAFSdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[VDAFS], &accept);
			break;
		      case FST:
			FSTdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[FST], &accept);
			break;
		      case CGM:
			CGMdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[CGM], &accept);
			break;
		      case EMSMSTN:
			EMSMSdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[EMSMSTN], &accept);
			break;
		      case CADDS:
			CADDSdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[CADDS], &accept,NULL,CADDS);
			break;
		      case CATIA:
			CATIAdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[CATIA], &accept,NULL,CATIA);
			break;
		      case TV:
			TVdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[TV], &accept);
			break;
		      case EMSDDN:
			EMSDDNdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[EMSDDN], &accept);
			break;
		      case EMSSTEP:
			EMSSTEPdummy(DUMMY_OUT_OPTIONS, NULL, NULL, 0, !sav_sel_options[EMSSTEP], &accept);
			break;
		      default:
			break;
		    }
		    sav_sel_options[prod_type] = accept;
		  }
		  else
		  {
  		    GRTRget_product_data_field (TRprod_name[prod_type], 2, trans_prod_name);
    		    UMSGetByNum (msgbuf, TR_E_ProdNoLoad, "%s", trans_prod_name);
	            TRSAV_status_out(msgbuf);
		    sel_flag = FALSE;
		    FIfld_set_select ( TRsav_form, L_PRODUCT, sel_index, 0, sel_flag);
		    prod_type = sel_index = -1;
		  }
		}
/* Commented out below code - otions button is disabled for EMS. Now part 
* file will be saved with default values of part number, revision and desc.
* This is taken care with the old Save and Rename form itself. No seperate 
* form for Part Save and Rename.  
*       else
*       {
*   
* 
*        struct GRid partid;
* Commented this out, EMS will have option to save as a different Part file
*    		    UMSGetByNum (msgbuf, TR_I_NoEmsSubFrm, 0);
*               TRSAV_status_out(msgbuf);
*
*                    sts = ret_msg = 0;
*                    sts = EMget_file_part( &ret_msg, NULL, &partid );
*                    if( sts & ret_msg & 1 )
*                    {
*  		        sprintf(abs_out_file_name, "%s/%s", dir_path, out_file_name);
*              EMPartSaveAs(file_name, abs_out_file_name);
*                    }
*       }
*/
		FIg_set_state_off(TRsav_form, L_OPTIONS);
		break;
	default:
		break;
    }
  }
  else 
  {
    /*---- Unknown form label ----*/
    return(TRSAV_ERROR);
  }
  return(TRSAV_SUCCESS);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++ TRSAV_form_setup */
int TRSAV_form_setup()
{
  int  ret, i;
  char str[256], status_str[256];
  char msgbuf[500];

  for (i = 0; i < NUM_TR_PROD; i++)
  {
    sav_sel_options[i] = 0;
    msg_load[i] = 0;
  }

  ret = FIf_new ( TRSAV_FORM, "TRsav", TRSAV_process_form, &TRsav_form );
  if ( ret != FI_SUCCESS )
  {
    UMSGetByNum (msgbuf, TR_F_NewForm, "%s%d", "TRsav", ret);
    UI_status(msgbuf);
    return(TRSAV_ERROR);
  }
  FIf_display( TRsav_form );
  FIg_disable(TRsav_form, L_OPTIONS);

  /*
   * read all available products
   */

  num_row = 0;
  FIfld_set_text( TRsav_form, L_PRODUCT, num_row, 0, TRprod_name[0], TRUE );
  strcpy(abs_out_file_name, file_name);
  strcpy(out_file_name, file_name_noext);
  FIfld_set_text( TRsav_form, L_OUTPUT_FILE_NAME, 0, 0, out_file_name, FALSE );
  FIfld_set_text( TRsav_form, L_DIRECTORY_PATH, 0, 0, dir_path, FALSE );
  num_row++;
  for (i = 1; i < NUM_TR_PROD; i++)
  {
    GRTRget_product_data_field (TRprod_name[i], 5, prod_path[i]);
    if (prod_path[i][0])
    {
      FIfld_set_text( TRsav_form, L_PRODUCT, num_row, 0, TRprod_name[i], FALSE );
      num_row++;
    }
  }
  FIfld_set_num_rows(TRsav_form, L_PRODUCT, num_row);

  TRSAV_set_directories();

  return(TRSAV_SUCCESS);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++ TRSAV_set_directories */
TRSAV_set_directories()
{
  DIR *fd=NULL;
  struct dirent *dlink;
  struct stat   buf;
  char file[256];
  int num=0;

  fd = (DIR *)opendir(dir_path);

  if ( fd == NULL )
	return (TRSAV_ERROR);

  while(dlink = readdir(fd))
  {
    sprintf(file, "%s/%s", dir_path, dlink->d_name);
    stat(file, &buf);
    if (buf.st_mode & S_IFDIR)
      FIfld_set_text( TRsav_form, L_DIRECTORIES, num++, 0, dlink->d_name, FALSE );
    FIfld_set_num_rows(TRsav_form, L_DIRECTORIES, num);
  }
  num_dir_row = num;
  return(TRSAV_SUCCESS);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ TRSAV_status_out */
/*  Write line to status field                                              */

TRSAV_status_out (msg)
char *msg;
{
  FIfld_set_text ( TRsav_form, L_STATUS_FIELD, 0, 0, msg, FALSE);
  UI_status ( msg );
  return(TRSAV_SUCCESS);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ TRSAVexit */
/*  Exit command                                              	  */

TRSAVexit ( form )
  Form form;
{
    char msgbuf[500];

    FIf_erase ( form );
    UMSGetByNum (msgbuf, TR_I_CmdServ, 0);
    UI_message(msgbuf);
    UMSGetByNum (msgbuf, TR_I_SelectCmd, 0);
    UI_prompt(msgbuf);
    UI_status ("");
    return(TRSAV_SUCCESS);

}

/*++++++++++++++++++++++++++++++++++++++++++++++++++ Has_dsheet */
Has_dsheet(argc, argv)
int argc;
char *argv[];
{
  int i;
  for (i = 0; i < argc; i++)
  {
    if (strcmp(argv[i], "-r")==0)
      return(1);
  }
  return(0);
}

#argsused
int EMsvrename_ops_notify ( form_label, gadget_label, value, fp )
int     form_label;
int     gadget_label;
double  value;
Form    fp;
{
char numb[40], rev[40], desc[40], newfile[40];
char tmpstr[256];
int  sf, rp;

    FIg_set_text(fp, FI_MSG_FIELD, "");
    switch( gadget_label )
    {
        case FI_ACCEPT:
            /*
             * Get the original number, rev and desc and store.
             * Read all the cols of NEW_MCF, modify the number, rev and
             * desc of the current file part, if different. Save the current
             * file with the new name. Reset the number, rev and desc of
             * current file to saved values.
             */
            tmpstr[0] = 0;
            FIfld_get_text(fp, NEW_MCF, 0, 0, 40, newfile, &sf, &rp);
            if( !newfile[0] )
            {
                FIg_set_text(fp, FI_MSG_FIELD, "Enter New File name");
                FIg_set_state_off(fp, FI_ACCEPT);
                break;
            }
            FIfld_get_text(fp, ORIG_MCF, 0, 1, 40, tmpstr, &sf, &rp);
            FIfld_get_text(fp, NEW_MCF,  0, 1, 40, numb, &sf, &rp);
	    if(!strcmp(numb, tmpstr)) numb[0] = 0;

            FIfld_get_text(fp, ORIG_MCF, 0, 2, 40, tmpstr, &sf, &rp);
            FIfld_get_text(fp, NEW_MCF,  0, 2, 40, rev, &sf, &rp);
	    if(!strcmp(rev, tmpstr)) rev[0] = 0;

            FIfld_get_text(fp, ORIG_MCF, 0, 3, 40, tmpstr, &sf, &rp);
            FIfld_get_text(fp, NEW_MCF,  0, 3, 40, desc, &sf, &rp);
	    if(!strcmp(desc, tmpstr)) desc[0] = 0;

            FIf_erase( fp );
            
            EMsave_newprt( newfile, numb, rev, desc );

            break;

        case FI_CANCEL:
            FIf_erase( fp );
            FIf_delete( fp );
            FIf_display( TRsav_form );
            break;
    }
    return( 1 );
}


EMPartSaveAs( orig_file, new_file )
char *orig_file, *new_file;
{
  int  ret;
  long msg;
  char txt_str[256], msgbuf[500];
  struct GRid partid;
  Form EMsv_form; 

  FIf_erase (TRsav_form);

  ret = FIf_new ( EMSVOP_FORM, "EMSvRename", EMsvrename_ops_notify, &EMsv_form);
  if ( ret != FI_SUCCESS )
  {
    UMSGetByNum (msgbuf, TR_F_NewForm, "%s%d", "EMSvRename", ret);
    UI_status(msgbuf);
    FIf_display(TRsav_form);
    return(0);
  }
  FIf_display( EMsv_form );

  /*
   * Set up the values in the form
   */
  ret = EMget_file_part( &msg, NULL, &partid );

  if( ret & msg & 1 )
  {
     FIfld_set_text( EMsv_form, ORIG_MCF, 0, 0, orig_file, 0 );
     ret = EMget_attr_valstr( &msg, "number", &partid, txt_str );
     if( ret & msg & 1 ) 
        FIfld_set_text( EMsv_form, ORIG_MCF, 0, 1, txt_str, 0 );
     EMget_attr_valstr( &msg, "revision", &partid, txt_str );
     if( ret & msg & 1 ) 
        FIfld_set_text( EMsv_form, ORIG_MCF, 0, 2, txt_str, 0 );
     EMget_attr_valstr( &msg, "description", &partid, txt_str );
     if( ret & msg & 1 ) 
        FIfld_set_text( EMsv_form, ORIG_MCF, 0, 3, txt_str, 0 );

     if( new_file[0] )
        FIfld_set_text( EMsv_form, NEW_MCF, 0, 0, new_file, 0 );

     return( ret );
  }
  FIf_display(TRsav_form);
  return( 0 );
}


end implementation TRsav;

