/*
Name
        lcdef.h

Description
        This file contains definitions used by the locate subsystem.

Dependencies
        None

History
        rc      ??/??/??    creation
        mrm     07/12/91    change mask definitions to hex (no value changes)
                09/12/91    change default for highlight to ALL_WINDOWS
                05/04/92    added locate info flags
*/

#ifndef lcdef_include
#define lcdef_include

/*
        Definitions for the properties field of struct GRlc_locate
*/

#define IGN_LC_BIT           0x00000000 /* ignore locate bit check */
#define LC_LC_ONLY           0x00000001 /* locate locateable objects only */
#define LC_NONLC_ONLY        0x00000002 /* locate non locatable objects only */
#define LC_LC_NONLC          0x00000003 /* locate both types of objects  */

#define IGN_RW_BIT           0x00000000 /* ignore read-write bit check */
#define LC_READ_ONLY         0x00000004 /* locate readable objects */
#define LC_WRITE_ONLY        0x00000008 /* locate writable objects */
#define LC_RW                0x0000000c /* locate readable and writable objs */

#define IGN_DP_BIT           0x00000000 /* ignore display bit check */
#define LC_DP_ONLY           0x00000010 /* locate displayable objects only */
#define LC_INVIS_ONLY        0x00000020 /* locate invisible objects only */
#define LC_DP_INVIS          0x00000030 /* locate displayable and invisible
                                           objects */
#define IGN_MOD_BIT          0x00000000 /* ignore modified bit check */
#define LC_NEW_ONLY          0x00000040 /* locate new objects only */
#define LC_MOD_ONLY          0x00000080 /* locate modified objects only */
#define LC_NEW_MOD           0x000000c0 /* locate new and modified objects */

#define IGN_PLANAR_BIT       0x00000000 /* ignore planar bit check */
#define LC_PLANAR_ONLY       0x00000100 /* locate planar objects only */
#define LC_NON_PLANAR_ONLY   0x00000200 /* locate non planar only */
#define LC_PLANAR_NON_PLANAR 0x00000300 /* locate planar and non planar */

#define IGN_PHY_OPEN_CLOSED  0x00000000 /* ignore object closure */
#define LC_PHY_CLOSED        0x00000400 /* locate physically closed objects */
#define LC_PHY_OPEN          0x00000800 /* locate only open objects */
#define LC_PHY_OPEN_CLOSED   0x00000c00 /* locate closed and open objects */

/*
        Definitions for the owner_action field of struct GRlc_locate.
*/

#define LC_RIGID_COMP           0x00000001 /* [do not] locate rigid          */
#define LC_NO_RIGID_COMP        0x00000000 /* components                     */

#define LC_RIGID_OWNER          0x00000002 /* [do not] locate rigid owners   */
#define LC_NO_RIGID_OWNER       0x00000000 /* (buggy, see below)             */

#define LC_FLEX_COMP            0x00000004 /* [do not] locate flexible       */
#define LC_NO_FLEX_COMP         0x00000000 /* components                     */

#define LC_FLEX_OWNER           0x00000008 /* [do not] locate flexible       */
#define LC_NO_FLEX_OWNER        0x00000000 /* owners (buggy, see below)      */

#define LC_OBJ_W_OWNER          0x00000010 /* [do not] locate objects with   */
#define LC_NO_OBJ_W_OWNER       0x00000000 /* owners                         */

#define LC_REF_HEADER           0x00000000 /* [do not] locate reference file */
#define LC_NO_REF_HEADER        0x00000020 /* headers                        */

#define LC_REF_OBJECTS          0x00000040 /* [do not] locate elements in    */
#define LC_NO_REF_OBJECTS       0x00000000 /* reference files                */

#define LC_TOP_DOWN             0x00000000 /* locate owners from the top     */
#define LC_BOTTOM_UP            0x00000080 /* down (as opposed to bottom up) */

#define LC_NO_INTERMEDIATE      0x00000000 /* [do not] locate intermediate   */
#define LC_INTERMEDIATE         0x00000100 /* nodes in an owner hierarchy    */
#define LC_INTERMIDIATE         0x00000100

#define LC_NO_ASSOCIATIVE       0x00000000 /* [do not] locate associative    */
#define LC_ASSOCIATIVE          0x00000200 /* objects                        */

