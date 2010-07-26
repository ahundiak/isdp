/*  This file is used to register user definable Object Space types.
**  These types must be registered with the EXNUC development group.
**
**  These types are bits, so a maximum of 32 types can be defined.
**  The macro om$set_os_type is used to set and get the type(s) of a
**  given Object Space.  See OMprimitives.h from more info.
**
**
**
**                Bit Usage Map - X means bit is reserved
**
**
**      3 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0
**      2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1
**    |-----------------------------------------------------------------|
**    |                                             X X X X X   X     X |
**    |-----------------------------------------------------------------|
**
**    Note that bits 6-10 are reserved due to legacy, since HL_CVT_TO_20
**    used to be decimal 1000 which is 0x000003e8 - this value was changed
**    to 0x00000008 when the logic was changed to make the OS type a
**    bitfield in the 2.4 release.
**
**/


#ifndef OM_file_types_inc
#define OM_file_types_inc 1

#define OS_DEFAULT         0x00000000   /* Default (no type)     */
#define NCFILE_BATCHED     0x00000001   /* NC specific           */
#define HL_CVT_TO_20       0x00000008   /* Converted file to 2.0 */


#endif
