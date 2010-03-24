class implementation cmdserver;

#include <exsysdep.h>
#include <OMerrordef.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <expriv.h>
#include <execmsg.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <igewindef.h>
#include <igewindow.h>
#include <igewinmacros.h>
#include <exlocale.h>
#include <limits.h>
#include <stdlib.h>
#include <exproto.h>
#include <stdio.h>
#include <sys/stat.h>
#include <helpif.h>


#include <journal.h>
#include <signal.h>
#include <stdio.h>
#ifdef IRIX
#include <curses.h>
#endif
#include <string.h>
#ifdef X11
#include <X11/Xlib.h>
#endif
#if defined (SUNOS5)
/* setjmp.h on SunOS5 contains a define statement that causes opp
 * to hang.  We're hard-coding in all of the SunOS5 setjmp.h here
 * except for that statement to get around the hang.  Other Unix
 * platforms can safely include setjmp.h
 */

#ifndef _SETJMP_H
#define	_SETJMP_H

#ifndef _JBLEN
#ifdef	__cplusplus
extern "C" {
#endif

#if defined(__STDC__)
#if #machine(i386)
#define	_SIGJBLEN 128	/* (sizeof(ucontext_t) / sizeof (int)) */
#elif #machine(sparc)
#define	_SIGJBLEN 19	/* ABI value */
#else
#define	_SIGJBLEN 64	/* (sizeof(ucontext_t) / sizeof (int)) */
#endif

#if #machine(pdp11)
#define	_JBLEN  3
#elif #machine(sparc)
#define	_JBLEN  12	/* ABI value */
#elif #machine(u370)
#define	_JBLEN  4
#elif #machine(u3b)
#define	_JBLEN  11
#else
#define	_JBLEN  10
#endif	/* #machine */

#else

#if i386
#define	_SIGJBLEN 128	/* (sizeof(ucontext_t) / sizeof (int)) */
#elif sparc
#define	_SIGJBLEN 19	/* ABI value */
#else
#define	_SIGJBLEN 64	/* (sizeof(ucontext_t) / sizeof (int)) */
#endif

#if pdp11
#define	_JBLEN  3
#elif sparc
#define	_JBLEN  12	/* ABI value */
#elif u370
#define	_JBLEN  4
#elif u3b
#define	_JBLEN  11
#else
#define	_JBLEN  10
#endif

#endif	/* __STDC__ */

typedef int jmp_buf[_JBLEN];

#if defined(__STDC__)
extern int setjmp(jmp_buf);
#pragma unknown_control_flow(setjmp)
extern void longjmp(jmp_buf, int);

#if __STDC__ == 0 || defined(_POSIX_SOURCE) || defined(_XOPEN_SOURCE)
/* non-ANSI standard compilation */

typedef int sigjmp_buf[_SIGJBLEN];

extern int sigsetjmp(sigjmp_buf, int);
#pragma unknown_control_flow(sigsetjmp)
extern void siglongjmp(sigjmp_buf, int);
#endif

#else
typedef int sigjmp_buf[_SIGJBLEN];

extern int setjmp();
#pragma unknown_control_flow(setjmp)
extern void longjmp();
extern int sigsetjmp();
#pragma unknown_control_flow(sigsetjmp)
extern void siglongjmp();

#endif  /* __STDC__ */

#ifdef	__cplusplus
}
#endif
#endif  /* _JBLEN */
#endif  /* _SETJMP_H */

#else
#include <setjmp.h>
#endif

from super_cmd import init,pre_wakeup,wakeup,execute,pre_sleep,sleep,help,help_topic,cmd_name,status_disp, get_command_info;

#define EX_CI_TEST_END 566
#define debug          0
#define stackdebug     0

#ifdef X11
extern Display       *EXdisplay;
extern int           Help_set_Xdisplay();
extern int           Help_document();
#endif
extern int OM_PMS();
extern int RAP_record_string();
extern int Help_active();
extern char	              EX_runname[];
extern char                   CS_path_name[];
extern struct EXevent_queue   *event_queue_front;
extern struct EXevent_queue   *event_queue_back;
extern struct EX_cmd_cntrl    *EX_cmdlist_ptr;
extern int                    EX_help_quiet;
extern int                    EX_help_proc_exist;
extern jmp_buf                EX_react_recover;
extern int                    EX_help_quiet;
extern int                    EX_disp_quiet;
extern short                  MS_Gs_messages_on;
extern int                    EX_time_for_backup;

static int              EX_cmd_stack_empty;
static int              EX_cmdserver_debug;
static int              NSC;  /* first non suspended cmd */

%safe
static int EX_only_one_session_init_flag = 1;
static struct EX_funnode *EX_initial_cmds = 0;
static char             EX_ret_cmd[] = "EXRtFl";
static int              EX_auto_ci_test_flag = 0;
static int              EX_auto_jump = 0;
static int              EX_old_auto_jump = 0;
static int              EX_cmdserver_save_last = 0;
static int              EX_chanselects = 0;
static FILE             *EX_auto_test_error_file;
static FILE             *tog_file;
%endsafe

static int              EX_msg_prev_state;
static jmp_buf          jmpbuf;
static OM_S_CHANSELECT  to_cmdstack,
                        to_cmd;

static int  init_chanselect()
{
   int   sts;

   if (!(1&(sts = om$make_chanselect(channame="cmdserver.cmdstack", 
      p_chanselect=&to_cmdstack))))
      return sts;
   if (!(1&(sts = om$make_chanselect(channame="super_cmd.cmd",
      p_chanselect=&to_cmd))))
      return sts;

   EX_chanselects = 1;
   return OM_S_SUCCESS;
}

method init_cs()
{
   ME.cmdserver->stkptr = (-1);
   ME.cmdserver->stklen = 0;
   return(OM_S_SUCCESS);
}

method wakeup_cs()
{
   IGRlong msg;
   int ret_stat;

#ifdef TIMING_TEST
   EX_start_timing();
#endif

   ret_stat = EX_cmdattach(&msg,-1,&ME.cmdserver->cmdlist);

#ifdef TIMING_TEST
   EX_end_timing("Attach command_table");
#endif

   if(msg!=EXSUCC)
   {
      printf("attach command_table returning OM_W_ABORT msg = %d\n",msg);
      return(OM_W_ABORT);
   }
   else
     return(OM_S_SUCCESS);
}  /* method wakeup_cs */



