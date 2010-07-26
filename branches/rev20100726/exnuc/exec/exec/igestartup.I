class implementation exec;
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/ipc.h>
#include <errno.h>
#include <pwd.h>
#include <signal.h>
#include <limits.h>
#include <OMparameters.h>
#include <OMerrordef.h>
#include <OMprimitives.h>
#include <OMminimum.h>
#include <igrtypedef.h>


#ifdef ENV5
#include <tools.h>
#include <sys/sysingr.h>
#endif

#include <exdef.h>
#include <ex.h>
#include <expriv.h>
#include <exmacros.h>
#include <exms.h>
#include <EXproduct.h>
#include <msdef.h>
#include <msmacros.h>
#include <execmsg.h>
#include <igeterm.h>
#include <igewindow.h>
#include <igewindef.h>
#include <igewinmacros.h>
#include <string.h>
#include <ipcl.h>
#include "exsysdep.h"

#include "wl.h"
#include "cm.h"
#include "igecolmacros.h"

#ifdef X11
#ifdef SUNOS
#include <values.h>
#define DBL_MAX MAXDOUBLE
#endif

#if defined( CLIX )
#include <X11/X.h>
#include <X11/extensions/XInput.h>
#include <X11/extensions/XDigitizer.h>
#endif

#if defined (CLIX) || defined (IRIX5) || defined (SUNOS5)
%safe
#include <X11/Xlibint.h>
%endsafe
#endif

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <alloca.h>

%safe
#include <X11/Xresource.h>
#include <X11/StringDefs.h>
#include <X11/IntrinsicP.h>
#include <X11/Intrinsic.h>

extern XrmDatabase   EXrDB;
extern Widget        EXtoplevel;
extern OMuint OM_Gf_verbose_error;
extern OMuint OM_Gf_verbose_warning;
static EX_sync_flag = 0;
%endsafe

extern  int INGR_DigButtonPress;
extern  int INGR_DigButtonRelease;
extern  int INGR_DevButtonPress;
extern  int INGR_DevButtonRelease;
extern  int INGR_DevButtonPress_class;
extern  int INGR_DevButtonRelease_class;

#if defined( CLIX ) && defined( X11 )
   XDevice        *EX_xdev_ptr;         
#endif

extern int           EX_read_product_data();
extern int           EX_init_dload();
extern int           EX_product_dload();
extern int           LowerCase();
extern Display       *EXdisplay;
extern int           DIR_G_init;
extern char          EX_display_name[];
extern int           IGEclosest_match_colors();

#if defined( X11 )
#if defined( OPENGL )
extern int DPglx_choose_visual( struct WLcontext_info *context,
                               XVisualInfo *avail_visuals,
                               int num_avail,
                               int *chosen_index );
#endif
#endif

extern OMuword OM_Gw_max_modules;
extern OMuword OM_Gw_max_ref_files;

extern int EX_max_modules;
extern int EX_max_ref_files;

#define MAX_TOTAL  60
#endif

#define debug 0

%safe
static char          *OM_params[]={ "", ""};
%endsafe
extern int                          EX_use_mloc;
extern struct module_params         **module_data;
extern struct EX_visible_module     *module_table;
extern struct EX_invisible_module   *invisible_table;
extern struct EXevent_queue         *event_queue_front,
                                    *event_queue_back;
extern struct EX_global             EX_global_var;
extern struct EX_pmenu_entry        EX_paper_menu[EX_PMENU_NUM];
extern struct EX_memnode            *EXmem;
extern struct IGEterm_info          term_info;
extern struct EX_cmd_cntrl          *EX_cmdlist_ptr;

extern short            EX_linebuffer_flag;
extern short            MS_Gs_messages_on;
extern uword            EX_exec_osnum;
extern uword            EX_active_OS_num;
extern OM_S_OBJID       EX_active_module;
extern OM_S_OBJID       EX_exec_id;
extern OM_S_OBJID       absdig_id ;
extern int              EX_same_file;
extern int              EX_index;
extern int              EX_mod_type;
extern int              EX_create;
extern int              EX_driver_exist; 
extern int              timer_no;  /* timer for backup */
extern int              active_module_num;
extern int              EX_batch_mode;
extern int              EX_help_proc_exist;
extern char             EX_filename[256];
extern char             EX_version[120];
extern char             EX_date[35];
extern char             EX_runname[20];

