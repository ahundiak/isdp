/*

Name
  InitValues.I

Description
 Routines in this file process input from the User
 for the initial value form.

Notes


 */

class implementation FIdirform;

#ifdef ENABLE_MATH_H
%safe
#include <math.h>
%endsafe
#endif

#include "coimport.h"
#include "OMerrordef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ODE.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include <stdio.h>
#include "msmacros.h"
#include "drawparam.h"

%safe
static Form   InitValuesForm = NULL;
static double *p_values = NULL;
static int    DIaccept, DIcount;
%endsafe

#argsused
void DINotifyInit (
  int    form_label,
  int    gadget_label,
  double value,
  Form   form)
{
  int  i, flag, response = TERMINATE;
  char tmp [DI_PATH_MAX];
  long msg;
  
  switch (gadget_label)
  {
    case 1: DIaccept = 1;
            for (i = 0; i < DIcount; i++)
            {
              FIfld_get_text ( form, 14, i, 1, DI_PATH_MAX,
                  tmp, &flag, &flag );
              sscanf ( tmp, "%lf", &(p_values [i]) );
              if (!*tmp)
              {
                DIaccept = 0;
                break;
              }
            }
    case 4: FIf_delete ( form );
            InitValuesForm = NULL;
            ex$putque ( msg = &msg, response = &response );
            break;
  }
}


EXPGiveInitialValues (
  char   *names [], /* list of variable names IN  */
  int    count,     /* number of names	      IN  */
  double values []) /* the values						  OUT */
/*
 * This routine is used to initialize variables of equations that are
 * in a strong component.
 */
{
  int    i, ret;
  char   tmp [DI_PATH_MAX];


  ret = FIf_new ( 1, "GRInitVals", DINotifyInit, &InitValuesForm );
  if (ret)
    return OM_E_ABORT;

  /*
   * We set the names and the values that are known.
   */
  for (i = 0; i < count; i++)
  {
    FIfld_set_text ( InitValuesForm, 14, i, 0, names [i], 0 );
    if (values [i] != MAXDOUBLE)
      sprintf ( tmp, "%g", values [i] );
    else
      *tmp = '\0';
    FIfld_set_text ( InitValuesForm, 14, i, 1, tmp, 0 );

  }
  
  p_values = values;
  DIaccept = 0;
  DIcount = count;
  FIf_display ( InitValuesForm );
  
  /*
   * We loop until we get accept/reject. DIaccept will be set to 1 if
   * the guy accepts the values. Note that he can only accept the 
   * values if ALL of them are initialized.
   */
  while (InitValuesForm)
  {
    long           msg, response;
    char           response_data [1024];
    struct GRevent event;

    co$getevent ( msg = &msg, event_mask = 0, response = &response, 
        response_data = response_data, event = &event );

  }
  
  return DIaccept;  
}


end implementation FIdirform;

