/*_________________

  FOR EMS 4.0
  Creation : Sanjay
  _________________
*/

#include <string.h>

/* ------------------------------------------------------------------------
 * This file provides the options generally referred by the Add/Remove Mtl.
 * functionality related functions.
 * ------------------------------------------------------------------------
 */ 

#ifndef  ADDRMOPTS_H
#define  ADDRMOPTS_H 

#define PLACE_PROTRUSION   2
#define PLACE_CUTOUT       3

/*
 * Options required for keeping the right trace groups. These options
 * are used by the function "EFaddrm_keep_right_trace_groups" defined
 * in the file $MODEL/src_dpr/funk/EFaddrmsupp.I
 */

#define  KEEP_TRACE_GROUP                               0x01 
#define  DELETE_TRACE_GROUP                             0x02
#define  STOP_AFTER_PROCESSING_FIRST                    0x04

#define  GROUPS_BETWEEN_THE_PARAMETER_VALUES            0x01
#define  GROUP_JUST_BEFORE_THE_PARAMETER                0x02
#define  GROUP_JUST_AFTER_THE_PARAMETER                 0x04
#define  GROUP_WITH_FIRST_INTOBJ                        0x08
#define  GROUP_WITH_LAST_INTOBJ                         0x10
#define  GROUPS_WITH_THE_START_PARAMETER                0x20
#define  GROUPS_WITH_ZERO_V_PARAMETER                   0x40

/*
 * In case of Revolved features, if the profile after modification is not 
 * closed and the sweep angle is 360 deg. then there will not be any caps
 * in which case we need to set this option.
 */
#define  AddRm_Skip_CapsCheck                           0x01

/*
 * Options required for the generation of secondary solid in case of From-To 
 * option where in the the solid need to be intersected with the From and To
 * Surfaces. These defines are used in the file: 
 *                         $MODEL/src_funk/misc/EFintsfsolid.I 
 */
#define  NO_EXTENSION                    0 /* no need to extend the surface 
                                            * with which the solid will be 
                                            * intersected 
                                            */
#define  EXTEND_SURFACE                  1 /* need to extend the surface with 
                                            * which the solid will be inters-
                                            * ected
                                            */
#define  EXTEND_SOLID                   -1 /* This is the output given by the
                                            * function in case if solid is of
                                            * insufficient length
                                            */


#define  KEEP_ALL_GROUPS               0x1 /* All the intersection groups prod-
                                            * ed by the intersecting surface w-
                                            * ill be kept
                                            */
#define  KEEP_ONLY_ONE_GROUP           0x2 /* The  groups  associated with the 
                                            * save side points will be kept
                                            */

/*
 * Options to indicate how the (open) profile is closed.
 */

#define  AddRm_Prof_Coplanar				0x01
#define  AddRm_Prof_CoplanarExtended			0x02
#define  AddRm_Prof_ClosedWithAxis                      0x04


/*
 * Options which can be set for Profile closure 
 */

#define  AddRm_Prof_CloseWithAxis                       0x01

/*
 * Following are the options which can be set for Add/Remove Boolean.
 *
 * o Don't do any selective boolean operation i.e. performs normal boolean.
 * o If at all the boolean fails, recall the boolean with double check option.
 * o If needed maximum splits on the secondary solid.
 */

#define  AddRm_Bool_NoSelective                         0x01 
#define  AddRm_Bool_DoubleCheck                         0x02
#define  AddRm_Bool_MaxSplitSecSolid                    0x04

/* Possibles actions :                                                        */

#define CONTINUE   0                 /* Continue the current process          */
#define RET_STATUS 1                 /* Return with the status of the message */
#define RET_VALUE  2                 /* Return with the value specified       */
#define GOTO_VALUE 3                 /* Go to the specified value             */

/* Macro definition */

#omdef add$status(test 	 = (!(sts &0x00000001)),
		  msg  	 = (*EFmsg),
		  code 	 = EMS_E_Fail,
		  str    = NULL,
               	  id     = NULL,
               	  osnum  = NULL,
               	  action = GOTO_VALUE,
               	  value  = NULL)
if(test) {\
extern unsigned int OM_Gf_verbose_warning;
msg = code; \
if( OM_Gf_verbose_warning ) 
{
    EFprintcode( stderr, msg ); \
       if( strrchr(__FILE__, '/') ) \
         printf("\nMessage from file : %s at line %d\n",&(((char *)strrchr(__FILE__, '/'))[1]),__LINE__); \
       else \
         printf("\nMessage from file : %s at line %d\n",__FILE__,__LINE__); \
#  if om$specified(str)
      printf((str));  \
      printf("\n");   \
#  endif
#  if om$specified(id)
	printf("Object id = %d", (id)); \
#  	if om$specified(osnum)
		printf("  Object osnum = %d", (osnum)); \
#	endif
	printf("\n"); \
#  endif
}
#if om$specified(action)
#   if om$specified(value)
#      if om$equal(action,RET_VALUE)
          return((value));\
#      else if om$equal(action,GOTO_VALUE)
          goto value;\
#      endif
#   else if om$equal(action,RET_STATUS)
	  return(msg);\
#   endif
#endif
   }\
