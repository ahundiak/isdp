/*****************************************************************************

	Description :

	             Macros for interface related functions in EMS.

	Creation :

	             Vadiraj M.R.  -  long ago.

****************************************************************************/ 
#ifndef EMSiface_func_macros
#define EMSiface_func_macros

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
# ifndef bstypes_include
#include "bstypes.h"
# endif

extern IGRlong ECdisplayBsplineBybuffer __((IGRlong *msg, 
                                     struct IGRdisplay this_Active_display,
                                     struct GRmd_env this_ModuleInfo,
                                     OM_S_OBJID this_id,
                                     struct IGRbsp_curve *incurve,
                                     enum GRdpmode mode,
                                     IGRshort type));  

extern IGRlong ECdisplayPointSetByBuffer __((IGRlong *msg, 
                                      struct IGRdisplay thisActiveDisplay,
                                      struct GRmd_env thisModuleInfo,
                                      OM_S_OBJID thisId, 
                                      IGRlong num_pnts,
                                      IGRpoint pnts[],
                                      IGRboolean draw_background));
                                      
extern IGRlong EFbuild_graphic_group __((IGRlong number_of_objects, 
                                  GRobjid *objects,
                                  struct GRid *ids, 
                                  struct GRvg_construct *construct_list,
                                  GRobjid *constructed_object,
                                  IGRlong *msg));

extern IGRlong EFdisplay_curve_normal_or_tangent __((struct GRlc_info *loc_info,
                                          struct GRevent *event,
                                          IGRboolean display_normal,
                                          IGRboolean reverse_vector,
                                          OM_S_OBJID my_stupid_id,
                                          enum GRdpmode draw_mode,
                                          struct GRmd_env *display_env,
                                          struct IGRdisplay *display,
                                          IGRlong *msg));        

extern IGRlong EFdisplay_iso_curve_of_a_surface __((struct GRlc_info *lc_info,
                                             struct IGRdisplay *display,
                                             struct GRmd_env *display_env,
                                             IGRboolean use_u_curve,
                                             BSpair uv_coordinate,
                                             IGRboolean draw_background,
                                             IGRboolean wait_for_input,
                                             OM_S_OBJID my_stupid_id,
                                             GRobjid *curve_object_id,
                                             IGRlong *msg));  

extern IGRlong EFdisplay_surface_normal __((struct GRlc_info *loc_info,
                                     IGRboolean natural_normal,
                                     OM_S_OBJID my_stupid_id,
                                     IGRboolean draw_background,
                                     struct GRmd_env *display_env,
                                     struct IGRdisplay *display,
                                     IGRlong *msg)); 

extern void EFdraw_vector_on_screen __((OM_S_OBJID my_stupid_id,
                                 struct IGRdisplay *active_display,
                                 struct GRmd_env *display_env,
                                 enum GRdpmode display_mode,
                                 IGRboolean reverse_vector,
                                 IGRpoint point,
                                 IGRvector vector,
                                 GRrange range,
                                 IGRlong *msg));

extern IGRlong EMselective_fence __((OM_S_CLASSLIST  *yes_classes,
                              OM_S_CLASSLIST  *no_classes,
                              struct GRlc_info *set_object,
                              IGRboolean break_down_composites,
                              IGRboolean is_operation_readonly,
                              OM_S_OBJID my_stupid_id,
                              IGRlong *number_of_objects,
                              struct GRlc_info **objects, 
                              IGRlong *msg));
#if defined(__cplusplus)
}
#endif

#undef __

/****************************************************************************
   
              Description :

              This macro is used to display a B-spline curve buffer.

              ARGUMENTS :

              IGRlong *msg      -  Output:
                                   Message return code.
                                   -EMS_S_Success,
                                    if all ends well.
                                   -EMS_E_InvalidArg,
                                    if the incoming curve
                                    buffer is not of
                                    B-spline geometry.

              struct IGRbsp_curve *incurve
                                -  Input:
                                   The incoming B-spline
                                   curve buffer to be
                                   displayed.

              OM_S_OBJID senderid
                                -  Input:
                                   The objid of the object,
                                   a method of which is calling
                                   this function.

             struct IGRdisplay display_attr
                                -  Input:
                                   Display attributes for the
                                   curve buffer to be displayed.

             struct GRmd_env mdenv
                                -  Input:
                                   The module environment in which
                                   the incoming curve buffer resides.

             enum GRdpmode mode -  Input:
                                   Mode of display.
                                   Refer to the header file
                                   dp.h for the structure of the 
                                   enumerator GRdpmode.  

             IGRshort type      -  Input:
                                   Curve geometry type identifier.
                                   Refer to the header file igrdef.h
                                   for Generic math geometry type identifiers.
****************************************************************************/
#omdef ems$displayBsplineBybuffer (msg,
                                   incurve,
                                   senderid,
                                   display_attr,
                                   mdenv,
                                   mode,
                                   type)