extern short            EX_echo_flag;
extern int              EX_entry,
                        EX_entry_full;
extern int              EX_pnt_entry,
                        EX_pnt_entry_full;
extern char             EX_keyin_cmd[EX_RCL_MAX_ENTRY][EX_RCL_MAX_LEN];

extern int              EX_ext_event_base;
extern int              EX_ext_error_base;

/* EX_RCL_.... defined in expriv.h */

extern unsigned int     OM_Gf_mailbox;
extern unsigned int     OM_Gf_process_unknowns;
extern int     		EX_process_unknowns;
extern char             *EX_firstcmd;
extern int              DIR_G_init;
extern char    *getenv(); 

extern int              EX_context_type;
extern int              EX_context_depth;
extern int              EX_hilite;
extern int		EX_double_buffer;

void IGEExit(status)
int status;
{
   char  file_name[15];
   int   have_file;

   if (OM_Gf_mailbox)
      EX_rm_msgque();   /* fortran/other process  task msg queue */
   if (EX_help_proc_exist == 1)
      Help_kill(); 
   if (ex$is_interactive() && (MS_menus_displayed())
                                            && EX_use_mloc )
   {
      EX_get_mloc_file(file_name, &have_file); /* get menu loc file name */
      MS_save_locations(file_name);
   }

   /*  Exit the Drawing and Windowing Layer  */
  
   DLexit();
   WLexit();

   FSExit();
   exit(status);
}


