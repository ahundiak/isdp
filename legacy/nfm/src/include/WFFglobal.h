#include "DEBUG.h"

/*  Global structure  */

struct	WFFglobal_st
  {
	/*  Depends on command line options  */

	int		bar_menu_height;

	/*  Used for journaling  */

	int		playback_time;
	int		delay_time;
	int		time_value;
	int		timestamp_enabled;

	short		Help_initialized;
	int		Help_was_displayed;

	char	record_file[80];
	char	playback_file[80];
	char	timestamp_file[80];
	char	timestamp_buffer[4096];

	/*  Keeps up with button transitions
	    for error message scrolling on all forms  */

	int		button_transition;

	long	user_id;
	char	server[40];
	char	username[40];
	char	password[40];
	char	environment[40];
	char	workflow[40];
	char	acl[40];
        char    display_name[20];
#ifdef XWINDOWS
        Display *display;
#endif

	/*  Buffer to store keyboard data in  */

	char	keyboard_buffer[512];

	long	cmd_status;
	long	error_no;
	long	working_no;
	long	current_list;
	long	current_popup;
	long	(*NFMfunction[3]) ();
	Form	message_form;
	Form	main_form;
	Form	current_form;

        /* original x and y positions of the MCF */

        int     tx_mcf;
        int     ty_mcf;
        int     x_mcf;
        int     y_mcf;

        /*  original x, y, height and width  */ 

        int     x_scrl;
        int     y_scrl;
        int     g_height;
        int     g_width;

        short   no_scrl_cols;

        /*  The current scroll location in the data_list*/

        short   scrl_val;

	/*  Type of vlt hardware is being used  */

	short	numslots;

	/*  Flag to tell where messages are output
	    (message_form, main_form, or current_form)  */

	short	where_message_is;

	/*  forms debug on/off  */

	short	debug_on;
        char    debug_file[80];

	/*  Flag to tell if there is a need to call FI_process_forms ()  */

	short	call_process_forms;

	/*  Pointers for listing buffers  */

	MEMptr	attr_list;
	MEMptr	list_buffer;

	/*  Structure to store server debug flags and filenames  */

	struct WFFdbg_st
	  {
		short	type;
		int		flag1;
		int		flag2;
		int		flag3;
		int		flag4;
		int		flag5;
		char	file1[NFM_DEBUG_FILE_SIZE];
		char	file2[NFM_DEBUG_FILE_SIZE];
		char	file3[NFM_DEBUG_FILE_SIZE];
		char	file4[NFM_DEBUG_FILE_SIZE];
		char	file5[NFM_DEBUG_FILE_SIZE];
	  } WFFserver;
	
	/*  Flag saying whether or not a command was confirmed */
	int  confirmed;

  	/*  Flag saying that copy workflow is in progress */
        int  copy_wf;
  };

/*  #define _WFFdebug(s) \
    if (WFFglobal.debug_on != 0) __WFFdebug s
*/
