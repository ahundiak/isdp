/* ###################   APOGEE COMPILED   ################## */
class implementation ECrmDjRg;

/*
HISTORY
06/04/91    DLB Support current_creator.
15 Feb 1989 jBk Genesis.
*/

# ifndef DEBUG
# define DEBUG 0
# endif


# if DEBUG
#   include <stdio.h>

#   include "EMScmacros.h"

extern int EFfprints ();

#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPS(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMR(rc, string)
#   define EMSdbgEPS(string)
# endif

/* EMSokay; EMSerror for EMSmsgReport */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

/* EMSmsgReport */
# ifndef EMScmacros_include
# include "EMScmacros.h"
# endif

/* typedef EMSrc */
# ifndef EMStypedef_include
# include "EMStypedef.h"
# endif

/* dp$erase_hilite */
# ifndef dpmacros_include
# include "dpmacros.h"
# endif

/* lc$locate */
# ifndef lcmacros_include
# include "lcmacros.h"
# endif

/* GR_w_novalue */
# ifndef griodef_include
# include "griodef.h"
# endif

# include "msdef.h"     /* definitions for ex$message */
# include "msmacros.h"  /* ex$message */

# include "igetypedef.h"    /* for gr.h */
# include "igrtypedef.h"    /* for gr.h, igrdp.h, igr.h and ex.h */
# include "igr.h"           /* for grio.h, go.h and igrdp.h */
# include "igrdp.h"         /* for go.h */
# include "gr.h"            /* for go.h */
# include "madef.h"         /* for godef.h */
# include "godef.h"         /* for go.h */
# include "go.h"            /* for grio.h */
# include "ex.h"            /* for griomacros.h and grio.h */
# include "griodef.h"       /* for grio.h */
# include "grio.h"          /* for co$getevent */
# include "griomacros.h"    /* co$getevent */

# include "EMSmsgdef.h"     /* EMS_S_Success */

# include "EMS_I.h"
# include "EMS_M.h"
# include "EMS_P.h"
# include "EMS_E.h"

from EMSsurface import EMgetContiguousAreas;
from EMSsfboolean import EMdelDisjAreas;

# define ME_locEvent (me^^ECelement.locev)
# define ME_locObject (me^^ECelement.locev.located_object[0].located_obj)
# define ME_locEnv (me^^ECelement.locev.located_object[0].module_info)

method delete (int f_defer_flag)
{
    extern EMSrc EFtreeEnd ();

    (void)EFtreeEnd (me^^ECrmDjRg.p_gathered);
    (void)EFtreeEnd (me^^ECrmDjRg.p_iterated);
    (void)EFtreeEnd (me^^ECrmDjRg.p_marked);

    return om$send (
        mode = OM_e_wrt_parent,
        msg = message ECrmDjRg.delete (f_defer_flag),
        targetid = my_id
    );
}

