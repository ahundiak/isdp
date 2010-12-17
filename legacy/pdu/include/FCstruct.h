#include "OMminimum.h"

struct FC_print_st {
  OM_S_OBJID form_id;		/* objid of print form */
  int displayed;
  struct FC_form_st *free_form;	/* data of form to be printed */
  struct FC_review_st *rev_form;/* data of form to be printed */
  int rows;
  int cols;
  int header;
  int write_append;
  char filename[80];
  int type;
  int error_msg_displayed;
};

struct FC_refresh_st {
  OM_S_OBJID form_id;		/* objid of current refresh form */
  int displayed;		/* is form currently displayed */
  int type;		/* value of toggle for refresh form if user*/
  int frozen;			/* is input allowed */
  int error_msg_displayed;
};

struct FC_button_st {
  OM_S_OBJID form_id;		/* objid of print form */
  int displayed;		/* is form currently displayed */
  int value;			/* gadget_label of selected button */
  int mode;			/* insert or modify */
};

struct FC_attr_st {
  OM_S_OBJID form_id;		/* objid of print form */
  int value;			/* index of selected attr */
  int displayed;		/* is form currently displayed */
  OM_S_OBJID calling_id;	/* objid of calling form */
  struct FI_data_st list;	/* FI_data used to send put_by_value to 
                                   calling_id  when form is exited */
};

struct FC_search_st
  {
    OM_S_OBJID form_id;		/* objid of print form */
    struct FC_search_data_st *data;
    struct node_st *top;
    struct node_st *bottom;
    struct node_st *row[10];
    int displayed;		/* is form currently displayed */
    int error_labels[5];
    int error_count;
  };

struct FC_define_st
  {
    int displayed;		/* is form currently displayed */
    OM_S_OBJID form_id;		/* objid of print form */
    struct FC_define_data_st *data;
    struct FC_define_node_st *old_row;
    int old_row_number;
    struct FC_define_node_st *edit_node;
    int col_offset;
    int row_offset;
    char screen[10][120];
    int r1;		/* selected row */
    int c1;		/* 1st selected column */
    int c2;		/* 2nd selected column */
    int d1,d2;
    int action;
    int toggle;
    int delete_state;
    int edit_state;
    char attr_str[132];
    char text_str[132];
    int width;
    int just;
    int *req_attr_check;
    int error_msg_displayed;    
  };

struct FC_review_st
  {
    int displayed;		/* is form currently displayed */
    OM_S_OBJID form_id;		/* objid of print form */
    struct FC_review_data_st *data;
    int row_offset;
  };

struct FC_form_st {
  OM_S_OBJID form_id;		/* objid of form */
  struct FC_data_st *fc_data;	/* data passed to forms controller */
  int data_count;		/* number of elements in data array */
  int data_ptr_count;		/* num of ptrs in data array (used + unused) */
  int row_offset;		/* row offset for scrolling */
  int col_offset;		/* column offset for scrolling */
  int max_row_offset;		/* maximum row offset for scrolling */
  int max_col_offset;		/* maximum column offset for scrolling */
  int num_rows_in_form;		/* number of rows in form */
  int num_cols_in_form;		/* number of columns in form */
  int scroll_offset;		/* width of columns scrolled off to the left */
  int freeze_width;		/* width of frozen columns */
  int display_width;		/* width of displayed data */
  char *freeze_string1;
  char *freeze_string2;
  char *freeze_string3;
  int field[11][4]; 	        /* conversion table:  */
				/*   gadget_label <--> position on form */
  int check[11];		/* conversion table:  */
				/*   gadget_label <--> checkmark on form */
  int hilited_rows[11];		/* which rows are hilited */
  int exit_sts;			/* exit status of form (accept or cancel) */
};

struct FC_two_col_st
  {
    OM_S_OBJID form_id;		/* objid of form */
    struct FC_two_col_data_st *data;	/* data passed to forms controller */
    int data_count;		/* number of elements in data array */
    int row_offset;		/* row offset for scrolling */
    int max_row_offset;		/* maximum row offset for scrolling */
    int field[11][2]; 	        /* conversion table:  */
				/*   gadget_label <--> position on form */
    int selected_rows[11];	/* which rows are selected */
    int next_gadget;
    int *invalid_data;
    int error_count;    
    int error_msg_displayed;        
    int empty_count;
  };

struct FC_security_st
  {
    OM_S_OBJID form_id;		/* objid of form */
    struct FC_security_data_st *data;	/* data passed to forms controller */
    int data_count;		/* number of elements in data array */
    int row_offset;		/* row offset for scrolling */
    int max_row_offset;		/* maximum row offset for scrolling */
    int field[11][2]; 	        /* conversion table:  */
				/*   gadget_label <--> position on form */
    int selected_rows[11][2];	/* which rows are selected */
    int error_msg_displayed;
  };

struct FC_three_col_st
  {
    OM_S_OBJID form_id;		/* objid of form */
    struct FC_three_col_data_st *data;	/* data passed to forms controller */
    int data_count;		/* number of elements in data array */
    int row_offset;		/* row offset for scrolling */
    int max_row_offset;		/* maximum row offset for scrolling */
    int field[11][3]; 	        /* conversion table:  */
				/*   gadget_label <--> position on form */
    int selected_rows[11];	/* which rows are selected */
    int next_gadget;
    int *invalid_data;
    int error_count;    
    int error_msg_displayed;            
    int empty_count;
  };

struct FC_four_col_st
  {
    OM_S_OBJID form_id;		/* objid of form */
    struct FC_four_col_data_st *data;	/* data passed to forms controller */
    int data_count;		/* number of elements in data array */
    int row_offset;		/* row offset for scrolling */
    int max_row_offset;		/* maximum row offset for scrolling */
    int field[11][4]; 	        /* conversion table:  */
				/*   gadget_label <--> position on form */
    int selected_rows[11];	/* which rows are selected */
    int next_gadget;
    int *invalid_data;
    int error_count;    
    int error_msg_displayed;    
  };

struct FC_six_col_st
  {
    OM_S_OBJID form_id;		/* objid of form */
    struct FC_six_col_data_st *data;	/* data passed to forms controller */
    int data_count;		/* number of elements in data array */
    int row_offset;		/* row offset for scrolling */
    int max_row_offset;		/* maximum row offset for scrolling */
    int field[11][6]; 	        /* conversion table:  */
				/*   gadget_label <--> position on form */
    int selected_rows[11];	/* which rows are selected */
    int *invalid_data;
    int error_count;    
    int error_msg_displayed;            
  };

struct FC_login_st
  {
    OM_S_OBJID form_id;		/* objid of form */
    struct FC_login_data_st *data;	/* data passed to forms controller */
  };

