/* MRP debug include file */

#include	<stdio.h>

#define DEBUG
extern int	MRP_debug_on;             /* defined in MRPmaster.c */
extern int	PDM_debug_on;           
extern FILE 	*rMRPdbg_fileptr;

/* #define  PDUdealloc(variable) \
  if (MRP_debug_on) \
     { \
     printf("Calling free from line %d in \"%s\"\n",__LINE__,__FILE__); \
     printf("ptr = %x\n", *variable); \
     } \
  if ( *variable != NULL ) \
     { \
     free((*variable)); \
     *variable = NULL; \
     }
*/

#define _mrp_colptr(buffptr,row,col) \
	((char *) (((char **) buffptr->data_ptr) [(row * buffptr->columns)+col]))

#define _mrp_memcheck(var) if (var == NULL)  return( MRP_E_COULD_NOT_MALLOC );

#define _streq(s1,s2) (!strcmp(s1,s2))

#define _mrp_max(x,y) ( ( (x) > (y) ) ? (x) : (y) )

#define _nullstr(x) ( x == 0 || !strcmp(x,"") )

#ifdef DEBUG
#define _mrp_debug_list(name,list,rows,cols) \
  { \
  int i,j; \
  if ( MRP_debug_on ) \
     { \
     fprintf(rMRPdbg_fileptr, "\nList %s has %d items, %d columns: \n", name, rows, cols); \
     for ( i = 0; i < rows; ++i ) \
	 { \
	 for ( j = 0; j < cols; ++j ) \
	     fprintf (rMRPdbg_fileptr, " %s [%d,%d] = %s\n",name, i, j, list[(cols*i)+j]); \
	 fprintf(rMRPdbg_fileptr, "\n"); \
	 } \
     } \
  }

#define _mrp_debug(message,variable) \
  { \
  if ( PDM_debug_on ) \
     { \
     printf("MRP -- "); \
     if (variable) \
	printf(message,variable); \
     else \
        printf(message); \
     printf("\n"); \
     } \
  }

#define _mrp_debug2(message,variable, variable2) \
  { \
  if ( PDM_debug_on ) \
     { \
     printf("MRP -- "); \
	printf(message,variable, variable2); \
     printf("\n"); \
     } \
  }

#define _mrp_debug_mes(message) \
  { \
  if ( PDM_debug_on ) \
     { \
     printf("MRP -- "); \
	printf(message); \
     printf("\n"); \
     } \
  }

#define _mrp_status(meth,sts1) \
	{ \
	if ( MRP_debug_on ) \
	   { \
	   fprintf(rMRPdbg_fileptr, "MRP -- %s returns, status = %d\n", meth, sts1); \
	   } \
	}

#define _mrp_status2(meth,sts1,sts2) \
	{ \
	if ( MRP_debug_on ) \
	   { \
	   fprintf(rMRPdbg_fileptr, "MRP -- %s returns: %d, status = %d\n", meth, sts2, sts1); \
	   } \
	}


#define _mrp_check_abort(sts1) if (!((sts1)&1)) \
	{ fprintf(stderr,"->%d<-\n",sts1);strcpy(0,"x"); }

#ifdef VERBOSE
#define _verbose(x) x
#else
#define _verbose(x)
#endif
#else
#define _pdm_debug(message,variable)
#define _pdm_debug_mes(message)
#define _pdm_debug2(message,variable,variable2)
#define _pdm_debug_list(name,list,rows,cols)
#define _pdm_status(meth,sts1)
#define _pdm_status2(meth,sts1,sts2)
#define _pdm_check_abort(sts1)
#endif
