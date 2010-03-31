
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef VEsomacros_include
#define VEsomacros_include 1

/*
   Name
     ve$create_soo ( msg,
                     osnum = OM_Gw_current_OS,
	             num_surfaces = -1,
	             num_curves = -1,
	             resolution = VESO_LOW_RES,
                     p_objid = NULL );

     This macro create the soo for osnum.  If that soo already exists
     its objid is returned and nothing gets created.  The num_surfaces, num_curves,
     and resolution parameters are used to efficiently pre-size the hash table
     of the soo.  If num_surfaces and num_curves is -1, then the default size is
     used.  See VEso.h for the defines used for the resolution parameter.

   Return status: MSSUCC: the soo has bee returned (created)
                  MSFAIL: cannot create the soo

   Argument description :
   --------------------

     ushort osnum       : the os the soo is for				(IN)

     IGRint num_surfaces : number of surfaces in os that will have      (IN)
                           SOs applied

     IGRint num_curves : number of curves in os that will have          (IN)
                         SOs applied

     IGRint resolution : the resolution of LVHL that is applying        (IN)
                         the SOs

     OM_S_OBJID *p_objid: the objid of the soo         			(OUT)
                          NULL_OBJID is returned if it failed
*/

#omdef ve$create_soo ( msg,
                       osnum = OM_Gw_current_OS,
	               num_surfaces = -1,
	               num_curves = -1,
	               resolution = VESO_LOW_RES,
                       p_objid = NULL )

  VEcreate_soo ( (msg), (p_objid), (osnum), (num_surfaces), (num_curves), (resolution) )

#endomdef

#endif
