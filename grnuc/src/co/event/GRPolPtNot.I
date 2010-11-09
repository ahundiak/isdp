/*
   Function:
      GRPolarDpt_notification()

   Arguments:
      standard FI notification interface
   
   Abstract: 
      This function is invoked when a gadget is processed by the
      form used by the Generate Polar Array of Point command.  This
      command's behaviour is affected by three external parameters:
         
         1) a flag determining if the center point is generated or not;

         2) a flag determining if a MOVEON event is generated after 
            each sweep;

         3) a flag determining if the start point of each sweep is 
            regenerated at the end of the sweep ( e.g. to close a
            linestring ).
   
      In version 1.3.0 of GRNUC, instance data in the dpb cannot be
      modified so we use the variable  table ( class GRvar ) to store
      this info from session to session.

 */

class implementation Root;

#include "coimport.h"
#include <stdio.h>
#include "FI.h"
#include "exmacros.h"
#include "griomacros.h"
#include "msdef.h"

/* variable names for Generate Polar Array of Points commands */
#define  MOVEON_TOGGLE_NAME     "_GR_MOVEON_TOGGLE"
#define  CENTER_PT_TOGGLE_NAME  "_GR_CENTER_PT_TOGGLE"
#define  CLOSE_TOGGLE_NAME      "_GR_CLOSE_TOGGLE"
#define  START_PT_TOGGLE_NAME   "_GR_POL_START_PT_TOG"

/* Gadgets */
#define  MOVEON_TOGGLE          (12)
#define  CENTER_PT_TOGGLE       (13)
#define  CLOSE_TOGGLE           (14)
#define  START_PT_TOGGLE        (15)

#define  _OFF                   ( 0 )
#define  _ON                    ( 1 )

from CEO import erase_form_by_label;

extern int 
   FIf_get_cmd_oid_os(),
   FIg_get_state(),
   FIg_set_state_on(),
   FIg_set_state_off();

#argsused
void  GRPolarDpt_notification(
   int     f_label,       /* The label of the form   */
   int     g_label,       /* The label of the gadget */
   double  value,         /* The value of the gadget */
   Form    fp)            /* Pointer to the form     */
{

   int  
      fi_sts = 0,
      state;

   IGRlong
      msg = MSSUCC,
      status = MSSUCC;

   struct GRIOvar_def
      var;

   unsigned int
      cmd_id;

   unsigned short 
      cmd_os; 

   switch ( g_label )
   {
      case FI_CANCEL:     /* Member of group   */
         /* Erase the displayed form */
         fi_sts = FIf_get_cmd_oid_os( fp, &cmd_id, &cmd_os );

         status = om$send(
             msg = message CEO.erase_form_by_label( STATUS_FORM, 0,
                           (IGRint *) &msg ),
             senderid = NULL_OBJID,
             targetid = cmd_id,
             targetos = cmd_os );

         break;

      case FI_ACCEPT:     /* Member of group   */
         {
            OMuword mod_os;

            /* module OS needed so we know which OS the variable table is in */
            status = ex$get_cur_mod( osnum = &mod_os );

            /*
             *  Process form data: read toggle setting and set variables
             *  accordingly
             */
   
            /* Moveon after each sweep ? */
            fi_sts = FIg_get_state( fp, MOVEON_TOGGLE, &state );
   
            var.type = GRIO_VAR_INT;
            var.contents.ivalue = state;

            status = co$addvar( msg           = &msg,
                                input_alias   =  MOVEON_TOGGLE_NAME,
                                osnum         =  mod_os,
                                input_string  = &var );
   
            /* set variable accordingly */
   
            /* Generate center point ? */
            fi_sts = FIg_get_state( fp, CENTER_PT_TOGGLE, &state );
   
            /* set variable accordingly */
            var.type = GRIO_VAR_INT;
            var.contents.ivalue = state;
   
            status = co$addvar( msg           = &msg,
                                input_alias   =  CENTER_PT_TOGGLE_NAME,
                                osnum         =  mod_os,
                                input_string  = &var );
   
            /* Close after each sweep ? */
            fi_sts = FIg_get_state( fp, CLOSE_TOGGLE, &state );
   
            /* set variable accordingly */
            var.type = GRIO_VAR_INT;
            var.contents.ivalue = state;
   
            status = co$addvar( msg           = &msg,
                                input_alias   =  CLOSE_TOGGLE_NAME,
                                osnum         =  mod_os,
                                input_string  = &var );
   
            /* Generate start point of first sweep? */
            fi_sts = FIg_get_state( fp, START_PT_TOGGLE, &state );
   
            /* set variable accordingly */
            var.type = GRIO_VAR_INT;
            var.contents.ivalue = state;
   
            status = co$addvar( msg           = &msg,
                                input_alias   =  START_PT_TOGGLE_NAME,
                                osnum         =  mod_os,
                                input_string  = &var );
      

            /* Erase the displayed form */
            fi_sts = FIf_get_cmd_oid_os( fp, &cmd_id, &cmd_os );

            status = om$send(
                msg = message CEO.erase_form_by_label( STATUS_FORM, 0,
                              (IGRint *) &msg ),
                senderid = NULL_OBJID,
                targetid = cmd_id,
                targetos = cmd_os );
         }
         break;

   } /* END switch ( g_label ) */

} /* END notification() */


