class implementation Root;

#include <stdio.h>
#include "FI.h"
#include "OMerrordef.h"
#include "TRprod_type.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "execmsg.h"
#include "msmacros.h"
#include "UMS.h"
#include "TR_msg.h"

static char   log_file_name[OM_K_MAXOSNAME_LEN];
static char   out_file_name[OM_K_MAXOSNAME_LEN];

extern int    TRprod_load[NUM_TR_PROD];
extern char  *TRprod_name[NUM_TR_PROD];
extern char   prod_path[NUM_TR_PROD][256];
extern char   pwd[];
extern char  *strrchr();

int msg_load[NUM_TR_PROD];

#define L_CHECK         1
#define L_ERROR_MSG	12

#define L2_CHECK         1
#define L2_DELETE        4
#define L2_WARNING	12
#define L2_EMS_FILE	19
#define L2_LOG_FILE	20
#define L2_OPTIONS	15

#ifndef FALSE
#define FALSE 0
#endif

#define TRRET_FORM    112
#define TR_E_INACCESSABLE_FILE 0

static Form TRret_form;
static char *in_file_name;
static char  warning_str[256];

extern char   *GRTRchange_extension();
extern char   *GRTRdirname();
extern int    GRTRget_product_data_field();
extern int    GRTRload_prod();

static int  prod_type, ret_sel_options, done_translate;

