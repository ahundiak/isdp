struct FC_data_st {
  int	form_no;		/* type of form to use 			*/
  int	form_x,form_y;		/* coordinates of form 			*/
  char	title[80];		/* title of form 			*/
  int	num_of_columns;		/* number of columns of data 		*/
  int	num_of_rows;		/* number of rows of data 		*/
  int	freeze_columns_count;	/* number of columns to freeze, 	*/
				/*    starting with the left column 	*/
  int	freeze_rows_count;	/* number of rows to freeze, starting	*/
				/*    with the top row			*/
  int	*column_just;		/* Column justification	(for each col)	*/
  int	*column_size;		/* Column size (free format form)	*/
  int	*column_pos;		/* Column position (free format form)	*/
  int	max_indent;		/* Maximum indentation			*/
  int	*indent_level;		/* Indentation level (for each row)	*/
  int	select_set_expected;	/* If non-zero, select set is expected	*/
  int	*select_set;		/* Array of integers representing the	*/
				/*    selected data			*/
  int	input_expected;		/* Input to form expected		*/
  int	*h1_pos;		/* Positions of data in header row 1	*/
  char	**h1_data;		/* Data for header row 1		*/
  int	*h2_pos;		/* Positions of data in header row 2	*/
  char	**h2_data;		/* Data for header row 2		*/
  int	*h3_pos;		/* Positions of data in header row 3	*/
  char	**h3_data;		/* Data for header row 3		*/

  char	**data;			/* Data form form			*/
};

struct FC_search_data_st
  {
    int sts;			/* exit status of form (Cancel or Accept)*/
    struct node_st *head;	/* linked list of current expression */
    int search_x,search_y;
    int button_x,button_y;
    int attr_x,attr_y;
    char *title;
    char *name;

    int attr_count;
    char **attr_list;
    int *attr_type;
    char **fn_ptr;
    char **fn_arg;
  };

struct FC_define_data_st
  {
    int sts;
    int mode;
    char *title;
    char *name;
    
    struct FC_define_node_st **row;
    int row_count;
    int attr_count;
    char **attr_list;
    int *attr_type;
    int *attr_widths;
    int req_attr_count;
    char **req_attr_list;
  };

struct FC_review_data_st
  {
    int sts;
    char *title;
    struct FC_define_node_st **row;
    int row_count;
  };

struct FC_define_node_st
  {
    int type;
    char *data;
    char *value;
    int pos;
    int width;
    int just;
    struct FC_define_node_st *next;
  };

struct node_st
  {
    int type;
    int value;
    char **fn_ptr;
    char *fn_arg;
    int arg_type;
    char *arg1,*arg2;
    struct node_st *prev,*next;
  };

struct FC_two_col_data_st
  {
    int sts;			/* exit status of form (accept or cancel) */
    int form_x,form_y;		/* coordinates of form    */
    int mode;			/* type of form */
    				/* TWO_COL_REG - Normal two column form */
				/* TWO_COL_SORT - Sort criteria definition */
    char *name;			/* Used in naming a search or sort criteria */
				/* NULL if you are not defining these crit. */
    char title[80];		/* title of form    */
    int num_of_rows;		/* number of rows of data   */
    int freeze_rows_count;	/* number of rows to freeze, starting */
				/*    with the top row   */
    int new_rows_expected;	/* If non-zero, new rows are expected */
    int select_set_expected;	/* If non-zero, select set is expected */

    int seq_gadgets_expected;   /* If non-zero, sequence for fields are expected */
    int next_field[22];		/* Sequence of gadget labels */
				/* ex: next_field[1] = 14    */
				/* label 2 -> label 14       */

				/* Validation function per row */
				/* Validates the second column keyin */
    int (**new_fn_ptr)();	/* Array of validation addresses for functions */
    char **new_fn_arg;		/* Array of arguments to validation functions */
    
    int *select_set;		/* Array of integers representing the */
				    /*    selected rows   */
    int *selectable;		/* Array of integers representing read-write */
				/* access per data item			     */
				/* zero - read only   non-zero - read/write */

    int *new_rows_select_col;	/* If there are new rows added, array of integers */
				/* per new column.  zero - read only         */
				/* non-zero - read/write		     */
    
    int attr_list_expected;     /* If list of values is available and type */

    int *attr_list_row;		/* Array of integers representing which rows */
				/* need a list */


    int attr_count;		/* Number of items in list */
    char **attr_list;		/* List of Items */
    int *attr_counts;
    char ***attr_lists;
    char **attr_list_data;
    int list_start_col;
    int num_of_list_data_cols;
   
    int req_data_expected;
    int *req_data;       

    char **fn_ptr;
    char **fn_arg;
    char **data;		/* Data form form   */
  };

