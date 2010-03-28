
/*
 robert patience
 31 october 87
*/
/*  related to type as defined in parametric.h */
#ifndef ci_macro_def
#define ci_macro_def

/* ci_macro definition of structure to access data */

struct ci_mac_st
{
  IGRchar    		ci_name [15]	/* The name of the ci file	*/;
  IGRchar             	int_name [16]   /* Internal data name           */;
  IGRshort		int_size	/* Internal data size		*/;
};


#define FROM_IN 	0
#define FROM_OUT	1

#endif
