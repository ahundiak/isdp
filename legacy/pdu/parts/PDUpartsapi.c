#include "stdio.h"
#include "PDUerror.h"
#include "PDUproto.h"

int PDUcheck_char(filename,spec_char)

char  * filename;
char  * spec_char;

{
   int       status = PDM_S_SUCCESS;
  int             string_len;
  int             char_index;

            string_len = strlen(filename);

            for (char_index = 0; char_index < string_len; ++char_index)
                {
                _pdm_debug("Examining character <%c>", ((char *)filename[char_index]));
                if (filename[char_index] == '/')
                   {
                   *spec_char = '/';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '#')
                   {
                   *spec_char = '#';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ' ')
                   {
                   *spec_char = ' ';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '=')
                   {
                   *spec_char = '=';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '!')
                   {
                   *spec_char = '!';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '*')
                   {
                   *spec_char = '*';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '\\')
                   {
                   *spec_char = '\\';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '(')
                   {
                   *spec_char = '(';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ')')
                   {
                   *spec_char = ')';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '{')
                   {
                   *spec_char = '{';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '}')
                   {
                   *spec_char = '}';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '[')
                   {
                   *spec_char = '[';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ']')
                   {
                   *spec_char = ']';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '<')
                   {
                   *spec_char = '<';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '>')
                   {
                   *spec_char = '>';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '&')
                   {
                   *spec_char = '&';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '?')
                   {
                   *spec_char = '?';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '$')
                   {
                   *spec_char = '$';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '@')
                   {
                   *spec_char = '@';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '+')
                   {
                   *spec_char = '+';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '-')
                   {
                   *spec_char = '-';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ':')
                   {
                   *spec_char = ':';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '|')
                   {
                   *spec_char = '|';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else
                   status = PDM_S_SUCCESS;
                }
return(status);
}