ECdisplayBsplineBybuffer ((msg), (display_attr), (mdenv), (senderid), 
                          (incurve), (mode), (type))
#endomdef

/****************************************************************************

            Description :

            This macro displays a line string with out creating an object.

            ARGUMENTS :

            IGRlong *msg       -  Output:
                                  Message return code.
                                  -EMS_S_Success,
                                   if all is well.

            IGRlong num_points -  Input:
                                  Number of points
                                  on the incoming line 
                                  string.
            IGRpoints points[] -  Input:
                                  The points on the line
                                  string to be displayed.

            OM_S_OBJID senderid -  Input:
                                   The objid of the object,
                                   a method of which is calling
                                   this function. 

            struct IGRdisplay display_attr
                                -  Input:
                                   Display attributes for the
                                   line string to be displayed.  

            struct GRmd_env mdenv 
                                -  Input:
                                   The module environment in which
                                   the incoming line string resides.

            IGRboolean draw_background
                                -  Input:
                                   A flag indicating whether the
                                   line string will be drawn in back-
                                   ground.
****************************************************************************/
#omdef ems$displayPointSetByBuffer (msg,
                                    num_points,
                                    points,
                                    senderid,
                                    display_attr,
                                    mdenv,
                                    draw_background)
ECdisplayPointSetByBuffer ((msg), (display_attr), (mdenv), (senderid),
                           (num_points), (points), (draw_background))
#endomdef     
                                    
/***************************************************************************

             Description :

             This macro creates a graphic group and adds the input objects
 to the group.  It is assumed that the input objects exist in
 the construction object space listed in the construction_args.  The
 graphic group is constructed in that object space.

             IGRlong *msg    -  Output:
                                Message return code.
                                -MSSUCC,
                                 in case of success.
                                -MANOMEMORY,
                                 failure to allocate 
                                 memory.
                                -MSFAIL,
                                 failure to construct 
                                 the graphic group. 

             IGRlong number_of_objects
                             -  Input:
                                Total number of objects 
                                that are going to form a group.

             GRobjid *objects
             struct GRid *objids
                             -  Input:
                                Input objects that form 
                                a graphic group. Either
                                of the two can be specified.

             struct GRvg_construct *construction_args
                             -  Input:
                                The construction object space
                                in which the incoming objects
                                reside, and in which the 
                                graphic group will be constructed.

             GRobjid *constructed_object
                             -  Output:
                                The objid of the graphic group
                                constructed.
    
***************************************************************************/
#omdef ems$build_graphic_group (msg,
                                number_of_objects,
                                objects = NULL,
                                objids  = NULL,
                                construction_args,
                                constructed_object)
EFbuild_graphic_group ((number_of_objects), (objects), (objids),
                       (construction_args), (constructed_object), (msg))
#endomdef
                            
/******************************************************************************

         Description :

         This macro will display the natural normal of a curve or
        the a directional indicator (tangent) at the beginning or end
        of the curve.

        ARGUMENTS :
    
        IGRlong *msg         -  Output:
                                Message return code.
                                -MSSUCC,
                                 if succeeds.
                                -MSFAIL,
                                 in case of failure.

        struct GRlc_info *loc_info
                             -  Input:
                                Curve locate information.

        struct GRevent *event
                             -  Input:
                                This event is used to determine the view normal
                                vector.  It is used iff displaying normals and
                                the curve is not planar.  

        IGRboolean display_normal_tangent
                             -  Input:
                                If TRUE  then display the normal vector of the
                               curve near the middle of the curve.  If the curve
                             is planar then the vector draw is the cross product
                             of the tangent vector and the plane normal.  If the
                             curve is nonplanar then the vector draw is the
                             cross product of the tangent vector and the view
                             normal.  If FALSE then the vector drawn is the
                             tangent vector at the beginning of the curve.

        IGRboolean reverse_vector
                             -  Input:
                               If TRUE and displaying the normal then the vector
                               is drawn in the opposite direction.  If TRUE
                               and displaying the tangent then the vector is
                               drawn at the end of the curve.

        OM_S_OBJID senderid  -  Input:
                                The objid of the object,
                                a method of which is calling
                                this function.

        enum GRdpmode draw_mode
                             -  Input:
                                Inputs the display mode:
                                (eg: GRbe, GRbd, GRhe, GRhd, GRhhd)
                                Refer to the dp.h file for info on
                                enum GRdpmode. 

        struct GRmd_env *display_mdenv
                             -  Input:
                                Display enviroment.  Should be obtained 
                                by calling gr$get_display_env().

        struct IGRdisplay *display
                             -  Input:
                                Active color, weight, etc.  Should be 
                                obtained by calling gr$get_active_display().
******************************************************************************/
#omdef ems$display_curve_normal_or_tangent (msg,
                                            loc_info,
                                            event = NULL,
                                            display_normal_tangent = TRUE,
                                            reverse_vector = TRUE,
                                            senderid,
                                            draw_mode,
                                            display_mdenv,
                                            display)

