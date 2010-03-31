#ifndef EMSobjmgrdef_include
#define EMSobjmgrdef_include

/*
   DESCRIPTION

     Contains the constant definitions that are used by the
     code dealing with EMS-object-manager objects.

   HISTORY

     SS  :  04/07/88  :  Creation
     RC  :  11/22/88  :  Added definitions related to class EMSfanmgr
     rlw :  01/31/89  :  Increased the default watermark
*/


/*
 * Defined constants which stand for the identifier of a given validator
 * function. Every validator function must have associated to it a unique
 * identifier.
 */

#define EMSvfunc_isshellvalid		0
#define EMSvfunc_valid_xyz_counterpart	1
#define EMSvfunc_lsvalidator		2


/*
 * Name of the associated cleaner object which is attached to all
 * managers for purposes of waking up and cleaning up on file opening and
 * closure, respectively.
 */

#define EMSobjmgr_cleaner "EMSobjmgr_cleaner"

/*
 * The following constants are the labels to be used to uniquely 
 * identify EMS-object-managers of a certain class, within an object space.
 */

/* CLASS: EMSshobjmgr */
#define EMSshobj_sfbdry 0
#define EMSshobj_expr   1

/* CLASS: EMScpmgr */
#define EMScp_sfbdry 0

/* Class : EMSfanmgr */
#define EMSlabel_xsection 0

/*
 * THE FOLLOWING CONSTANTS DEAL WITH THE CLASS EMSobjmgr.
 */

/*
 * Options to be used in the message - EMvalidate.
 */

#define EMS_OBJMGR_CORRECT	0x01
#define EMS_OBJMGR_LABELSPEC	0x02
#define EMS_OBJMGR_PASSON	0x04

/*
 *
 * The watermark-level for the shell-object manager is defined
 * as a constant here. This is stored in the instance data of the
 * manager and describes it's characteristics to an extent. It
 * can be later changed by a message send.
 */

#define EMSSHELL_WATERMARK_LEVEL  100

/*
 * The incrementing value for the variable-length arrays
 * in the shell-manager objects.
 */

#define EMSSHELL_VLAINCR_SIZE 5


/*
 * THE FOLLOWING CONSTANTS DEAL WITH THE CLASS EMSshobjmgr.
 *
 * Options used to define the maniputlation operation on the
 * coutnerpart-manager object.
 */

#define EMSshell_create		0x01  /* A new object must unconditionally be
                                         created for return */
#define EMSshell_check		0x02  /* Simply check if this object is present
                                         as a valid shell within this object
                                         or any of the overflows. The classid
                                         and the shell-obj are provided on the
                                         arg list */
#define EMSshell_classvfunc	0x04  /* The validator function is used to
                                         perform processing on the entire
                                         array of objects of the specified
                                         class. After this the method 
                                         terminates. See EMshgetobj.I */

/*
 * THE FOLLOWING CONSTANTS DEAL WITH THE CLASS EMScpmgr.
 *
 * Options used to define the maniputlation operation on the
 * coutnerpart-manager object.
 */

#define EMScpmanip_put		0x01
#define EMScpmanip_get		0x02
#define EMScpmanip_del		0x04
#define EMScpmanip_keywise	0x08
#define EMScpmanip_cpwise	0x10


/*
 * THE FOLLOWING CONSTANTS DEAL WITH THE CLASS EMSfanmgr.
 *
 * Definitions in maniputlating the fan-manager object.
 */

#define EMSFM_MANIP_GET   0x01
#define EMSFM_MANIP_PUT   0x02
#define EMSFM_MANIP_DEL   0x04
#define EMSFM_MANIP_RPL   0x08

#define EMSFM_KEY_FAN   0x01
#define EMSFM_KEY_TIP   0x02




#endif
