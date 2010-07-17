 
#ifndef dbs_def
#define dbs_def

#define MAX_ATTR      200   /* max number of attributes for family catalogue */
#define MAX_SIZE_LINE 600   /* max length for a line (see struct buff_attr)  */
#define MAX_ISO_ATTR  100   /* max attributes retrieve for ISOGEN	     */

/* The following define are used to define the type of the attributes 
 * define in the following structure
 */

#define IS_ASCI    1
#define IS_NPD	   2  /* for connect point size  */
#define IS_INT     3
#define IS_REAL    4
#define IS_NDEF	   5  /* for attributes not yet defined */

struct row_attr
 {
  short		length[MAX_ISO_ATTR];	/* length of the asci attributes     */
  short 	type[MAX_ISO_ATTR];     /* type of the attributes	     */
  char  	attr[MAX_SIZE_LINE];    /* array of asci attributes	     */	
  short 	nb_attr;		/* number of attributes for the line */
 };

struct  buff_attr 
  {
   int   	    nb_buff;	/* number of lines 			*/
   struct row_attr *row_attr;   /* for each row				*/
  };


#endif

