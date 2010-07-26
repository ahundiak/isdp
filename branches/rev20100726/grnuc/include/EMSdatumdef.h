#ifndef EMSdatumdef_h
#define EMSdatumdef_h 1

#define INACTIVE_DATUM_WEIGHT 0
#define ACTIVE_DATUM_WEIGHT 2
#define DATUM_STYLE 4

/* Options for EMtoggle_on_off message */

#define EMS_OPT_ON  0x1 /* Sets the datum properties to be on */
#define EMS_OPT_OFF 0x2 /* Sets the datum properties to be off */
#define EMS_OPT_TOGGLE 0x4 /*Toggles the datum propertieoperties */.

/* Options for EMget_datums message */

#define EMS_OPT_OFF_DATUMS 0x1    /* Datums whose display has been turned off*/
#define EMS_OPT_ON_DATUMS 0x2     /* Datums whose display has been turned on */
#define EMS_OPT_HIDDEN_DATUMS 0x4 /* Datums which have been hidden from
                                     the user */
#define EMS_OPT_BASE_DATUMS 0x8   /* Return the base datums */

/* Options for EMSdatpln.EMput_pln_info message */

#define EMS_OPT_SET_EXTERNAL_CONSTRAINT 0x1

/* Options for EMSdatplnmgr.EMactiave */
#define EMS_OPT_DEACTIVATE 0x1

/* Options for EMSdatplnmgr.EMmanage_datum_entry message */
#define EMS_OPT_ADD 0x1
#define EMS_OPT_DELETE 0x2
#define EMS_OPT_ACTIVATE 0x4

/* Options for EMSdatpln.EMcreate_resize_handle */
#define EMS_OPT_DISPLAY_HANDLE 0x1

/* Options for ems$ref_plane_lock macro */
#define EMS_REF_PLANE_LOCK_INQ     0x1 /* Enquires the current state of
                                          reference plane lock */
#define EMS_REF_PLANE_LOCK_SET     0x2 /* Sets the current state of
                                          reference plane lock */
#define EMS_REF_PLANE_LOCK_ON      0x4 /* Sets the current state of
                                          reference plane lock to on */
#define EMS_REF_PLANE_LOCK_OFF     0x8 /* Turns the reference plane
                                          lock off */
#define EMS_REF_PLANE_LOCK_TOGGLE  0x10/* Toggles the reference plane
                                          lock */
#define EMS_REF_DO_NOT_CHANGE_COLOR 0x20
                                       /* This define allows the caller
                                          to not cause a change in the
                                          reference plane color 
                                          when the lock changes state */
                   
                                     

/* Properties of the datum plane */

#define EMS_BASE_REFERENCE_PLANE   0x1 /* Indicates that this is a base
                                          reference plane */
#define EMS_HIDDEN_REFERENCE_PLANE 0x2 /* Indicates that this is a hidden
                                          reference plane that is not
                                          seen by the user and exists
                                          for maintaining associativity */

/* Options for ems$get_reference_plane_for_given_orientation macro */

#define EMS_OPT_DO_NOT_CREATE 0x1 /* Do not create a reference plane if
                                     one does not exist */

#endif