int IGE_startup(argc, argv, mode)
int   argc;
char  *argv[];
int   mode;
{
   extern int     ihfulfz_01();

#if defined( CLIX ) && defined( X11 )
     XExtCodes  *ext_ptr;
#endif

   extern long    strtol();

   register       i;
   register char  *temp, *temp1, *temp2;
  
   int            status,
                  margc,
                  char_len,
                  num_entry;
   char           *env_char1,
                  *env_char2,
                  *env_char3,
                  *spath,
                  **margv,
                  **menvp;
   key_t          EX_getkey();
   OM_S_OBJID     exec_id,
   	          NOD_object;
   uword          exec_classid;
   char           language[40];

   EX_firstcmd = NULL;

   if (mode == EX_BATCH)
      EX_batch_mode = EX_BATCH;
   else
      EX_batch_mode = EX_INTERACT;

   if (EX_batch_mode == EX_INTERACT)
   {

#ifdef ENV5
      status = syscall(SYSINGR, SINGRNSCREEN);
      if (status == 0)
      {
         fprintf(stderr, "IGE_startup: You cannot run interactively on a server\n");
    	 exit(1);
      }
#endif

      MS_Gs_messages_on = 1;
      EX_echo_flag = 1;
   }
   else
   {
      MS_Gs_messages_on = 0;
      EX_echo_flag = 0;
   }

   EX_linebuffer_flag = 0;
   EX_cmdlist_ptr = 0;
   active_module_num = 0;
   event_queue_front = 0;
   event_queue_back = 0;
   timer_no = -1;
   absdig_id = NULL_OBJID;

   if (temp = strrchr(argv[0], '/'))
      strcpy(EX_runname, temp + 1);
   else
      strcpy(EX_runname, argv[0]);

   module_set_def_dir();
   module_set_pathname(argv[0]);
   module_get_def_dir(argc, argv);

   if (!(1 & EX_read_product_data()))
      exit(1);

   if (!(1 & EX_set_srch_path()))
      exit(1);

   {
      int     i;
      key_t   ipcl_key=IPCL_QKEY;
      getargs(&margc, &margv, &menvp);

      for ( i=1; i<margc; i++ )
      {
         if(!strncmp("OMipcl=", margv[i], 7)) {
            char   *tmp=margv[i]+7;
            if( tmp[0] =='0' ) {
               if( tmp[1] == 'x' )
                  sscanf( &tmp[2], "%x", &ipcl_key );
               else
                  sscanf( tmp, "%o", &ipcl_key );
            } else if ( tmp[0] < '0' || tmp[0] >'9' ) {
               int ii;
               for( ii=0; ii<4; ii++)  ((char *)&ipcl_key)[3-ii] = tmp[ii];
            } else {
               sscanf( tmp, "%d", &ipcl_key );
            }
         }
      }

      if( -1 ==  IPCL_init( 0, ipcl_key, 0666, IPC_CREAT ) ) {
         perror("\nUnable to establish IPCL message queue ");
         exit(1);
      }
   }

   if (!EX_init_locale()) /* IGEEnter expects menus to be set up */
   {
      fprintf(stderr, "IGE_startup: EX_init_locale error\n");
      exit(1);
   }

   EX_get_srch_path(&spath, &num_entry);
   if (!(temp = om$malloc(size = (strlen(spath) + 1))))
      return(OM_E_NODYNMEM);
   temp2 = temp;
   strcpy(temp, spath);
   if (!(env_char1 = om$malloc(size = (strlen(temp) + 10 * num_entry + 200))))
      return(OM_E_NODYNMEM);
   strcpy(env_char1, "OMSYSGENPATH=");
   while(temp1 = strtok(temp, ":"))
   {
      strcat(env_char1, temp1);
      strcat(env_char1, "config/:");
      temp = NULL;
   }
   temp = temp2;  /* Reset temp to beginning of malloced area */
   OM_params[0] = env_char1;
   OM_params[1] = NULL;
   if (!(1&(status = om$runtime_init(paramc = 1, param_list = OM_params))))
   {
       fprintf(stderr, "IGE_startup: OM_runtime_init error\n");
       om$report_error(sts = status);
       exit(status);
   }
   OM_Gf_process_unknowns = EX_process_unknowns;
   om$dealloc(ptr = env_char1);

   EX_max_modules = OM_Gw_max_modules + 2;
   EX_max_ref_files = OM_Gw_max_ref_files;

   /* set up font env variable */
   EX_inq_language(language);
   char_len = strlen(language) + 16;  /* length of config/language/typeface */
   strcpy(temp, spath);    /* spath = EX_search_path; temp already malloced */
   if (!(env_char2 = om$malloc(size=
      (strlen(temp) + char_len * num_entry + 20))))
      return(OM_E_NODYNMEM);
   strcpy(env_char2, "FS_TFPATH=.");
   while(temp1 = strtok(temp, ":"))
   {
      sprintf(env_char2, "%s:%sconfig/%s/typeface",
         env_char2, temp1, language);
      temp = NULL;
   }
   temp = temp2;  /* Reset temp to beginning of malloced area */
   if (putenv(env_char2) != 0)
      fprintf(stderr, "IGE_startup: cannot put Fontserver typeface environment variable. <%s>\n",
         env_char2);

   strcpy(temp, spath);
   char_len = strlen(language) + 15;  /* length of config/language/charmap */
   if (!(env_char3 = om$malloc(size =
      strlen(temp) + char_len * num_entry + 20)))
      return(OM_E_NODYNMEM);

   strcpy(env_char3, "FS_CMPATH=.");
  
   while(temp1 = strtok(temp, ":"))
   {
      sprintf(env_char3, "%s:%sconfig/%s/charmap",
         env_char3, temp1, language);
      temp = NULL;
   }
   temp = temp2;  /* Reset temp to beginning of malloced area */
   if (putenv(env_char3) != 0)
      fprintf(stderr, "IGE_startup: cannot put Fontserver charmap environment variable. <%s>\n",
         env_char3);

   if (!
#ifdef X11
   IGEEnter (argc, argv)
#else
   IGEEnter ()
#endif
      )
      exit(1);

   if (!EX_init_dload() || !EX_product_dload())
      exit(1);

   /* set up message queue for other process */

   if (OM_Gf_mailbox)
      EX_set_msgque();

   /* ms$init depends on IGEEnter & FSenter */
   ms$init();
   MS_Gs_messages_on = (EX_batch_mode == EX_INTERACT) ? 1 : 0;

   EX_set_interrupt();

   if (!(module_data = (struct module_params **) om$calloc(size=sizeof(int),
      num = (EX_MAX_MODULES + EX_MAX_INVIS_MODULES))))
   {
      fprintf(stderr, "IGE_startup: Could not allocate module data table\n");
      exit(1);
   }
   if (!(module_table = (struct EX_visible_module *) om$calloc
      (num=EX_MAX_MODULES, size = sizeof(struct EX_visible_module))))
   {
      fprintf(stderr, "IGE_startup: Could not allocate module table\n");
      exit(1);
   }
   if (!(invisible_table = (struct EX_invisible_module *) om$calloc(
      size = sizeof(struct EX_invisible_module), num=EX_MAX_INVIS_MODULES)))
   {
      fprintf(stderr, "IGE_startup: Could not allocate invisible table\n");
      exit(1);
   }

   for (i = 0; i < EX_MAX_MODULES; i++)
   {
      module_table[i].module_my_id = NULL_OBJID;
      module_table[i].filed_id = NULL_OBJID;     
      module_table[i].permis_flag = EX_read_write;
   }
   for(i = 0; i < EX_MAX_INVIS_MODULES; i++)
   {
      invisible_table[i].module_my_id = NULL_OBJID;
      invisible_table[i].filed_id = NULL_OBJID;
   }

#ifdef ENV5

   if (EX_batch_mode == EX_INTERACT)
   {
      Set_keyboard_mode(KEYBD_DEC_3KEY_MODE);
      Swapvs_event_setup();
      Enable_events(BUTTON_EVENT   |
                    KEYBOARD_EVENT |
		    REFRESH_EVENT  |
		    DELETE_EVENT   |
		    COVER_EVENT    |
		    COLLAPSE_EVENT |
		    EXTRA_EVENT    |
		    MENUBAR_EVENT  |
		    WINDOW_USER_ICON_EVENT |
		    USER_EVENT  |
                    SWAPVS_EVENT |
		    TIMER_EVENT );
   }
   else
      Enable_events(TIMER_EVENT );
#endif

   EX_driver_exist = 0;
#ifdef X11
	/*  On X based systems, qid turns out to be 0 ( valid qid) if EMS
is invoked for the first time after reboot/cold start. On clippers, however
smgr seems to be creating message queues during reboot/coldstart resulting
a non-zero qid.  This affects 'stop sign' misbehaviour on X   -Mohan  */
   if ((temp = getenv("DRIVERQID")) )
#else
   if ((temp = getenv("DRIVERQID")) && atoi(temp))
#endif
      EX_driver_exist = 1;

   status = om$get_classid(classname = "exec", p_classid = &exec_classid);
   if (!(1&status))
   {
      fprintf(stderr, "IGE_startup: error getting exec classid\n");
      om$report_error(sts = status);
      IGEExit(1);
   }

   status = om$construct(osnum = OM_Gw_current_OS, classid = exec_classid,
                       p_objid = &exec_id, neighbor = OM_GS_NULL_NEIGHBOR);
   if (!(1&status))
   {
      fprintf(stderr, "IGE_startup: error constructing exec object\n");
      om$report_error(sts = status);
      IGEExit(1);
   }

   EX_exec_id = exec_id;
   EX_exec_osnum = OM_Gw_current_OS;  

   status = ex$get_NOD(NODname = "IGENOD",pobjid = &NOD_object,create=TRUE,
                        mod_osnum=OM_Gw_TransOSnum_0);
   if (!(1 & status))
   {
      fprintf(stderr, "IGE_startup: error constructing IGENOD\n");
      om$report_error(sts = status);
      IGEExit(1);
   }

   for (i=0; i<EX_PMENU_NUM; i++)
   {
      EX_paper_menu[i].win_id = NULL_OBJID;
      EX_paper_menu[i].num_of_cmds = 0;
      EX_paper_menu[i].p_cmd = NULL;         
      EX_paper_menu[i].menu_name[0] = '\0';
   }

#if defined(X11) && defined(CLIX)
    
    ext_ptr = XInitExtension( EXdisplay, DIGITIZERNAME );
    
    EX_xdev_ptr = XOpenDigitizer( EXdisplay ) ;

    if ( ( EX_xdev_ptr != NULL )  && ( EX_xdev_ptr != ( XDevice *) BadAlloc ) )
    {
       XQueryDigitizerExtension( EXdisplay, &EX_ext_event_base, &EX_ext_error_base);

       DeviceButtonPress( EX_xdev_ptr, INGR_DevButtonPress,INGR_DevButtonPress_class);
       DeviceButtonRelease( EX_xdev_ptr, INGR_DevButtonRelease,INGR_DevButtonRelease_class);

       INGR_DigButtonPress   = EX_ext_event_base + DigButtonPress;
       INGR_DigButtonRelease = EX_ext_event_base + DigButtonRelease;
/*       
printf("event base=%d error_base=%d\n",EX_ext_event_base, EX_ext_error_base);
printf("INGR_DigButtonPress(event/mask)= %d %d\n",INGR_DigButtonPress,INGR_DigButtonPress_class);
printf("INGR_DigButtonRelease(event/mask)= %d %d\n",INGR_DigButtonRelease,INGR_DigButtonRelease_class);
*/
    }
#endif


   /* for recal keyin */
   EX_entry = 0;
   EX_entry_full = 0;
   EX_pnt_entry = 0;
   EX_pnt_entry_full = 0;

   EX_init_keyboard();
  
   /* init message files  */

   if ( EX_batch_mode == EX_INTERACT )
   {
      EX_init_session();  /* help function button files pocketmenu */

      status = om$send(mode = OM_e_wrt_object, msg = message exec.wake_up(),
		     senderid = OM_GO_TransOS_0, targetid = exec_id);
      if (!(1&status))
      {
	  fprintf(stderr, "IGE_startup: error from exec wakeup\n");
	  om$report_error(sts = status);
      }     
      IGEExit(0);
   }



   return(1);
} /* ex_main */



