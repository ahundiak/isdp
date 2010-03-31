/****************************************************************************

	Description :

                    Macros for property evaluation functions in EMS.

	Creation :

	            Vadiraj M.R. - long ago.
****************************************************************************/
#ifndef EMSprops_func_macros
#define EMSprops_func_macros

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

extern void EMavgsfnorm __((IGRlong *msg, struct IGRbsp_surface *srf,
                     IGRdouble u, IGRdouble v, 
                     IGRdouble *sfpt, IGRvector natnorm));

extern void MSaccprop __((IGRdouble *prop, IGRdouble *cum));

extern void MScnvtprop __((IGRdouble *in_prop, IGRdouble *in_org,
                    IGRdouble *in_glo_loc, IGRdouble *dest_prop,
                    IGRdouble *dest_org, IGRdouble *dest_glo_loc));

extern void MSdisplay_prop __((IGRboolean stderr_only, IGRchar filename[],
                   IGRlong option, IGRlong numb_less_1,
                   IGRchar *obj_descr, IGRdouble *glo_loc,
                   IGRdouble *origin, IGRdouble prop[], IGRdouble factor,
                   IGRchar *master_units, IGRint coord_type,
                   IGRchar *c_name, IGRchar *object_name));

extern void MSdrawtriadn __((IGRlong *msg, IGRlong option, IGRdouble *axes,
                      IGRdouble sld, IGRdouble *prop, 
                      struct GRmd_env *moduleinf, 
                      struct IGRdisplay *display_att,
                      OM_S_OBJID my_id, IGRboolean output_triad,
                      struct GRvg_construct *construct_list,
                      struct GRid *massprop_id));
#if defined(__cplusplus)
}
#endif

#undef __

/***************************************************************************

         Description :

         This macro returns the unit normal to a surface, taking
         into account cusp-points/lines at the surface. The possible
         normals (in 1-4 directions) are averaged. If the average is
         a zero-length normal, EMS_I_NoSolution is returned. 

         ARGUMENTS :

         IGRlong *msg   -  Output:
                           Message return code.
                           -EMS_I_NoSolution,
                            if the average turns out to be
                            a zero-length normal.
                           -EMS_E_Fail,
                            in case the call to a math
                            function fails.

         struct IGRbsp_surface *surface
                        -  Input:
                           The given surface for which normal(s)
                           are to be evaluated.

         IGRdouble uparam
         IGRdouble vparam 
                        -  Input:
                           The u and v parameters in the parametric
                           space of the surface, at which the
                           normal(s) are to be evaluated.

         IGRdouble *surfacept
                        -  Output:
                           The point on the surface, in the model space,
                           at which the normal(s) have been evaluated.  

         IGRvector natnorm
                        -  Output:
                           The evaluated surface normals.  
***************************************************************************/
#omdef ems$avgsfnorm (msg,
                      surface,
                      uparam = 0.0,
                      vparam = 0.0,
                      surfacept,
                      natnorm)
EMavgsfnorm ((msg), (surface), (uparam), (vparam), (surfacept), (natnorm))
#endomdef

/***************************************************************************

            Description :

            Given mass properties in global system at centroids of two objects
"propobj1" and "propobj2_cumprop", this returns the properties at the new
 centroid in "propobj2_cumprop".

        The mass properties for both the objects can be passed in
        as follows :

        0       volume
        1       mass
        2,3,4   centroid
        5       moment of inertia about x axis
        6       moment of inertia about y axis
        7       moment of inertia about z axis
        8       product moment xy
        9       product moment yz
        10      product moment zx
        11      surface area

            ARGUMENTS :

            IGRdouble *propobj1    -  Input:
                                      Mass properties for the object 1.

            IGRdouble *propobj2_cumprop
                                   -  Input/Output:
                                      Mass properties for the object 2 
                                      (serves as an input), and when
                                      returned by this macro contains
                                      the cumulative mass properties of
                                      both the objects.
***************************************************************************/
#omdef ems$accprop (propobj1,
                    propobj2_cumprop)
MSaccprop ((propobj1), (propobj2_cumprop))
#endomdef

