#ifndef _PWapi_include
#define _PWapi_include



PWresult pwAddDraft
(
  PWobjid solid,
  PWosnum os,
  PWobjid datum_plane,
  int num_draft_sfs,
  PWobjid *draft_sfs,
  struct PWvalueinfo draft_angle,
  PWboolean draft_into_volume,
  PWobjid *drafted_solid
);


/*
  OVERVIEW
  Function prototypes and structures that are required for the use of
  Add/Remove material Feature APIs.

  NOTES

  HISTORY
  Aditya   03/19/96   Creation
*/





extern PWresult pwAddMaterialProjected _PW_(( PWobjid solid,
  PWosnum os,
  PWobjid profile_cv,
  PWvector dir_vector,
  PWboolean proj_normal,
  PWboolean add_matl_on_right,
  enum PWaddremexttype ext_type,
  PWobjid from_sf,
  PWobjid to_sf,
  struct PWvalueinfo *distance,
  PWobjid *mod_solid
));


extern PWresult pwAddMaterialRevolved _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile_cv,
   PWpoint axis_point,
   PWvector axis_vector,
   PWboolean add_matl_on_right,
   enum PWaddremexttype ext_type,
   PWobjid from_sf,
   PWobjid to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *mod_solid
));


extern PWresult pwAddMatlBySkinning _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile_cv,
   PWobjid trace_curve,
   enum PWaddremexttype type,
   PWboolean along_trace_curve,
   PWobjid *mod_solid
));


extern PWresult pwRemMatProjected _PW_((
  PWobjid solid,
  PWosnum os,
  PWobjid profile,
  PWvector dir_vector,
  PWboolean proj_normal,
  PWboolean rem_matl_on_right,
  enum PWaddremexttype ext_type,
  PWobjid from_sf,
  PWobjid to_sf,
  struct PWvalueinfo *depth,
  PWobjid *mod_solid
));

extern PWresult pwRemMatRevolved _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile,
   PWpoint axis_point,
   PWvector axis_vector,
   PWboolean rem_matl_on_right,
   enum PWaddremexttype ext_type,
   PWobjid from_sf,
   PWobjid to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *mod_solid
));


extern PWresult pwRemMatBySkinning _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile,
   PWobjid trace_curve,
   enum PWaddremexttype type,
   PWboolean along_trace_curve,
   PWobjid *mod_solid
));


extern PWresult pwQueryAddMatProjected _PW_((
  PWobjid feature_id,
  PWosnum os,
  PWobjid *profile,
  PWvector *dir_vector,
  PWboolean *proj_normal,
  PWboolean *add_matl_on_right,
  enum PWaddremexttype *ext_type,
  PWobjid *from_sf,
  PWobjid *to_sf,
  struct PWvalueinfo *distance,
  PWobjid *base_solid
));

extern PWresult pwQueryAddMatRevolved _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWpoint *axis_point,
   PWvector *axis_vector,
   PWboolean *add_matl_on_right,
   enum PWaddremexttype *ext_type,
   PWobjid *from_sf,
   PWobjid *to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *base_solid
));


extern PWresult pwQueryAddMatBySkinning _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWobjid *trace_curve,
   enum PWaddremexttype *ext_type,
   PWboolean *along_trace_curve,
   PWobjid *base_solid
));


extern PWresult pwQueryRemMatProjected _PW_((
  PWobjid feature_id,
  PWosnum os,
  PWobjid *profile,
  PWvector *dir_vector,
  PWboolean *proj_normal,
  PWboolean *rem_matl_on_right,
  enum PWaddremexttype *ext_type,
  PWobjid *from_sf,
  PWobjid *to_sf,
  struct PWvalueinfo *depth,
  PWobjid *mod_solid
));

extern PWresult pwQueryRemMatRevolved _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWpoint *axis_point,
   PWvector *axis_vector,
   PWboolean *rem_matl_on_right,
   enum PWaddremexttype *ext_type,
   PWobjid *from_sf,
   PWobjid *to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *base_solid
));


extern PWresult pwQueryRemMatBySkinning _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWobjid *trace_curve,
   enum PWaddremexttype *ext_type,
   PWboolean *along_trace_curve,
   PWobjid *mod_solid
));






extern PWresult pwClassifyInteractionWithAdjseg _PW_((
  struct PWcvdata      *p_bdata,       /* Boundary data */
  PWboolean            b_reverse,     
  struct PWcvdata      *p_badjdata,
  PWboolean            badj_reverse,
  struct PWcvpt        *p_bpt,         /* Intersection point on Boundary 
                                          data */
 
  struct PWcvdata      *p_idata,       /* Intersection data */
  PWboolean            i_reverse,
  struct PWcvdata      *p_iadjdata, 
  PWboolean            iadj_reverse,
  struct PWcvpt        *p_ipt,         /* Intersection point on Intersection 
                                          data */

  PWvector             dirvec,
  double               lentol,

  enum PWcontaintype   intrels[2]      /* Intersection point classification */
));

extern PWresult pwGetFwBwTangentsCvdata _PW_((
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_cvpar,
  PWboolean         reversed,
  double            lentol,
  PWvector          tangents[2]
));

extern PWresult pwGetFwBwCurvatureBspcv _PW_((
  struct IGRbsp_curve *p_cv,
  PWboolean           reversed,
  double              par,
  double              max_disp,
  double              *kurv,
  double              *rad,
  PWpoint             points[4],
  PWboolean           *cusp

));

extern enum PWcontaintype get_rel_from_angles1 _PW_((
  double  ang1, 
  double  ang2, 
  double  angtol
));

extern void pwClassifyPointWithCurvature _PW_((
  PWvector  b_bwd,
  PWvector  b_fwd,
  PWvector  i_bwd,
  PWvector  i_fwd,

  double    b_bwd_rad,
  double    b_fwd_rad,
  double    i_bwd_rad,
  double    i_fwd_rad,

  PWvector  b_bwd_cen,
  PWvector  b_fwd_cen,
  PWvector  i_bwd_cen,
  PWvector  i_fwd_cen,


  PWpoint   intpt,

  PWvector  dirvec,

  double    lentol,

  enum PWcontaintype  intrels[2]
));

extern void pwClassifyPointWithCurvature1 _PW_((
  PWvector  b_bwd,
  PWvector  b_fwd,
  PWvector  i_bwd,
  PWvector  i_fwd,

  double    b_bwd_rad,
  double    b_fwd_rad,
  double    i_bwd_rad,
  double    i_fwd_rad,

  PWvector  b_bwd_cen,
  PWvector  b_fwd_cen,
  PWvector  i_bwd_cen,
  PWvector  i_fwd_cen,

  PWpoint   intpt,

  PWvector  dirvec,

  double    lentol,

  PWboolean *is_ib_bwd_same,

  enum PWcontaintype  intrels[2]
));

extern PWresult pwGetFwBwCurvatureBspcv1 _PW_((
  struct IGRbsp_curve *p_cv,
  double              par, 
  double              max_disp,
  double              *kurv,
  double              *rad,
  PWpoint             points[4],
  PWboolean           *cusp
  
));







extern int pwAlignCvSize  _PW_((
  int num_poles, 
  short order, 
  PWboolean rational, 
  int num_boundaries
));

extern int pwAlignSfSize _PW_((
  long u_num_poles, 
  long v_num_poles, 
  short u_order, 
  short v_order, 
  PWboolean rational, 
  int num_boundaries,
  int *points_per_bnd
));

extern void pwAlignCvGeom _PW_((
  long num_poles, 
  short order, 
  PWboolean rational, 
  int num_boundaries, 
  struct IGRbsp_curve  *p_curve
));

extern void pwAlignSfGeom _PW_((
  long u_num_poles, 
  long v_num_poles, 
  short u_order, 
  short v_order, 
  PWboolean rational, 
  int num_boundaries, 
  int *points_per_bnd, 
  struct IGRbsp_surface *p_surface
));







extern PWresult      pwGetAmbiguousVecs  _PW_(( 
   int numvecs, 
   double (*vecs)[3], 
   double *dirvec,
   int *sort_indices, 
   int *numambi,
   int *p_ambi_indices 
));

extern double     pwConvertAngleMeasure _PW_(( 
  double ang_meas
));

extern void    pwMergeAmbiguousVecs _PW_(( 
   int numambi,
   int *ambi_indices, 
   int numsort,
   int *sort_indices, 
   int *newlist 
));





extern PWresult pwAngle2d _PW_((
  PWvector2d  vec_a,
  PWvector2d  vec_b,
  double      *radians 
));

extern PWresult pwAngle _PW_((
  PWvector  vec_a,
  PWvector  vec_b,
  PWvector  ndirvec,
  double    *radians
));





extern double pwAngmeas2d  _PW_((
  PWvector2d nvec1, 
  PWvector2d nvec2
));

extern double pwAngmeas  _PW_((
  PWvector nvec1, 
  PWvector nvec2,
  double *dirvec
));

extern double pwGetAngFromAngmeas  _PW_((
  double angmeas
));







extern double pwGetZeroAngTolDeg _PW_((
));

extern double pwGetZeroAngTolRad _PW_((
));

extern void pwSetZeroAngTolDeg  _PW_((
  double angtol
));

extern void pwSetZeroAngTolRad  _PW_((
  double angtol
));

extern double pwGetCosZeroAngTol _PW_((
));

extern double pwGetSinZeroAngTol _PW_((
));







extern PWresult pwGetSymbology _PW_((
  PWobjid                 objid, 
  PWosnum                 os,
  struct GRsymbology     *p_symb
));






extern struct PWattrib *pwCreateIntAttrib  _PW_((
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  int              attrib_val
));

extern struct PWattrib *pwCreateDoubleAttrib  _PW_((
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  double           attrib_val
));

extern struct PWattrib *pwCreateGenAttrib  _PW_((
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  char             *p_gen_val,
  void             (*free_func)(char *),
  char             *(*copy_func)(char *)
));

extern PWboolean pwGetIntAttrib _PW_((
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  int              *attrib_val
));

extern PWboolean pwGetDoubleAttrib _PW_((
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  double           *attrib_val
));

extern PWboolean pwGetGenAttrib _PW_((
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  char             **attrib_val
));

extern struct PWattrib *pwGetAttribPtr _PW_((
  struct PWattrib    *p_attrib, 
  unsigned int       ident,
  enum PWattribtype  attribtype
));

extern void pwFreeAttribList _PW_(( 
  struct PWattrib *p_attrib
));

extern void pwRemoveAttrib _PW_((
  struct PWattrib **p_attrib,
  struct PWattrib *p_remove_attrib
));

extern struct PWattrib *pwCopyAttribList _PW_((
  struct PWattrib *p_attrib
));







extern unsigned pwGetBits _PW_(( 
  unsigned word, 
  int pos, 
  int nbits 
));

extern void pwSetBits _PW_(( 
  unsigned *word, 
  int pos, 
  int nbits, 
  int mask 
));







extern void pwUnweightPoles _PW_ ((
  int num_poles,
  PWpoint *poles,
  double *weights,
  PWpoint *unweighted_poles
));

extern void pwUnweightPoles2d _PW_ ((
  int num_poles,
  PWpoint2d *poles,
  double *weights,
  PWpoint2d *unweighted_poles
));





extern PWresult  pwChangeEMSCvdata _PW_((
  struct EMSdataselect *p_datasel,
  struct PWcvdata      *p_cvdata,
  short                mattyp,
  PWmatrix             p_mat,
  PWboolean            *p_allocated
));

extern void pwFreeCvdata _PW_((
  struct PWcvdata *cvdata
));








extern void pwInitClocks _PW_((
));

extern void pwInitClock _PW_((
  int clock_number
));

extern void pwStartClock _PW_((
  int clock_number
));

extern void pwStopClock _PW_((
  int clock_number
));

extern void pwPrintClock _PW_((
  FILE *file,
  int clock_number
));

extern int pwGetRealTime _PW_((
  int clock_number
));

extern int pwGetUserTime _PW_((
  int clock_number
));

extern int pwGetSysTime _PW_((
  int clock_number
));





extern PWclassid omClassidFromObjid _PW_((
  PWobjid objid,
  PWosnum osnum
));

extern char *omClassNameFromClassid _PW_((
  PWclassid classid,
  PWosnum osnum,
  char *classname
));

extern PWclassid omClassidFromName _PW_((
  char *classname,
  PWosnum osnum
));

extern PWboolean omIsAncestryValid  _PW_((
  PWclassid subclassid,
  PWclassid superclassid
));