%safe
#ifdef X11
static void setVlt(dest, src, min, max, flags)
XColor	*dest;
unsigned short src[][3];
int	min;
int	max;
char	flags;
{
      int slot;

      for (slot = min; slot < max; slot++)
      {
         dest[slot].pixel = slot;
         dest[slot].red = src[slot-1][0];
         dest[slot].green = src[slot-1][1];
         dest[slot].blue = src[slot-1][2];
         dest[slot].flags = flags;
      }
}
#endif

#argsused

#if defined (X11)
int IGEEnter(argc, argv)
int   argc;
char *argv[];
#elif defined (ENV5)
int IGEEnter()
#else
#error " A windowing system must be defined"
#endif
{
   int                     status;
   char                    msgtext[80];
   struct WLinit           wl_init;
   struct WLinit_ret_val   wl_ret;

#ifdef X11   
   XrmOptionDescRec        Xrm_options;
   WLuint16                lscreen_no;
   int                     screen_type;
   WLuint32                ctx_num;
   struct WLcontext_info  *wl_ctx_info_p;
   short                   max_ingr_slot;
   struct WLnative_info    native_info;
#endif


   /*============================================*/
   /*  set up the WL initialize input structure  */
   /*============================================*/

   if ( EX_batch_mode == EX_INTERACT )
      wl_init.batch_mode = 0;
   else
      wl_init.batch_mode = 1;

#ifdef X11
   wl_init.display_name = NULL;
   wl_init.flags = WL_USE_XTOOLKIT;
   wl_init.shell_name = argv[0];
   wl_init.app_class = argv[0];

   if (EX_display_name[0] == 0)
   {
      wl_init.options = NULL;
      wl_init.num_options = 0;
   }
   else
   {
      Xrm_options.option = EX_display_name;
      wl_init.options = &Xrm_options;
      wl_init.num_options = 1;
   }

   wl_init.argc = (Cardinal *)&argc;
   wl_init.argv = argv;
#endif

   /*==================================*/
   /*  Initialize the Windowing Layer  */
   /*==================================*/

   status = WLinitialize ( &wl_init, &wl_ret );
   if (status != WL_SUCCESS)
   {
      fprintf (stderr, "Failure reported from WLinitialize:: %x\n",status);
      IGEExit(1);
   }


#if defined( X11 )
#if defined( OPENGL )
   
   /*==============================================*/
   /*  For X11 and OPENGL set the visual function  */
   /*==============================================*/

   WLglx_set_choose_visual_function ( DPglx_choose_visual );

#endif
#endif

   /*================================*/
   /*  Initialize the Drawing Layer  */
   /*================================*/

   status = DLinitialize ( );
   if (status != WL_SUCCESS)
   {
      fprintf (stderr,"Failure reported from DLinitialize:: %x\n",status);
      IGEExit(1);
   }
   /*=====================================*/
   /*  Initialize the Display List Logic  */
   /*=====================================*/

   status = DPdlist_initialize ( );
   if (!(1&status))
   {
      fprintf(stderr,"Failure reported from DPdlist_initialize:: %x\n",status);
      IGEExit(1);
   }

#ifdef X11
   EXdisplay = wl_ret.display;
   EXtoplevel = wl_ret.widget;
#endif

   /*=====================================================*/
   /*  Make a call to setup the contexts for each screen  */
   /*=====================================================*/

   status = CMsetup_contexts ( EX_double_buffer, EX_context_type,
                               EX_context_depth, EX_hilite );
   if (status != CM_SUCCESS)
   {
      fprintf(stderr,"Failure reported from CMsetup_contexts:: %x\n",status);
      IGEExit(1);
   }

   status = IGEload_term_info();
   if ((EX_batch_mode == EX_INTERACT) && (!status))
   {
      fprintf(stderr, "\nYou must configure your Interpro to 5-plane virtual screen mode.\n\n");
      ex$message(msgnumb = EX_F_WrongVirScn);
      IGEExit(1);
   }

   status = get_modtype_data ( EX_runname, msgtext, NULL, NULL, NULL, NULL );
   if (1&status)
   {
      EX_set_logo(msgtext);
   }       
   
   FSEnter(0);

   FEI_enter();       /* FEI_enter will worry about no screen case */

#if defined( X11 )
   status = WLget_active_screen( &lscreen_no, &screen_type);
   if (status != WL_SUCCESS)
   {
      fprintf(stderr,"Failure reported from WLget_active_screen:: %x\n",status);
      IGEExit(1);
   }

   CMget_exnuc_forms_context( lscreen_no, &ctx_num);
   if (status != CM_SUCCESS)
   {
      fprintf(stderr,"Failure reported from CMget_exnuc_forms_context:: %x\n",status);
      IGEExit(1);
   }

   /* get the native info */
   WLget_native_info_from_context( lscreen_no, ctx_num, &native_info);

   /* find the max slot a forms color is in. */
   ige$get_FI_COLOR_phys_slot( context_no = ctx_num,
                            FI_DEFINE = -1,
                            phys_slot_num = &max_ingr_slot);

   /* sets up the mappings for Xforms in range 1 - max_ingr_slot */
   _FI_colormap_notify(native_info.colormap, max_ingr_slot);
#endif

   if (EX_batch_mode == EX_INTERACT)
      EX_start_copyright();

   return(1);
}
%endsafe