struct FC_four_col_data_st
  {
    int sts;			/* exit status of form (accept or cancel) */
    int form_x,form_y;		/* coordinates of form    */
    char title[80];		/* title of form    */
    int num_of_rows;		/* number of rows of data   */
    int freeze_rows_count;	/* number of rows to freeze, starting */
				/*    with the top row   */
    int new_rows_expected;	/* If non-zero, new rows are expected */
    int select_set_expected;	/* If non-zero, select set is expected */

    int seq_gadgets_expected;
    int next_field[44];
    int (*new_fn_ptr[4])();
    char *new_fn_arg[4];
    
    int *select_set;		/* Array of integers representing the */
				    /*    selected rows   */
    int *selectable;
    int *new_rows_select_col;
        
    int *attr_list_row;
    int attr_list_expected;
    int attr_count;
    char **attr_list;
    char **attr_list_data;
    int num_of_list_data_cols;
    int *attr_type;
       
    char **fn_ptr ;
    char **fn_arg;
    char **data;		/* Data form form   */
  };

struct FC_six_col_data_st
  {
    int sts;			/* exit status of form (accept or cancel) */
    int form_x,form_y;		/* coordinates of form    */
    int mode;    
    char title[80];		/* title of form    */
    int num_of_rows;		/* number of rows of data   */
    int freeze_rows_count;	/* number of rows to freeze, starting */
				/*    with the top row   */
    int new_rows_expected;	/* If non-zero, new rows are expected */
    int select_set_expected;	/* If non-zero, select set is expected */
    int required_data_expected; /* If non-zero, required data is expected */

    int (*new_fn_ptr[6])();
    char *new_fn_arg[6];
    
    int *select_set;		/* Array of integers representing the */
				    /*    selected rows   */
    int *selectable;
    int *new_rows_select_col;

    int *required_data_cols;
    int *required_data_position;
    int *required_data_attr;
        
    int *attr_list_row;
    int attr_list_expected;
    int attr_count;
    char **attr_list;
    char **attr_list_data;
    int num_of_list_data_cols;
    int *attr_type;
       
    char **fn_ptr;
    char **fn_arg;
    char **data;		/* Data form form   */
  };

struct FC_three_col_data_st
  {
    int sts;			/* exit status of form (accept or cancel) */
    int form_x,form_y;		/* coordinates of form    */
    char title[80];		/* title of form    */
    int num_of_rows;		/* number of rows of data   */
    int freeze_rows_count;	/* number of rows to freeze, starting */
				/*    with the top row   */
    int new_rows_expected;	/* If non-zero, new rows are expected */
    int select_set_expected;	/* If non-zero, select set is expected */

    int seq_gadgets_expected;
    int next_field[33];
    int (*new_fn_ptr[3])();
    char *new_fn_arg[3];
    
    int *select_set;		/* Array of integers representing the */
				    /*    selected rows   */
    int *selectable;
    int *new_rows_select_col;
        
    int *attr_list_row;
    int attr_list_expected;
    int attr_count;
    char **attr_list;
    char **attr_list_data;
    int num_of_list_data_cols;
    int *attr_type;

    int req_data_expected;
    int *req_data;
       
    char **fn_ptr;
    char **fn_arg;
    char **data;		/* Data form form   */
  };

struct FC_login_data_st
  {
    int sts;			/* exit status of form (accept or cancel) */
    int form_x,form_y;		/* coordinates of form    */
    char title[80];		/* title of form    */
    int num_of_rows;		/* number of rows of data   */

    int attr_list_expected;
    int attr_count;
    char **attr_list;

    char **data;		/* Data form form   */
  };



struct FC_security_data_st
  {
    int sts;			/* exit status of form (accept or cancel) */
    int form_x,form_y;		/* coordinates of form    */
    char title[80];		/* title of form    */
    int num_of_rows;		/* number of rows of data   */
    int freeze_rows_count;	/* number of rows to freeze, starting */
				/*    with the top row   */
       
    int *select_set;		/* Array of integers representing the */
				    /*    selected rows   */
    
    char **data;		/* Data form form   */
    int  required_rows[3];
    struct node_st              *read_search;
    struct node_st		*write_search;
  };

