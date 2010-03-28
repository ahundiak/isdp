/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              Intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRcreate_setadp
 
     Abstract:

      This function returns the form pointer to the set active drawing
      parameters form.  It creates the form if it does not exist.
-----
%SC%

     VALUE = GRcreate_setadp(msg,create,form_ptr)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     create       IGRint              TRUE (1) => create the form if it does
                                                  not exist
                                      FALSE (0) => do not create the form if
                                                   it does not exist
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong             return code
                                        MSSUCC - if successful
                                        MSFAIL - if we cannot create
                                                 the form
     *form_ptr    Form                a pointer to the form
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:
     methods:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  06/13/89 : Design date.
        WBC  06/13/89 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This function returns the form pointer to the set active drawing
parameters form.  It creates the form if it does not exist.
----*/
/*EH*/

#include "coimport.h"
#include "tools.h"
#include "FI.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "exmacros.h"
#include "adpdef.h"
#include "msdef.h"

static Form   setadp_form_ptr = 0;

IGRint GRcreate_setadp(msg,create,form_ptr)

IGRlong       *msg;       /* return code                       */
IGRint        create;     /* whether or not to create the form */
Form          *form_ptr;  /* a pointer to the form             */

{
    extern void   GRprocess_setadp();  /* function to process input */
    IGRint        status;

    *msg = MSSUCC;
    status = TRUE;

    if (setadp_form_ptr)
    {
        /*
         * form already exists; return the form pointer
         */

        *form_ptr = setadp_form_ptr;
    }
    else if (create)
    {
        if (FIf_new(SET_ADP_FORM_LABEL,SET_ADP_FORM_FILENAME,
                    GRprocess_setadp,form_ptr))
        {
            *msg = MSFAIL;
            status = FALSE;
        }
        else
        {
            setadp_form_ptr = *form_ptr;
        }
    }
    else
    {
        status = FALSE;
    }

    return(status);
}

IGRint GRdelete_setadp()
{
    if (setadp_form_ptr)
    {
        FIf_delete(setadp_form_ptr);
        setadp_form_ptr = NULL;
    }

    return(TRUE);
}