#ifdef X11
void EX_set_sync()
{
   EX_sync_flag = 1;
}

void EX_sync_on()
{
   XSynchronize(EXdisplay,1);
   fprintf(stderr, "SYNC ON\n");
}

void EX_sync_off()
{
   XSynchronize(EXdisplay,0);
   fprintf(stderr, "SYNC OFF\n");
}
#endif


int EX_is_batch()
{
   return( EX_batch_mode);
}

int EX_is_interactive()
{
   return ( EX_batch_mode == EX_INTERACT );
}



static struct {
		char name[40];
		int user_time;
		int system_time;
		int real_time;
		int stack_pos;
	      } timing_test[100];
%safe
static int time_count = 0;
static int stack_count = 0;
%endsafe 
static struct tms  start_time_buf[10],end_time_buf[10];  
static int	   start_real_time[10],end_real_time[10];


void EX_clear_timing()
{
    time_count = 0;
    stack_count = 0;
}

void EX_start_timing()
{
	start_real_time[stack_count] = time((long *) 0);
	times(&start_time_buf[stack_count++]);
}

void EX_end_timing(string)
char *string;
{
	strcpy(timing_test[time_count].name,string);
	times(&end_time_buf[--stack_count]);
	end_real_time[stack_count] = time ((long *) 0);

	timing_test[time_count].stack_pos = stack_count;
	timing_test[time_count].real_time = end_real_time[stack_count] -
					  start_real_time[stack_count];
	
	timing_test[time_count].user_time = end_time_buf[stack_count].tms_utime -
					  start_time_buf[stack_count].tms_utime;

	timing_test[time_count++].system_time = end_time_buf[stack_count].tms_stime -
					    start_time_buf[stack_count].tms_stime;
}