method exec_cs(int *response; char *response_data; int mode)
{
#ifdef CLIX
   struct statl fbuf;
#else
   struct stat fbuf;
#endif
   int result;

   int                           (*dyn_function)();
   char                          *add_info;
   IGRlong                       msg;
#ifndef NT
   char                          **dload_argv;
#endif
#ifdef ENV5
   int                           SRmode,
                                 SRwno,
                                 SRno_area;
#endif
#ifndef NT
   int                           i;
   int                           scn, x, y, vsnum;
#endif
   long                          size;
   int                           ret_stat,
                                 om_error_flag,
                                 construct_error_flag,
                                 help_active_flag,
                                 quiet_resp,
                                 sleep_type,
                                 event_nbytes,
                                 tmpstate,
                                 wakeup_type = 0;
   int                           found_flag = 0;
   int                           help_flag = 0;   /* help button selected */
   OM_S_OBJID                    cmd_objid,
                                 topobj,
                                 nextobj;
   char                          *tmp_string;
   OMuword                       os_num,
                                 osnum1,
                                 osk_num;
#ifndef NT
   char                          file_name[256];
#endif
   char                          string[128],
                                 class_name[16];
   char                          rapstring[53];/*defined in super_cmd as 53*/
   struct EX_cmd_mode_resp_data  *mode_str;
   struct EX_cmd                 cmd;
   static OM_S_CHANSELECT        commdstk;
%safe
   static int                    commdstk_init = 0;
%endsafe
   dyn_function = 0;
   add_info = 0;
   if (!commdstk_init)
   {
      if (!(1&(ret_stat = om$make_chanselect(channame="cmdserver.cmdstack", 
				p_chanselect=&commdstk))))
         return ret_stat;
      commdstk_init = 1;
   }
   ret_stat = setjmp(jmpbuf);
   ret_stat = setjmp(EX_react_recover);
   if (ret_stat)
   {
      ret_stat = om$send(mode = OM_e_wrt_message,
                         msg = message Root.delete(0),
                         senderid = my_id,
                         p_chanselect = &commdstk,
                         from = ME.cmdserver->stkptr,
                         to = ME.cmdserver->stkptr);
      check_error_status(ret_stat, "OM_send_channel (Root.delete) error");

      ME.cmdserver->stklen = (ME.cmdserver->stkptr);
      if (ME.cmdserver->stkptr == NSC)
         NSC--;
      ME.cmdserver->stkptr--;
      EX_call_cmdserver_func(EX_CMD_POP);
      EX_pop_quiet();
      if (ME.cmdserver->stklen != 0)
      {
         osk_num = OM_Gw_TransOSnum_0;
         ret_stat = om$get_objid_at_index(objid = my_id,
                                          osnum = osk_num,
					  p_chanselect = &commdstk,
					  index = ME.cmdserver->stkptr,
					  objidaddr = &topobj,
					  osnumaddr = &osnum1);
         class_name[0] = '\0';
         ret_stat = om$get_classname(osnum = osnum1,
                                     objid = topobj,
			             classname = class_name);
	
         ret_stat = om$send(mode = OM_e_wrt_object,
                            msg = message super_cmd.wakeup(wakeup_type),
			    senderid = my_id,
			    p_chanselect = &commdstk,
			    from = ME.cmdserver->stkptr,
			    to = ME.cmdserver->stkptr);

         /* sleep flag possibly reset in disconnect from form message */

         ME.cmdserver->form_cmd_detached = 1;
         wakeup_type = 1;
      }
      goto cmderror;
   }

   wakeup_type = 0;
   EX_help_quiet = 0;
   help_flag = 0;

#ifdef TIMING_TEST
%safe
   int first_time = 1;
%endsafe
#endif

   found_flag=0;
   om_error_flag=0;

   /* check for backed up file , reset pointer if necessary */
   
   if ( (*response == STRING) && (!strcmp(response_data,"ExReTrIeVe"))
        && (ME.cmdserver->stklen != 0)  )
   {
      ME.cmdserver->stklen = 0;
      ME.cmdserver->stkptr = -1;
   }
   EX_cmdserver_debug = 0;

   while(1) 
   {

cmderror:  /*if have reactive load error inside cleanup and start
             over here*/

      if (ME.cmdserver->stklen!=0)
      {
         /* somebody out there */
         EX_cmd_stack_empty = 0;
         help_active_flag = 0;  


         if ( EX_help_proc_exist == 1 )
         {
/*helpnt*/
            ret_stat = Help_active(&help_active_flag);        
	    if( ((help_active_flag == 1 ) && (EX_help_quiet == 0)) || (help_flag == 1)) 
	    {
	       /* if help window exist */
               help_flag = 0;
               ret_stat = 0;
#ifdef ENV5
               ret_stat = ige$SR_active() ;
#endif
               if ( !ret_stat)
               {
                  ret_stat = om$send(mode = OM_e_wrt_object,
                                     msg = message super_cmd.help(),
				     senderid = my_id,
				     p_chanselect = &commdstk,
				     from = ME.cmdserver->stkptr,
				     to = ME.cmdserver->stkptr);
               }
            }
         }


         /*sleep flag possibly reset in disconnect from form message*/

         ME.cmdserver->form_cmd_detached = 1;
         ret_stat = 1;
         ret_stat = om$send(mode = OM_e_wrt_object,
                            msg = message super_cmd.get_command_info(string,0,0,0,0,0,0),
                            senderid = my_id,
                            p_chanselect = &commdstk,
                            from = ME.cmdserver->stkptr,
                            to = ME.cmdserver->stkptr);


         /* here should write command in string[] to journal file */	
         event_nbytes = strlen(string);
#ifndef NT
         if ( event_nbytes )
             JNL_record_info_event(JNL_CHAR,event_nbytes, string);
#endif

         ret_stat=om$send(mode = OM_e_wrt_object,
                          msg = message super_cmd.execute(response,
                             response_data,0),
                          senderid = my_id,
                          p_chanselect = &commdstk,
                          from = ME.cmdserver->stkptr,
                          to = ME.cmdserver->stkptr);

         /* if something bad return from execute method , terminate the cmd */

         if ( !( 1& ret_stat) )
            if ( *response != TERMINATE )
               *response = TERMINATE;
      }     /* end if somebody there */
      else  /* stack empty */
      {
       /*stack finally empty see if it is time to back up*/
       if ( EX_time_for_backup )
        {
         *response = EX_CMD_KEY;
         strcpy(response_data,"EXBc");
         EX_time_for_backup = 0;
        }
       else
        { /*no backup required*/
         EX_cmd_stack_empty = 1;
         help_active_flag = 0;  


         if ( EX_help_proc_exist == 1 )
         {
            ret_stat = Help_active(&help_active_flag); 

	    if ( (help_active_flag == 1) || (help_flag == 1))
	    {
               help_flag = 0;
#ifdef ENV5
               if ( !ige$SR_active() )
               {
#endif
		   Help_toc();
#ifdef ENV5
	       }
#endif
	    }
         }


         tmp_string = (char *) EX_get_and_del_first_fun( &EX_initial_cmds );
         if ( tmp_string == NULL )
         {
            if ( event_queue_front == NULL )
   	    {

#ifdef TIMING_TEST
               if (first_time)
	       {
                  EX_end_timing("Total time of initialization");
		  EX_print_timing();
		  first_time = 0;
	       }
#endif

               if ( ex$is_batch() ) 
	          *response = EX_CMDSVR_RETURN;
	       else
	       {
                  ex$message(msgnumb = EX_M_CmdSvc);
                  ex$message(msgnumb = EX_P_SelCmd,justification = RIGHT_JUS);
                  EX_get_input(response,response_data,mode);
	       }
            }
            else
               EX_get_input(response,response_data,mode);
	 }
         else
	 {
            *response = EX_CMD_KEY;
            strcpy(response_data, tmp_string);
         }
       } /* end no timer backup required*/
      }  /* end else */

      quiet_resp = 0; 
      if( (*response == EX_CMD_M_STR ) || (*response == EX_CMD_M_KEY) )
      {
         mode_str = ( struct EX_cmd_mode_resp_data *)response_data;
         quiet_resp = mode_str->mode;
	 strcpy(response_data, mode_str->string);
	 *response = ( *response == EX_CMD_M_KEY ) ? EX_CMD_KEY : CMD_STRING;
      }

      if ( EX_cmdserver_debug )
        {
         if (tog_file)
            fprintf(tog_file,"response = <%d>\n",*response);
         else
            printf("\nresponse = <%d> ",*response);
        }    
    
      if ((*response == CMD_STRING) ||
          (*response == STRING) ||
          (*response == EX_CMD_KEY))
      {
         /*************************************/
         /* found_flag >=  0  if match,       */
         /* found_flag = (-2) if no match,    */
         /*              (-1) if ambiguous    */
         /*************************************/

         if (EX_cmdserver_debug)
          {
            if (tog_file)
               fprintf(tog_file,"response_data = <%s>\n",response_data);
            else
               printf("response_data = <%s>\n",response_data);
          }      
      
         found_flag = EX_cmdsrch(&msg, EX_cmdlist_ptr, response_data,
            &cmd, response);

         if (found_flag >= 0)
         { 
            if(EX_cmdserver_debug)
             {
             if (tog_file)
              fprintf(tog_file,"command string = <%s>\n",cmd.command_name_ptr);
             else            
              printf("command string = <%s>\n",cmd.command_name_ptr);
          }
            /* set flag to not look in cmd table */
            *response =  cmd.exec_flag & 0xff;
         }
         else if (found_flag==(-1))
         {
            if (EX_auto_ci_test_flag )
               fprintf(EX_auto_test_error_file,
                  "INVALID COMMAND  response=<%d> response_data=<%s>\n",
                  *response,response_data);
            else
            {
               if (ex$is_batch())
                  printf("INVALID COMMAND  response=<%d> response_data=<%s>\n",
                     *response,response_data);
               else
               {
                  response_data[50] = '\0';
                  UI_echo(response_data);
                  ex$message(msgnumb = EX_F_InvalidCmd);
                  UI_echo(" ");
               }
            }
         }
         else if (found_flag == (-2))
         {
            response_data[50] = '\0';
            UI_echo(response_data);
            ex$message(msgnumb = EX_F_AmbKeyin);	  
            UI_echo(" ");
         }
         else if (found_flag == (-5))
         {
            response_data[50] = '\0';
            UI_echo(response_data);
            ex$message(msgnumb = EX_F_BadKeyin);	  
            UI_echo(" ");
         }
      }

      switch (*response)
      {
         case TERMINATE:
         /*  case D_RESET: */

            wakeup_type = ( ME.cmdserver->stkptr == NSC ) ? EX_suspend :
               EX_nonsuspend;
            if (ME.cmdserver->stklen != 0)
            {
               ret_stat=om$send(mode = OM_e_wrt_object,
                                msg = message super_cmd.sleep(EX_suspend),
                                senderid = my_id,
                                p_chanselect = &commdstk,
                                from = ME.cmdserver->stkptr,
                                to = ME.cmdserver->stkptr);
               EX_call_cmdserver_func(EX_CMD_SLEEP);
               ret_stat=om$send(mode = OM_e_wrt_object,
                                msg = message Root.delete(0),
                                senderid = my_id,
                                p_chanselect = &commdstk,
                                from = ME.cmdserver->stkptr,
                                to = ME.cmdserver->stkptr);
               check_error_status(ret_stat,
                  "OM_send_channel (Root.delete) error");

               ME.cmdserver->stklen=(ME.cmdserver->stkptr);
               if ( ME.cmdserver->stkptr == NSC )
                  NSC--;
               ME.cmdserver->stkptr--;
               EX_call_cmdserver_func(EX_CMD_POP);
               EX_pop_quiet();
               if (ME.cmdserver->stklen != 0)
               {
                  osk_num = OM_Gw_TransOSnum_0;
                  ret_stat = om$get_objid_at_index(objid = my_id,
                                                   osnum = osk_num,
						   p_chanselect = &commdstk,
						   index = ME.cmdserver->stkptr,
						   objidaddr = &topobj,
						   osnumaddr = &osnum1);
		  class_name[0] = '\0';
		  ret_stat = om$get_classname(osnum = osnum1,
				              objid = topobj,
			                      classname = class_name);
	
                  ret_stat=om$send(mode = OM_e_wrt_object,
                                   msg = message super_cmd.wakeup(wakeup_type),
				   senderid = my_id,
				   p_chanselect = &commdstk,
				   from = ME.cmdserver->stkptr,
				   to = ME.cmdserver->stkptr);

                  /*Sleep flag possibly reset in disconnect from form message*/

                  ME.cmdserver->form_cmd_detached = 1;
                  wakeup_type = 1;
               }
            }
            break;

         case CLEAR_STACK: 
            ret_stat = om$send (msg = message cmdserver.clear_stack(),
                                senderid = my_id,
			    	targetos = OM_Gw_TransOSnum_0,
                                targetid = my_id);      
            break;

         case EX_POCKET:
/*helpnt*/
#ifndef NT
            IGEinq_mouse_pos( &scn, &x, &y); 

            /* scn=0 right screen, 1 left screen */

            ige$inq_term_info( screen_no = scn, vs_no = &vsnum);
            MS_process_pocket(vsnum,x,y);
#endif          
            break;

         case COMMAND:
            if (EX_auto_ci_test_flag )
            fprintf(EX_auto_test_error_file,
               "                 response=<%d> response_data=<%s>\n",
               *response, response_data);
            om_error_flag=0;
            construct_error_flag = 0;
            ME.cmdserver->stkptr++;

            /* send info to RAP to write to file */
            /*53 set in instance data of super_cmd*/
            if (cmd.command_nbytes >= 53)
                                    cmd.command_nbytes = 52;
            strncpy ( rapstring, cmd.command_name_ptr,
                                 cmd.command_nbytes);
       
            rapstring[cmd.command_nbytes] = 0;
/*helpnt*/
            RAP_record_string( cmd.command_key, rapstring, cmd.class_name);
            if (ME.cmdserver->stkptr==ME.cmdserver->stklen)
            {
               if (found_flag >= 0)
               { /* command found */
                  ret_stat = 1; /*set to 1 in case no .o to load*/
#ifndef NT
                  if ( cmd.dload_name_ptr != NULL )	
                  {

/*helpnt*/
                     char  **argv;
                     int   argc;
                     int   j, file_found, path_found;
                     char  plifpath[256];
                     int   ndload;

#ifdef SUNOS
                     char  productcmd[256];
                     int ii;
                     char  product[512];
                     char  *colon;
                     int npath;
#endif
                     int sizebuf;

                     sizebuf = 512;
                     ndload = 0;
                     ret_stat = EX_dload_setup(cmd.dload_name_ptr,&argv,&argc);
                     if ( ret_stat )
                      {
                      dload_argv = (char **) malloc ((argc + 1) *
                        sizeof (char *));

                     ret_stat = 1;
                     path_found = 1;
                     for ( i = 0 ; i < argc ; i++)
                     {

                        file_found = 0; 
                        for( j=0; (file_found == 0) && path_found; j++)
                        {
                           path_found = ex$get_path( index=j, path=plifpath,
		                                       len=sizeof(plifpath) );
                           if(path_found)
                           {

                              strcat(plifpath,"config/dload/cmds/");
                              strcat(plifpath,argv[i]);
#ifdef SUNOS
/*******ifsun*****/
                              colon = strrchr(plifpath,'.');
                              if (colon)
                                {
                                 colon++;
                                 strcpy(colon,"so");
                                }                                 
                              else
                                 strcat(plifpath, ".so");
#endif

#ifdef CLIX
                              result = statl(plifpath,&fbuf);
#else
                              result = stat(plifpath,&fbuf);
#endif

                              if (result == 0)
                              {
                                 file_found = 1;
                                 strcpy (dload_argv[i] = (char *)
                                    malloc(strlen (plifpath) + 1), plifpath);
                                 ndload++;
                              }
                           }/*end if path*/
                        }
                        if ( !file_found )
                        {
                           strcpy(file_name,
                              "cmdserver: can not find dload command \n");
                           ex$message(msgnumb = EX_S_Var1,
                                      type = "%s",
                                      var = plifpath,
                                      justification = LEFT_JUS); 
                           i = argc;   /*exit loop*/
                           ret_stat = 0;
                        }
                     }/*end for *.o*/

                     if ( ret_stat )
                     {  /*okay so far load*/
                      dload_argv[argc] = 0;
                      ret_stat = som_dload_class(dload_argv,0,0);
/*
#else
#error Windowing system switches must be set!
*/

                        if (!(ret_stat & 1))
                        { 
                           printf("dynamic load class <%s> file <%s>error\n",
                                      cmd.class_name,cmd.dload_name_ptr);
                           om$report_error(sts = ret_stat);
                           ex$message(msgnumb = EX_F_InvalidCmd2);
                        }
                     }
                     while (ndload--)
                       {
                        free (dload_argv[ndload]);
                       }
                     free (dload_argv);
                     EX_dload_free();
                   }/*end if good return from dload_setup*/
                  else
                   {
                    printf (" error from dload setup\n");
                   }
                  }  /*end if must dload*/
#endif

                  if (ret_stat & 1)                       
                  { 
                     /*class exists/od dloaded just construct it*/

                     ret_stat=om$construct(osnum = OM_Gw_TransOSnum_0,
                                           classname = cmd.class_name,
                                           p_objid = &cmd_objid,
                                           neighbor = OM_GS_NULL_NEIGHBOR);
                     if (!(ret_stat&1))
                     {
                        printf("OM_construct_object_by_name <%s> error\n",cmd.class_name);
                        om$report_error(sts = ret_stat);
                        om_error_flag=1;
                        construct_error_flag = 1;
                        ex$message(msgnumb = EX_F_InvalidCmd);
                     }
                     else /* connect cmd_obj */
                     {
                        if (!EX_chanselects)
                           if (!(1&(ret_stat = init_chanselect())))
                              goto om_error1;
             
                        ret_stat = om$send ( msg = message Root.connect(
                           to_cmd,ME.cmdserver->stkptr, my_id,
                           OM_Gw_TransOSnum_0, to_cmdstack, 0 ),
                           senderid = my_id,
			   targetos = OM_Gw_TransOSnum_0,
                           targetid = cmd_objid);      
                        if (!(ret_stat&1))
                        {
om_error1:
                           printf("OM_connect_me_by_name (cmdserver.command) error\n");
                           om$report_error(sts = ret_stat);
                           om_error_flag = 1;
                        }
                        else
                        {
                           ret_stat=om$send(mode = OM_e_wrt_object,
                           msg = message super_cmd.cmd_name(
                              rapstring, cmd.command_key,
                              cmd.path,cmd.exec_flag),
                              senderid = my_id,
                              p_chanselect = &commdstk,
                              from = ME.cmdserver->stkptr,
                              to = ME.cmdserver->stkptr);
                           if (!(ret_stat&1))
                           {
                              printf( "OM_send_channel (super_cmd.cmd_name) error");
                              om$report_error(sts = ret_stat);
                              om_error_flag=1;
                           }
                           if( !om_error_flag )
                           {
                              ex$message(msgnumb = EX_S_Clear);	  
                              ex$message(msgnumb = EX_M_Clear);	  
                              ex$message(msgnumb = EX_P_Clear);
                              ret_stat=om$send(mode = OM_e_wrt_object,
                              msg = message super_cmd.init(cmd.type,cmd.path),
                                 senderid = my_id,
				 p_chanselect = &commdstk,
				 from = ME.cmdserver->stkptr,
				 to = ME.cmdserver->stkptr);
                              if (!(ret_stat&1))
                              {
                                 if ( EX_is_auto_test() )
                                    fprintf(EX_auto_test_error_file,
                                       "super_cmd.init failed   <%s>\n",
                                       cmd.command_name_ptr);
                                 printf( "OM_send_channel (super_cmd.init) error");
                                 om$report_error(sts = ret_stat);
                                 om_error_flag=1;
                              }
                           }
                           if ( ! om_error_flag )
                           {
                              ret_stat=om$send(mode = OM_e_wrt_object,
                              msg = message super_cmd.help_topic(0,
                                 (char *)cmd.command_key),
				 senderid = my_id,
				 p_chanselect = &commdstk,
				 from = ME.cmdserver->stkptr,
				 to = ME.cmdserver->stkptr);
                              if (!(ret_stat & 1))
                              {
                                 printf("OM_send_channel (super_cmd.help_tpic) error\n");
                                 om$report_error(sts = ret_stat);
                                 om_error_flag=1;
                              }
                           }
                           if ( !om_error_flag )
                              ME.cmdserver->stklen++;
                        } /* not OM_connect error */
                     } /* not OM_construct error */
                     if (om_error_flag)
                     {
                        if (construct_error_flag != 1)
                        {
                           ret_stat=om$send(mode = OM_e_wrt_object,
                                    msg = message Root.delete(0),
                                    senderid = my_id,
				    targetos = OM_Gw_TransOSnum_0,
                                    targetid = cmd_objid);
                           check_error_status(ret_stat,
                              "OM_send_object (Root.delete) error");
                        }
                        ME.cmdserver->stkptr--;
                     }
                     else /* construct/connect success */
                     {
                        EX_call_cmdserver_func(EX_CMD_NEW);
                        if ( cmd.input_string != NULL )
                        {
                           int  resp;
                           long  bytecnt;
         		   resp = STRING;
         		   bytecnt = strlen(cmd.input_string) + 1;
         		   ret_stat = ex$putque(msg= &msg,response=&resp,
		                          byte = &bytecnt,
					  buffer = cmd.input_string);
                        }

#    if stackdebug
        printf("before stack size check,stklen = %d  stkptr = %d\n",
               ME.cmdserver->stklen,ME.cmdserver->stkptr);
#    endif

                        if ( ME.cmdserver->stklen > EX_CMD_STACK_SIZE )
                        {
                           ret_stat=om$send(mode = OM_e_wrt_object,
			         msg = message Root.delete(0),
				 senderid = my_id,
				 p_chanselect = &commdstk,
				 from = 0, to = 0);
                              ME.cmdserver->stklen=(ME.cmdserver->stkptr);
                              ME.cmdserver->stkptr--;
                              NSC--;
                              EX_call_cmdserver_func(EX_CMD_DROP);

                        }
		
#    if stackdebug
        printf("after stack size check, stklen = %d  stkptr = %d\n",
               ME.cmdserver->stklen,ME.cmdserver->stkptr);
#    endif


                        /* send sleep to previous cmds */

                        if (ME.cmdserver->stklen == 1)
                           NSC = 0;
                        if ((ME.cmdserver->stklen > 1) &&
                            (ME.cmdserver->form_cmd_detached))
                        {
                           /* normal commands are put to sleep */
                           /* form commands have disconnected themselves
                              from stack */
                           osk_num = OM_Gw_TransOSnum_0;
         		   ret_stat = om$get_objid_at_index(objid = my_id,
						    osnum = osk_num,
						    p_chanselect = &commdstk,
						    index = ME.cmdserver->stkptr - 1,
						    objidaddr = &topobj,
						    osnumaddr = &osnum1);
                           class_name[0] = '\0';
                           ret_stat = om$get_classname(osnum = osnum1,
				   objid = topobj,
			       classname = class_name);
                           sleep_type = (cmd.immediate_flag == 0) ?
                              EX_suspend : EX_nonsuspend;
                           if (cmd.immediate_flag == 0) 
                           {

                           ret_stat=om$send(mode = OM_e_wrt_object,
                           msg = message super_cmd.pre_sleep(&dyn_function,
                                                             &add_info),
                                       senderid = my_id,
                                       p_chanselect = &commdstk,
                                       from = NSC,
                                       to = ME.cmdserver->stkptr - 1);

                              /* not immediate cmd (suspending) */
                              ret_stat=om$send(mode = OM_e_wrt_object,
			               msg = message super_cmd.sleep(sleep_type),
                                       senderid = my_id,
                                       p_chanselect = &commdstk,
                                       from = NSC,
				       to = ME.cmdserver->stkptr - 1);
                              NSC = ME.cmdserver->stkptr;
                           }
                           else  /* immediate cmd ( non suspending ) */
                           {

             ret_stat=om$send(mode = OM_e_wrt_object,
                           msg = message super_cmd.pre_sleep(&dyn_function,
                                                             &add_info),
                                       senderid = my_id,
                                       p_chanselect = &commdstk,
                                       from = ME.cmdserver->stkptr - 1,
                       to = ME.cmdserver->stkptr - 1);

                              ret_stat=om$send(mode = OM_e_wrt_object,
			         msg = message super_cmd.sleep(sleep_type),
				 senderid = my_id,
			         p_chanselect = &commdstk,
				 from = ME.cmdserver->stkptr - 1,
 				 to = ME.cmdserver->stkptr - 1);
                           }
                           EX_call_cmdserver_func(EX_CMD_SLEEP);
                        }

                   ret_stat=om$send(mode = OM_e_wrt_object,
                           msg = message super_cmd.pre_wakeup(dyn_function,
                                                              add_info),
                           senderid = my_id,
                           p_chanselect = &commdstk,
                           from = ME.cmdserver->stkptr,
                           to = ME.cmdserver->stkptr);

          dyn_function = 0;/*once used clear function*/
                        add_info = 0;
                        /* send wakeup to newly created command */
                        ret_stat=om$send(mode = OM_e_wrt_object,
                           msg = message super_cmd.wakeup(EX_suspend),
                           senderid = my_id,
                           p_chanselect = &commdstk,
                           from = ME.cmdserver->stkptr,
                           to = ME.cmdserver->stkptr);
                        if ( !( 1&ret_stat))
                        {
                           if (EX_is_auto_test())
                              fprintf(EX_auto_test_error_file,
                                 "super_cmd.wakeup failed   <%s>\n",
                                 cmd.command_name_ptr);
                        }

                        EX_push_quiet(quiet_resp);
                     } /* end of construct connect success */
                  }/* end of dload/check classid */
                  else
                     ME.cmdserver->stkptr--;
               } /* command found */
               else
                  ME.cmdserver->stkptr--;
            }
            break;

         case TOGGLE_COMMAND:
         case D_COMMAND:   /* swap top 2  command objects */
            if (ME.cmdserver->stklen < 2)
            {
               ex$message(msgnumb = EX_S_NoCmd);
            }
            else  /* at least 2 commands on stack */
            {
               /* get objid of top 2 command objects */
               os_num = OM_Gw_TransOSnum_0;
               ret_stat = om$get_objid_at_index(objid = my_id,
                                                osnum = os_num,
                                                p_chanselect = &commdstk,
                                                index = ME.cmdserver->stkptr,
                                                objidaddr = &topobj,
                                                osnumaddr = &osnum1);
               if(!(1&ret_stat))
               {
                  om$report_error(sts = ret_stat);
                  printf("cmdserver swap cmd get topobjid failed\n");
                  *response = -1;
               }
               else  /* got objid of top stack */
               {
                  ret_stat = om$get_objid_at_index(objid = my_id,
                     osnum = os_num,
                     p_chanselect = &commdstk,
                     index = ME.cmdserver->stkptr - 1,
                     objidaddr = &nextobj,
                     osnumaddr = &osnum1);
                  if (!(1 & ret_stat))
                  {
                     om$report_error(sts = ret_stat);
                     printf("cmdserver swap cmd get nextobjid failed\n");
                     *response = -1;
                  }
                  else /* got both objids */
                  {
                     /* swap commands on channel */
 
                     if (!EX_chanselects)
                        if (!(1 & (ret_stat = init_chanselect())))
                           goto om_error2;
                     ret_stat = om$send( msg = message Root.disconnect(
                        to_cmd, my_id, OM_Gw_current_OS, to_cmdstack),
                        senderid = my_id,
                        p_chanselect = &to_cmdstack,
                        from = ME.cmdserver->stkptr,
                        to = ME.cmdserver->stkptr);
                     if (!(1 & ret_stat))
                     {
om_error2:
                        om$report_error(sts = ret_stat);
                        printf("cmdserver swap disconnect topobj error\n");
                        *response = -1;
                     }
                     else /* top disconnected */
                     {
                        /* try to disconnect nextobj */
                        ret_stat = om$send( msg = message Root.disconnect(
                           to_cmd, my_id, OM_Gw_current_OS, to_cmdstack),
                           senderid = my_id,
                           p_chanselect = &to_cmdstack,  
                           from = ME.cmdserver->stkptr - 1,
                           to = ME.cmdserver->stkptr - 1);
                        if (!(1 & ret_stat))
                        {
                           om$report_error(sts = ret_stat);
                           printf("cmdserver swap disconet nextobj error\n");
                           ret_stat = om$send ( msg = message Root.connect(
                              to_cmd,ME.cmdserver->stkptr, my_id,
                              OM_Gw_current_OS, to_cmdstack, 0 ),
                              senderid = my_id,
                              targetos = OM_Gw_TransOSnum_0,
                              targetid = topobj);      
                           check_error_status(ret_stat,
                              "reconnect topobj error");
                           *response = -1;
                        }
                        else /* next disconnected */
                        {
                           /* reconnect topobj */
                           ret_stat = om$send ( msg = message Root.connect(
                              to_cmd, ME.cmdserver->stkptr - 1, my_id,
                              OM_Gw_current_OS, to_cmdstack, 0 ),
                              senderid = my_id,
                              targetos = OM_Gw_TransOSnum_0,
                              targetid = topobj );      
                           if (!(1 & ret_stat))
                           {
                              om$report_error(sts = ret_stat);
                              printf("cmdserver swap can't reconnect top");
                              *response = -1;
                              ME.cmdserver->stkptr -= 2;
                           }
                           else
                           {
                              /* connect nextobj to top */

                              ret_stat = om$send ( msg = message Root.connect(
                                 to_cmd, ME.cmdserver->stkptr, my_id,
                                 OM_Gw_current_OS, to_cmdstack, 0 ),
                                 senderid = my_id,
			    	 targetos = OM_Gw_TransOSnum_0,
                                 targetid = nextobj);      
                              if (!(1 & ret_stat))
                              {
                                 om$report_error(sts = ret_stat);
                                 printf("cmdserver swap can't recon next");
                                 *response = -1;
                                 ME.cmdserver->stkptr--;
                              }
                              else
                              {
                                 /* send sleep to old  top  command */
                                 ret_stat=om$send(mode = OM_e_wrt_object,
			            msg = message super_cmd.sleep(EX_suspend),
				    senderid = my_id,
                                    p_chanselect = &commdstk,
				    from = ME.cmdserver->stkptr - 1,
 				    to = ME.cmdserver->stkptr - 1);

                                 EX_call_cmdserver_func(EX_CMD_SLEEP);

                                 /* send wakeup to new  top  command */
                                 ret_stat=om$send(mode = OM_e_wrt_object,
		                    msg = message super_cmd.wakeup(EX_suspend),
		                    senderid = my_id,
			            p_chanselect = &commdstk,
				    from = ME.cmdserver->stkptr,
 				    to = ME.cmdserver->stkptr);
                                 EX_call_cmdserver_func(EX_CMD_SWAP);
                                 EX_swap_quiet();
                              }
                           }
                        }
                     }
                  }
               }
            }
            break;

         case STATUS_DISP:
            if ( ME.cmdserver->stklen )
            {
               ret_stat=om$send(mode = OM_e_wrt_object,
                  msg = message super_cmd.status_disp(),
                  senderid = my_id,
                  p_chanselect = &commdstk,
                  from = ME.cmdserver->stkptr,
                  to = ME.cmdserver->stkptr);
               check_error_status(ret_stat,
                  "OM_send_channel (super_cmd.status_disp) error");
            }
            break;

         case RESET:
         case DATA:
            if (( ! ME.cmdserver->form_cmd_detached ) &&
                ( ME.cmdserver->stklen ) )
            {
               /* if this button was received by form command */
               /* put it back on the queue for the command    */

               size= sizeof ( struct EX_button );
               ret_stat = ex$putque ( msg = &msg,
                                     response = response,
                                     byte = &size,
                                     buffer = response_data );
            }
            break;

         case HELP:  /* send help to stkptr */
            if ( EX_help_proc_exist == 0  && !ige$SR_active() )
            {
               ex$help_init();
            }
            help_flag = 1;
            break;

        case OMPMS:
            OM_PMS();
            break;

         case EX_CMDSVR_RETURN: 
            *(int *)response_data = EX_CMDSVR_RETURN;
            return(OM_S_SUCCESS);
 
         case EX_EXIT:
            *(int *)response_data = EX_EXIT;
            return(OM_S_SUCCESS);

#ifdef ENV5
         case EX_CALC:
            EX_cut_calc_input();
            break;

         case EX_CALC_RETURN:
            EX_paste_calc_input();
            break;

         case EX_NEXT_SCREEN:
            if ( ex$is_interactive())
            {       
               Inq_SR_active(&SRmode,&SRwno,&SRno_area); 
               if ( SRmode != 1 )
                  Swap_vs();
            }
            break;
#endif
         case EX_CI_TEST_END:
            tmpstate = EX_msg_prev_state;
            fclose(EX_auto_test_error_file);
            ms$function( status = MS_F_STATUS  ); 
            ms$function( status =   MS_BOX_STATUS  ); 	       
            EX_auto_ci_test_flag = 1;
            EX_auto_jump = EX_old_auto_jump;
            EX_old_auto_jump = 0;
            break;

         default: 
            break;
      }  /* end switch */
   }  /* end while 1 loop */
}  /* method exec_cs */


