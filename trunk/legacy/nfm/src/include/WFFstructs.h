/*  Structure to store command info in  */

typedef struct WFFconfirm_st
  {
	short	type;

	/*  Listing type  */

	int		listing_type;

	/*  Command specific data  */

	char	entity1[80];
	char	entity2[80];
	char	entity3[80];

	/*  Functions to clear listing data  */

	void	(*clear_function[2]) ();

  } *WFFconfirm_ptr;

typedef struct WFFlogin_st
  {
	short	type;
	short	done;
	short	attempts;
	MEMptr	attr_list;
	MEMptr	data_list;
	MEMptr	value_list;
	MEMptr	wf_list;
  } *WFFlogin_ptr;

typedef struct WFFadd_st
  { 
	short	type;
	short	done;
	short	curr_page;
	short	next_page;
	short	wf_in_use;
        long    workflow_no;
        char    complete[2];
        Form    page1_form;
        Form    page2_form;
        Form    page3_form;
        Form    page4_form;
        short   get_wfs;
        char    old_wf_name[24];
        char    workflow_name[24];
        char    workflow_desc[48];
        char    existing_wf_name[24];
        char    application[8];
        MEMptr  wf_list;
        MEMptr  app_list;
        MEMptr  comm_list;
        struct   WFFclass_st  *class_list;
        int      num_classes;
        struct   WFFstate_st  *state_list;
        int      num_states;
        struct   WFFtrans_st  *trans_list;
        int      num_trans;
        struct   WFFaccess_st *access_list;
        int      num_access;
  } *WFFadd_ptr;


typedef struct WFFcmd_st
  { 
	short	 type;
	short	 done;
        int      num_cmds;
        int      num_app;
        struct   WFFcommand_st  *cmd_list;
  } *WFFcmd_ptr;

