#ifndef vdmemmacro_include
#define vdmemmacro_include

/* I/VDS
 *
 * File:        ~VDS/include/vdmemmacros.h
 *
 * Description: This file contains macros for mallocing string lists
 *		and freeing them.
 *
 * History:
 *      11/04/94        Raju MSB
 *
 */

/*============================================================================*/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern long VDmalloc_str_list __((
  char			***str_list,
  int			num_str,
  int			str_size
));

extern long VDfree_str_list __((
  char			**str_list,
  int			num_str
));

#if defined(__cplusplus)
}
#endif

/*============================================================================*/
/* -----------------------------------------------------------------------------

Macro
  vd$malloc_str_list();

Abstract
  Mallocs '*str_list' to point to 'num_list' of character strings.
  Each strings is allocated a string size of 'str_size'.

Arguments
  char ***str_list	I/O - list containing strings
  int  num_str		I   - no. of strings needed in '*str_list'
  int  str_size		I   - size of each string

Return status
  1 =  Memory has been successfully malloced.
  0 =  Failure. Can not allocate memory ( insufficient memory )

  EXAMPLE
  char		**StrList = NULL;
  int		NbStr, StrSize;

    NbStr = 10;
    StrSize = 81;

    sts = vd$malloc_str_list  (  str_list = &str_list,
				 num_str  = NbStr,
				 str_size = StrSize    );
    if ( !sts )
    {
       printf("Can not allocate memory\n");
    }

    sts = vd$free_str_list  (	str_list = str_list,
				num_str  = NbStr     );

  ------------------------------------------------------------------------- */

#omdef  vd$malloc_str_list(	str_list,
				num_str ,
				str_size  )

	VDmalloc_str_list ( (str_list), (num_str), (str_size) )

#endomdef


/* -----------------------------------------------------------------------------

Macro
  vd$free_str_list();

Abstract
  Frees a list of strings.

Arguments
  char **str_list	I   - list containing strings
  int  num_str		I   - no. of strings needed in 'str_list'

Return status
  1  always

  EXAMPLE
  char		**StrList = NULL;
  int		NbStr, StrSize;

    NbStr = 10;
    StrSize = 81;

    sts = vd$malloc_str_list  (  str_list = &str_list,
				 num_str  = NbStr,
				 str_size = StrSize    );
    if ( !sts )
    {
       printf("Can not allocate memory\n");
    }

    sts = vd$free_str_list  (	str_list = str_list,
				num_str  = NbStr     );

  ------------------------------------------------------------------------- */

#omdef  vd$free_str_list(  str_list,
			   num_str   )


	VDfree_str_list ( (str_list), (num_str) )

#endomdef

#endif
