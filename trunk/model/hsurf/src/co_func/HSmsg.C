
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

#include <stdio.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hsmacdef.h"
#include "hsmsg.h"
#include "msmacros.h"
#include "msdef.h"
#include "exmacros.h"
#include "exdef.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_co_func.h"


#if defined(__STDC__) || defined(__cplusplus)
	HSfile_error( int status )
#else
	HSfile_error(status)
	int status;
#endif

{
  switch(status)
    {
     case 1:  ex$message ( msgnumb = HS_E_ErrOpenFile,
                   field = ERROR_FIELD);
              break;
     case 2:  ex$message ( msgnumb = HS_E_ErrWriteFile,
                   field = ERROR_FIELD);
              break;
     case 3:  ex$message ( msgnumb = HS_E_ErrAllocMem,
                   field = ERROR_FIELD);
              break;
     case 4:  ex$message ( msgnumb = HS_E_ErrClosFile,
                   field = ERROR_FIELD);
              break;
     case 5:  ex$message ( msgnumb = HS_E_ErrLocFile,
                   field = ERROR_FIELD);
              break;
     case 6:  ex$message ( msgnumb = HS_E_ErrReadFile,
                   field = ERROR_FIELD);
              break;
     case 7:  ex$message ( msgnumb = HS_E_ErrLimitHit,
                   field = ERROR_FIELD);
              break;
     case 8:  ex$message ( msgnumb = HS_E_ErrReservChar,
                   field = ERROR_FIELD);
              break;
     case 9:  ex$message ( msgnumb = HS_E_ErrIncmpTerm,
                   field = ERROR_FIELD);
              break;
     default: break;
    }
  sleep(3);

  ex$message (field=MESSAGE_FIELD, justification=LEFT_JUS,in_buff="");
  return(0);
}    


#if defined(__STDC__) || defined(__cplusplus)
	HSget_msg( int which_one,
		  char message[],
		  char insert[] )
#else
	HSget_msg( which_one, message, insert )
	int which_one;
	char message[], insert[];
#endif

{
  switch ( which_one )
   {
    case 1:
       ex$message ( msgnumb = HS_I_ReadyToRecall,
                    buff = message );
       break;
    case 2:
       ex$message ( msgnumb = HS_I_LoadingImages,
                    buff = message );
       break;
    case 3:
       ex$message ( msgnumb = HS_I_ExitRecallImg,
                    buff = message );
       break;

    case 4:
       ex$message ( msgnumb = HS_I_TooManyPlanes,
		    buff = message );
       break;
 
    case 5:
       ex$message ( msgnumb = HS_I_ReadyToAnimate,
		    buff = message );
       break;
	
    case 8:
	ex$message ( msgnumb = HS_I_Not10Not15, type="%s", var=`insert`,
		     buff = message );
	break;

    case 9:
	ex$message ( msgnumb = HS_I_Directory,  type="%s", var=`insert`, 
		     buff = message );
	break;
   
    case 10:
 	ex$message ( msgnumb = HS_I_DynBuffFull, buff=message );

	break;

    case 12:
       ex$message ( msgnumb = HS_I_ModeActVal, type="%s", var=`insert`,
		    buff = message );
	break;

    case 13:
       ex$message ( msgnumb = HS_I_ModeElemVal, type="%s", var=`insert`,
		    buff = message );
	break;

    case 14:
       ex$message ( msgnumb = HS_I_RenderMixup, buff = message );
	break;

    case 15:
       ex$message ( msgnumb = HS_I_RendFileTooBig, type="%s", var=`insert`,
		    buff = message );
	break;

    default:
	
	break;

  }
 return(0);
}

#if defined(__STDC__) || defined(__cplusplus)
	HSdisplay_memory_realloc_message(void)
#else
	HSdisplay_memory_realloc_message()
#endif

	{
	ex$message( 
		field   = ERROR_FIELD, 
		msgnumb = HS_I_ZReSize );
	}
	
#if defined(__STDC__) || defined(__cplusplus)
	HSerase_memory_realloc_message(void)
#else
	HSerase_memory_realloc_message()
#endif

	{
	ex$message( 
		field   = ERROR_FIELD, 
		in_buff = "" );
	}


#if defined(__STDC__) || defined(__cplusplus)
	HSdisplay_update_message( IGRuchar style )
#else
	HSdisplay_update_message( style )

	IGRuchar style;
#endif

	{
	IGRint msg_no;
	IGRchar buffer[100];

	switch ( style )
	   {
	   case HS_STYLE_SMOOTH :
	      msg_no = HS_I_SmoothDispInProg;
	      break;

	   case HS_STYLE_CONSTANT :
	      msg_no = HS_I_ConstDispInProg;
	      break;

	   case HS_STYLE_RASTER :
	      msg_no = HS_I_RHLDispInProg;
	      break;

	   case HS_STYLE_FILLED_RASTER :
	      msg_no = HS_I_FRHLDispInProg;
	      break;

	   default:
	      msg_no = HS_I_DispInProg;
	      break;
	   }

	ex$message( msgnumb = msg_no, buff = buffer );
	HSinit_heartbeat( buffer );
	}

