#ifndef SC_DATA
#define SC_DATA

struct SCcolumn_data_st
  {
    int sts;
    char title[200];		/* title of form    */
    int num_of_rows;		/* number of rows of data   */
    int num_of_cols;		/* number of columns of data   */
    int freeze_rows_count;	/* number of rows to freeze, starting */
				/*    with the top row   */
    int new_rows_expected;	/* If non-zero, new rows are expected */
    int select_set_expected;	/* If non-zero, select set is expected */

    int *col_width;

    int (**new_fn_ptr)();
    char **new_fn_arg;
    
    int *select_set;		/* Array of integers representing the */
				    /*    selected rows   */
    int *selectable;
    int *hidden;		/* Array of integers representing the */
				    /* hidden data positions   */
    int (**fn_ptr)();
    char **fn_arg;
    char **data;		/* Data form form   */
  };

struct SCfree_data_st
  {
    int sts;			/* exit status				*/
    char title[200];		/* title of form 			*/
    int	num_of_cols;		/* number of columns of data 		*/
    int	num_of_rows;		/* number of rows of data 		*/
    int	freeze_cols_count;	/* number of columns to freeze, 	*/
				/*    starting with the left column 	*/
    int	freeze_rows_count;	/* number of rows to freeze, starting	*/
				/*    with the top row			*/
  
    int	*col_just;		/* Column justification	(for each col)	*/
    int	*col_size;		/* Column size (free format form)	*/
    int	*col_pos;		/* Column position (free format form)	*/
  
    int	max_indent;		/* Maximum indentation			*/
    int	*indent_level;		/* Indentation level (for each row)	*/
    int	select_set_expected;	/* If non-zero, select set is expected	*/
    int	*select_set;		/* Array of integers representing the	*/
				/*    selected data			*/
  
    int	*h1_pos;		/* Positions of data in header row 1	*/
    char	**h1_data;	/* Data for header row 1		*/
    int	*h2_pos;		/* Positions of data in header row 2	*/
    char	**h2_data;	/* Data for header row 2		*/
    int	*h3_pos;		/* Positions of data in header row 3	*/
    char	**h3_data;	/* Data for header row 3		*/
  
    char	**data;		/* Data form form			*/
  };

#endif
