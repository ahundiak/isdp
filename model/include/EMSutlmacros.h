/****************************************************************************

 	Description :

        Macros for utility functions in 'EMS'.

        Creation :

        Vadiraj M.R. - long ago.
****************************************************************************/
#ifndef EMSutil_func_macros
#define EMSutil_func_macros

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) ()
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
#ifndef igetypedef_include
#include "igetypedef.h"
# endif
#ifndef gr_include
#include "gr.h"
# endif
#ifndef go_include
#include "go.h"
# endif
#ifndef exdef_include
#include "exdef.h"
# endif
#ifndef ex_include
#include "ex.h"
# endif
#ifndef emsinterdef_include
#include "emsinterdef.h"
# endif
# ifndef emssfintdef_include
#include "emssfintdef.h"
# endif
# ifndef emsdef_include
#include "emsdef.h"
# endif
#ifndef griodef_include
#include "griodef.h"
# endif
#ifndef grio_include
#include "grio.h"
# endif
#ifndef godef_include
#include "godef.h"
# endif
#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"
# endif
# ifndef emserr_include
#include "emserr.h"
# endif
#ifndef dp_include
#include "dp.h"
# endif
#ifndef emsmapdef_include
#include "emsmapdef.h"
# endif
#ifndef OM_D_MINIMUM
#include "OMminimum.h"
# endif
# ifndef emsbool_include
#include "emsbool.h"
# endif
# ifndef emsdattyp_include
#include "emsdattyp.h"
# endif

extern IGRint EMgetvggeom __((IGRlong *msg, IGRshort *mattyp, IGRmatrix mat,
                       struct GRid *object, IGRchar **geom,
                       enum EMSdatatype *type));

extern IGRlong EMmake_chanselect __((IGRint chan_label, 
                                     OM_S_CHANSELECT *chan_sel));

extern IGRlong EMpromote_class __((IGRboolean is_a_curve,
                                   struct GRmd_env *md_env,
                                   struct GRid *id, IGRlong *msg));

extern IGRlong EFget_construction_info_from_id __((IGRlong *EMmsg,
                                        struct GRvg_construct *construct_list,
                                        GRobjid objid,
                                        OMuword osnum));

extern IGRlong EFget_creator_id __((IGRlong *EMmsg, GRobjid created_id,
                             OMuword created_os, GRobjid *creator_id,
                             IGRushort options));
#if defined(__cplusplus)
}
#endif

#undef __

/****************************************************************************

       Description :

       This macro can be used to get the B-spline geometry of a given
    surface/curve. It mallocs a contiguous, buffer that is appropriately
    partitioned to hold the geometry. Deallocation is done on just this
    one address.

       ARGUMENTS :

       IGRlong *msg         -  Output:
                               Message return code.
                               -EMS_S_Success,
                                if all is well.
                               -EMS_E_InvalidArg,
                                in case the incoming
                                object does not make
                                sense.
                               -EMS_E_Fail,
                                in case of failure.
                               -EMS_E_NoDynamicMemory,
                                failure to allocate
                                memory.

      IGRshort *matrixtype
      IGRmatrix matrix       -  Input:
                                Information about the 
                                module matrix in which
                                incoming objects reside.

      struct GRid *object    -  Input:
                                The object whose geometry
                                is required.

      IGRchar **geometry     -  Output:
                                The geometry of the incoming
                                object.

      enum EMSdatatype *geomtype
                             -  Output:
                                The type of the geometry
                                returned.
                                Eg. : The returned geometry
                                type can be EMSdata_curve3d
                                or EMSdata_surface.

                                Refer to the header file
                                emsdattyp.h for different
                                enumerated data types.
****************************************************************************/
#omdef ems$getvggeom (msg,
                      matrixtype,
                      matrix,
                      object,
                      geometry,
                      geomtype = NULL)
EMgetvggeom ((msg), (matrixtype), (matrix), (object), (geometry), (geomtype))
#endomdef

