
#define CS_S_SUCCESS 1
#define CS_E_NAME_NOT_FOUND 0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <exsysdep.h>
#include <exlanguage.h>
#include <igrtypedef.h>
#include <OMminimum.h>
#include <exdef.h>
#include <ex.h>
#include <expriv.h>


#include <exproto.h>

#define CS_PATH_MAX 256


#define CACHE_SIZE  15
#define posit(name) ((name [0] + name [strlen ( name ) - 1]) % CACHE_SIZE)
#define weigth(wt)  time ( &wt )

extern struct diacritic *EX_diacritic;
extern int EX_ndiacritic;

static char   CScache_name   [CACHE_SIZE] [CS_PATH_MAX];
static int    CScache_id     [CACHE_SIZE];
static int    CScache_weigth [CACHE_SIZE] = { 0 };


/*----------------------------------------------------------------------*/
/*                                                                      */
/*      compare - This function takes an abbreviated command string     */
/*                and a full command string as input, returns           */
/*                  NO_MATCH    if no match, or                         */
/*                  MATCH       if match, or                            */
/*                  EXACT_MATCH if exact match                          */
/*                    ( every word in command name matches the input )  */
/*                    ex: "p l" EXACT_MATCH "place line"                */
/*                  TOTAL_MATCH if every character matches              */
/*                    ex:  "co"  TOTAL_MATCH "co"                       */
/*                         "co"  EXACT_MATCH "color"                    */
/*----------------------------------------------------------------------*/

static IGRlong compare ( abb_ptr, full_ptr )

IGRchar *abb_ptr;
IGRchar *full_ptr;

{
    IGRchar     temp[260];
    IGRchar     *temp_ptr;
    IGRchar     *abb_ptr_sav;
    IGRchar     hit_the_end;
    IGRint      status;

    temp_ptr = temp;
    abb_ptr_sav = abb_ptr;
    *temp_ptr = 0;
    hit_the_end = FALSE;
    status = NO_MATCH;
    
    while ( *abb_ptr )
    {
        if ( *abb_ptr == BLANK )
        {
            while (( *full_ptr != BLANK ) && ( *full_ptr ))
            {
                ++full_ptr;
            }
        }
        ++abb_ptr;
        *temp_ptr++ = *full_ptr++;
    }

    if( ! *full_ptr )
    {
       status = TOTAL_MATCH;
    }

    while (( *full_ptr != BLANK ) && ( *full_ptr ))
    {
        ++full_ptr;
    }

    if (! *full_ptr )
    {
        hit_the_end = TRUE;
    }

    *temp_ptr = 0;

    if (! strcmp ( temp, abb_ptr_sav ))
    {
        if( status == TOTAL_MATCH )
        {
           return (TOTAL_MATCH);
        }
        else
        {
           return (( hit_the_end ) ? EXACT_MATCH : MATCH );
        }
    }
    else
    {
        return ( NO_MATCH );
    }

} /* compare */


CSclear_cache()
{
int i;
 
for (i = 0; i < CACHE_SIZE; i++)
 { 
  CScache_name[i][0] = 0;
  CScache_id[i] = 0;
  CScache_weigth[i] = 0;
 }
  return CS_S_SUCCESS;
}

CSadd_to_cache ( name, indx )
                 char  *name	/* The name to be added			IN  */;
                 int   indx	/* The index to be added		IN  */;
/*
   This function adds an entry to the cache.
   
   Return status: CS_S_SUCCESS: the name - index pair has been added
   =============
*/
{
  int index;
  long wt;

  weigth ( wt );
  if ((wt - CScache_weigth [index = posit ( name )]) > 3)
  {
    strcpy ( CScache_name [index], name );
    CScache_id [index] = indx;
    CScache_weigth [index] = wt;
  }

  return CS_S_SUCCESS;
}



CSget_from_cache ( name, p_indx )
                   char *name    /* The name to be found		IN  */;
                   int  *p_indx  /* The index we found			IN  */;
/*
   This function gets an entry from the cache.
   
   Return status: CS_S_SUCCESS:        the name has been found
   =============  CS_E_NAME_NOT_FOUND: the name is not in the cache
*/
{
  int index;

  if (!strcmp ( name, CScache_name [index = posit ( name )]))
  {
    *p_indx = CScache_id [index];
    return CS_S_SUCCESS;
  }
  else
    return CS_E_NAME_NOT_FOUND;
}


CSdump_cache ()
/*
   This function dumps the cache to stdout.
   
   Return status: CS_S_SUCESS: always
   =============
*/
{
  int i;
 
  for (i = 0; i < CACHE_SIZE; i++)
    if (CScache_name [i] [0])
      printf ( "%2d: '%s' - %d (%d)\n",
               i, CScache_name [i], CScache_id [i], CScache_weigth [i] );
    else
      printf ( "%2d: ---EMPTY SLOT---\n", i );
 
  return CS_S_SUCCESS;
}



