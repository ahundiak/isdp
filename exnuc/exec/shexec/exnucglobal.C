
#include "igrtypedef.h"
#include "OMlimits.h"
#include "version.h"
#include "OMminimum.h"
#include "exdef.h"
#include "ex.h"
#include "expriv.h"
#include "igeterm.h"
#include "igetypedef.h"
#include "igewindow.h"
#include <stdio.h>
#include <nlist.h>
#include <setjmp.h>
#include "mspriv.h"
#include <sys/param.h>

#include "wl.h"

#include <COB_pf_nod.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "exlanguage.h"

#ifdef X11
#include <sys/time.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Intrinsic.h>
#include <X11/Xresource.h>

#define MAX_TOTAL   60
#define MAX_WINDOW  40
#endif

#include <EXproduct.h>

/*   from message   */

IGRshort        MS_Gs_messages_on = 1;
struct MS_header *MS_files = 0;

 /*  from EX_main.C  */

struct module_params **module_data = 0; /* EX_MAX_MODULES + EX_MAX_INVIS_MODULES */
struct EX_visible_module *module_table = 0;      /* EX_MAX_MODULES       */
struct EX_invisible_module *invisible_table = 0; /* EX_MAX_INVIS_MODULES */
struct EXevent_queue *event_queue_front = 0;
struct EXevent_queue *event_queue_back = 0;
struct EX_global EX_global_var = {0};
struct EX_pmenu_entry EX_paper_menu[EX_PMENU_NUM] = {0};
struct EX_memnode  *EXmem = 0;

short   EX_linebuffer_flag = 0;
uword   EX_exec_osnum = 0;
uword   EX_active_OS_num = 0;
int EX_time_for_backup = 0;

OM_S_OBJID EX_active_module = 0;
OM_S_OBJID EX_exec_id = 0 ;
OM_S_OBJID EX_cmdserver_id = 0 ;

int  EX_same_file = 0; /*after spawn use the old file */
int  EX_index = 0;
int  EX_mod_type = 0;
int  EX_create = 0;
int  EX_driver_exist = 0; 
int  timer_no = -1;  /* timer for backup */
int  active_module_num = 0;
int  EX_batch_mode = 0;
int  EX_kbd_wrt = 0;
int  EX_kbd_rd = 0;
int  EX_logkbd = 0;

char EX_filename[OM_K_MAXOSNAME_LEN] = { "" };
char EX_seedfile[OM_K_MAXOSNAME_LEN] = { "" };
char CS_path_name[OM_K_MAXOSNAME_LEN] = { "" };
char EX_version[120] = { "" };
char EX_date[35] = { "" };
char EX_runname_not_used[20] = { "" }; /* now in OMppgd.C */
char *EX_firstcmd = 0;

/* from execi.I */

OM_S_OBJID absdig_id = 0 ;
int no_modules = 0 ;

/* from wfi/keyin.C */

short EX_echo_flag = 0 ;
int EX_entry = 0;
int EX_entry_full = 0;

char  EX_keyin_cmd[EX_RCL_MAX_ENTRY][EX_RCL_MAX_LEN] = { ' ' }; /* 10 cmds , 80 char each */


/* from wfi/squeue.C */

int EX_pnt_entry = 0;
int EX_pnt_entry_full = 0;
struct EX_button     EX_recallpnt[EX_RCL_MAX_ENTRY] = { 0 };

/* from wfi/wfi.C */

char  EX_keybuff[257] = {0};

/* from cmdserver attch.C */

struct EX_cmd_cntrl *EX_cmdlist_ptr = 0;


/* from igewindow/IGEldtrminfo.C */

struct IGEterm_info term_info ={0};

/* from cmdserver cmdserveri.I */

int EX_help_quiet = 0;
int EX_disp_quiet = 0;
int EX_help_proc_exist = 0;


/* Globals  from menu sys */

char *MS_menus[MAX_WINDOW] = {0};


char 	MS_panel_exists = '\0';
char 	MS_strip_exists = '\0';
char	MS_pocket_exists = '\0';
char	MS_funckey_exists = '\0';

char	* MS_menu_strip_name = 0;
char	* MS_menu_panel_name = 0;
char	* MS_pocket_menu_name = 0;
int MS_panel_win_no = 0; 
int MS_strip_win_no = 0; 
int EX_use_mloc = 0;
/* end */

struct COB_pf_nod *COB_persistent_forms = 0;

int	COBtrace = 0;		/* general trace flag */
int	COBdebugindentlvl = 0;	/* format debug output */
int	COBdebFlag_debug = 0;	/* debug for COBdebFlag class  */
int	actions_debug = 0;	/* debug for actions class  */
int	CEO_debug = 0;		/* debug for CEO class  */
int	CEO_LOCATE_debug = 0;	/* debug for CEO_LOCATE class  */
int	CEO_GSLOCATE_debug = 0;	/* debug for CEO_GSLOCATE class  */
int	state_debug = 0;	/* debug for state class  */
int	trans_debug = 0;	/* debug for trans class  */
int	read_debug = 0;		/* debug for CEO.read_t_file  */
int	dump_debug = 0;		/* debug for CEO.dump  */



/* from IGEcolortbl.C the cube look up table for macros */
short *IGErgb_table = NULL;
struct WLcmap_entry       IGEphys_vlt[512]; 

/* from exlocinit.C   locale */

struct EX_locale_struct *EX_locale = 0;
struct EX_locale_struct *EX_text_locale = 0;
struct EX_locale_struct *EX_message_locale = 0;


OM_S_OBJID  FIfm_id = 0;
int FIdont_flush = 0;
uword   EX_ACTINV_OS_num = 0;
uword   EX_dup_os_occured = 0;
char *EX_msg_form = 0;
char *EX_msg_form_left = 0;
int EX_two_message_strips = 0;
jmp_buf EX_react_recover = {0};

struct diacritic *EX_diacritic = 0;
int EX_ndiacritic = 0;

long    EX_stopproc_id = 0;

#ifdef X11
Display *EXdisplay = 0;
struct timeval EXtimeout = {0,135000};
int      EXweight = 0;
char    EX_display_name[16] = { "" };  
unsigned int  EX_button_state = 0;
Window  EX_copyright_win_no = 0;
Widget  EXtoplevel = { 0 };
Window  EX_prim_win_no = 0;
XrmDatabase  EXrDB = { 0 };
#endif

int    EX_max_modules = 0;
int    EX_max_ref_files = 0;
int EX_process_unknowns = 0;
char *EX_search_path = NULL;
char *EX_dependencies = NULL;
int  EX_ext_event_base = 0;
int  EX_ext_error_base = 0;

/* following 2 entries are for all the defined dig buttons pressed/released */
/*   in a digitizer region                                                  */

int INGR_DigButtonPress;         /* event type */
int INGR_DigButtonRelease;       /* event type */

/* following entries are for buttons greater than 3 which are pressed when  */
/* the digitizer puck is in an window.                                      */

int INGR_DevButtonPress;         /* event type */
int INGR_DevButtonRelease;       /* event type */
int INGR_DevButtonPress_class;   /* extension event class */
int INGR_DevButtonRelease_class; /* extension event class */


/*  Some globals for WL initialization  */

int EX_context_type = 0;
int EX_context_depth = 0;
int EX_hilite = 0;
int EX_double_buffer = 0;
