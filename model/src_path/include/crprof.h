#ifndef _CreateProfAPI_include 
#define _CreateProfAPI_include 

#ifndef _PWminimum_include
#include "PWminimum.h"
#endif

#if defined(__STDC__) || defined(__cplusplus) 
#ifndef _PW_ 
#define _PW_(args) args 
#endif 
#else 
#ifndef _PW_ 
#define _PW_(args) () 
#endif 
#endif 

#if defined(__cplusplus) 
extern "C" 
{ 
#endif

enum PWprof_elem_type
{
  point_state, 
  line_state, 
  arc_state, 
  circ_state,
};

/* This is the structure for filling the other points 
   of profile elements. If the element type is a line
   only end_pt is to be given, if it is a circle only
   center is to be given and if the element type is
   an arc, both end_pt as well as center should be
   given
*/

struct other_data
{
   PWpoint	end_pt;      
   PWpoint	center;      
};

struct PWprofelems
{
  enum PWprof_elem_type	type;
  PWpoint	start_pnt;
  struct other_data second_data;
} ;

struct PWcomponent
{
  PWobjid   objid    ;     /* The objid of the component */
  unsigned short gmtype ;  /* geometry type i.e. Line, Arc, or Bspline */
  int       num_pts     ;  /* number of connected ptvars */
  PWobjid   p[4]       ;   /* The 1st, 2nd, 3rd, and 4th SKptvar objid */
};

extern PWresult pwCreateProfile  _PW_(( 
  PWobjid refplid,
  PWosnum os,
  int num_elems,
  struct PWprofelems *elements,
  PWboolean close_profile, 
  PWobjid *profile
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