#define LC_NO_EXTERN_CONST      0x00000000 /* [do not] locate externally     */
#define LC_EXTERN_CONSTRAINED   0x00000400 /* constrained objects            */

#define LC_CONTINUE_ON_ASSOC    0x00000000 /* [do not] stop after processing */
#define LC_STOP_ON_ASSOC        0x00000800 /* an associative object          */

#define LC_NO_INVIS_OVERRIDE    0x00000000 /* [do not] locate invisible      */
#define LC_INVIS_OVERRIDE       0x00001000 /* symbology overrides            */

#define LC_NO_LOCALMOD          0x00000000 /* used to indicate that a local  */
#define LC_LOCALMOD             0x00002000 /* modification command is doing  */
                                           /* the locate and is doing a      */
                                           /* write even though it claims to */
                                           /* be doing a read                */

#define LC_HANDLES              0x00004000 /* Only if this owner action is   */
#define LC_NO_HANDLES           0x00000000 /* specified will the locate of   */
                                           /* an owner/components will take  */
                                           /* place.  This is used to        */
                                           /* disable locates of graphic     */
                                           /* handles in most situations.    */

#define LC_NO_RIGID_OWNER_WORKS 0x00008000 /* These definitions are provided */
#define LC_NO_FLEX_OWNER_WORKS  0x00010000 /* to work around a bug in the    */
                                           /* owner locate mechanism which   */
                                           /* allows both rigid and flexible */
                                           /* owners to be located even      */
                                           /* without setting the            */
                                           /* LC_RIGID_OWNER or the          */
                                           /* LC_FLEX_OWNER.  The bug's      */
                                           /* behavior is expected by        */
                                           /* numerous commands, and fixing  */
                                           /* it would be worse that the     */
                                           /* problems it causes.  This      */
                                           /* workaround allows commands     */
                                           /* which really don't want owners */
                                           /* to obtain that functionality.  */

#define LC_RIGID_COMP_PRISM     0x00020000 /* [Do not] locate rigidly owned  */
#define LC_NO_RIGID_COMP_PRISM  0x00000000 /* objects by prism (e.g. fence). */
                                           /* Locating rigid components      */
                                           /* works only for read-only       */
                                           /* operations.                    */

#define LC_MOVE_CMD             0x00040000 /* This bit is only set by the    */
                                           /* Move command.                  */

#define LC_DELETE_CMD           0x00080000 /* This bit is only set by the    */
                                           /* Delete command.                */

/*
        The following definitions are for the purpose of classifing
        commands into categories of geometric modification or non
        geometric modification.  
*/

#define LC_GEOM_MOD     LC_FLEX_OWNER | LC_FLEX_COMP | LC_RIGID_OWNER
#define LC_NON_GEOM_MOD LC_RIGID_COMP | LC_FLEX_COMP | \
                        LC_FLEX_OWNER | LC_RIGID_OWNER

/*
        The following definition should be used when a command is
        performing an operation that is read only.  
*/
        
#define LC_READ         LC_RIGID_COMP | LC_FLEX_COMP | \
                        LC_FLEX_OWNER | LC_RIGID_OWNER

/*
        The following definitions are for use with the display_flag
        arguments to lc$locate.
*/

#define ALL_WINDOWS          0x00000000 /* hilite located objects in all
                                           windows */
#define ONE_WINDOW           0x00000001 /* hilite located objects only in
                                           the window in which they are
                                           located */

#define SEGMENT_HILIGHT      0x00000000 /* hilite object segment and
                                           extensions */
#define ELEM_HILIGHT         0x00000002 /* hilite entire object */

#define PROJ_ACCEPT_POINT    0x00000000 /* project the user's accept point
                                           onto the object - expensive, use
                                           only when necessary */
#define NO_PROJ_ACCEPT_POINT 0x00000004 /* don't project the accept point */

#define NO_ACC_REJ_CYCLE     0x00000008 /* don't ask the user to accept
                                           located objects */
#define ACC_REJ_CYCLE        0x00000000 /* ask the user to accept
                                           located objects */

#define DO_NOT_RELOCATE      0x00000010 /* exit the locate filter if the
                                           user's input does not identify
                                           any objects */