method sleep_cs(int type_sleep)
{
  IGRlong msg;
  OM_S_CHANSELECT commdstk;

  commdstk.type = OM_e_addr;
  commdstk.u_sel.addr = &ME.cmdserver -> cmdstack;

    if( type_sleep == EX_REAL_SLEEP)
    {
      EX_cmddetach(&msg,-1);
    }
    if (ME.cmdserver->stklen)
    {
        msg = om$send (msg = message Root.delete(1),p_chanselect = &commdstk,
	                from=OM_K_MAXINT, to=0); 
        if (!(1&msg))
        {
            EX_call_cmdserver_func(EX_CMD_POP);
            printf ("\n clear stack error -- cmdserver.sleep\n");
            om$report_error (sts = msg);
        }
        ME.cmdserver->stkptr=(-1);
        ME.cmdserver->stklen=0;
    }

    return(OM_S_SUCCESS);
} /* method sleep_cs */

method disconnect_from_stack ( int *msg )
{
    int ret_stat;

    if (!EX_chanselects)
    	if (!(1&(ret_stat = init_chanselect())))
		goto om_error;

    *msg = MSSUCC;
 
    ret_stat = om$send( msg = message Root.disconnect(
                   to_cmd, my_id, OM_Gw_current_OS,
                   to_cmdstack),
                   senderid = my_id,
                   p_chanselect = &to_cmdstack,     
                   from = ME.cmdserver->stkptr,
                   to = ME.cmdserver->stkptr);
    if( !(1&ret_stat))
    {
	om_error:
          *msg = MSFAIL;
          om$report_error(sts = ret_stat);
          printf("cmdserver  disconnect error\n");
    }
    ME.cmdserver->form_cmd_detached = 0;/*dont send sleep to top of stack*/
    ME.cmdserver->stklen=(ME.cmdserver->stkptr);
    ME.cmdserver->stkptr--;
    EX_call_cmdserver_func(EX_CMD_DISCONNECT);
    return (OM_S_SUCCESS);
 }

