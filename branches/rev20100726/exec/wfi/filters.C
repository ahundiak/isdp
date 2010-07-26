
\
#include <OMminimum.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <exproto.h>

#define debug 0



/*****************************************************/
/*                                                   */
/*       EX_get_keyin                                */  
/*                                                   */
/*****************************************************/



int EX_get_keyin(response,response_data,mode)

 int *response;
 char *response_data;
 int mode;

 {
     int num_bytes;

     do
     {
        EX_wait_for_input(response,response_data,mode,&num_bytes);
     }
     while((*response==DATA) || (*response==D_DATA));
     return(1);

 } /* EX_get_keyin */




/*****************************************************/
/*                                                   */
/*       EX_keyin_no_cmd                             */  
/*                                                   */
/*****************************************************/

int EX_keyin_no_cmd(response,response_data,mode)

 int *response;
 char *response_data;
 int mode;

 {
  int num_bytes;

  do 
  {
     EX_wait_for_input(response,response_data,mode,&num_bytes);
  }
  while((*response==DATA)    || (*response==D_DATA) || 
        (*response==COMMAND) || (*response==D_COMMAND));
     return(1);
 } /* EX_keyin_no_cmd */



/*****************************************************/
/*                                                   */
/*       EX_get_input                                */  
/*                                                   */
/*****************************************************/

int EX_get_input(response,response_data,mode)

 int *response;
 char *response_data;
 int mode;

 {
    int num_bytes;
 
    EX_wait_for_input(response,response_data,mode,&num_bytes);
    return(1);
 } 
