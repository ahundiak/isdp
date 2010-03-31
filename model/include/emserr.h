# ifndef emserr_include
# define emserr_include 1

#include <stdio.h>

/* EMSerror, NOT_RELEASED, & needed for EMSmsgReport */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

/* EMSmsgReport */
# ifndef EMScmacros_include
# include "EMScmacros.h"
# endif

#ifndef EMMAXERRMSG_LEN
#define EMMAXERRMSG_LEN 30
#endif

/*** TEMPORARILY DEFINED HERE **/
#ifndef MSNOMEM
#define MSNOMEM -1
#endif

# if RELEASED
# define EFmsgReport(fp, sts, string) EMSerror (sts)
# endif

#define EMis_error(code) (EMSerror (code))

#define EMomerr_hndlr_action(stat, action, string)\
         if(EMSerror (stat))\
          {\
           if(stat != OM_W_ABORT)\
            {\
             EFmsgReport (0, stat, string); \
            }\
           stat=OM_E_ABORT;\
           action;\
          }

#define EMomerr_hndlr(stat,label,string)\
        EMomerr_hndlr_action(stat, goto label, string)


#define EMerr_hndlr_action(test, msg, code, action) \
         if (test)\
           {\
           msg = code;\
           action;\
           }

#define EMerr_hndlr(test, msg, code, label) \
        EMerr_hndlr_action (test, msg, code, goto label)

#define EMmserr_hndlr_action(stat, om_stat, action, string)\
         if(EMSerror (stat))\
          {\
             EFmsgReport (0, stat, string); \
             om_stat = OM_E_ABORT;\
             action;\
          }

#ifndef EMWRAPUP_STUFF
#define EMWRAPUP_OM(msg,status,str) \
          if(EMSmsgReport ((status), (str), 0) && EMSokay (msg)) \
            (msg) = EMS_E_OMerror;

#define EMWRAPUP_MSG(msg,status,str) \
          if(EMSmsgReport ((msg), (str), 0) && EMSokay (status)) \
            (status) = OM_E_ABORT;

#define EMWRAPUP(msg,status,str) \
          EMWRAPUP_OM((msg),(status),(str)) \
          EMWRAPUP_MSG((msg),(status),(str))

#define EMWRAPUPI(msg,status,str) \
          EMWRAPUP_OM((msg),(status),(str)) \
          EMWRAPUP_MSG((msg),(status),(str)) \
	  if(EMSerror((msg)) || EMSerror((status))) \
	    fprintf(stderr, "MY ID = %d\n", my_id);
#endif

#endif