method clear_stack()
{
   int num_times;
   int cnt;
   int ret_stat;

   OM_S_CHANSELECT commdstk;

           if (ME.cmdserver->stklen!=0)
           {

               commdstk.type = OM_e_addr;
               commdstk.u_sel.addr = &ME.cmdserver -> cmdstack;

               ret_stat=om$send(mode = OM_e_wrt_object,
                                   msg = message super_cmd.sleep(EX_suspend),
                                   senderid = my_id,
                                   p_chanselect = &commdstk,
                                   from = ME.cmdserver->stkptr,
                                   to = ME.cmdserver->stkptr);

               EX_call_cmdserver_func(EX_CMD_SLEEP);

               num_times=(EX_cmdserver_save_last == 0 ) ? ME.cmdserver->stkptr :
	                                              ME.cmdserver->stkptr - 1;
               for (cnt=num_times;cnt>=0;cnt--)
               {

                 ret_stat=om$send(mode = OM_e_wrt_object,
                                  msg = message Root.delete(0),
                                  senderid = my_id,
                                  p_chanselect = &commdstk,
                                  from = cnt,
                                  to = cnt);
               }
               if ( EX_cmdserver_save_last == 0 )
	       {
                  ME.cmdserver->stkptr=(-1);
                  ME.cmdserver->stklen=0;
               }
	       else
	       {
                  ME.cmdserver->stkptr=0;
                  ME.cmdserver->stklen=1;
               }
	       NSC = 0;
               EX_call_cmdserver_func(EX_CMD_CLEAR_STACK);	

           }
           EX_cmdserver_save_last = 0;
           EX_clear_quiet();
	   ex$message(msgnumb = EX_S_Clear);	  
	   ex$message(msgnumb = EX_M_Clear);	  
	   ex$message(msgnumb = EX_P_Clear);	  	  	  
     return(OM_S_SUCCESS);
}




