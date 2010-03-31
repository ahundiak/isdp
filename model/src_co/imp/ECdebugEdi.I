/* ###################   APOGEE COMPILED   ################## */
class implementation ECdebugEd;

#include "EMS.h"

/*
HISTORY

29 Dec 89   DLB Modified this abortion (a.k.a a 'Brooke command') to write to 
                stdout if no filename is given.
23 Sep 1989 rlw Modified to support sets and modified prompts to make
                intentions clearer.
27 Jun 1989 jBk Fixed oversight which caused incorrect file name
                to be used for reading in reading and editing
                invocations of this command when such invocations
                are stacked.

01 May 1989 jBk Genesis.
*/

# ifndef DEBUG
# define DEBUG 0
# endif

# ifndef DEBUGEXFORK
# define DEBUGEXFORK 0
# endif

# if DEBUG || DEBUGEXFORK
#   include <stdio.h>
#   include "EMScmacros.h"
    extern int EFfprints ();
# endif

# if DEBUG
#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPS(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMR(rc, string)
#   define EMSdbgEPS(string)
# endif

# if DEBUG || DEBUGEXFORK
#   define EMSdbgMRexfork(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPSexfork(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMRexfork(rc, string)
#   define EMSdbgEPSexfork(string)
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

/* ex$putque */
# ifndef exmacros_include
# include "exmacros.h"
# endif

/* GR_w_novalue */
# ifndef griodef_include
# include "griodef.h"
# endif

# include "msdef.h"     /* definitions for ex$message */
# include "msmacros.h"  /* ex$message */

# include "exmacros.h"  /* ex$fork */

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
# include "grgsdef.h"       /* Needed for the macros */
# include "grgsmacros.h"    /* gr$gsput_locate_criteria() */

# include "EMSmsgdef.h"     /* EMS_S_Success */

# include "EMS_I.h"
# include "EMS_M.h"
# include "EMS_P.h"
# include "EMS_E.h"

# define ME_locEvent (me^^ECelement.locev)
# define ME_locObject (me^^ECelement.locev.located_object[0].located_obj)
# define ME_locEnv (me^^ECelement.locev.located_object[0].module_info)

method delete (int f_defer_flag)
{
    if (me^^ECdebugEd.fp)
    {
        if (ME.ECdebugEd->write_to_stdout)
        {
          /*DLB*/
          (void) fflush (me^^ECdebugEd.fp);
        }
        else
        {
          (void) fclose (me^^ECdebugEd.fp);
        }
        me^^ECdebugEd.fp = NULL;
    }

    return om$send (
        mode = OM_e_wrt_parent,
        msg = message ECdebugEd.delete (f_defer_flag),
        targetid = my_id
    );
}

