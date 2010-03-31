/* header file for place cross-section surface command */

/*---global defines---*/
/* for EFget_curve_information */
#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2
#define LITTLE_ELEMENT 3
#define ANY_ELEMENT 4
#define BIG_SURFACE 5

/* command states */
#define INITIALIZE           0
#define TRACE_CURVES         1
#define PARALLEL_TO_PLANE    2
#define VEC_DIRECTION        3
#define GET_VECTOR           4
#define SURFACE_NORMAL       5
#define GET_SURFACE          6
#define CROSS_CURVES         7
#define PROCESS              8

/* substates for hangup_method */
#define SET_ORIGIN      1
#define SET_LOCATION    2
#define SET_MIRROR_CASE 3
#define SET_ANGLE       4
#define SET_ORIENTATION 5

/* FORMS */
#define CS_OPTIONS_FORM	100

/* for switching dependend on me->mytype */
#define SURFACE 0

/* for points to create, if screen position selection */
# define COLOR 2
# define WEIGHT 2

/*---defines for CS_OPTIONS FORM---*/
#define CSOp_SMOOTH_TGL          22
#define CSOp_SMOOTH_TXT          21
#define CSOp_TANGENCY_TGL        17
#define CSOp_TANGENCY_TXT        18
#define CSOp_COORDS_FLD          15
#define CSOp_COORDS_TXT          16
#define CSOp_POINT_TXT           25
#define CSOp_POINT_TGL           24
#define CSOp_ANGLE_TXT           26
#define CSOp_ANGLE_TGL           27
#define CSOp_STEP_FLD            12
#define CSOp_STEP_TXT            13

struct CSsf_wrk_t
{
    IGRdouble  refpln[12];             /*ref.plane data (x,y,z -vec & origin)*/
    IGRdouble  parpln[3];              /*par.plane data (z -vec) or direct.vec */
    IGRdouble  orig_sect[3];           /*origin of current section */
    IGRdouble  dyn_step;               /*step size for angle dynamics */
    GRobjid    crs_refpl_id;
    struct     GRid tmp_crv;
    struct     IGRbsp_curve *trace_geom;
    struct     IGRbsp_curve *css_geom;
    struct     IGRbsp_surface *srf_geom;
    IGRint     mirror_case;
    IGRint     toggle_case;            /*toggle orientation of angles ? */
    IGRuchar   coord_default[21];      /*forms text manipulation */
    IGRboolean loc_coord;              /*TRUE = we need a coordsys */
    IGRboolean repaint;                /*set in sleep, to check in wakeup */
    struct CSsf_coords                 /*remember data of trace coord_system */
    {
       GRrange		range;
       struct		IGRdisplay display;
       IGRdouble	csys[12];
    } coords;
    IGRdouble  dyn_csys[12];           /*coord_system data of current CS for dynamics */
};

struct DYrotang_info
{
    IGRint                  num_buffs;
    struct DPele_header    *display_buffers;
    struct IGRbsp_curve    *bscurve;
    struct IGRbsp_curve    *trace;
    struct IGRbsp_surface  *srf;
    IGRdouble               refplane[12];
    IGRdouble               orig_xsect[3];
    IGRdouble               param;
    IGRint                  bs_case;
    IGRdouble               vec[3];
    IGRint                  mirror;
    IGRint                  mirr_toggle;
    struct IGRplane         plane;
    IGRvector               start_vec;
};

/*------- routine headers ----------------------------------------------*/

/* ECprfsksfi.I */

extern void EFget_parents_and_info (IGRlong *EMmsg, struct GRid *obj_GRid, IGRuint *type,
IGRuint *info_size, IGRchar *info, IGRint *num_parents, struct GRid *parents);

extern IGRboolean EFisAncestryValid(IGRlong *EMmsg, GRobjid child_objid,
OMuword child_osnum, OMuword parent_classid, IGRboolean validate_child);

extern IGRint GRget_to_owner_info(OM_S_CHANSELECT *p_chansel, OMuword osnum,
                                  OM_S_OBJID objid, IGRint *p_count);

/* EMcsprfdyn.I */

extern IGRint DYrotang_dyn (struct DYrotang_info *dyn_info, struct EX_button *to_point,
IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers,
IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3,
IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3);

extern void EFcalc_turn_angle (IGRlong *msg, IGRpoint point, struct IGRplane *plane,
IGRmatrix view, IGRvector start_vec, IGRint mirr_toggle, IGRdouble *angle);