int EX_is_cmd_stack_empty()
{
   return( (EX_cmd_stack_empty == 1) ? 1 : 0 );
}

int EX_set_cmdserver_debug()
{

int prompt_status;
int response;
char response_data[1024];
    EX_cmdserver_debug = (EX_cmdserver_debug) ? 0 : 1;
    if (EX_cmdserver_debug)
     {

      tog_file = 0;
      prompt_status = ex$create_prompt(message_no = EX_P_TogFile,
              left_prompt = EX_P_Yes,
              right_prompt = EX_P_No,
              response = &response,
              response_data = response_data);

      if (prompt_status == EX_LEFT_MATCH)
        {
        tog_file = (FILE *) fopen("tog.cmds", "w+");
        }
     }
    else
     {
      if (tog_file)
#ifndef NT
         close (tog_file);
#else
         fclose (tog_file);
#endif
     }
    return(1);
}



int EX_help_init()
{
  int num_entry;
  int path_found, j;
  int status; 
  char *def_file;
  char *exec_file;
  char *font_dir;
  char *msg_dir;
  char *sym_dir;
  int file_found;
  char *colon;
  struct HP_doc_id_struct doc;
  char language[128];
  char help_string[256];
  FILE *fp;

  char **help_path;       	     
  char class_name[16]; 
  char string[128];



     help_path = 0;

     if (  ex$is_interactive()  )
	   { 
	     num_entry = 0;
	     def_file = exec_file = msg_dir = sym_dir = font_dir = 0;

         path_found = TRUE;
         ex$language(language = class_name);
                  /* use class_name to hold language name */
    status = TRUE;
    file_found = FALSE;
    for( j=0; status == TRUE; j++)
    {
     if( status = ex$get_path(index=j,path=string,len= sizeof(string) ) )
       {
	    strcat(string,"config/");
        EX_inq_language(language);
        strcat(string,language);
        strcat(string,"/HELPINFO");
        if ( ( fp = (FILE *) fopen ( string , "r") ) )
         {
         file_found = TRUE;
         status = FALSE;
         if ( fgets ( help_string,128,fp ) != NULL )
          {
           colon = strchr(help_string,':');
           if (colon)
            {
            *colon = 0;
            colon++;
            doc.logical_name = help_string;
            }
           else
            {
            file_found = FALSE;
            printf("No document name in HELPINFO\n");
            break;
            }
           doc.language = colon;
           colon = strchr(colon,':');
           if (colon)
            {
            *colon = 0;      
            colon++;
            doc.version = colon;
            colon = strchr (colon,'\n');
            if (colon)
              *colon = 0;
            }
           else
            {
            file_found = FALSE;
            printf("No document version in HELPINFO\n");
            }
           }
         fclose ( fp );
	    }
	  }
    }/* end for each path */
 if (file_found)
   {
    status = Help_set_Xdisplay(getenv("DISPLAY"));
    if ( status != HP_SUCCESS )
      {
      fprintf(stderr, "Help_set_Xdisplay failed\n");
      return(1);
      }
#ifdef ENV5
      {
      double double_x;
      double double_y;
      int x;
      int y;
      IGE_get_menu_scaling_factors(&double_x,&double_y);
      double_x = 499.*double_x;
      double_y = 99.*double_y;
      x = double_x;
      y = double_y;
      status = Help_origin(x,y);
      }
#endif
#ifdef X11
      status = Help_origin(450,99);
#endif
    if ( status != HP_SUCCESS )
      {
      fprintf( stderr,"Help_origin failed\n");
      return(1);
      }
    status = Help_document(&doc);
    if ( status )
     {
     fprintf(stderr,"Help_document failed\n");
     return (1);
     }
    else
     {
     EX_help_proc_exist = 1;
     }
    }
 else
     {
     fprintf(stderr,"No HELPINFO file found\n");
     }
   }
	   return(1);
}

