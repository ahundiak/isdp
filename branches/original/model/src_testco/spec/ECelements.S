/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This abstract class is intended as a generic class with the functionality
    to support chain-locate of any number of elements with specified
    properties/attributes, etc. Some methods are provided which are
    intended for override by the instantiated class to tailor-make the
    locate for that particular class.

  HISTORY

    SS  :  04/18/89
    SY  :  12/11/92	Add instance variable locobj_hndlr which is a pointer
			to a function. This variable is initialized to NULL
			and will be set by method set_locobj_hndlr_func.
			The method proc_locobj applies locobj_hndlr to its
			arguments when locobj_hndlr is not NULL.
			Also added new methods: set_locobj_hndlr_func and
			set_locate_criteria.
    SY  :  12/29/92     Add instance variable locevents array to store 
                        projected locate point in case it is requested.
    SY  :  02/17/93     Add option EC_LOC_NO_ACC_RJT to support locate without
                        accept/reject cycle.
    SY  :  02/26/93     Add option EC_LOC_NO_RELOCATE to support changing
                        locate criteria when interfacing form processing
    scw :  08/14/94     Clarified sleep method
*/

class specification ECelements (1:2) of super_cmd;

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "godef.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "EMSmsgdef.h"
#include "EMSlcdef.h"
#include "EMSlc.h"
#include "EC_I.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "grgsmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

/*
 * Definitions that are used in the get_locate_criteria method to 
 * specify the action. 
 */

#define EC_GEOM_READ		0 
#define EC_GEOM_CHGSHAPE	1
#define EC_GEOM_NOCHGSHAPE	2
#define EC_ATTR_READ		3
#define EC_ATTR_WRITE		4

/*
 * Options that may be specified in the do_locate method.
 */

#define EC_LOC_APPENDOBJNUM	0x01	/* The index of the object being
					   located (second onwards) is
					   included in the locate string */
#define EC_LOC_NOCHKDUPLICATES  0x02    /* If multiple objects are being
					   do not check for duplicates. The
					   default is to check */
#define EC_LOC_DISPELEMDIR	0x04	/* The locate point is to be used
					   to determine direction of the
					   located element and direction
					   displayed by arrowhead */
#define EC_LOC_PROJLOCPT	0x08	/* The point used to locate the
					   object is to be projected. If
					   a named locate is performed
					   get a locate point nevertheless */
#define EC_LOC_NOFLEXGROUPS	0x10	/* Do not locate flexible grouping type
					   objects */
#define EC_LOC_PROJACCPT	0x20	/* The point used to accept the
					   object is to be projected. If
					   a named locate is performed
					   get an accept point nevertheless */
#define EC_LOC_NOSPECOBJS	0x40	/* Do not locate specified objects
                                           of any kind */
#define EC_LOC_PLANEDEF         0x80    /* Locate elements which present
                                           plane definitions */
#define EC_LOC_NOHALFHILITE     0x100   /* Do not go to half-highlight
                                           on acceptance of object */
#define EC_LOC_RIGIDCOMPOK      0x200   /* If specified, will OR in the
                                           mask to locate RIGID_COMP regardless
                                           of other criteria */
#define EC_LOC_READONLYOK       0x400   /* If specified, will OR in the
                                           mask to locate READ_ONLY regardless
                                           of other criteria */
#define EC_LOC_ASSOCOK		0x800   /* If specified, will OR in the
                                           mask to locate ASSOCIATIVE objects
                                           regardless of other criteria */   
#define EC_LOC_EXTCONSTOK	0x1000  /* If specified, will OR in the
                                           mask to locate EXTERN_CONSTRAINED
                                           objects regardless of other
                                           criteria */

#define EC_LOC_DISPONEWINDOW	0x2000	/* if specified, will highlight located
					   in the located window */

#define EC_LOC_NO_ACC_RJT	0x4000	/* if specified, will not go through
					   accept/reject cycle. Select handler
					   should be set to NULL */

#define EC_LOC_NO_RELOCATE	0x8000	/* if specified, will not go through
					   relocate cycle */

/*
 * The properties that a given object that is located can have as
 * attributes. These are stored in the instance data, corresponding to
 * each of the located elements.
 */

#define EC_ELEM_ISCURVE		0x01	/* Indicates that the element is
					   a curve */
#define EC_ELEM_ISREVERSED	0x02	/* Indicates that the element is
					   to be treated as reversed */

/*
 * The number by which the located-object holder array increases,
 * each time it begins to overflow.
 */

#define ELEMS_ARRAY_INCR 3

/*
 * The maximum number of restrictive classes permissible
 */

#define MAXNUM_RESTRICTIVE_CLASSES	5


instance ECelements
  {
  struct GRmd_env active_md_env;
  struct IGRdisplay active_display;
  IGRshort active_level;

  IGRlong locate_mask, accept_mask;
  OM_S_CLASSLIST rtree_classes, elig_classes, nelig_classes;
  GRclassid r_classmem[MAXNUM_RESTRICTIVE_CLASSES];
  GRclassid e_classmem[MAXNUM_RESTRICTIVE_CLASSES];
  GRclassid ne_classmem[MAXNUM_RESTRICTIVE_CLASSES];
  IGRint display_flag;
  IGRulong owner_action, properties;
  IGRint min_to_locate, max_to_locate;
  IGRushort options;
  IGRboolean (*acthndlr)();
  IGRchar *acthndlr_args;
  IGRboolean (*selhndlr)();
  IGRchar *selhndlr_args;

  struct GRevent locev, accev;
  struct GRlc_stack locate_stack;

  IGRint num_elems;
  variable struct GRlc_info elems[ELEMS_ARRAY_INCR];  
  variable IGRushort elemprops[ELEMS_ARRAY_INCR];
  IGRboolean elems_hilit;

  IGRint num_events;
  variable IGRint num_atevent[ELEMS_ARRAY_INCR];
  variable struct GRevent locevents[ELEMS_ARRAY_INCR];

  IGRint (*locobj_hndlr)();
  };

