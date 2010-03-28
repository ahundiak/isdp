/*
Name
        comndef.h

Description
        This file contains #defines used by the generic manipulation commands.

Dependencies
        lcdef.h

History
        mrm     07/29/88    creation
*/

#ifndef comndef_include
#define comndef_include

/*
 *  locate properties and owner action for most geometry-modifying commands,
 *  such as move
 */
 
#define MOVE_LC_PROPS   LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY
#define MOVE_LC_OWNER   LC_GEOM_MOD | LC_REF_HEADER | LC_ASSOCIATIVE

/*
 *  locate properties and owner action for delete
 */
 
#define DELETE_LC_PROPS   LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY
#define DELETE_LC_OWNER   LC_GEOM_MOD | LC_REF_HEADER | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED | LC_HANDLES

/*
 *  locate properties and owner action for most reference-only commands,
 *  such as copy
 */
 
#define COPY_LC_PROPS   LC_RW | LC_LC_ONLY | LC_DP_ONLY
#define COPY_LC_OWNER   LC_READ | LC_REF_HEADER | LC_REF_OBJECTS

/*
 *  locate display flags used by most manipulation commands
 */
 
#define MANIP_LC_DISFLAG    ALL_WINDOWS |               \
                            ELEM_HILIGHT |              \
                            NO_PROJ_ACCEPT_POINT |      \
                            ACC_REJ_CYCLE |             \
                            RELOCATE |                  \
                            LC_REGULAR_HIGHLIGHT |      \
                            LC_ERASE_ALL

/*
 *  number of events stored in COmanip instance data
 */

#define MNEVENTS 6

/*
 *  flags defined in the dpb
 */

#define DISPLAY_DYNAMICS    0
#define COPY_DYNAMICS       1

#endif
