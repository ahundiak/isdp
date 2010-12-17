/* PDM debug include file */

#include	<stdio.h>

#define DEBUG
extern int	PDM_debug_on;

/* #define  PDUdealloc(variable) \
  if (PDM_debug_on) \
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

#define _pdm_colptr(buffptr,row,col) \
	((char *) (((char **) buffptr->data_ptr) [(row * buffptr->columns)+col]))

#define _pdm_memcheck(var) if (var == NULL)  return( PDM_E_COULD_NOT_MALLOC );

#define _streq(s1,s2) (!strcmp(s1,s2))

#define _pdm_max(x,y) ( ( (x) > (y) ) ? (x) : (y) )

#define _nullstr(x) ( x == 0 || !strcmp(x,"") )

#ifdef DEBUG
#define _pdm_debug_list(name,list,rows,cols) \
  { \
  int i,j; \
  if ( PDM_debug_on ) \
     { \
     printf("\nList %s has %d items, %d columns: \n", name, rows, cols); \
     for ( i = 0; i < rows; ++i ) \
	 { \
	 for ( j = 0; j < cols; ++j ) \
	     printf (" %s [%d,%d] = %s\n",name, i, j, list[(cols*i)+j]); \
	 printf("\n"); \
	 } \
     } \
  }

#define _pdm_obj_info(status) \
  { \
  fprintf(stderr,"OM_Gw_current_OS = %d,   OM_GO_current_OS_objid = %d\n", \
	  OM_Gw_current_OS, OM_GO_current_OS_objid); \
  fprintf(stderr,"my_id = %d   sender_id = %d   sender_os = %d\n", my_id, \
	  sender_id, sender_os ); \
  om$report_error (sts=status); \
  }

#define _pdm_check1(meth,sts1) \
	{ \
	if ( PDM_debug_on ) \
	if ( sts1&1 ) \
	   { \
	   fprintf(stderr, "%s message was sent, status = %d\n", meth, sts1); \
	   if (sts1 != 1) \
	      { \
	      om$report_error (sts=sts1); \
	      } \
	   } \
	else \
	   { \
	   fprintf(stderr, "%s message was sent, status = %d\n", meth, sts1); \
	   _pdm_obj_info(sts1) \
	   } \
	}

#define _pdm_check2(meth,sts1,sts2) \
	{ \
	if ( PDM_debug_on ) \
 	if ( (1&sts1)&&(sts2) ) \
	   { \
	   fprintf(stderr,"%s message succeeds: %d, status = %d\n", \
		   meth, sts2, sts1); \
	   if (sts1 != 1) \
	      { \
	      om$report_error (sts=sts1); \
	      } \
	   } \
	else \
	   { \
	   fprintf (stderr, "%s message returns: %d\n", meth, sts2); \
	   _pdm_obj_info(sts1) \
	   } \
	}

#define _pdm_check_abort(sts1) if (!((sts1)&1)) \
	{ fprintf(stderr,"->%d<-\n",sts1);strcpy(0,"x"); }

#ifdef VERBOSE
#define _verbose(x) x
#else
#define _verbose(x)
#endif
#else
#define _pdm_debug_list(name,list,rows,cols)
#define _pdm_check1(meth,sts1)
#define _pdm_check2(meth,sts1,sts2)
#define _pdm_check_abort(sts1)
#endif