int trans_ret_function(file_name)
char *file_name;
{
  int   sts = OM_S_SUCCESS;
  int   i, len;
  char	msgbuf[500], *dirname=NULL;

  if ( access(file_name, 0) == -1 )
    goto quit;

  dirname = GRTRdirname(file_name);
  if (dirname) strcpy (pwd, dirname);
  if (dirname) free (dirname);

  ret_sel_options = 0;

  for (i = 1; i < NUM_TR_PROD; i++)
  {
    GRTRget_product_data_field (TRprod_name[i], 5, prod_path[i]);
    msg_load[i] = 0;
  }
  in_file_name = file_name;

  if (TRis_object_file(file_name))
  {
    goto quit;
  }
  else if (TRis_iges_file(file_name))
  {
    if (prod_path[IGES][0] || prod_path[CIGES][0] || prod_path[VDAIS][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "IGES");
      prod_type = IGES;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "IGES", "I/IGES, I/CIGES");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if ( TRis_dxf_file (file_name) )
  {
    if (prod_path[DXF][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "DXF");
      prod_type = DXF;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "DXF", "I/DXF");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if (TRis_vda_file(file_name))
  {
    if (prod_path[VDAFS][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "VDAFS");
      prod_type = VDAFS;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "VDAFS", "I/VDAFS");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if ( TRis_ascii (file_name) && TRcheck_ext (file_name, "fst") )
  {
    if (prod_path[FST][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "FST");
      prod_type = FST;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "FST", "I/FST");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if ( TRcheck_ext (file_name, "cgm" ) )
  {
    if (prod_path[CGM][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "CGM");
      prod_type = CGM;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "CGM", "I/CGM");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if ( TRis_TV_file (file_name) )
  {
    if (prod_path[TV][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "TECH2D");
      prod_type = TV;
      len = strlen(file_name);
      file_name[len-2] = '\0';  /* cut :X */
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "TECH2D", "EMS_TECH2D");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if ( TRis_MS_file (file_name) )
  {
    if (prod_path[EMSMSTN][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "MicroStation");
      prod_type = EMSMSTN;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "MicroStation", "EMSMSTN");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if (TRis_cadds_file(file_name) )
  {
    if (prod_path[CADDS][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "CADDS");
      prod_type = CADDS;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "CADDS", "EMSCADDS");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if (TRis_catia_file (file_name))
  {
    if (prod_path[CATIA][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "CATIA");
      prod_type = CATIA;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "CATIA", "EMSCATIA");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if (TRis_ddn_file (file_name))
  {
    if (prod_path[EMSDDN][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "ICEM DDN");
      prod_type = EMSDDN;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "ICEM DDN", "EMSDDN");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else if (TRis_step_file (file_name))
  {
    if (prod_path[EMSSTEP][0])
    {
      UMSGetByNum (warning_str, TR_W_NoOMFile, "%s%s", file_name, "ProSTEP");
      prod_type = EMSSTEP;
    }
    else
    {
      UMSGetByNum (msgbuf, TR_E_NoOMFile, "%s%s%s", file_name, "ProSTEP", "EMSSTEP");
      EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
      prod_type = -1;
      sts = TR_E_INACCESSABLE_FILE;
      goto quit;
    }
  }
  else
  {
    UMSGetByNum (msgbuf, TR_E_UnknFile, "%s", file_name);
    EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
    prod_type = -1;
    sts = TR_E_INACCESSABLE_FILE;
    goto quit;
  }

  if (prod_type)
  {
    done_translate = 0;
    TRRET_translate(file_name);
    if (done_translate)
      strcpy(file_name, out_file_name);
    else
      sts = TR_E_INACCESSABLE_FILE;
  }
quit:

  return(sts);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++ TRRET_process_form */
TRRET_process_form ( form_label, gadget_label, value )
int     form_label;
int     gadget_label;
double  value;
{
  int   sel_flag;
  int   i, rpos, accept, sts;
  int   rsp = EX_FORM_FINISHED;
  long  stat;
  int   argc=0;
  char  *argv[50], *sp;
  char	msg_file[256], trans_prod_name[80];
  char	msgbuf[500];

  if ( form_label == TRRET_FORM )    {
    switch ( gadget_label ) {
	case L2_EMS_FILE:
		FIfld_get_text( TRret_form, L2_EMS_FILE, 0, 0, OM_K_MAXOSNAME_LEN, out_file_name, &sel_flag, &rpos);
		break;
	case L2_LOG_FILE:
		FIfld_get_text( TRret_form, L2_LOG_FILE, 0, 0, OM_K_MAXOSNAME_LEN, log_file_name, &sel_flag, &rpos);
		break;
	case L2_CHECK:
		/*--- Check for existance of output file ---*/
   	        if ( access(out_file_name, 0) == 0 )
		{
		   sp = (sp = strrchr ( out_file_name, '/' )) ? (sp + 1) : out_file_name;
    	           UMSGetByNum (msgbuf, TR_E_FileEx, "%s", sp);
	           UI_status(msgbuf);
    		   UMSGetByNum (msgbuf, TR_P_FileExOvwr, "%s", sp);
		   /** UI_prompt (msgbuf); **/

		  /******
                   sts = FI_confirm_box(FI_CURRENT_SCREEN, -1, -1,
                                         "", FI_BLACK, "mono821b", 15.0,
                                         msgbuf, FI_BLACK, "mono821b", 15.0,
                                         FI_CENTER_JUSTIFIED,
                                         FI_ACCEPT | FI_CANCEL, strlen(msgbuf)+4);
		  *******/
		   sts = GRconfirm_box(msgbuf);

		   if ( ! sts )
                   {
			UMSGetByNum (msgbuf, TR_I_ChgEmsFile, 0);
			UI_status(msgbuf);
	   		FIg_set_state_off(TRret_form, L2_CHECK);
			break;
		   }
		}
        	FIf_erase ( TRret_form );
		if (TRRET_load_prod(prod_type) > 0)
		{
		  /* Remove output filename before translation */
   	          if ( access(out_file_name, 0) == 0 )
		  {
			unlink (out_file_name);
		  }

		  argc = 1;
                  argv[argc] = (char *)malloc(strlen("-d")+1);
		  strcpy(argv[argc++], "-d");
		  argv[argc] = (char *)malloc(strlen("in")+1);
		  strcpy(argv[argc++], "in");
		  if (prod_type != TV)
		  {
		    argv[argc] = (char *)malloc(strlen("-i")+1);
		    strcpy(argv[argc++], "-i");
		    argv[argc] = (char *)malloc(strlen(in_file_name)+1);
		    strcpy(argv[argc++], in_file_name);
		  }
		  else
		  {
		    argv[argc] = (char *)malloc(strlen("-a")+1);
		    strcpy(argv[argc++], "-a");
		    argv[argc] = (char *)malloc(strlen("SCR")+1);
		    strcpy(argv[argc++], "SCR");
		    argv[argc] = (char *)malloc(strlen("-p")+1);
		    strcpy(argv[argc++], "-p");
		    argv[argc] = (char *)malloc(strlen(in_file_name)+1);
		    strcpy(argv[argc++], in_file_name);
		  }
		  argv[argc] = (char *)malloc(strlen("-o")+1);
		  strcpy(argv[argc++], "-o");
		  argv[argc] = (char *)malloc(strlen(out_file_name)+1);
		  strcpy(argv[argc++], out_file_name);
		  argv[argc] = (char *)malloc(strlen("-l")+1);
		  strcpy(argv[argc++], "-l");
		  argv[argc] = (char *)malloc(strlen(log_file_name)+1);
		  strcpy(argv[argc++], log_file_name);
		  argv[argc] = (char *)malloc(strlen("-Y")+1); /* For interactive activaion */
		  strcpy(argv[argc++], "-Y");
		  switch(prod_type) 
                  {
		    case IGES:
	  		if (!msg_load[IGES])
	  		{
	    	  	  sprintf(msg_file, "%s/config/english/messages/iges_msg.msg", prod_path[IGES]);
    			  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  msg_load[IGES]++;
	  	        }
			argv[0] = (char *)malloc(strlen("iges")+1);
			strcpy(argv[0], "iges");
			if(ret_sel_options)
			  IGESdummy(TRprod_name[IGES], 
				    DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
			IGESdummy(TRprod_name[IGES],
				  DUMMY_MAIN, &argc, argv, 0, 0, &accept);
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
			if(ret_sel_options)
			  IGESdummy(TRprod_name[CIGES], 
				    DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
			IGESdummy(TRprod_name[CIGES], 
				   DUMMY_MAIN, &argc, argv, 0, 0, &accept);
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
			if(ret_sel_options)
			  IGESdummy(TRprod_name[VDAIS], 
				    DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
			IGESdummy(TRprod_name[VDAIS], 
				  DUMMY_MAIN, &argc, argv, 0, 0, &accept);
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
			if(ret_sel_options)
			  DXFdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
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
			if(ret_sel_options)
			  VDAFSdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
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
			if(ret_sel_options)
			  FSTdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
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
			if(ret_sel_options)
			  CGMdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
			CGMdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
			break;
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
			if(ret_sel_options)
			  TVdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
			sprintf(driver, "%s/bin/TVdriver &", prod_path[TV]);
			system(driver);
			TVdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
			break;
                    }
		    case EMSMSTN:
	  		if (!msg_load[EMSMSTN])
	  		{
	    	  	  sprintf(msg_file, "%s/config/english/messages/emsmstn.msg", prod_path[EMSMSTN]);
    			  UMSInitMsg ( msg_file, UMS_INDEX | UMS_KEY);
		    	  msg_load[EMSMSTN]++;
	  	        }
			argv[0] = (char *)malloc(strlen("emsmstn")+1);
			strcpy(argv[0], "emsmstn");
			if(ret_sel_options)
			  EMSMSdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
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
			if(ret_sel_options)
			  CADDSdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept,set_export,CADDS);
			UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
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
			if(ret_sel_options)
			  CATIAdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept,set_export,CATIA);
			UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
			CATIAdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept,NULL,CATIA);
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
			if(ret_sel_options)
			  EMSDDNdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
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
			if(ret_sel_options)
			  EMSSTEPdummy(DUMMY_IN_GETOPT_STRING, &argc, argv, 0, 0, &accept);
	  	        UMSGetByNum (msgbuf, TR_I_TranProg, 0);
			UI_status(msgbuf);
			EMSSTEPdummy(DUMMY_MAIN, &argc, argv, 0, 0, &accept);
			break;

		    default:
			break;

		  }  /* End switch(prod_type) */

		  for (i = 0; i < argc; i++)
		    free(argv[i]);
		  done_translate++;
	          UI_status("");
		}
		else
		{
  		  GRTRget_product_data_field (TRprod_name[prod_type], 2, trans_prod_name);
    		  UMSGetByNum (msgbuf, TR_E_ProdNoLoad, "%s", trans_prod_name);
     		  EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
 		}
	     	ex$putque(msg = &stat, response = &rsp);
		break;
	case L2_DELETE:
        	FIf_erase ( TRret_form );
	     	ex$putque(msg = &stat, response = &rsp);
		break;

        case FI_HELP:
		break;

	case L2_OPTIONS:
		if (TRRET_load_prod(prod_type) > 0)
		{
		  switch(prod_type) {
		    case IGES:
			IGESdummy(TRprod_name[IGES], DUMMY_IN_OPTIONS,
				  NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case CIGES:
			IGESdummy(TRprod_name[CIGES], DUMMY_IN_OPTIONS,
				  NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case VDAIS:
			IGESdummy(TRprod_name[VDAIS], DUMMY_IN_OPTIONS,
				  NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case DXF:
			DXFdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case VDAFS:
			VDAFSdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case FST:
			FSTdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case CGM:
			CGMdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case TV:
			TVdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case EMSMSTN:
			EMSMSdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
			break;
		    case CADDS:
			CADDSdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept,NULL,CADDS);
			break;
		    case CATIA:
			CATIAdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept,NULL,CATIA);
			break;
		    case EMSDDN:
			EMSDDNdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
		    case EMSSTEP:
			EMSSTEPdummy(DUMMY_IN_OPTIONS, NULL, NULL, 0, !ret_sel_options, &accept);
			break;

		    default:
			break;
		  }
		  ret_sel_options = accept;
		  FIg_set_state_off(TRret_form, L2_OPTIONS);
		}
		else
		{
  		  GRTRget_product_data_field (TRprod_name[prod_type], 2, trans_prod_name);
    		  UMSGetByNum (msgbuf, TR_E_ProdNoLoad, "%s", trans_prod_name);
    		  EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
		  FIf_erase ( TRret_form );
	     	  ex$putque(msg = &stat, response = &rsp);
		}
		break;
	default:
		break;
    }
  }
  return(0);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ TRRET_translate */
TRRET_translate(file_name)
char *file_name;
{
  int   ret;
  int   response;
  char  response_data[512];
  char  warning_str1[64]; 
  int   num_bytes;
  int   ret_done;
  int   i, l_begin, l_end, line;
  char	msgbuf[500];

  ret = FIf_new ( TRRET_FORM, "TRret", TRRET_process_form, &TRret_form );
  if ( ret != FI_SUCCESS )
  {
    UMSGetByNum (msgbuf, TR_F_NewForm, "%s%d", "TRret", ret);
    EX_error_box (FI_CURRENT_SCREEN, msgbuf, NULL);
    return(1);
  }
  FIf_display( TRret_form );

  /*--- Display Note massage on form ---*/

  warning_str1[0] = '\0';
  l_begin = l_end = line = 0;
  while (1)
  {
	if (strlen (warning_str) > (l_begin + 60))
	{
	    for (i = l_begin + 59; i >= 0; i--)
	    {
		if (warning_str[i] == ' ')
		{
		    l_end = i;
		    i = 0;
		}
	    }
	    memcpy (warning_str1, warning_str + l_begin, l_end - l_begin + 1);
	    warning_str1[l_end - l_begin + 1] = '\0';
	    FIfld_set_text( TRret_form, L2_WARNING, line, 0, warning_str1, FALSE );
	    l_begin = l_end + 1;
	    line ++;
	}
	else
	{
	    memcpy (warning_str1, warning_str + l_begin, strlen (warning_str) - l_begin);
	    warning_str1[strlen (warning_str) - l_begin] = '\0';
	    FIfld_set_text( TRret_form, L2_WARNING, line, 0, warning_str1, FALSE );
	    break;
	}
  }
/*****
  warning_str1[0] = warning_str2[0] = warning_str3[0] = '\0';
  if (strlen(warning_str) > 120)
      memcpy(warning_str3, warning_str+120, 60);
  if (strlen(warning_str) > 60)
      memcpy(warning_str2, warning_str+60, 60);
  memcpy(warning_str1, warning_str, 60);
  warning_str1[60] = warning_str2[60] = warning_str3[60] = '\0';

  FIfld_set_text( TRret_form, L2_WARNING, 0, 0, warning_str1, FALSE );
  FIfld_set_text( TRret_form, L2_WARNING, 1, 0, warning_str2, FALSE );
  FIfld_set_text( TRret_form, L2_WARNING, 2, 0, warning_str3, FALSE );
*******/
  strcpy(out_file_name, GRTRchange_extension(file_name, "ems"));
  strcpy(log_file_name, GRTRchange_extension(file_name, "log"));
  FIfld_set_text( TRret_form, L2_EMS_FILE, 0, 0, out_file_name, FALSE );
  FIfld_set_text( TRret_form, L2_LOG_FILE, 0, 0, log_file_name, FALSE );

  ret_done = 0;

  while ( !ret_done )
  {
    EX_wait_for_input( &response,response_data,0,&num_bytes);  
    if ( response == EX_FORM_FINISHED )
    {
      ret_done = 1;
    }
  }
  return(0);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++ TRRET_load_prod */
TRRET_load_prod(int prod_num)
{
  int ret;

  if (TRprod_load[prod_type])
    return(prod_type);

  switch(prod_type) {
    case IGES:
      GRTRload_prod(TRprod_name[IGES]);
      if ( TRprod_load[IGES] )
      {
        ret = prod_type = IGES;
      }
      else
      {
        GRTRload_prod(TRprod_name[CIGES]);
	if ( TRprod_load[CIGES] )
	{
	  ret = prod_type = CIGES;
	}
	else
	{
	  GRTRload_prod(TRprod_name[VDAIS]);
	  if ( TRprod_load[VDAIS] )
	  {
	    ret = prod_type = VDAIS;
	  }
	  else
	  {
	    ret = -1;
	  }
	}
      }
      break;
    case CADDS:
    case CATIA:
    case CGM:
    case DXF:
    case EMSDDN:
    case EMSMSTN:
    case EMSSTEP:
    case FST:
    case TV:
    case VDAFS:
      GRTRload_prod(TRprod_name[prod_type]);
      if ( TRprod_load[prod_type] )
      {
        ret = prod_type;
      }
      else
      {
        ret = -1;
      }
      break;

   default:
      ret = -1;
      break;
  }
  return(ret);
}
end implementation Root;