override init, wakeup, super_cmd.sleep;

/*
  DESCRIPTION
    
    This message is sent by this classes init-method to itself, in order
    to obtain certain specifiable locate characteristics. The rest
    of the characteristics are hard-coded into the EMgetobjs method.

  ARGUMENTS
    
    The maximum number of classes in rtree-classes, elig-classes and not
    eligible classes is currently set to MAXNUM_RESTRICTIVE_CLASSES in the
    init method. This value is again input as maxnum_classes.

    The geometry-props argument is used to specify any restrictions on
    geometric property of the element to be located: 
    LC_PLANAR_ONLY, LC_NON_PLANAR_ONLY, LC_PHY_CLOSED, LC_PHY_OPEN
    Any of these bits being set indicates PRESENCE OF that restriction.

    The type of operation for which the locate is taking place is also
    specified. The various masks possible are defined at the top of this file:
    EC_GEOM_READ, EC_GEOM_CHGSHAPE, EC_GEOM_NOCHGSHAPE,
    EC_ATTR_READ, EC_ATTR_WRITE
    For now, specifying this has the effect of validating the geom-props
    and topo-props given and setting the LC_RW bit.

    The minimum and maximum number of elements to be located is also obtained.
    MAXINT is a legal specifier for maximum.

  HISTORY

    SS  :  04/18/89  :  Creation
*/
message get_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                             OM_S_CLASSLIST *rtree_classes, *elig_classes,
                             *nelig_classes; IGRushort *geomprops;
                             IGRshort *operation; IGRushort *options;
                             IGRint *minnum_to_locate, *maxnum_to_locate);

/*
  DESCRIPTION

    This message needs to be sent to perform the task of locate. This
    message is in lieu of the lc$locate.

  NOTES

    In the case where more than one element is located, the count of the
    element is included in the locate-string. The options that can be used
    are defined in the beginning of this file.

  HISTORY

    SS :  04/18/89  :  Creation
*/
message do_locate (IGRlong *msg; enum EMSuser_responses *useract;
                   IGRint *response; IGRchar *response_data;
                   IGRchar *elemtype, *postmsg_gen,
                   *postmsg_1, *postmsg_2, *postmsg_3;
                   IGRushort options);


/*
  DESCRIPTION

    This method is invoked after every element that gets accepted in the
    EMdo_locate method and after it has been posted into the instance data
    of this class. Therefore, the current element can be found as:
            ME.ECelements->elems[ME.ECelements->num_elems-1]

    It's implementation at this class is a noop with successful return codes.
    It is intended to be overidden for specialized processing by the
    instantiated command-object. The three events obtained from the
    call to lc$locate are passed in on the argument list. The third event
    could be NULL. The "locate" event can also be obtained frm the 
    instance data of this class and is provided here solely for completeness.

  HISTORY

    SS  :  04/19/89  :  Creation
*/
message proc_locobj (IGRlong *msg; struct GRevent *loc_event, *acc_event,
                     *obj_event);

/*
  DESCRIPTION

    If subclasses would like to override the action-handlers and/or the 
    select-handlers that are going to be used by default in the 'do_locate'
    method, send this message before calling 'do_locate', specifying
    the new functions (with their arguements, if any) to be used.
    NULL is a valid input.

  HISTORY

    SS  :  04/02/91  :  Creation
*/
message set_hndlr_funcs (IGRlong *msg;
                         IGRboolean (*acthndlr)(); IGRchar *acthndlr_args;
                         IGRboolean (*selhndlr)(); IGRchar *selhndlr_args);

/*
  DESCRIPTION
    
    This message achieves the goal of resetting certain specifiable locate
    characteristics. This method should be called whenever we want to locate
    a different group of objects. This method differs from get_locate_criteria
    in that get_locate_criteria is sent by this class' init-method. Thus,
    the locate characteristics remain unchanged across the invokation of the
    command object.

  ARGUMENTS
    
    See get_locate_criteria for description.

    Notice that geomprops, operation, options, minnum_to_locate and
    maxnum_to_locate are not integral pointer types here.


  HISTORY

    SY  :  12/11/92  :  Creation.
*/
message set_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                             OM_S_CLASSLIST *rtree_classes, *elig_classes,
                             *nelig_classes; IGRushort geomprops;
                             IGRshort operation; IGRushort options;
                             IGRint minnum_to_locate, maxnum_to_locate);

/*
  DESCRIPTION

    This method is invoked to set a function used to process located object.
    The intent is to allow different functions be used to process located
    object in method proc_locobj, which can only be overriden once by each
    subclass. New subclass from this class needs not to override 
    proc_locobj. Instead, it calls this method with the processing function.

  HISTORY

    SY  :  12/11/92  :  Creation.
*/
message set_locobj_hndlr_func (IGRlong *msg; IGRint (*locobj_hndlr)());

 
end specification ECelements;
