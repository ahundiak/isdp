/*  #defines for WFG */

#define WFF_ADD          "ADD"
#define WFF_DROP         "DROP"
#define WFF_MODIFY       "MODIFY"

/* Structures used by WFF and WFG */

struct WFFclass_st
  {
        char   class_name[24];
        char   status [8]; 
        int    row;
        long   class_no;
  }; 

struct WFFstate_st
  {
        char   state_name[48];
        char   state_desc[48];
        char   no_signoffs[16];
        char   majority[8];
        char   trans_from[8];
        char   trans_to[8];
        char   seq_no[16];
        char   status [8]; 
        int    row;
        long   state_no;
  };

struct WFFtrans_st
  {
        char   trans_name[88];
        char   command_name[104];
        char   from_state[48];
        char   to_state[48];
        char   logon_success[8];
        char   logon_failure[8];
        char   n_notify[8];
        char   status [8]; 
        int    row;
        long   trans_no;
  };

struct WFFstatus_st
  {
        char   trans_name[88];
        char   from_state[48];
        char   to_state[48];
        char   status[8];
  }; 

struct WFFaccess_st
  {
        char   class_name[24];
        int    num_trans;
        char   status[8];
        struct WFFstatus_st *trans_ptr;
  }; 

struct WFFcommand_st
  {
        char   command_name[108];
        char   app_name    [8];
        char   trans_cmd   [8];
        char   entity      [16];   /* can change this to [8] with 3.0 */
        char   nfm_cmd_no  [16];   /* can change this to [8] with 3.0 */
        char   status[8];
  }; 

