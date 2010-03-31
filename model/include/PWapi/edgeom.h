 #ifndef _edgeom_proto_h 
#define _edgeom_proto_h

#include <alloca.h>

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

#define PW_GetEdGeomStack(edobj, os, eddata) \
( \
 !((pwGetEdGeomType ((edobj), (os)) == PWcvdata_py2d) ? \
    (int) ((eddata).data.py2d.p_pts = (PWpoint2d *)  \
       alloca (pwGetEdGeomSize ((edobj), (os)))) : \
    (int) ((eddata).data.p_bspcv = (struct IGRbsp_curve *) \
       alloca (pwGetEdGeomSize ((edobj), (os))))) ? \
     (SetError (PW_K_Pathway, PW_K_DynamicMemory)) : \
     (pwGetEdGeom ((edobj), (os), &(eddata))) \
)

#define PW_GetEdGeomHeap(edobj, os, eddata) \
( \
    (((eddata).data.py2d.p_pts = NULL) , \
     ((eddata).data.py.p_pts = NULL) , \
     ((eddata).data.p_bspcv = NULL) , \
     ((eddata).data.p_gmbspcv = NULL)) , \
    (pwGetEdGeom ((edobj), (os), &(eddata))) \
)

#define PW_GetNatEdGeomStack(edobj, os, eddata) \
( \
 !((pwGetEdGeomType ((edobj), (os)) == PWcvdata_py2d) ? \
    (int) ((eddata).data.py2d.p_pts = (PWpoint2d *)  \
       alloca (pwGetEdGeomSize ((edobj), (os)))) : \
    (int) ((eddata).data.p_bspcv = (struct IGRbsp_curve *) \
       alloca (pwGetEdGeomSize ((edobj), (os))))) ? \
     (SetError (PW_K_Pathway, PW_K_DynamicMemory)) : \
     (pwGetNatEdGeom ((edobj), (os), &(eddata))) \
)

#define PW_GetNatEdGeomHeap(edobj, os, eddata) \
( \
    (((eddata).data.py2d.p_pts = NULL) , \
     ((eddata).data.py.p_pts = NULL) , \
     ((eddata).data.p_bspcv = NULL) , \
     ((eddata).data.p_gmbspcv = NULL)) , \
    (pwGetNatEdGeom ((edobj), (os), &(eddata))) \
)

extern enum PWcvdatatype  pwGetEdGeomType _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern int  pwGetEdGeomSize _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWresult  pwGetEdDef _PW_((
  PWobjid         edobj,
  PWosnum         os,
  struct PWcvdata *p_eddata
));

extern PWresult pwGetEdGeom _PW_((
  PWobjid          edobj,
  PWosnum          os,
  struct PWcvdata  *p_cvdata
));

extern PWresult pwGetEdGeomAsLinear _PW_((
  PWobjid          edobj,
  PWosnum          os,
  struct PWpoly2d  *p_py2d
));

extern PWresult pwGetEdGeomAsBspline _PW_((
  PWobjid              edobj,
  PWosnum              os,
  struct IGRbsp_curve  **p_curve
));

extern PWresult pwGetNatEdGeom _PW_((
  PWobjid          edobj,
  PWosnum          os,
  struct PWcvdata  *p_cvdata
));

extern PWresult pwGetNatEdGeomAsLinear _PW_((
  PWobjid          edobj,
  PWosnum          os,
  struct PWpoly2d  *p_py2d
));

extern PWresult pwGetNatEdGeomAsBspline _PW_((
  PWobjid              edobj,
  PWosnum              os,
  struct IGRbsp_curve  **p_curve
));

extern void pwGetEdEndPts _PW_((
  PWobjid    edobj,
  PWosnum    os,
  PWpoint2d  startpt,
  PWpoint2d  stoppt
));

extern void pwGetEdEndPars _PW_((
  PWobjid           edobj,
  PWosnum           os,
  struct PWcvparam  *p_startpar,
  struct PWcvparam  *p_stoppar
));

extern PWresult  pwCvtToEdPar _PW_((
  PWobjid          edobj,
  PWosnum          os,
  struct PWcvparam *p_inpar,
  struct PWcvparam *p_outpar
));

extern PWresult pwGetNatEdLocation _PW_((
  PWobjid  edobj,
  PWosnum  os,
  int      *location
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
