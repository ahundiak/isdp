/* $Id: VRiso.sl,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/$ROUTE
 *
 * File:  vriso/VRiso.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRiso.sl,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.5  1997/02/02  22:39:10  pinnacle
# Replaced: vriso/VRiso.sl for:  by kddinov for route
#
# Revision 1.4  1997/01/21  16:08:08  pinnacle
# Replaced: vriso/VRiso.sl for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/03/21  23:23:08  pinnacle
# Replaced: vriso/VRiso.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/17  00:08:22  pinnacle
# Replaced: vriso/VRiso.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:22:06  pinnacle
# Replaced: vriso/VRiso.sl for:  by r240_int for route240
#
 *
 * History:
 *   31-Oct-91  1.4.3.7  
 *
 *    Bruno
 *    - Remove the ex$get_path and call the VR$GetUnixPath
 *      macro.
 *    - "config/iso/..." names are no longer hardcoded any
 *      where but defined in the .h file.
 *    - In form_notification, refuse design filenames with
 *      an extension.
 *
 *  12/06/95  tlb  Remove VRcmd.h
 *  01/15/96  tlb  Add VX_FIproto.h, prototypes
 *  10/05/96  KDD  Add NQS batch job capability. 
 *
 *************************************************************************/

command_string       VRC_M_ExIsDr,0,VRExIsDr
class                VRiso
super_class          CEO
product_name         "$ROUTE"
command_table        "route.cmd"
start_state          start

form "VRisogen" ,MAIN,1,"-1","-1"
form "VRiso_crit",SUB ,0,"0","0"

specification

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "VRGlobMac.h"
#include "big.h"
#include "dbs.h"
#include "ISOformdef.h"
#include "FI.h"
#include "VRmsg.h"

#include "AS_status.h"

char    user_mail[PATH_MAX];
char    QUEUE[PATH_MAX];

#define AS_DEBUG 1
extern  GRclassid  OPP_user_data_class_id; 


/* instance variables for form control */


instance
{
   struct GRid        attr_grid;
   struct ISOform     isoform;   
   IGRlong            init_status;
}

implementation

#include <stdio.h>
#include "OMerrordef.h"

#include "exmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "FI.h"
#include "dp.h"
#include "dpmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"

#include "big.h"
#include "dbs.h"
#include "VRmsg.h"

#include "COBmacros.h"
#include "AS_status.h"
#include "vriso_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG 1
/*
#define MY_DEBUG 1
*/
#define DEBUG 1
#define MAIN 0
#define SUB 1
#define FORM_NAME ":IGENOD:iso.extract"
     
extern  GRclassid  OPP_user_data_class_id;
extern	char    user_mail[];
extern	char    QUEUE[];
 
from NDnode import NDdisplay;

/**********************************************************/

state_table

#include "VRmsg.h"

#define MAIN 0
#define SUB 1
#define DEFINE 1

state start
   message_key    VR_M_ExIsDr
   prompt    "Key in file names"
   filter      wfi
     

   on TERMINATE
      do erase_form MAIN
      do erase_form SUB
      state terminate



/***********************************************************/

action init
/*.init*/
{
  struct GRid   VRap_co;
  OM_S_OBJID    mod_id;
  char          path_name[PATH_MAX];
  char          file_name[PATH_MAX];
  IGRlong       retmsg;
  IGRint        sts;

  /*|VRiso: init entry \n */
   me->isoform.index_crit = 0;
   me^^CEO.ret = MSSUCC;
   me^^VRiso.init_status = OM_S_SUCCESS;
   dp$erase_hilite(msg=&status); 
   status = om$send (mode = OM_e_wrt_message,
                     msg = message CEO.init( type, str_ptr ),
                     targetid = my_id);
   if (! (status & OM_S_SUCCESS))
   {
      printf("VRiso: failure sending init\n");
      me^^VRiso.init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }
   /*|VRiso: in init, calling VRiso...\n*/

   me->init_status = ex$get_cur_mod (id = &mod_id,
                                  osnum = &me->attr_grid.osnum );

/*******************************************************************************
* KDD 06-NOV-96  NQS
*
* QUEUE	= NONE		(default) no queue available,abort "Extract Iso" command
*	= ISOGEN 	Isogen product installed locally 
*	= NT_IsoBatch 	pipe queue connected to isogen batch queue on NT server
*	= Unix_IsoBatch pipe queue connected to isogen batch queue, Unix server
*******************************************************************************/
   strcpy(QUEUE, "NONE"); 

   if ( ! system("qstat NT_IsoBatch | grep ENABLED >> /dev/console") ) {
        strcpy(QUEUE, "NT_IsoBatch");
        goto queue_found;
   } 

   if ( ! system("qstat Unix_IsoBatch | grep ENABLED >> /dev/console") ) {
	strcpy(QUEUE, "Unix_IsoBatch"); 
        goto queue_found;
   }  

   sts = VR$GetUnixPath (msg = &retmsg,
                product_name = VR_ISO_PROD_NAME,
                   file_path = VR_ISO_KSH_NAME,
                product_path = file_name,
            product_path_len = sizeof (file_name)  );

   if ( !(sts & OM_S_SUCCESS) ) {
     UI_status("Neither pipe queue nor Isogen product found (see NQShelp.doc)");
     FIfld_set_text( me^^CEO.forms[0].form_ptr, MESSAGE_FIELD, 
         0, 2,"Neither pipe queue nor Isogen product found(see NQShelp.doc)",0);
     printf("product isogen not found\n");
     me^^VRiso.init_status = OM_E_ABORT;
     return OM_E_ABORT;
   }
   else { 
     strcpy(QUEUE, "ISOGEN");
   }

queue_found:

   status = ISOinit_main  ( &(me->isoform));
   if (! (status & OM_S_SUCCESS))
   {
     printf("error in ISOinit_main\n");
     me^^VRiso.init_status = OM_E_ABORT;
     return OM_E_ABORT;
   }

   status = ISOinit_sub(&(me->isoform));
   if (! (status & OM_S_SUCCESS))
   {
     printf("error in ISOinit_sub\n");
     me^^VRiso.init_status = OM_E_ABORT;
     return OM_E_ABORT;
   }

   /*|apres init_sub\n*/
   me->init_status =
   om$send( targetid = my_id,
              mode   = OM_e_wrt_message,
              msg    = message VRiso.update_form (&status, &(me->attr_grid)));

   /*|after send update_form\n*/

   status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
                           pathname = path_name );
   /*"pathname: %s\n",path_name*/

   if ( status != DIR_S_SUCCESS )
   {
     /*| error in di$give_pathname\n*/
     di$report_error( sts = status,  comment = "error in give pathname" );  
     return ( OM_E_ABORT );
   }

   strcat( path_name, FORM_NAME );

