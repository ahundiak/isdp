struct NFFglobal_st
  {
    int   button_transition;
    int   time_value;
    int   project_active;
    int   search_active;
    int   sort_active;
    int   Help_was_displayed;
    double scale_factor_x;
    double scale_factor_y;
    short admin_or_user;
    short locations[4];
    short positions[NUMBER_OF_FORMS];
    short numslots;
    short timestamp_enabled;
    short delay_time;
    short playback_time;
    short where_message_is;
    short Help_initialized;
    short collapse_flag;
    long  status;
    long  working_no;
    char  keyboard_buffer[512];
    char  playback_file[128];
    char  record_file[128];
    char  timestamp_file[128];
    char  timestamp_buffer[4096];
    char  server[40];
    char  username[NFM_USERNAME + 1];
    char  password[NFM_PASSWD + 1];
    char  environment[40];
    char  node[NFM_NODENAME + 1];
    char  storage_area[NFM_SANAME + 1];
    char  working_area[NFM_SANAME + 1];
    char  user[NFM_USERNAME + 1];
    char  catalog[NFM_CATALOGNAME + 1];
    char  class[NFM_CLASSNAME + 1];
    char  project[NFM_PROJECTNAME + 1];
    char  workflow[NFM_WORKFLOWNAME + 1];
    char  acl[NFM_ACLNAME + 1];
    char  item[NFM_ITEMNAME + 1];
    char  new_item[NFM_ITEMNAME + 1];
    char  revision[NFM_ITEMREV + 1];
    char  new_revision[NFM_ITEMREV + 1];
    char  set_indicator[NFM_SETINDICATOR + 1];
    char  search[NFM_REPORTNAME + 1];
    char  sort[NFM_REPORTNAME + 1];
    char  display_name[20];
#ifdef XWINDOWS
    Display *display;
#endif
    Form  forms[NUMBER_OF_FORMS];
    Form  current_form;
    Form  popup_form;
    Form  debug_form;
    Form  error_form;
    Form  add_util_sa_form;
    long  (*NFMRfunction[3]) ();
  };

struct NFFdbg_st
  {
    int     flag1;
    int     flag2;
    int     flag3;
    int     flag4;
    int     flag5;
    int     flag6;
    int     flag7;
    int     flag8;
    int     flag9;
    int     flag10;
    int     flag11;
    int     flag12;
    char    file1[NFM_DEBUG_FILE_SIZE];
    char    file2[NFM_DEBUG_FILE_SIZE];
    char    file3[NFM_DEBUG_FILE_SIZE];
    char    file4[NFM_DEBUG_FILE_SIZE];
    char    file5[NFM_DEBUG_FILE_SIZE];
    char    file6[NFM_DEBUG_FILE_SIZE];
    char    file7[NFM_DEBUG_FILE_SIZE];
    char    file8[NFM_DEBUG_FILE_SIZE];
    char    file9[NFM_DEBUG_FILE_SIZE];
    char    file10[NFM_DEBUG_FILE_SIZE];
    char    file11[NFM_DEBUG_FILE_SIZE];
    char    file12[NFM_DEBUG_FILE_SIZE];
  };

/*  Structure to store buffer pointers, etc.  */

typedef struct NFFadd_st
  {
    short    type;
    short    done;

    /*  Active command  */

    int      command;

    /*  For visible rows  */

    int      *rows;

    /*  Which row is active  */

    long     active_attribute;

    /*  Which row in the
        validate mcf is active  */

    long     validate_row;

    char     entity[40];

    MEMptr   attr_list;
    MEMptr   data_list;
    MEMptr   value_list;
  } *NFFadd_ptr;

