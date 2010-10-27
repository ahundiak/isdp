/* $Id: VDgetAttDrSy.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddgninfo/func/VDgetDgnPar.I
 *
 * Description:
 *      those functions are used for Design Setup parameter command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgetAttDrSy.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/07/08  16:11:24  pinnacle
# Created: vddgninfo/func/VDgetAttDrSy.I by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	06/01/97	yzhu		create
 ***************************************************************************/

class implementation Root;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vddgndef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "vderrmacros.h"
#include "v_drwproto.h"
#include "v_drw.h"
#include "v_drwmacros.h"

 /* ----------------------------------------------------------------------
 */

from  ACrg_collect	import  ACget_attribute_at_index;
from  NDmacro		import  ACgive_structure;

/*
 * ----------------------------------------------------------------------
 */

long   VDgetAttDrSymbInfo(msg, attDrSymbStatus, support_file )

long			*msg;			/* Return message	*/
int 			*attDrSymbStatus;	/* status of symb driven*/
char 			*support_file;		/* status of symb driven*/

{
long			status;
IGRint                  rc ,
                        dirIndex = -1;
struct  ret_struct      retStr ;
GRname                  AttrName;
GRname                  AttrStatus;
struct GRid             collId;
struct GRmd_env         mdEnv ;


     SetProc( VDgetAttDrSymbInfo ); Begin

     *msg = MSSUCC;
     *attDrSymbStatus  = -1;

     /*
      * Get the collector.
      */
     collId.objid = NULL_OBJID ;
     status =
     VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
     if( ! (status&*msg&1)){
	 /*
          * stop processing. There is something wrong.
          */
         *msg = MSFAIL ;
         goto wrapup ;
     }

     /* get support file name */
     strcpy( AttrName, "symbDrFile" );

     status = _VD_SEND_OBJN(       collId,
                        NDmacro.ACgive_structure( &rc, &dirIndex, AttrName,
                                                  &retStr, &mdEnv ));


     if(( ! (status&rc&1 )) ||
           ( !strcmp (retStr.var.text_st.text_string, VD_UNDEFINED_STR) ))
     {
           *msg = MSFAIL ;
           goto wrapup;
     }
     else   {
       strcpy ( support_file,  retStr.var.text_st.text_string) ;
     }

     /* get attribute driven symbology status */
     strcpy( AttrStatus, "symbDrStatus"  );

     status = _VD_SEND_OBJN(       collId,
                        NDmacro.ACgive_structure( &rc, &dirIndex, AttrStatus,
                                                  &retStr, &mdEnv ));
     if(( ! (status&rc&1 )) ||
           ( !strcmp (retStr.var.text_st.text_string, VD_UNDEFINED_STR) ))
     {
           *msg = MSFAIL ;
           goto wrapup;
     }
     else   {
       *attDrSymbStatus = atoi( retStr.var.text_st.text_string) ;
     }

     if( support_file[0] == '\0' || *attDrSymbStatus != 1) {
                        *msg = MSFAIL ;
                        status = MSFAIL ;
     }   
wrapup:
     End
     return status;
} /* VDgetAttDrSymbInfo */

/*
 * ----------------------------------------------------------------------
 */

long   VDsetAttDrSymb(msg, objId, md_env, output )
long                    *msg;                   /* Return message       */
struct GRid             objId;			/* (IN) object id/os    */
struct GRmd_env         *md_env ;		/* (IN) modulao env     */
VD_drwOutputData        *output;                /* (OUT) output data    */
{
int                     status, attDrSymbStatus;
GRname                  filename;

     SetProc( VDsetAttDrSymb ); Begin
     output = NULL;

     /* get attribute driven symbology */
     status =
     VDgetAttDrSymbInfo(msg, &attDrSymbStatus, filename );

     if( !(status&*msg&1)) goto wrapup;
     if( attDrSymbStatus != 1) {
	*msg = MSFAIL;
	goto wrapup;
     } 

     /* call parser */
     status =
     vd_$drwExecSymbology(      msg = msg,
                                elmId = &objId,
                                elmEnv = md_env ,
                                filename = filename,
                                output = &output );

wrapup:
     End
     return status;
}

end implementation Root;