/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME        EX_cmdsrch()
 
     Abstract:

       This function takes a command control table and a string as input,
       searches through the table for a match.

       The string may be the combination of the abbreviation of the command
       name and arguments, which means that the string should be used to
       match the longest command name, and the rest of the string are used
       as arguments. These arguments will be pushed to the event queue, so
       that the command object can get to them by calling GRgetevent or
       CS_WaitForInput.

               e.g. If "place line" and "place line string" are both in
                    the command table, the string "pl li st ar1 ar2" will
                    match the command "place line string" and generate
                    a keyin event "ar1 ar2" instead of matching the
                    command "place line" and generating the keyin event
                    "st ar1 ar2".

       If the shorter command is really needed, an '=' sign can be used
       to indicate the end of the command clearly.

               e.g. The string "pl li=st ar1 ar2" will match the command
                    "place line" and create the keyin event "st ar1 ar2".

       If a match is found, the input string will contain the expanded
       command name and the command structure will be returned.

       The function returns
               -1 if no match, or
               -2 if ambiguous, or
               -4   ignore,
               -5   bad keyin
               n, where n is the index to the command table and n >= 0.

-----
%SC%

        index = EX_cmdsrch ( msg, cmd_cntrl, keyin, cmd ,response);

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

   *cmd_cntrl   struct EX_cmd_cntrl     - command control table.

   *keyin       IGRchar                 - string.
      
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

   *msg         IGRlong                 - EXSUCC for success, or
                                          EXFAIL for failure.

   *keyin       IGRchar                 - expanded command name.

   *cmd         struct EX_cmd           - command structure found.

-----
%MD%

     MODULES INVOKED:
        EX_cmdstrip () - get rid of leading, trailing blanks, and multiple
                         blanks, and convert command portion to lower case.

-----
%NB%

     NOTES:
                    
-----
%CH%
     CHANGE HISTORY:
        
        czn  05/01/86  : Creation date.
        czn  05/05/86  : change to handle '=' sign.
        czn  07/17/86  : change to push the rest of the keyin into
                         the software event queue.
        ht   07/30/86  : add code to do total match
        ht   09/03/87  : add cmd_keky search for new command_table
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
----*/
/*EH*/

#define tolower(c) c >= 'A' && c <= 'Z' ? c + 0x20 : c

IGRlong EX_cmdsrch ( msg, cmd_cntrl, keyin, cmd, response )