method execute (int *response; char *response_data; int pos)
{
    enum TransitionTypes
    {
        choiceT, epsilonT, locateT, openRT, openWT, fnameT
    };
    
/*
NOTE

Init must be the first action or at least the action equivalent
to zero because this helps save us from needing an init method
override in order to initialize me^^ECdebugEd.action.
*/

    enum actions
    {
        Init, ErRet, Err, Nil, Ret, EInit, RInit, WInit, MkTmp,
        EOpnW, EOpnR, Write, Close, Edit, RdDis, FName, NoFyl
    };

/*

ErRet -- abort.

Err -- an error; ought not execute this action.

Init -- initialize instance variables.

Nil -- no action.

Ret -- return to sender.

EInit -- initialize for the "edit" portion of this command.

RInit -- initialize for the "read" portion of this command.

WInit -- initialize for the "write" portion of this command.

MkTmp -- make up a temporary filename for editing.

EOpnW -- report error upon opening a file for writing.

EOpnR -- report error upon opening a file for reading.

Write -- write element to file.

Close -- close file.

Edit -- invoke editor on temporary file.

RdDis -- read file and display results.

FName -- use text event for filename (really Nil).

NoFyl -- no file specified

*/

/*
NOTE

Start must be the first state or at least the state equivalent
to zero because this helps save us from needing an init method
override in order to initialize me^^super_cmd.state.
*/

    enum states
    {
        start,    eInit,    mdTmp,    edOpn,    edClo,
        editd,    edIn,     rInit,    fnamR,    rdIn,
        wInit,    fnamW,    wOpen,    error
    };

/*  A transition for every state: */

    static enum TransitionTypes transitions[] =
    {
        choiceT,  epsilonT, openWT,   locateT,  epsilonT,
        openRT,   epsilonT, fnameT,   openRT,   epsilonT,
        fnameT,   openWT,   locateT,  epsilonT
    };

#   define NUM_STATES ((sizeof (transitions))/(sizeof (transitions[0])))

    /* */ static /* */ int Tokens[] =
    {
        EX_RJT_MOVEON, EX_STRING, GR_UNKNOWN_TYPE
    };

    /*
        I am defining EPSILON to be a valid token number so I can
        make "epsilonT" transitions when there is no input
    */

#   define EPSILON ((sizeof (Tokens))/(sizeof (Tokens[0])))
#   define LOCATE (EPSILON+1)
#   define NUM_TOKENS (EPSILON+2)

#   define READ     1   /* read geometry from file */
#   define WRITE    2   /* write geometry to file */
#   define EDIT     3   /* edit geometry */

#   define EOPEN    3   /* file not opened successfully */
#   define OPEN     4   /* file opened successfully */

#   define READ_MASK    (0x1)
#   define WRITE_MASK   (0x2)
#   define EDIT_MASK    (READ_MASK | WRITE_MASK)
#   define HEX_MASK     (0x4)
#   define CLASS_MASK   (0x8)

    /*
        In the column headers of the NextState and NextAction
        arrays, the single characters mean the following (the
        meanings follow from definitions of tokens above):

        choiceT
        R -- READ
        W -- WRITE
        E -- EDIT

        Here are how the events currently lie (15 Feb 1989):

        0 MV_ON
        1   TXT R -- READ
        2   UNK W -- WRITE
        3   EPS E -- EDIT   E -- EOPEN
        4   LOC             O -- OPEN
    */

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:   MV_ON  TXT/R  UNK/W  E/E/E   L/O
    old state:  */
    /* start */ {error, rInit, wInit, eInit, error},
    /* eInit */ {error, error, error, mdTmp, error},
    /* mdTmp */ {error, error, error, error, edOpn},
    /* edOpn */ {edClo, edOpn, edOpn, error, edOpn},
    /* edClo */ {error, error, error, editd, error},
    /* editd */ {error, error, error, error, edIn},
    /* edIn  */ {error, error, error, eInit, error},
    /* rInit */ {rInit, fnamR, rInit, rInit, error},
    /* fnamR */ {error, error, error, rInit, rdIn},
    /* rdIn  */ {error, error, error, rInit, error},
    /* wInit */ {wInit, fnamW, wInit, wInit, error},
    /* fnamW */ {error, error, error, wInit, wOpen},
    /* wOpen */ {wInit, wOpen, wOpen, error, wOpen},
    /* error */ {error, error, error, error, error}
    /*  token:   MV_ON  TXT/R  UNK/W  E/E/E   L/O */
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:   MV_ON  TXT/R  UNK/W  E/E/E   L/O
    old state:  */
    /* start */ {ErRet, RInit, WInit, EInit, ErRet},
    /* eInit */ {ErRet, ErRet, ErRet, MkTmp, ErRet},
    /* mdTmp */ {ErRet, ErRet, ErRet, EOpnW, Nil},
    /* edOpn */ {Close, Ret,   Ret,   ErRet, Write},
    /* edClo */ {ErRet, ErRet, ErRet, Edit,  ErRet},
    /* editd */ {ErRet, ErRet, ErRet, EOpnR, RdDis},
    /* edIn  */ {ErRet, ErRet, ErRet, Close, ErRet},
    /* rInit */ {Nil,   FName, Ret,   NoFyl, ErRet},
    /* fnamR */ {ErRet, ErRet, ErRet, EOpnR, RdDis},
    /* rdIn  */ {ErRet, ErRet, ErRet, Close, ErRet},
    /* wInit */ {Nil,   FName, Ret,   NoFyl, ErRet},
    /* fnamW */ {ErRet, ErRet, ErRet, EOpnW, Nil},
    /* wOpen */ {Close, Ret,   Ret,   ErRet, Write},
    /* error */ {ErRet, ErRet, ErRet, ErRet, ErRet}
    /*  token:   MV_ON  TXT/R  UNK/W  E/E/E   L/O */
    };

    struct GRevent event;
        /* assigned only by fnameT transition and MkTmp action */

    IGRint token;
    EMSrc omrc = OM_S_SUCCESS;
    EMSrc rc = OM_S_SUCCESS;
    int tryhex, tryclass;

    tryhex = me^^super_cmd.mytype & HEX_MASK;
    tryclass = me^^super_cmd.mytype & CLASS_MASK;

