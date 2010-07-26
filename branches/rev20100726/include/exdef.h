#ifndef exdef_include

#define exdef_include

/* IGE response types */

#define COMMAND              0
#define DATA                 1
#define RESET                2
#define D_COMMAND            3
#define D_DATA               4
#define D_RESET              5
#define HELP                 6
#define EXEC                 7
#define STRING               8
#define CMD_STRING           9
#define ODEN                 10
#define OMPMS                11
#define VALUE                12
#define CHAR                 13
#define STATUS_DISP          14
#define CLEAR_STACK          15
#define MOVE_ON              16
#define TERMINATE            17
#define TOGGLE_COMMAND       18
#define ABS_DIG              19     /* absolute digitizer point */
#define FORM_FINISHED        20
#define SPECIFIED_OBJ        21

#define EX_DATA               1   /* same as DATA      */
#define EX_RJT_MOVEON         2   /* same as RESET     */
#define EX_BACK_UP            5   /* same as D_RESET   */
#define EX_STRING             8   /* same as STRING    */
#define EX_VALUE             12   /* same as VALUE     */
#define EX_CHAR              13   /* same as CHAR      */
#define EX_FORM_FINISHED     20   /* same as FORM_FINISHED */
#define EX_OBJID             21   /* same as SPECIFIED_OBJ */
#define EX_RESTART           22
#define EX_CMD_KEY           23   /* search cmd_table use key field */
                                 
#define EX_POCKET	     24   /* for EXEC use only */
#define EX_CMD_M_STR         25   /* for EXEC use only */
#define EX_CMD_M_KEY         26   /* for EXEC use only */
#define EX_CMDSVR_RETURN     27   /* for EXEC use only */
                                  /* for batch return from cmdserver */
#define EX_EXIT              28   /* for EXEC use only */
#define EX_FORM_DATA         29   /* data for form use */
#define EX_WINDOW_CHANGE     30
#define EX_CALC              31   /* invoke calculator */
#define EX_CALC_RETURN       32   /* return calculator */
#define EX_NEXT_SCREEN       33   /* swap virtual screens*/
#define EX_MAX_RESPONSE      34 

/* system valuse */
#define EX_MAX_MODULES          EX_max_modules
#define EX_MAX_INVIS_MODULES    EX_max_ref_files 


#define EX_RESPONSE_DATA_SIZE 1024  /* size of response_data        */ 
#define EX_PMENU_NUM            10  /* number of paper menu allowed */
#define EX_CMD_STACK_SIZE       10

#define EX_STANDARD_FILE_FORM   0  /*type form for file lists*/

/* quiet mode are per command only */
#define EX_HELP_QUIET	     0x00010000
#define EX_MSG_QUIET	     0x00020000
#define EX_DISP_QUIET	     0x00040000

/* for wait_for_input      */   
#define EX_LINE_MODE             1
#define EX_ALL_ASCII_MODE        2
#define EX_ALL_CHAR_MODE         8

#define EX_LEFT_ARROW            0x0000000c
#define EX_RIGHT_ARROW           0x00000012
#define EX_UP_ARROW              0x00000010
#define EX_DOWN_ARROW            0x0000000e

#define MAX_CHAR                81
#define MAX_FILE_NAME           30

/* for ex$putque    */
#define BACK                     0
#define FRONT                    1

#define EX_default               0
#define EX_new_module            1
#define EX_old_module            2


#define EX_invisible	         0
#define EX_visible               1

/* type of invisible file */
#define EX_ref     	         1
#define EX_cell                  2
#define EX_ACTINV                4 /* if you dont know what this is, then you
                                      dont have to know. internal flag for exec */


/* return msg from retrieve module */
#define EX_erro             0      /* generic error */
#define EX_succ             1

#define EXe_max_module     -4      /* maximum number of module exceeded */
#define EXe_no_create      -6      /* file not exist and creat flag not set */ 
#define EXe_os_exists      -8      /* file currently open  */
#define EXe_enoent         -10     /* no such file or directory */
#define EXe_ver_mis        -12     /* version mismatch or non object space */
#define EXe_os_construct   -14     /* can not construct object space */ 
#define EXe_change_name    -16     /* can not change os name for seed_file */
#define EXe_iso_in_seed    -18     /* iso in seedfile can not change os name */
#define EXe_module_class   -20     /* can not get module class namne */
#define EXe_module_id      -22     /* can not get module object id  */
#define EXe_module_wakeup  -24     /* module wake up error */
#define EXe_module_init    -26     /* module init error */
#define EXe_no_filename	   -28     /* no filename provided */
#define EXe_mod_construct  -30     /* construct module error */
#define EXe_file_curr_open -32     /* file currently  open */

/* next 3 for invisible module only  */
#define EX_flag            -34     /* file in mem, but perm is differ from requested */
#define EX_nofile          -36     /* file not in master or invis table */ 
#define EX_inacc_file      -38     /* file inaccessable, perm or non exist */

