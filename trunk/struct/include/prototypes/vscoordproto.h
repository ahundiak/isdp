/* $Id: vscoordproto.h,v 1.2 2001/07/13 16:35:20 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	struct/include/prototypes/vscoordproto.h
 *
 * Description:
 *		CS by 2 elements command
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vscoordproto.h,v $
 *	Revision 1.2  2001/07/13 16:35:20  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  2000/02/23  22:20:20  pinnacle
 * tr179901005
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/11/19  16:39:26  pinnacle
 * TR179702163
 *
 * Revision 1.2  1997/06/16  15:12:16  pinnacle
 * TR179701071
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      06/16/97        ah              Header Creation
 *      06/16/97        ah              TR179701071
 *	11/19/97	ah		TR179702163 Cleaned up protos
 *      02/23/00        ah              TR179901005 Changed VScsExtendSurface
 * -------------------------------------------------------------------*/

#ifndef vscoordproto_include
#define	vscoordproto_include

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VScsby2elF.I */

long	VSfind_longer_u_v_iso
			__((	struct	GRobj_env	*surface,
				struct	GRvg_construct	*cst,
					int		*u_is_longer));
IGRlong	VStest_angle	__((		IGRlong		*msg,
				struct	GRobj_env	*Axis,
				struct	GRobj_env	*Surf,
				struct	IGRbsp_surface	**srf,
					IGRdouble	*angle	));
long	VSfind_botu0_web
			__((	struct	GRobj_env	*beam,
				struct	GRobj_env	*bot_srf,
					int		*web	));
long	VSfind_webL_webR_vec
			__((	struct	GRobj_env	*surface,
				struct	GRparms		*par,
					double		web,
					int		u_is_longer,
					int		*options,
				struct	GRvg_construct	*cst,
					double		*vec	));
IGRlong	VSgetBeamCenter	__((	struct	GRobj_env	*beam,
					double		*center	));
IGRlong	VSfind_surf_to_intersect
			__((	struct	GRobj_env	*plate_or_beam,
					double		*beam_center,
					int		*options,
				struct	GRobj_env	*axis,
					int		*idxSurf,
				struct	GRobj_env	*srf_to_int,
				struct	IGRbsp_surface	**bspexsrf	));

IGRlong VSfind_origin_pnt __((
  TGRobj_env        *Beam,
  TGRobj_env        *BeamSrf,
  TGRobj_env        *IntSrf,
  IGRchar           *webName,
  TGRvg_construct   *Cst,
  IGRpoint           pnt,
  IGRdouble         *u,
  IGRdouble         *v
));

IGRlong	VSfind_origin	__((	struct	GRobj_env	*Beam,
				struct	GRobj_env	*PlBm,
				struct	GRobj_env	*botS,
				struct	GRobj_env	*topS,
				struct	GRobj_env	*Surf,
				struct	GRvg_construct	*Cst,
					IGRint		Option,
					IGRint		Ulonger,
					IGRdouble	*Origin,
				struct	GRparms		*Bparms,
				struct	GRparms		*Sparms	));
long	VSfind_xaxis	__((	struct	GRobj_env	*bot_or_sup_surf,
				struct	IGRbsp_surface	*surface,
				struct	GRvg_construct	*cst,
					int		*options,
					int		web,
					int		u_is_longer,
				struct	GRparms		*beam_parms,
				struct	GRparms		*srf_parms,
					double		*xaxis	));
long	VSfind_yaxis	__((	struct	GRobj_env	*bot_or_sup_surf,
				struct	IGRbsp_surface	*surface,
					double		*xaxis,
					double		*beam_center,
				struct	GRvg_construct	*cst,
					int		*options,
					int		web,
					int		u_is_longer,
				struct	GRparms		*beam_parms,
				struct	GRparms		*srf_parms,
					double		*yaxis	));

/* VSget3dbeam.I */
long  VSgetDetailedRepBeam __((
  IGRlong   *msg,
  TGRmd_env *bmEnv,
  TGRid     *fromBeam,
  TGRid     *myBeam
));

/* VSint.I */
IGRlong	VScsInt2Elements  __((
  IGRlong     *msg,
  TGRobj_env  *Obj1,
  TGRobj_env  *Obj2,
  TGRmd_env   *Env,
  TGRid	      *Inter
));

IGRlong	VScsExtendSurface __((
  TGRobj_env      *srfOE,
  IGRdouble        ER,      // TR179901005
  TGRid           *resultID
));

IGRlong	VScsIntCrvSrf __((		
  IGRlong         *msg,
  TGRobj_env      *Curv,
  TGRobj_env      *Surf,
  TGRmd_env       *Env,
  IGRpoint	   Pnt,
  IGRdouble	  *parT,
  IGRdouble	  *parU,
  IGRdouble	  *parV	
));

IGRlong VScsIntSrfSrf __((
  IGRlong     *msg,
  TGRobj_env  *Srf1,
  TGRobj_env  *Srf2,
  TGRmd_env   *Env,
  TGRid       *Crv	
));

#if defined(__cplusplus)
}
#endif

#endif