#define RELOCATE             0x00000000 /* prompt the user for more input */

#define LC_HALF_HIGHLIGHT    0x00000020 /* use half-hilite to display
                                           located objects */
#define LC_REGULAR_HIGHLIGHT 0x00000000 /* use normal hilite */

#define LC_ERASE_LOC_ELEMENT 0x00000040 /* unhilite only the rejected object */
#define LC_ERASE_ALL         0x00000000 /* unhilite by erasing the entire
                                           hilite plane */

#define LC_ACCEPT_CURSOR     0x00000080 /* display the locate cursor during
                                           the accept phase (useful during
                                           chain locates) */

#define LC_ACC_ONE_ELEMENT   0x00000100 /* if a data point uniquely identifies
                                           exactly one object, return it 
                                           without asking the user
                                           to accept it */

#define LC_INPUT_LOC_POINT   0x00000200 /* force the user to enter a data
                                           point when an object is located
                                           by name */

#define LC_RETRIEVE_CRITERIA 0x00000400 /* retrieve the locate criteria of
                                           the previous command */
#define LC_Retrieve_Criteria 0x00000400

#define LC_ACC_TWO_ELEMENT   0x00000800 /* if a data point uniquely
                                           identifies exactly two objects,
                                           return them without asking the
                                           user to accept them */

#define LC_IGNORE_FIRST_MISS 0x00001000 /* Do not issue the relocate prompt if
                                           the user's first input does not
                                           identify an object.  Useful in
                                           chain locates when the locate point
                                           is also the previous object's
                                           accept point, especially when some
                                           status message may be overwritten
                                           before the user has a shot at it.
                                           Subsequent misses will display the
                                           relocate prompt as usual. */

/*
        Definitions for the type argument to lc$locate
*/

#define LC_DPB_LOCATE           0       /* default in macro */
#define LC_BL_LOCATE            1
#define LC_PT_LOCATE            2

/*
        Definitions for the regex argument to lc$locate
*/

#define LC_REGEX_ON               1
#define LC_REGEX_OFF              0     /* default */
         
/*
        Return codes from lc$locate
*/

#define LC_NO_OBJ_LOCATED       0
#define LC_OBJ_LOCATED          1
#define LC_OBJS_IN_STACK        2
#define LC_ONE_ELEM_ACCEPT      3
#define LC_TWO_ELEM_ACCEPT      5

/*
        Definition for the maximum size of the locate stack.
*/

#define MAX_LCSTACK_LEN          10

/*
        Additional return codes for select handlers
*/

#define LC_RELOCATE             3
#define LC_UNKNOWN_TYPE         4
#define LC_BACKUP               5

/* 
        For use in lc$index macro
*/

#define LC_ADD_INDEX           0
#define LC_ACTIVATE_INDEX      1
#define LC_DEACTIVATE_INDEX    2

/*
        For use in lc$check_id -- mode values
*/

#define LC_CHECK                0
#define LC_DELETE               1
#define LC_ADD                  2
#define LC_ADD_CHECK            3
#define LC_DEL_CHECK            4

#define LC_ID_FOUND             1
#define LC_ID_NOT_FOUND         2

#define LC_APPARENT             0
#define LC_PTPROJECT            1
#define LC_LNPROJECT            2

#define LC_PTBL_ACTION          0
#define LC_ACCEPT_ONE_ACTION    1
#define LC_EVENT_ACTION         2

/*
        Definitions used by the locate criteria stacking mechanism
*/

#define LC_NO_CRITERIA          0
#define LC_CRITERIA             1
#define LC_PASS_CRITERIA        2

#define LC_Locate_Point         1
#define LC_Other_Point          0

/*
	These definitions are used to output information during the locate
        process, primarily for debugging purposes.
*/

#define GRObjectHit             0x00000001
#define GRObjectEligible        0x00000002
#define GRObjectIneligible      0x00000004
#define GRVerboseLocateInfo     0x00000008
#define GROwnerInfo             0x00000010
#define GRLocateFilterOutput    0x00000020

/*
        Miscellaneous definitions
*/

#define LC_NO_MSG              -1

#define LC_DPB                  0
#define LC_NO_DPB               1

#endif