#define EXe_no_read_perm   -40     /* no read permision for file */
#define EXe_multihop       -42     /* require hopping to multiple remote machines */  
#define EXe_no_link        -44     /* file in on remore machine, but link not active */
#define EXe_access         -46     /* search perm is denide for a component of path */ 
#define EXe_not_dir        -48     /* a component of path is not a directory */
#define EXe_bad_dir        -50     /* bad directory specified ( no such directory) */
#define EXe_cell           -52     /* try to retrieve cell file as master file */

#define EXi_read_from_file    -3   /* old file   */
#define EXi_read_from_RO_file -5   /* read from read only file */






/* internal return codes from command table operations */
#define EXe_mod_type       -1      /* error in module type */
#define EXe_cmd_cntrl_addr -2      /* error in command control table address */
#define EXe_cmd_addr       -3      /* error in command table addr */
#define EXe_cmd_ndx_addr   -4      /* error in cmd index table add */
#define EXe_cmd_file       -3      /* error in command file name */
#define EXe_no_cmdmem      -4      /* no dynamic memory available */
#define EXe_empty_file     -5      /* command file is empty */
#define EXe_not_attached   -6      /* module not attached */



#define EX_INTERACT        0
#define EX_BATCH           1


#define EX_read_only       1
#define EX_read_write      2
#define EX_overwrite       4       /* used for save as another file */

#define EX_REAL_SLEEP      0       /* close a file /or end of session */
#define EX_TEMP_SLEEP      1       /* a wakeup will follow */

#define EX_INQ             0
#define EX_SET             1

#define EX_END_PARAM       0
#define EX_CUR_FILENAME    1   /*  current master file name. 
                                    (no directory path)           */
#define EX_WORKING_DIR     2   /*  directory where saved file is  */
#define EX_SUPPORT_DIR     3   /*  /usrx/ige/                     */
/*      EX_MODULE_TYPE     4     no longer used (type number of the module) */

#define EX_WRITE_FILE      0   /* if you do not understand this ,  */
#define EX_NOWRITE_FILE    1   /* you do not need to know          */

#define REDIR_INPUT        1   /* redirection of standard input to use pipe */
#define REDIR_OUTPUT       2   /* redirection of standard outpot to use pipe */
#define CREATE_PIPE        4   /* user provided the name of named pipe  */

#define EX_START_FUNC      0   /* start function list  */
#define EX_END_FUNC	   1   /* end   function list  */



/*defines for forms*/
#define EX_FMB_MAX_TITLE        25
#define EX_FMB_MAX_HEADER2      38
#define EX_FMB_MAX_HEADER3      25
#define EX_FMB_TITLE	   	 11
#define EX_FMB_HEADER_COL1       12
#define EX_FMB_HEADER_COL2       13
#define EX_FMB_HEADER_COL3        14
#define EX_FMB_SCROLL_FIELD1    15
#define EX_FMB_SCROLL_FIELD2    16
#define EX_FMB_SCROLL_FIELD3    17
#define EX_FMB_TEXT_FIELD1    21
#define EX_FMB_TEXT_FIELD2    22
#define EX_FMB_TEXT_FIELD3    23
#define EX_FMB_SAMPLE         20
#define EX_FMB_QUIT    	         4
#define EX_FMB_EXIT      	 1
#define EX_FMB_EDT      	 6




/* for menu */
#define EX_MENU_BTN              1
#define EX_POCKET_MNU            2

#define EX_MENU_PANEL		 1
#define EX_MENU_POCKET		 2
#define EX_MENU_BAR		 3
#define EX_MENU_F_KEY		 4

#define EX_INIT                  1
#define EX_UPDATE	         0

/* for command server use    */
#define EX_CMD_POP		 1
#define EX_CMD_CLEAR_STACK	 2
#define EX_CMD_NEW		 3
#define EX_CMD_DROP		 4
#define EX_CMD_SWAP		 5
#define EX_CMD_DISCONNECT        6
#define EX_CMD_SLEEP             7

/* for command sleep/wakeup message */
#define EX_nonsuspend            0
#define EX_suspend	 	 1

/* for command table entry -- exec_flag */
#define EX_SINIT    		 256         /* session startup command */
#define EX_FINIT    		 512         /* file startup command    */
#define EX_SHUTDOWN 		 1024        /* shutdown command        */
#define EX_FCREATE  		 2048        /* file creation command   */

/* for ex$get_path   type of path  */
/* on a distributed system config directory may be on other machine */

#define EX_CONFIG_PATH           0          
#define EX_PRODUCT_PATH          1    

#define EX_HARDWARE_GENERATED    0x40000000

#define EX_NO_MATCH 0
#define EX_LEFT_MATCH 1
#define EX_RIGHT_MATCH 2
#define EX_INVALID_PROMPT 3

#define EX_TOP_EDGE        0x00000001
#define EX_RIGHT_EDGE      0x00000002
#define EX_BOTTOM_EDGE     0x00000004
#define EX_LEFT_EDGE       0x00000008
#define EX_MAX_WINDOW      40  
#endif
