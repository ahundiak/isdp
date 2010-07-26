class specification COtext (1:0) of CEO_LOCATE;



#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "dpstruct.h"


instance COtext
{
    struct GRvg_construct    cnst_lis;      /* construction list             */
    struct GRdpb_text_symb   text_symb;     /* text symbology                */
    struct extents           text_extents;
    struct extents           just_extents;  /* justified extents of the text */
    struct vfont_entry       font_info;     /* font information              */
    struct IGResintx         tx_attr;       /* cnst text specific attr       */
    struct IGRestx           text_attr;     /* text specific attributes      */
    struct IGRlbsys          lbs_geom;      /* local bounded system geometry */
    struct DPele_header      elem;          /* information for dynamics      */
    struct EX_button         origin_button; /* save origin as a button       */
    IGRlong                  cnst_lis_msg;  /* return msg from construct     */
    GRspacenum               cur_mod_osnum; /* current module's osnum        */
    IGRchar                  empty_tx_name[GR_MAX_CHAR]; 
                                            /* empty text element's name     */
    IGRuchar                 *text_string;  /* pointer to text string        */
    GRclassid                classid;       /* classid of object             */
    IGRshort                 text_length;   /* length of string in bytes     */
    IGRshort                 text_buf_size; /* # of bytes currently allocated*/
                                            /* for text_string               */
    IGRint                   viewind;       /* type of view independence     */
    IGRboolean               dyn_on;        /* flag to indicate if dynamics  */
                                            /* are on (1 == on, 0 == off)    */
    IGRpoint                 origin;        /* origin point of text object   */
    IGRmatrix                rot_matrix;    /* rotation matrix of view origin
                                               was placed in                 */
    IGRmatrix                wld_view_mtrx; /* world to view transformation
                                               matrix                        */
};


override init;

override pre_sleep;

override wakeup;

override delete;

message append_text_to_buffer ();

message clear_buffer ();

override dynamics;

message store_origin ();

message get_view_rot_matrix ();

message init_text_attr ();

message construct_text ();

message is_it_empty_text ();

message calc_angle_size ();

message get_construct_attr ();

message named_empty_text ();

message empty_text_no_name ();

message set_empty_flag ();

message check_dynamics ();

message dyn_set_prompt (long dyn_prompt, non_dyn_prompt);

end specification COtext;
