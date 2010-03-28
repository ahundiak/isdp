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
   CO_ni_show_variable()

   Abstract: 

      This function displays the type and contents of a variable 

   Arguments: 
     
      ReturnMsg      *IGRlong 
         return message 
            MSSUCC
            CO_e_bad_variable_name  - no such variable
            MSFAIL

      Events         *struct GRevent[]
        array of events that supply information needed to make the variable
        assignment.

           Events[0]  -  name of the variable

   Returns: 

      MSSUCC
      MSFAIL

   Sample Call: 

      status = CO_ni_show_variable( &msg, Events );

   Caveats: 

   History: 

       08/21/87  srh  - created
 */

/*  EH - End of Header */

#include    "coimport.h"
#include    "OMminimum.h"
#include    "OMprimitives.h"
#include    "igrtypedef.h"
#include    "igetypedef.h"
#include    "igr.h"
#include    "gr.h"
#include    "igrdp.h"
#include    "msdef.h"
#include    "godef.h"
#include    "go.h"
#include    "ex.h"
#include    "griodef.h"
#include    "grio.h"
#include    "griomacros.h"
#include    "comiscmac.h"
#include    "exmacros.h"
#include    "grdpbmacros.h"
#include    "dpdef.h"
#include    "dp.h"
#include    "dpmacros.h"
#include    "codebug.h"
#include    "igrmacros.h"
#include    "grdpbdef.h"

#define     VariableName     Events[0]->event.keyin


IGRlong  CO_ni_show_variable( ReturnMsg,
                              Events )
 
    IGRint             *ReturnMsg;
    struct GRevent     *Events[];

{
    IGRlong
       ReturnStatus = MSSUCC;

    IGRchar
       StatusFieldMsg[80];

    OMuword   
       ModuleOsnum;     /* object space where variable is stored */
    
    struct GRIOvar_def
       Variable; /* variable to be assigned a value */

    extern int 
       DPdrawcross();

    /***  EV - end of local variables ***/

    _m_debug_str( "> CO_ni_show_variable" );

    ex$get_cur_mod( osnum = &ModuleOsnum );

    ReturnStatus = co$cvtvar( msg   =  ReturnMsg,
                              alias =  VariableName,
                              osnum =  ModuleOsnum,
                              var   = &Variable );
    _m_check2q( ReturnStatus, *ReturnMsg );

    /* 
     *  Build string describing contents of variable according to the 
     *  specified variable's type
     */
    switch( Variable.type )
    {
       case GRIO_VAR_FLOAT : 
 
          sprintf( StatusFieldMsg, 
                   "%s(value) = %f", 
                   VariableName,
                   Variable.contents.fvalue );
          break;
 
       case GRIO_VAR_INT : 
 
          sprintf( StatusFieldMsg, 
                   "%s(integer) = %d", 
                   VariableName,
                   Variable.contents.ivalue );
          break;
 
       case GRIO_VAR_POINT : 
                 
          {
              struct EX_button DisplayButton;
              IGRint 
	         BufferSize = sizeof( struct EX_button ),
	         BytesReturned;

              sprintf( StatusFieldMsg, 
                       "%s(point) = %f, %f, %f", 
                       VariableName,
                       Variable.contents.point[0],
                       Variable.contents.point[1],
                       Variable.contents.point[2] );

       
              gr$get_last_point( msg    = &ReturnStatus,
                                 sizbuf = &BufferSize,
                                 buffer = &DisplayButton,
                                 nret   = &BytesReturned );

             DisplayButton.x = Variable.contents.point[0];
             DisplayButton.y = Variable.contents.point[1];
             DisplayButton.z = Variable.contents.point[2];

             DPdrawcross(&ReturnStatus, &DisplayButton );
          }
          break;
 
       case GRIO_VAR_STRING : 
 
          sprintf( StatusFieldMsg, 
                   "%s(string) = %s", 
                   VariableName,
                   Variable.contents.string );
          break;
 
       default :   
 
          printf( " COsetvar:   Bad variable type received!!!\n" );
          goto quit;

    }

    UI_status( StatusFieldMsg );

quit: 
    _m_debug_str( "< CO_ni_show_variable" );
    return ( ReturnStatus );

}