void EX_print_timing()
{
   int i;
   double user_time;
   double system_time;
   double total_time;
   int    real_time;
   double io_time;
   int    stack_real_time;
   double stack_cpu_time;   
 	
	stack_real_time = 0;
	stack_cpu_time = 0.0;


	printf("%-30s%7s%13s%17s%17s%17s%17s\n\n","Description","Stack","User time","System time",
					"Total CPU time","Total real time","I/O-page time");

	for (i=0; i<time_count; i++)
	{
	   user_time = (timing_test[i].user_time / 60) + 
			((timing_test[i].user_time % 60) / 60.0);

	   system_time = (timing_test[i].system_time / 60) + 
			((timing_test[i].system_time % 60) / 60.0);

	   real_time = timing_test[i].real_time;
	   total_time = user_time + system_time;
	   
	   io_time = real_time - total_time;

	   if (timing_test[i].stack_pos == 1)
	   {
	      stack_real_time += real_time;
	      stack_cpu_time += total_time;
	   }
	   printf("%-30s%5d%15.6f%15.6f%15.6f%17d%17.6f\n",timing_test[i].name,
					    timing_test[i].stack_pos,user_time,
					    system_time,total_time,real_time,io_time);
	}
/*
	printf("\n\nTotal cpu time for stack = 1 is %15.6f\n\n",stack_cpu_time);
	printf("Total real time for stack = 1 is %15d\n\n",stack_real_time);
*/
        fflush(stdout);
}
#ifdef X11
%safe