extern PWresult pwCloseUvCompCvWithFaceBounds _PW_((
  int num_cvs,
  struct PWcvdata *p_uvcvs,  

  PWobjid fcobj,
  PWosnum os,

  PWboolean reverse, /* reverse the bdry curves */

  PWvector startextvec,
  PWvector stopextvec,
  PWboolean ignoremidcvs,

  double lentol,

  PWboolean *start_extended,
  PWboolean *stop_extended,

  int *num_loops,
  int **num_edges_loop,
  struct PWgeomloop **p_loops
));

extern void pwCopyCvdata _PW_((
  struct PWcvdata *p_incv,
  struct PWcvdata *p_outcv
));

extern void pwGetMidCvpar _PW_((
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  double dist_factor,
  
  struct PWcvparam *p_par
));







extern PWresult pwCloseXyzCompCvWithFaceBounds _PW_((
  int num_xyzcv,
  struct PWcvdata *p_xyzcvs,

  PWobjid fcobj,
  PWosnum os,
  PWboolean reverse,

  PWvector startextvec,
  PWvector stopextvec,
  PWboolean ignoremidcvs,

  double lentol,

  PWboolean *start_extended,
  PWboolean *stop_extended,

  int *num_loops,
  int **num_edges_loop,
  struct PWgeomloop **p_loops
));







extern PWresult pwGetGroundGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetHorizVertGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetCoincidentGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetTangencyGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetPointOnElementGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out,
  struct PWcvpt *cvpt
));

extern PWresult pwGetParallelGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id1,
  PWobjid *geom_id2
));

extern PWresult pwGetCollinearGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetEqualityGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id1,
  PWobjid *geom_id2
));

extern PWresult pwGetNormalGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
));

extern PWresult pwGetSinglparlGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out
));

extern PWresult pwGetRadialGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out
));

extern PWresult pwGetStackedGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetAxisStackedGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetAbsangleGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetRelangleGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
));

extern PWresult pwGetDimConstraintProps _PW_((
  PWobjid cnstr_id,
  PWosnum os,
  PWboolean *is_clockwise,
  PWboolean *is_negative_axis,
  PWboolean *is_supplement
));




/*
  OVERVIEW
  Function prototypes and structures that are required for the use of
  Profile Query  APIs.

  NOTES

  HISTORY
  Satya   06/11/96   Creation
*/




extern enum PWprfcnstrtype  pwConstraintType   _PW_((
  PWobjid cnstr_id,
  PWosnum os
));

extern double pwDimConstraintVal  _PW_((
  PWobjid dimcnstr_id,
  PWosnum os
));

extern PWboolean pwIsDimConstraint   _PW_((
  PWobjid cnstr_id,
  PWosnum os
));

extern PWboolean pwIsGeomConstraint   _PW_((
  PWobjid cnstr_id,
  PWosnum os
));

extern PWresult  pwGetProfileConstraints _PW_((
  PWobjid profile_id,
  PWosnum os,
  PWobjid *constraints
));

extern PWresult pwGetConstraintGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
));

extern int pwNumProfileConstraints  _PW_(( 
  PWobjid profile_id,
  PWosnum os
));

extern int pwGetDimObject _PW_((
  PWobjid cnstr_id,
  PWosnum os,
  PWobjid *dim_id
));

extern PWresult pwGetConstraintProps _PW_((
  PWobjid cnstr_id,
  PWosnum os,
  unsigned short *vprops
));





extern PWresult pwCoincVec2d  _PW_((
  int numvecs,
  PWvector2d *vecs,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
));

extern PWresult pwCoincVec _PW_((
  int numvecs,
  PWvector *vecs,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
));







extern PWresult pwGetColorMapSize _PW_((
  short *size,
  PWosnum osnum
));


extern PWresult pwGetColorMap _PW_((
  struct IGEvlt *rgb_val, 
  short *num_colors,
  PWosnum osnum
));





extern PWresult pwCompressSurfaceEntity _PW_((
  PWobjid sf_entity,
  PWosnum os,
  PWobjid *comp_entity
));





extern PWresult pwGetBoundsOfCylinder _PW_((
  PWrange rngbx,
  PWpoint axispt,
  PWvector axisvec,
  PWpoint base_center,
  PWpoint height_center
));

extern PWresult pwGetBoundsOfCone _PW_((
  PWrange rngbx,
  PWpoint axispt,
  PWvector axisvec,
  double  halfangle,
  PWpoint   genpt,
  PWvector  majoraxis,
  PWboolean same,
  PWpoint base_center,
  double  *base_radius,
  PWpoint top_center,
  double  *top_radius
));







extern enum PWdirtype pwCrossProd2d  _PW_((
  PWvector2d vec1, 
  PWvector2d vec2,
  double tol, 
  double *val
));

extern enum PWdirtype pwCrossProd  _PW_((
  PWvector vec1,
  PWvector vec2,
  double tol,
  double *val
));

extern enum PWdirtype pwCrossProdAngTol2d  _PW_((
  PWvector2d vec1,
  PWvector2d vec2,
  double atol,
  double *val
));

extern enum PWdirtype pwCrossProdAngTol  _PW_((
  PWvector vec1,
  PWvector vec2,
  double atol,
  double *val
));

extern double pwCross2d _PW_((
  PWvector2d v1,
  PWvector2d v2
));

extern void pwCross _PW_((
  PWvector v1,
  PWvector v2,
  PWvector cv
));





extern int pwNumCvsOfCompCv  _PW_((
  PWobjid  cvobj,
  PWosnum  os
));

extern int pwCvsOfCompCv  _PW_((
  PWobjid  cvobj,
  PWosnum  os,
  PWobjid  *p_cvs
));







extern PWobjid  pwCreateCvObj _PW_((
  struct PWcvdata  *p_cvdata,
  PWosnum  os
));







extern PWresult pwDisplayCv _PW_((
  struct IGRbsp_curve *cv,
  enum PWdisplaymode dpmode
));







extern PWresult pwGetCvPlane _PW_((
  PWobjid cvid,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  struct PWplane *plane
));






extern PWresult pwGetCvAsBspline _PW_((
  PWobjid                 cvobj, 
  PWosnum                 os,
  short                   mattyp,
  PWmatrix                matrix,
  struct IGRbsp_curve     *p_cvgeom
));

extern int  pwGetCvSize  _PW_((
  PWobjid  cvobj,
  PWosnum  os
));

extern PWresult pwGetCvAsCvdata _PW_((
  PWobjid          cvobj,
  PWosnum          os,
  short            mattyp,
  PWmatrix         matrix,
  struct PWcvdata  *p_cvdata
));

extern enum PWcvdatatype pwGetCvType _PW_((
  PWobjid cvobj, 
  PWosnum os
));

extern int pwGetCvAsCvdataSize _PW_((
  PWobjid cvobj,
  PWosnum os
));

extern PWresult pwGetCvEndPts  _PW_((
  PWobjid          cvobj,
  PWosnum          os,
  short            mattyp,
  PWmatrix         matrix,
  PWpoint          Start,
  PWpoint          End
));


/*
 * Macros that are used to perform the very common functions dealing with
 * curve geometry. The "Stack" macro should be used whenever curve
 * geometry is being requested for within-the-function computations.
 * NOTES: These macros should be used with the same syntax as PW-API
 * functions that return a PWresult. This result must then be tested to
 * make sure the op was successful. A single-pointer is the argument to hold
 * the curve geometry as opposed to the more conventional double-pointer
 * used when invoking a function of similar behaviour.
 */

  ( \
    pwGetCvAsBspline ((cvobj), (os), (mattyp), (matrix), \
     (p_bspcv) = (struct IGRbsp_curve *) \
                  alloca (pwGetCvSize ((cvobj), (os)))) \
  )

  ( \
    pwGetCvAsBspline ((cvobj), (os), (mattyp), (matrix), \
     (p_bspcv) = (struct IGRbsp_curve *) \
                  malloc (pwGetCvSize ((cvobj), (os)))) \
  )

  ( \
    (((curve).poles = (double *) alloca ((npoles) * sizeof (PWpoint))) && \
    ((curve).knots = (double *) alloca (((npoles)+(order)) * \
                                        sizeof (double))) && \
    (rational ? (int) ((curve).weights = (double *) alloca ((npoles) * \
                                        sizeof (double)))   : TRUE)) ? \
    (PW_K_Success) : SetError (PW_K_Pathway, PW_K_DynamicMemory) \
  )

  ( \
    (((curve).poles = (double *) malloc ((npoles) * sizeof (PWpoint))) && \
     ((curve).knots = (double *) malloc (((npoles)+(order)) * \
                                        sizeof (double))) && \
     (rational ?  (int) ((curve).weights = (double *) malloc ((npoles) * \
                                        sizeof (double)))   : TRUE)) ? \
     (PW_K_Success) : SetError (PW_K_Pathway, PW_K_DynamicMemory) \
  )

  ( \
    ((pwGetCvType ((cvobj), (os)) == PWcvdata_py) ? \
      (int) ((cvdata).data.py.p_pts = (PWpoint *) alloca \
                                   (pwGetCvAsCvdataSize ((cvobj), (os)))) : \
      (int) ((pwGetCvType ((cvobj), (os)) == PWcvdata_bspcv) ? \
        (int) ((cvdata).data.p_bspcv = (struct IGRbsp_curve *) alloca \
                          (pwGetCvAsCvdataSize ((cvobj), (os)))) : TRUE)) ? \
    (pwGetCvAsCvdata ((cvobj), (os), (mattyp), (matrix), &(cvdata))) : \
    (SetError (PW_K_Pathway, PW_K_InvalidArg)) \
  )

  ( \
    ((pwGetCvType ((cvobj), (os)) == PWcvdata_py) ? \
      (int) ((cvdata).data.py.p_pts = (PWpoint *) malloc \
                                   (pwGetCvAsCvdataSize ((cvobj), (os)))) : \
      (int) ((pwGetCvType ((cvobj), (os)) == PWcvdata_bspcv) ? \
        (int) ((cvdata).data.p_bspcv = (struct IGRbsp_curve *) malloc \
                          (pwGetCvAsCvdataSize ((cvobj), (os)))) : TRUE)) ? \
    (pwGetCvAsCvdata ((cvobj), (os), (mattyp), (matrix), &(cvdata))) : \
    (SetError (PW_K_Pathway, PW_K_InvalidArg)) \
  )





extern PWresult pwGetCvdataInternalPts _PW_((
  struct PWcvdata *cvdata,
  int num_internalpts,
  double lentol,
  struct PWcvpt *internalpts
));







extern struct PWcvintpt_list *pwCreateCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts 
));

extern void pwFreeCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts 
));

extern PWboolean pwRemoveCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_remove_node
));

extern PWboolean pwFreeNodeCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_free_node
));

extern void pwInsertAtInxCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_insert_node,
  int                   index
));

extern PWboolean pwSwapNodesCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_a_node,
  struct PWcvintpt_list *p_b_node
));

extern void pwAppendCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_append_node
));

extern void pwPrefixCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_prefix_node
));

extern int pwNumCvintptList _PW_((
  struct PWcvintpt_list *p_from_node
));

extern struct PWcvintpt_list *pwNodeAtInxCvintptList _PW_((
  struct PWcvintpt_list *p_from_node,
  int                   index
));

extern PWboolean pwInxOfNodeCvintptList _PW_((
  struct PWcvintpt_list *p_from_node,
  struct PWcvintpt_list *p_node,
  int                   *index
));

extern struct PWcvintpt_list *pwHeadCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern struct PWcvintpt_list *pwTailCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern void pwSetContainCvintpt _PW_((
  struct PWcvintpt      *p_cvintpt,
  int                   side,
  enum   PWcontaintype  containment
));

extern enum PWcontaintype  pwGetContainCvintpt _PW_((
  struct PWcvintpt      *p_cvintpt,
  int                   side
));

extern void pwSetNoSiblingCvintpt  _PW_((
  struct PWcvintpt *p_cvintpt 
));

extern void pwUnsetNoSiblingCvintpt _PW_((
  struct PWcvintpt *p_cvintpt
));

extern PWboolean pwIsNoSiblingCvintpt _PW_((
  struct PWcvintpt *p_cvintpt
));

extern void pwSetContainCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts, 
  int                   side,
  enum   PWcontaintype  containment
));

extern enum PWcontaintype pwGetContainCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts,
  int                   side
));

extern void pwSetArbSeqCvintptList  _PW_((
  struct PWcvintpt_list *p_cvintpts 
));

extern void pwUnsetArbSeqCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern PWboolean pwIsArbSeqCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern void pwSetCoincCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts,
  int                   side
));

extern void pwUnsetCoincCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts,
  int                   side
));

extern PWboolean pwIsCoincCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts, 
  int                   side
));

extern void pwSetInfoNodeCvintptList  _PW_((
  struct PWcvintpt_list *p_cvintpts 
));

extern void pwUnsetInfoNodeCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern PWboolean pwIsInfoNodeCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern PWresult pwSortCvintptList _PW_((
  struct PWcvintpt_list  **p_cvintpts,    /*  I/O  */
  double                 tol               /*   I   */
));







extern double pwCvdataLen _PW_((
  struct PWcvdata *cvdata
));

extern void pwParAtCvdataLen _PW_((
  struct PWcvdata *cvdata,
  double length_along,
  struct PWcvparam *cvpar
));







extern PWresult pwGetProfilesOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_profiles,
  PWobjid **profiles
));

extern PWresult pwGetCompCvsOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_compcvs,
  PWobjid **compcvs
));

extern PWresult pwGetSingleCvsOfOS _PW_((
  PWosnum  os,
  PWboolean cvs_in_rtree,
  int *num_cvs,
  PWobjid **cvs
));







extern PWboolean pwIsCvOpen  _PW_((
  PWobjid cvobj,
  PWosnum os
));







extern struct PWcvregion_list *pwCreateCvregionList _PW_((
  struct PWcvregion_list **p_cvregions 
));

extern void pwFreeCvregionList _PW_((
  struct PWcvregion_list *p_cvregions 
));

extern PWboolean pwRemoveCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_remove_node
));

extern PWboolean pwFreeNodeCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_free_node
));

extern void pwInsertAtInxCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_insert_node,
  int                    index
));

extern PWboolean pwSwapNodesCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_a_node,
  struct PWcvregion_list *p_b_node
));

extern void pwAppendCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_append_node
));

extern void pwPrefixCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_prefix_node
));

extern int pwNumCvregionList _PW_((
  struct PWcvregion_list *p_from_node
));

extern struct PWcvregion_list *pwNodeAtInxCvregionList _PW_((
  struct PWcvregion_list *p_from_node,
  int                    index
));

extern PWboolean pwInxOfNodeCvregionList _PW_((
  struct PWcvregion_list *p_from_node,
  struct PWcvregion_list *p_node,
  int                    *index
));

extern struct PWcvregion_list *pwHeadCvregionList _PW_((
  struct PWcvregion_list *p_cvregions
));

extern struct PWcvregion_list *pwTailCvregionList _PW_((
  struct PWcvregion_list *p_cvregions
));

extern void pwSetContainCvregion _PW_((
  struct PWcvregion     *p_cvregion, 
  enum   PWcontaintype  containment
));

extern enum PWcontaintype pwGetContainCvregion _PW_((
  struct PWcvregion *p_cvregion
));

extern void pwSetDegenCvregion  _PW_((
  struct PWcvregion *p_cvregion
));

extern void pwUnsetDegenCvregion _PW_((
  struct PWcvregion *p_cvregion 
));

extern PWboolean pwIsDegenCvregion _PW_((
  struct PWcvregion *p_cvregion
));







extern PWboolean pwIsCurve _PW_((
  PWobjid  cvobj,
  PWosnum  cvos
));

extern PWboolean pwIsCompCv _PW_((
  PWobjid  cvobj,
  PWosnum  cvos
));

extern PWboolean pwIsSimpleCv _PW_((
  PWobjid  cvobj,
  PWosnum  cvos
));

extern char pwEMSCvType _PW_((
  short bstype
));

extern PWclassid pwCvClassid _PW_((
  short cvtype
));







extern PWresult pwMapUvCvToXyzOfSfOld _PW_((
  struct PWcvdata   *p_uvcv,
  struct PWsfdata   *p_sfdata,
  double            xyztol,
  struct PWcvdata   *p_xyzcv
));







extern PWresult pwTransformBspline _PW_((
  PWmatrix trans_mat,
  struct IGRbsp_curve *cvin, 
  struct IGRbsp_curve *cvout
));





extern int pwGetDebugLevel _PW_((
));

extern void pwSetDebugLevel _PW_((
  int level
));







extern void pwInitDbgObject _PW_((
  PWosnum osnum
));

extern void pwDeleteDbgObject _PW_((
));

extern void pwAddObjDbgObject _PW_((
  PWobjid grobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat
));

extern void pwAddCvDbgObject _PW_((
  struct PWcvdata *cvdata
));

extern void pwAddSfDbgObject _PW_((
  struct PWsfdata *sfdata
));







extern int pwNumDegenSpans2d _PW_((
  int num_pts, 
  PWpoint2d *pts,
  double tol
));

extern int pwNumDegenSpans _PW_((
  int num_pts, 
  PWpoint *pts,
  double tol
));

extern int pwRemoveDegenSpans2d _PW_((
  int num_inpts,
  PWpoint2d *inpts,
  int *num_outpts,
  PWpoint2d *outpts,
  double tol
));

extern int pwRemoveDegenSpans _PW_((
  int num_inpts,
  PWpoint *inpts,
  int *num_outpts,
  PWpoint *outpts,
  double tol
));

extern PWboolean pwIsDegenPy2d  _PW_((
  int numpts,
  PWpoint2d *pts,
  double tol
));

extern PWboolean pwIsDegenPy _PW_((
  int numpts,
  PWpoint *pts,
  double tol
));

extern PWboolean pwIsCvDegen _PW_((
  struct IGRbsp_curve  *p_cv,
  double               tol
));

extern PWboolean pwIsDegenCvdata _PW_((
  struct PWcvdata *p_cvdata,
  double lentol
));







extern PWresult pwOrientDegenInt _PW_((
  struct EMSinters  **p_inters,
  double            xyztol
));







extern PWresult   pwDeleteInt _PW_((
   struct EMSinters **pp_inters
));






extern PWboolean  pwDetIntReversal _PW_((
  PWobjid             coinc_ed,
  struct EMSintobj    *intobj,
  double              uvtol
));







extern PWresult pwFixangConstraint  _PW_((
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *fixang
));



extern PWresult pwHorizDimConstraint  _PW_((  
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWboolean is_horiz,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *horizdim
));




extern PWresult pwRadialConstraint  _PW_(( 
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *radial
));

extern PWresult pwSingleParlConstraint  _PW_(( 
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *singleparl
));

extern PWresult pwRelangConstraint  _PW_(( 
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *relang
));






extern enum PWrelvectype pwDotLenTol2d  _PW_((
  PWvector2d v1,
  PWvector2d v2,
  double tol,
  double *val
));

extern enum PWrelvectype pwDotLenTol  _PW_((
  PWvector v1,
  PWvector v2,
  double tol,
  double *val
));

extern double pwDot2d _PW_((
  PWvector2d v1,
  PWvector2d v2
));

extern double pwDot _PW_((
  PWvector v1,
  PWvector v2
));








extern PWresult pwGetDpbInfo _PW_ ((
    struct PWdpbdata *dpbdata,
    PWosnum os
));

extern PWresult pwSetBSFromDpbInfo _PW_ ((
    struct PWdpbdata *dpbdata
));











extern PWresult pwGetDpbParam _PW_((
  PWosnum osnum,
  int param,
  char *buffer
)
);








void pwQueryAddDraft
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid *datum_plane, 
  int *num_draft_sfs,
  PWobjid **draft_sfs, 
  double *draft_angle,
  PWboolean *draft_into_volume,
  PWobjid *base_solid
);







extern void     pwProcessDupInt _PW_(( 
   struct EMSinters **p_inters, 
   double           xyztol
));

extern PWboolean AreIntobjsSame _PW_((
   struct EMSintobj  *p_intcv1,
   struct EMSintobj  *p_intcv2,
   double            tol
));







extern PWresult pwGetEdbcXyzGeom _PW_((
   PWobjid		ed,
   PWosnum		os,
   struct PWsfdata      *p_sfdata,
   struct IGRbsp_curve  **p_bspcv
));







extern PWobjid pwCreateEdge _PW_((
  PWosnum os,
  struct PWcvdata *p_edgeom,
  int edprops,
  int edxyz_type
));

extern PWobjid pwCreateDummyEdge _PW_((
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type
));

extern PWobjid pwCreatePartEdge _PW_((
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type
));

extern PWboolean pwGetNatLocation _PW_((
  PWpoint2d edpts[2],
  double u_min,
  double u_max, 
  double v_min,
  double v_max,

  int *natloc,
  PWboolean *natrev
));







extern PWobjid pwGetPartEdOfEd _PW_((
  PWobjid           edobj,
  PWosnum           os,
  struct PWcvparam  *p_edpar
));

extern PWobjid pwGetCommonEd  _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid pwGetNextEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid pwGetPrevEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid pwGetNextEdNoDegen _PW_((
  PWobjid  edobj,
  PWosnum  os,
  double   lentol
));

extern PWobjid pwGetPrevEdNoDegen _PW_((
  PWobjid  edobj,
  PWosnum  os,
  double   lentol
));

extern PWobjid pwGetEdOfPartEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid  pwGetInterveningEdge _PW_((
  PWosnum            os,
  PWobjid            ed1,
  enum PWtopopostype topo1,
  PWobjid            ed2,
  enum PWtopopostype topo2,
  PWpoint2d          midpt,
  double             uvtol
));







( \
 !((pwGetEdGeomType ((edobj), (os)) == PWcvdata_py2d) ? \
    (int) ((eddata).data.py2d.p_pts = (PWpoint2d *)  \
       alloca (pwGetEdGeomSize ((edobj), (os)))) : \
    (int) ((eddata).data.p_bspcv = (struct IGRbsp_curve *) \
       alloca (pwGetEdGeomSize ((edobj), (os))))) ? \
     (SetError (PW_K_Pathway, PW_K_DynamicMemory)) : \
     (pwGetEdGeom ((edobj), (os), &(eddata))) \
)

( \
    (((eddata).data.py2d.p_pts = NULL) , \
     ((eddata).data.py.p_pts = NULL) , \
     ((eddata).data.p_bspcv = NULL) , \
     ((eddata).data.p_gmbspcv = NULL)) , \
    (pwGetEdGeom ((edobj), (os), &(eddata))) \
)

( \
 !((pwGetEdGeomType ((edobj), (os)) == PWcvdata_py2d) ? \
    (int) ((eddata).data.py2d.p_pts = (PWpoint2d *)  \
       alloca (pwGetEdGeomSize ((edobj), (os)))) : \
    (int) ((eddata).data.p_bspcv = (struct IGRbsp_curve *) \
       alloca (pwGetEdGeomSize ((edobj), (os))))) ? \
     (SetError (PW_K_Pathway, PW_K_DynamicMemory)) : \
     (pwGetNatEdGeom ((edobj), (os), &(eddata))) \
)

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







extern PWresult   pwEdInternalPts _PW_((
  PWobjid edobj,
  PWosnum os,
  int num,
  PWpoint2d *pts
));







extern void pwEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern pwMakeCommEdgeConn _PW_((
 PWosnum    osnum,
 PWboolean  orient1,
 PWboolean  orient2,
 PWobjid    edobj1,
 PWobjid    edobj2
));







extern PWboolean pwIsEdOpen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdRevConn _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdDegen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdIso _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdSubordinate _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdClosedXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdSeam _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdNatural _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern int pwGetEdCvType _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdOpen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdRevConn _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdDegen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdIso _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwUnsetEdIso _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwUnsetEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdSubordinate _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdClosedXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdSeam _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdNatural _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdCvType _PW_((
  PWobjid  edobj,
  PWosnum  edos,
  int      cvtype
));

extern void pwSetEdTangent _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdCompatible _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdDegenTol _PW_((
  PWobjid  edobj,
  PWosnum  edos,
  double   tol
));

extern void pwUnsetEdSubordinate _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwUnsetEdSeam _PW_((
  PWobjid  edobj,
  PWosnum  edos
));
   




extern PWresult    pwEdPtProject _PW_((
  struct PWid     *p_edid,
  int             numpts,
  PWpoint2d       *pts,
  double          uvtol,
  struct PWcvpt   *p_cvpt
));







extern int pwGetEdTypeFromBsType _PW_(( 
  int bstype
));







extern FILE *pwGetErrLogFile _PW_((
));

extern PWboolean pwSetErrLogFile  _PW_((
  char *filename,
  PWboolean append
));

extern void pwResetErrLogFile  _PW_((
));

extern PWboolean pwGetErrLogFilename  _PW_((
  char *filename
));





PWboolean pwPushError 
(
  PWresult retcode
);

PWboolean pwPushErrorId 
(
  PWresult retcode,
  PWobjid id
);

PWboolean pwPushErrorIdVal 
(
  PWresult retcode,
  PWobjid id,
  double val
);

PWboolean pwPushErrorIdId 
(
  PWresult retcode,
  PWobjid id1,
  PWobjid id2
);

PWboolean pwGetFirstError 
(
  struct PWerrentry *p_errentry
);

