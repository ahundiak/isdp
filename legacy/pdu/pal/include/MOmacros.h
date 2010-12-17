/* MOLD macros include file */

#include	<stdio.h>
#include	"PDUerror.h"

#define _MO_omerr_chk(mess,sta,label) 				\
	{ 							\
	   if (!(sta &1)) 					\
	   { 							\
		PDUmessage (PDM_E_FAILURE, 's');		\
		_pdm_debug ("OM Error - %s", mess);		\
		_pdm_debug ("OM Status = %d\n", sta); 		\
	      	goto label; 					\
	    } 							\
	}

#define _MO_emerr_chk(mess,sts,label) 				\
	{ 							\
	   if (!(sts & 1)) 					\
	   { 							\
		PDUmessage (PDM_E_FAILURE, 's');		\
		_pdm_debug ("OM Error - %s", mess);		\
		_pdm_debug ("OM Status = %d\n", sts); 		\
	      	goto label; 					\
	    } 							\
	}

#define CHAMFER_LIMIT 0.0
