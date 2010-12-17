#include        <ctype.h>
#include        <stdio.h>
#include	<PDUerror.h>
#include	<PDUcommand.h>
#include	<PDUfile_def.h>
#include	<PDUstr.h>
#include	<string.h>
#include        <tools.h>
#include        <MEMerrordef.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

extern int PDU_command;
extern int PDM_debug_on;
int PDUvalid_alt_tag( string, arg, msg )
   char 			*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				length;
   int                          str_length;
   int                          char_index;

  _pdm_debug("In PDUvalid_alt_tag", 0);
  _pdm_debug("string = <%s>", string);

  str_length = strlen(string);
  _pdm_debug("length of string = %d",(char *)str_length);

  _pdm_debug("arg = <%s>", arg);
     
   sscanf(arg,"%d",&length);
   _pdm_debug("Length = %d", (char *)length);
   
   if ( strlen(string) > (length) )
     {
     _pdm_debug("String is too LONG",0);     	
     sprintf( msg, "Value has more than %d characters", length);
     status = PDM_E_INVALID_INPUT;
     }   
 
   /* check input for invalid values */ 
   for ( char_index = 0; char_index < str_length; ++char_index )  
     {
 
       if ( string[char_index] == ':' )
         {
          strcpy(msg,"':' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
          break;
         } 

       if ( string[char_index] == '*' )
         {
          strcpy(msg,"'*' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
          break;
         } 
     } 

   /* check uniqueness of alt tag no in part directory structure */
   if (status == PDM_S_SUCCESS)
      {
   	status = PDUvalidate_alt_tag(string);

   	if (status == PDM_E_DUP_ALTTAGNO)
    	{
          _pdm_debug("alt tag no already exists!",0);
          sprintf(msg,"Alt tag number %s already exists !",string);
          status = PDM_E_INVALID_INPUT;
        }

       if (status != PDM_S_SUCCESS)
          _pdm_debug("can not validate alt tag no",0);
      }

   return(status);
   }
  
int PDUvalid_alt_tag_edt_part( string, argument, msg )
   char 			*string;
   char				*argument;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				length;
   int                          osnum;
   int                          char_index;
   char                         *s;
   char                         *arg = NULL;
   char                         *strosnum = NULL;
   char                         *tmparg = NULL;

  _pdm_debug("In PDUvalid_alt_tag_edt_part",0);

  _pdm_debug("on PDUvalid_alt_tag_edt_part entry, argument = <%s>",argument);
  PDUfill_in_string(&tmparg,argument);

  /* extract first argument (osnum) */
  s = strtok(tmparg,":");
  PDUfill_in_string(&strosnum,s);
  _pdm_debug("strosnum = <%s>",strosnum);

  /* convert strosnum to integer */
  sscanf(strosnum,"%d",&osnum);
  _pdm_debug("converted osnum = %d",(char *)osnum);

  /* extract 2nd argument (arg) */
  s = strtok(0,":");
  PDUfill_in_string(&arg,s);
  _pdm_debug("arg = <%s>",arg); 

  _pdm_debug("string = <%s>", string);

  _pdm_debug("Validating a character string", 0);

   sscanf(arg,"%d",&length);
   _pdm_debug("Length = %d", (char *)length);
   
   if ( strlen(string) > (length) )
     {
     _pdm_debug("String is too LONG",0);     	
     sprintf( msg, "Value has more than %d characters", length);
     status = PDM_E_INVALID_INPUT;
     
     }   

   /* check input for invalid values */ 
   for ( char_index = 0; ((char_index < strlen(string)) && 
        (status == PDM_S_SUCCESS)); ++char_index )
     {
       if ( string[char_index] == ' ' )
         {
          strcpy(msg,"Blank Characters are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
 
       if ( string[char_index] == NULL )
         {
          strcpy(msg,"Must Enter Value");
          status = PDM_E_INVALID_INPUT;
         } 
 
       if ( string[char_index] == ':' )
         {
          strcpy(msg,"':' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if ( string[char_index] == '*' )
         {
          strcpy(msg,"'*' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if (char_index == 1)
         {
           if (string[char_index] == '_')
             {
               strcpy(msg,"'_' is not valid for second character");
               status = PDM_E_INVALID_INPUT;
 	     }
         }
     } 

   /* check uniqueness of alt tag no in part directory structure */
   status = PDUcheck_uniqueness(string,osnum);

   if (status == PDM_E_DUP_ALTTAGNO)
    {
     _pdm_debug("alt tag no already exists!",0);
     sprintf(msg,"Alt tag number %s already exists !",string);
     status = PDM_E_INVALID_INPUT;
    }

   if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("can not validate alt tag no",0);
     return(status);
    }
   return(status);
     
   }


int PDUvalid_part_type( string, arg, msg )
   char 			*string;
   char 			*arg;
   char 			*msg;
   {
   int				status = PDM_S_SUCCESS;

  _pdm_debug("Validating a part type", 0);
  _pdm_debug("string = <%s>", string);

   /* check if part type field is empty */
   if ( (strcmp(string,"") == 0) || (string == NULL) )
      {
       _pdm_debug("part type is empty",0);
       status = PDM_E_INVALID_INPUT;
      }

   /* check if part type keyed in is valid */
   if ((strcmp(string,"D") != 0) &&
       (strcmp(string,"d") != 0) &&
       (strcmp(string,"M") != 0) &&
       (strcmp(string,"m") != 0) &&
       (strcmp(string,"G") != 0) &&
       (strcmp(string,"g") != 0) &&
       (strcmp(string,"N") != 0) &&
       (strcmp(string,"n") != 0))
      {
       _pdm_debug("invalid part type encountered",0);     	
       _pdm_debug("part type entered = <%s>",string);
       status = PDM_E_INVALID_PART_TYPE;
      }
      
   return(status);
     
   }
  
  
int PDUvalid_date( string, arg, msg )
   char 			*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				length;
   int				index = 0;
   int				month;
   int				day;
   char				*temp = NULL;
   char				*month_ptr = NULL, *day_ptr = NULL;
   char				*getenv();
   char				*dateformat;
   int				european = FALSE;
   
  _pdm_debug("Validating date", 0);
   
   length = strlen(string);

   dateformat = getenv("PDMDATE");

   _pdm_debug("pdm date format = <%s>", dateformat);

   if ((strcmp(dateformat,"dd/mm/yy") == 0) || 
       (strcmp(dateformat,"DD/MM/YY") == 0) ||
       (strcmp(dateformat,"dd/mm/yyyy") == 0) ||
       (strcmp(dateformat,"DD/MM/YYYY") == 0))
     european = TRUE;
   
   /* check month in string */
   if ( isdigit(string[index]))
     {
      ++index ;

      if (((isdigit(string[index])) && (string[(index + 1)] == '/')) ||
          (string[index] == '/'))
        {              
        PDUfill_in_string(&temp, string);

        month_ptr = strtok(temp,"/");
        
        sscanf(month_ptr,"%d",&month);

        temp = NULL;
        
        if(string[index] == '/')
          ++index;
        else
          index += 2;
         
        if (((european) && (month <= 31)) ||
            (!(european) && (month <= 12)))
          {
           if (isdigit(string[index]))
             {
              ++index;

              if(((isdigit(string[index])) && (string[(index + 1)] == '/')) ||
                 (string[index] == '/'))
                {
                PDUfill_in_string(&temp, string);

                day_ptr = strtok(temp,"/");
                day_ptr = strtok(0,"/");
                
                sscanf(day_ptr,"%d",&day);
                
                if(string[index] == '/')
                   ++index;
                else
                   index += 2;
                
                if(((european) && (day <=12)) ||
                   (!(european) && (day <= 31)))
                  {
                  while((index < length) && (status == PDM_S_SUCCESS))
                    {
                    if(!isdigit(string[index++]))
                      {
                      sprintf(msg,"Invalid character %c",
                                   string[index-1]);
                      status = PDM_E_INVALID_INPUT;
                      }
                    }
                  }
                else
                  {
                   if (european)
                     sprintf(msg,"%d is invalid value for the month",day);
                   else
                     sprintf(msg,"%d is invalid value for the day",day);
                  status = PDM_E_INVALID_INPUT;
                  }
                }
              else
                {
                sprintf(msg,"Found %c where it expected /",string[index]);
                status = PDM_E_INVALID_INPUT;
                }
             }          	
           else
             {
             sprintf(msg,"Invalid character %c", string);
             status = PDM_E_INVALID_INPUT;
             }
          }
        else
          {
           if (european)
             sprintf(msg,"%d is invalid for day", month);
           else
             sprintf(msg,"%d is invalid for month", month);

          status = PDM_E_INVALID_INPUT;
          }
       }
     else
       {
       sprintf(msg,"Found %c where expected /",string[index]);
       status = PDM_E_INVALID_INPUT;
       }
     }
   else
     {
     sprintf(msg,"Incorrect character %c in date",string[index]);
     status = PDM_E_INVALID_INPUT;
     }

   return(status);
     
   }


int PDUvalid_dynamic_attr( string, arg, msg )
   char				*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				char_index;
      
   _pdm_debug("Validating a dynamic attribute name or value", 0);
   _pdm_debug("string = <%s>", string);

   /* make sure string not empty */
   if (strcmp(string,"")==0)
     {
       strcpy(msg,"Must Enter Valid Attribute Name/Value");
       status = PDM_E_INVALID_INPUT;
     }

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

   for ( char_index = 0; ((char_index < strlen(string)) && 
        (status == PDM_S_SUCCESS)); ++char_index )
     {
       if ( string[char_index] == ' ' )
         {
          strcpy(msg,"Blank Characters are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
 
       if ( string[char_index] == ':' )
         {
          strcpy(msg,"':' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if ( string[char_index] == '*' )
         {
          strcpy(msg,"'*' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if ( string[char_index] == '!' )
         {
          strcpy(msg,"'!' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if (char_index == 1)
         {
           if (string[char_index] == '_')
             {
               strcpy(msg,"'_' is not valid for second character");
               status = PDM_E_INVALID_INPUT;
 	     }
         }
     } 
   return(status);
   }

int PDUvalid_Y_N_attr( string, arg, msg )
   char				*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   /*int			char_index;		APOGEE */
   int                          length;
      
   _pdm_debug("In the function PDUvalid_Y_N_attr",0);
   _pdm_debug("Validating a directory y/n attribute", 0);
   _pdm_debug("string = <%s>", string);

   /* check if string is empty */
   if (strcmp(string,"")==0)
       {
         strcpy(msg,"Enter (Y/N)");
         status = PDM_E_INVALID_INPUT;
       }

   sscanf(arg,"%d",&length);

   if ( strlen(string) > length )
     {
        sprintf(msg,"Input is longer than %d characters", length);
        return(PDM_E_INVALID_INPUT);
     }

     /* string must be (y/n or Y/N) */
     if ((strcmp(string,"Y")!=0) &&
         (strcmp(string,"y")!=0) &&
         (strcmp(string,"N")!=0) &&
         (strcmp(string,"n")!=0))
        {
         strcpy(msg,"Enter (Y/N)");
         status = PDM_E_INVALID_INPUT;
        }

   return(status);
   }

int PDUvalid_dynamic_value( string, arg, msg )
   char				*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				char_index;
   int                          length;
      
   _pdm_debug("In the function PDUvalid_dynamic_value",0);
   _pdm_debug("Validating a dynamic attribute value", 0);
   _pdm_debug("string = <%s>", string);

   /* check if string is empty */
   if (strcmp(string,"")==0)
      {
       strcpy(msg,"Must Enter Dynamic Attribute Value");
       status = PDM_E_INVALID_INPUT;
      }

   sscanf(arg,"%d",&length);

   if ( strlen(string) > length )
     {
        sprintf(msg,"Input is longer than %d characters", length);
        return(PDM_E_INVALID_INPUT);
     }

   /* check for invalid special characters */
   for ( char_index = 0; ((char_index < strlen(string)) && 
        (status == PDM_S_SUCCESS)); ++char_index )
     {
       if ( string[char_index] == ' ' )
         {
          strcpy(msg,"Blank Characters are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
 
       if ( string[char_index] == NULL )
         {
          strcpy(msg,"Must Enter Value");
          status = PDM_E_INVALID_INPUT;
         } 
 
       if ( string[char_index] == ':' )
         {
          strcpy(msg,"':' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if ( string[char_index] == '*' )
         {
          strcpy(msg,"'*' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 
     } 

   return(status);
   }

int PDUvalid_synonym( string, arg, msg )
   char 			*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   /*int			length;			APOGEE */

  _pdm_debug("Validating a synonym", 0);
  _pdm_debug("synonym = <%s>", string);
   
   if ( strlen(string) > PDU_NFM_SYN_LEN )
     {
     status = PDM_E_INVALID_INPUT;
     }   
   return(status);
     
   }

int PDUvalid_level( string, arg, msg )
  char 		*string;
  char		*arg;
  char		*msg;
  {
  int		status = PDM_S_SUCCESS;
  int		level, prev_level;

  _pdm_debug("Validating the level number %s", string);

  if ( arg == NULL )
    {
    _pdm_debug("arg is NULL",0);
    }
  else
    {
     _pdm_debug("arg = <%s>", arg);
    }
     
  status = PDUvalid_number ( string, "I", msg);
  _pdm_status ("valid number",status);
  
  if ( status == PDM_S_SUCCESS )
    {  
     sscanf(string,"%d", &level);
     
     if ( level > 0 )
       {
       	if (arg == NULL)
       	  {
       	  if ( level == 1 )
       	    return( PDM_S_SUCCESS );
       	  else
       	    {
       	    strcpy(msg,"Must begin with level 1");
       	    return(PDM_E_INVALID_INPUT);
       	    }
       	  }
       	else
          sscanf(arg,"%d", &prev_level);       	
        
        if (( level != prev_level ) && (level != (prev_level + 1)))
          {
          if ( level > prev_level )
            {
             sprintf(msg,"%s is more than 1 greater than previous");
             status = PDM_E_INVALID_INPUT;
            }
          }
       }
     else
       {
       strcpy(msg,"Level must be greater than zero");
       status = PDM_E_INVALID_INPUT;
       }
       
    }

  return(status);
  }
  
int PDUvalidate_dyn_attr_uniqueness( string, arg, msg )
   char				*string;
   char				*arg;
   char				*msg;
   {
   int				status = PDM_S_SUCCESS;
   int				char_index,i;
   char                         **data;
   MEMptr                       dyn_attr_list;
      
   _pdm_debug("Validating a dynamic attribute name or value", 0);
   _pdm_debug("Also, validating the uniqueness of dyn attr copied",0);
   _pdm_debug("string = <%s>", string);
   _pdm_debug("arg = <%s>",arg);

   /* make sure string not empty */
   if (strcmp(string,"")==0)
     {
       strcpy(msg,"Must Enter Valid Attribute Name/Value");
       status = PDM_E_INVALID_INPUT;
     }

   if ( strlen(string) > PDU_NFM_ATTR_LEN )
     {
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

   for ( char_index = 0; ((char_index < strlen(string)) && 
        (status == PDM_S_SUCCESS)); ++char_index )
     {
       if ( string[char_index] == ' ' )
         {
          strcpy(msg,"Blank Characters are Invalid");
          status = PDM_E_INVALID_INPUT;
         } 
 
       if ( string[char_index] == ':' )
         {
          strcpy(msg,"':' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if ( string[char_index] == '*' )
         {
          strcpy(msg,"'*' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if ( string[char_index] == '!' )
         {
          strcpy(msg,"'!' Is Invalid Input");
          status = PDM_E_INVALID_INPUT;
         } 

       if (char_index == 1)
         {
           if (string[char_index] == '_')
             {
               strcpy(msg,"'_' is not valid for second character");
               status = PDM_E_INVALID_INPUT;
 	     }
         }
     } /* end for loop */
    
     /* check uniqueness of keyed in dynamic attribute */
     if (arg)
     {
     dyn_attr_list = (MEMptr) arg;
     if (PDM_debug_on)
       MEMprint_buffer("source catalog dyn attr at validation",
                      dyn_attr_list,PDU_DEBUG_FILE);

     data = (char **) dyn_attr_list->data_ptr;

     for (i = 1; i < dyn_attr_list->rows; ++i)
         {
          if (strcmp(string,data[(dyn_attr_list->columns * i)+0]) == 0)
             {
              strcpy(msg,"Dynamic attribute already exists");
              status = PDM_E_INVALID_INPUT;
             } 
    }
    }
   return(status);
   }

int PDUvalid_case ( string, arg, msg )
  char 		*string;	/* character to validate */
  char		*arg;		/* type of character to validate */
  char		*msg;		/* error message string */

/******************************************************************************

Doc:	PDUvalid_case

Abstract:
	Validates characters as upper or lowercase.
	
Algorithm:
		1.	If the string length of the entry is zero, return error message.
		2.	Check the first character to see if it is upper or
lowercase.  If it is uppercase, check the remaining letters.  If you find a lowercase letter, display and error message.  Use reverse logic for a case in which
the first character is lowercase.

Return Status: PDM_S_SUCCESS

History:       Mychelle Joiner    March 1, 1991

*****************************************************************************/

  {
  int		status = PDM_S_SUCCESS; /* PDM status */
  int		string_len, char_index;
  int           length; 

  _pdm_debug("Validating the application attribute", 0);
  _pdm_debug("string = <%s>", string);

  _pdm_debug("arg = <%s>", arg);
     
   sscanf(arg,"%d",&length);
   _pdm_debug("Length = %d", (char *)length);
   
   if ( strlen(string) > (length) )
     {
     _pdm_debug("String is too LONG",0);     	
     sprintf( msg, "Value has more than %d characters", (char *)length);
     status = PDM_E_INVALID_INPUT;
     
     }   
  string_len = strlen(string);
  
  
  if ( strcmp(string, "") == 0 )
    {

    strcpy(msg, "This Attribute Must Have a Value");
    status = PDM_E_INVALID_INPUT;
    }
    
     _pdm_debug("Examining Character ", 0);
     
     if ( islower ( string[0] ))
       {
       for ( char_index = 1;((char_index < string_len) && 
           (status == PDM_S_SUCCESS)); ++char_index )
       if ( ! (islower ( string[char_index] )))
         {
         strcpy(msg, 
               "Must Be All Upper or All Lowercase");
         status = PDM_E_INVALID_INPUT;
         }
       }
     else
       {
       for ( char_index = 1;((char_index < string_len) && 
           (status == PDM_S_SUCCESS)); ++char_index )
       if ( islower ( string[char_index] ))
         {
         strcpy(msg, 
               "Must Be All Upper or All Lowercase");
         status = PDM_E_INVALID_INPUT;
         }
       }

   return (status);
}

PDUcheck_for_blanks(string)
char  string[132];

/******************************************************************************

Doc:	PDUcheck_for_blanks

Abstract:
	Checks a text string to see if it contains all blank spaces.
	
Algorithm:
		1.	Check the first character to see if it is a blank.
                        If it is, check the remaining characters for blanks.

                2.      If the function contains all blanks, return 1.
                        Otherwise, return 0.

Return Status: 0 or 1

History:       Mychelle Joiner    April 3, 1991

*****************************************************************************/

{
  int    i;    /* counter for loop */
  int    length;  /* length of the string */

  _pdm_debug("Entering PDUcheck_for_blanks", 0);

  length = strlen(string);

  _pdm_debug("Entering loop to check for blanks", 0);

  for (i = 0; i < length; ++i)
    {
    if (string[i] != ' ')
      {
       _pdm_debug("Encountered a nonblank character", 0);
       return(0);
      }
    }
  return(1);

}

 /*****************************************************************************
   Document:  PDUpart_id

   Algorithm:
   This function receives a character string and
      1)  Makes sure the string is not NULL, and
      2)  Makes sure the user has specified a catalog.

   Return Status:  PDM_E_PART_FIELD_BLANK   No part was specified
                   PDM_E_REV_FIELD_BLANK    No revision was specified
                   PDM_E_CAT_FIELD_BLANK    No catalog was specified
                   PDM_E_REV_DOES_NOT_EXIST Part and revsion do not exist

                   PDM_S_SUCCESS

   History:  April 23, 1991    Mychelle Joiner    Created
 *****************************************************************************/


 int PDUpart_id(catalog, partid, revision)
    char                         *catalog;
    char                         *partid;
    char                         *revision;
    {
    int                          status = PDM_S_SUCCESS;
    int                          string_len;

    _pdm_debug("Validating a part id", 0);
    _pdm_debug("partid = <%s>", partid);

    string_len = strlen(partid);

    if ( string_len == 0 )
      {
      _pdm_debug("Partid is NULL", 0);
      return(PDM_E_PART_FIELD_BLANK);
      }

    string_len = strlen(revision);

    if ( string_len == 0 )
      {
      _pdm_debug("Revision is NULL", 0);
      return(PDM_E_REV_FIELD_BLANK);
      }

    status = PDMrverify_part(catalog, partid, revision);

    if ( status != PDM_S_SUCCESS )
      {
      _pdm_debug("Revision <%s> does not exist", revision);
      _pdm_debug("for part <%s> ", partid);
      return(PDM_E_REV_DOES_NOT_EXIST);
      }
    return(PDM_S_SUCCESS);
    }

 /*****************************************************************************
   Document:  file_id

   Algorithm:
   This function receives a character string and
      1)  Makes sure the string is not NULL,
      2)  Makes sure the string is not too long.

   Return Status:  PDM_E_FILENAME_BLANK      No data in filename field
                   PDM_E_FILENAME_TOO_LONG   Too many characters in filename
                   PDM_S_SUCCESS

   History:  April 23, 1991      Mychelle Joiner    Created
 ******************************************************************************/


 int PDUfile_id(filename)
    char                       *filename;
    {
    /*int                        status = PDM_S_SUCCESS; APOGEE */
    int                          string_len;

   _pdm_debug("Validating a character string", 0);
   _pdm_debug("filename = <%s>", filename);


   string_len = strlen(filename);

   if ( string_len == 0 )
     {
     _pdm_debug("Filename is NULL", 0);
     return(PDM_E_FILENAME_BLANK);
     }

   if ( strlen(filename) > 14 )
     {
     _pdm_debug("String is too LONG",0);
     return(PDM_E_FILENAME_TOO_LONG);
     }
   return(PDM_S_SUCCESS);
   }

 int PDUvalidate_function(filename)
    char                       *filename;
    {
    int                          string_len;

   _pdm_debug("filename = <%s>", filename);

   string_len = strlen(filename);

   if ( string_len == 0 )
     {
     _pdm_debug("Filename is NULL", 0);
     return(PDM_E_FILENAME_BLANK);
     }

   if ( strlen(filename) > 14 )
     {
     _pdm_debug("String is too LONG",0);
     return(PDM_E_FILENAME_TOO_LONG);
     }
   else if (filename[(string_len -2)] != '.')
     {
     _pdm_debug("filename is not in format xxx.u or xxxx.e", 0);
     return(PDM_E_INVALID_INPUT);
     }
   else if ((filename[(string_len -1)] == 'e') || 
            (filename[(string_len -1)] == 'u'))
     {
     return(PDM_S_SUCCESS);
     }
    
   return(PDM_E_INVALID_INPUT);
   }

int PDUvalid_decimal( string, arg, msg )
  char 		*string;	/* number to validate */
  char		*arg;		/* type of number to validate */
  char		*msg;		/* error message string */

/*****************************************************************************/
/*                                                                           */
/*  Document: PDUvalid_decimal                                               */
/*  Purpose : This function validates decimals                               */
/*  Author  : Jenny Brewer                                                   */
/*  Input   :                                                                */
/*            char *string    number to validate                             */
/*            char *arg       type of number to validate                     */
/*            char *msg       error message string                           */
/*                                                                           */
/*  Range   : Maximum precision is 15.                                       */
/*                                                                           */
/*****************************************************************************/
  {

  int status;
  int DIGIT_FOUND = FALSE;
  int index, length;
 
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
    return(status);
   }

int PDUvalidate_synonym_is_unique(synonym, buffer)

  char *synonym;
  MEMptr buffer;

  {
  int status;
  int i;
  int FOUND = FALSE;
  char **buffer_data = NULL;

  _pdm_debug("PDUvalidate_synonym_is_unique", 0);

  status = MEMbuild_array(buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  buffer_data = (char **)buffer->data_ptr;

  /* validate synonyms */
  for (i = 0; i < buffer->rows; i++)
   if (PDU_command != PDC_M_MODIFY_CATALOG)
     {
     if (strcmp(synonym, buffer_data[(buffer->columns * i) + PDU_NFM_SYN_COL]) 
          == 0)
       {
       FOUND = TRUE;
       break;
       }
      }
   else if (strcmp(buffer_data[(buffer->columns * i ) + PDU_NFM_SYN_COL + 
            PDU_NFM_MOD_OFFSET], "") == 0)
     {
     _pdm_debug("attribute added during Change Catalog", 0);
     if (strcmp(synonym, buffer_data[(buffer->columns * i) + PDU_NFM_SYN_COL]) 
          == 0)
       {
       FOUND = TRUE;
       break;
       }
      }
    else
     {
     if (strcmp(synonym, buffer_data[(buffer->columns * i) + PDU_NFM_SYN_COL +
         PDU_NFM_MOD_OFFSET]) == 0)
       {
       FOUND = TRUE;
       break;
       }
      }

  if (FOUND)
    return(PDM_E_INVALID_INPUT);

  /* validate synonym is not an attribute name */
  for (i = 0; i < buffer->rows; i++)
    if (strcmp(synonym, buffer_data[(buffer->columns * i) + PDU_NFM_ATTR_COL]) 
          == 0)
       {
       FOUND = TRUE;
       break;
       }

   if (FOUND)
     status = PDM_E_INVALID_INPUT;
   else
     status = PDM_S_SUCCESS;

  return(status);
  }
        