int pwGetFirstInfoError 
(
  struct PWerrentry *p_errentry
);

PWboolean pwGetErrorAtInx 
(
  int inx,
  struct PWerrentry *p_errentry
);

void pwInitErrorStack
(
);





extern PWresult pwAddHolesToFace _PW_((
  PWosnum os,
  PWobjid face,
  int num_holes,
  PWobjid *p_holes
));







extern PWobjid pwCreateFaceFromEdges _PW_((
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom 
));

extern PWobjid pwCreateHoleFromEdges _PW_((
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom
));







extern PWresult pwAddFaceToSf _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWobjid faceobj
));

extern PWresult pwAddHoleToSf _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWobjid holeobj
));

extern PWresult pwRemoveFaceOfSf _PW_((
  PWobjid faceobj,
  PWosnum os
));

extern PWresult pwRemoveHoleOfSf _PW_((
  PWobjid hole,
  PWosnum os
));






extern PWresult pwIntersectWithFace _PW_((
  struct PWid             *p_faceid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWsfdata         *p_sfdata,
  double                  xyztol,
  struct PWcvintpt_list   **p_cvintpts
));







extern PWresult   pwFcPtLocate _PW_((
           struct PWid      *p_lpid,
           PWpoint          xyzpt,
           PWpoint2d        uvpt,
           struct PWsfdata  *p_sfdata, 
           double           xyztol, 
           enum PWptloctype *p_ptloc, 
           PWobjid          *p_bdryid, 
           struct PWcvpt    *p_edpt
));







extern PWresult pwTrimAgainstFace _PW_((
  struct PWid             *p_faceid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWsfgmid         *p_sfgmid,
  double                  xyztol,
  struct PWcvregion_list  **p_cvregs
));







extern PWboolean pwIsBooleanObj _PW_((
  PWobjid obj,
  PWosnum os,
  enum PWbooltype *booltype
));

extern enum PWfeattype pwFeatureType _PW_((
  PWobjid featnode,
  PWosnum os
));

extern PWresult pwGetFeatureSfs _PW_((
  PWobjid featnode,
  PWosnum os,
  int *num_featsfs,
  PWobjid **featsfs
));

extern PWboolean pwIsFeatureState _PW_((
  PWobjid feature_id,
  PWosnum os,
  enum PWfeattype *feat_type
));

extern PWboolean pwIsFeatureActive _PW_((
  PWobjid feature_id,
  PWosnum os
));






extern struct PWgeomloop *pwCreateGeomloop  _PW_((
  struct PWgeomloop **p_loops
));

extern PWboolean pwRemoveGeomloop _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_remove_node
));

extern void pwFreeGeomloop _PW_((
  struct PWgeomloop *p_loops 
));

extern void pwInsertAtInxGeomloop  _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_insert_node, 
  int index
));

extern PWboolean pwSwapNodesGeomloop  _PW_(( 
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_a_node, 
  struct PWgeomloop *p_b_node
));

extern void pwAppendGeomloop  _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_append_node
));

extern void pwPrefixGeomloop  _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_prefix_node
));

extern int pwNumGeomloop _PW_((
  struct PWgeomloop *p_from_node
));

extern struct PWgeomloop *pwNodeAtInxGeomloop  _PW_((
  struct PWgeomloop *p_from_node, 
  int index
));

extern PWboolean pwInxOfNodeGeomloop  _PW_((
  struct PWgeomloop *p_from_node,
  struct PWgeomloop *p_node, 
  int *index
));

extern struct PWgeomloop *pwHeadGeomloop  _PW_((
  struct PWgeomloop *p_loops
));

extern struct PWgeomloop *pwTailGeomloop  _PW_((
  struct PWgeomloop *p_loops
));







extern struct GRmd_env *pwModuleEnv _PW_((
  PWosnum os,
  struct GRmd_env *md_env
));









extern PWresult pwCoincidentConstraint _PW_((
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *coincident
));

extern PWresult pwCollinearConstraint  _PW_(( 
  int num_elems,
  PWobjid *element_ids,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *collinear
));



extern PWresult pwEqualityConstraint  _PW_(( 
  int num_elems,
  PWobjid *element_ids,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *equal
));

extern PWresult pwGroundConstraint  _PW_(( 
  PWobjid element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr, 
  PWobjid *ground
));


extern PWresult pwHorizVertConstraint  _PW_(( 
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWboolean is_horiz,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *horizvert
));


extern PWresult pwNormalConstraint  _PW_((  
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *normal
));


extern PWresult pwParallelConstraint  _PW_((  
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *parallel
));


extern PWresult pwPtonelmtConstraint  _PW_(( 
  PWobjid *element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *ptonelmt
));


extern PWresult pwTangencyConstraint  _PW_(( 
  PWobjid element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *tangent
));






extern void pwSetTopoposCvpt _PW_(( 
  struct PWcvpt         *p_cvpt,
  enum   PWtopopostype  topopos
));

extern enum PWtopopostype pwGetTopoposCvpt _PW_((
  struct PWcvpt  *p_cvpt
));

extern void pwFreeCvdataGeom _PW_((
  struct PWcvdata *cvdata
));

extern void pwCnvtPyToCv _PW_((
  struct PWpoly       *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
));

extern void pwCnvtPy2dToCv _PW_((
  struct PWpoly2d     *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
));







extern void pwFreeCvdataGeom _PW_ ((
  struct PWcvdata *cvdata
));





extern void pwDisplayObj _PW_((
  PWobjid grobj,
  PWosnum os,
  PWboolean erase,
  PWboolean highlight
));







extern PWresult pwGetFileTopOwners  _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_top_objs,
  PWobjid **top_objs
));

extern PWresult pwGetRtreeTopOwners  _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWclassid rtree_class,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
));







extern PWobjid pwNumCompsOfOwner _PW_((
  PWobjid ownobj,
  PWosnum os
));

extern int pwCompsOfOwner _PW_((
  PWobjid ownobj,
  PWosnum os,
  PWobjid *p_comps
));

extern PWobjid pwCompAtInxOfOwner _PW_((
  PWobjid ownobj,
  PWosnum os,
  int index
));

extern int pwCompInxOnOwner _PW_((
  PWobjid compobj,
  PWosnum os
));

extern PWobjid pwOwnerOfComp _PW_((
  PWobjid compobj,
  PWosnum os
));

extern int pwMaxTreeDepth  _PW_((
  PWobjid ownobj,
  PWosnum os
));

extern int pwCompTreeDepth _PW_((
  PWobjid compobj,
  PWosnum os
));

extern PWobjid pwTopOwner _PW_((
  PWobjid grcomp,
  PWosnum os
));







extern PWboolean pwIsRigidComp _PW_((
  PWobjid grobj,
  PWosnum os
));

extern PWboolean pwIsRigidOwner _PW_((
  PWobjid grobj,
  PWosnum os
));

extern short GraphicsProps _PW_((
  PWobjid grobj,
  PWosnum os
));







extern PWresult pwPrintObject _PW_((
  PWobjid grobj,
  PWosnum os,
  FILE *file,
  PWboolean full_format
));

extern PWresult pwReadAllObjects _PW_((
  FILE *file,
  PWosnum os,
  PWboolean full_format,
  int *num_objects,
  PWobjid **objects
));

extern PWresult ReadObject _PW_((
  FILE *file,
  PWosnum os,
  PWboolean full_format,
  PWboolean create_object_if_needed,
  PWboolean object_data_follows,
  PWobjid *objid
));

extern void InitNewObjTable _PW_((
));

extern void DeleteNewObjTable _PW_((
));

extern PWresult AddNewObjToTable _PW_((
  PWobjid oldobjid,
  PWobjid newobjid
));

extern PWresult GetNewObjFromTable _PW_((
  PWobjid oldobjid,
  PWobjid *newobjid
));







extern void pwInsertDouble _PW_((
  int numinspts,
  double *p_inspts,
  int atinx, 
  int numpts,
  double *p_pts
));

extern void pwInsertPts2d  _PW_((
  int numinspts,
  PWpoint2d *p_inspts,
  int atinx,
  int numpts,
  PWpoint2d *p_pts
));

extern void pwInsertPts _PW_((
  int numinspts,
  PWpoint *p_inspts,
  int atinx,
  int numpts,
  PWpoint *p_pts
));







extern PWboolean pwAreIntobjsCoinc _PW_((
   struct EMSintobj  *p_intcv1,
   struct EMSintobj  *p_intcv2,
   double            tol
));







extern PWresult pwCvCvInt _PW_((
  struct IGRbsp_curve    *p_bcv,
  struct PWadjseg        *p_badjseg,
  PWrange                b_range,
  PWboolean              b_reverse,
  PWboolean              b_process_start, 

  struct IGRbsp_curve    *p_icv,
  struct PWadjseg        *p_iadjseg,
  PWrange                i_range,
  PWboolean              i_reverse,
  PWboolean              i_process_start,

  PWvector               dirvec,
  double                 lentol,

  int                    *p_num_inters,
  struct PWcvintpt_list  **p_cvintpt_list
));

extern PWresult pwGetCvFwBwTangents _PW_((
  struct IGRbsp_curve  *p_cv,
  double               par,
  PWboolean            reverse, 
  double               partol,
  PWvector             tangents[2]
));







extern PWresult pwGetInternalCvPts _PW_((
  struct PWcvdata     *p_cv,
  int                 numpts,
  enum PWtopopostype  topopos,
  struct PWcvpt       *p_internalpts
));







extern void    SetContainIntobj _PW_(( 
   struct EMSintobj       *p_intcv, 
   int                    side,
   enum  PWcontaintype    containment
));

extern enum PWcontaintype   GetContainIntobj _PW_((
   struct EMSintobj  *p_intcv,
   int               side
));







extern PWresult pwIntPyPy2d  _PW_((
  int b_numpts, 
  PWpoint2d *b_pts,
  struct PWadjseg *b_adjseg,
  PWrange2d b_range,
  PWboolean b_reverse, 
  PWboolean b_process_start,

  int i_numpts, 
  PWpoint2d *i_pts,
  struct PWadjseg *i_adjseg,
  PWrange2d i_range,
  PWboolean i_reverse, 
  PWboolean i_process_start,

  double lentol,

  int *num_inters,
  struct PWcvintpt_list **inter_pts
));







extern PWresult       pwComputeIntRels _PW_((
  struct EMSintobj   *p_intcv, 
  double             xyztol
));

extern PWresult    pwGetIntPropsAtPt  _PW_((
  struct EMSintobj         *p_intcv, 
  PWpoint                  sampleptxyz,
  double                   xyztol,
  PWboolean                option, 
  PWvector                 T, 
  PWvector                 *vecs,
  struct IntInfo           *p_intinfo 
));







extern PWboolean pwIntSgSg2d  _PW_((
  PWpoint2d bpt1, 
  PWpoint2d bpt2,
  double *bpt_next,
  PWpoint2d cpt1,
  PWpoint2d cpt2,
  double *cpt_next,

  double lentol,

  int *num_inters,
  PWpoint2d b_inter_pts[2],
  PWpoint2d c_inter_pts[2],
  double bpars[2],
  double cpars[2],
  enum PWtopopostype bposs[2], 
  enum PWtopopostype cposs[2],
  enum PWcontaintype lfrels[2], 
  enum PWcontaintype rtrels[2],
  PWboolean b_atstop_onc[2], 
  PWboolean c_atstop_onb[2]
));







extern PWresult    pwGetXyzTanAtIntPt _PW_((
  short                  mattyp,
  PWmatrix               mat,
  struct EMSdataselect   *ingeom,
  PWpoint                inpt,
  double                 xyztol,
  struct PWcvpt          *projpt,
  PWvector               tanvec
));







extern PWboolean pwIsUvPtsIso _PW_((
  int num_uvpts,
  PWpoint2d *p_uvpts,
  double uvtol,
  int *isodir
));







extern double pwLenVec2d  _PW_((
  PWvector2d vec
));

extern double pwLenVec _PW_((
  PWvector vec
));

extern double pwLenSqVec2d _PW_((
  PWvector2d vec
));

extern double pwLenSqVec _PW_((
  PWvector vec
));





extern char *pwCreateNode _PW_((
  char **p_list,
  unsigned int  size
));

extern PWboolean pwRemoveNode _PW_((
  char **p_list,
  char *p_remove_node
));

extern int pwNumNodes _PW_((
  char *p_from_node
));

extern char *pwNodeAtInx _PW_((
  char *p_from_node,
  int  index
));

extern PWboolean pwInxOfNode _PW_((
  char *p_from_node,
  char *p_node,
  int  *index
));

extern char *pwHead _PW_((
  char *p_list
));

extern char *pwTail _PW_((
  char *p_list
));