#ifdef MY_DEBUG
   printf ("pathname: %s\n",path_name);
#endif

   status = di$translate ( objname = path_name,
                           osnum   = OM_Gw_TransOSnum_0,
                           p_objid = &VRap_co.objid,
                           p_osnum = &VRap_co.osnum );
#ifdef MY_DEBUG
   printf (" translate: %d, %d\n",VRap_co.objid,VRap_co.osnum);
#endif

   if ( status != DIR_S_SUCCESS )
   {
     /*| fail in di$translate\n*/

     if ( status == DIR_W_NAME_NOT_FOUND )
     {

       /*|DIR NAME NOT FOUND: so trying to create my entry\n\n*/

       status = di$add_name( objname = path_name,
                             objid   = my_id,
                             osnum   = OM_Gw_TransOSnum_0 );

       if ( status != DIR_S_SUCCESS )
       {
         /*|fail in add_name\n*/
         di$report_error( sts     = status,
                          comment = "Error : di$add_name" );
       }
     }
     else
     {
       /*|other than DIR NAME NOT FOUND\n*/
       di$report_error( sts     = status,
                        comment = "VRiso: Unable to find my entry\n" );
     }
  }
  else
  if ( VRap_co.objid != my_id )
  {
   /*| VRiso ( translate de pathname) !=my_id\n */
   /*" VRiso : %d, my_id: %d\n",VRap_co.objid,my_id*/
  }
  
  goto quit;
} 

/*********************************************************/

action update_form( int  * sts;
             struct GRid * attr_grid )
/*.update_form*/
{

  status = OM_S_SUCCESS;

  me->attr_grid.objid = attr_grid->objid;
  me->attr_grid.osnum = attr_grid->osnum;

  me->init_status = ISOupdate_main( me^^CEO.forms[MAIN].form_ptr, 
                                    &(me->isoform) );
  *sts = me->init_status;
  me->init_status = ISOupdate_sub( me^^CEO.forms[SUB].form_ptr, 
                                    &(me->isoform) );
 
  *sts = me->init_status;
  /*|VRiso: exit update form action\n\n*/

  goto quit;
}
/*********************************/
action wakeup
/*.wakeup*/
{

   me^^CEO.ret = MSSUCC;
   me->init_status = OM_S_SUCCESS;
   status = om$send (mode = OM_e_wrt_message,
                      msg = message CEO.wakeup (pos),
                 targetid = my_id);
   if (! (status & OM_S_SUCCESS))
   {
      printf("isogen: failure sending wakeup\n");
      me->init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }

   goto quit;
}

/**********************************************************/
action delete
/*.delete*/
{
   int     sts;

   dp$erase_hilite(msg=&sts);
   status = om$send( targetid = my_id,
                       mode   = OM_e_wrt_message,
                       msg    = message Root.delete ( 0 ));

   if (! (status & OM_S_SUCCESS))
   {
      printf("isogen: failure sending delete\n");
      me->init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }

   goto quit;
}
/****************************************************************/

action sleep
/*.sleep*/
{
   int     sts;
   me^^CEO.ret = MSSUCC;
   dp$erase_hilite(msg=&sts);
   me->init_status = OM_S_SUCCESS;
   status = om$send (mode = OM_e_wrt_message,
                     msg = message CEO.sleep (pos),
                     targetid = my_id);
   if (! (status & OM_S_SUCCESS))
   {
      printf("isogen:failure sending sleep\n");
      me->init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }

   goto quit;
}



/**********************************************************************/
/* form_notification -                  */
/*   Override of CEO method for handling input from new C-based  forms.*/
/**********************************************************************/
action form_notification  (int form_label;int gadget_label; double value;
                 char   *form_ptr )       extern

