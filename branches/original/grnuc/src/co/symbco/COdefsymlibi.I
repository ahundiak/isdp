/*
Name
   COdefsymlib

Description
   The COdefsymlib command object defines an active cell library  
   given a cell library name from a keyin. If the file does not exist,
   the user is prompted if he wishes to create the file; If the file 
   exists but is not a cell library, the command is restarted.  If a 
   file is already attached as an active cell library, this file is 
   dettached before the new cell library is attached. 

Notes
   At this time only one symbol library may be attached, later more
   should be accomodated. Problems can arise if a symbol library is
   attached as read only and another module attempts to attach for
   read/write.


History
   BC     06/12/86 : Design date.
   HGW    07/03/86 : Finish coding and tested.
   mrm    10/10/86 : OM 4.0 conversion
   HGW    07/27/87 : Added code to insure that the 
                     retreived OS was of the proper type.
   HGW    12/15/87 : Changes for version 1.1
   mrm    03/23/89 : display cell name before exiting if successfully attached
   jhw    12/30/89 : Added a check for a NULL string in the state GET_LIB
   mrm    11/15/93 : Check for invalid character in filename
   dhm    11/16/93 : Check for filename already being the active cell library.
   sudha  04/26/94 : purify fix - initialize file
*/

class implementation COdefsymlib;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "exmacros.h"
#include "codef.h"
#include "grdpbdef.h"
#include "grerr.h"
#include "execmsg.h"

/*
 *  External states
 */

#define START        0
#define CREATE_LIB   1

/*
 *  Internal states
 */

#define GET_LIB      3
#define DEFINE_LIB   2

/*
 *  Control looping conditions
 */

#define OMERROR     0      /* Exit command and return(om_msg)       */
#define SUCCESS     1      /* Continue looping                      */
#define RETCONTROL  2      /* Exit command and return(OM_S_SUCCESS) */

