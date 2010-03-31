class specification HSplacelite (1:0) of CEO_LOCATE;



#include "hslight.h"


instance HSplacelite
{
    short                  changing_ambient; /* TRUE, if changing ambient light */
    short                  new_light;        /* TRUE, if defining a new light */
    short                  save_restore;     /* TRUE, if the form is Save/Restore */
    short                  init_rgb_called;  /* TRUE, if HRinit_rgb() has been called */
    short                  scale;            /* Percentage or absolute scale to be used for RGBs */
    double                 max;              /* Max value for sliders */
    int                    curr_lite;        /* current light source # */
    int                    next_state;       /* next state to go to */
    unsigned int           light_flags;
    struct HS_light_source light;
    struct HS_light_source ambient;
    unsigned short         *sph_amb;
    int                    color_plane;
    WLhwin_no              hwin_no;
    WLuint16               lscreen_no;
    WLuint32               context_no;
    WLuint32               lwin_no;
    int                    allocated_window;
    };


message init_command ( long * sts );

message restore_color_table ( long * sts );

message free_buffer ( long * sts );

message which_state ( long * sts );

message process_backup ( IGRint *sts; IGRint current_state );

message display_prompt ( IGRint *sts; IGRint current_state );

message process_light_num ( IGRint *sts; IGRint use_default );

message process_origin ( IGRint *sts; IGRint use_default );

message process_target ( IGRint *sts; IGRint use_default );

message process_radius ( IGRint *sts; IGRint use_default );

message process_angle ( IGRint *sts; IGRint use_default );

message process_window ( IGRint *sts; IGRint use_default );

message get_2d_point ( long * sts );

message init_form_display ( long * sts );

message init_form ( long * sts );

override form_notification;

message read_light_source ( long * sts );

message read_ambient ( long * sts );

message store_light_source ( long * sts );

message store_ambient ( long * sts );

message read_sphere ( long * sts );

message display_sphere_init ( long * sts );

message draw_on_form ( long * sts );

end specification HSplacelite;