/****************************************************************************

          Description :

          This macro is intended as a replacement for the om$make_chanselect
    call throughout EMS-code. The idea is to speed up "making" a channel.
    Studies have shown that this call is atleast 10 times as fast as
    the om$make_chanselect.

          ARGUMENTS :
          IGRint chan_label      -  Input:
                                    The type of channel to be made.

                                    Refer to the header file emsdef.h
                                    for the various channel labels
                                    available.  

         OM_S_CHANSELECT *chan_selector
                                 -  Input:
                                    User defined channel selector.
                                    Once the channel is made,
                                    connections exist to the
                                    objects across this channel
                                    selector.
                                    Eg. : A sample call to this
                                    macro may look like the
                                    following :
                                    ems$make_chanselect (chan_label = 
                                                   GRcmpowner_to_components,
                                                   chan_selector = &to_cmpnts).
                                    The channel made, in this case, is between
                                    the owner and its components. 
****************************************************************************/
#omdef ems$make_chanselect (chan_label, 
                            chan_selector)
EMmake_chanselect ((chan_label), (chan_selector))
#endomdef

/****************************************************************************

        Description :

        This macro promotes an object to be freeform.

        ARGUMENTS :

        IGRlong *msg     -  Output:
                            Message return code.
                            -MSSUCC,
                             if succeeds.
                            -MSFAIL,
                             in case of a failure.
                            -OM_I_INVANCESTRY,
                             in case of invalid
                             ancestry.

        struct GRid *object
                         -  Input:
                            The objid of the object
                            whose class is to be promoted.

        struct GRmd_env *mdenv
                         -  Input:
                            Information about the module in which
                            the incoming object resides. 

        IGRboolean is_a_curve
                         -  Input:
                            A flag that determines whether the
                            incoming object's class really needs
                            promoting.
        
****************************************************************************/
#omdef ems$promote_class (msg,
                          object,
                          mdenv,
                          is_a_curve = TRUE)
EMpromote_class ((is_a_curve), (mdenv), (object), (msg))
#endomdef
 
/****************************************************************************

      Description :

      This macro generates the construct list based on the construction
      information that is stored in itself. It fills the entire
      structure barring the environment information. It expects the memory for
      the display field in the construct_list structure to be allocated.
      If construct_list->class_attr is not NULL then this method assumes
      that enough memory has been allocated to get the element specific
      attributes and it will try to obtain the same from itself.  

      ARGUMENTS :

      IGRlong *msg         -  Output:
                              Message return code.
                              -EMS_S_Success,
                               If all ends well.

                              -EMS_E_Fail,
                               in case of an error.

       GRobjid objid       -  Input:
                              Objid of the object whose
                              construction list is to be 
                              prepared.

       OMuword osnum       -  Input:
                              Object space number of the
                              object whose construction list
                              is to be prepared.           

       struct GRvg_construct *construction_args
                           -  Input/Output:
                              The filled in construction
                              list for the incoming object.
                              Refer to the header file go.h
                              for more info. on the structure
                              GRvg_construct. 
****************************************************************************/
#omdef ems$get_construction_info_from_id (msg,
                                          objid = my_id,
                                          osnum = OM_Gw_current_OS,
                                          construction_args)
EFget_construction_info_from_id ((msg), (construction_args), (objid), (osnum))
#endomdef 

/****************************************************************************

         Description :

         This macro returns the id of the element that created the
         surface/loop/edge given.

         ARGUMENTS :
       
         IGRlong *msg        -  Output:
                                Message return code.
                                -EMS_S_Success,
                                 if all ends well.
                                -EMS_E_NotFound,
                                 in case the created_id
                                 points to some absurdity.
                                -EMS_E_Ambiguous,
                                 in case of an ambiguous
                                 situation. 

         GRobjid created_id  -  Input:
                                Objid of the object whose
                                creator is being asked for.

         OMuword created_os  -  Input:
                                The object space number of
                                the object whose creator is
                                being asked for.

         GRobjid creator_id  -  Output:
                                The objid of the object
                                which is the creator of
                                the incoming object.

         IGRushort options   -  Input:
                                Not yet supported.  
****************************************************************************/
#omdef ems$get_creator_id (msg,
                           created_id = my_id,
                           created_os = OM_Gw_current_OS,
                           options = NULL,
                           creator_id)
                            
EFget_creator_id ((msg), (created_id), (created_os), (creator_id), (options))
#endomdef

#endif

