/* ###################   APOGEE COMPILED   ################## */
class implementation ECnatsides;

#include "EMS.h"
/*
HISTORY

14 Aug 1994 scw Clarified sleep method
13 Jul 1988 jBk Changed call of EFnaturalSolidFromSurfaces to be
                EFnaturalGeneralSolidFromSurfaces.  Modified this
                command object accordingly.
                Changed the displayed command names.
                Erase the "Erasing" message.
07 Jun 1988 jBk Utilized change of instance variable eliclass to
                an array.
03-Jun-1988 jBk Added surfaces with imposed boundaries to the
                list of locatables.
                Added LC_RIGID_OWNER to owner_action of location
                attributes.
                Removed extraneous message imports.
16-May-1988 jBk Added capability to recognize two closed surfaces
                and create a solid boolean using the message,
                EMsolidFromNonIntersectingClosedSurfaces.
                Changed to send EMmk_w_natural_sides_twixt_2sf to
                an EMSsfsolid instead of to a EMSgencompsf.
                These changes were mostly reflected in a new
                function call, EFnaturalSolidFromSurfaces.
01-Feb-1988 jBk Genesis.
*/

# ifndef DEBUG
# define DEBUG 0
# endif

/* stderr */
# if DEBUG
# include <stdio.h>
# endif

/* strcpy */
# include <string.h>

/* EMSokay; EMSerror for GIFTmsgReport */
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

/* ex$putque */
# ifndef exmacros_include
# include "exmacros.h"
# endif

/* grdpb_module_env, grdpb_active_level and grdpb_active_display
    for macros from grdpbmacros.h */
# ifndef grdpbdef_include
# include "grdpbdef.h"
# endif

/* gr$get_module_env, gr$get_active_level, gr$get_active_display */
# ifndef grdpbmacros_include
# include "grdpbmacros.h"
# endif

/* IF_NULL_OBJID */
# ifndef OM_D_MACROS
# include "OMmacros.h"
# endif

/* EMS_I_Fail */
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

/* EMS_E_UnusedCodeVariable */
# ifndef EMS_E_include
# include "EMS_E.h"
# endif

#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"

from GRgraphics import GRdisplay;

method init (int type; char *str_ptr)
{
    me->action = 2;
    me->locatedElement[0].objid = NULL_OBJID;
    me->locatedElement[1].objid = NULL_OBJID;

    return om$send (
        mode = OM_e_wrt_message,
        msg = message super_cmd.init (type, str_ptr),
        targetid = my_id
    );
}

method super_cmd.sleep (int pos)
{
    EMSrc rc;

    dp$erase_hilite (msg = &rc);
    (void)EMSmsgReport (rc, "ECnatsides sleep UnHi", DEBUG);

    return om$send (
        mode = OM_e_wrt_message,
        msg = message super_cmd.wakeup (pos),
        targetid = my_id
    );
}

method wakeup (int pos)
{
    EMSrc rc;
    int size;

    size = sizeof (me->env);
    gr$get_module_env (
        msg = &rc,
        sizbuf = &size,
        buffer = &me->env,
        nret = &size
    );

    if (NOT EMSmsgReport (rc, "ECnatsides wakeup get mod env", DEBUG))
    {
        size = sizeof (me->layer);
        gr$get_active_level (
            msg = &rc,
            sizbuf = &size,
            buffer = &me->layer,
            nret = &size
        );
        (void)EMSmsgReport (rc, "ECnatsides wakeup get layer", DEBUG);
    }

    if (EMSokay (rc))
    {
        size = sizeof (me->display);
        gr$get_active_display (
            msg = &rc,
            sizbuf = &size,
            buffer = &me->display,
            nret = &size
        );
        (void)EMSmsgReport (rc, "ECnatsides wakeup get display", DEBUG);
    }

    {
        int ii = 1;

#       if DEBUG
        (void)fprintf (stderr, "wakeup rehighlight\n");
#       endif

        do
        {
            if (NOT IF_NULL_OBJID (me->locatedElement[ii].objid))
            {
                EMSrc omrc;
                enum GRdpmode mode = GRhd;

                omrc = om$send (
                    msg = message GRgraphics.GRdisplay (
                        (IGRlong *)&rc,
                        &me->locatedEnv[ii].md_env.matrix_type,
                        me->locatedEnv[ii].md_env.matrix,
                        &mode,
                        &me->locatedEnv[ii].md_id
                    ),
                    targetid = me->locatedElement[ii].objid,
                    targetos = me->locatedElement[ii].osnum
                );
                (void)EMSmsgReport (omrc, "ECnatsides wkds", DEBUG);
                (void)EMSmsgReport (rc, "ECnatsides rcwkds", DEBUG);
            }
        } while (ii--);
    }

    return om$send (
        mode = OM_e_wrt_message,
        msg = message super_cmd.wakeup (pos),
        targetid = my_id
    );
}