typedef struct NFFaddusa_st
  {
    short   type;
    short   done;
    char    st_area[NFM_SANAME + 1];
    char    node_num[40];
    char    user_name[NFM_USERNAME + 1];
    int     u_loc;
    int     u_width;
    char    passwd[40];
    int     pswd_loc;
    int     pswd_width;
    char    pathname[NFM_PATHNAME + 1];
    int     path_loc;
    int     path_width;
    char    dev_type[8];
    char    dev_command[88];
    int     d_loc;
    int     d_width;
    MEMptr  attr_list;
    MEMptr  data_list;
    MEMptr  value_list;
  } *NFFaddusa;

/*  Structure to store MEM buffer pointers  */

typedef struct NFFcatalog_st
  {
    short    type;
    short    done;
    short    command;
    short    advice_exists;
    short    range_exists;
    short    list_exists;
    short    user_defined;
    long     active_attribute;
    MEMptr   cat_attr;
    MEMptr   cat_data;
    MEMptr   cat_value;
    MEMptr   cat_appl;

    /*  Structure for LOC information  */

    NFFadd_ptr    loc;

  } *NFFcatalog;

/*  Structure to store command info in  */

typedef struct NFFconfirm_st
  {
    /*  Command specific data  */

    char    entity1[80];
    char    entity2[80];
    char    entity3[80];
  } *NFFconfirm_ptr;

/*  Structure to store in the form  */

typedef struct NFFfitem_st
  {
    short   type;
    short   done;
    int     command;
    int     *columns;
    long    level;
    char    title1[NFF_MAX_MESSAGE];
    char    title2[NFF_MAX_MESSAGE];
    char    st_area[20];
    char    temp_node[20];
    char    temp_user[20];
    char    temp_passwd[40];
    char    temp_path[80];
    MEMptr  item_attr;
    MEMptr  item_data;
  } *NFFfitem;

/* structure used to temporarily store the data from the data_list */

typedef struct NFFnew_list
  {
     short dup_entry;
     char *str;
  } *NFFlist_ptr;

typedef struct NFFlogin_st
  {
    short   type;
    short   done;
    short   attempts;
    MEMptr  attr_list;
    MEMptr  data_list;
    MEMptr  value_list;
    MEMptr  wf_list;
  } *NFFlogin_ptr;

typedef struct NFFmap_st
  {
    short   type;
    short   done;
    short   command_type;
    short   user_offset;
    short   state_offset;
    int     *rows;
    int     *columns;
    int     command;
    int     num_states;
    long    active_data;
    long    active_attribute;
    long    validate_row;
    char    entity_attr[20];
    char    **statenames;
    char    **statenos;
    MEMptr  attr_list;
    MEMptr  data_list;
    MEMptr  value_list;
  } *NFFmap;

/*  Structure to store in the form  */

typedef struct NFFmk_trans_st
  {
    short   type;
    short   done;
    MEMptr  attr_list;
    MEMptr  data_list;
  } *NFFmk_trans;

typedef struct NFFpasswd_st
  {
    short   type;
    short   done;
    short   verify_flag;
    char    old_password[20];
    char    new_password[20];
    char    verify_password[20];
  } *NFFpasswd;

typedef struct NFFmember_struct
{
    char  catalog[NFM_CATALOGNAME + 1];
    char  item[NFM_ITEMNAME + 1];
    char  revision[NFM_ITEMREV + 1];
    char  type[8];
    char  status[8];
} *NFFmem_struct;

/*  Structure to store buffer pointers, etc.  */

typedef struct NFFset_mem
  {
    short   type;
    short   done;
    short   level;
    int     command;
    char    project [NFM_PROJECTNAME + 1];

    /*  For visible rows  */

    int     rows;
    int     vis_rows ;
    int     columns;

    /*  Which row is active  */

    long    active_row;

    /* default values for toggle text */

    char    on_text [2];
    char    off_text[2];

    /*  attribute offsets in the data_list */

    short   project_offset;
    short   cat_offset;
    short   item_offset;
    short   rev_offset;
    short   type_offset;
    short   level_offset;
    short   status_offset;
    short   set_offset;

    /* current catalog and item */

    char    curr_cat [NFM_CATALOGNAME + 1]; 
    char    curr_item [NFM_ITEMNAME + 1]; 
    char    curr_rev [NFM_ITEMREV + 1]; 

    short   cat_name_offset;
    short   item_name_offset;
    short   rev_name_offset;
    short   toggle_offset;
    short   cat_displayed;
    short   item_displayed;
    short   rev_displayed;

    MEMptr  attr_list;
    MEMptr  data_list;
    MEMptr  cat_data;
    MEMptr  item_data;

    NFFmem_struct member_list; 
  } *NFFset_ptr;