int EX_session_init_cmd( cmd_cntrl )
struct EX_cmd_cntrl *cmd_cntrl;
{
   int     lo;
   register struct EX_cmd *cmd_entry;
   register int   hi;
   register int    i;

   if ( EX_only_one_session_init_flag == 0 )return(1);
   else EX_only_one_session_init_flag = 0;

   /* now add the retrieve command */
   if ( ex$is_interactive() )
   {
     EX_add_fun( &EX_initial_cmds, 0, EX_ret_cmd);
   }

   lo = 0;
   hi = cmd_cntrl->no_of_cmd;

   for ( i = lo; i < hi; ++i )
   {
       cmd_entry =&(cmd_cntrl->cmd[i]);
      if( (cmd_entry->exec_flag & EX_SINIT) == EX_SINIT )   
      {
          EX_add_fun( &EX_initial_cmds, 0, cmd_cntrl->cmd[i].command_key );
      }
   }
   return(1);
}



int EX_file_init_cmd( cmd_cntrl )

struct EX_cmd_cntrl *cmd_cntrl;
{
   int     lo;
   register int   hi;
   register int    i;

   lo = 0;
   hi = cmd_cntrl->no_of_cmd;

   for ( i = lo; i < hi; ++i )
   {
      if( (cmd_cntrl->cmd[i].exec_flag & EX_FINIT) == EX_FINIT )   
      {
          EX_add_fun( &EX_initial_cmds, 0, cmd_cntrl->cmd[i].command_key );
      } 
   }
   return(1);
}