EFdisplay_curve_normal_or_tangent ((loc_info), (event), 
                                   (display_normal_tangent),
                                   (reverse_vector), (senderid), (draw_mode),
                                   (display_mdenv), (display), (msg))
#endomdef                                                                                                                    
/*****************************************************************************

          Description :

          This macro extracts and displays an isoparametric curve of
 the input surface.  The extracted curve is created in the object space
 of the surface, is marked as non-locatable, and is not placed in the
 R-tree.  If desired, the curve is deleted (after displaying it) by
 this routine.

          ARGUMENTS :

          IGRlong *msg    -  Output:
                             Message return code.
                             -MSSUCC,
                              if succeeds.
                             -MSFAIL,
                              in case of failure.

          struct GRlc_info *loc_info
                          -  Input:
                             Surface locate information.

          BSpair uv_coordinate
                          -  Input:
                             A pair of u,v points to get
                             the required iso-curve.

          IGRboolean use_u_curve
                          -  Input:
                             Flag to determine whether
                             the iso-curve wanted is 
                             only the U-isocurve or
                             the U-isocurve.

          IGRboolean draw_background
                          -  Input:
                             Flag to determine whether
                             the iso-curve is to be drawn in
                             background or erase mode.
                             Eg. : GRbd stands for background draw,
                             and GRhd stands for highlight draw.  
                             Refer to the dp.h and grmacros.h for valid
                             display modes.
 
          IGRboolean wait_for_input
                          -  Input:
                             If TRUE then the curve is displayed in GRhhd -
                             half highlight draw - mode,
                             the function waits for user input, then the
                             curve is erased.                              

          OM_S_OBJID senderid  
                             -  Input:
                                The objid of the object,
                                a method of which is calling
                                this function.

          GRobjid *curve_object_id
                             -  Input:
                                Objid of the iso-curve formed.
                                If NULL, then the curve is not returned.


          struct GRmd_env *display_mdenv
                             -  Input:
                                Enviroment in which displays should take place,
                                if NULL then no display is performed. 

          struct IGRdisplay *display
                             -  Input:
                                Info. on active color, weight, etc. 
                                         
*****************************************************************************/
#omdef ems$display_iso_curve_of_a_surface (msg,
                                           loc_info,
                                           uv_coordinate,
                                           use_u_curve = TRUE,
                                           draw_background,
                                           wait_for_input = FALSE,
                                           senderid,
                                           curve_object_id = NULL,
                                           display_mdenv = NULL,
                                           display)
EFdisplay_iso_curve_of_a_surface ((loc_info), (display), (display_mdenv),
                                   (use_u_curve), (uv_coordinate), 
                                   (draw_background),
                                   (wait_for_input), (senderid),
                                   (curve_object_id), (msg))     
#endomdef                                           

/****************************************************************************

              Description :

              This macro will display the natural normal of a surface or
              it's reverse.

              ARGUMENTS :
          
              IGRlong *msg         -  Output:
                                      Message return code.
                                      -MSSUCC,
                                       if succeeds.
                                      -MSFAIL,
                                       in case of failure.

              struct GRlc_info *loc_info
                                   -  Input:
                                      Surface locate information.

              IGRboolean natural_normal
                                   -  Input:
                                      If TRUE  then display the natural normal,
                                      else display it's opposite.

              IGRboolean draw_background
                                   -  Input:
                                      If TRUE then draw in background,
                                      else erase.   


              OM_S_OBJID senderid  -  Input:
                                      The objid of the object,
                                      a method of which is calling
                                      this function.
 
              struct GRmd_env *display_mdenv
                                   -  Input:
                                      Display enviroment.  Should be
                                      obtained by calling gr$get_display_env().

              struct IGRdisplay *display
                                   -  Input:
                                      Info. on active color, weight, etc.
                                      Should be obtained by calling 
                                      gr$get_active_display().              
****************************************************************************/
#omdef ems$display_surface_normal (msg,
                                   loc_info,
                                   natural_normal = TRUE,
                                   draw_background = TRUE,
                                   senderid,
                                   display_mdenv,
                                   display)
