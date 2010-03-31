/*
  DESCRIPTION

    This file contains the options that are used in various methods/functions
    of the associative system in EMS.
*/

#ifndef EMSasopts_include_
#define EMSasopts_include_

/*
 * These are the options to be used in calling the functions that are
 * used to create associative objects in the system
 */

#define EMSasconst_notassociative	0x0001
#define EMSasconst_noautodimension	0x0002
#define EMSasconst_generatename		0x0004
#define EMSasconst_recompute		0x0008
#define EMSasconst_no_autodimension     0x0010
#define EMSasconst_createsource		0x0020

/*Options for EMastore*/
#define EMastore_DONT_MOVE_TAGS     0x01

/* options for EMinit_associative*/
#define EMS_no_const_assoc                  0x0001
#define EMSinit_dont_connect_parents        0x0002
#define EMSinit_dont_store_recomp_info      0x0004

/* options for ALL the macro functions which drive init_associative*/
#define EFfunc_PLACE_NON_ASSOC          0x0001 /*do NDmove_to_root when done */
#define EFfunc_CREATE_SOURCE            0x0002 /*make source objs if needed  */

/* options for EFround_chamfer */
#define EFrnd_cham_PLACE_NON_ASSOC        EFfunc_PLACE_NON_ASSOC
#define EFrnd_cham_CREATE_SOURCE          EFfunc_CREATE_SOURCE
#define EFrnd_cham_UNIFORM                0x10

/* options for EFdrafted_lift */
#define EFdlft_PLACE_NON_ASSOC            EFfunc_PLACE_NON_ASSOC
#define EFdlft_CREATE_SOURCE              EFfunc_CREATE_SOURCE
#define EFdlft_NEG_MAG_OUTSIDE            0x04
#define EFdlft_NEG_ANGLE_OUTSIDE          0x08
#define EFdlft_POS_MAG_INSIDE 	          0x10

/* options for EFlift_face */
#define EFlft_PLACE_NON_ASSOC            EFfunc_PLACE_NON_ASSOC
#define EFlft_CREATE_SOURCE              EFfunc_CREATE_SOURCE
#define EFlft_POS_WITH_VECT              0x04
#define EFlft_WITH_POS_ORIENT	         0x08

/* options for EMexternal_constraint_changed */
#define EMext_const_chg_CONSTRAINT_ADDED  0x01
#define EMext_const_chg_CHECK             0x02

/*
 * Options used in the EMScnstr.EMinit methods while creating 
 * constraints.
 */

#define EMScnstr_connect_geomhandle	0x01
#define EMScnstr_check_cycle		0x02
#define EMScnstr_minimum_delta		0x04
#define EMScnstr_display		0x08

 /*
  * Options used in the solution/validation messages for EMSparameter/EMScnstr
  * methods. Also, used in getting geometry of the parent/child via the
  * EMgetdrivgeom function. Some of these options may not make sense or
  * be supported in all of the functions/methods.
  */
 
#define EMSsolve_checkcycle	0x01
#define EMSsolve_minimum	0x02

#endif