extern void pwInsertNodeAtInx _PW_((
  char **p_list,
  char *p_insert_node,
  int  index
));

extern PWboolean pwSwapNodes _PW_((
  char **p_list,
  char *p_a_node,
  char *p_b_node
));

extern void pwAppendNode _PW_((
  char **p_list,
  char *p_append_node
));

extern void pwPrefixNode _PW_((
  char **p_list,
  char *p_prefix_node
));






extern PWresult pwGetLpBdry _PW_((PWobjid lp, PWosnum os, short *mattyp,
				  PWmatrix mat, struct IGRbsp_surface *srfgeom,
				  struct EMSpartolbasis *partolbas,
				  unsigned short options, int depth,
				  int *numbdrys,
				  struct IGRpolyline **xyzbdrys,
				  struct IGRpolyline **uvbdrys,
				  PWobjid **edids, unsigned short **edprops));







extern PWresult pwCreateLoopFromEdgeGeoms _PW_((
  int num_eds,
  struct PWcvdata *p_eddata,
  int *p_edprops,
  int *p_edxyz_type,
  PWboolean *p_edrev,

  struct IGRbsp_surface *p_sfgeom,

  PWosnum os,
  double xyztol,

  int *num_loops,
  PWobjid **p_loops
));

extern PWobjid pwCreateLoopFromEdgeObjs _PW_((
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom 
));

extern PWresult pwConnectSeams _PW_((
  int num_loops,
  PWobjid *p_loops,
  PWosnum os,
  double uvtol
));






extern int pwNumEdsOfLp  _PW_((
  PWobjid loopobj,
  PWosnum os
));

extern int pwEdsOfLp  _PW_((
  PWobjid loopobj,
  PWosnum os,
  PWobjid *p_eds
));

extern PWobjid pwEdAtInxOfLp _PW_((
  PWobjid  loopobj,
  PWosnum  os,
  int      index
));

extern PWobjid pwGetLpOfEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern int pwGetEdInxOnLp  _PW_((
  PWobjid  edobj,
  PWosnum  os
));







extern PWresult pwIntersectWithLoop _PW_((
  struct PWid             *p_lpid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWsfdata         *p_sfdata,
  double                  xyztol,
  struct PWcvintpt_list   **p_cvintpts
));







extern PWresult  pwLpInternalPts _PW_((
  PWobjid          lpobj,
  PWosnum          os,
  struct PWsfdata  *p_sfdata, 
  double           xyztol,
  int              callinx,
  int              num_pts,
  PWpoint2d        *p_pts
));







extern void pwGetLpRange  _PW_((
  PWobjid   loopobj,
  PWosnum   loopos,
  PWrange2d range 
));

extern PWboolean pwIsLpNatural  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpSplit  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpOpen  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpFace  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpOuter  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpNew  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpActive  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpRev _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpNatural  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwUnsetLpNatural  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpSplit  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpOpen  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpFace  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpOuter  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpNew  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpActive  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpRev _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpRange _PW_((
  PWobjid   loopobj,
  PWosnum   loopos
));







extern PWresult  pwLpPtLocate _PW_((        
          struct PWid      *p_lpid,
          PWpoint          xyzpt,
          PWpoint2d        uvpt, 
          struct PWsfdata  *p_sfdata, 
          double           xyztol, 
          enum PWptloctype *p_ptloc,
          PWobjid          *p_edid,
          struct PWcvpt    *p_edpt
));







extern PWresult pwTrimAgainstLoop _PW_((
  struct PWid             *p_lpid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWgeomid         *p_sfgmid,
  double                  xyztol,
  struct PWcvregion_list  **p_cvregs
));







extern PWobjid pwCreateLoopset _PW_((
  PWobjid sfobj,
  PWosnum os
));







extern PWboolean pwIsLsNatural  _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern PWboolean pwIsLsSplit _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern PWboolean pwIsLsXyz _PW_((
  PWobjid lsobj,
  PWosnum lsos
));







extern PWboolean pwIsLsNatural  _PW_((
  PWobjid lsobj,
  PWosnum os
));







extern void pwSetLsNatural  _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern void pwUnsetLsNatural  _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern void pwSetLsSplit _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern void pwSetLsXyz _PW_((
  PWobjid lsobj,
  PWosnum lsos
));







extern PWboolean pwIsLinearMapOkOnPlane _PW_((
  struct IGRbsp_surface *p_sfgeom,
  double lentol
));

extern PWresult pwLinearMapXyzCvToUvOfPlane _PW_((
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,
  
  struct PWcvdata *p_uvcv
));

extern PWresult pwLinearMapXyzCvToUvOfInfPlane _PW_((
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,

  struct PWcvdata *p_uvcv
));

extern PWresult pwLinearMapUvCvToXyzOfPlane _PW_((
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,

  struct PWcvdata *p_xyzcv
));







extern PWresult pwMapXyzCvToUvOfSf _PW_((
  struct PWcvdata *p_xyzcv,
  struct PWsfdata *p_sfdata,
  double xyztol, 

  int *num_uvcv,
  struct PWcvdata **p_uvcv,
  int **p_uvcv_props,
  int **p_xyzcv_type
));

extern PWresult pwMapUvCvToXyzOfSf _PW_((
  struct PWcvdata *p_uvcv,
  struct PWsfdata *p_sfdata,
  double xyztol,
 
  struct PWcvdata *p_xyzcv
));







extern PWresult pwSplitAndMapXyzCvIsoInUvOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  
  int *num_isocvs,
  PWpoint2d isocv_pts[6],

  int *num_non_isocvs,
  struct PWcvdata p_non_isocvs[3]
));







extern PWresult pwSplitAndMapXyzCvSeamInUvOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  
  int *num_seamcvs,
  PWpoint2d **p_seamcvpts,

  int *num_splitcvs,
  struct PWcvdata **p_splitcvs
));







extern double pwDistPtPt2d  _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2
));

extern double pwDistPtPt  _PW_((
  PWpoint pt1,
  PWpoint pt2
));

extern double pwDistSqPtPt2d  _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2
));

extern double pwDistSqPtPt  _PW_((
  PWpoint pt1,
  PWpoint pt2
));

extern PWresult pwProjPtLn2d _PW_((
  PWpoint2d pt, 
  PWpoint2d segpt1,
  PWpoint2d segpt2,
  PWpoint2d minpt,
  double *minpar
));

extern PWresult pwProjPtLn _PW_((
  PWpoint pt, 
  PWpoint segpt1,
  PWpoint segpt2,
  PWpoint minpt,
  double *minpar
));

extern double pwMinDistSqPtSeg2d _PW_((
  PWpoint2d pt,
  PWpoint2d segpt1,
  PWpoint2d segpt2,
  PWpoint2d minpt,
  double *minpar
));

extern double pwMinDistSqPtSeg _PW_((
  PWpoint pt,
  PWpoint segpt1,
  PWpoint segpt2,
  PWpoint minpt,
  double *minpar
));

extern double pwMinDistSqPtPy2d _PW_((
  PWpoint2d pt,
  int numpypts,
  PWpoint2d *pypts,
  PWpoint2d minpt,
  struct PWcvparam *minpar
));

extern double pwMinDistSqPtPy _PW_((
  PWpoint pt,
  int numpypts,
  PWpoint *pypts,
  PWpoint minpt,
  struct PWcvparam *minpar
));

extern PWresult pwProjPtRngPy2d _PW_((
  PWpoint2d pt,
  int numpts,
  PWpoint2d *pts,
  double rngdist,
  PWpoint2d minpt,
  struct PWcvparam *minpar
));

extern PWresult pwProjPtRngPy _PW_((
  PWpoint pt,
  int numpts,
  PWpoint *pts,
  double rngdist,
  PWpoint minpt,
  struct PWcvparam *minpar
));

extern double pwMinDistSqPtCvdata _PW_((
  double           *p_pt,       /* could be 2d or 3d depending on data type */
  struct PWcvdata  *p_cvdata,
  double           *p_minpt,    /* could be 2d or 3d depending on data type */
  struct PWcvparam *p_minpar
));







extern void pwSwapDouble  _PW_((
  double *d1,
  double *d2
));

extern void pwSwapInt  _PW_((
  int *i1,
  int *i2
));

extern void pwSwapPt2d _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2
));

extern void pwSwapPt _PW_((
  PWpoint pt1,
  PWpoint pt2
));

extern void pwCnvt3dTo2d  _PW_((
  int numpts,
  PWpoint *pts,
  PWpoint2d *pts2d
));

extern void pwCnvt2dTo3d  _PW_((
  int numpts,
  PWpoint2d *pts2d,
  PWpoint *pts
));

extern PWresult pwMemInChunks _PW_((
  int num_objs,
  void **p_objs,
  int obj_size,
  int chunk_size
));

extern void pwFree _PW_((
  void *ptr
));






extern PWresult pwMergeCvdata _PW_((
  struct PWcvdata *p_cv1,
  struct PWcvdata *p_cv2,
  double lentol,
  
  struct PWcvdata *p_outcv
));







extern PWresult pwMakeCvRegions _PW_((
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvdata        *p_cvdata,
  PWosnum                os,
  double                 tol,
  struct PWcvregion_list **p_cvregions 
));






extern void pwMakeVec  _PW_((
  PWpoint   frompt,
  PWpoint   topt,
  PWvector  vec
));

extern void pwMakeVec2d _PW_((
  PWpoint2d   frompt,
  PWpoint2d   topt,
  PWvector2d  vec
));







extern PWresult omMakeMessage _PW_((
  char *classname,
  char *messgname,
  void *messgargs,
  int argssize,
  struct PWommsg *messg
));

extern PWresult omSend _PW_((
  struct PWommsg *messg,
  PWobjid targetid,
  PWosnum targetos,
  PWobjid senderid,
  PWboolean invoke_parent_implementation
));





extern double * pwIdMx _PW_((
  PWmatrix mat
));







extern PWresult pwNormVec2d  _PW_((
  PWvector2d vec,
  PWvector2d nvec
));

extern PWresult pwNormVec  _PW_((
  PWvector vec,
  PWvector nvec
));







extern PWobjid omObjOfClass _PW_((
  PWclassid objclass,
  PWosnum os
));

extern PWresult omGetObjsOfClass _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
));

extern PWresult omEligObjs _PW_((
  int num_inobjs,
  PWobjid *inobjs,
  PWosnum os,
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  int *num_outobjs,
  PWobjid **outobjs
));

extern PWresult omGetRtreeObjsOfClass _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
));







extern PWobjid omCreateObjFromClassid _PW_((
  PWosnum os,
  PWclassid clsid
));

extern PWobjid omCreateObjFromObjid _PW_((
  PWosnum os,
  PWobjid objid
));







extern PWresult omDeleteObject _PW_((
  PWobjid object,
  PWosnum os
));







extern PWboolean omIsObjidValid _PW_((
  PWobjid objid,
  PWosnum osnum
));







extern void omReportError _PW_((
  PWresult status
));







extern void pwRevNormalSf _PW_((
  PWobjid  sfobj,
  PWosnum  os 
));







extern PWresult omRuntimeInit _PW_((
));

extern PWresult omConstructOS  _PW_((
  char *filename,
  PWobjid *osobjid,
  PWosnum *osnum,
  int *numobjs_in_space
));

extern PWresult omFileNameToOS  _PW_((
  char *filename,
  PWosnum *osnum
));

extern PWresult omDeleteOS _PW_((
  PWosnum osnum
));

extern PWresult omWriteOS  _PW_(( 
  PWosnum osnum,
  PWobjid osobjid
));

extern PWresult omCloseOS  _PW_((
  PWosnum osnum
));

extern PWresult omGetFileName  _PW_((
  PWosnum os,
  char *filename
));

extern PWresult omGetProdVersion _PW_((
  PWosnum os,
  char *prodname,
  int ver[4]
));








extern PWresult pwPartOfPy2d _PW_((
  int num_pts,
  PWpoint2d *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  int *num_outpts,
  PWpoint2d *p_outpts
));

extern PWresult pwPartOfPy  _PW_((
  int num_pts,
  PWpoint *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  int *num_outpts,
  PWpoint *p_outpts
));

extern PWresult pwPartOfCv _PW_((
  struct IGRbsp_curve *p_cv,
  double startpar,
  double stoppar,
  double midpar,

  double lentol,

  struct IGRbsp_curve *p_outcv
));

extern PWresult pwPartOfCvdata _PW_((
  struct PWcvdata *p_cvdata,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  struct PWcvdata *p_outcvdata
));





extern double pwGetParTolCv  _PW_((
  struct IGRbsp_curve *cv,
  double xyztol
));

extern double pwGetParTolSf  _PW_((
  struct IGRbsp_surface *sf,
  double xyztol
));