EFdisplay_surface_normal ((loc_info), (natural_normal), (senderid),
                          (draw_background), (display_mdenv),
                          (display), (msg))
#endomdef     

/****************************************************************************

           Desacription :

           This macro draws a vector on the screen with an arrowhead.
 This routine requires a point (from which to draw the vector),
 a vector (for direction), and a range box (from which to determine
 the length of the vector).

           ARGUMENTS :

           IGRlong *msg       -  Output:
                                 Message return code.
                                 -EMS_S_Success 
                                  is always returned.

           IGRpoint point     -  Input:
                                 The point from which to draw
                                 the vector.

           IGRvector vector   -  Input:
                                 Unit vector for the required
                                 direction.

           GRrange range      -  Input:
                                 The range box to determine
                                 the length of the vector.

           IGRboolean reverse_vector
                              -  Input:
                                 Flag to determine whether to
                                 draw the vector in the reverse
                                 direction.
                             
           OM_S_OBJID senderid 
                              -  Input:
                                 The objid of the object,
                                 a method of which is calling
                                 this function.                                   
           enum GRdpmode mode -  Input:
                                 Inputs the display mode:
                                 (eg: GRbe, GRbd, GRhe, GRhd, GRhhd)
                                 Refer to the dp.h file for info on
                                 enum GRdpmode.   
       
           struct GRmd_env *display_mdenv
                              -  Input:
                                 Display enviroment for the vector to
                                 be displayed.

           struct IGRdisplay *display
                              -  Input:
                                 Info. on active color, weight, etc.  
****************************************************************************/
#omdef ems$draw_vector_on_screen (msg,
                                  point,
                                  vector,
                                  range,
                                  reverse_vector = TRUE,
                                  senderid,
                                  mode,
                                  display_mdenv,
                                  display)
EFdraw_vector_on_screen ((senderid), (display), (display_mdenv), (mode),
                         (reverse_vector), (point), (vector), (range), (msg))
#endomdef

/****************************************************************************

            Description :

            Given an object, which may be a graphic group or graphics set, this
 routine will return a list of acceptable member objects.  It is intended that
 this be used to break down sets into curves, surfaces, and composites.
 In order for an element to be accepted it must be in the yes list
 and not in the no list.               

            ARGUMENTS :

            IGRlong *msg         -  Output:
                                    Message return code.
                                    -MSSUCC,
                                     if succeeds.
                                    -MSFAIL,
                                     in case of failure.

            struct GRlc_info *set_object
                                 -  Input:
                                    The object which you desire
                                    to be dissected.

            OM_S_CLASSLIST *yes_classes
                                 -  Input:
                                    A list of classes which you will accept.
                                    Note that only w_count and p_classes fields
                                    of the OM_S_CLASSLIST structure are used,
                                    i.e., w_flags field is ignored.
                                    Refer to the file OMminimum.h for
                                    the defn. of the structure OM_S_CLASSLIST.

            OM_S_CLASSLIST *no_classes
                                 -  Input:
                                    A list of classes which you will not
                                    accept.
                                    Note that only w_count and p_classes fields
                                    of the OM_S_CLASSLIST structure are used,
                                    i.e., w_flags field is ignored.

            IGRboolean break_down_composites
                                 -  Input:
                                    If TRUE then EMScomposite object will be
                                    broken down into its members.   
                                    This option is provided to support 
                                    commands such as change ruled line display
                                    and toggle polygon.  Ordinarly one should
                                    not change elements of a rigid composite. 

            IGRboolean is_operation_readonly
                                 -  Input:
                                    Are you just going to do read operations
                                    on the objects I return you. If so then
                                    I will dissect cells and other rigid
                                    IGE sets, if not then I will return you
                                    the rigid set objects.

            OM_S_OBJID senderid  -  Input:
                                    The objid of the object,
                                    a method of which is calling
                                    this function.                                    
            IGRlong *number_of_objects
                                 -  Output:
                                    Total count of objects returned.

            struct GRlc_info **objects
                                 -  Output:
                                    The objects themselves.
****************************************************************************/
#omdef ems$selective_fence (msg,
                            set_object,
                            yes_classes,
                            no_classes,
                            break_down_composites = FALSE,
                            is_operation_readonly = TRUE,
                            senderid,
                            number_of_objects,
                            objects)
EMselective_fence ((yes_classes), (no_classes), 
                   (set_object), (break_down_composites),
                   (is_operation_readonly), (senderid), (number_of_objects),
                   (objects), (msg))
#endomdef   
                                    
#endif 
