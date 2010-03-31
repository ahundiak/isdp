/* EMS properties definitions */

# ifndef EMSprop_include
# define EMSprop_include 1

/* The loopset properties are as follows(the properties apply if
   the corresponding bit set to 1).
*/
/*
* .... .... .... ...x     Loopset is natural
* .... .... .... ..x.     Loopset is split
* .... .... .... .x..     Loopset is non-modifiable
* .... .... .... x...     Loopset consists of model-space geometry
* .... .... ...x ....     Loopset created as a shell
*/

#define EMLS_NATURAL            0x0001
#define EMLS_SPLIT              0x0002
#define EMLS_NONMODIFIABLE      0x0004
#define EMLS_XYZ                0x0008
#define EMLS_SHELL              0x0010

/* The loop properties are as follows(the properties apply if the
   corresponding bit is set to 1).
*/
/*
* .... .... .... ...x   Loop is natural
* .... .... .... ..x.   Loop is split
* .... .... .... .x..   Loop represents neither an area or a hole region.
* .... .... .... x...   Loop is open
* .... .... ...x ....   Loop is reversed
* .... .... ..x. ....   Loop is a P loop
* .... .... .x.. ....   Loop is external(directly under Loopset)
* .... .... x... ....   Loop is new to the loopset
* .... ...x .... ....   Loop has a model-space counterpart
* .... ..x. .... ....   unused
* .... .x.. .... ....   Loop is currently active
* .... x... .... ....   Loop is a dummy C loop, introduced to avoid
                        nested P loop problems.
* ...x .... .... ....   Loop contains model-space geometry
*/
#define EMLP_NATURAL            0x0001
#define EMLP_SPLIT              0x0002
#define EMLP_NOAREA_NOHOLE      0x0004		
#define EMLP_OPEN               0x0008
#define EMLP_REVERSED           0x0010
#define EMLP_PLOOP              0x0020
#define EMLP_EXTERNAL           0x0040
#define EMLP_NEW                0x0080
#define EMLP_MSCEXISTS	        0x0100
#define EMLP_UNUSED2            0x0200		/* Unused */
#define EMLP_ACTIVE             0x0400
#define EMLP_DUMMY_CLOOP        0x0800
#define EMLP_XYZ		0x1000

/* The edge properties are as follows(the properties apply if the
   corresponding bit is set to 1)
*/
/*
* .... .... .... ...x   Edge is natural
* .... .... .... ..x.   Edge has a model-space counterpart
* .... .... .... .x..   Common edge has a model-space counterpart
* .... .... .... x...   Edge is open in UV space
* .... .... ...x ....   Edge is reversed to the direction of 
                         parametrization
* .... .... ..x. ....   Edge is reversed wrt its common edge
* .... .... .x.. ....   Edge is degenerate
* .... .... x... ....   Edge lies along an iso line.
* .... ...x .... ....   Edge is not displayed.
* .... ..x. .... ....   Edge is subordinant.
* .... .x.. .... ....   Edge is closed in (x,y,z) space.
* .... x... .... ....   Edge is a seam.
* ...x .... .... ....   Edge is compatible
* ..x. .... .... ....   Edge contains model-space geometry
* .x.. .... .... ....   Edge begin point is rounded
* x... .... .... ....   Edge end point is rounded
*/

#define EMED_NATURAL            0x0001
#define EMED_MSCEXISTS          0x0002
#define EMED_TANGENT            0x0004
#define EMED_OPEN               0x0008
#define EMED_REVERSED           0x0010
#define EMED_REVERSE_CONNECT    0x0020
#define EMED_DEGENERATE         0x0040
#define EMED_ISO                0x0080
#define EMED_NO_DISPLAY         0x0100
#define EMED_SUBORDINATE        0x0200
#define EMED_XYZ_CLOSED         0x0400
#define EMED_SEAM               0x0800
#define EMED_COMPATIBLE         0x1000
#define EMED_XYZ                0x2000
#define EMED_BEG_ROUNDED        0x4000
#define EMED_END_ROUNDED        0x8000


/*
 * BS properties
 */

#define EMBS_PERIODIC           0x0001
#define EMBS_NON_UNIFORM	0x0002
#define EMBS_RATIONAL		0x0004


/* DPR properties*/
#define EMS_UNEVAL_STATE        0x01
#define EMS_NULL_STATE          0x02
#define EMSIS_ACTIVE_STATE      0x04
#define EMSIS_ACTIVE_PATH       0x08
#define EMS_CONVERTED_TO_CS     0x10
#define EMS_MULT_BOOL           0x20
#define EMS_PERFORM_REEX        0x40
#define EMS_ORIENT_FLIPPED      0x80
#define EMS_MACRO_STATE        0x100
#define EMS_USER_SUPPRESSED    0x200           
#define EMS_DELETED            0x400
#define EMS_PATTERN_FEATURE    0x800
#define EMS_POST310_OBJECT     0x1000

