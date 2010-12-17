#include	<string.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<stdio.h>
#include	<ctype.h>
#include	"rMRPstr.h"
#include	"MRPmacros.h"
#include 	"MRPmessage.h"
#include 	"PDUstr.h"
#include 	"PDUproto.h"
#include	"MRPintdef.h"

#define		finished = -1;

/* Externs */
extern struct PSUrpt	*PDU_pdurpt;
extern struct PSUattr	*psuattr;
extern int MRP_debug_on;

int rMRPfree_pdurpt(pdurpt)
struct PSUrpt	**pdurpt;
 {
  struct  dba_default_list *rpt_list = NULL;

  _pdm_debug("In the rMRPfree__PDU_pdurpt function",0);
  if (( (*pdurpt)->list != NULL ) && ( (*pdurpt)->list_total != 0 ))
      {
	 rpt_list = (*pdurpt)->list;
         _pdm_debug("before rpt_list free",0);
         free( rpt_list );
         _pdm_debug("rpt_list structure free",0);
	 (*pdurpt)->list = NULL;
       }

  if ( (*pdurpt)->where != NULL )
	 {
         free( (*pdurpt)->where );
	 (*pdurpt)->where = NULL;
	 }

  if ( (*pdurpt)->templib != NULL )
	 {
         free( (*pdurpt)->templib );
	 (*pdurpt)->templib = NULL;
	 }

  if ( (*pdurpt)->justification != NULL )
	 {
         free( (*pdurpt)->justification );
	 (*pdurpt)->justification = NULL;
	 }

  if ( *pdurpt != NULL )
      {
      free ( *pdurpt );
      *pdurpt = NULL;
      }
return( MRP_S_Success );
}

int rMRPfree_psurpt()
 {
  struct  dba_default_list *rpt_list = NULL;

  _pdm_debug("In the rMRPfree__PDU_pdurpt function",0);
  _pdm_debug("free rpt_list total = %d", (char *)PDU_pdurpt->list_total);
  if (( PDU_pdurpt->list != NULL ) && ( PDU_pdurpt->list_total != 0 ))
      {
	 rpt_list = PDU_pdurpt->list;
         _pdm_debug("before rpt_list free",0);
         free( rpt_list );
         _pdm_debug("rpt_list structure free",0);
	 PDU_pdurpt->list = NULL;
       }

  if ( PDU_pdurpt->where != NULL )
	 {
         free( PDU_pdurpt->where );
	 PDU_pdurpt->where = NULL;
	 }

  if ( PDU_pdurpt->templib != NULL )
	 {
         free( PDU_pdurpt->templib );
	 PDU_pdurpt->templib = NULL;
	 }

  if ( PDU_pdurpt->justification != NULL )
	 {
         free( PDU_pdurpt->justification );
	 PDU_pdurpt->justification = NULL;
	 }

  if ( PDU_pdurpt != NULL )
      {
      free ( PDU_pdurpt );
      PDU_pdurpt = NULL;
      }
return( MRP_S_Success );
}

int rMRPfree_psuattr(total)
  int total;
 {
  int cnt=0;

  _pdm_debug("In the rMRPfree__psuattr function",0);
  _pdm_debug("free psuattr total = %d", (char *)total);
  if (( psuattr != NULL ) && ( total != 0 ))
      for ( cnt = 0; cnt < total; ++cnt )
      {
	 if ( psuattr[cnt].name != NULL )
            free( psuattr[cnt].name);
	 if ( psuattr[cnt].syn != NULL )
            free( psuattr[cnt].syn);
	 if ( psuattr[cnt].datatype != NULL )
            free( psuattr[cnt].datatype);
       }

  if ( PDU_pdurpt != NULL )
      {
      free ( psuattr );
      psuattr = NULL;
      }

return( MRP_S_Success );
}

int	MRPstrcpy (variable, value)
  char	**variable;
  char	*value;
  {

  if ( *variable != NULL )
     {
     free (*variable);
     *variable = NULL;
     }

  if ( (value != NULL) && strcmp(value, NULLSTR) )
     {
     *variable = (char *) malloc ( strlen(value) + 1);
     strcpy (*variable, value);
     }

  return ( MRP_S_Success );
  }

int	MRPstrcpy2 (variable, value)
  char	**variable;
  char	*value;
  {

  *variable = NULL;
  if ( (value != NULL) && strcmp(value, NULLSTR) )
     {
     *variable = (char *) malloc ( strlen(value) + 1);
     strcpy (*variable, value);
     }

  return ( MRP_S_Success );
  }

int  MRPdealloc (variable)
  char	**variable;
  {
  if ( *variable != NULL )
     {
     free(*variable);
     *variable = NULL;
     }

  return (MRP_S_Success);
  }

int PSUfree_list ( data_list, number_of_rows, number_of_cols )
   char				**data_list; /* array of character strings */
   int				number_of_rows; /* number of rows to free */
   int				number_of_cols; /* number of columns to free */

/******************************************************************************

Doc:	PSUfree_list

Abstract:
	Frees memory allocated for character strings in an array.
	
Algorithm:
	.bp
		1.	For each row and column entry, check to see if the address is NULL.
		2.	If it isn't NULL, free the memory.
		3.	If not the last row and column, go back to step 1.
	.ep
Return Status:
	PDM_S_SUCCESS	-	Successful completion
Caveats:

History:
	9/18/90	-	Documentation date
*****************************************************************************/

   {
   int				status = MRP_S_Success, row, col;
   extern int			MRP_debug_on;
    
   _pdm_debug("In the MRPfree list function",0);
      
   for ( row = 0; row < number_of_rows; ++row )
     for ( col = 0; col < number_of_cols; ++col )
       {
       	if ( data_list[(number_of_cols * row) + col] != NULL)
       	  free ( data_list[(number_of_cols * row) + col] );

       }
    return (status);
   }

