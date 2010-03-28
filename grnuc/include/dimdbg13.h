#ifndef dm_static
#define dm_static
#endif

/***********************************************************************
  PPL include file defining all debug and trace functions and macros
  
  Bruno Demars
  
  date :	August 31, 1988
***********************************************************************/
#ifndef DIM_DEV_DEBUG
#define DIM_DEV_DEBUG

/*****************************************************************
                           DEBUG MACROS  
******************************************************************/
#ifdef DEBUG

dm_static int    _TRACE;
dm_static int    _DEBUG;

/*.......................*/
extern DIreport_error();

/*.......................*/
#define DIM_ERROR(rc,message)\
	if (rc != 1)\
	 {\
	  printf("DIM_ERROR %d : %s \n",rc,message);\
         }

/*.......................*/
#define DIM_DEBUG(action)\
        if (_DEBUG)\
         {\
          printf("\t");\
          action;\
          printf("\n");\
         }
        
/*.......................*/
#define list_debug(num,elem) \
        if (_DEBUG)\
         {\
          for (i=0; i<num; i=i+1) {\
           printf ("elem[i]= %d  \n", elem[i]); }\
         }


/*.......................*/
#define DIM_TRACE(action)\
        if (_TRACE)\
         {\
          printf("\t");\
          action;\
          printf("\n");\
         }
        
/***************************** NO DEBUG ***************************/

#else

#define DIreport_error(stat, message, string)
#define DIM_ERROR(rc,message)
#define DIM_DEBUG(action)
#define list_debug(num,elem) 
#define DIM_TRACE(action)

#endif





/*****************************************************************
                           TRACE MACROS
******************************************************************/
#ifdef DEBUG
  
#define wait(message) \
    strcpy(_string, message);\
    strcat(_string, ", wait for return");\
  prompt (_string);\
  ci$get(string = response);\
  prompt ("continue...");


	int trace_depth; /* accessed by trace_in and trace_out functions */

trace_in(p_fun_name)

char	*p_fun_name;
{
	int i;
	
  if (_TRACE)
  {
    printf("\n>>> ENTER ");
    for (i= 0; i<trace_depth; i=i+1)
      printf("\t");
    printf ("%s \n",p_fun_name );
   trace_depth = trace_depth + 1;
   }
}


trace_out(p_fun_name)

char	*p_fun_name;
{
	int i;
	
  if (_TRACE)
  {
   trace_depth = trace_depth - 1;
    printf("\n>>> EXIT ");
    for (i= 0; i<trace_depth; i=i+1)
      printf("\t");
    printf ("%s \n",p_fun_name );
   }
}



/***************************** NO DEBUG ***************************/


#else

#define wait(message)
#define trace_in(message)
#define trace_out(message)

#endif

#endif