#endomdef

#define is_a_subclass( subclassid, superclassid ) \
        (som_is_ancestry_valid( (subclassid), (superclassid), NULL, NULL ))

/*
 * Following options are used for generating a skinning surface/solid.
 */
#define SKIN_OPT_ABSOLUTE    0x01
#define SKIN_OPT_SMOOTH      0x02
#define SKIN_OPT_MADECOMP    0x04
#define SKIN_OPT_CLOSED      0x08

/*
 * This structure gives the info of skinning surface created.
 */
struct SkinSurfInfo
{
  int     ncusp_u;    /* Number of cusps in u-direction */
  int     ncusp_v;    /* Number of cusps in v-direction */
  int     nsplit_sec; /* Number of splits along cross section curve. 
                         i.e. for( nsec_cvs ) nsplit_sec += ncomps[sec_cv] 
                         i.e. sum of the number components of each section
                              curve */
  int     nsplit_trc; /* Number of splits along trace curve. 
                         i.e. for( ntrc_cvs ) nsplit_trc += ncomps[trc_cv] 
                         i.e. sum of the number components of each trace
                              curve */
  int     nsplit_u;   /* Number of splits in u-direction 
                         i.e. ncusp_u + nsplit_sec + 2 - n_duplicates_u */ 
  int     nsplit_v;   /* Number of splits in v-direction
                         i.e. ncusp_v + nsplit_trc + 2 - n_duplicates_v */ 
  double  *cusp_u;    /* Cusp parameters along U */
  double  *cusp_v;    /* Cusp parameters along V */
  double  *split_sec; /* Split parameters along cross-section curve(s) */
  double  *split_trc; /* Split parameters along trace curve(s) */
  double  *split_u;   /* Split parameters along U */
  double  *split_v;   /* Split parameters along V */
  GRobjid *split_surfs; /* Split Surface Object Ids */
};

struct SecSolidInfo
{
  /*
   * Secondary Solid Object ID
   */
  struct GRid   grid;

  /*
   * The capping surfaces of the solid. First cap surface encloses the plane
   * of the profile.
   */
  GRobjid    capsurfs_id[2];

  /*
   * Number of surfaces in V direction 
   *  In case of Solid of Projection/Revolution, it is 1.
   *  In case of Solid of Skinning, it is equal to number of components of
   *                                               the trace curve. 
   * In case if the the solid is generated by the closed profile, the following
   * info. is not required. So, I say num_v_surfs is zero.
   */
  int        num_v_surfs;

  /*
   * For each Composite surface in V-direction, there are two surfaces, which
   * represents the surfaces produced by the end segments of the original 
   * profile and two parameters associated with each surface, represents 
   * U parameters of the surface corresponding to end points of the original
   * profile. 
   */
  IGRint     *surfs_index;
  GRobjid    *surfs_id;
  double     *parms; 
};

struct ComponentInfo
{
  int      index;
  GRobjid  id;
  double   u;
  IGRpoint pt;
};

/*
 * This structure represents the relation between the original and modified
 * profiles.
 */
struct ModProfileInfo
{
  /*
   * properties of the modified profile.
   *   1. Modified profile is composite.
   *   2. Modified profile is produced by self intersection of end tangents.
   */
  #define   ModProf_Composite         0x01
  #define   ModProf_SelfIntersecting  0x02
  #define   ModProf_Coplanar          0x04
  #define   ModProf_CoplanarExtended  0x08

  IGRlong        props;

  /*
   * Modified profile grid and plane of the profile
   */
  struct GRid      grid;
  struct GRmd_env  mdenv;
  struct IGRplane  plane;

  /*
   * start and stop indices of the modified profile components which are
   * overlapping with the original profile.
   * The parameter values of these components corresponding to the end points
   * of the overlapping segments of the original profile.
   */
  struct ComponentInfo parms[2];

  /*
   * Internal segment of the modified profile, overlapping the original
   * profile.
   */
  struct ComponentInfo iparm;
};

struct IntobjInfo 
{
  GRobjid          creator;
  IGRboolean       convex;
};

struct ProfileInfo 
{
  struct GRid      grid;
  struct GRmd_env  mdenv;
  struct IGRplane  plane;
};

struct FromToSurfInfo 
{
  IGRlong      props;

  #define FROM_SURF_REFPLANE    0x01
  #define FROM_SURF_PLANE       0x02
  #define TO_SURF_REFPLANE      0x04
  #define TO_SURF_PLANE         0x08
  #define INT_WITH_FROM_SURF    0x10
  #define INT_WITH_TO_SURF      0x20
  #define FROMTO_MADE_COMPSURF  0x40
  #define FROM_AND_TO_ARE_SAME  0x80

  IGRint       num_sfs;
  IGRdouble    svsdpt[3];
  struct GRid  *sfs_grid;

  union
  {
    IGRdouble  proj_pts[6];
    IGRdouble  rev_angs[2];
  }d;
};

struct SegmentInfo
{
  int       segment;
  IGRpoint  intpt;
};

struct TraceInfo
{
  struct GRid  grid;
  IGRboolean   reverse;
};

#endif
