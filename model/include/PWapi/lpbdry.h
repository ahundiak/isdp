#ifndef _lpbdry_proto_h
#define _lpbdry_proto_h

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

extern PWresult pwGetLpBdry _PW_((PWobjid lp, PWosnum os, short *mattyp,
				  PWmatrix mat, struct IGRbsp_surface *srfgeom,
				  struct EMSpartolbasis *partolbas,
				  unsigned short options, int depth,
				  int *numbdrys,
				  struct IGRpolyline **xyzbdrys,
				  struct IGRpolyline **uvbdrys,
				  PWobjid **edids, unsigned short **edprops));

#if defined(__cplusplus)
}
#endif

#endif


