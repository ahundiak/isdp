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
              intergraph and/or other  third parties which is
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

/*
    CObuild_button()
       
    Abstract:  function to fill in the fields of a EX_button structure

    Arguments:

      *msg          IGRlong             return code = MSSUCC always
       x            IGRdouble           x coordinate ( in WCS ) 
       y            IGRdouble           y coordinate ( in WCS )
       z            IGRdouble           z coordinate ( in WCS )
       window       IGRlong             hardware window number
       objid        OM_S_OBJID          gragad objid 
       osnum;       uword               space # of gragad
       numb         IGRshort            button number
       clicks       IGRshort            number of button clicks
       button_down  IGRshort            1 = down, 0 = up 
      *button;      struct EX_button    buffer where EX_button stored


    BUTTON STRUCTURE  ( for reference )

    struct  EX_button
    {
       IGRdouble   x;                       x coordinate ( in WCS )
       IGRdouble   y;                       y coordinate ( in WCS )
       IGRdouble   z;                       z coordinate ( in WCS )
       IGRlong     window;                  hardware window number
       OM_S_OBJID  objid;                   object id of the gragad
       uword       osnum;                   space # of gragad
       IGRshort    numb;                    button number
       IGRshort    clicks;                  number of button clicks
       IGRshort    button_down;             1 = down, 0 = up
    }


    Returns:  MSSUCC (always)

 */

/* EH */

#include "coimport.h"
#include "codebug.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "msdef.h"
#include "griodef.h"
#include "grio.h"
#include "igrmacros.h"


IGRlong CObuild_button( msg,
                        x,
                        y,
                        z,
                        window,
                        objid,
                        osnum,
                        numb,
                        clicks,
                        button_down,
                        button )

    IGRlong           *msg;             /* return code = MSSUCC or MSFAIL    */
    IGRdouble          x;               /* x coordinate ( in WCS )           */
    IGRdouble          y;               /* y coordinate ( in WCS )           */
    IGRdouble          z;               /* z coordinate ( in WCS )           */
    IGRlong            window;          /* hardware window number            */
    OM_S_OBJID         objid;           /* gragad objid                      */
    uword              osnum;           /* space # of gragad                 */
    IGRshort           numb;            /* button number                     */
    IGRshort           clicks;          /* number of button clicks           */
    IGRshort           button_down;     /* 1 = down, 0 = up                  */
    struct EX_button  *button;          /* EX_button structure built         */

{  
   _m_debug_str( ">  CObuild_button" );
   *msg = MSSUCC;

   button->x = x;
   button->y = y;
   button->z = z;

   button->window      = window;     
   button->objid       = objid;
   button->osnum       = osnum;    
   button->numb        = numb;    
   button->clicks      = clicks; 
   button->button_down = button_down;
   
   _m_debug_str( "<  CObuild_button" );
   return(MSSUCC);
}
