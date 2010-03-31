/* ###################   APOGEE COMPILED   ################## */
class specification ECnatsides (1:0) of super_cmd;

/*
ABSTRACT

Construct a solid from two surfaces and the natural sides between
the two surfaces, unless the surface are closed (and will produce
no natural sides), in which case an appropriate solid boolean is
performed.

USER INTERFACE

- 1) Identify surface 1.

- 2) Identify surface 2.

- 3) Restart at step 1.

INSTANCE

locatedElement, locatedEnv:  a located element and its environment.

NOTE

This is just a kluge until ci starts cooperating.

HISTORY

07 Jun 1988 jBk Changed instance variable eliclass to an array.
17-May-1988 jBk Changed abstract to reflect the change of the
                target from composite surface to solid.
 1-Feb-1988 jBk Genesis.
*/

# include "igr.h"
# include "igetypedef.h"
# include "gr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"

instance ECnatsides
{
    IGRshort layer;                             /* current layer */
    struct GRmd_env env;                        /* current env */
    struct IGRdisplay display;                  /* current display */
    struct GRid locatedElement[2];
    struct GRmd_env locatedEnv[2];
    IGRchar                 action;             /* action to take */
    struct    GRlc_locate   attr;               /* locate attr */
    struct    GRlc_stack    locate_stack;   /* stack for locate filter */
    OM_S_CLASSLIST rtree_classes, elig_classes; /* for locations */
    OMuword        rclass, eliclass[2];         /* for locations */
};

override init;
/*
MOTIVATION

To initialize action to be 2.

FILE

ECnatsidesi.I
*/

override sleep;
/*
MOTIVATION

To erase highlight plane.

FILE

ECnatsidesi.I
*/

override wakeup;
/*
MOTIVATION

To get current layer, display and environment; to redisplay
highlighted elements.

FILE

ECnatsidesi.I
*/

override execute;
/*
MOTIVATION

I override this method because I have defined this class' unique
finite state machine via the execute method.

FILE

ECnatsidesi.I
*/

end specification ECnatsides;
