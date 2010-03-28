/*----
     CHANGE HISTORY:

     ch-jla  07/10/86   : Design date
----*/

class implementation COpara;

#include "msmacros.h"
#include "ASmessages.h"
#include "grmsg.h"
#include "grdpbmacros.h"

/* 
   return active display and level 
*/

  ASget_active_symb(level,display)
  struct IGRdisplay *display;
  IGRshort *level;
   {
    IGRlong NumberOfBytes;
    IGRlong BytesReceived;
    IGRlong msg;
 
    /*
     *  get the default symbology data from the DPB
     */
    NumberOfBytes = sizeof( *level);
    gr$get_active_level(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = level,
            nret = &BytesReceived);

    if ( COERROR( msg)) return (OM_W_ABORT);


    /*
     *  get the default display symbology data from the DPB
     */
    NumberOfBytes = sizeof( *display);
    gr$get_active_display(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = display,
            nret = &BytesReceived);

    if ( COERROR( msg)) return (OM_W_ABORT);
  return( OM_S_SUCCESS);
 }


/*
 *  init method   
 */
method init ( int type; char *string_ptr)

{
    IGRlong msg;
    IGRlong NumberOfBytes;
    IGRlong BytesReceived;

#define NIL             0
#define ERR             1
#define INITIAL_STATE   2

    /* construct super_para if necessary */ 

     ASsuper_construct();
    

   /* type of command from command table */

    me->mytype = type;

    /*
     *  get the module env from the DPB
     */
    NumberOfBytes = sizeof( me->ModuleInfo);
    gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &me->ModuleInfo,
                nret = &BytesReceived);
    if ( COERROR( msg)) return (OM_W_ABORT);

    /*
     *  get the default database type from the DPB
     */

    NumberOfBytes = MAX_DB_TYPE_SIZE;
    gr$get_database_type(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer =  me->DatabaseType,
                nret = &BytesReceived);
    if ( COERROR( msg)) return (OM_W_ABORT);

    /*
     *  set the state to be 0.  this should work for MOST command objects
     *  the action is set to 2.  by common consent, NIL and ERR actions
     *  are NIL = 0, and ERR = 1.
     */
    me->state = NIL;
    me->action = INITIAL_STATE;
    me->locate_stack.num_entries = 0;

    /*
       Initialize default locate message
    */

    ex$message( buff =  me->loc_prompt, msgnumb = GR_P_IdEle);
    ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej);
    ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);


    /*
       initialisation for locate
    */
   
    strcpy(me->attr.classes, "GRgraphics");
    me->attr.properties =  LC_DP_ONLY | LC_LC_ONLY | LC_RW;

    me->attr.owner_action = LC_RIGID_COMP
			  | LC_RIGID_OWNER | LC_FLEX_COMP 
		  	  | LC_FLEX_OWNER  | LC_REF_OBJECTS;


    return ( OM_S_SUCCESS);
}



/*
 *  COpara sleep method
 */
method sleep ( int pos)
{
 UI_prompt( "");
 UI_message( "");

 return( OM_S_SUCCESS);
}


end implementation COpara;
