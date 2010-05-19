/* $Id: VDSaction.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vdinclude/VDSaction.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSaction.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/04/16  20:00:34  pinnacle
 * Created: vdinclude/VDSaction.h by jwfrosch for vds.240
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

/*
 * HF: 04/15/96
 *
 * This file is an extended version of the file : $MODEL/include/EMSaction.h
 *
 * The "struct VDSaction_handler" has been appended at the end.
 * This structure allows for dynamic allocation of the required number
 * of lc_info pointers, in stead of the fixed size limit of 1000 maximum, 
 * which turns out to be far to small for Interference Checking operations
 * in VDS / ROUTE.
 *

 Description

 This include file defines the information which
 needs to be passed to the EFlocate_action_handler().
 This action handler will prevent the relocation of
 objects which are in this arrary.
 
 Notes

 In order to prevent unnecessary mallocs I have defined the maximum
 size of the array to be 1000.  I do not think that the user will ever
 pick this many objects.

 Variables

 next              Pointer to another data structure of this type.  This
                   field is present such that one can say include only
                   certain objects and not certain others.
 option            [0,1] - Determines how the list is processed
                   0 - Do not locate any objects in the list
                   1 - Only locate objects in the list
                   2 - Do not locate any objects which belong to
                       an array of classids or are subclasses of the
                       same.
                   3 - Locate only objects which belong to an array of
                       classids or are subclasses of the same.
                   4 - Do not locate only objects whose activeid belongs to
                       the array of classids specified or are subclasses of
                       the same.
                   5 - Locate only objects whose activeid belongs to the
                       array of classids specified or are subclasses of the
                       same.

 THE following have been defined for the purpose of passing locate
information down to edge level. This was chosen as a last resort since
I, AMD, could find no other way of doing the above.
                   
                   6 - LOCATE EDGE
                   
                   7 - LOCATE VERTEX

                   9 - LOCATE LOOP

 type              [0,1,2] - Determines how the objects are specified
                   0 - Array of pointers to GRlc_info's
                   1 - Pointer to an array of GRid's
                   2 - Pointer to an array of GRobjid's
 number_of_objects If option = 0 or 1 then it represents the number of
                   objects already located.
                   If option = 2 or 3 then it represents the number of
                   classids.
 lc_info           Array of 200 pointers to struct GRlc_info.
 id                Pointer to an array of struct GRid
 space_number      Object space number
 objid             Pointer to an array of object id's
 classids          Pointer to an array of classids. Is only applicable
                   with option = 2 or option = 3.

 History

 09/19/88 : rlw : Creation date
 09/26/88 : rlw : Added option field and next field
 11/11/88 : pp  : Added option to support locating/not locating objects
                  belonging to the input classid list.
 08/08/89 : pp  : Added option to support locating/not locating objects
                  whose active id belongs to the input classid list.
 09/11/91 : amd : added option for supporting locate of vertex, edge
                  and loop. 
 08/26/92 : DLB : increase RLW_STACK_SIZE to 1000.  was getting corruptions
                  when an event generator would pick more than 200 elements
                  at a time.  just increasing the array size is not the right
                  answer but just decreases the likelyhood of an overwrite.
                  this should be changed to dynamic (alloca?) memory to make 
                  the correct fix.
 */
#define RLW_STACK_SIZE 1000

#define LOCATE_EDGE 6
#define LOCATE_VERTEX 7
#define LOCATE_LOOP  9

struct EMSaction_handler
 {
  struct	VDSaction_handler *next;
  IGRlong	option;
  IGRlong	type;
  IGRlong	num_objects;
  union
   {
    struct GRlc_info *lc_info[RLW_STACK_SIZE];	/* Type 0 */
    struct GRid *id;                            /* Type 1 */
    struct
     {
      OMuword space_number;
      GRobjid *objid;                           /* Type 2 */
     } same_space;
    OMuword *classids;                          /* Type 3 , is only
                                                   applicable if option = 2, 
                                                   3 , 4 or 5 */ 
   } objects;
 };

/*
 * HF: 04/15/96
 *
 * The lc_info member of the union NEEDS TO BE dynamically allocatable, because
 * p.e. for Interference Checking, because in VDS & ROUTE,
 * locate operations can easily result in thousands of elements being located
 * in a single set, while multiple sets are possible as well, which at the end
 * might result in a total of well over ten-thousand('s ?!? of) elements.
 *
 * The user has to malloc() & free() the required memory for the lc_info pointer !!!
 *		   =================
 */

struct VDSaction_handler
 {
  struct	VDSaction_handler *next;
  IGRlong	option;
  IGRlong	type;
  IGRlong	num_objects;
  union
   {
    struct GRlc_info **lc_info;			/* Type 0 */
    struct GRid *id;                            /* Type 1 */
    struct
     {
      OMuword space_number;
      GRobjid *objid;                           /* Type 2 */
     } same_space;
    OMuword *classids;                          /* Type 3 , is only
                                                   applicable if option = 2, 
                                                   3 , 4 or 5 */ 
   } objects;
 };