void GRPolarDpt_init( fp )
   Form  fp;
{

   int  
      fi_sts = 0,
      state;

   IGRlong
      status = MSSUCC,
      msg = MSSUCC;

   struct GRIOvar_def
      var;

   OMuword mod_os;

   /* ================================================================ */

   msg = MSSUCC;
    
   /* module OS needed so we know which OS the variable table is in */
   status = ex$get_cur_mod( osnum = &mod_os );

   /* get saved toggle settings from variable table */

   /* ========================  MOVEON_TOGGLE  ======================= */
   status = co$cvtvar( msg    = &msg,
                       alias  =  MOVEON_TOGGLE_NAME,
                       osnum  =  mod_os,
                       var    = &var );

   /* if variable does not exist, create it with the default value */
   if ( msg == MSFAIL )
   {
      var.type = GRIO_VAR_INT;
      var.contents.ivalue = _OFF; /* dafault */
      status = co$addvar( msg           = &msg,
                          input_alias   =  MOVEON_TOGGLE_NAME,
                          osnum         =  mod_os,
                          input_string  = &var );
   }

   state = var.contents.ivalue;
   fi_sts = ( state == _ON ) ?
      FIg_set_state_on  ( fp, MOVEON_TOGGLE ) :
      FIg_set_state_off ( fp, MOVEON_TOGGLE );


   /* ====================  CENTER_PT_TOGGLE  ======================= */

   /* get saved toggle settings from variable table */
   status = co$cvtvar( msg    = &msg,
                       alias  =  CENTER_PT_TOGGLE_NAME,
                       osnum  =  mod_os,
                       var    = &var );

   /* if variable does not exist, create it with the default value */
   if ( msg == MSFAIL )
   {
      var.type = GRIO_VAR_INT;
      var.contents.ivalue = _OFF; /* default */
      status = co$addvar( msg           = &msg,
                          input_alias   =  CENTER_PT_TOGGLE_NAME,
                          osnum         =  mod_os,
                          input_string  = &var );
   }

   state = var.contents.ivalue;
   fi_sts = ( state == _ON ) ?
      FIg_set_state_on  ( fp, CENTER_PT_TOGGLE ) :
      FIg_set_state_off ( fp, CENTER_PT_TOGGLE );

   /* ========================  CLOSE_TOGGLE  ====================== */

   /* get saved toggle settings from variable table */
   status = co$cvtvar( msg    = &msg,
                       alias  =  CLOSE_TOGGLE_NAME,
                       osnum  =  mod_os,
                       var    = &var );

   /* if variable does not exist, create it with the default value */
   if ( msg == MSFAIL )
   {
      var.type = GRIO_VAR_INT;
      var.contents.ivalue = _OFF; /* default */
      status = co$addvar( msg           = &msg,
                          input_alias   =  CLOSE_TOGGLE_NAME,
                          osnum         =  mod_os,
                          input_string  = &var );
   }

   state = var.contents.ivalue;
   fi_sts = ( state == _ON ) ?
      FIg_set_state_on  ( fp, CLOSE_TOGGLE ) :
      FIg_set_state_off ( fp, CLOSE_TOGGLE );

   /* ====================  START_PT_TOGGLE  ======================= */

   /* get saved toggle settings from variable table */
   status = co$cvtvar( msg    = &msg,
                       alias  =  START_PT_TOGGLE_NAME,
                       osnum  =  mod_os,
                       var    = &var );

   /* if variable does not exist, create it with the default value */
   if ( msg == MSFAIL )
   {
      var.type = GRIO_VAR_INT;
      var.contents.ivalue = _ON; /* default */
      status = co$addvar( msg           = &msg,
                          input_alias   =  START_PT_TOGGLE_NAME,
                          osnum         =  mod_os,
                          input_string  = &var );
   }

   state = var.contents.ivalue;
   fi_sts = ( state == _ON ) ?
      FIg_set_state_on  ( fp, START_PT_TOGGLE ) :
      FIg_set_state_off ( fp, START_PT_TOGGLE );

}

end implementation Root;
