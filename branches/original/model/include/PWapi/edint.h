#ifndef _edint_proto_h 
#define _edint_proto_h

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

extern PWresult pwIntersectWithEdge _PW_((
  struct PWid             *p_edid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWsfdata         *p_sfdata,
  double                  xyztol,
  struct PWcvintpt_list   **p_cvintpts
));

extern PWresult pwIntersectWithEdgeGeom _PW_((
  PWobjid		 edid,
  PWosnum		 os,
  struct PWcvdata        *p_eddata,
  PWboolean              edrev,
  struct PWadjseg        *p_adjseg,
  PWboolean              edmap_to_py,

  struct PWcvdata        *p_uvcv,
  struct PWcvdata        *p_xyzcv,
  PWrange2d              uvcvrng,
  PWboolean              cvmap_to_py,

  struct PWsfdata        *p_sfdata,

  double                 xyztol,
  double                 uvtol,

  struct PWcvintpt_list  **p_cvintpts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
