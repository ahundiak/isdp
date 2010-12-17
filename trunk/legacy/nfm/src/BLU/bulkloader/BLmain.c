#include <stdio.h>
#include <string.h>
#include <tools.h>
#include <signal.h>
#include <FEI.h>
#include <FI.h>
#include <MI.h>
#include <termio.h>
#include "UMS.h"
#include "BLums.h"
#include "BLdefs.h"
#include "BLtypes.h"

#define UMSversion  "3.2.0"

/* define the variables that will be used later */
#define extern
#include "BLvars.h"
#undef extern

/* declarations for forms stuff */
/* 06/14/92 removed (but not forgotten)
Form BULK_login;
#include "BULKFORM.h"
extern void BULK_notify();
*/

extern char *getenv();

/******************************************************************************

Doc:    main

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmain.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function sets up conditions needed to perform the bulkload.    
        It writes its own messages to the results file
        Algorithm:
          1) It opens the debug file if requested.
               -check for presence of /usr/tmp/bulkload.err
               -if found, open the file name found on first line
          2) It opens the timer debug file if requested.
               -check for presence of /usr/tmp/timer.err
               -if found, open the file name found on first line
          3) It parses the command line options entered and prompts for ones
               not found.
          4) It forks off the bulkload process.

Examples:
          main(argc,argv);

Return Status:
          (none)

History:
     06/19/91  wrw  -added signal call to ignore death of parent process
     09/03/91  wrw  -added standard header and converted externs to .h
     09/20/91  wrw  -added code to support new command line options:
                       -r <ris_load_file>  for ris pre-load file.
                       -nomail             to supress the mailing option.
     12/03/91  wrw  -added code to look in the current directory for the 
                       message file if it was not found in the other locations.
                    -added code to check the version of the message file that
                       was opened.
                    -added code to support new command line options:
                        -developer    to print the password in the debug file.
     01/31/92  wrw  -added code to support new command line options:
                        -?            print out options and exit
                        -sts          print out status file
                        -nofork       do not fork
                        -nocheck      do not check database before checkins
                        -output <dir> print output files in given dir
     06/14/92  wrw  -added code to support new command line option:
                        -ftr          do not use dmands defaults for ftr
                    -removed code to proccess form
     08/03/92  wrw  -added code to change mode on files for world access.

******************************************************************************/
  

