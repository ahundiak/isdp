/*
Name
        grdpb.h

Description
        This file contains definitions used by the Default Parameter
        Block subsystem.

History
        pth     09/08/87    creation
        scw     08/02/91    Added auto accept flag
        scw     08/06/91    Added change active coordinate system
                            type flag
        scw     02/02/92    Added model reference plane lock flag
        hgb     05/20/93    Added smart sketch constraint elligibility
        WBC     06/30/93    Used one of the DPB_BOOLEAN bits as a toggle
                            to indicate if the necessary elements should be
                            created so that the file can be used as an
                            associative read-only reference file.
       Gang     08/12/93    Added reference file shrink_wrap and background
                            flags.
*/

#ifndef grdpbdef_include
#define grdpbdef_include

/* definitions used to map gr_get... and gr_put... to the proper value */

#define grdpb_chord_height_tolerance     0
#define grdpb_offset_tolerance 		 1
#define grdpb_arclength_tolerance	 2
#define grdpb_basis_tolerance 		 3
#define grdpb_maximum_step_size		 4 
#define grdpb_hidden_surf_sym 		 5
#define grdpb_patrn_edge_delta 		 6
#define grdpb_active_angle 	         7
#define grdpb_patrn_area_deltas	         8
#define grdpb_active_display	         9
#define grdpb_model_mode		10
#define grdpb_bore_locate 	        11
#define grdpb_apparent_flag		12
#define grdpb_dit_tolerance	        13
#define grdpb_last_point		14
#define grdpb_display_env               15
#define grdpb_locate_env		16
#define grdpb_module_env		17
#define grdpb_model_env			18
#define grdpb_active_scale              19
#define grdpb_arc_direction		20
#define grdpb_active_prop		21
#define grdpb_database_type     	22
#define grdpb_active_cs_type		23
#define grdpb_text_symb		        24
#define grdpb_active_level		25
#define grdpb_local_abs                 26
#define grdpb_name_mode			27
#define grdpb_raster_graphics           28
#define grdpb_unit_lock                 29
#define grdpb_projection_angle          30
#define grdpb_dynamics_on	        31
#define grdpb_dynamics_all_windows      32
#define grdpb_dynamics_copy_flag	33
#define grdpb_xhatch_spacing            34
#define grdpb_xhatch_angle              35
#define grdpb_locate_levels             36
#define grdpb_locate_properties         37
#define grdpb_associative_flag          38
#define grdpb_brush_type                39
#define grdpb_hesym                     40
#define grdpb_auto_accept_flag          41
#define grdpb_change_acs_type           42
#define grdpb_invis_so_on               43
#define grdpb_hidden_so_on              44
#define grdpb_visible_edge_sym          45
#define grdpb_mrp_lock                  46
#define grdpb_smart_sketch_constraints  47
#define grdpb_smart_sketch_on		48
#define grdpb_assoc_read_only_reffile   49
#define grdpb_ref_shrink_wrap_flag      50
#define grdpb_ref_background_flag       51

/* dpb version */
/* note:  versions 2 and 3 were for EMS 3 */
#define DPB_VERSION                     3

/* bit field interpretation for DPB_BOOLEAN */

#define DPB_LOCAL_ABS_FLAG          0x0001
#define DPB_ARC_DIRECTION           0x0002  /* TRUE => ccw; FALSE => cw */
#define DPB_APPARENT_FLAG           0x0004
#define DPB_BORE_LOCATE             0x0008
#define DPB_DYNAMICS_ON             0x0010
#define DPB_DYNAMICS_ALL_WINDOWS    0x0020
#define DPB_DYNAMICS_COPY_FLAG      0x0040
#define DPB_ASSOCIATIVE_FLAG        0x0080
#define DPB_AUTO_ACCEPT_FLAG        0x0100
#define DPB_CHANGE_ACS_TYPE         0x0200
#define DPB_INVIS_SO_ON             0x0400
#define DPB_HIDDEN_SO_ON            0x0800
#define DPB_MRP_LOCK                0x1000  /* model reference plane lock */
#define DPB_ASSOC_READ_ONLY_REFFILE 0x2000
#define DPB_REF_SHRINK_WRAP_FLAG    0x4000
#define DPB_REF_BACKGROUND_FLAG     0x8000

/* macros for manipulating unsigned char arrays as boolean flags */

#define CHECK_BIT(a,n)          ((*(((char*)a)+(n/8)) & (1<<(n%8)))?1:0)
#define SET_BIT(a,n)            (*(((char*)a)+(n/8)) |= (1<<(n%8)))
#define CLEAR_BIT(a,n)          (*(((char*)a)+(n/8)) &= ~(1<<(n%8)))
#define ASSIGN_BIT(a,n,v)       ((v)?SET_BIT(a,n):CLEAR_BIT(a,n))

/* definitions for hidden edge symbology overrides */

#define DPB_USE_ORIG_COLOR      0x01
#define DPB_USE_ORIG_WEIGHT     0x02
#define DPB_USE_ORIG_STYLE      0x04

/* definitions to indicate which bar menu is active */

#define GR_UNKNOWN_MODE         0
#define GR_MODEL_MODE           1
#define GR_DETAIL_MODE          2

/* misc definitions */

#define DRAWING_MODE        0
#define MODEL_MODE          1
#define SELECTIVE_MODE      2
#define MAX_FUNCKEY_NAME    80
#define MAX_DB_TYPE_SIZE    3
#define MAX_CS_TYPE	    24	
#define MAX_SHORT           (0xffff)

#define DPB_COMMENT         0x23   /* this is the character # */
#define DPB_INQ             0
#define DPB_SET             1

#define DPB_NAME_LENGTH     16
#define DPB_LOCATABLE       0x0001
#define DPB_ACTIVE_ENTRY    0x0002

#define DPB_LOCATE_ON	        1

#define DPB_END_PARAM    	0
#define DPB_BASE_NAME    	1
#define DPB_INCREMENT    	2
#define DPB_BASE_NUMBER  	3
#define DPB_CLASSID      	4
#define DPB_NEXT_NAME    	5
/*
#define DPB_NAME_MODE    	6
*/
#define DPB_NUMBER_CLASSES_LOC	7
#define DPB_CLASSES_LOC	 	8
#define DPB_NUMBER_CLASSES 	9
#define DPB_CLASSES 	 	10
#define DPB_PROPERTIES   	11
#define DPB_GRAPHICS            12
#define DPB_ADD_CLASSLIST       13
#define DPB_SET_LAYER           14
#define DPB_SET_PROPERTIES      15
#define DPB_GET_CLASSES         16
#define DPB_GET_LAYER           17

#define DPB_EOLN	        10

/*
 * Bit fields for the Smart Sketch: when the bit is on, the
 * constraint is recognized.
 */
#define DPB_SS_HORIZONTAL	0x00000001
#define DPB_SS_VERTICAL		0x00000002
#define DPB_SS_ON_ELEMENT	0x00000004
#define DPB_SS_TANGENT		0x00000008
#define DPB_SS_PARALLEL		0x00000010
#define DPB_SS_PERPENDICULAR	0x00000020
#define DPB_SS_INTERSECTION	0x00000040
#define DPB_SS_KEYPOINT		0x00000080
#define DPB_SS_TEXTDISPLAYED    0x80000000
#endif
