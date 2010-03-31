#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"


/*
  DESCRIPTION

  The following function can be used to obtain a double value from the
  user. If NULL is specified for 'prompt' then prompt field remains untouched.
  If NULL is specified for 'status then status field remains untouched. If
  FALSE is specified for 'default_acceptabl', then default (move-on) is not
  acceptable. If default is acceptable and default is specified by user
  then 'default_value' is returned as this function's value.
*/

double EMgetdouble
(
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  double default_value 
)
{
  IGRboolean got_input=FALSE, got_default;
  IGRint response;
  IGRlong msg_loc;
  IGRdouble response_data[128], val=0.0;
  struct GRevent event;

  do 
  {
    if (status)
      UI_status (status);

    if (prompt)
      UI_prompt (prompt);

    got_default = FALSE;
    co$getevent (msg = &msg_loc, event_mask = 
     GRm_VALUE | GRm_RJT_MOVEON, response = &response,
     response_data = response_data, event = &event);

    if (prompt)
      UI_prompt ("");
   
    if (msg_loc == GRw_no_value || event.response == EX_RJT_MOVEON)
      got_default = TRUE;

    if (default_acceptable && got_default)
    {
      val = default_value;
      got_input = TRUE;
    }
    else if (event.response == EX_VALUE)
    {
      val = event.event.value;
      got_input = TRUE;
    }
    else 
    {
      UI_status ("No way out of here, except via good input");
      sleep (1);      
    }
  }
  while (!got_input);

  return (val);
}


/*
  DESCRIPTION

  The following function can be used to obtain an integer value from the
  user. If NULL is specified for 'prompt' then prompt field remains untouched.
  If NULL is specified for 'status then status field remains untouched. If
  FALSE is specified for 'default_acceptable', then default (move-on) is not
  acceptable. If default is acceptable and default is specified by user
  then 'default_value' is returned as this function's value.
*/

int EMgetint
(
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  int default_value 
)
{
  IGRboolean got_input=FALSE, got_default;
  IGRint response, val=0;
  IGRlong msg_loc;
  IGRdouble response_data[128];
  struct GRevent event;

  do 
  {
    if (status)
      UI_status (status);

    if (prompt)
      UI_prompt (prompt);

    got_default = FALSE;
    co$getevent (msg = &msg_loc, event_mask = 
     GRm_VALUE | GRm_RJT_MOVEON, response = &response,
     response_data = response_data, event = &event);

    if (prompt)
      UI_prompt ("");
   
    if (msg_loc == GRw_no_value || event.response == EX_RJT_MOVEON)
      got_default = TRUE;

    if (default_acceptable && got_default)
    {
      val = default_value;
      got_input = TRUE;
    }
    else if (event.response == EX_VALUE)
    {
      val = event.event.value;
      got_input = TRUE;
    }
    else 
    {
      UI_status ("No way out of here, except via good input");
      sleep (1);      
    }
  }
  while (!got_input);

  return (val);
}


/*
  DESCRIPTION

  The following function can be used to obtain a single character from the
  user. If NULL is specified for 'prompt' then prompt field remains untouched.
  If NULL is specified for 'status then status field remains untouched. If
  FALSE is specified for 'default_acceptable', then default (move-on) is not
  acceptable. If default is acceptable and default is specified by user
  then 'default_value' is returned as this function's value.
*/

char EMgetchar
(
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  char default_value 
)
{
  char val='\0';
  IGRboolean got_input=FALSE, got_default;
  IGRint response;
  IGRlong msg_loc;
  IGRdouble response_data[128];
  struct GRevent event;

  do 
  {
    if (status)
      UI_status (status);

    if (prompt)
      UI_prompt (prompt);

    got_default = FALSE;
    co$getevent (msg = &msg_loc, event_mask = 
     GRm_CHAR | GRm_RJT_MOVEON, mode = EX_ALL_CHAR_MODE,
     response = &response, response_data = response_data, event = &event);

    if (prompt)
      UI_prompt ("");
   
    if (msg_loc == GRw_no_value || event.response == EX_RJT_MOVEON)
      got_default = TRUE;

    if (default_acceptable && got_default)
    {
      val = default_value;
      got_input = TRUE;
    }
    else if (event.response == EX_CHAR)
    {
      val = event.event.keyin[0];
      got_input = TRUE;
    }
    else 
    {
      UI_status ("No way out of here, except via good input");
      sleep (1);      
    }
  }
  while (!got_input);

  return (val);
}


/*
  DESCRIPTION

  The following function can be used to obtain a NULL-terminated string
  from the user. The function returns the pointer to the first character of
  the string. The memory for the string-output is passed in by the caller and
  is a character array of size = GR_MAX_CHAR. 

  If NULL is specified for 'prompt' then prompt field remains untouched. If
  NULL is specified for 'status then status field remains untouched. If FALSE
  is specified for 'default_acceptable', then default (move-on) is not
  acceptable. If default is acceptable and default is specified by user then 
  'default_value' is returned as this function's value. The 'default_value'
  string is copied into 'string_memory' and it's pointer returned.
*/

char *EMgetstring
(
  char *prompt, 
  char *status, 
  IGRboolean default_acceptable, 
  char *default_value,
  char string_memory[GR_MAX_CHAR]
)
{
  IGRboolean got_input=FALSE, got_default;
  IGRint response;
  IGRlong msg_loc;
  IGRdouble response_data[128];
  struct GRevent event;

  do 
  {
    if (status)
      UI_status (status);

    if (prompt)
      UI_prompt (prompt);

    got_default = FALSE;
    co$getevent (msg = &msg_loc, event_mask = 
     GRm_STRING | GRm_RJT_MOVEON, response = &response, 
     response_data = response_data, event = &event);

    if (prompt)
      UI_prompt ("");
   
    if (msg_loc == GRw_no_value || event.response == EX_RJT_MOVEON)
      got_default = TRUE;

    if (default_acceptable && got_default)
    {
      strcpy (string_memory, default_value);
      got_input = TRUE;
    }
    else if (event.response == EX_STRING)
    {
      strcpy (string_memory, event.event.keyin);
      got_input = TRUE;
    }
    else 
    {
      UI_status ("No way out of here, except via good input");
      sleep (1);      
    }
  }
  while (!got_input);

  return (string_memory);
}
