#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<MEMerrordef.h>
#include	<PDMtypes.h>
#include	<PDUfile_def.h>
#include	<PDUproto.h>

int PDUfree_list ( data_list, number_of_rows, number_of_cols )
   char				**data_list; /* array of character strings */
   int				number_of_rows; /* number of rows to free */
   int				number_of_cols; /* number of columns to free */

/******************************************************************************

Doc:	PDUfree_list

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
	9/13/89	-	Documentation date
*****************************************************************************/

   {
   int				status = PDM_S_SUCCESS, row, col;
   extern int			PDM_debug_on;
    
   _pdm_debug("In the PDUfree list function",0);
      
   for ( row = 0; row < number_of_rows; ++row )
     for ( col = 0; col < number_of_cols; ++col )
       {
       	if ( data_list[(number_of_cols * row) + col] != NULL)
       	  free ( data_list[(number_of_cols * row) + col] );

       }
    return (status);
   }

int PDUfill_in_string( variable, string )
  char		    		**variable; /* i/o - address of variable copied string into */
  char		    		*string; /* i - character string to copy */
  {
/******************************************************************************

Doc:	PDUfill_in_string

Abstract:
	Allocates memory and copies a string into it.

Algorithm:
	.bp
		1.	If the address of the variable of which you are storing the variable is not NULL, Free the memory previously used by the variable.
		2.	If the string is not NULL, allocate the amount of memory need to store the string and copy it into the variable.
	.ep

Return Status:
	PDM_S_SUCCESS	-	Successful completion
Caveats:

History:
	9/13/89	-	Documentation date
*****************************************************************************/

  int				status = PDM_S_SUCCESS;
  
  if ( (*variable != NULL) && (strcmp(*variable, "")) )
    {
        free (*variable);
        *variable = NULL_STRING;		      
    }
    
  if ( string != NULL )                              
    {
    *variable = (char *) malloc ( strlen(string) + 1);
    strcpy (*variable, string);
    }
 
  return( status );
  }

int PDUfill_in_string1( variable, string )
  char                          **variable; /* i/o - address of variable copied
string into */
  char                          *string; /* i - character string to copy */
  {
/******************************************************************************

Doc:    PDUfill_in_string1

Abstract:
        Allocates memory and copies a string into it.

Algorithm:
        .bp
                1.      If the address of the variable of which you are storing
the variable is not NULL or "" (Null String), Free the memory previously used bythe variable.
                2.      If the string is not NULL or "" (Null String), allocate the amount of memory need to store the string and copy it into the variable.
        .ep

Return Status:
        PDM_S_SUCCESS   -       Successful completion
Caveats:

History:
        11/11/91 -       Documentation date
*****************************************************************************/


  int                           status = PDM_S_SUCCESS;

  if (( *variable != NULL ) && (strcmp(*variable,"") != 0))
    {
    free (*variable);
    *variable = "";
    }

  if (( string != NULL ) && (strcmp(string,"") != 0))
    {
    *variable = (char *) malloc ( strlen(string) + 1);
    strcpy (*variable, string);
    }

  return( status );
  }