method execute (int *response; char *response_data; int pos)
{
    enum TransitionTypes
    {
        choiceT, enoughT, epsilonT, locateT, loopT, marksT,
        queueT, whenT 
    };
    
/*
NOTE

Init must be the first action or at least the action equivalent
to zero because this helps save us from needing an init method
override in order to initialize me^^ECrmDjRg.action.
*/

    enum actions
    {
        Init, AllMk, AProm, AqDjA, Back, Clean, CndEM, CndHM,
        CondE, CondH, ErRet, Err, High, HighM, MProm, Mark, Nil,
        None, One, Ret, RmDjA, Show, UDraw, UShow, UnHi, UnHiL,
        UnHiM, UnHiP
    };

/*

AllMk -- inform user all regions in the model are marked.

AProm -- let user see currently highlighted marked regions before
prompting user to accept or reject their removal.  [Really, Nil.]

AqDjA -- aquire disjoint areas (regions).

Back -- backup to previous region, unmarking it if necessary.

Clean -- free memory; return to initial state.

CndEM -- conditionally un-highlight all marked regions.  [Really,
always erase highlight plane.]

CndHM -- conditionally re-highlight all marked regions.  [Really,
always re-highlight all marked regions.]

CondE -- conditionally un-highlight current region.  [Really,
always erase highlight plane.]

CondH -- conditionally re-highlight current region.  [Really,
always re-highlight current region.]

ErRet -- abort.

Err -- an error; ought not execute this action.

High -- highlight current region.

HighM -- highlight all marked regions.

Init -- initialize instance variables.

MProm -- let user see currently highlighted region before
prompting user to mark or pass currently hightlighted region. 
[Really, Nil.]

Mark -- mark current region for removal.

Nil -- no action.

None -- inform user he has marked no region for removal in his
selected model.

One -- inform user there is but one region in his selected model.

Ret -- return to sender.

RmDjA -- remove all marked regions.

Show -- let user see currently highlighted region before
prompting user to continue.  [Really, Nil.]

UDraw -- undraw all marked regions.

UShow -- unshow all shown (iterated) regions, and unmark marked
regions.

UnHi -- un-highlight current region.  [Really, erase highlight
plane.]

UnHiL -- un-highlight located element.  [Really, erase highlight
plane.]

UnHiM -- un-highlight all marked regions.  [Really, erase
highlight plane.]

UnHiP -- un-highlight current region [really, erase highlight
plane]; remove it from gathered stack; and push it onto iterated
stack.

*/

/*
NOTE

Start must be the first action or at least the action equivalent
to zero because this helps save us from needing an init method
override in order to initialize me^^super_cmd.state.
*/

    enum states
    {
        start,    erase,    aqDjA,    whyle,    done,
        clean,    uDraw,    accRm,    highM,    high,
        mProm,    unHi,     shown,    back,     condE,
        preHi,    rmDjA,    allMk,    aProm,    cndEM,
        preHM,    error
    };

/*  A transition for every state: */

    static enum TransitionTypes transitions[] =
    {
        locateT,  epsilonT, enoughT,  loopT,    choiceT, 
        epsilonT, epsilonT, epsilonT, epsilonT, choiceT,
        queueT,   epsilonT, queueT,   whenT,    epsilonT,
        epsilonT, marksT,   epsilonT, queueT,   epsilonT,
        epsilonT, epsilonT
    };

#   define NUM_STATES ((sizeof (transitions))/(sizeof (transitions[0])))

    /* */ static /* */ IGRlong masks[NUM_STATES] =
    {
    /* start */ GRm_TEXT_VALUE | GRm_DATA,
    /* erase */ 0,
    /* aqDjA */ 0,
    /* whyle */ 0,
    /* done  */ 0,
    /* clean */ 0,
    /* uDraw */ 0,
    /* accRm */ 0,
    /* highM */ 0,
    /* high  */ 0,
    /* mProm */ GRm_RESTART | GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON,
    /* unHi  */ 0,
    /* shown */ GRm_RESTART | GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON,
    /* back  */ 0,
    /* condE */ 0,
    /* preHi */ 0,
    /* rmDjA */ 0,
    /* allMk */ 0,
    /* aProm */ GRm_RESTART | GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON,
    /* cndEM */ 0,
    /* preHM */ 0,
    /* error */ 0
    };

    /* */ static /* */ IGRlong prompts[NUM_STATES] =
    {
    /* start */ EMS_P_IdSlCmSf, /* Identify solid/composite surface */
    /* erase */ 0,
    /* aqDjA */ 0,
    /* whyle */ 0,
    /* done  */ 0,
    /* clean */ 0,
    /* uDraw */ 0,
    /* accRm */ 0,
    /* highM */ 0,
    /* high  */ 0,         
    /* mProm */ EMS_P_AcMarkRm, /* Accept to mark region for */
    /* unHi  */ 0,                  /* removal/reject */
    /* shown */ EMS_P_AcMOCont, /* Accept or move on to continue */
    /* back  */ 0,
    /* condE */ 0,
    /* preHi */ 0,
    /* rmDjA */ 0,
    /* allMk */ 0,
    /* aProm */ EMS_P_AcRm,     /* Accept to remove regions/reject */
    /* cndEM */ 0,
    /* preHM */ 0,
    /* error */ 0
    };

    /* */ static /* */ int Tokens[] =
    {
        EX_RESTART, EX_RJT_MOVEON, EX_BACK_UP, GR_UNWANTED_PT,
        GR_UNKNOWN_TYPE
    };

    /*
        I am defining EPSILON to be a valid token number so I can
        make "epsilonT" transitions when there is no input
    */

#   define EPSILON ((sizeof (Tokens))/(sizeof (Tokens[0])))
#   define LOCATE (EPSILON+1)
#   define NUM_TOKENS (EPSILON+2)

#   define SHOW     1   /* show regions command */
#   define RMDJA    2   /* remove regions command */

#   define ONE      3   /* only one area in model */
#   define MT1      4   /* more than one area in model */

#   define ITER     5   /* iterate over current region */
#   define DONE     6   /* iterated over all regions */

#   define ZERO     5   /* no regions iterated */
#   define GT0      6   /* at least one region iterated */

#   define ALL      1   /* all marked, invalid */
#   define NONE     2   /* none marked, invalid */
#   define YES      3   /* 0 < marked < all */

    /*
        In the column headers of the NextState and NextAction
        arrays, the single characters mean the following (the
        meanings follow from definitions of tokens above):

        choiceT
        S -- Show
        R -- Rmdja

        enoughT
        1 -- ONE
        M -- MT1

        loopT
        I -- Iter
        D -- Done

        marksT
        A -- All
        N -- None
        Y -- Yes

        whenT
        0 -- ZERO
        G -- GT0

        Here are how the events currently lie (15 Feb 1989):

        0   RESTART
        1   RJT S -- Show   A -- All
        2   BAK R -- Rmdja  N -- None
        3   UPT 1 -- ONE    Y -- Yes    
        4   UNK M -- MT1
        5   EPS I -- Iter   0 -- ZERO
        6   LOC D -- Done   G -- GT0
    */

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:  RESTART RJT/S/A BAK/R/N  UPT/1/Y UNK/M  EPS/I/0 LOC/D/G
    old state:  */
    /* start */ {start,  start,  start,  start,  start,  start,  erase},
    /* erase */ {error,  error,  error,  error,  error,  aqDjA,  error},
    /* aqDjA */ {error,  error,  error,  clean,  whyle,  error,  error},
    /* whyle */ {error,  error,  error,  error,  error,  high,   done},
    /* done  */ {error,  start,  rmDjA,  error,  error,  error,  error},
    /* clean */ {error,  error,  error,  error,  error,  start,  error},
    /* uDraw */ {error,  error,  error,  error,  error,  clean,  error},
    /* accRm */ {error,  error,  error,  error,  error,  uDraw,  error},
    /* highM */ {error,  error,  error,  error,  error,  aProm,  error},
    /* high  */ {error,  shown,  mProm,  error,  error,  error,  error},
    /* mProm */ {clean,  whyle,  back,   unHi,   condE,  error,  error},
    /* unHi  */ {error,  error,  error,  error,  error,  whyle,  error},
    /* shown */ {clean,  whyle,  back,   whyle,  condE,  error,  error},
    /* back  */ {error,  error,  error,  error,  error,  start,  whyle},
    /* condE */ {error,  error,  error,  error,  error,  preHi,  error},
    /* preHi */ {error,  error,  error,  error,  error,  high,   error},
    /* rmDjA */ {error,  allMk,  allMk,  highM,  error,  error,  error},
    /* allMk */ {error,  error,  error,  error,  error,  whyle,  error},
    /* aProm */ {clean,  allMk,  back,   accRm,  cndEM,  error,  error},
    /* cndEM */ {error,  error,  error,  error,  error,  preHM,  error},
    /* preHM */ {error,  error,  error,  error,  error,  highM,  error},
    /* error */ {error,  error,  error,  error,  error,  error,  error}
    /*  token:  RESTART RJT/S/A BAK/R/N  UPT/1/Y UNK/M  EPS/I/0 LOC/D/G */
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:  RESTART RJT/S/A BAK/R/N  UPT/1/Y UNK/M  EPS/I/0 LOC/D/G
    old state:  */
    /* start */ {Nil,    Nil,    Nil,    Nil,    Ret,    Nil,    UnHiL},
    /* erase */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  AqDjA,  ErRet},
    /* aqDjA */ {ErRet,  ErRet,  ErRet,  One,    Nil,    ErRet,  ErRet},
    /* whyle */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  High,   Nil},
    /* done  */ {ErRet,  Clean,  Nil,    ErRet,  ErRet,  ErRet,  ErRet},
    /* clean */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  Clean,  ErRet},
    /* uDraw */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  RmDjA,  ErRet},
    /* accRm */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  UDraw,  ErRet},
    /* highM */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  AProm,  ErRet},
    /* high  */ {ErRet,  Show,   MProm,  ErRet,  ErRet,  ErRet,  ErRet},
    /* mProm */ {UnHi,   UnHiP,  UnHi,   UnHiP,  CondE,  ErRet,  ErRet},
    /* unHi  */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  Mark,   ErRet},
    /* shown */ {UnHi,   UnHiP,  UnHi,   UnHiP,  CondE,  ErRet,  ErRet},
    /* back  */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  Clean,  Back},
    /* condE */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  Ret,    ErRet},
    /* preHi */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  CondH,  ErRet},
    /* rmDjA */ {ErRet,  AllMk,  None,   HighM,  ErRet,  ErRet,  ErRet},
    /* allMk */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  UShow,  ErRet},
    /* aProm */ {UnHiM,  UnHiM,  UnHiM,  UnHiM,  CndEM,  ErRet,  ErRet},
    /* cndEM */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  Ret,    ErRet},
    /* preHM */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  CndHM,  ErRet},
    /* error */ {ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  ErRet,  ErRet},
    /*  token:  RESTART RJT/S/A BAK/R/N  UPT/1/Y UNK/M  EPS/I/0 LOC/D/G */
    };

    IGRint token = 0;
    EMSrc omrc = OM_S_SUCCESS;
    EMSrc rc = OM_S_SUCCESS;

    switch (me^^super_cmd.mytype)
    {
    case SHOW:
        ex$message (msgnumb = EM_M_ShDjRg);
        break;
    case RMDJA:
        ex$message (msgnumb = EM_M_RmDjRg);
        break;
    default:
        *response = TERMINATE;
        return OM_E_ABORT;
    }

    forever
    {
        struct GRevent event;

#       if DEBUG
            fprintf (
                stderr,
                "top of forever for state %d\n",
                me^^super_cmd.state
            );
#       endif

        switch (me^^ECrmDjRg.action)
        {

        case Show:
        case MProm:
        case AProm:
        case Nil:
            {
                EMSdbgEPS ("Nil Show MProm action\n");
            }
            /* esac Nil */
            break;

        case Ret:
            {
                EMSdbgEPS ("Ret action\n");

                me^^ECrmDjRg.action = Nil;
                return omrc;
            }
            /* esac Ret */
            /* "break;" not necessary because of "return" */

        case Err:
            {
                EMSdbgEPS ("Err action\n");

                ex$message (msgnumb = EMS_E_GIFTinvalidAction);
            }
            /* esac Err */
            break;

        case ErRet:
            {
                EMSdbgEPS ("ErRet action\n");

                *response = TERMINATE;
                return OM_E_ABORT;
            }
            /* esac ErRet */
            /* "break;" not necessary because of "return" */

        case Init:
            {
                extern OMuword OPP_EMSsurface_class_id;
                extern OMuword OPP_EMScompsurf_class_id;
                extern OMuword OPP_EMSsubbs_class_id;

                EMSdbgEPS ("Init action; falls into Clean\n");

                me^^ECelement.elem.located_obj.objid = NULL_OBJID;

                (void)strcpy (
                    me^^ECrmDjRg.attr.classes,
                    "EMSsurface"
                );

                me^^ECrmDjRg.attr.properties =
                    LC_LC_ONLY |
                    LC_DP_ONLY;
/*
 * Modified the owner action attributes to not allow location of 
 * associative solids/surfaces for removing disjoint regions.
 * pp 12/26/91
 */

                if (me->mytype == SHOW)
                 me^^ECrmDjRg.attr.owner_action =
                    LC_RIGID_COMP | 
                    LC_RIGID_OWNER; 
                else
                 me^^ECrmDjRg.attr.owner_action =
                    LC_RIGID_OWNER; 
/* end pp */

                me^^ECrmDjRg.rtree_classes.w_count = 1;
                me^^ECrmDjRg.elig_classes.w_count = 1;

                me^^ECrmDjRg.rtree_classes.w_flags = OM_CLST_subclass;
                me^^ECrmDjRg.elig_classes.w_flags = OM_CLST_subclass;

                me^^ECrmDjRg.rtree_classes.p_classes =
                    &OPP_EMSsubbs_class_id;

                me^^ECrmDjRg.elig_classes.p_classes =
                    &OPP_EMScompsurf_class_id;

                {
                    extern EMSrc EFtreeStart ();

                    rc = EFtreeStart (&me^^ECrmDjRg.p_gathered);

                    if (EMSokay (rc))
                        rc = EFtreeStart (&me^^ECrmDjRg.p_iterated);

                    if (EMSokay (rc))
                        rc = EFtreeStart (&me^^ECrmDjRg.p_marked);

                    if (EMSerror (rc))
                    {
                        *response = TERMINATE;
                        return OM_E_ABORT;
                    }
                }
            }
            /* esac Init */
            /* "break;" not wanted */

        case Clean:
            {
                extern EMSrc EFtreeEmpty ();
                extern EMSrc EFtreeEndSubTrees ();

                EMSdbgEPS ("Clean action\n");

                (void)EFtreeEndSubTrees (me^^ECrmDjRg.p_gathered);
                (void)EFtreeEmpty (me^^ECrmDjRg.p_gathered);
                (void)EFtreeEndSubTrees (me^^ECrmDjRg.p_iterated);
                (void)EFtreeEmpty (me^^ECrmDjRg.p_iterated);
                (void)EFtreeEmpty (me^^ECrmDjRg.p_marked);
            }
            /* esac Clean */
            break;

        case UShow:
            {
                extern EMSrc EFtreeEmpty ();
                extern EMSrc EFstackTop ();
                struct EMStreeNode *p_node = NULL;
                struct EMStreeHeap *p_area = NULL;

                EMSdbgEPS ("UShow action\n");

                /*
                    Following do-while loop puts shown areas back
                    in the gathered stack, leaving them in the
                    iterated stack.  Iterated and marked stacks
                    are cleared after the loop finishes.
                */

                rc = EFstackTop (
                    me^^ECrmDjRg.p_iterated,
                    &p_node,
                    &p_area
                );

                while (rc IS EMS_I_Found)
                {
                    extern EMSrc EFstackPushNode ();

                    rc = EFstackPushNode (
                        p_area,
                        me^^ECrmDjRg.p_gathered
                    );

                    if (rc IS EMS_S_Success)
                    {
                        extern EMSrc EFnodeNextInStack ();

                        rc = EFnodeNextInStack (
                            p_node,
                            &p_node,
                            &p_area
                        );
                    }
                    else
                    {
                        rc = EMS_E_Fail;
                    }
                }

                (void)EFtreeEmpty (me^^ECrmDjRg.p_iterated);
                (void)EFtreeEmpty (me^^ECrmDjRg.p_marked);

                if (EMSerror (rc))
                {
                    *response = TERMINATE;
                    return OM_E_ABORT;
                }
            }
            /* esac UShow */
            break;

        case UnHiP:
            {
                extern EMSrc EFstackPushNode ();

                EMSdbgEPS ("UnHiP action; falls into Erase\n");

                rc = EFstackPushNode (
                    me^^ECrmDjRg.p_area,
                    me^^ECrmDjRg.p_iterated
                );

                if (EMSokay (rc))
                {
                    extern EMSrc EFtreeExciseNode ();

                    rc = EFtreeExciseNode (
                        me^^ECrmDjRg.p_gathered,
                        me^^ECrmDjRg.p_node
                    );
                }

                if (EMSerror (rc))
                {
                    *response = TERMINATE;
                    return OM_E_ABORT;
                }
            }
            /* esac UnHiP */
            /* "break;" not desired */

        case CondE:
        case CndEM:
        case UnHiL:
        case UnHi:
        case UnHiM:
            {
                EMSdbgEPS ("Erase action\n");

                dp$erase_hilite (msg = &rc);
                (void)EMSmsgReport (rc, "ECrmDjRg execute UnHi", DEBUG);
            }
            /* esac UnHiM */
            break;

        case CndHM:
        case HighM:
            {
                extern EMSrc EFareasTreeDraw ();

                EMSdbgEPS ("CndHM HighM action\n");

                omrc = EFareasTreeDraw (
                    &rc,
                    me^^ECrmDjRg.p_marked,
                    &ME_locEnv,
                    GRhd,
                    ME_locObject.osnum
                );
            }
            /* esac HighM */
            break;

        case CondH:
        case High:
            {
                extern EMSrc EFareaDraw ();

                EMSdbgEPS ("CondH/High action\n");

                omrc = EFareaDraw (
                    &rc,
                    me^^ECrmDjRg.p_area,
                    &ME_locEnv,
                    GRhd,
                    ME_locObject.osnum
                );
            }
            /* esac High */
            break;

        case AqDjA:
            {
                EMSdbgEPS ("AqDjA action\n");

                omrc = om$send (
                    msg = message EMSsurface.EMgetContiguousAreas (
                        &rc,
                        &me^^ECrmDjRg.p_gathered
                    ),
                    targetid = ME_locObject.objid,
                    targetos = ME_locObject.osnum
                );

                EMSdbgMR (rc, "AqDjA rc");
                EMSdbgMR (omrc, "AqDjA omrc");
            }
            /* esac AqDjA */
            break;

        case Mark:
            {
                extern EMSrc EFstackPushNode ();

                EMSdbgEPS ("Mark action\n");

                rc = EFstackPushNode (
                    me^^ECrmDjRg.p_area,
                    me^^ECrmDjRg.p_marked
                );
            }
            /* esac Mark */
            break;

        case Back:
            {
/*
                This action assumes the top of the iterated stack
                is now in the me->node and me->area variables.
*/
                extern EMSrc EFstackTop ();
                struct EMStreeNode *p_markedNode;
                struct EMStreeHeap *p_markedArea;

                EMSdbgEPS ("Back action\n");

                rc = EFstackTop (
                    me^^ECrmDjRg.p_marked,
                    &p_markedNode,
                    &p_markedArea
                );

                if (rc IS EMS_I_Found AND
                    p_markedArea IS me^^ECrmDjRg.p_area
                )
                {
                    extern EMSrc EFtreeExciseNode ();

                    rc = EFtreeExciseNode (
                        me^^ECrmDjRg.p_marked,
                        p_markedNode
                    );
                }

                if (EMSokay (rc))
                {
                    extern EMSrc EFtreeExciseNode ();

                    rc = EFtreeExciseNode (
                        me^^ECrmDjRg.p_iterated,
                        me^^ECrmDjRg.p_node
                    );
                }

                if (EMSokay (rc))
                {
                    extern EFstackPushNode ();

                    rc = EFstackPushNode (
                        me^^ECrmDjRg.p_area,
                        me^^ECrmDjRg.p_gathered
                    );
                }
            }
            /* esac Back */
            break;

        case UDraw:
            {
                extern EMSrc EFareasTreeDraw ();

                EMSdbgEPS ("UDraw action\n");

                omrc = EFareasTreeDraw (
                    &rc,
                    me^^ECrmDjRg.p_marked,
                    &ME_locEnv,
                    GRbe,
                    ME_locObject.osnum
                );
            }
            /* esac UDraw */
            break;

        case RmDjA:
            {
                extern OMuword OPP_EMSsfboolean_class_id;

                OMuword classid, consClassid = OPP_EMSsfboolean_class_id;
                int okayToDelete = FALSE;
                struct EMStreeHeap *p_loopList = NULL;

                EMSdbgEPS ("RmDjA action\n");

                omrc = om$get_classid (
                    osnum = ME_locObject.osnum,
                    objid = ME_locObject.objid,
                    p_classid = &classid
                );

                if (EMSokay (omrc)) /* get constructed class id */
                {
                    extern OMuword OPP_EMSsolid_class_id;

                    omrc = om$is_ancestry_valid (
                        subclassid = classid,
                        superclassid = OPP_EMSsolid_class_id
                    );

                    switch (omrc)
                    {
                    case OM_S_SUCCESS:
                    {
                        extern OMuword OPP_EMSslboolean_class_id;

                        EMSdbgEPS ("gonna make a solid\n");

                        consClassid = OPP_EMSslboolean_class_id;
                        okayToDelete = TRUE;
                    }
                    break;
                    case OM_I_INVANCESTRY:
                    {
                        extern OMuword OPP_EMSsfboolean_class_id;

                        EMSdbgEPS ("gonna make a surface\n");

                        consClassid = OPP_EMSsfboolean_class_id;
                        okayToDelete = TRUE;
                    }
                    /* no break; */
                    /* no default: */
                    } /* end switch (omrc) */

                } /* get constructed class id */

                if (okayToDelete)
                {
                    extern EMSrc EFtreeStart ();

                    rc = EFtreeStart (&p_loopList);

                    okayToDelete = EMSokay (rc);
                }

                if (okayToDelete) /* make list of loops */
                {
                    extern EMSrc EFtreeLeftmostNode ();
                    struct EMStreeNode *p_markedNode = NULL;
                    struct EMStreeHeap *p_markedArea = NULL;

                    rc = EFtreeLeftmostNode (
                        me^^ECrmDjRg.p_marked,
                        &p_markedNode,
                        &p_markedArea
                    );

                    while (rc IS EMS_I_Found)
                    {
                        extern EMSrc EFstackPushTreeContents ();

                        rc = EFstackPushTreeContents (
                            p_markedArea,
                            p_loopList
                        );

                        if (EMSokay (rc))
                        {
                            extern EMSrc EFnodeNextToRight ();

                            rc = EFnodeNextToRight (
                                p_markedNode,
                                &p_markedNode,
                                &p_markedArea
                            );
                        }        
                    }

                    okayToDelete = EMSokay (rc);

                } /* make list of loops */

                if (okayToDelete) /* remove areas */
                {
                    /* delete areas marked for deletion */
                    OM_S_OBJID consObjid;
                    struct GRvg_construct list;

                    EMSdbgEPS ("okayToDelete have class id\n");

                    list.msg = (IGRlong *)&rc;
                    list.env_info = &me^^ECelement.md_env;
                    list.newflag = FALSE;
                    list.level = me^^ECelement.active_level;
                    list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
                    list.geometry = NULL;
                    list.display = &me^^ECelement.active_display;
                    list.class_attr = NULL;
                    list.name = NULL;

                    omrc = om$construct(classid = consClassid,
                                        osnum = ME_locObject.osnum,
                                        p_objid = &consObjid);
                    if (1 & omrc)
                    {
                      extern OM_S_OBJID current_creator;
                      current_creator = consObjid;
                      omrc = om$send(msg = message EMSsfboolean.EMdelDisjAreas
                                           ((IGRlong *)&rc, &list, p_loopList,
                                            ME_locObject.objid),
                                     targetid = consObjid,
                                     targetos = ME_locObject.osnum);
                      current_creator = NULL_OBJID;
                    }

                } /* remove areas */

                if (p_loopList) /* deallocate memory */
                {
                    EMSrc endrc;
                    extern EMSrc EFtreeEnd ();

                    endrc = EFtreeEnd (p_loopList);

                    if (EMSokay (rc) AND EMSokay (omrc))
                    {
                        rc = endrc;
                    }

                } /* deallocate memory */
            }
            /* esac RmDjA */
            break;

        case One:
            {
                EMSdbgEPS ("One action\n");

                ex$message (msgnumb = EMS_I_1RegionInModel);
            }
            /* esac One */
            break;

        case None:
            {
                EMSdbgEPS ("None action\n");

                ex$message (msgnumb = EMS_I_NoMarkedRegions);
            }
            /* esac None */
            break;

        case AllMk:
            {
                EMSdbgEPS ("AllMk action\n");

                ex$message (msgnumb = EMS_I_AllRegionsMarked);
            }
            /* esac AllMk */
            break;

        default:
            {
                (void)EMSmsgReport (
                    OM_E_ABORT,
                    "ECrmDjRg execute action table possibly corrupt",
                    DEBUG
                );
                *response = TERMINATE;
                return OM_E_ABORT;
            }    
        } /* end switch (me^^ECrmDjRg.action) */

#       if DEBUG
            fprintf (
                stderr,
                "Before performing transition type %d for state %d\n",
                transitions[me^^super_cmd.state], me^^super_cmd.state
            );
#       endif

        if (NOT (EMSokay (rc) AND EMSokay (omrc)))        
        {
            me^^ECrmDjRg.action = ErRet;
            me^^super_cmd.state = error;
        }
        else switch (transitions[me^^super_cmd.state])
        {
        case epsilonT:
            {
                EMSdbgEPS ("epsilonT transition\n");

                token = EPSILON;
            }
            /* esac epsilonT */
            break;

        case enoughT:
            {
                EMSrc EFtreeCountNodes ();
                int gatheredCount = 0;

                EMSdbgEPS ("enoughT transition\n");

                rc = EFtreeCountNodes (
                    me^^ECrmDjRg.p_gathered,
                    &gatheredCount
                );

                if (EMSokay (rc))
                {
                    if (gatheredCount IS 1)
                    {
                        token = ONE;
                    }
                    else
                    {
                        token = MT1;
                    }
                }
            }
            break;

        case choiceT:
            {
                EMSdbgEPS ("choiceT transition\n");

                switch (me^^super_cmd.mytype)
                {
                case SHOW:
                case RMDJA:
                    token = me^^super_cmd.mytype;
                    break;
                default:
                    (void)EMSmsgReport (
                        OM_E_ABORT,
                        "ECrmDjRg execute action invalid type",
                        DEBUG
                    );
                    *response = TERMINATE;
                    return OM_E_ABORT;
                }
            }
            /* esac choiceT */
            break;

        case locateT:
            {
                IGRuint size = sizeof (struct GRevent);
                IGRlong display_flag =
                    ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;
                IGRboolean status;

                EMSdbgEPS ("locateT transition\n");

                status = lc$locate (
                    rc = &rc,
                    event1 = &ME_locEvent,
                    event2 = &ME_locEvent,
                    mask1 = masks[me^^super_cmd.state]/* | GRm_BACK_UP*/,
                    mask2 = GRm_DATA,
                    eventsize = &size,
                    display_flag = display_flag,
                    response = response,
                    response_data = response_data,
                    unhilight_mode = (enum GRdpmode) GRhd,
                    locate_key = prompts[me^^super_cmd.state],
                    acc_key = EMS_P_00038,
                    relocate_key = EMS_I_EltNotLocated,
                    attributes = &me^^ECrmDjRg.attr,
                    stack = &me^^ECelement.locate_stack,
                    rtree_classes = &me^^ECrmDjRg.rtree_classes, 
                    eligible_classes = &me^^ECrmDjRg.elig_classes
                );
                    
                if (status AND EMSokay (rc))
                {
                    token = LOCATE;
                }
                else
                {
                    extern IGRint GRloc_token ();

                    token = GRloc_token (&rc, Tokens, &ME_locEvent);
                }

                rc = OM_S_SUCCESS;
            }
            /* esac locateT */
            break;

        case loopT:
            {
                extern EMSrc EFstackTop ();

                EMSdbgEPS ("loopT transition\n");

                rc = EFstackTop (
                    me^^ECrmDjRg.p_gathered,
                    &me^^ECrmDjRg.p_node,
                    &me^^ECrmDjRg.p_area
                );

                switch (rc)
                {
                case EMS_I_Found:
                    token = ITER;
                    break;
                case EMS_I_NotFound:
                    token = DONE;
                    break;
                default:
                    token = 0;
                }
            }
            /* esac loopT */
            break;

        case marksT:
            {
                EMSrc EFtreeCountNodes ();
                int iteratedCount = 0;

                EMSdbgEPS ("marksT transition\n");

                rc = EFtreeCountNodes (
                    me^^ECrmDjRg.p_iterated,
                    &iteratedCount
                );

                if (EMSokay (rc))
                {
                    int markedCount = 0;

                    rc = EFtreeCountNodes (
                        me^^ECrmDjRg.p_marked,
                        &markedCount
                    );

                    /* trees are initialized -- ought not error */

                    if (EMSokay (rc))
                    {
                        if (markedCount)
                        {
                            if (markedCount IS iteratedCount)
                            {
                                token = ALL; /* all are marked */
                            }
                            else
                            {
                                token = YES; /* 0 < marked < total */
                            }
                        }
                        else
                        {
                            token = NONE; /* none marked */
                        }
                    }
                    else
                    {
                        token = 0; /* error */
                    }
                }
            }
            /* esac marksT */
            break;

        case queueT:
            {
                EMSdbgEPS ("queueT transition\n");

                co$getevent (
                    msg = &rc,
                    event_mask = masks[me^^super_cmd.state],
                    msgnum = prompts[me^^super_cmd.state],
                    event = &event,
                    response = response,
                    response_data = response_data,
                );

                /* intentional block */
                {
                    extern IGRint GRloc_token ();

                    token = GRloc_token (&rc, Tokens, &event);
                }
            }
            /* esac queueT */
            break;

        case whenT:
            {
                EMSdbgEPS ("whenT transition\n");

                rc = EFstackTop (
                    me^^ECrmDjRg.p_iterated,
                    &me^^ECrmDjRg.p_node,
                    &me^^ECrmDjRg.p_area
                );

                switch (rc)
                {
                case EMS_I_Found:
                    token = GT0;
                    break;
                case EMS_I_NotFound:
                    token = ZERO;
                    break;
                default:
                    token = 0;
                }
            }
            /* esac whenT */
            break;

        default:
            {
#               if DEBUG
                    (void)fprintf (stderr,
"Performing (default) transition type %d for state %d\n",
                    transitions[me^^super_cmd.state], me^^super_cmd.state);
                    (void)fprintf (stderr,
"ECrmDjRg execute, invalid type of transition -- aborting\n");
#               endif
                *response = TERMINATE;
                return OM_E_ABORT;
            }

        } /* end switch (transitions[me^^super_cmd.state]) */
    
        me^^ECrmDjRg.action = NextAction[me^^super_cmd.state][token];
        me^^super_cmd.state = NextState[me^^super_cmd.state][token];

    } /* end forever, should never get here */

/* This code is unreachable
    (void)EMSmsgReport (OM_E_ABORT, "ECrmDjRg execute forever", DEBUG);
    *response = TERMINATE;
    return OM_E_ABORT;
*/

} /* method execute */

end implementation ECrmDjRg;