extern enum PWtopopostype pwGetPosPtSg2d _PW_((
  double par,
  PWpoint2d pt1, 
  PWpoint2d pt2,
  double tol
));

extern enum PWtopopostype pwGetPosPtSg _PW_((
  double par,
  PWpoint pt1, 
  PWpoint pt2,
  double tol
));

extern enum PWtopopostype pwGetPosPtPy2d _PW_((
  struct PWcvparam *par,
  int numpts, 
  PWpoint2d *pts,
  double tol
));

extern enum PWtopopostype pwGetPosPtPy _PW_((
  struct PWcvparam *par,
  int numpts, 
  PWpoint *pts,
  double tol
));

extern PWboolean pwIsParAtCvEnd _PW_((
  struct PWcvparam *par,
  PWboolean at_stop_end,
  struct PWcvdata *cvdata,
  PWboolean cv_reverse,
  double lentol
));







extern void pwStringAttrib  _PW_((
  enum PWattribtype attr,
  char *str
));

extern void pwPrintAttrib  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWattrib *attrib
));







extern void pwStringCvtype _PW_((
  enum PWcvdatatype cvtype,
  char *str
));

extern void pwStringSftype  _PW_((
  enum PWsfdatatype sftype,
  char *str
));

extern void pwStringTopopos  _PW_((
  enum PWtopopostype pos,
  char *str
));

extern char *pwStringFeattype _PW_((
  enum PWfeattype feattype,
  char *str
));

extern int pwCvdata  _PW_((
  struct PWcvdata *cvdata
));

extern void pwPrintCvdata  _PW_((
  FILE *file,
  int num_indent,
  struct PWcvdata *cvdata
));

extern int pwPoly2d  _PW_((
  struct PWpoly2d *py
));

extern void pwPrintPy2d  _PW_((
  FILE *file,
  int num_indent,
  struct PWpoly2d *py
));

extern int pwPoly _PW_(( 
  struct PWpoly *py
));

extern void pwPrintPy  _PW_((
  FILE *file,
  int num_indent,
  struct PWpoly *py
));

extern int pwBspcurve  _PW_((
  struct IGRbsp_curve *cv
));

extern void pwPrintBspCv  _PW_((
  FILE *file,
  int num_indent,
  struct IGRbsp_curve *bspcv
));

extern int pwSfdata  _PW_((
  struct PWsfdata *sfdata
));

extern void pwPrintSfdata _PW_((
  FILE *file,
  int num_indent,
  struct PWsfdata *sfdata
));

extern int pwBspsurface _PW_((
  struct IGRbsp_surface *bspsf
));

extern void pwPrintBspSf  _PW_((
  FILE *file,
  int num_indent,
  struct IGRbsp_surface *bspsf
));

extern int pwCvpt  _PW_((
  struct PWcvpt *cvpt
));

extern void pwPrintCvpt  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvpt *cvpt
));







extern void pwStringContain  _PW_((
  enum PWcontaintype cont,
  char *str
));

extern int pwCvintpt  _PW_((
  struct PWcvintpt *cvintpt
));

extern void pwPrintCvintpt  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvintpt *cvintpt
));

extern int pwCvintpt_list  _PW_((
  struct PWcvintpt_list *cvintpt_list
));

extern void pwPrintCvintptList  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvintpt_list *cvintpts
));

extern int pwCvregion _PW_(( 
  struct PWcvregion *cvregion
));

extern void pwPrintCvregion _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvregion *cvregion
));

extern int pwCvregion_list  _PW_((
  struct PWcvregion_list *cvregion_list
));

extern void pwPrintCvregionList  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvregion_list *cvregions
));







extern int pwGetSubsysString _PW_((
  unsigned int holder,
  char *str
));

extern int pwGetErrCodeString _PW_((
  unsigned int holder,
  char *str
));

extern int pwGetErrCodeTypeString _PW_((
  unsigned int holder,
  char *str
));

extern int pwGetErrorString  _PW_((
  PWresult code,
  char *errstr
));

extern int pwPrintCode  _PW_((
  FILE *fp,
  PWresult code
));

extern void pwPrintError  _PW_((
  PWresult code,
  char *str
));

extern void pwPrintErrorId  _PW_((
  PWresult code,
  char *str, 
  PWobjid id
));

extern void pwPrintErrorIdVal  _PW_((
  PWresult code,
  char *str,
  PWobjid id, 
  double val
));

extern void pwPrintErrorIdId  _PW_((
  PWresult code,
  char *str,
  PWobjid id1,
  PWobjid id2
));

extern void pwPrintFileLine _PW_((
  char *filename,
  int linenum
));

extern void pwDebugLine _PW_((
  int debug_level,
  char *format,
  ...
));







extern int pwPoint2d _PW_((
  PWpoint2d pt
));

extern void pwPrintPt2d _PW_((
  FILE *file,
  int num_indent,
  PWpoint2d pt
));

extern int pwPoint  _PW_((
  PWpoint pt
));

extern void pwPrintPt  _PW_((
  FILE *file,
  int num_indent,
  PWpoint pt
));

extern void pwPrintId _PW_((
  FILE *file,
  int num_indent,
  PWobjid objid,
  PWosnum os
));




/*
  OVERVIEW
  Function prototypes and structures that are required for the use of
  Profile Query  APIs.

  NOTES

  HISTORY
  Satya   06/11/96   Creation
*/





extern PWobjid pwGetRefPlane  _PW_((
  PWobjid profile_id,
  PWosnum os
));

extern PWresult  pwGetProfileComponents  _PW_(( 
  PWobjid profile_id,
  PWosnum os,
  PWobjid *components
));

extern int pwNumProfileComponents  _PW_(( 
  PWobjid profile_id,
  PWosnum os
));

extern PWresult  pwGetCvComponents   _PW_((
  PWobjid comp_curve,
  PWosnum os,
  PWobjid *components
));

extern int pwNumCvComponents  _PW_(( 
  PWobjid comp_curve,
  PWosnum os
));


extern PWresult pwProfileXformMat  _PW_(( 
  PWobjid profile_id,
  PWosnum os,
  short inp_mattyp,
  PWmatrix inp_mat,
  short  *xyz_xy_mattyp,
  PWmatrix xyz_xy_mat,
  short  *xy_xyz_mattyp,
  PWmatrix xy_xyz_mat
));




   (bx)[0][0] -= (tol); \
   (bx)[0][1] -= (tol); \
   (bx)[1][0] += (tol); \
   (bx)[1][1] += (tol); \

   (bx)[0][0] = (uvpt)[0] - (tol); \
   (bx)[0][1] = (uvpt)[1] - (tol); \
   (bx)[1][0] = (uvpt)[0] + (tol); \
   (bx)[1][1] = (uvpt)[1] + (tol); \

   (bx)[0][0] = (xyzpt)[0] - (tol); \
   (bx)[0][1] = (xyzpt)[1] - (tol); \
   (bx)[0][2] = (xyzpt)[2] - (tol); \
   (bx)[1][0] = (xyzpt)[0] + (tol); \
   (bx)[1][1] = (xyzpt)[1] + (tol); \
   (bx)[1][2] = (xyzpt)[2] + (tol); \

       ( ((pt)[0]>=(box)[0][0])&&((pt)[1]>=(box)[0][1])&& \
((pt)[0]<=(box)[1][0])&& ((pt)[1]<=(box)[1][1])) ? TRUE : FALSE




extern PWresult   pwPtNesting _PW_((
   struct PWid  *p_lpid,
   PWpoint2d    uvpt,
   double       xyztol,
   int          *p_lpcount,
   PWobjid      *p_outlpids
));







extern PWresult pwPtAtParPy2d _PW_((
  int               numpts,
  PWpoint2d         *p_pts,
  struct PWcvparam  *p_par,
  PWpoint2d         pt 
));

extern PWresult pwPtAtParPy _PW_((
  int               numpts,
  PWpoint           *p_pts,
  struct PWcvparam  *p_par,
  PWpoint2d         pt 
));

extern PWresult pwPtAtParCv _PW_((
  struct IGRbsp_curve  *p_bspcv,
  double               par,
  double               *p_pt
));

extern PWresult pwPtAtParCvdata _PW_((
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_par,
  double            *p_pt
));

extern PWresult pwGetTangentPy2d _PW_((
  struct PWpoly2d  *p_py,
  int              spaninx,
  PWboolean        reverse,
  PWvector2d       tangent
));

extern PWresult pwGetTangentPy _PW_((
  struct PWpoly    *p_py,
  int              spaninx,
  PWboolean        reverse,
  PWvector         tangent
));

extern PWresult pwGetTangentCv _PW_((
  struct IGRbsp_curve  *p_cv,
  double               par,
  PWboolean            reverse,
  PWvector             tangent
));

extern PWresult pwGetTangentCvdata  _PW_((
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar,
  PWboolean        reverse,
  double           *p_tangent
));

extern PWresult pwParAtPtCvdata _PW_((
  struct PWcvdata  *p_cvdata,
  double           *p_pt,       /* could be 2d or 3d depending on data type */
  double           tol,         /* The input must be lying on the input geom
                                   with in this tolerance */
  double           *p_minpt,    /* could be 2d or 3d depending on data type */
  struct PWcvparam *p_cvpar
));

extern void pwGetEndPtCvdata _PW_((
  struct PWcvdata *p_cvdata,
  PWboolean       reversed,
  PWboolean	  stop_end,
  double          *p_pt
));

extern void pwGetEndPtsCvdata _PW_((
  struct PWcvdata *p_cvdata,
  double          *p_startpt,
  double          *p_endpt
));

extern void pwGetEndCvparCvdata _PW_((
  struct PWcvdata *p_cvdata,
  PWboolean reversed,
  PWboolean stop_end,
  struct PWcvparam *p_cvpar
));

extern void pwGetEndCvptCvdata _PW_((
  struct PWcvdata *p_cvdata,
  PWboolean       reversed,
  PWboolean       stop_end,
  struct PWcvpt   *p_cvpt
));







extern PWresult   pwPushCoincEdges _PW_((
  struct EMSinters **pp_inters,
  struct EMSintobj *p_intcv,
  double           xyztol
));







extern void pwCnvtPyToCv _PW_((
  struct PWpoly       *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
));

extern void pwCnvtPy2dToCv _PW_((
  struct PWpoly2d     *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
));







extern enum PWcvdatatype pwCvtypeFromString  _PW_((
  char *str
));

extern enum PWsfdatatype pwSftypeFromString _PW_((
  char *str
));

extern PWboolean pwReadCvdata  _PW_((
  FILE *file,
  struct PWcvdata *cvdata
));

extern PWboolean pwReadPy2d _PW_((
  FILE *file,
  struct PWpoly2d *py
));

extern PWboolean pwReadPy  _PW_((
  FILE *file,
  struct PWpoly *py
));

extern PWboolean pwReadBspCv  _PW_((
  FILE *file,
  struct IGRbsp_curve *bspcv
));

extern PWboolean pwReadSfdata  _PW_((
  FILE *file,
  struct PWsfdata *sfdata
));

extern PWboolean pwReadBspSf _PW_((
  FILE *file,
  struct IGRbsp_surface *bspsf
));







extern PWboolean pwReadPt2d  _PW_((
  FILE *file,
  PWpoint2d pt
));

extern PWboolean pwReadPt  _PW_((
  FILE *file,
  PWpoint pt
));

extern PWboolean pwReadId _PW_(( 
  FILE *file,
  PWobjid *objid,
  PWosnum *os,
  char classname[PW_K_MaxStringLen]
));

extern PWboolean pwReadIdFromString _PW_((
  char *line,
  PWobjid *objid,
  PWosnum *os,
  char classname[PW_K_MaxStringLen]
));







extern enum PWcvdatatype pwCvtypeFromString  _PW_((
  char *str
));

extern enum PWsfdatatype pwSftypeFromString _PW_((
  char *str
));

extern PWboolean pwReadCvdata  _PW_((
  FILE *file,
  struct PWcvdata *cvdata
));

extern PWboolean pwReadPt2d  _PW_((
  FILE *file,
  PWpoint2d pt
));

extern PWboolean pwReadPt  _PW_((
  FILE *file,
  PWpoint pt
));

extern PWboolean pwReadPy2d _PW_((
  FILE *file,
  struct PWpoly2d *py
));

extern PWboolean pwReadPy  _PW_((
  FILE *file,
  struct PWpoly *py
));

extern PWboolean pwReadBspCv  _PW_((
  FILE *file,
  struct IGRbsp_curve *bspcv
));

extern PWboolean pwReadId _PW_(( 
  FILE *file,
  struct PWid *id,
  char classname[PW_K_MaxStringLen]
));

