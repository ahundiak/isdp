/*  Global structure  */

struct	NFMRglobal_st
  {
	int  date_format;
	int  override;
	long NETid;
	long administrator; /* 1 if user is admin, else 0 */
	long query_rows;    /* number of rows to be used in block querys
			       0 if block querys not used (default) */
	long do_not_register_PDM;   /* 0 if we will register PDM assemblies,
				      else 1 */
			     
  };