#   define WRITE_HEX        6
#   define READ_HEX         5
#   define READ_CLASS       9
#   define READ_HEX_CLASS  13

    switch (me^^super_cmd.mytype)
    {
    case READ_HEX:
    case READ_CLASS:
    case READ_HEX_CLASS:
    case READ:
/*      ex$message (msgnumb = EM_M_DebugRdHexGeom);
        ex$message (msgnumb = EM_M_DebugRdClsGeom);
        ex$message (msgnumb = EM_M_DebugRdXClGeom); */
        ex$message (msgnumb = EM_M_DebugReadGeom);
        break;
    case WRITE_HEX:
    case WRITE:
/*      ex$message (msgnumb = EM_M_DebugWrHexGeom); */
        ex$message (msgnumb = EM_M_DebugWriteGeom);
        break;
    case EDIT:
        ex$message (msgnumb = EM_M_DebugEditGeom);
        break;
    default:
        *response = TERMINATE;
        return OM_E_ABORT;
    }

    forever
    {
#       if DEBUG
            fprintf (
                stderr,
                "top of forever for state %d\n",
                me^^super_cmd.state
            );
#       endif

        switch (me^^ECdebugEd.action)
        {

        case Init:
            {
                extern OMuword OPP_GRbspline_class_id;
                extern OMuword OPP_EMSsubbs_class_id;
                extern OMuword OPP_GRowner_class_id;

                EMSdbgEPS ("Init action\n");

                me^^ECelement.elem.located_obj.objid = NULL_OBJID;
/*
                (void)strcpy (
                    me^^ECdebugEd.attr.classes,
                    "GRvg"
                );
*/
                me^^ECdebugEd.attr.properties =
                    LC_RW          |       /* Operation is readonly */
                    LC_LC_ONLY     |       /* Locate locatable objects */
                    LC_DP_ONLY     |       /* Locate displayable objects */
                    IGN_MOD_BIT    |       /* Ignore modified and new props */
                    LC_PLANAR_NON_PLANAR;  /* Planarity doesn't matter */

                me^^ECdebugEd.attr.owner_action =
                    LC_RIGID_OWNER |    /* Composites */
                    LC_RIGID_COMP  |    /* Rigid children */
                    LC_FLEX_OWNER  |    /* Graphic groups, etc. */
                    LC_FLEX_COMP   |    /* Members of graphic groups, etc. */
                    LC_REF_OBJECTS |    /* Objects in ref. files are O.K. */
                    LC_NO_REF_HEADER;   /* No reference file headers */

                me^^ECdebugEd.rtree_classes.w_count = 2;
                me^^ECdebugEd.elig_classes.w_count = 3;

                me^^ECdebugEd.rtree_classes.w_flags = OM_CLST_subclass;
                me^^ECdebugEd.elig_classes.w_flags = OM_CLST_subclass;

                me^^ECdebugEd.rtree_classes.p_classes =
                    me^^ECdebugEd.rtreeClassids;

                me^^ECdebugEd.elig_classes.p_classes =
                    me^^ECdebugEd.eligClassids;

                me^^ECdebugEd.rtreeClassids[0] = OPP_GRbspline_class_id;
                me^^ECdebugEd.rtreeClassids[1] = OPP_EMSsubbs_class_id;

                me^^ECdebugEd.eligClassids[0] = OPP_GRbspline_class_id;
                me^^ECdebugEd.eligClassids[1] = OPP_EMSsubbs_class_id;
                me^^ECdebugEd.eligClassids[2] = OPP_GRowner_class_id;
            }
            /* esac Init */
            break;

        case Ret:
            {
                EMSdbgEPS ("Ret action\n");

                me^^ECdebugEd.action = Nil;
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

        case EInit:
        case RInit:
        case WInit:
        case Nil:
            {
                EMSdbgEPS ("Nil ?Init action\n");
            }
            /* esac Nil */
            break;

        case FName:
            {
                EMSdbgEPS ("FName action\n");

                strcpy (
                    me^^ECdebugEd.tempEditFileName,
                    event.event.keyin
                );
            }
            /* esac FName */
            break;

        case MkTmp:
            {
                extern char *tmpnam ();

                EMSdbgEPS ("MkTmp action\n");

                (void) tmpnam (me^^ECdebugEd.tempEditFileName);
            }
            /* esac MkTmp */
            break;

        case EOpnW:
            {
                EMSdbgEPS ("EOpnW action\n");

                ex$message (
                    msgnumb = EMS_E_OpenFileW,
                    var = me^^ECdebugEd.tempEditFileName,
                    type = "%s"
                );
            }
            /* esac EOpnW */
            break;

        case EOpnR:
            {
                EMSdbgEPS ("EOpnR action\n");

                ex$message (
                    msgnumb = EMS_E_OpenFileR,
                    var = me^^ECdebugEd.tempEditFileName,
                    type = "%s"
                );
            }
            /* esac EOpnR */
            break;

        case NoFyl:
            {
                EMSdbgEPS ("NoFyl action\n");

                ex$message (
                    msgnumb = EMS_E_NoFileSpecified,
                    var = me^^ECdebugEd.tempEditFileName,
                    type = "%s"
                );
            }
            /* esac NoFyl */
            break;

        case Write:
            {
                extern EMSrc EFfprintGeom ();

                EMSdbgEPS ("Write action\n");

                dp$erase_hilite (msg = &rc);
                /* do not care about   ^^^ returned code today */

                ex$message (msgnumb = EMS_I_Processing);
                omrc = EFfprintGeom (
                    &rc,
                    me^^ECdebugEd.fp,
                    ME_locObject.osnum,
                    ME_locObject.objid,
                    &ME_locEnv,
                    tryhex
                );

                if (EMSerror (omrc) OR EMSerror (rc))
                {
                    ex$message (msgnumb = EMS_E_OperationFailed);
                    omrc = OM_S_SUCCESS;
                    rc = EMS_S_Success;
                }
                else
                {
                    ex$message (msgnumb = EMS_I_ClearStatusField);
                }

                if (ME.ECdebugEd->write_to_stdout)
                {
                   /*DLB*/
                   (void) fflush (me^^ECdebugEd.fp);
                }  
            }
            /* esac Write */
            break;

        case Close:
            {
                EMSdbgEPS ("Close action\n");
                
                if (ME.ECdebugEd->write_to_stdout)
                {
                  /*DLB*/
                  (void) fflush (me^^ECdebugEd.fp);
                } 
                else
                {
                  (void) fclose (me^^ECdebugEd.fp);
                }
                me^^ECdebugEd.fp = NULL;
            }
            /* esac Close */
            break;

        case Edit:
            {
                extern char *getenv ();
                char *argu[3];
                char commandString[BUFSIZ];
                char *p_editor;

                EMSdbgEPS ("Edit action\n");

                p_editor = getenv ("EDITOR");

                if (NOT p_editor) p_editor = "vi";

                (void) sprintf (
                    commandString,
                    "/bin/ksh -c %s %s",
                    p_editor,
                    me^^ECdebugEd.tempEditFileName
                );

                ex$message (
                    field = ERROR_FIELD,
                    in_buff = commandString
                );

                EMSdbgEPSexfork (commandString);
                EMSdbgEPSexfork ("\n");

                (void) sprintf (
                    commandString,
                    "%s %s",
                    p_editor,
                    me^^ECdebugEd.tempEditFileName
                );

                EMSdbgEPSexfork (commandString);
                EMSdbgEPSexfork ("\n");

                argu[0] = "/bin/ksh";
                argu[1] = "-c";
                argu[2] = commandString;

                ex$fork (
                    wait_flag = TRUE,
                    num_entry = 3,
                    argu = argu
                );

                EMSdbgEPSexfork ("returned from ex$fork\n");

                ex$message (msgnumb = EMS_I_ClearStatusField);
            }
            /* esac Edit */
            break;

        case RdDis:
            {
                extern EMSrc EFfreadGeom ();
                struct GRvg_construct list;
                enum GRdpmode mode_bd = GRbd;
                OM_S_OBJID objid;

                EMSdbgEPS ("RdDis action\n");

                ex$message (msgnumb = EMS_I_Processing);

                list.msg = (IGRlong *)&rc;
                list.env_info = &me^^ECelement.md_env;
                list.newflag = FALSE;
                list.class_attr = NULL;
                list.level = me^^ECelement.active_level;
                list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
                list.display = &me^^ECelement.active_display;
                list.name = NULL;
                list.geometry = NULL;

                while (NOT feof (me^^ECdebugEd.fp) AND
                    EMSokay (omrc) AND EMSokay (rc)
                )
                {
                    omrc = EFfreadGeom (
                        me^^ECdebugEd.fp,
                        me^^ECelement.md_env.md_id.osnum,
                        &objid,
                        &list,
                        &mode_bd,
                        tryclass,
                        tryhex
                    );
                }

                if (EMSerror (omrc) OR EMSerror (rc))
                {
                    ex$message (msgnumb = EMS_E_OperationFailed);
                    omrc = OM_S_SUCCESS;
                    rc = EMS_S_Success;
                }
                else
                {
                    ex$message (msgnumb = EMS_I_ClearStatusField);
                }
            }
            /* esac RdDis */
            break;

        default:
            {
                (void)EMSmsgReport (
                    OM_E_ABORT,
                    "ECdebugEd execute action table possibly corrupt",
                    DEBUG
                );
                *response = TERMINATE;
                return OM_E_ABORT;
            }    
        } /* end switch (me^^ECdebugEd.action) */

#       if DEBUG
            fprintf (
                stderr,
                "Before performing transition type %d for state %d\n",
                transitions[me^^super_cmd.state], me^^super_cmd.state
            );
#       endif

        if (NOT (EMSokay (rc) AND EMSokay (omrc)))        
        {
            me^^ECdebugEd.action = ErRet;
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

        case openRT:
            {
                EMSdbgEPS ("openRT transition\n");

                me^^ECdebugEd.fp = fopen (
                    me^^ECdebugEd.tempEditFileName,
                    "r"
                );

                if (me^^ECdebugEd.fp)
                    token = OPEN;
                else
                    token = EOPEN;
            }
            /* esac openRT */
            break;

        case openWT:
            {
                EMSdbgEPS ("openWT transition\n");

                if (ME.ECdebugEd->write_to_stdout)
                {
                  /*DLB*/
                  me^^ECdebugEd.fp = stdout;
                }
                else
                {
                  me^^ECdebugEd.fp = fopen (
                      me^^ECdebugEd.tempEditFileName,
                      "w"
                  );
                }

                if (me^^ECdebugEd.fp)
                    token = OPEN;
                else
                    token = EOPEN;
            }
            /* esac openWT */
            break;

        case fnameT:
            {
                ME.ECdebugEd->write_to_stdout = FALSE; /*DLB*/

                EMSdbgEPS ("fnamT transition\n");

                event.event.keyin[0] = NULL;

                co$getevent (
                    msg = &rc,
                    event_mask = GRm_TEXT_VALUE,
                    msgnum = ((ME.super_cmd->mytype == WRITE_HEX ||
                               ME.super_cmd->mytype == WRITE) ?
                               EMS_P_EnterFileNameStdout : 
                               EMS_P_EnterFileName),
                    event = &event,
                    response = response,
                    response_data = response_data,
                );

                ex$message (msgnumb = EMS_I_ClearStatusField);

                if (rc IS GRw_no_value)
                {
                    if (ME.super_cmd->mytype == WRITE_HEX ||
                        ME.super_cmd->mytype == WRITE)
                    {
                      /*DLB*/
                      ME.ECdebugEd->write_to_stdout = TRUE;
                      token = 1;
                    }
                    else
                    {
                      token = EPSILON;
                    }
                    rc = MSSUCC;
                }
                else
                {
                    extern IGRint GRloc_token ();

                    token = GRloc_token (&rc, Tokens, &event);
                }
            }
            /* esac fnamT */
            break;

        case choiceT:
            {
                EMSdbgEPS ("choiceT transition\n");

                token = me^^super_cmd.mytype & EDIT_MASK;

                if (NOT token)
                {
                    (void)EMSmsgReport (
                        OM_E_ABORT,
                        "ECdebugEd execute action invalid type",
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
                IGRchar locate_prompt[80];
                IGRuint size = sizeof (ME_locEvent);
                IGRlong sts;
                IGRlong display_flag =
                    ALL_WINDOWS |
                    ELEM_HILIGHT |
                    NO_PROJ_ACCEPT_POINT |
                    ACC_REJ_CYCLE |
                    RELOCATE |
                    LC_REGULAR_HIGHLIGHT |
                    LC_ERASE_ALL |
                    LC_ACCEPT_CURSOR;
                IGRboolean status;
                struct GRevent accept_event, object_event;

                EMSdbgEPS ("locateT transition\n");

                sts = gr$gsput_locate_criteria(
                    msg = &rc,
                    attributes = &me^^ECdebugEd.attr,
                    rtree_classes = &me^^ECdebugEd.rtree_classes, 
                    eligible_classes = &me^^ECdebugEd.elig_classes
                );
                if (me^^super_cmd.mytype == EDIT)
		  ex$message(msgnumb = EMS_P_IdCuSurSeMoEdit,
			buff = locate_prompt)
                else
		  ex$message(msgnumb = EMS_P_IdCuSurSeMoClose,
			buff = locate_prompt)

                status = lc$locate (
                    rc = &rc,
                    event1 = &ME_locEvent,
                    event2 = &accept_event,
                    event3 = &object_event,
                    mask1 = GRm_DATA | GRm_TEXT_VALUE | GRm_SPECIFIED_OBJ,
                    mask2 = GRm_DATA | GRm_TEXT_VALUE,
                    eventsize = &size,
                    display_flag = display_flag,
                    response = response,
                    response_data = response_data,
                    unhilight_mode = (enum GRdpmode) GRhd,
                    locate_prompt = locate_prompt,
                    acc_key = EMS_P_00101,
                    relocate_key = EMS_I_EltNotLocated,
                    attributes = &me^^ECdebugEd.attr,
                    stack = &me^^ECelement.locate_stack,
                    rtree_classes = &me^^ECdebugEd.rtree_classes, 
                    eligible_classes = &me^^ECdebugEd.elig_classes
                );
                    
                ex$message (msgnumb = EMS_I_ClearStatusField);

#               if DEBUG
                (void) fprintf (stderr,
                    "lc$locate status %d rc %d response %d %d subt %d\n",
                    status,
                    rc,
                    *response,
                    ME_locEvent.response,
                    ME_locEvent.subtype
                );
#               endif

                if (status AND EMSokay (rc))
                {
                    token = LOCATE;

                    ME_locEvent.num_id = object_event.num_id;
                    ME_locEvent.located_object[0] = 
                     object_event.located_object[0];
                    if (ME_locEvent.response == EX_OBJID)
                      {}
                    else if ((ME_locEvent.subtype != GRst_REGULAR) &&
                     ME_locEvent.num_id && 
                     (ME_locEvent.located_object[0].located_obj.objid ==
                      accept_event.located_object[0].located_obj.objid))
                      {}
                    else
                    {
                        IGRboolean success;

                        size = sizeof (struct GRevent);

                        success = ex$putque (
                            msg = (IGRlong *)&rc,
                            response = &accept_event.response,
                            byte = (IGRlong *)&size,
                            buffer = (IGRchar *)&accept_event.event
                        );

                        if (EMSerror (rc) OR NOT success)
                        {
                            omrc = OM_E_ABORT;

                            me^^ECdebugEd.action = ErRet;
                            me^^super_cmd.state = error;
                        }
                    }
                }
                else
                {
                    extern IGRint GRloc_token ();

#                   if DEBUG
                    (void) fprintf (
                        stderr,
                        "lc$locate status %d rc %d\n",
                        status, rc
                    );
                    (void) fprintf (
                        stderr,
                        "lc$locate ME_locEvent.response %d %d\n",
                        ME_locEvent.response,
                        *response
                    );
#                   endif

                    ME_locEvent.response = *response;
                    token = GRloc_token (&rc, Tokens, &ME_locEvent);
                }

                rc = OM_S_SUCCESS;
            }
            /* esac locateT */
            break;

        default:
            {
#               if DEBUG
                    (void)fprintf (stderr,
"Performing (default) transition type %d for state %d\n",
                    transitions[me^^super_cmd.state], me^^super_cmd.state);
                    (void)fprintf (stderr,
"ECdebugEd execute, invalid type of transition -- aborting\n");
#               endif
                *response = TERMINATE;
                return OM_E_ABORT;
            }

        } /* end switch (transitions[me^^super_cmd.state]) */
    
#       if DEBUG
        (void) fprintf (stderr, "ostate is %d\n", me^^super_cmd.state);
        (void) fprintf (stderr, "token is %d\n", token);
#       endif

        me^^ECdebugEd.action = NextAction[me^^super_cmd.state][token];
        me^^super_cmd.state = NextState[me^^super_cmd.state][token];

#       if DEBUG
        (void) fprintf (stderr, "nstate is %d\n", me^^super_cmd.state);
        (void) fprintf (stderr, "naction is %d\n", me^^ECdebugEd.action);
#       endif

    } /* end forever, should never get here */

    (void)EMSmsgReport (OM_E_ABORT, "ECdebugEd execute forever", DEBUG);
    *response = TERMINATE;
    return OM_E_ABORT;

} /* method execute */

end implementation ECdebugEd;