/***************************************************************************

          Description :

          Given mass properties in a system this macro returns
          mass properties in new system.

          ARGUMENTS :
 
          IGRdouble *in_props   -  Input:
                                   Incoming mass properties.

          IGRdouble *in_origin  -  Input:
                                   Origin for the incoming mass properties. 

          IGRdouble *in_global_ornt
                                -  Input:
                                   Incoming orientation.

          IGRdouble *out_props  -  Output:
                                   Out going mass properties.

          IGRdouble *out_origin -  Output:
                                   Origin for the out going mass properties.

          IGRdouble *out_global_ornt
                                -  Output:
                                   Out going orientation.

          NOTES :

1.      Mass properties are passed in/out as follows:

        0       volume
        1       mass
        2,3,4   centroid
        5       moment about x axis
        6       moment about y axis
        7       moment about z axis
        8       product moment xy
        9       product moment yz
        10      product moment zx
        11      surface area

2.      The volume, mass, centroid and surface area are not
        altered by this transformation.   
***************************************************************************/
#omdef ems$cnvtprop (in_props,
                     in_origin,
                     in_global_ornt,
                     out_props,
                     out_origin,
                     out_global_ornt)
MScnvtprop ((in_props), (in_origin), (in_global_ornt), (out_props),
            (out_origin), (out_global_ornt))
#endomdef

/***************************************************************************

          Description :

          This macro displays the mass/area properties of an object.

          ARGUMENTS :

          IGRboolean stderr_only   -  Input:
                                      A flag indicating whether the
                                      properties to be dumped only on stderr.

          IGRchar *filename        -  Input:
                                      File name for outputting results.

          IGRlong option           -  Input:
                                      The following options are available
                                      regarding the properties to be output:

                                    0  area properties
                                    1  mass properties in global origin
                                    2  mass properties in principal orientn
                                    3  mass properties in general orientn
                                        (about any user defined point) 
      
          IGRlong object_index     -  Input:
                                      The index of an object whose
                                      properties are being displayed.

          IGRchar *object_descr    -  Input:
                                      The description of an object whose
                                      properties are being displayed.

          IGRdouble *global_to_local
                                   -  Input:
                                      Orientation matrix global to local.

          IGRdouble *origin        -  Input:
                                      Point about which properties are computed.
                               
          IGRdouble props[]        -  Output:
                                      Properties that are output.

          IGRdouble factor         -  Input:
                                      Scaling factor from working units to
                                      to master units.

          IGRchar *master_units    -  Input:
                                      Master units in which the properties
                                      are to be expressed.

          IGRint coord_type        -  Input:
                                      The co-ordinate system in which the
                                      properties are calculated.
                                      The active co-ordinate system can
                                      be - rectangular,
                                           spherical,
                                           cylindrical.

          IGRchar *coord_name      -  Input:
                                      Name of coordinate system.

          IGRchar *object_name     -  Output:
                                      The object name for which the
                                      properties are being output. 
                                                    
***************************************************************************/   
#omdef ems$display_prop (stderr_only,
                         filename,
                         option = 2,
                         object_index,
                         object_descr,
                         global_to_local,
                         origin = NULL,
                         props,
                         factor,
                         master_units,
                         coord_type,
                         coord_name,
                         object_name)
MSdisplay_prop ((stderr_only), (filename), (option),
                (object_index), (object_descr),
                (global_to_local), (origin), (props), 
                (factor), (master_units), 
                (coord_type), (coord_name), (object_name))
#endomdef  
                         
/***************************************************************************

          Description :

          This micro displays the Mass/Area Designator.

          ARGUMENTS:

          IGRlong *msg      -  Output:
                               Message return code.
                               This macro by itself does not print any 
                               error messages.

          IGRlong option    -  Input:
                               option to print Area or Mass properties.

          IGRdouble *axes   -  Input:
                               Orientation matrix from global to local.

          IGRdouble solid_range
                            -  Input:
                               Solid range box for the object for which
                               the Mass/Area Designator is to be displayed.

          IGRdouble *props  -  Input:
                               Mass properties explained above.

          struct GRmd_env *moduleinfo
                            -  Input:
                               Current object module environment.

          struct IGRdisplay *display_attr
                            -  Input:
                               Current object display attributes.

          OM_S_OBJID comobj_id
                            -  Input:
                               The objid of the command object
                               invoking this macro.

           
          IGRboolean output_triad
                            -  Input:
                               A flag indicating whether 
                               the Mass/Area Designator 
                               should be displayed or not.
                               Always display, by default.

          struct GRvg_construct *construction_args
                            -  Input:
                               Construction list for the 
                               object to be constructed.

          struct GRid *massprop_id
                            -  Output:
                               The objid of the Mass/Area Designator
***************************************************************************/
#omdef ems$drawtriadn (msg,
                       option,
                       axes,
                       solid_range,
                       props,
                       moduleinfo,
                       display_attr,
                       comobj_id,
                       output_triad = TRUE,
                       construction_args,
                       massprop_id) 
MSdrawtriadn ((msg), (option), (axes),
              (solid_range), (props), 
              (moduleinfo), (display_attr),
              (comobj_id), (output_triad),
              (construction_args),
              (massprop_id))
#endomdef
#endif

