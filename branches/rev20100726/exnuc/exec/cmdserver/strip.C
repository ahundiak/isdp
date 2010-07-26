/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME        EX_cmdstrip
 
     Abstract:  This function has the following effects:
                        - Leading and trailing blanks are striped.
                        - Multiple blanks are combined into one (the
                          first '=' sign is considered to be a blank).
                        - All character up to the first '=' sign or the
                          end of the string is converted to lower case.
                        - Size of the resulting string is returned.
                          If the string contains all blanks, 0 will be
                          returned.
-----
%SC%
        status = EX_cmdstrip ( keyin );

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

      *keyin     IGRchar                - input string

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

     *msg       IGRlong         - return code.
     *keyin     IGRchar         - expanded string

	ht   12/01/87  : change command_name to lower case( pete's request)

----*/

#include <igrtypedef.h>
#include <exdef.h>
#include <expriv.h>
#include <exlanguage.h>
#include <string.h>
#include <ctype.h>

extern struct diacritic *EX_diacritic;
extern int EX_ndiacritic;

IGRint EX_cmdstrip ( keyin )

unsigned char *keyin;

{
    unsigned char          temp[1024];
    unsigned char          *temp_ptr;
    unsigned char          *keyin_ptr;
    IGRchar       blank, first_equal;
    unsigned char          *lower_ptr;
    unsigned char          lower_char[1024];
    int           i;
    int           found;

    /* combine multiple blanks into one */
    lower_ptr = lower_char;
    keyin_ptr = keyin;
    temp_ptr = temp;
    *temp_ptr = NULL;
    *lower_ptr = NULL;
    blank = TRUE;
    first_equal = TRUE;
    while ( *keyin_ptr )
    {
        if ( *keyin_ptr == BLANK )
        {
            if (! blank )
            {
                *temp_ptr++ = *keyin_ptr++;
                blank = TRUE;
            }
            else
            {
                keyin_ptr++;
            }
        }
        else if (( *keyin_ptr == '=' ) && ( first_equal ))
        {
            if ( temp_ptr != temp )
            {
                if ( *(temp_ptr-1) == BLANK )
                {
                    *(temp_ptr-1) = *keyin_ptr++;
                }
                else
                {
                    *temp_ptr++ = *keyin_ptr++;
                }
            }
            else
            {
                *temp_ptr++ = *keyin_ptr++;
            }
            blank = TRUE;
            first_equal = FALSE;
        }
        else
        {
            *temp_ptr++ = *keyin_ptr++;
            blank = FALSE;
        }
    }

    if ( temp_ptr != temp )
    {
        if ( *(temp_ptr - 1 ) == BLANK )
        {
            *(temp_ptr - 1 ) = NULL;
        }
        else
        {
            *temp_ptr = NULL;
        }
    }

    /* convert characters up to the first '=' sign or end of string
       to lower case. */

    temp_ptr = temp;
    while (( *temp_ptr != '=' ) && ( *temp_ptr != NULL ))
    {
      if (( (unsigned char) *temp_ptr <= 0x7f ) || ( !EX_ndiacritic ))
       {
        *lower_ptr = tolower ( *temp_ptr );
        ++temp_ptr;
        ++lower_ptr;
       }
      else
       {
         /*foreign language translate*/
         found = 0;
         for ( i = 0 ; i < EX_ndiacritic ; i++ )
              {
              if ( *temp_ptr == (unsigned char)EX_diacritic[i].diacritic )
               {

               strncpy ( (char *)lower_ptr , (char *)EX_diacritic[i].lower_char,
                                         EX_diacritic[i].nbytes );
               lower_ptr = lower_ptr + EX_diacritic[i].nbytes;
               ++temp_ptr;
               i = EX_ndiacritic;
               found = 1;
               }/*end if ==*/
              }/*end for*/
            if (!found)
             {
             *lower_ptr = tolower ( *temp_ptr );
		     ++temp_ptr;
             ++lower_ptr;
             }
        }/*end else foreign char*/
    }
    if ( *temp_ptr == '=' )
     {
     while ( *temp_ptr != NULL )
       {
        *lower_ptr =  *temp_ptr ;/*transfer rest of string*/
        ++temp_ptr;
        ++lower_ptr;
       }
     }       
    *lower_ptr = 0; /*null last byte*/
    strcpy ( (char *)keyin, (char *)lower_char );
    return ( strlen ( (char *)keyin ));
} /* EX_cmdstrip */