extern PWboolean pwReadSfdata  _PW_((
  FILE *file,
  struct PWsfdata *sfdata
));

extern PWboolean pwReadBspSf _PW_((
  FILE *file,
  struct IGRbsp_surface *bspsf
));







extern int pwGetNumRefFiles _PW_((
  PWosnum osnum
));


extern PWresult pwGetRefFiles _PW_((
  PWosnum osnum,
  int *NumRefFiles,
  char **RefFileNames 
));





extern PWresult pwRefineUvPtsOnDegenBdrysOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  int num_uvpts,
  PWpoint2d *p_uvpts,
  double xyztol
));

extern PWresult pwInsertUvPtsAtSeamsOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  int *num_pts,
  PWpoint2d *p_pts
));

extern PWresult pwSplitUvPtsAtSeamsOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  int num_pts,
  PWpoint2d *p_pts,
  int *num_grps,
  int *num_pts_grp
));

extern PWresult pwSplitAndRefineUvPtsOnSeamsOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  int num_pts,
  PWpoint2d *p_pts,

  double uvtol,

  int *num_grps,
  int **num_outpts,
  PWpoint2d **p_outpts
));







extern PWresult pwGetDatpldata _PW_((
  PWobjid datplane,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  PWvector xvec,
  PWvector yvec,
  PWvector zvec,
  PWpoint  origpt
));








extern PWresult  pwInitializeRelsTable _PW_((
   struct PWrelstable *p_intable
));

extern void  pwUninitializeRelsTable _PW_((
));

extern void   pwGetBooleanRelsTable _PW_((
   int                  optyp, 
   struct PWrelstable   *p_table 
));

extern void    pwValidateIntRels _PW_((
   struct EMSintobj     *p_intcv 
));








extern FILE *pwRequestInFile _PW_((
));

extern FILE *pwRequestOutFile _PW_((
));







extern void pwRevCvdata _PW_((
  struct PWcvdata *p_cvdata
));

extern void pwRevPy2d _PW_((
  int num_pts,
  PWpoint2d *p_pts
));

extern void pwRevPy _PW_((
  int num_pts,
  PWpoint *p_pts
));







extern void pwRevVec2d _PW_((
  PWvector2d vec,
  PWvector2d outvec
));

extern void pwRevVec _PW_((
  PWvector vec,
  PWvector outvec
));







extern void pwGetRange2d  _PW_((
  int num_points,
  PWpoint2d *pts,
  PWrange2d range
));

extern void pwGetRange  _PW_((
  int num_points,
  PWpoint *pts,
  PWrange range
));

extern void pwExpandRange2d  _PW_((
  PWrange2d rng,
  double k
));

extern void pwExpandRange  _PW_((
  PWrange rng,
  double k
));

extern PWboolean pwIsOverlapRngRng2d  _PW_((
  PWrange2d rng1,
  PWrange2d rng2
));

extern PWboolean pwIsOverlapRngRng  _PW_((
  PWrange rng1,
  PWrange rng2
));

extern PWboolean pwIsOutsideSegRng2d  _PW_((
  PWpoint2d seg[2],
  PWrange2d rng
));

extern PWboolean pwIsOutsideSegRng _PW_((
  PWpoint seg[2],
  PWrange rng
));

extern void pwGetCvRange _PW_((
  struct IGRbsp_curve *p_cv,
  PWrange             range
));

extern void pwGetRangeCvdata _PW_((
  struct PWcvdata *p_cvdata,
  double *range
));

extern void pwGetMaxParCvdata _PW_((
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar
));

extern void pwGetMinParCvdata _PW_((
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar
));

extern void pwGetRngPts _PW_((
  PWrange  rngbx,
  PWpoint  rngpts[8]
));

extern PWresult  pwMinMaxPtsAlongVec  _PW_((
  int       numpts, 
  PWpoint   *ppoints, 
  PWvector  dirvec,
  PWpoint   maxpt, 
  PWpoint   minpt
));




/*

 OVERVIEW
 Structures and API prototypes for the placement and query on round edge
 feature.

 NOTES

 HISTORY
 Aditya  03/19/96  Creation

*/





extern PWresult pwRoundEdges _PW_((
  PWobjid surface_entity,
  PWosnum os,
  int num_edge_sets,
  struct PWrndedgeset *edge_sets,
  PWboolean is_chamfer,
  PWobjid *rounded_solid));





extern PWresult pwAddObjToRtree _PW_((
  PWobjid objid,
  PWosnum os,
  PWrange range
));







extern PWboolean pwIsSamePt2d  _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2,
  double tol
));

extern PWboolean pwIsSamePt  _PW_((
  PWpoint pt1,
  PWpoint pt2,
  double tol
));







extern PWboolean pwIsCompSf _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern void pwGetNatSfUvRng _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWrange2d uvrng
));

extern void pwGetSfUvRng _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWrange2d uvrng
));

extern PWresult pwGetSubbsRtreeRange _PW_((
  PWobjid               sfid,
  PWosnum               sfos,
  short                 mat_typ,
  PWmatrix              mat,
  double                *sfrange
));

extern PWresult pwGetSubbsRtreeRangeFromGRrtree _PW_((
  PWobjid               sfid,
  PWosnum               sfos,
  PWobjid               rtreeObjid,
  short                 mat_typ,
  PWmatrix              mat,
  double             *sfrange
));

extern PWresult pwIsSurfaceActive _PW_((
  PWobjid sfobj, 
  PWosnum os,
  short *isActive
));

extern PWresult pwIsSurfaceDisplayable _PW_((
  PWobjid sfobj,
  PWosnum os, 
  short   *isDisplayable
));





















extern PWresult pwGetDegenNatBdrysOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  double lentol,

  PWboolean *degen_u0,
  PWboolean *degen_u1,
  PWboolean *degen_v0,
  PWboolean *degen_v1
));

extern PWresult pwGetSfEds _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWboolean is_dominant,
  PWboolean is_not_degenerate,
  PWboolean is_not_tangent,
  int *num_edges,
  PWobjid **edges
));

extern PWresult pwGetSfEdCvs _PW_((
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  PWboolean is_dominant,
  PWboolean is_not_degenerate,
  PWboolean is_not_tangent,
  int *num_cvs,
  struct IGRbsp_curve ***cvs
));







extern PWresult pwSfBooleanUnion _PW_((
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *union_sf
));

extern PWresult pwSfBooleanDifference _PW_((
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *difference_sf
));

extern PWresult pwSfBooleanIntersection _PW_((
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *intersection_sf
));

extern PWresult pwSfCutWithPlane _PW_((
  PWobjid sf,
  struct PWplane *plane,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *cut_sf
));







extern int pwGetSliverSfs _PW_((
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  double xyztol,
  int num_samplepts,
  PWobjid **sliver_sfs
));







extern int pwNumSfsOfCompSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwGetSfsOfCompSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_sfs
));





extern PWobjid pwCreateSfObj _PW_(( 
 struct IGRbsp_surface *pSurfGeom,
 int sftype,
 PWosnum osnum
));

extern PWresult pwCreatePlaneBsp _PW_((
  PWpoint basept1,
  PWpoint basept2,
  PWpoint heightpt,
  struct IGRbsp_surface *p_plane
));

extern PWresult pwCreateCylinderBsp _PW_((
  PWpoint base_center,
  PWpoint top_center,
  double  radius,
  struct IGRbsp_surface *p_cylinder
));

extern PWresult pwCreateConeBsp _PW_((
  PWpoint base_center,
  PWpoint top_center,
  double  base_radius,
  double  top_radius,
  struct IGRbsp_surface *p_cone
));

extern PWresult pwCreateElpCylinderBsp _PW_((
  PWpoint  base_center,
  PWpoint  top_center,
  PWpoint  major_axispt,
  PWpoint  minor_axispt, 
  struct IGRbsp_surface *p_elpcylinder
));

extern PWresult pwCreateElpConeBsp _PW_((
  PWpoint  base_center,
  PWpoint  top_center,
  PWpoint  major_axispt,
  PWpoint  minor_axispt,
  double   scale,
  struct IGRbsp_surface *p_elpcone
));

extern PWresult pwCreateSphereBsp _PW_((
  PWpoint center,
  double  radius,
  struct IGRbsp_surface *p_sphere
));

extern PWresult pwCreateTorusBsp _PW_((
  PWpoint base_center, 
  double  base_radius,
  PWpoint tor_axispt1,
  PWpoint tor_axispt2,
  struct IGRbsp_surface *p_torus
));

extern PWresult pwCreateProjSfBsp _PW_((
  struct IGRbsp_curve *p_cv,
  PWpoint axispt1,
  PWpoint axispt2,
  struct IGRbsp_surface *p_sfproj
));

extern PWresult pwCreateRevSfBsp _PW_((
  struct IGRbsp_curve *p_cv,
  PWpoint axispt1,
  PWpoint axispt2,
  PWboolean full,
  double stang,
  double swang,
  struct IGRbsp_surface *p_sfrev
));

extern PWresult pwCreateTorusBsp1 _PW_((
  PWpoint tor_center,
  PWvector tor_axis,
  double tor_radius,
  double base_radius,

  struct IGRbsp_surface *p_torus
));







extern PWresult  pwCreateSfCvRegion _PW_((
  struct PWgeomid        *p_sfgmid,    
  struct PWcvdata        *p_cvdata,
  double                 xyztol,
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvregion_list **p_cvregs
));





extern PWresult pwSfdataIntersect _PW_ ((
  struct PWsfdata *sf1,
  struct PWsfdata *sf2,
  PWboolean discard_point_intersections,
  PWboolean discard_uvcvs,
  int *num_inters,
  struct PWcvdata **xyzcvs1,
  struct PWcvdata **uvcvs1,
  struct PWcvdata **xyzcvs2,
  struct PWcvdata **uvcvs2
));

extern void pwSfdataIntersectFree _PW_ ((
  int num_inters,
  struct PWcvdata *xyzcvs1,
  struct PWcvdata *uvcvs1,
  struct PWcvdata *xyzcvs2,
  struct PWcvdata *uvcvs2
));





extern PWresult pwTraverseCSfCSfs _PW_((
  PWobjid csfobj,
  PWosnum os,
  PWboolean depth_first,
  PWresult (*func)(),
  void *func_args
));

extern PWresult pwTraverseSfSfs _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
));

extern PWresult pwTraverseSfLps _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
));

extern PWresult pwTraverseSfEds _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
));







extern PWresult pwGetSfAttrData _PW_((
  PWobjid                 sfobj, 
  PWosnum                 os,
  struct PWsfattrdata     *p_sfattrdata
));

extern PWresult pwGetSfRuleLineTable _PW_((
  PWobjid sfobj,
  PWosnum os,
  int *num_u_rules,
  int *num_v_rules,
  double **u_rule_pars,
  double **v_rule_pars,
  int **num_u_rule_bdrys,
  int **num_v_rule_bdrys,
  double (***u_rule_bdrys)[2],
  double (***v_rule_bdrys)[2]
));

extern void pwFreeSfRuleLineTable _PW_((
  int num_u_rules,
  int num_v_rules,
  double *u_rule_pars,
  double *v_rule_pars,
  int *num_u_rule_bdrys,
  int *num_v_rule_bdrys,
  double (**u_rule_bdrys)[2],
  double (**v_rule_bdrys)[2]
));

extern PWresult pwGetSfRuleLineCvs _PW_((
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  int *num_rule_cvs,
  struct IGRbsp_curve ***rule_cvs
));







extern PWresult pwGetSfPts _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts
));

extern PWresult pwGetSfArrayPts _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts
));

extern PWresult pwGetSfTangents _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts,
  PWvector *unit_utans,
  double *u_derivative,
  PWvector *unit_vtans,
  double *v_derivative
));

extern PWresult pwGetSfArrayTangents _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts,
  PWvector *unit_utans,
  PWvector *unit_vtans
));

extern PWresult pwGetSfNormals _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix mat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts,
  PWvector *unit_norms
));

extern PWresult pwGetSfArrayNormals _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts,
  PWvector *unit_norms
));

extern PWresult pwGetSfPtsInBdry _PW_((
  PWobjid sfobj,
  PWosnum os,
  int num_pts,
  PWpoint2d *uv_pts,

  PWboolean *is_inbdry
));

extern PWresult pwGetSfArrayPtsInBdry _PW_((
  PWobjid sfobj,
  PWosnum os,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWboolean *is_inbdry
));







extern PWresult pwCreateSfDispObj _PW_((
  PWobjid sfobj,
  PWosnum os
));








extern PWresult pwGetSfAsBspline _PW_((
  PWobjid sfobj, 
  PWosnum os,
  short mattyp,
  PWmatrix matrix,
  struct IGRbsp_surface *p_sfgeom
));

