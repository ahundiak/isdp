union cl_typ
  {
  short	type;		/* cl_type[0]=original shape type written to file */
  char	cl_type[2];	/* cl_type[1]=shape type for reporting purposes   */
  } hard_soft;		/*            legitimate values are 1 , 2 or 4    */