#argsused
void ButtonCB( w,client_data, call_data)
Widget    w; /* widget id */
caddr_t   client_data; /* data from application */
caddr_t   call_data;   /* data from widgt class */
{
  /* print message */
  long msg,num_byte;
  int resp;
/*  printf("Button %s selected.\n",client_data);*/
  resp = EX_CMD_KEY;
  num_byte = strlen(client_data)+1;
  ex$putque( msg=&msg, pos=BACK, response=&resp, byte=&num_byte,buffer=client_data);
}







int EX_PrintDefaultError (dpy, event)
    Display *dpy;
    XErrorEvent *event;

{
    char buffer[BUFSIZ];
    char mesg[BUFSIZ];
    char number[32];
    char *mtype = "XlibMessage";
    register _XExtension *ext = (_XExtension *)NULL;

    if (OM_Gf_verbose_error || OM_Gf_verbose_warning) {
       XGetErrorText(dpy, event->error_code, buffer, BUFSIZ);
       XGetErrorDatabaseText(dpy, mtype, "XError", "X Error", mesg, BUFSIZ);
       (void) printf( "%s:  %s\n  ", mesg, buffer);
       XGetErrorDatabaseText(dpy, mtype, "MajorCode", "Request Major code %d", 
                             mesg, BUFSIZ);
       (void) printf( mesg, event->request_code);
       if (event->request_code < 128) {
          sprintf(number, "%d", event->request_code);
          XGetErrorDatabaseText(dpy, "XRequest", number, "", buffer, BUFSIZ);
       } else {
          for (ext = dpy->ext_procs;
               ext && (ext->codes.major_opcode != event->request_code);
               ext = ext->next)
          ;
          if (ext)
             strcpy(buffer, ext->name);
          else
             buffer[0] = '\0';
       }
       (void) printf( " (%s)\n  ", buffer);
       XGetErrorDatabaseText(dpy, mtype, "MinorCode", "Request Minor code %d",
                             mesg, BUFSIZ);
       (void) printf( mesg, event->minor_code);
       if (ext) {
          sprintf(mesg, "%s.%d", ext->name, event->minor_code);
          XGetErrorDatabaseText(dpy, "XRequest", mesg, "", buffer, BUFSIZ);
          (void) printf( " (%s)", buffer);
       }
       printf("\n  ");
       XGetErrorDatabaseText(dpy, mtype, "ResourceID", "ResourceID 0x%x",
                             mesg, BUFSIZ);
       (void) printf( mesg, event->resourceid);
       printf("\n  ");
       XGetErrorDatabaseText(dpy, mtype, "ErrorSerial", "Error Serial #%d", 
                             mesg, BUFSIZ);
       (void) printf( mesg, event->serial);
       printf("\n  ");
       XGetErrorDatabaseText(dpy, mtype, "CurrentSerial", "Current Serial #%d",
                             mesg, BUFSIZ);
       (void) printf( mesg, dpy->request);
       printf("\n");
       if (event->error_code == BadImplementation) return 0;
    }
    return 1;
}

