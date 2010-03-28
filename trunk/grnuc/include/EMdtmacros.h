#ifndef EMSdt_macros
#define EMSdt_macros




/* *******************************************************************
Description
 This macros returns the datum plane manager id and osnum when
 supplied with the object space in which the manager needs
 to be searched for.

Arguments
 msg   :  I : Completion code
 osnum : I  : Object space in which the manager needs to be searched.
              If NULL then, the manager is hunted for in the object
              space corresponding to the master file
 mgrid : O  : Object id of the manager
 mgros : O  : osnum of the manager. Returned if the same is not NULL.

*********************************************************************** */
 
#omdef ems$get_datum_plane_mgr(
                 msg,
                 osnum = NULL,
                 mgrid,
                 mgros = NULL)
EMget_datum_plane_mgr(msg,osnum,mgrid,mgros)
#endomdef       

/* *******************************************************************
Description
 This macros returns the active datum plane object if one exists.

Arguments
 msg   :  I : Completion code
 options : I : Currently can be set to NULL.
 datpln : O : GRid of the active datum plane
 window : O : Optional. Only present for historical reasons.

*********************************************************************** */

#omdef ems$get_active_datum_plane(
                 msg,
                 options = NULL,
                 datpln,
                 window = NULL)
                 
EMget_active_datum_plane(msg,options,datpln,window)
#endomdef       

/* *******************************************************************
Description
 This macro returns/sets the reference plane lock.

Arguments
 msg   :  I : Completion code
 options : I : If options is set to EMS_REF_PLANE_LOCK_INQ
               then the current state of the reference plane lock
               is returned in mode field.

               If options is set to
               EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET
               then the current state of reference plane lock 
               is set to on.

               If options is set to
               EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET
               then the current state of reference plane lock 
               is set to off.

               If options is set to
               EMS_REF_PLANE_LOCK_TOGGLE | EMS_REF_PLANE_LOCK_SET
               then the current state of reference plane lock 
               is toggled

               if options is set to
                  EMS_REF_DO_NOT_CHANGE_COLOR 
               then the color of the reference plane does not change
               when the lock is turned on or off

 mode : Only applicable if options is set to EMS_REF_PLANE_LOCK_INQ
               
Completion code
 MSINARG : If there is no active reference plane and the macro has
           been asked to turn the lock to be on
 MSFAIL  : Fatalistic failure
 MSSUCC : If all goes well

********************************************************************** */
           
#omdef ems$ref_plane_lock(msg,
                          options,
                          mode = NULL)
EFref_plane_lock(msg, options, mode)
#endomdef

#omdef ems$get_reference_plane_for_given_orientation(
                 msg,
                 options = NULL,
                 env_info,
                 refpln_mxtyp,
                 refpln_mx,
                 pln_GRid)
/* *******************************************************************
Description
 This macro returns a reference plane when specified an orientation.
 The search is only made on base reference planes and those reference
 planes that are hidden from the user. If one does not exist then one
 is created and returned, if options have specifically not been set to
 not create.

Arguments
 IGRlong *msg   :  I : Completion code
 IGRint options :  I : EMS_OPT_DO_NOT_CREATE : Do not create a reference
                       plane if one which matches the given orientation
                       does not exist.
 struct GRmd_env *env_info : I : Module environment where the reference
                       plane has to be created/searched.
 IGRshort *refpln_mxtyp : I : Matrix type of the orientation matrix that
                              is to be used for matching.
 IGRmatrix refln_mx : I : Orientation matrix that is to be used for
                          matching.
 struct GRid *pln_GRid : O : GRid of the plane which matches the
                             orientation. pln_GRid->objid will be
                             NULL_OBJID if the match was unsuccessful
                             and the options was set to not create
                             a new one.
               
Related files:
 EMSdatumdef.h

Completion code
 MSFAIL  : Fatalistic failure
 MSSUCC : If all goes well
********************************************************************** */

EFreturn_reference_plane (msg, options, env_info, refpln_mxtyp, refpln_mx,
                          pln_GRid)
#endomdef


/*

Name
  ems$get_pln_info()

Abstract
  This macro is a wrapper for the message EMSdatpln.EMget_pln_info for
  a specified datum plane (if no datum plane specified (NULL), then the 
  active datum plane is assumed).

Synopsis
  long ems$get_pln_info ( p_datum_plane,
                          options,
                          env,
                          xdir,
                          ydir,
                          zdir,
                          origin,
                          props)

  datum_plane : objid/osnum of datume plane to be queried
  options     : Ubiquitous options field. Currently not supported
  env         : if non-null, Module environment (current is default).
  xdir        : if non-null xdirection of the datum plane is returned
  ydir        : if non-null ydirection of the datum plane is returned
  zdir        : if non-null zdirection of the datum plane is returned
  origin      : if non-null origin of the datum plane is returned
  props       : if non-null properties of the datum plane are returned.

Return Value
  MSSUCC: If all goes well
  MSFAIL : If there is some form of failure

Description
  Retrieves geometric and other proterties from a reference (datum) plane.
  
Notes
  Can be stubbed in GRNUC.  Needed for the implementation of Smart Sketch
  in the GRNUC platform. Smart Sketch requires knowledge of the reference
  planes, which is currently a MODEL class.

Index

Keywords
  get,macro

History
  05/21/93 : Shelley R. Heard : created

 */
#omdef ems$get_pln_info( p_datum_plane = NULL,
                         options,
                         p_env = NULL,
                         p_xdir = NULL,
                         p_ydir = NULL,
                         p_zdir = NULL,
                         p_origin = NULL,
                         p_props = NULL )

EFget_pln_info ( p_datum_plane,
                 options,
                 p_env,
                 p_xdir,
                 p_ydir,
                 p_zdir,
                 p_origin,
                 p_props )

#endomdef

#endif
