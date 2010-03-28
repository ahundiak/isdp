class implementation Root;

#include    "coimport.h"
#include    <stdio.h>
#include    "FI.h"
#include    "codebug.h"
#include    "msdef.h"
#include    "exmacros.h"
#include    "msmacros.h"
#include    "grmessage.h"
#include    "griomacros.h"


/* Gadgets */

#define DEFAULT_ANGLE_OF_ROTATION  "0 degrees"

#define ANGLE_OF_ROTATION_NAME     "_GR_ANGLE_OF_ROTATION"
#define GEN_START_PT_TOGGLE_NAME   "_GR_START_PT_TOGGLE"

#define ANGLE_OF_ROTATION           (12)
#define GEN_START_PT_TOGGLE         (14)


#define BAD_ANGLE ( !( (status & 1) && (msg & 1) ) )

/* toggle gadget settings */
#define  _OFF                   ( 0 )
#define  _ON                    ( 1 )


/* Externs */

extern int 
   FIg_get_text_length(),
   FIg_get_text(),
   FIg_get_state(),
   FIf_get_cmd_oid_os(),
   FIg_set_state_on(),
   FIg_set_state_off();


from CEO import erase_form_by_label;

#argsused
void GRMtrxDpt_notification ( f_label, g_label, value, fp )
   int     f_label;       /* The label of the form   */
   int     g_label;       /* The label of the gadget */
   double  value;         /* The value of the gadget */
   Form    fp;            /* Pointer to the form     */
{
   char
     *text,
      angle_text[40];

   short
      field_size;

   int
      text_len,
      fi_sts = 0;

   long
      status = MSSUCC,
      msg = MSSUCC;

   unsigned int
      cmd_id;

   unsigned short
      cmd_os; 

   struct GRIOvar_def
      var;

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
            int state;

            /* module OS needed so we know which OS the variable table is in */
            status = ex$get_cur_mod( osnum = &mod_os );

            /*
	     *  save toggle setting in variable table 
	     */
            fi_sts = FIg_get_state( fp, GEN_START_PT_TOGGLE, &state );

            var.type = GRIO_VAR_INT;
            var.contents.ivalue = state;

            status = co$addvar( msg          = &msg,
                                input_alias  =  GEN_START_PT_TOGGLE_NAME,
                                osnum        =  mod_os,
                                input_string  = &var );

            /*
	     *  save rotation angle from form gadget in variable table 
	     */
            FIg_get_text ( fp, ANGLE_OF_ROTATION, angle_text );

            var.type = GRIO_VAR_STRING;
            strncpy( var.contents.string, angle_text, 40 );

            status = co$addvar( msg           = &msg,
                                input_alias   =  ANGLE_OF_ROTATION_NAME,
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

      case ANGLE_OF_ROTATION:
         {
            IGRdouble angle;
            OMuword mod_os;

            /* module OS needed so we know which OS the variable table is in */
            status = ex$get_cur_mod( osnum = &mod_os );

            /* Get the text length of the active row */
            FIg_get_text_length ( fp, g_label, &text_len );

            /* Calloc space for string */
            text = ( char * ) calloc ( 1, ++text_len );

            /* Get the active row text from the field */
            FIg_get_text ( fp, g_label, text );

            /* Code to process text string */
            status = co$expreval( msg        = &msg,
                                  expression =  text,
                                  unit_type  =  GRIO_ANGLE,
                                  result     = &angle );

            /* handle good and bad input */
            if ( BAD_ANGLE )
            {
               char msg_text[40];

               /* handle bad input:  get current value from variable table
                * and restore the original value.  Print message in 
                * form's message field staing "bad keyin";
                */
               status = co$cvtvar( msg   = &msg,
                                   alias =  ANGLE_OF_ROTATION_NAME,
                                   osnum =  mod_os,
                                   var   = &var );

               fi_sts = FIg_set_text( fp, 
                                      ANGLE_OF_ROTATION,
                                      var.contents.string);

               /* write error message to FI_MSG_FIELD field */
               ex$message( msgnumb = GR_E_InvAng, buff = msg_text );
               msg_text[39] = '\0';  /* ob,ts */
               fi_sts = FIg_set_text( fp, 
                                      FI_MSG_FIELD,
                                      msg_text );
            }
            else /* GOOD angle conversion */
            {
               /* handle good input */
               int nbr_of_aliases = 1;
               field_size = sizeof(char) * 40;
               status = co$cvt_imp_to_alias(
                            msg                = &msg,
                            unit_type          =  GRIO_ANGLE,
                            osnum              =  mod_os,
                            working_units      = &angle,
                            num_alias          = &nbr_of_aliases,
                            field_size         = &field_size,
                            cvt_list           =  angle_text );
               /*
                * 12/03/92 - JSD - adding field_size above will properly null
                * terminate the string so the following line is not needed
                */

               /* angle_text[39] = '\0';   once bitten, twice shy */

               fi_sts = FIg_set_text( fp, 
                                      ANGLE_OF_ROTATION,
                                      angle_text );
            }

            /* Free the space calloced */
            free ( text );
         }
         break;

     } /* END switch ( g_label ) */

} /* END GRMtrxDpt_notification() */



void GRMtrxDpt_init( fp )
   Form     fp;
{

   int  
      fi_sts = 0,
      state;

   IGRlong
      status = MSSUCC,
      msg = MSSUCC;

   struct GRIOvar_def
      var;

   OMuword 
      mod_os;

   IGRchar 
      angle_text[40];

   /* module OS needed so we know which OS the variable table is in */
   status = ex$get_cur_mod( osnum = &mod_os );

   /* ======================  ANGLE_OF_ROTATION  ==================== */
   status = co$cvtvar( msg    = &msg,
                       alias  =  ANGLE_OF_ROTATION_NAME,
                       osnum  =  mod_os,
                       var    = &var );

   /* if variable does not exist, create it with the default value */
   if ( msg == MSFAIL )
   {
      var.type = GRIO_VAR_STRING;
      strncpy( var.contents.string, DEFAULT_ANGLE_OF_ROTATION, 40 );

      status = co$addvar( msg           = &msg,
                          input_alias   =  ANGLE_OF_ROTATION_NAME,
                          osnum         =  mod_os,
                          input_string  = &var );
   }

   strncpy( angle_text, var.contents.string, 40 );
   angle_text[39] = '\0'; /* once bitten, twice shy */

   fi_sts = FIg_set_text( fp, ANGLE_OF_ROTATION, angle_text );


   /* ====================  GEN_START_PT_TOGGLE  ======================= */

   /* get saved toggle settings from variable table */
   status = co$cvtvar( msg    = &msg,
                       alias  =  GEN_START_PT_TOGGLE_NAME,
                       osnum  =  mod_os,
                       var    = &var );

   /* if variable does not exist, create it with the default value */
   if ( msg == MSFAIL )
   {
      var.type = GRIO_VAR_INT;
      var.contents.ivalue = _ON; /* default */
      status = co$addvar( msg          = &msg,
                          input_alias  =  GEN_START_PT_TOGGLE_NAME,
                          osnum        =  mod_os,
                          input_string = &var );
   }

   state = var.contents.ivalue;

   fi_sts = ( state == _ON ) ?
      FIg_set_state_on  ( fp, GEN_START_PT_TOGGLE ) :
      FIg_set_state_off ( fp, GEN_START_PT_TOGGLE );

}
end implementation Root;
