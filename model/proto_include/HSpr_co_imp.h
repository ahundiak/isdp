#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*---HSRenderImgi.I--------------------------------------------------*/
/*
extern int convert_working_to_alias __(( IGRdouble, IGRchar *, IGRint ));
*/

/*---NCcretpi.I------------------------------------------------------*/
/*
extern void assign_bsp_curve __(( struct IGRbsp_curve *, IGRdouble *, IGRint *));
*/

/*---NCdistpi.I------------------------------------------------------*/

extern void nc_debug_surface __(( struct IGRbsp_surface *, IGRboolean ));
extern void nc_debug_curve   __(( struct IGRbsp_curve *, IGRboolean ));

#if defined(__cplusplus)
}
#endif


#undef __