typedef struct NFFsignoff_st
  {
    short   type;
    short   done;
    short   override_depressed;
    char    *reason;
    int     length;       /* maximum length allowable for the reason str */
    int     r_offset;     /* offset of n_reason */
    int     s_offset;     /* offset of n_signoff */
    MEMptr  attr_list;
    MEMptr  data_list;
    MEMptr  value_list;
  } *NFFsignoff;


typedef struct NFFsort_st
  {
    short   type;
    short   done;
    char    sort_name[NFM_REPORTNAME + 1];
    int     *order_list;    
    int     num_rows;
    short   name_offset;
    short   syn_offset;
    MEMptr  attr_list;
  } *NFFsort_ptr;


typedef struct NFFflag_st
  {
    short   type;
    short   flag_type;
    short   item_offset; 
    short   rev_offset; 
    short   ver_offset; 
    short   file_offset; 
    int     num_rows;
    int     *vers_ptr;
    MEMptr  data_list;
  } *NFFflag_ptr;

typedef struct NFFcopy_st
  {
    short       type;
    short       command;
    char        catalog[NFM_CATALOGNAME + 1];
    char        item[80];
    char        revision[NFM_ITEMREV + 1];
    int         label;
    int         act_row;
    int         act_col;
    NFFadd_ptr  add_ptr;
    NFFadd_ptr  file_ptr;
    MEMptr      temp_list;
  } *NFFcopy_ptr;

typedef struct NFFnflag_st
  {
    short       type;
    short       command;
    char        project[NFM_PROJECTNAME + 1];
    char        catalog[NFM_CATALOGNAME + 1];
    char        item[NFM_ITEMNAME + 1];
    char        revision[NFM_ITEMREV + 1];
    char  act_indicator[NFM_SETINDICATOR + 1];

  } *NFFnflag_ptr;


typedef struct NFFversion_st
  {
    short       type;
    short       command;
    char        catalog[NFM_CATALOGNAME + 1];
    char        item[NFM_ITEMNAME + 1];
    char        revision[NFM_ITEMREV + 1];

    MEMptr      attr_list;
    MEMptr      data_list;
  } *NFFversion_ptr;

typedef struct NFFutility_st
  {
    short       type;
    short       done;
    int         utility;
    char        label[16];
    MEMptr      sa_list;
    MEMptr      item_list;
    MEMptr      label_list;
  } *NFFutil_ptr;

typedef struct NFFchangewf_st
  {
    short       type;
    short       done;
    char        workflow[NFM_WORKFLOWNAME + 1];
    char        acl[NFM_ACLNAME + 1];
    long        acl_no;
    char        state[NFM_STATENAME + 1];
    long        state_no;
    MEMptr      wf_list;
    MEMptr      state_list;
  } *NFFiwf_ptr;


/* removed the typedef PS 
struct NFFcopy_acl_users_st
*/
typedef struct NFFcopy_acl_users_st
  {
    char        new_aclname [NFM_ACLNAME+1];
    char        new_wfname [NFM_WORKFLOWNAME+1] ;
    long        existing_wfno;
    struct NFFadd_st  *acl_ptr;
  } *NFFcopy_acl_users_ptr;


typedef struct NFFpopup_st
  {
    int         f_label;
    Form        form; 
  }*NFFpopup_ptr;

