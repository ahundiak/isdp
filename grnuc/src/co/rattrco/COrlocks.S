class specification COrlocks (1:0) of CEO;



/******************************************************************************

Description:		This command provides the user interface for the 
			following commands:

		1. set raster transparency on  
		2. set raster transparency off
		3. set raster fast display 
		4. set raster regular display
		5. set raster border display on
		6. set raster border display off
		7. set raster grid line on
		8. set raster grid line off
		9. set auto define on
		10.set auto define off
		11.set fill mode on
		12.set fill mode off

Abstract class:		No.

Messages:
	
	message toggle_lock(int * sts);

History:	jay wallingford	11/21/87	Design and implementation
                scott walters   07/14/92        Ansi conversion

Bugs:		No know bugs.

Algorithm:	

Notes:

    COMMAND TABLE ENTRIES FOR GRSetTran:
   -----------------------------------------------------------------
    cmd_str                       cmd_t       cmd_key        cmd_class  
   --------------------------------------------------------------------        
    set raster transparency on    GRSetTrnOn  1              COattr
   --------------------------------------------------------------------
    set raster transparency off   GRSetTrnOf  2              COattr
   --------------------------------------------------------------------
    set raster fast display       RSSCnDsPTF  3              COattr
   --------------------------------------------------------------------
    set raster regular display    RSSCnDsPTR  4              COattr
   --------------------------------------------------------------------
    set raster border display on  RSTOnCBDP  5              COattr
   --------------------------------------------------------------------
    set raster border display off RSTOfCBDP  6              COattr
   --------------------------------------------------------------------
    set raster grid line on       RSTrOnCnGr  7              COattr
   --------------------------------------------------------------------
    set raster grid line off      RSTOnCGLDP  8              COattr
   --------------------------------------------------------------------
    set auto define on            RSTrOnAtCn  9              COattr
   --------------------------------------------------------------------
    set auto define off           RSTrOfAtCn  10             COattr
   --------------------------------------------------------------------
    set fill mode on              RSTrOnCnFl  11             COattr
   --------------------------------------------------------------------
    set fill mode off             RSTrOfCnFl  12             COattr
   --------------------------------------------------------------------
   
*******************************************************************************/

#include <grmessage.h>
#include <ctype.h>
#include <ODE.h>
#include <msdef.h>
#include <msmacros.h>
#include <igrdef.h>
#include <igrdp.h>
#include <gr.h>
#include <godef.h>
#include <go.h>
#include <griodef.h>
#include <grio.h>
#include <griomacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <bsvalues.h>
#include <dpdef.h>
#include <wl.h>
#include <igecolor.h>
#include <igecolmacros.h>
#include <OMerrordef.h>
#include <exmacros.h>
#include <COerr.h>
#include "COrlocksdef.h"




message toggle_lock ( long * sts );

end specification COrlocks;
