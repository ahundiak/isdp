/*****************************************************************************

 Description :

 DPB related macros in EMS.

 Creation :

 Vadiraj M.R. - long ago.

****************************************************************************/
#ifndef EMSdpb_func_macros
#define EMSdpb_func_macros

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) ()
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
#ifndef igetypedef_include
#include "igetypedef.h"
# endif
#ifndef gr_include
#include "gr.h"
# endif
#ifndef go_include
#include "go.h"
# endif
#ifndef exdef_include
#include "exdef.h"
# endif
#ifndef ex_include
#include "ex.h"
# endif
# ifndef emsdef_include
#include "emsdef.h"
# endif
# ifndef griodef_include
#include "griodef.h"
# endif
#ifndef grio_include
#include "grio.h"
# endif
#ifndef godef_include
#include "godef.h"
# endif
#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"
# endif
# ifndef emserr_include
#include "emserr.h"
# endif
#ifndef EMSdpb_include
#include "EMSdpb.h"
# endif

extern IGRint EMdpb_get __((IGRlong *EMmsg, IGRlong parameter,
                            IGRuchar *buffer));

extern IGRint EMdpb_getinfo __((IGRlong *EMmsg, struct EMdpbinfo *dpbinfo));
#if defined(__cplusplus)
}
#endif

#undef __

/****************************************************************************

       Description :

       This macro when supplied with the dpb parameter interested in, gets
       the value of the same in the buffer supplied. Note that the dpb
       parameter that is returned is that of the current module.

       ARGUMENTS :

       IGRlong *msg       -  Output:
                             Message return code.
                             Upon exit the completion code will be one
                             of the following:
                             -EMS_S_Success : if successful,
                             -EMS_E_InvalidArg : if invalid arguments.

       IGRlong parameter  -  Input:
                             The dpb parameter whose value is wanted.

       IGRuchar *buffer   -  Output:
                             The value of the dpb parameter above, is
                             returned in this buffer. 
****************************************************************************/
#omdef ems$dpb_get (msg,
                    parameter,
                    buffer)
EMdpb_get ((msg), (parameter), (buffer))
#endomdef

/***************************************************************************

         Description :

         This macro gets the entire dpb information into the structure 
         EMdpbinfo.  
         The structure definition exists in the include file "EMSdpb.h".

         ARGUMENTS :

         IGRlong *msg    -  Output:
                            Message return code.
                            -EMS_S_Success : if successful,
                            -An OM error-code : in case of failure.  

         struct EMdpbinfo *dpbinfo
                         -  Output:
                            Structure containing the entire dpb
                            information.
***************************************************************************/
#omdef ems$dpb_getinfo (msg,
                        dpbinfo)
EMdpb_getinfo ((msg), (dpbinfo))
#endomdef

#endif
