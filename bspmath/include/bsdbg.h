/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsdbg_include
# define bsdbg_include

# define BSNBALLOC 5000

struct  BSlsalloc 
  {
  IGRint  nbmax;
  IGRint  number;
  IGRchar **list;
  };

/*  value of BSdbglev :  		 				*/
/*    0  : no check of overwrite in stackalloc and malloc arrays  	*/
/*   20  : check of overwrite in stackalloc and malloc arrays		*/

# endif /* bsdbg_include */
