#ifndef _refbdrypts_proto_h 
#define _refbdrypts_proto_h

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



#if defined(__cplusplus) 
} 
#endif 

#endif 
