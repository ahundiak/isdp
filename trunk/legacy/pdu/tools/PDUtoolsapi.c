#include "PDUextdef.h"
#include "PDUerror.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"

int PDUadd_buffer_string(buff_string, position, char_string)
  char			*buff_string;
  int			*position;
  char			*char_string;
  {
    _pdm_debug("In the function PDUadd_buffer_string",0);

    strcpy((buff_string + (*position)), char_string);
    (*position) += strlen(char_string);

    buff_string[(*position)++] = PDM_BUFFER_TERM;
    return(PDM_S_SUCCESS);
  }


int PDUvalid_attr( string, arg, msg )
   char				*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				char_index;
      
   _pdm_debug("Validating a attribute name", 0);
   _pdm_debug("string = <%s>", string);

   if ( strlen(string) > PDU_NFM_ATTR_LEN )
     {
        sprintf(msg,"Attribute is more than %d characters", PDU_NFM_ATTR_LEN);
        return(PDM_E_INVALID_INPUT);
     }

   if ( isdigit ( string[0] ))
     {
     strcpy(msg,"A digit is not valid for first character");
     return(PDM_E_INVALID_INPUT);
     }

   if (strcmp(string, "p_sketch") == 0)
     return(PDM_S_SUCCESS);
   else if (strcmp(string, "p_macro") == 0)
     return(PDM_S_SUCCESS);
   else if (strcmp(string, "p_altpartno") == 0)
     return(PDM_S_SUCCESS);
   else if (strcmp(string, "p_flatten") == 0)
     return(PDM_S_SUCCESS);
   if (strchr(string, '\'') != NULL)
     {
     strcpy(msg,"Single Quotes are Invalid");
     status = PDM_E_BAD_DATA;
     return(status);
     }

   for ( char_index = 0; ((char_index < strlen(string)) && 
        (status == PDM_S_SUCCESS)); ++char_index )
     {
       if ( string[char_index] == ' ' )
         {
          strcpy(msg,"Blank Characters are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
       else if ( string[char_index] == '"' )
         {
          strcpy(msg,"Double Quotes are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
       else if ( string[char_index] == ';' )
         {
          strcpy(msg,"Semi-colons are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
       else if ( string[char_index] == '.' )
         {
          strcpy(msg,"Periods are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
 
     } 
   return(status);
   }


int PDUvalid_timestamp( string, msg )
  char 		*string;	/* number to validate */
  char		*msg;		/* error message string */

/*****************************************************************************/
/*                                                                           */
/*  Document: PDUvalid_timestamp                                             */
/*  Purpose : This function validates timestamps                             */
/*  Author  : Jenny Brewer                                                   */
/*  Input   :                                                                */
/*            char *string    number to validate                             */
/*            char *arg       type of number to validate                     */
/*            char *msg       error message string                           */
/*                                                                           */
/*****************************************************************************/

{
int    status = PDM_S_SUCCESS;

int		string_len, char_index, DIGIT_FOUND = FALSE;

  _pdm_debug("Validating Datatype Timestamp", 0);
  _pdm_debug("string = <%s>", string);
  
  string_len = strlen(string);
  
  if ( string_len != 19)
    {
    strcpy(msg, "Invalid Number");
    status = PDM_E_INVALID_INPUT;
    }
  
    
  for ( char_index = 0;((char_index < string_len) && (status == PDM_S_SUCCESS));
       ++char_index )
    {
     
     if ( isdigit ( string[char_index] ))
       {
       _pdm_debug("It is a digit",0);
       if ( DIGIT_FOUND == FALSE )
         DIGIT_FOUND = TRUE;
       }
     else 
       if (string[char_index] == '/')
         {
          _pdm_debug("Verify timestamp is in the form mm/dd/yyyy hh:mm:ss",0);
          if (char_index != 2)
            if (char_index != 5)
              {
              status = PDM_E_INVALID_INPUT;       
              strcpy(msg, "Timestamp not in format mm/dd/yyyy hh:mm:ss");
              }
            else 
              _pdm_debug("Index is 5",0);
          else 
            _pdm_debug("Index is 2",0);
          }
     else 
       if (string[char_index] == ':')
         {
          _pdm_debug("Verify timestamp is in the form mm/dd/yyyy hh:mm:ss",0);
          if (char_index != 13)
            if (char_index != 16)
                {
                status = PDM_E_INVALID_INPUT;       
                strcpy(msg, "Timestamp not in format mm/dd/yyyy hh:mm:ss");
                }
            else 
              _pdm_debug("Index is 16",0);
          else 
            _pdm_debug("Index is 13",0);
          }
     else 
       if (string[char_index] == ' ')
         {
          _pdm_debug("Verify timestamp is in the form mm/dd/yyyy hh:mm:ss",0);
          if (char_index != 10)
            {
            status = PDM_E_INVALID_INPUT;       
            strcpy(msg, "Timestamp not in format mm/dd/yyyy hh:mm:ss");
            }
          else 
            _pdm_debug("Index is 10",0);
         }
    else 
      {
      status = PDM_E_INVALID_INPUT;
      strcpy(msg, "Illegal Characters");  
      }
    }

  return(status);
  }


int PDUvalid_number( string, arg, msg )
  char 		*string;	/* number to validate */
  char		*arg;		/* type of number to validate */
  char		*msg;		/* error message string */

/******************************************************************************

Doc:	PDUvalid_number

Abstract:
	Validates integer and float numbers.
	
Algorithm:
	.bp
		1.	If the string length of the number is zero, return error message.
		2.	Check each character to make sure it is a digit.  If it isn't, return an error message.
		3.	If there is a blank in the number, return an error message.
		4.	If there is a '-' character after a digit, return an error message.
		5.	If there is a '.' character found and the type is integer, return an error message.
		6.	
	.ep

Return Status:

Caveats:

History:

*****************************************************************************/

  {
  int		status = PDM_S_SUCCESS; /* PDM status */
  int		string_len, char_index, DIGIT_FOUND = FALSE;
  int		DECIMAL_FOUND = FALSE;

  _pdm_debug("Validating the %s type of number", arg);
  _pdm_debug("string = <%s>", string);
  
  string_len = strlen(string);
  
  if ( string_len == 0 )
    {
    strcpy(msg, "Invalid Number");
    status = PDM_E_INVALID_INPUT;
    }
    
  for ( char_index = 0;((char_index < string_len) && (status == PDM_S_SUCCESS));
       ++char_index )
    {
     
     if ( isdigit ( string[char_index] ))
       {
       _pdm_debug("It is a digit",0);
       if ( DIGIT_FOUND == FALSE )
         DIGIT_FOUND = TRUE;
       }
     else 
       if (( string[char_index] == ' ' ) || ( string[char_index] == '-' ))
         {
         if ( DIGIT_FOUND )
           {
           sprintf( msg, "Invalid number %s", string);
           status = PDM_E_INVALID_INPUT;
           }
         else
           if ( string[char_index] == '-' )
             DIGIT_FOUND = TRUE;
         }
       else       
         {
         if ( string[char_index] == '.') 
           {
           if ( strncmp (arg, "I",1) == 0 )
             {
             sprintf(msg, "Decimal Number %s is not valid",  string); 
             status = PDM_E_INVALID_INPUT;
             }
           else if (DECIMAL_FOUND)
             {
             sprintf( msg, "Invalid number %s", string);
             status = PDM_E_INVALID_INPUT;
             }
           else 
             DECIMAL_FOUND = TRUE;
           }
         else
           {
            sprintf(msg, "Invalid Digit %c in Number",  string[char_index]);
            status = PDM_E_INVALID_INPUT;
           }
         }

    }

  return(status);
  }

int PDUvalid_string( string, arg, msg )
   char 			*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				length;

  _pdm_debug("Validating a character string", 0);
  _pdm_debug("string = <%s>", string);

  _pdm_debug("arg = <%s>", arg);
     
   sscanf(arg,"%d",&length);
   _pdm_debug("Length = %d", (char *)length);
   
   if ( strlen(string) > (length) )
     {
     _pdm_debug("String is too LONG",0);     	
     sprintf( msg, "Value has more than characters");
     status = PDM_E_IDENTIFIER_TOO_LONG;
     
     }   
   return(status);
     
   }


int PDUvalid_smallint( string, arg, msg )
  char 		*string;	/* number to validate */
  char		*arg;		/* type of number to validate */
  char		*msg;		/* error message string */

/*****************************************************************************/
/*                                                                           */
/*  Document: PDUvalid_smallint                                              */
/*  Purpose : This function validates small integers                         */
/*  Author  : Jenny Brewer                                                   */
/*  Input   :                                                                */
/*            char *string    number to validate                             */
/*            char *arg       type of number to validate                     */
/*            char *msg       error message string                           */
/*                                                                           */
/*  Range   : Integer value from -32768 to 32767                             */
/*                                                                           */
/*****************************************************************************/

  {
  int	  length, index, value = 0;
  int     status ;       
  int     DIGIT_FOUND = FALSE;

  status = PDM_S_SUCCESS;
  length = strlen(string);
  
  if ( length == 0 )
    {
    strcpy(msg, "Invalid Number");
    status = PDM_E_INVALID_INPUT;
    }
    
  for ( index = 0;((index < length) && (status == PDM_S_SUCCESS));
       ++index )
    {
     
     if ( isdigit ( string[index] ))
       {
       _pdm_debug("It is a digit",0);
       if ( DIGIT_FOUND == FALSE )
         DIGIT_FOUND = TRUE;
       }
     else 
       if (( string[index] == ' ' ) || ( string[index] == '-' ))
         {
         if ( DIGIT_FOUND )
           {
           sprintf( msg, "Invalid number %s", string);
           status = PDM_E_INVALID_INPUT;
           }
         else
           if ( string[index] == '-' )
             DIGIT_FOUND = TRUE;
         }
       else       
         {
         if ( string[index] == '.') 
           {
             sprintf(msg, "Decimal Number %s is not valid",  string); 
             status = PDM_E_INVALID_INPUT;
           }
         else
           {
            sprintf(msg, "Invalid Digit %c in Number",  string[index]);
            status = PDM_E_INVALID_INPUT;
           }
         }

    }
  if (status == PDM_S_SUCCESS)
    {   
    /* convert character to integer */ 
    _pdm_debug("convert string to integer", 0);
    sscanf( string,"%d", &value);
    _pdm_debug("Integer Value is %d", (char *)value);
    if ((value > -32769) && (value < 32768))
      { 
      _pdm_debug("Value is in the range -32768 to 32767", 0);
      status = PDM_S_SUCCESS;
      }
    else
      {
      sprintf(msg," Value %d is not in range", (char *)value);
      status = PDM_E_INVALID_INPUT;
      }
    }

  return(status);
  }

int PDUfind_attr_in_buffer(buffer, attr)
  MEMptr	buffer; 	/* i - buffer of attributes */
  char		*attr;		/* i - attribute or synonym */

/******************************************************************************

Doc:	PDUfind_attr_in_buffer

Abstract:
	Finds the row in a buffer which contains an attribute or synonym.
	
Algorithm:
	.bp
		1.	If the attribute name passed in is equal to the row in the buffer, return the row number and exit function.
	.ep

Return Status:
	none	

Caveats:

History:
	9/13/89	-	Documentation date
*****************************************************************************/

  {
  int		row;
  int		col;
  char 		**data;

  data = (char **)buffer->data_ptr;

  for (row=0; row<buffer->rows; ++row)
    {
      for (col=0; col<buffer->columns; ++col)
        {
          if (strcmp(data[(buffer->columns * row) + col],attr) == 0)
            break;
        }
      if ( col < buffer->columns)
        break;
    }

  if (row == buffer->rows)
    row = -1;

  return(row);
  }    

int PDUvalid_datatype( string, arg, msg )
   char				*string;
   char				*arg;
   char				*msg;
   {
   /*int			status = PDM_S_SUCCESS;	APOGEE */
   int				i, bad_char;
  int                           length, arg_length;
   /*int                        value1 = 0;value2 = 0;  APOGEE */
   _pdm_debug("Validating a datatype", 0);
   _pdm_debug("string = <%s>", string);
   _pdm_debug("arg = <%s>", arg);
   if ( strlen(string) > PDU_NFM_DATATYPE_LEN )
     {
      sprintf(msg, "Data type is more than %d characters", PDU_NFM_DATATYPE_LEN);
      return(PDM_E_INVALID_INPUT);
     }

    /*ALR  10/23/93  Do not allow to change datatype */ 
  if ((arg != NULL) && (strcmp(arg, "") != 0))
  {
    if ((strncmp(arg,"char",4) == 0) ||
     (strncmp(arg,"Char",4) == 0))
       {
         if ((strncmp(string,"char",4)) && 
            (strncmp(string,"Char",4)))
            {
               _pdm_debug("Can not change datatype",0);
               strcpy(msg,"Can not change datatype");
               return(PDM_E_INVALID_DATATYPE);
             }
      }
   }  
   if (strcmp(string,"integer")) 
    if (strcmp(string,"Integer"))
     if (strcmp(string,"real"))
      if (strcmp(string,"Real"))
       if (strcmp(string,"double"))
        if (strcmp(string,"Double"))
         if (strcmp(string, "timestamp"))
          if (strcmp(string, "Timestamp"))
           if ( strcmp(string,"smallint"))
            if ( strcmp(string,"Smallint"))
             if ( strcmp(string,"decimal"))
              if ( strcmp(string,"Decimal"))
                if (( strncmp(string,"char",4)) && 
                   ( strncmp(string,"Char",4)))
                     {
                       _pdm_debug("NOT a valid datatype",0);
                       sprintf(msg,"%s is an invalid datatype",string);
                       return(PDM_E_INVALID_INPUT);
                     }
                   else
                     {
                       sscanf(string, "char(%d)", &length);
                       _pdm_debug("length is <%d>", (char *)length);
                       if (strcmp(string, "char(0)") == 0)
                         {
                          _pdm_debug("Minimum Length of 1 Character",0);
                          strcpy(msg,"Minimum Length of 1 Character");
                          return(PDM_E_MIN_1_CHAR);
                         }
                       if (length == 0)
                         {
                          _pdm_debug("Minimum Length of 1 Character",0);
                          strcpy(msg,"Minimum Length of 1 Character");
                          return(PDM_E_MIN_1_CHAR);
                         }
                       if (length > 240)
                         {
                          _pdm_debug("Maximum Length of 240 Characters",0);
                          strcpy(msg,"Maximum Length of 240 Characters");
                          return(PDM_E_MAX_240_CHARS);
                         }
                       if ((arg != NULL) && (strcmp(arg, "") != 0))
                       {
                       /* ALR make sure length of char is > old char length */
                       sscanf(arg, "char(%d)", &arg_length);

/*  7/6/95 MJG TR 139420557 - Allow char length to be decreased 
                       if (length < arg_length)
                        {
                          _pdm_debug("Can not decrease the length of char datatype",0);
                         strcpy(msg,"Length of the character datatype can only be increased");
                         return(PDM_E_DECREASE_CHAR_LEN);  
                        }   
*/
                       if (strcmp(arg,"real") == 0)
                         {
                          _pdm_debug("Can not change real to character",0);
                          strcpy(msg,"Can not change real to character");
                          return(PDM_E_REAL_CHAR);
                         }

                       if (strcmp(arg,"integer") == 0) 
                         {
                          _pdm_debug("Can not change integer to character",0);
                          strcpy(msg,"Can not change integer to character");
                          return(PDM_E_INTEGER_CHAR);
                         }

          	       if (strcmp(arg,"smallint") == 0) 
                         {
                          _pdm_debug("Can not change smallint to character",0);
                          strcpy(msg,"Can not change smallint to character");
                          return(PDM_E_SMALLINT_CHAR);
                         }

          	       if (strcmp(arg,"decimal") == 0) 
                         {
                          _pdm_debug("Can not change decimal to character",0);
                          strcpy(msg,"Can not change decimal to character");
                          return(PDM_E_DECIMAL_CHAR);
                         }

          	       if (strcmp(arg,"timestamp") == 0) 
                         {
                          _pdm_debug("Can not change timestamp to character",0);
                          strcpy(msg,"Can not change timestamp to character");
                          return(PDM_E_TIMESTAMP_CHAR);
                         } 
                       }

                       if ( string[0] == 'C' )
                         string[0] = 'c';
                   
                       if ( string[4] != '(' )
                         {
                           sprintf(msg,"Must use ( after char instead of %c",string[4]);
                           return(PDM_E_INVALID_INPUT);
                         }
                 
                       if (isdigit(string[5])) 
                         {
                           bad_char = FALSE;                   	
                  
                           length = strlen(string);
                           for(i=6; i < (length - 1); i++)
                             {
                    
                              if (!isdigit(string[i]))
                                {
                                bad_char = TRUE;
                                break;
                                }
                             }

                         if (string[(length - 1)] != ')')
                           bad_char = TRUE;
                   
                           if (bad_char)
                             {
                              sprintf(msg,"Expected digit or ) but found %c", 
                                        string[i]);
                              return(PDM_E_INVALID_INPUT);
                             }
                           else
                             return(PDM_S_SUCCESS);
                         } /* if isdigit */
                       else
                         {
                          sprintf(msg,"Found %c instead of a digit after (",string[5]);
                          return(PDM_E_INVALID_INPUT);
                         }
                       }
                     else
                       {
                       string[0] = 'd';
                       return(PDM_S_SUCCESS);
                       }
                   else
                     return(PDM_S_SUCCESS);  
                 else
                   {
                   string[0] = 's';
                   return(PDM_S_SUCCESS);
                   }
                else
                  return(PDM_S_SUCCESS);  
             else
               {
               string[0] = 't';
               return(PDM_S_SUCCESS);
               }
           else
             return(PDM_S_SUCCESS);  
          else
            {
            string[0] = 'd';
            return(PDM_S_SUCCESS);
            }
         else
           return(PDM_S_SUCCESS);  

        else
          {
          string[0] = 'r';
          return(PDM_S_SUCCESS);
          }

       else
           return(PDM_S_SUCCESS);  

     else
       {
        string[0] = 'i';
        return(PDM_S_SUCCESS);
       }

   else
       return(PDM_S_SUCCESS);  
   }
