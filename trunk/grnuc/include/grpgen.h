/*
Name
        grpgen.h

Description
        This file contains structures used by the group generator
        commands.

Dependencies
        igrtypedef.h, igetypedef.h, grdpbdef.h, grdpb.h, gr.h

History
        mrm     05/08/91    creation
*/

#ifndef grpgen_include
#define grpgen_include

/*
    This structure is used by the generate set form.  It is essentially
    a combination of the structures GRrp_action_args and
    GRsymb_action_args, which are defined in grgs.h
*/

struct COsymbact
{
    IGRint rp_relation;         /* desired prism relationship */
    IGRint clip_flag;           /* clip indicator */
    IGRint symb_set;            /* see grpgendef.h */
    IGRuchar *weight;   /* each bit represents a weight */
    IGRuchar *color;    /* each bit represents a color */
    IGRuchar *style;    /* each bit represents a style */
    struct GRid gs_id, sv_id;
};

/*
    This structure is used by the Generate Set command/form
*/

struct COgenset_info
{
    int elclass_count;
    struct GRelclass_f *elclass;
    int classlist_changed;
    OM_S_OBJID *grset;
    struct GRmd_env *mod;
    IGRint *obj_count, *mod_count;
    Form *forms;
};

#endif
