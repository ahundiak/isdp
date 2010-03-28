class implementation ASsrctext ;
#include "fontdef.h"
#include "font.h"
#include "gotext.h"
#define AS_DEBUG

extern IGRboolean ASbroadcast_in_progress;

method   GRchgtextattr(IGRlong *msg; struct GRmd_env *module_env;
		       IGRuint attr; struct GRdpb_text_symb *text_symb)
{
IGRint status;
status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
status = ASchange_node(my_id,NULL);
return(status);
}


method GRchgtxstring(IGRlong *msg; struct GRdpb_text_symb *text_symb;
                      struct vfont_entry *font_info; IGRint num_positions;
                      IGRshort *positions[]; struct extents *text_extents)

{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method  GRgettxattr(IGRlong *msg; struct IGRestx *text_attr;
                    IGRshort *text_length; IGRuchar **text_string)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRtext.GRtxfillbuf( IGRlong *p_mess; IGRshort *p_mtyp; IGRmatrix matrix;
                           struct DPele_header *p_elhd )
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRfield_inquire(IGRlong *msg; IGRuchar *field_num;
                        IGRshort *type; IGRmatrix matrix; IGRshort *length;
                        IGRuchar **contents;
                        IGRuchar *attributes; struct extents *v_extents;
                        GRrange range; struct just_pts *v_fjust_pts)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method GRdpemptytext(IGRlong *msg; IGRboolean display; IGRshort *matrix_type;
                     IGRmatrix matrix)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRreplace_text(IGRlong *msg; struct GRmd_env *md_env;
                      IGRshort text_length;  IGRuchar *text_string)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
if (!ASbroadcast_in_progress) status = ASchange_node(my_id,md_env);
return(status);
}

method GRchange_flag(IGRlong *msg; IGRint set; IGRshort bitmask)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}



method GRpostabsg(IGRlong *msg; struct GRmd_env *md_env;
        struct GRpost_info *info; IGRchar *absptr; GRobjid *newobjid)
{
IGRint status;
status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
if (!ASbroadcast_in_progress) status = ASchange_node(my_id,md_env);
*newobjid = my_id;
return(status);
}
end implementation ASsrctext ;