int EX_blank_msg()
{
    return(1);
}  

int EX_ci_test_start( filename )
char *filename;
{
   ms$function( status = MS_F_STATUS  , function = EX_blank_msg );
   ms$function( status = MS_BOX_STATUS , function = EX_blank_msg );
   EX_auto_ci_test_flag = 1;
   EX_old_auto_jump = EX_auto_jump;
   EX_set_auto_jump();
   if (EX_auto_test_error_file = (FILE *) fopen(filename, "w"))
   {
      fprintf(EX_auto_test_error_file,"Automatic testing of commands:\n\n");
      EX_auto_ci_test_flag = 1;
   }
   return(1);
}

EX_ci_test_end()
{
   long msg;
   int resp;
   long size=1;
   char respd[2];
   respd[0] = 0;
   resp = EX_CI_TEST_END;

   ex$putque( msg = &msg, pos=BACK, response=&resp, byte=&size, buffer=respd ); 
   return(1);
}


int EX_set_auto_jump()   /* this is a toggle */
{
    EX_auto_jump = (EX_auto_jump) ? 0 : 1;
    return(1);
}


EX_jump()
{
    longjmp(jmpbuf,1);
    return(1);
}

int EX_is_auto_jump()
{
   return( EX_auto_jump );
}
int EX_is_auto_test()
{
   return( EX_auto_ci_test_flag  );
}