extern int pwGetSfSize _PW_((
  PWobjid sfobj,
  PWosnum os
));

extern PWresult pwSfAsGeomBspline _PW_((
  PWobjid sfobj,
  PWosnum os,
  struct IGRbsp_surface *bspsf,
  struct BSgeom_bsp_surf *gmbspsf
));

/*
 * Macros that are used to perform the very common functions dealing with
 * surface geometry. The "Stack" macro should be used whenever surface
 * geometry is being requested for within-the-function computations. 
 * NOTES: These macros should be used with the same syntax as PW-API 
 * functions that return a PWresult. This result must then be tested to 
 * make sure the op was successful. A single-pointer is the argument to hold 
 * the surface geometry as opposed to the more conventional double-pointer 
 * used when invoking a function of similar behaviour.
 */

  ( \
    pwGetSfAsBspline (sfobj, os, mattyp, p_matrix, \
     p_bspsf = (struct IGRbsp_surface *) \
                alloca (pwGetSfSize (sfobj, os))) \
  ) 

  ( \
    pwGetSfAsBspline (sfobj, os, mattyp, p_matrix, \
     p_bspsf = (struct IGRbsp_surface *) \
                malloc (pwGetSfSize (sfobj, os))) \
  ) 

  ( \
    pwGetSfAsGeomBspline (sfobj, os, mattyp, p_matrix, \
     (struct IGRbsp_surface *) \
      alloca (pwGetSfSize (sfobj, os)), \
     p_gmbspsf = (struct BSgeom_bsp_surf *) \
      alloca (sizeof (struct BSgeom_bsp_surf))) \
  ) 

  ( \
    pwGetSfAsGeomBspline (sfobj, os, mattyp, p_matrix, \
     (struct IGRbsp_surface *) \
      malloc (pwGetSfSize (sfobj, os)), \
     p_gmbspsf = (struct BSgeom_bsp_surf *) \
      malloc (sizeof (struct BSgeom_bsp_surf))) \
  ) 





extern PWresult pwGetMinDistAdjPoles _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,

  double *mindist,
  int minpoleinx[2],
  PWboolean *in_u_dir
));







extern PWresult pwIntersectWithSurface _PW_((
  struct PWgeomid         *p_sfgmid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  double                  xyztol,
  struct PWcvintpt_list   **p_cvintpts
));







extern int pwNumOuterFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwOuterFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_faceloops
));

extern int pwNumInnersOfLp _PW_((
  PWobjid  loopobj, 
  PWosnum  os
));

extern int pwInnersOfLp _PW_((
  PWobjid  loopobj, 
  PWosnum  os,
  PWobjid  *p_lps
));

extern PWobjid  pwOutterOfLp _PW_((
  PWobjid  loopobj,
  PWosnum  os
));

extern int pwNumLpsOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwLpsOfSf _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_loops
));

extern int pwNumFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwFacesOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_faceloops
));

extern PWobjid pwFaceAtInxOfSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  unsigned int index
));

extern PWobjid pwOuterFaceAtInxOfSf _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  int      index
));

extern PWobjid pwLpAtInxOfSf _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  int      index
));

extern int pwNumHolesOfFace  _PW_((
  PWobjid  faceloop, 
  PWosnum  os
));

extern int pwHolesOfFace  _PW_((
  PWobjid  faceloop, 
  PWosnum  os,
  PWobjid  *p_holeloops
));

extern int pwNumInnerFacesOfHole  _PW_((
  PWobjid  holeloop, 
  PWosnum  os
));

extern int pwInnerFacesOfHole  _PW_((
  PWobjid  holeloop, 
  PWosnum  os,
  PWobjid  *p_faceloops
));

extern PWobjid pwHoleAtInxOfFace _PW_((
  PWobjid  faceloop,
  PWosnum  os, 
  int      index
));

extern PWobjid pwInnerFaceAtInxOfHole _PW_((
  PWobjid  holeloop,
  PWosnum  os, 
  int      index
));

extern PWobjid pwSfOfLp _PW_((
  PWobjid  loopobj,
  PWosnum  os
));





extern PWresult pwGetSolidsOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_solids,
  PWobjid **solids
));

extern PWresult pwGetCompSfsOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_compsfs,
  PWobjid **compsfs
));

extern PWresult pwGetSingleSfsOfOS _PW_((
  PWosnum  os,
  PWboolean sfs_in_rtree,
  int *num_surfs,
  PWobjid **surfs
));







extern PWboolean pwIsSfOpen  _PW_((
  PWobjid sfobj,
  PWosnum os
));

extern PWboolean pwIsSfNormalReversed _PW_((
  PWobjid sfobj,
  PWosnum os
));

extern PWboolean pwIsRectPlane  _PW_((
  PWobjid sfobj, 
  PWosnum sfos
));

extern PWboolean pwIsSfNatural _PW_((
  PWobjid sfobj,
  PWosnum os
));







extern PWresult   pwSfPtLocate _PW_((
           struct PWgeomid   *p_sfgeomid,
           PWpoint           xyzpt,
           PWpoint2d         uvpt,
           double            xyztol,
           enum PWptloctype  *p_ptloc,
           PWobjid           *p_bdryid,
           struct PWcvpt     *p_edpt
));

extern PWresult SfGeomPtLocate _PW_((
  struct IGRbsp_surface *sf,
  PWosnum os,
  PWpoint xyzpt,
  PWpoint2d uvpt,
  double xyztol,
  int numoutfcs,
  PWobjid *p_outfcs,
  int numloops,
  enum PWptloctype *p_ptloc,
  PWobjid *p_bdryid,
  struct PWcvpt *p_edpt
));







extern void pwGetNatSfUvRng _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWrange2d uvrng
));





extern PWresult pwTrimAgainstSurface _PW_((
  struct PWgeomid        *p_sfgmid,
  struct PWcvdata        *p_uvcv,
  struct PWcvdata        *p_xyzcv,
  PWrange2d              uvcvrng,
  double                 xyztol,
  struct PWcvregion_list **p_cvregs
));







extern PWboolean pwIsSurface _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern PWboolean pwIsCompSf _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern PWboolean pwIsSolid _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern PWboolean pwIsSimpleSf _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern short pwSfType  _PW_((
  PWobjid sfobj,
  PWosnum sfos
));







extern PWobjid pwGetSfOfEd _PW_((
  PWobjid edobj,
  PWosnum os
));

extern PWobjid pwGetLpOfEd _PW_((
  PWobjid edobj,
  PWosnum os
));

extern PWobjid pwGetSfOfLp _PW_((
  PWobjid lpobj,
  PWosnum os
));





extern void pwGetSfUvRng 
(
  PWobjid sf,
  PWosnum os,
  PWrange2d uvrng
);





extern PWresult pwCreatSolidOfProj _PW_((
   PWobjid      profile_id,
   PWosnum 	profile_os,
   PWboolean 	project_normal,
   PWvector  	dirvec,
   struct PWvalueinfo  distance,
   PWboolean 	is_symmetric,
   PWobjid     	*solid 
));

extern PWresult pwCreateSolidOfProjBtnPlanes _PW_((
   PWobjid profile_id,
   PWosnum profile_os,
   PWboolean proj_normal,
   PWvector dir_vector, //if proj_normal==TRUE, approx dir_vec accepted,
                        // else dir_vec is absolute.
   PWobjid start_plane,  // if NULL, use prof plane.
   PWobjid end_plane,
   PWobjid *mod_solid
));

extern int pwNumSideSf _PW_((
  PWobjid solid,
  PWosnum os
));

extern  PWobjid pwCapsf _PW_((
  PWobjid solid,
  PWosnum os,
  PWboolean is_start_cap
));

extern PWobjid pwSideSf _PW_((
  PWobjid solid,
  PWosnum os,
  int side_index  
));







extern PWresult pwCreateSolidOfRev _PW_((
   PWobjid profile_id,
   PWosnum profile_os,
   PWpoint axis_point,
   PWvector axis_vector,
   struct PWvalueinfo *start_angle, /* if NULL start at prof plane */
   struct PWvalueinfo *sweep_angle, /* if NULL, revolve 360.       */
   PWobjid *rev_solid
));







extern PWresult pwCreatSolidBySkinning _PW_((
 int num_trace_curves,
 PWobjid *trace_curves,
 PWboolean *trace_curve_orientation,
 PWosnum os,
 int num_cross_sections,
 PWobjid *cross_sections,
 PWboolean *cross_sections_orientation,
 PWboolean is_obsolute_orientation,
 PWobjid *skinned_solid
));







extern PWresult pwSortCvintptList _PW_((
  struct PWcvintpt_list  **p_cvintpts,    /*  I/O  */
  double                 tol               /*   I   */
));





extern PWresult pwSortVec2d  _PW_((
  int numvecs,
  PWvector2d *vecs,
  int *sort_indices
));

extern PWresult pwSortVec  _PW_((
  int numvecs,
  PWvector *vecs,
  PWvector dirvec,
  int *sort_indices
));







extern PWresult pwGetSpanCvdata _PW_((
  struct PWcvdata *p_cvdata,
  int             spaninx,
  struct PWcvdata *p_span
));

extern PWboolean pwGetNonDegenSpanPy _PW_((
  struct PWpoly *p_py,
  int           spaninx,
  double        lentol,
  PWpoint       outpts[2]
));

extern PWboolean pwGetNonDegenSpanPy2d _PW_((
  struct PWpoly2d *p_py,
  int             spaninx,
  double          lentol,
  PWpoint2d       outpts[2]
));






extern PWboolean pwFuzzyMatch _PW_((
  char *str,
  char *match
));

extern int pwNumFields _PW_((
  char *str
));

extern int pwGetInxOfField _PW_((
  int n,
  char *str
));

extern PWboolean pwFieldInStr _PW_((
  int n,
  char *str,
  char *field
));





extern PWresult pwStrokeUvdataIfNeeded _PW_((
  struct IGRbsp_surface *p_sf,
  int num_pts,
  PWpoint2d *p_uvpts,
  PWpoint *p_xyzpts,

  double xyztol,

  int *num_outpts,
  PWpoint2d **p_outuvpts,
  PWpoint **p_outxyzpts
));







extern PWresult pwPutSymb _PW_((
  PWobjid objid, 
  PWosnum osnum,  
  struct GRsymbology *Symb
));







extern PWresult pwThinWall _PW_((
 PWobjid surface_entity,
 PWosnum os,
 struct PWvalueinfo *common_thickness,
 PWboolean is_offset_symmetric,
 PWboolean offset_inside,
 int       num_open_sfs,
 PWobjid   *opensfs,
 int       num_spel_sfs_groups,
 struct PWspecialsfs *special_sfs,
 PWobjid *mod_solid
));

extern PWresult pwQueryThinWall _PW_((
  PWobjid feature_id,
  PWosnum os,
  struct PWvalueinfo *common_thickness,
  PWboolean *is_offset_symmetric,
  PWboolean *is_offset_inside,
  int *num_open_sfs,
  PWobjid **opensfs,
  int *num_spel_sfs_groups,
  struct PWspecialsfs **special_sfs,
  PWobjid *base_sf_entity
));







extern PWresult pwUndoFeatureTree _PW_((
  PWobjid feature_id,
  PWosnum os,
  int levels_to_undo,
  int *num_top_owners,
  PWobjid **top_owners
));

extern PWresult pwUndoFeatTreeUntilObjid _PW_((
  PWobjid feature_id,
  PWosnum os,
  PWobjid target_id,
  int *num_top_owners,
  PWobjid **top_owners
));







extern PWboolean pwIsMetric _PW_((
  PWosnum osnum
));

extern PWresult uomGetUnits _PW_(( 
  PWosnum osnum,
  char units[]
));







extern PWresult pwGetUvCvdataProps _PW_(( 
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_sfgeom,
  double xyztol,
  double uvtol,
  int    *props
));






extern PWresult pwGetSfFaceLoopsUv _PW_((
  PWobjid sfobj,
  PWosnum os,

  double xyztol,

  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops
));







extern PWresult pwGetSfFaceLoopsXyz _PW_((
  PWobjid sfobj,
  PWosnum os,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops_xyz
));

extern PWresult pwGetUvCvsOfSfFaceLoopsXyz _PW_((
  PWobjid sfobj,
  PWosnum os,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops_uv
));







extern double pwActiveXYZLenTol _PW_((
));

extern double pwActiveXYZChtTol _PW_((
));

extern void pwSetActiveXYZLenTol _PW_((
  double newtol
));

extern void pwSetActiveXYZChtTol _PW_((
  double newtol
));

extern PWresult pwGetPersistXYZTols _PW_((
  PWosnum os,
  double *lentol,
  double *chttol
));




#endif