static char *EX_SysErrorMsg (n)
    int n;
{
    extern char *sys_errlist[];
    extern int sys_nerr;
    char *s = ((n >= 0 && n < sys_nerr) ? sys_errlist[n] : "unknown error");

    return (s ? s : "no such error");
}


EX_DefaultIOError (dpy)
	Display *dpy;
{
     char ans[256];
     int  status;
     char *pp2;

	(void) fprintf (stderr, 
	 "XIO:  fatal IO error %d (%s) on X server \"%s\"\r\n",
			errno, EX_SysErrorMsg (errno), DisplayString (dpy));
	(void) fprintf (stderr, 
	 "      after %lu requests (%lu known processed) with %d events remaining.\r\n",
			NextRequest(dpy) - 1, LastKnownRequestProcessed(dpy),
			QLength(dpy));

	if (errno == EPIPE) {
	    (void) fprintf (stderr,
	 "      The connection was probably broken by a server shutdown or KillClient.\r\n");
	}
 
     if(  EX_batch_mode == EX_INTERACT  || EX_batch_mode == EX_BATCH)
     {
         int finished;
	 finished = 0;
	 
         while( !finished )
         {  
           finished = 1;

	   printf("\n Do you want to save current file ? (y/n) [y] : ");
  
           fgets(ans,sizeof(ans),stdin); 

           if( ans[0] == 'y' || ans[0] == '\n' )
	   {
	     printf("Enter Filename [%s] : ",module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
             fgets(ans,sizeof(ans),stdin); 

	     if( ans[0] != '\n')
             {
	        strcpy( module_data[module_table[active_module_num].obj_space_num]->CS_OS_name,
		        ans);
	        printf("saved file to %s\n",ans);
	     }
             MS_Gs_messages_on =  0;
	     status = close_visible( EX_saveOnClose  ,EX_exec_id);
	     if( status == 0 )
	     {
	        printf("Something wrong during the save operation\n");
		printf("The disk may not have enough space left for the file\n");
		printf("Do you want to get into a shell layer and cleanup your disk? (y/n) [y] ");
                fgets(ans,sizeof(ans),stdin); 
                if( ans[0] == 'y' || ans[0] == '\n' )
                {
 	 	   pp2 = getenv("SHELL");

		   if( pp2 == 0)
		   {
	              pp2 = "ksh";
		   }
                   system(pp2);
	           finished = 0;	   
	        }
	     }
       	   }
	 }
     }


	IGEExit(1);
}
%endsafe
#endif
end implementation exec;

 