/***********************************************************************/
/******************** COevent execute method ***************************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
IGRlong                    om_msg = 1;
IGRlong                    ret_msg;
IGRint                     exit_code;
IGRint                     flag;
IGRchar                    ans_string[GR_MAX_CHAR]; 
struct GRsymbol_lib_file   file;

   file.file_name[0] = NULL;
   file.file_no = -1;
   file.file_access = FALSE;

   ex$message(msgnumb = GRC_M_DfnActCelLib);
   if (me->init_success)
   {
      exit_code = SUCCESS;
   }else
   {
      ex$message(msgnumb = GR_F_ErrEncCmdTrm);
      exit_code = RETCONTROL;
   }

   while (exit_code == SUCCESS)
   {
      switch (me->state)
      {
         case START:
         {
            gr$symget_asl_info (msg = &ret_msg, file = &file);

            if (ret_msg != GR_I_NOSL)
            {
               if (file.file_no == -1)
               {
                  ex$message(msgnumb = GR_I_CelLibNotFnd, type="%s",
                     var=`file.file_name`);
               }else
               {
                  ex$message(msgnumb = GR_I_CelLib, type="%s",
                     var=`file.file_name`);
               }
            }
            me->state = GET_LIB;
         }  /* End of case START */

         case GET_LIB:
         {
            co$getevent(msg = &ret_msg, 
               event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
               msgnum = GR_P_KyCelLibNme, response = response, 
               response_data = response_data, event = &me->event);

            switch (me->event.response)
            {
               case STRING:
               {
                  if ( me->event.event.keyin[0] )
                  {
                      // Make sure the filename is valid - this test seems
                      // backwards, but that's the way the function works.
                      if (!EX_invalid_char_in_filename(me->event.event.keyin))
                      {
                          ex$message(msgnumb = EX_F_InvalidFilename,
                                     type = "%s",
                                     var = `me->event.event.keyin`);
                          break;
                      }

                     /*
                      * See if this file is already the active cell library.
                      */

                     if ( !strcmp(file.file_name, me->event.event.keyin) )
                     {
                         ex$message(msgnumb = GR_I_FileIsCellLib,
                                    type = "%s",
                                    var = `me->event.event.keyin`);
                         break;
                     }

                     strcpy (me->asl_file.file_name, me->event.event.keyin);
   
                     /* 
                      *  Retrieve the cell library with the given file name.
                      */

                     ret_msg = gr$symretrieve_cell_library (
                               filename = me->asl_file.file_name,
                               file_no = &me->asl_file.file_no,
                               flag = EX_read_write | EX_read_only,
                               file_access = &me->asl_file.file_access,
                               fstat = EX_old_module);

                     if (ret_msg & 1)
                     {
                        me->state = DEFINE_LIB;
                     }else if (ret_msg == GR_E_NO_FILE)
                     {
                        me->state = CREATE_LIB;
                     }else if (ret_msg == GR_E_NOT_CELL_LIB)
                     {                     
                        ex$message(msgnumb = GR_E_PlsEntCelLib);
                        me->state = GET_LIB;
                     }else if (ret_msg == GR_E_NO_PREMISSION)
                     {
                        ex$message(msgnumb = GR_E_ErrFlProt);
                      }else
                     {
                        ex$message(msgnumb = GR_E_ErrFlAtch);
                     }
                  }
                  else 
                  {
                     ex$message(msgnumb = GR_E_PlsEntCelLib);
                     me->state = GET_LIB;
                  }
               }  /* end of STRING case */
               break;
            
               case EX_RESTART:
               case EX_BACK_UP:
               {
                  me->state = START;
               }
               break;

               case GR_UNKNOWN_TYPE:
               {
                  exit_code  = RETCONTROL;
               }
               break;
            }  /* End of case on event type */
         }  /* End of case GET_LIB */
         break;      
         
         case CREATE_LIB:
         {
            co$getevent(msg = &ret_msg, 
               event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
               msgnum = GR_P_FlNotExst, response = response, 
               response_data = response_data, event = &me->event);

            switch (me->event.response)
            {
               case STRING:
               {
                  strcpy (ans_string, me->event.event.keyin);

                  /* 
                   *  Call a function to parse the keyin.
                   */

                  GRparseyn (&ret_msg, ans_string, &flag);

                  if ((ret_msg & 1) && flag)
                  {
                     /* 
                      *  Create a symbol library with the specified
                      *  name.
                      */

                     ret_msg = gr$symretrieve_cell_library (
                               filename = me->asl_file.file_name,
                               file_no = &me->asl_file.file_no,
                               flag = EX_read_write,
                               file_access = &me->asl_file.file_access,
                               fstat = EX_new_module);

                     if (ret_msg & 1)
                     {
                        me->state = DEFINE_LIB;
                     }else if (ret_msg == GR_E_NO_PREMISSION)
                     {
                        ex$message(msgnumb = GR_E_ErrFlProt);
                        me->state = GET_LIB;
                     }else
                     {
                        ex$message(msgnumb = GR_E_ErrFlCrt);
                        me->state = GET_LIB;
                     }
                  }else if (ret_msg & 1)
                  {
                     /*
                      *  Do not create the file.  Thus restart the
                      *  command.
                      */
                     
                     me->state = START;
                  }else
                  {
                     ex$message(msgnumb = GR_E_PlsEntYN);
                  }                                 
               }  /* end of STRING case */
               break;
            
               case EX_RESTART:
               case EX_BACK_UP:
               {
                  me->state = START;
               }
               break;

               case GR_UNKNOWN_TYPE:
               {
                  exit_code  = RETCONTROL;
               }
               break;
            }  /* End of case on event type */
         }  /* End of case CREATE_LIB */
         break;
         
         case DEFINE_LIB:
         {
            /*
             *  Define the symbol library as the active symbol.
             *  The super is responsible for file mantainance.
             */

            om_msg = gr$symput_asl ( msg = &ret_msg,
                     file = &me->asl_file);

            if (!(om_msg & ret_msg & 1))
            {
               ex$message(msgnumb = GR_E_ErrEncCmdRst);
               me->state = GET_LIB;
               break;
            };

            ex$message (msgnumb = GR_I_CelLib,
                        type = "%s",
                        var = `me->asl_file.file_name`);

            /*
             *  A active symbol library was defined.  Then exit
             *  the command.
             */

            *response = TERMINATE;
            exit_code = RETCONTROL;   

         }  /* End of case DEFINE_LIB */
      }  /* end of state switch */
   }  /* End of while */

   if (exit_code == OMERROR)
   {
      me->state = START;
   }else
   {
      om_msg = OM_S_SUCCESS;
   }
   return(om_msg);
}
/***********************************************************************/
/*************************** init method  ******************************/
/***********************************************************************/

method init(int type;char *str_ptr)
{
IGRlong           ret_msg;
IGRint            size;

   me->state = START;
   me->init_success = TRUE;

   size = sizeof(struct GRmd_env);
   if (!gr$get_module_env(msg = &ret_msg, sizbuf = &size, 
      buffer = &me->ModuleInfo, nret = &size))
   {
      me->init_success = FALSE;
   }
   return(OM_S_SUCCESS);
}

end implementation COdefsymlib;