method execute (int *response; char *response_data; int pos)
{
    /* */ static /* */ int Tokens[] =
    {
        EX_RJT_MOVEON, EX_BACK_UP, GR_UNKNOWN_TYPE
    };
/*
    I am defining EPSILON to be a valid token number so I can
    make "epsilon" transitions when there is no input
*/
#   define EPSILON 3
#   define LOCATE (EPSILON+1)
#   define NUM_TOKENS (EPSILON+2)

#   define GENERATOR EPSILON
#   define DEADEND LOCATE

    enum TransitionTypes
    {
        epsilon, locat1, locat2, choice
    };
    
    enum actions
    {
        Nil, Err, Init, Ret, ErRet, UnHi, Make, PutQ, Erase, Disp
    };

#   define NUM_STATES 7
    enum states
    {
        start,  surf1,  surf2,   erase,   made,   disp,    error
    };

    static enum TransitionTypes transitions[NUM_STATES] =
    {
        locat1, locat2, epsilon, epsilon, choice, epsilon, epsilon
    };

    /* */ static /* */ IGRlong masks[NUM_STATES] =
    {
    /* start */ GRm_TEXT_VALUE | GRm_DATA,
    /* surf1 */ GRm_TEXT_VALUE | GRm_DATA,
    /* surf2 */ 0,
    /* erase */ 0,
    /*  made */ 0,
    /*  disp */ 0,
    /* error */ 0
    };

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:    RJT    BAK    UNK   EPS/G  LOC/E
    old state:  */
    /* start */ {start, start, start, error, surf1},
    /* surf1 */ {surf1, start, surf1, error, surf2},
    /* surf2 */ {error, error, error, erase, error},
    /* erase */ {error, error, error, made,  error},
    /*  made */ {error, error, error, disp,  start},
    /*  disp */ {error, error, error, error, error},
    /* error */ {error, error, error, error, error}
    };
    
    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:    RJT    BAK    UNK   EPS/G  LOC/E
    old state:  */
    /* start */ {Err,   Nil,   Ret,   ErRet, Nil},
    /* surf1 */ {Err,   UnHi,  Ret,   ErRet, UnHi},
    /* surf2 */ {ErRet, ErRet, ErRet, Erase, ErRet},
    /* erase */ {ErRet, ErRet, ErRet, Make,  ErRet},
    /*  made */ {ErRet, ErRet, ErRet, Disp,  Disp},
    /*  disp */ {ErRet, ErRet, ErRet, PutQ,  Err /* it was error before */},
    /* error */ {ErRet, ErRet, ErRet, ErRet, ErRet}
    };

    IGRint token;
    EMSrc omrc = OM_S_SUCCESS;
    EMSrc rc = OM_S_SUCCESS;

    switch (ME.super_cmd->mytype)
    {
    case GENERATOR:
        ex$message ( msgnumb = EM_M_EventGenerateNaturalSidesBet);
        break;
    case DEADEND:
        ex$message ( msgnumb = EM_M_GenerateNaturalSidesBetSfs);
        break;
    default:
        *response = TERMINATE;
        return OM_E_ABORT;
    }

    forever
    {
        struct GRevent event;
        OM_S_OBJID composite;
        OM_S_OBJID parts[6];

        switch (ME.ECnatsides->action)
        {
        case Nil:
#               if DEBUG
                (void)fprintf (stderr, "Nil action\n");
#               endif
            break;
        case Ret:
            {
#               if DEBUG
                (void)fprintf (stderr, "Ret action\n");
#               endif

                ME.ECnatsides->action = Nil;
                return omrc;
            }
            /* no break necessary */
        case Err:
            {
#               if DEBUG
                (void)fprintf (stderr, "Err action\n");
#               endif

                ex$message ( msgnumb = EMS_S_InvInp);

            }
            break;
        case ErRet:
            {
#               if DEBUG
                (void)fprintf (stderr, "ErRet action\n");
#               endif

                *response = TERMINATE;
                return OM_E_ABORT;
            }
            /* no break necessary */
        case Init:
            {
                extern OMuword OPP_EMSsubbs_class_id;

#               if DEBUG
                (void)fprintf (stderr, "Init action\n");
#               endif

                (void)strcpy (
                    ME.ECnatsides->attr.classes,
                    "EMSsubbs"
                );
                ME.ECnatsides->attr.properties =
                    LC_LC_ONLY |
                    LC_DP_ONLY;
                ME.ECnatsides->attr.owner_action =
                    LC_RIGID_OWNER |
                    LC_FLEX_COMP;

                me->rtree_classes.w_count = 1;
                me->rtree_classes.w_flags = OM_CLST_subclass;
                me->rclass = OPP_EMSsubbs_class_id;
                me->rtree_classes.p_classes = &me->rclass;

                me->elig_classes.w_count = 2;
                me->elig_classes.w_flags = OM_CLST_subclass;
                {
                    extern OMuword OPP_EMSsfimpbnd_class_id;

                    me->eliclass[0] = OPP_EMSsubbs_class_id;
                    me->eliclass[1] = OPP_EMSsfimpbnd_class_id;
                }
                me->elig_classes.p_classes = me->eliclass;
            }
            break;
        case UnHi:
            {
#               if DEBUG
                (void)fprintf (stderr, "UnHi action\n");
#               endif

                dp$erase_hilite (msg = &rc);
                (void)EMSmsgReport (rc, "ECnatsides execute UnHi", DEBUG);
            }
            break;
        case Make:
            {
                struct GRvg_construct list;
                EMSrc rc2 = EMS_E_UnusedCodeVariable;
                int ii = 3;

#               if DEBUG
                (void)fprintf (stderr, "Make action\n");
#               endif

                ex$message ( msgnumb = EMS_I_00003);

                list.msg = (IGRlong *)&rc2;
                list.env_info = &me->env;
                list.newflag = FALSE;
                list.level = me->layer;
                list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
                list.geometry = NULL;
                list.display = &me->display;
                list.class_attr = NULL;
                list.name = NULL;

                /* intentional block */
                {
                    extern IGRlong EFnaturalGeneralSolidFromSurfaces ();
                    extern void EFmessage ();

                    for (ii = 0; ii < 6; ii++)
                    {
                        parts[ii] = NULL_OBJID;
                    }
                    composite = NULL_OBJID;
                    rc = EMS_E_OperationFailed;

#                   if DEBUG
                    (void)fprintf (stderr,
                        "avant EF me0 %d me1 %d parts[0]\n",
                        me->locatedElement[0].objid,
                        me->locatedElement[1].objid
                    );
#                   endif

                    omrc = EFnaturalGeneralSolidFromSurfaces (
                        &rc,
                        my_id,
                        me->env.md_id.osnum,
                        me->locatedElement[0].objid,
                        me->locatedElement[1].objid,
                        &list,
                        parts,
                        &composite
                    );

                    EFmessage (rc);

#                   if DEBUG
                    (void)fprintf (stderr,
                      "apres EF me0 %d me1 %d parts[0] %d composite %d\n",
                        me->locatedElement[0].objid,
                        me->locatedElement[1].objid,
                        parts[0],
                        composite
                    );
#                   endif

                    if (EMSokay (rc))
                    {
                        parts[0] = composite;
                    }
                    else
                    {
                        if (IF_NULL_OBJID (composite))
                        {
                            /* no partial result exists;
                                if there is a graphic group, it is
                                in parts[0]
                             */
                            parts[1] = me->locatedElement[0].objid;
                            parts[2] = me->locatedElement[1].objid;
                        }
                        else /* partial result appears to exist */
                        {
                            parts[0] = composite;
                        }
                    }
                }

                me->locatedElement[0].objid = NULL_OBJID;
                me->locatedElement[1].objid = NULL_OBJID;
    
                if (EMSerror (omrc) OR EMSerror (rc))
                {
                    composite = NULL_OBJID;
                }

#               if DEBUG
                (void)fprintf (stderr,
                    "ECnatsides comp_id %d\n", composite);
#               endif
            }
            break;
        case PutQ:
            {
#               if DEBUG
                (void)fprintf (stderr, "PutQ action\n");
#               endif

#               if DEBUG
                (void)fprintf (stderr,
                    "ECnatsides comp_id %d\n", composite);
#               endif

                if (NOT IF_NULL_OBJID (composite))
                {
                    int spec_obj_response = EX_OBJID;
                    IGRint size;

                    size = sizeof (struct GRevent);

                    event.located_object[0].located_obj.objid =
                        composite;
                    event.located_object[0].located_obj.osnum =
                        me->env.md_id.osnum;
                    event.located_object[0].module_info = me->env;

                    ex$putque (
                        msg = (IGRlong *)&rc,
                        response = &spec_obj_response,
                        byte = (IGRlong *)&size,
                        buffer = (IGRchar *)&event.event
                    );

                    (void)EMSmsgReport (rc, "ECnatsides putQ", DEBUG);

#                   if DEBUG
                    (void)print_queue ();
#                   endif

                    *response = TERMINATE;
                    return OM_S_SUCCESS;
                }
            }
            /* break; not necessary ^^^ */
        case Erase:
            {
                int ii = 1;

#               if DEBUG
                (void)fprintf (stderr, "Erase action in state %d\n",
                    me^^super_cmd.state);
#               endif

                ex$message ( msgnumb = EMS_S_Erasing);

                do
                {
                    enum GRdpmode mode = GRbe;

#                   if DEBUG
                    (void)fprintf (stderr,
                        "Erasing os %d oi %d\n",
                        me->locatedElement[ii].osnum,
                        me->locatedElement[ii].objid
                    );
#                   endif

                    if (NOT IF_NULL_OBJID (me->locatedElement[ii].objid))
                    {
                        omrc = om$send (
                            msg = message GRgraphics.GRdisplay (
                                (IGRlong *)&rc,
                                &me->locatedEnv[ii].md_env.matrix_type,
                                me->locatedEnv[ii].md_env.matrix,
                                &mode,
                                &me->locatedEnv[ii].md_id
                            ),
                            targetid = me->locatedElement[ii].objid,
                            targetos = me->locatedElement[ii].osnum
                        );
                        (void)EMSmsgReport (omrc, "ECnatsides er", DEBUG);
                        (void)EMSmsgReport (rc, "ECnatsides rcer", DEBUG);
                    }
                } while (ii--);
            }

            ex$message (msgnumb = EMS_S_ClearStatusField);

            break;
        case Disp:
            {
                int ii = 5;

#               if DEBUG
                (void)fprintf (stderr, "Disp action\n");
#               endif

                do
                {
#                   if DEBUG
                    (void)fprintf (stderr, "ns Disp ii %d id %d\n",
                        ii, parts[ii]);
#                   endif

                    if (NOT IF_NULL_OBJID (parts[ii]))
                    {
                        enum GRdpmode mode = GRbd;

                        omrc = om$send (
                            msg = message GRgraphics.GRdisplay (
                                (IGRlong *)&rc,
                                &me->env.md_env.matrix_type,
                                me->env.md_env.matrix,
                                &mode,
                                &me->env.md_id
                            ),
                            targetid = parts[ii],
                            targetos = me->env.md_id.osnum
                        );
                        (void)EMSmsgReport (omrc, "ECnatsides ds", DEBUG);
                        (void)EMSmsgReport (rc, "ECnatsides rcds", DEBUG);
                    }
                } while (ii--);
            }
            break;
        default:
            {
                (void)EMSmsgReport (
                    OM_E_ABORT,
                    "ECnatsides execute action table possibly corrupt",
                    DEBUG
                );
                *response = TERMINATE;
                return OM_E_ABORT;
            }    
        } /* end switch (ME.ECnatsides->action) */

#       if DEBUG
            fprintf (
                stderr,
                "Before performing transition type %d for state %d\n",
                transitions[ME.super_cmd->state], ME.super_cmd->state
            );
#       endif

        switch (transitions[ME.super_cmd->state])
        {
        case epsilon:
            {
#               if DEBUG
                (void)fprintf (stderr, "epsilon transition\n");
#               endif

                token = EPSILON;
            }
            break;
        case choice:
            {
#               if DEBUG
                (void)fprintf (stderr, "choice transition\n");
#               endif

                switch (ME.super_cmd->mytype)
                {
                case GENERATOR:
                case DEADEND:
                    token = ME.super_cmd->mytype;
                    break;
                default:
                    (void)EMSmsgReport (
                        OM_E_ABORT,
                        "ECnatsides execute action invalid type",
                        DEBUG
                    );
                    *response = TERMINATE;
                    return OM_E_ABORT;
                }
            }
            break;
        case locat1:
        case locat2:
            {
                IGRuint size = sizeof (struct GRevent);
		IGRchar locate_prompt[80], accept_prompt[80], 
		        relocate_prompt[80];
                IGRlong display_flag =
                    ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;
                IGRboolean status;

#               if DEBUG
                (void)fprintf (stderr, "locate transition\n");
#               endif

		ex$message(msgnumb = EMS_P_00062, type = "%d",
			var = `(ME.super_cmd->state + 1)`, 
			buff = locate_prompt);

		ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
		ex$message(msgnumb = EMS_P_ElementNotFound, buff = relocate_prompt);
                status = lc$locate (
                    rc = &rc,
                    event1 = &event,
                    event2 = &event,
                    mask1 = masks[ME.super_cmd->state] | GRm_BACK_UP,
                    mask2 = GRm_DATA,
                    eventsize = &size,
                    display_flag = display_flag,
                    response = response,
                    response_data = response_data,
                    unhilight_mode = (enum GRdpmode) GRhd,
                    locate_prompt = locate_prompt,
		    acc_prompt = accept_prompt,
	            relocate_prompt = relocate_prompt,
                    attributes = &ME.ECnatsides->attr,
                    stack = &ME.ECnatsides->locate_stack,
                    rtree_classes = &me->rtree_classes, 
                    eligible_classes = &me->elig_classes
                );
                    
                if (status AND EMSokay (rc))
                {
                    int which = 0;

                    if (transitions[ME.super_cmd->state] IS locat2)
                    {
                        which = 1;
                    }

                    token = LOCATE;
                    me->locatedElement[which] =
                        event.located_object[0].located_obj;
                    me->locatedEnv[which] =
                        event.located_object[0].module_info;

#                   if DEBUG
                        (void)fprintf (
                            stderr,
                            "after lc$locate me->lE[%d].oid is %d\n",
                            which, me->locatedElement[which].objid
                        );
#                   endif                   
                }
                else
                {
                    token = GRloc_token (&rc, Tokens, &event);
                }

                rc = OM_S_SUCCESS;
            } /* end of case locate */
            break;
        default:
            {
#               if DEBUG
                    fprintf (stderr,
"Performing (default) transition type %d for state %d\n",
                    transitions[ME.super_cmd->state], ME.super_cmd->state);
                    fprintf (stderr,
"ECnatsides execute, invalid type of transition -- aborting\n");
#               endif
                *response = TERMINATE;
                return OM_E_ABORT;
            }
        } /* end switch (transitions[ME.super_cmd->state]) */
    
        ME.ECnatsides->action = NextAction[ME.super_cmd->state][token];
        ME.super_cmd->state = NextState[ME.super_cmd->state][token];
    } /* end forever, should never get here */

} /* method execute */

end implementation ECnatsides;