IGRlong *msg;
struct EX_cmd_cntrl *cmd_cntrl;
IGRchar *keyin;
struct EX_cmd *cmd;
int *response;
{
    register unsigned char *temp_ptr, *lower_ptr;
    IGRlong     lo;
    IGRlong     hi;
    IGRlong     size,j;
    IGRlong     index;
    IGRlong     exact_index;
    IGRlong     total_index;
    IGRlong     result;
    int     done;
    IGRchar     temp[260];
    char        original_keyin[260];
    int    i;
    int    count;
    int    exact_count;
    int    total_count;
    int    start;
    int         where_equal_is;
    IGRlong     ret;
    int         resp;
    IGRlong     no_bytes;
    IGRlong     cmd_first;
    IGRlong     exact_first;
    IGRlong     total_first,found;
    char        local_command_name[CS_PATH_MAX], lower_char_name[CS_PATH_MAX],
                                                          *ptr_for_cache;
    *msg = EXFAIL;
    index = NO_MATCH;
    if( strlen(keyin) >= 255 ) return(NO_MATCH);
    strcpy(original_keyin,keyin);
    if ( ((*response != EX_CMD_KEY)) && ( !( EX_cmdstrip ((unsigned char *) keyin ))))
    {
        return ( IGNORE );
    }
    ptr_for_cache = strchr (keyin,'=');
    if (ptr_for_cache  )
    {
      *ptr_for_cache = '\0';
      if (!strlen(keyin))return(IGNORE);
      if (CSget_from_cache ( (char *) keyin, (int *) &index ) == CS_S_SUCCESS)
      {
         /* we push the rest of the command line on the stack	*/
         resp = STRING;
         ptr_for_cache++;
         no_bytes = strlen ( ptr_for_cache ) ;
         if ( no_bytes )
          {
           no_bytes++;
           EXputq_front ( &ret, &resp, &no_bytes, ptr_for_cache );
          }
         strncpy ( keyin, cmd_cntrl->cmd[index].command_name_ptr,
                                 cmd_cntrl->cmd[index].command_nbytes);
         keyin[cmd_cntrl->cmd[index].command_nbytes] = 0;
         *cmd = cmd_cntrl->cmd[index];
         *msg = EXSUCC;

         return index;
      }
    }
    else
      if (CSget_from_cache ( (char *) keyin, (int *) &index ) == CS_S_SUCCESS)
      {
         strncpy ( keyin, cmd_cntrl->cmd[index].command_name_ptr,
                         cmd_cntrl->cmd[index].command_nbytes);
         keyin[cmd_cntrl->cmd[index].command_nbytes] = 0;
         *cmd = cmd_cntrl->cmd[index];
         *msg = EXSUCC;

         return index;
      }
    if (ptr_for_cache)
      *ptr_for_cache = '=';
    if( strlen(keyin) >= CS_PATH_MAX ) return(NO_MATCH);


    /* find out where the equal sign is ( 0 means there is no '=' sign ) */

    where_equal_is = 0;
    i = 0;
    size = strlen ( keyin );
    while (( i < size ) && (! where_equal_is ))
    {
        if ( keyin[i] == '=' )
        {
            if ( i == size - 1 )
            {
                keyin[i] = 0;
            }
            where_equal_is = i;
        }
        ++i;
    }

    strcpy ( temp, keyin );
    size = ( where_equal_is ) ? where_equal_is : strlen ( keyin );
    temp[size] = 0;
    done = FALSE;
    index = NO_MATCH;

    while (((int) strlen ( temp ) >= where_equal_is ) &&
           ( strlen ( temp )) &&
           (! done ))
    {
        count = 0;
        exact_count = 0;
        total_count = 0;
        exact_index = NO_MATCH;
        total_index = NO_MATCH;
	cmd_first = 1;
	exact_first = 1;
	total_first = 1;

        lo = 0;
	hi = cmd_cntrl->no_of_cmd;

        for ( i = lo; i < hi; ++i )
        {
	    if( *response == EX_CMD_KEY )
	    {
        result = strcmp ( temp,
               cmd_cntrl->cmd[i].command_key) ? NO_MATCH : TOTAL_MATCH;
	    }
	    else
	    {

           strncpy(local_command_name, cmd_cntrl->cmd[i].command_name_ptr,
                                           cmd_cntrl->cmd[i].command_nbytes);
           local_command_name[cmd_cntrl->cmd[i].command_nbytes] = 0;
	       temp_ptr = (unsigned char *) local_command_name;
           lower_ptr = (unsigned char *) lower_char_name;
	       while ( *temp_ptr != 0 )
	       {
           if (( *temp_ptr <= 0x7f ) || (!EX_ndiacritic))
             {
             *lower_ptr = tolower ( *temp_ptr );
		     ++temp_ptr;
             ++lower_ptr;
             }
           else
             {
             found = 0;
             /*foreign language translate*/
             for ( j = 0 ; j < EX_ndiacritic ; j++ )
              {
              if ( *temp_ptr == EX_diacritic[j].diacritic )
               {
               strncpy ( (char *)lower_ptr , EX_diacritic[j].lower_char,
                                         EX_diacritic[j].nbytes );
               lower_ptr = lower_ptr + EX_diacritic[j].nbytes;
               ++temp_ptr;
               j = EX_ndiacritic;
               found = 1;
               }/*end if ==*/
             }/*end for*/
             if ( !found )
             {
              *lower_ptr =  *temp_ptr ;
	    	  ++temp_ptr;
              ++lower_ptr;
             }
	        }/*end else foreign char*/
           }/*end while*/
           *lower_ptr = 0;

           result = compare ( temp,  lower_char_name);
	    }

            switch ( result )
            {
                case TOTAL_MATCH:
		     if( total_first )
		     {
			 index = i;
			 exact_index = i;
			 total_index = i;
			 total_first = 0;
		     }
		     ++total_count;
		     ++exact_count;
		     ++count;
                     /* let's get out of here	*/
                     i = hi;
		     break;

                case EXACT_MATCH:
		     if( exact_first )
		     {
			 index = i;
			 exact_index = i;
			 exact_first = 0;
		     }
		     ++exact_count;
		     ++count;
		     break;

                case MATCH:
                     if( cmd_first )
		     {
		        index = i;
			cmd_first = 0;
		     }
                     ++count;
                     break;

                default:
                    break;
            }
        }

        switch ( count )
        {
            case 0:
                done = TRUE;
                break;

            case 1:
                done = TRUE;
                break;

            default:
                done = TRUE;

                if( total_count != 0 )
		{
		   index = total_index;
		}
		else if( exact_count != 0 )
		{
		   index = exact_index;
		}
                break;
        } /* switch */
    } /* while */

    if (( index != NO_MATCH ) && ( index != AMBIGUOUS ) )
    {
        start = strlen ( temp ) + 1;
        if ( (start < (int)strlen (&keyin[0]) + 1 ) && (where_equal_is > 0) )
        {
            resp = STRING;
            no_bytes = strlen ( &keyin[start] ) + 1;
            result = EXputq_front ( &ret, &resp, &no_bytes, &keyin[start]);
        }
        if (ptr_for_cache)
          *ptr_for_cache = '\0';

        CSadd_to_cache ( (char *) keyin, (int) index );
        strncpy ( keyin, cmd_cntrl->cmd[index].command_name_ptr,
                                  cmd_cntrl->cmd[index].command_nbytes);
        keyin[cmd_cntrl->cmd[index].command_nbytes] = 0;

        *cmd = cmd_cntrl->cmd[index];
        *msg = EXSUCC;
    }
   else
    {
      strcpy(keyin,original_keyin);
    }
    return ( index );
} /* EX_cmdsrch */      

