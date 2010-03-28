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
   CO_ni_set_variable()

   Abstract: 

      This function sets the value of a variable ( new or old ) to a 
      specified value.


   Arguments: 
     
      ReturnMsg      *IGRlong 
         return message 
            MSSUCC
            MSFAIL

      Events         *struct GRevent[]
        array of events that supply information needed to make the variable
        assignment.

           Events[0]  -  name of the variable
           Events[1]  -  contents of the variable

   Returns: 

      MSSUCC
      MSFAIL

   Sample Call: 

      status = CO_ni_set_variable( &msg, Events );

   Caveats: 

   History: 

       07/30/87  srh  - created
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
#include    "msmacros.h"
#include    "grmessage.h"
#include    "godef.h"
#include    "go.h"
#include    "ex.h"
#include    "griodef.h"
#include    "grio.h"
#include    "griomacros.h"
#include    "griopriv.h"
#include    "comiscmac.h"
#include    "exmacros.h"
#include    "grdpbmacros.h"
#include    "dpdef.h"
#include    "dp.h"
#include    "dpmacros.h"
#include    "codebug.h"
#include    "igrmacros.h"

#define     VariableName     Events[0]->event.keyin
#define     VariableType     Events[1]->response
#define     StringVariable   Events[1]->event.keyin
#define     ValueVariable    Events[1]->event.value
#define     PointVariable    Events[1]->event.button





IGRlong  CO_ni_set_variable( ReturnMsg,
                             Events )
 
    IGRint             *ReturnMsg;
    struct GRevent     *Events[];

{
    IGRlong
       ReturnStatus = MSSUCC;

    struct GRIOvar_def
       Variable;        /* variable to be assigned a value       */

    OMuword   
       ModuleOsnum;     /* object space where variable is stored */

    IGRchar
       *p_VarChar;

    IGRboolean
       BadVarName;

    /*  EV - end of local variables */

    /*
     *  --------------------------------------------------------------------
     *  Step 1 :   Validate variable name
     *  --------------------------------------------------------------------
     */

    p_VarChar = VariableName;
    BadVarName = FALSE;
 
    while ( *p_VarChar != NULL ) 
    {
       if ( ! isvar( *p_VarChar ) )
       {
	  BadVarName = TRUE;
       }
       p_VarChar++;
    }

    if ( ! BadVarName )
    {
       /*
        *  --------------------------------------------------------------------
        *  Step 2 :  get variable's contents and load it in var struct
        *  --------------------------------------------------------------------
        */
       _m_debug_str( "> CO_ni_set_variable" );

       switch( VariableType )
       {

         case EX_STRING: 

            Variable.type  = GRIO_VAR_STRING;
            strncpy( Variable.contents.string, StringVariable, 40 ); 
            break;


         case EX_DATA: 

            Variable.type  = GRIO_VAR_POINT;
            Variable.contents.point[0] = PointVariable.x;
            Variable.contents.point[1] = PointVariable.y;
            Variable.contents.point[2] = PointVariable.z;
            break;


         case EX_VALUE:  

            Variable.type  = GRIO_VAR_FLOAT;
            Variable.contents.fvalue = ValueVariable;
            break;


         default: 

            break;

      } /*  end switch( VariableTyep ) */
   
      /*
       *  --------------------------------------------------------------------
       *  Step 3 :  add variable to variable table
       *  --------------------------------------------------------------------
       */

      ex$get_cur_mod( osnum = &ModuleOsnum );

      ReturnStatus = co$addvar( msg          =  ReturnMsg,
                                input_alias  =  VariableName,
                                osnum        =  ModuleOsnum,
                                input_string = &Variable );

      _m_check2p( ReturnStatus, 
		 *ReturnMsg,
		 "CO_ni_set_variable:  co$addvar failed" );

      ReturnStatus = CO_ni_show_variable( ReturnMsg,
                                          Events );

   }
   else
   {
      ex$message( msgnumb = GR_E_NotValVarNam,
                  field   = ERROR_FIELD,
                  justification = CENTER_JUS );

      *ReturnMsg = CO_e_bad_variable_name;
       ReturnStatus = MSFAIL;
   }

   _m_debug_str( "< CO_ni_set_variable" );
   return ( ReturnStatus );

}

