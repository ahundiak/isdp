# ifndef ECjbk_include
# define ECjbk_include 1

# define CanAcceptWithAnything 0
# define APPROVE_IS_DATA 1
# define NO_OBJECT_EVENT 1

# ifndef grutil_include

/* grutil.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

/* end of grutil.h replacement */
# endif

# ifndef EMSlogic_include
#   include "EMSlogic.h"
# endif

# if APPROVE_IS_DATA
#   ifndef APPROVE
#       define APPROVE DATA
#   endif
#   ifndef GRm_APPROVE
#       define GRm_APPROVE GRm_DATA
#   endif
# else
#   ifndef APPROVE
#       define APPROVE MOVE_ON
#   endif
#   ifndef GRm_APPROVE
#       define GRm_APPROVE GRm_MOVE_ON
#   endif
# endif

# ifndef REJECT
# define REJECT RESET
# endif
# ifndef GRm_REJECT
# define GRm_REJECT GRm_RESET
# endif

# if NO_OBJECT_EVENT
#   ifndef IS_OBJECT
#       define IS_OBJECT(X) ((X) IS DATA || (X) IS STRING)
#   endif
#   ifndef GRm_OBJECT
#       define GRm_OBJECT (GRm_DATA | GRm_TEXT_VALUE)
#   endif
# else
#   ifndef IS_OBJECT
#       define IS_OBJECT(X) ((X) IS OBJECT)
#   endif
# endif

# define STATUS_BUF_SIZE 53
# define MAX_STATUS_SIZE STATUS_BUF_SIZE

# endif /* ECjbk_include */
