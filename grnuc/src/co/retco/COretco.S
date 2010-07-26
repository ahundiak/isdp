class specification COretco (1:0) of CEO;



/******************************************************************************

Description:		This class supports the RetOptFrm form.

Abstract class:		No.

Override methods:	None.

Messages:
	message set_options();
	message set_gadgets();

History:		jay wallingford	8/12/88	1.2.0	Creation

Bugs:			No know bugs.

Algorithm:	

Notes:			
			
******************************************************************************/

#include "coimport.h"
#include <stdio.h>
#include <ctype.h>
#include <OMerrordef.h>
#include <msdef.h>
#include <msmacros.h>
#include <igr.h>
#include <igrdp.h>
#include <grmessage.h>
#include <gr.h>
#include <ODE.h>
#include <FI.h>
#include "COretcodef.h"
#include <ex.h>
#include <exdef.h>
#include <execmsg.h>
#include <sys/types.h>
#include <toolco.h>

#define MAX_FILENAME_LEN 132
#define MAX_COMMAND_LEN  40


instance COretco
{
    char filename[MAX_FILENAME_LEN];
    char seedfile[MAX_FILENAME_LEN];
    char firstcmd[MAX_COMMAND_LEN];
    int  create;
};


message set_options ();

message set_gadgets ();

override form_notification;

end specification COretco;