/******************DPR PROPERTIES NOTES*************************************

EMS_UNEVAL_STATE - DPR is unevaluated. This can occur due to being affected by
                   a change, or in the process of checking for a change (such
                   as during a model update).  Note that a state in an
                   unevaluated mode can be restored without a recompute so long
                   as the EMS_NULL_STATE bit is NOT set.
                   Will ALWAYS be set if the DPR is in any kind of a suppress
                   mode (FAIL, USR_SUPPRESS, DELETE).                    
EMS_NULL_STATE - DPR node is null (suppressed) due to overlap being detected
                 during update, recompute failure, feature deletion or 
                 feature suppression.
EMSIS_ACTIVE_STATE - DPR is active.  Only the top state will be marked in 
                     a stable environment.  During a recompute this bit may be
                     set lower in the tree indicating the tree has been
                     partially undone.
EMSIS_ACTIVE_PATH - DPR is in active path.  All states below the ACTIVE_STATE
                    will have this bit set while all states above will not.
EMS_CONVERTED_TO_CS - Recompute caused the solid to become open and therefore
                converted to a composite surface.  Setting this bit will force
                each update to attempt to convert the composite surface back to
                a solid.
EMS_MULT_BOOL - was being set in 1.4.0 as a way to do multiple booleans and
                allow only 1 undo.  For 2.0 the code was changed to use a
                macro state to handle the undo.  Therefore the code to do
                this type of multiple boolean no longer is called and has
                been removed.  A special EMmult_undo message exists to use this
                bit.  Since the bit remains set from 1.4.0 files, the bit 
                definition must remain along with the EMmult_undo message.
EMS_PERFORM_REEX - Preform reexecute during redo. Used prior to 2.0.  Can this
                   be removed????? 
EMS_ORIENT_FLIPPED - Used during the recompute process to handle DPR operations
                     which flip pos_orient normals of surfaces (booleans
                     only?).  Since this is set only during uneval and eval
                     operations the filed os should never have this bit set!
EMS_MACRO_STATE - Used to allow multiple DPR nodes to be considered as 1
                  operation (such as features).  If set there MUST be an owner
                  DPR of class EMSsfmacro (or subclass) that is controlling
                  this DPR.  The undo process will undo thru all MACRO DPRS.
EMS_USER_SUPPRESSED - Used to allow a user to temporarily suppress a DPR
                      operation (typically features).  If set, a model update
                      will NOT attempt to recompute ths DPR node.  
EMS_DELETED - Used to allow a user to delete a DPR operation.  This bit allows
              the deletion without having to cut out the DPR node from the
              graph.  Also, the "delete feature" command must be able to 
              undo the deletion which also makes this bit necessary. The DELETE
              bit is needed in place of the USER_SUPPRESSED bit since the
              "unsuppress feature" command must be able to distinguish a user
              suppress feature from a delete feature.               

**+++NOTE+++*** - DPR nodes marked by EMS_NULL_STATE, EMS_USER_SUPPRESS, &
                  EMS_DELETED may have a child suppress object if the DPR 
                  created geometry when it was alive.
******************/




/*
 * Flags for the execute-curve-function function.
 */
# define EMS_EDGE_CURVE         0x1
# define EMS_FIRST_EDGE         0x2


/* 
 * Solid/surface split with surface properties.
 */

#define EMsws_IsOriginal	0x0001
#define EMsws_HistoryKept	0x0002

/* 
 * Properties of a fillet surface.
 */

#define EMSfillet_surf_is_a_fillet     0x01 /* first  surface itself is a
                                             * fillet surface.  */
#define EMSfillet_com_surf_is_a_fillet 0x02 /* second surface itselef is a
                                             * fillet surface.  */
#define EMSfillet_ed_is_xyz_closed     0x04 /* the edge for which the fillet 
                                             * is created is closed in model
                                             * space. */
#define EMSfillet_v0_is_degenerate     0x08 /* v=0.0 end of the fillet goes 
                                             * to a point. */
#define EMSfillet_v1_is_degenerate     0x10 /* v=1.0 end of the fillet goes
                                             * to a point. */
#define EMSfillet_v0_closeto_start_end 0x20 /* v=0.0 end of the fillet is
                                               closer to the start end of
                                               the edge. */
#define EMSfillet_is_variable_radius   0x40

#define EMSrnd_input_ed_grp_start      0x80

#define EMSfillet_inaccurate_atstart   0x100

#define EMSfillet_inaccurate_atstop    0x200

#define EMSrnd_mark_ed_deleted	       0x400  /* edge marked as deleted */

# endif