int EX_auto_test_print_err(signo)
int signo;
{
/*helpnt*/
#ifndef NT
  if( EX_is_auto_test() )
  {
    switch( signo )
    {
      case  SIGIOT :
          fprintf(EX_auto_test_error_file,"I/O Trap instruction\n");
          break;   
      case  SIGEMT :
          fprintf(EX_auto_test_error_file,"Emulator Trap instruction\n");
          break;   
      case  SIGFPE :
          fprintf(EX_auto_test_error_file,"Floating-point exception\n");
          break;   
      case  SIGILL :
          fprintf(EX_auto_test_error_file,"Illegal instruction\n");
          break;   
      case  SIGBUS :
          fprintf(EX_auto_test_error_file,"Bus error\n");
          break;   
      case  SIGSEGV :
          fprintf(EX_auto_test_error_file,"Segmentation violation\n");
          break;   
      case  SIGSYS :
          fprintf(EX_auto_test_error_file,"Bad argument to system call\n");
          break;   
      case  SIGPIPE :
          fprintf(EX_auto_test_error_file,"Write on a pipe not opened for reading\n");
	  break;
      default:
          break;   
    }
  }
#endif
  return(1);
}


int EX_cmdserver_save_last_cmd()
{
   EX_cmdserver_save_last = 1;
   return(1);
}


end implementation cmdserver;