main(argc,argv)
long	argc;       /* I - number of command line arguments passed on call */
char	*argv[];    /* I - array of command line arguments */
{
long    i, pid, status;
FILE   *temp_ptr;
char   base[256];
char   work[MAX_ASCII_LINE_LEN];
char   work_fn[MAX_ASCII_LINE_LEN];
char   output_dir[MAX_ASCII_LINE_LEN];
char   *extension;
char   *slash,*tmp;
char    ext[14];
struct termio arg;

/* 06/14/92 removed (but not forgotten)
extern long forms_int();
FILE   *tmp_fp;
*/


   setuid(0); setgid(3);

   /* initialize globals that need it */
   max_sa = 0; on_node[0]=0;  mirror_count = 0;  mirror_okay = 0;
   setbuf(stdout,0); errlog=fopen("/dev/null","w"); DEBUG=(FILE*)NULL;

   /* turn on debug if it is desired */
   flags.dbg = 0;
   temp_ptr=fopen("/usr/tmp/bulkload.err","r");
   if (temp_ptr) {
      fgets(work,MAX_ASCII_LINE_LEN,temp_ptr);
      work[strlen(work)-1]='\0';
      dbgfile = fopen(work,"w");
      if (dbgfile) {
         flags.dbg=1;
         setbuf(dbgfile,0);
         }
      else {
         BLwrite_output(DMD_F_DBG_BAD_OPEN,work);
         }
      }
   if (flags.dbg)
      fprintf(dbgfile,"In main() debug file has been opened\n");

	if (getenv("BLK_LOCATION"))
		strcpy(base,getenv("BLK_LOCATION"));
	else
		strcpy(base,"/usr/ip32/xdmanager");

   /* set up the user message system */
   sprintf(work_fn,"%s/bin/BLums.msg",base);
   status = UMSInitMsg(work_fn,UMS_INDEX);
   if (flags.dbg)
      fprintf(dbgfile,"Looking for message file in <%s>.\n",work_fn);

   if (status == UMS_S_SUCCESS) {
      /* check and see if the message file is the correct version for this
         executable */
      UMSGetByNum(work,DMD_I_MESSAGE_VERSION,0);
      if (strcmp(work,UMSversion)) {
         /* check another location. */
         status = -1;
         UMSClearMsg(work_fn);
   		if (flags.dbg)
      		fprintf(dbgfile,"\tWrong version found.\n",work_fn);
         }
      }
	else {
  		if (flags.dbg)
     		fprintf(dbgfile,"\tNot there.\n",work_fn);
		}

	if (status != UMS_S_SUCCESS) {
   	sprintf(work_fn,"%s/cfg/BLums.msg",base);
   	status = UMSInitMsg(work_fn,UMS_INDEX);
   	if (flags.dbg)
     	 fprintf(dbgfile,"Looking for message file in <%s>.\n",work_fn);
   	if (status == UMS_S_SUCCESS) {
      	/* check and see if the message file is the correct version for this
         	executable */
      	UMSGetByNum(work,DMD_I_MESSAGE_VERSION,0);
      	if (strcmp(work,UMSversion)) {
         	/* check another location. */
         	status = -1;
         	UMSClearMsg(work_fn);
   			if (flags.dbg)
      			fprintf(dbgfile,"\tWrong version found.\n",work_fn);
         	}
      	}
		else {
  			if (flags.dbg)
     			fprintf(dbgfile,"\tNot there.\n",work_fn);
			}
		}

   if (status != UMS_S_SUCCESS) {
      /* look in NFM's directory */
      temp_ptr=fopen("/usr/ip32/nfm/config/language","r");
      if (temp_ptr) {
         if (fgets(work,MAX_ASCII_LINE_LEN,temp_ptr) != NULL) {
            tmp=strrchr(work,'\n');
            if (tmp)
               strcpy(tmp,"\0");
            }
         else
            strcpy(work,"english");
         fclose(temp_ptr);
         }
      else
         strcpy(work,"english");
      sprintf(work_fn,"/usr/ip32/nfm/config/%s/messages/BLums.msg",work);
      status = UMSInitMsg(work_fn,UMS_INDEX);
   	if (flags.dbg)
			fprintf(dbgfile,"Looking for message file in <%s>.\n",work_fn);

      if (status == UMS_S_SUCCESS) {
         /* check and see if the message file is the correct version for this
            executable */
         UMSGetByNum(work,DMD_I_MESSAGE_VERSION,0);
         if (strcmp(work,UMSversion)) {
            /* check another location. */
            status = -1;
            UMSClearMsg(work_fn);
   			if (flags.dbg)
      			fprintf(dbgfile,"\tWrong version found.\n",work_fn);
            }
         }
		else {
  			if (flags.dbg)
     			fprintf(dbgfile,"\tNot there.\n",work_fn);
			}
		}

	/* look in the old non-x directories */
	strcpy(base,"/usr/ip32/dmanager");
	if (status != UMS_S_SUCCESS) {
   	sprintf(work_fn,"%s/cfg/BLums.msg",base);
   	status = UMSInitMsg(work_fn,UMS_INDEX);
   	if (flags.dbg)
     	 fprintf(dbgfile,"Looking for message file in <%s>.\n",work_fn);
   	if (status == UMS_S_SUCCESS) {
      	/* check and see if the message file is the correct version for this
         	executable */
      	UMSGetByNum(work,DMD_I_MESSAGE_VERSION,0);
      	if (strcmp(work,UMSversion)) {
         	/* check another location. */
         	status = -1;
         	UMSClearMsg(work_fn);
   			if (flags.dbg)
      			fprintf(dbgfile,"\tWrong version found.\n",work_fn);
         	}
      	}
		else {
  			if (flags.dbg)
     			fprintf(dbgfile,"\tNot there.\n",work_fn);
			}
		}

	if (status != UMS_S_SUCCESS) {
   	sprintf(work_fn,"%s/bin/BLums.msg",base);
   	status = UMSInitMsg(work_fn,UMS_INDEX);
   	if (flags.dbg)
     	 fprintf(dbgfile,"Looking for message file in <%s>.\n",work_fn);
   	if (status == UMS_S_SUCCESS) {
      	/* check and see if the message file is the correct version for this
         	executable */
      	UMSGetByNum(work,DMD_I_MESSAGE_VERSION,0);
      	if (strcmp(work,UMSversion)) {
         	/* check another location. */
         	status = -1;
         	UMSClearMsg(work_fn);
   			if (flags.dbg)
      			fprintf(dbgfile,"\tWrong version found.\n",work_fn);
         	}
      	}
		else {
  			if (flags.dbg)
     			fprintf(dbgfile,"\tNot there.\n",work_fn);
			}
		}

   if (status != UMS_S_SUCCESS) {
      /* last try...look in this directory */
      strcpy(work_fn,"./BLums.msg");
      status = UMSInitMsg(work_fn,UMS_INDEX);
   	if (flags.dbg)
     	 fprintf(dbgfile,"Looking for message file in <%s>.\n",work_fn);
      if (status == UMS_S_SUCCESS) {
         /* check and see if the message file is the correct version for this
            executable */
         UMSGetByNum(work,DMD_I_MESSAGE_VERSION,0);
         if (strcmp(work,UMSversion)) {
            status=-1;
            UMSClearMsg(work_fn);
   			if (flags.dbg)
      			fprintf(dbgfile,"\tWrong version found.\n",work_fn);
            }
         }
		else {
  			if (flags.dbg)
     			fprintf(dbgfile,"\tNot there.\n",work_fn);
			}
   	}

   if (status != UMS_S_SUCCESS) {
      printf(
        "Correct User Message System File not found. Contact support.\n");
      exit(0);
      }

   /* turn on timer if it is desired */
   flags.timer = 0;
   temp_ptr=fopen("/usr/tmp/timer.err","r");
   if (temp_ptr) {
      fgets(work,MAX_ASCII_LINE_LEN,temp_ptr);
      work[strlen(work)-1]='\0';
      timerfile = fopen(work,"w");
      setbuf(timerfile,0);
      if (timerfile)
         flags.timer=1;
      else {
         BLwrite_output(DMD_F_DBG_BAD_OPEN,work);
         }
      }

   /* read in command line options that were supplied */
   flags.nfm_mode = flags.ftr_mode  = flags.ris_load = flags.no_mail 
                  = flags.developer = flags.sts      = flags.output 
                  = flags.nofork    = flags.nocheck  = s_flag 
                  = e_flag          = u_flag         = p_flag 
                  = b_flag          = 0;
   for (i=1;i<argc;i++) {
      if (flags.dbg)
         fprintf(dbgfile,"argv[%d] = .%s.\n",i,argv[i]);

      /* check for second chance to turn on debug */
      if (!strcmp(argv[i],"-dbg")) {
         if (!flags.dbg) {
            dbgfile = fopen("/usr/tmp/blk.err","w");
            if (dbgfile) {
               flags.dbg=1;
               setbuf(dbgfile,0);
               }
            else 
               BLwrite_output(DMD_F_DBG_BAD_OPEN,work);
            }
         continue;
         }

      /* check for server */
      if (!strcmp(argv[i],"-s")) {
         s_flag = 1;
         strcpy(server,argv[++i]);
         if (flags.dbg)
            fprintf(dbgfile,"server = .%s.\n",server);
         continue;
         }

      /* check for environment */
      if (!strcmp(argv[i],"-e")) {
         e_flag = 1;
         strcpy(n_environ,argv[++i]);
         if (flags.dbg)
            fprintf(dbgfile,"n_environ = .%s.\n",n_environ);
         continue;
         }

      /* check for user */
      if (!strcmp(argv[i],"-u")) {
         u_flag = 1;
         strcpy(user,argv[++i]);
         if (flags.dbg)
            fprintf(dbgfile,"user = .%s.\n",user);
         continue;
         }

      /* check for password */
      if (!strcmp(argv[i],"-p")) {
         p_flag = 1;
         strcpy(password,argv[++i]);
         if (flags.dbg)
            fprintf(dbgfile,"password = .%s.\n",password);
         continue;
         }

      /* check for bulkload file */
      if (!strcmp(argv[i],"-b")) {
         b_flag = 1;
         strcpy(bulk_fn,argv[++i]);
         if (flags.dbg)
            fprintf(dbgfile,"bulk_fn = .%s.\n",bulk_fn);
         continue;
         }

      /* check for nfm mode */
      if (!strcmp(argv[i],"-nfm")) {
         flags.nfm_mode = 1;
         continue;
         }

      /* check for ftr mode */
      if (!strcmp(argv[i],"-ftr")) {
         flags.ftr_mode = 1;
         continue;
         }

      /* check for ris pre-load file */
      if (!strcmp(argv[i],"-r")) {
         flags.ris_load = 1;
         strcpy(ris_fn,argv[++i]);
         if (flags.dbg)
            fprintf(dbgfile,"ris_fn = .%s.\n",ris_fn);
         continue;
         }

      /* check for output directory */
      if (!strcmp(argv[i],"-output")) {
         flags.output = 1;
         strcpy(output_dir,argv[++i]);
         if (flags.dbg)
            fprintf(dbgfile,"output_dir = .%s.\n",output_dir);
         continue;
         }

      /* check for nomail option */
      if (!strcmp(argv[i],"-nomail")) {
         flags.no_mail = 1;
         continue;
         }

      /* check for .sts file option */
      if (!strcmp(argv[i],"-sts")) {
         flags.sts = 1;
         continue;
         }

      /* check for no fork option */
      if (!strcmp(argv[i],"-nofork")) {
         flags.nofork = 1;
         continue;
         }

      /* check for no check for checkin option */
      if (!strcmp(argv[i],"-nocheck")) {
         flags.nocheck = 1;
         continue;
         }

      /* check if they just wanted some help */
      if (!strcmp(argv[i],"-?")) {
         BLwrite_output(DMD_I_BLK_HELP_HDR,"");
         BLwrite_output(DMD_I_OPTION_S,"-s");
         BLwrite_output(DMD_I_OPTION_E,"-e");
         BLwrite_output(DMD_I_OPTION_U,"-u");
         BLwrite_output(DMD_I_OPTION_P,"-p");
         BLwrite_output(DMD_I_OPTION_B,"-b");
         BLwrite_output(DMD_I_OPTION_OUTPUT,"-output");
         BLwrite_output(DMD_I_OPTION_NOMAIL,"-nomail");
         BLwrite_output(DMD_I_OPTION_NFM,"-nfm");
         BLwrite_output(DMD_I_OPTION_STS,"-sts");
         BLwrite_output(DMD_I_OPTION_NOFORK,"-nofork");
         BLwrite_output(DMD_I_OPTION_NOCHECK,"-nocheck");
         BLwrite_output(DMD_I_OPTION_QUEST,"-?");
         BLwrite_output(DMD_I_BLK_LOCATION,"");
         status = UMSClearMsg(work_fn);
         if (flags.dbg && !pid) {
            fprintf(dbgfile,"Terminating the bulkload proccess\n");
            fclose(dbgfile);
            }
         exit(0);
         }

      /* check for developer option */
      /* this option was added to allow the password to be displayed in the
         debug file if the DEVELOPER thought that it was necessary.  It should
         NEVER be documented. */
      if (!strcmp(argv[i],"-developer")) {
         flags.developer = 1;
         continue;
         }

      } /* for loop */

   /* retrieve any options not found */
   while (!s_flag || !e_flag || !u_flag || !p_flag || !b_flag) {
/* 06/14/92 removed (but not forgotten)
      tmp_fp = vpopen("who am i | cut -c12-14","r");
      if (tmp_fp && fgets(work,5,tmp_fp)) 
         if (!strncmp(work,"ttx",3)) {
            forms_int();
            continue;
            }
*/
      if (!s_flag) {
         BLwrite_output(DMD_I_S_PROMPT,"");
         printf("-->");
         fgets(work,80,stdin);
         strcpy(strchr(work,'\n'),"\0");
         if (strcmp(work,"\0")) {
            s_flag = 1;
            strcpy(server,work);
            }
         }
      if (!e_flag) {
         BLwrite_output(DMD_I_E_PROMPT,"");
         printf("-->");
         fgets(work,80,stdin);
         strcpy(strchr(work,'\n'),"\0");
         if (strcmp(work,"\0")) {
            e_flag = 1;
            strcpy(n_environ,work);
            }
         }
      if (!u_flag) {
         BLwrite_output(DMD_I_U_PROMPT,"");
         printf("-->");
         fgets(work,80,stdin);
         strcpy(strchr(work,'\n'),"\0");
         if (strcmp(work,"\0")) {
            u_flag = 1;
            strcpy(user,work);
            }
         }
      if (!p_flag) {
         BLwrite_output(DMD_I_P_PROMPT,"");
         printf("-->");
         /* turn off echo */
         ioctl(stdin->_file,TCGETA,&arg);
         arg.c_lflag &= ~8;
         ioctl(stdin->_file,TCSETA,&arg);

         fgets(work,80,stdin);

         /* turn echo back on */
         arg.c_lflag |= 8;
         ioctl(stdin->_file,TCSETA,&arg);
         strcpy(strchr(work,'\n'),"\0");
         if (strcmp(work,"\0")) {
            p_flag = 1;
            strcpy(password,work);
            }
         }
      if (!b_flag) {
         printf("\n");
         BLwrite_output(DMD_I_B_PROMPT,"");
         printf("-->");
         fgets(work,80,stdin);
         strcpy(strchr(work,'\n'),"\0");
         if (strcmp(work,"\0")) {
            b_flag = 1;
            strcpy(bulk_fn,work);
            }
         }
      }

   /* open bulkload, results, and reload files */
   extension = strrchr(bulk_fn,'.');
   slash = strrchr(bulk_fn,'/');
   if (!slash)
      slash = bulk_fn;
   else
      slash++;
   if (!extension || (strlen(slash)>14)) {
      BLwrite_output(DMD_F_BLK_BAD_NAME,bulk_fn);
      exit(0);
      }
   if (flags.dbg)
      fprintf(dbgfile,"extension = .%s.\n",extension);
   strcpy(ext,extension);
   if (strcmp(extension,".blk") && strcmp(extension,".rld")) {
      BLwrite_output(DMD_F_BLK_BAD_EXT,bulk_fn);
      exit(0);
      }
   bulkload = fopen(bulk_fn,"r");
   if (!bulkload) {
      BLwrite_output(DMD_F_BLK_BAD_OPEN,bulk_fn);
      exit(0);
      }
   strcpy(fn_bulkload,bulk_fn);
   
   /* check the version */
   if (BLcheck_version()) {
      BLwrite_output(DMD_F_BAD_VERSION,"");
      BLwrite_output(DMD_F_NO_FIX,"");
      exit(0);
      }

   strcpy(extension,".rst");
   if (flags.output) {
      strcpy(fn_results,output_dir);
      if (fn_results[strlen(fn_results)-1]!='/')
         strcat(fn_results,"/");
      strcat(fn_results,slash);
      }
   else {
      strcpy(fn_results,bulk_fn);
      }
   results = fopen(fn_results,"w");
   if (!results) {
      BLwrite_output(DMD_F_RST_BAD_OPEN,fn_results);
      exit(0);
      }
   setbuf(results,0);
	sprintf(work,"chmod 666 %s",fn_results);
	system(work);

   if (!strcmp(ext,".rld"))
      strcpy(extension,".rl2");
   else
      strcpy(extension,".rld");
   if (flags.output) {
      strcpy(fn_reload,output_dir);
      if (fn_reload[strlen(fn_reload)-1]!='/')
         strcat(fn_reload,"/");
      strcat(fn_reload,slash);
      }
   else {
      strcpy(fn_reload,bulk_fn);
      }
   reload = fopen(fn_reload,"w");
   if (!reload) {
      BLwrite_output(DMD_F_RLD_BAD_OPEN,bulk_fn);
      exit(0);
      }
	sprintf(work,"chmod 666 %s",fn_reload);
	system(work);

   if (flags.dbg)
      fprintf(dbgfile,"bulkload, results, and reload files opened\n");

   if (flags.sts) {
      strcpy(extension,".sts");
      if (flags.output) {
         strcpy(fn_sts,output_dir);
         if (fn_sts[strlen(fn_sts)-1]!='/')
            strcat(fn_sts,"/");
         strcat(fn_sts,slash);
         }
      else {
         strcpy(fn_sts,bulk_fn);
         }
      stsfile = fopen(fn_sts,"w");
      if (!stsfile) {
         BLwrite_output(DMD_F_STS_BAD_OPEN,fn_sts);
         exit(0);
         }
      setbuf(stsfile,0);
		sprintf(work,"chmod 666 %s",fn_sts);
		system(work);
      }

   if (flags.nofork) {
      BLbulkload();
      pid=0;
      }
   else {
      /* fork process */
      if (flags.dbg)
         fprintf(dbgfile,"about to fork bulkload process\n");

      if ((pid=fork()) == -1) {
         BLwrite_output(DMD_F_BAD_FORK,"");
         if (flags.dbg)
            fclose(dbgfile);
         exit(0);
         }

      /* child process continues; parent ends */
      if (!pid) {
         signal(SIGHUP,SIG_IGN);
         BLbulkload();
         }
      }

   status = UMSClearMsg(work_fn);
   if (flags.dbg && !pid) {
      fprintf(dbgfile,"Terminating the bulkload proccess\n");
      fclose(dbgfile);
      }
   if (flags.dbg && pid)
      fprintf(dbgfile,"Terminating the parent proccess\n");
   return(0);
} /* end main */


/******************************************************************************

Doc:    forms_int

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmain.c

Author: Jim Albersheim

Date:   xx-DECEMBER-1990

Description:
        This function sets the forms interface.

Examples:
          status = forms_int();

Return Status:
          0           - success
          1           - failure

History:
     06/10/91  wrw  -made revisions for new bulkload program to use.
     09/03/91  wrw  -added standard header
     06/14/92  wrw  -removed from existience

******************************************************************************/
  
/* 06/14/92 removed (but not forgotten)
long forms_int ()
{
struct vlt_slot *vlt;
long vs;
long slots;
long status;

   vlt=NULL;
   Enter_tools();
   Inq_displayed_vs(&vs);
   Get_fixed_vlt(&vs,&slots);
   Loadvlt(vs,vlt,slots);
   Enable_events(FI_EVENT_MASK);
   
   FI_enter();
   status = FIf_new(BULKFORM,"/usr/ip32/dmanager/bin/BULKFORM",BULK_notify
                            ,&BULK_login);
   if (status) {
      status = FIf_new(BULKFORM,"/usr/ip32/nfm/config/forms/BULKFORM"
                               ,BULK_notify,&BULK_login);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
      
   
   LDR_set_list(BULK_login,BULK_FILE,"blk");

   status = FIf_display(BULK_login);
   if (status) {
      BLwrite_output(DMD_F_FORMS_ERROR,"");
      exit(0);
      }

   if (!s_flag) {
      status = FIg_set_text(BULK_login,FI_MSG_FIELD,"Enter the NFM Server");
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
   if (!e_flag) {
      status = FIg_set_text(BULK_login,NFM_SERVER,server);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
   if (!u_flag) {
      status = FIg_set_text(BULK_login,NFM_ENVIR,n_environ);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      status = FIg_set_text(BULK_login,NFM_SERVER,server);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
   if (!p_flag) {
      status = FIg_set_text(BULK_login,NFM_LOGIN,user);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      status = FIg_set_text(BULK_login,NFM_SERVER,server);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      status = FIg_set_text(BULK_login,NFM_ENVIR,n_environ);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }

   if (!b_flag) {
      status = FIg_set_text(BULK_login,NFM_LOGIN,user);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      status = FIg_set_text(BULK_login,NFM_SERVER,server);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      status = FIg_set_text(BULK_login,NFM_ENVIR,n_environ);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }

   if (!s_flag) {
      status = FIg_set_text(BULK_login,FI_MSG_FIELD,"Enter the NFM server");
      if (!status)
         status = FIfld_pos_cursor( BULK_login, NFM_SERVER, 0, 0, 0, 0, 0, 0);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
   else if (!e_flag) {
      status=FIg_set_text(BULK_login,FI_MSG_FIELD,"Enter the NFM Environment");
      if (!status)
         status = FIfld_pos_cursor( BULK_login, NFM_ENVIR, 0, 0, 0, 0, 0, 0);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
   else if (!u_flag) {
      status = FIg_set_text(BULK_login,FI_MSG_FIELD,"Enter the NFM User Name");
      if (!status)
         status = FIfld_pos_cursor( BULK_login, NFM_LOGIN, 0, 0, 0, 0, 0, 0);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
   else if (!p_flag) {
      status = FIg_set_text(BULK_login,FI_MSG_FIELD,"Enter the NFM Password");
      if (!status)
         status = FIfld_pos_cursor( BULK_login, NFM_PASSWD, 0, 0, 0, 0, 0, 0);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }
   else if (!b_flag) {
      status=FIg_set_text(BULK_login,FI_MSG_FIELD
                                    ,"Enter the Bulkload File name");
      if (!status)
         status = FIfld_pos_cursor( BULK_login, BULK_FILE, 0, 0, 0, 0, 0, 0);
      if (status) {
         BLwrite_output(DMD_F_FORMS_ERROR,"");
         exit(0);
         }
      }

   FI_process_forms();
   return(0);

}
*/
