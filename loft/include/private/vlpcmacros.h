/*
		I/LOFT profile card macros.
*/

#ifndef vlpcmacros_include
#define	vlpcmacros_include

/* ------------------------------------------------------------	
Macro vl$pldrwborder()

Abstract  
  Place automaticaly an ACheader of the given
  macro name.
Arguments 
	struct	GRobj_env *csId,	I  : Placement Cs
	char		  *borderName,	I  : Drawing border name
	struct	GRmd_env  *curMdEnv,	I  : Placement environment
	struct	GRid	  *drwBr	O  : Drawing border Id
*/

#omdef vl$pldrwborder( 	csId,
			name,
			env,
			border = NULL )

	VLplDrwBorder(	csId,
			name,
			env,
			border )
#endomdef

/* ------------------------------------------------------------	
Macro vl$plpcview()

Abstract  
  Place a VLpcView occurrence.

Arguments 
	struct	GRobj_env *Supp,	I  : Support element for query 
	struct	GRobj_env *Cs,		I  : Cs of placement		  
	struct	GRid	  *ViewId,	IO : Id of the View orientation
						( side, bottom, ... )	   
	char		  *ViewType,	I  : if ViewId == NULL or
						ViewId->objid == NULL_OBJID
						we use ViewType to create
						ViewId.			 
	int		  consume,	I  : Consume constructed cs
	char		  asState,	I  : Assoc properties      
	struct	GRmd_env  *curMdEnv,	I  : Placement environment
	struct	GRid	  *PcViewId )	O  : Profile card view Id
*/

#omdef vl$plpcview( 	supportId,
			csId,
			viewId		= NULL,
			viewType,
			rngPtId,
			consume		= 0,
			asState		= 0,
			env,
			pcViewId	= NULL )

	VLplPcView(	supportId,
			csId,
			viewId,
			viewType,
			rngPtId,
			consume,
			asState,
			env,
			pcViewId )
#endomdef

/* ------------------------------------------------------------	
Macro vl$plcsfit()

Abstract  
  Place a VLcsFitElem occurrence.

Arguments 
	struct	GRobj_env	*drwBdr,	I  : Drawing Border Id     
	char			*pathCs,	I  : Path to get Cs Id     
	char			*pathRgPt,	I  : Path to get Pt Id     
	struct	GRobj_env	*elem,		I  : Element to fit 
	int			consume,	I  : Consume constructed cs
	char			asState,	I  : Assoc properties      
	struct	GRmd_env	*curMdEnv,	I  : Placement environment 
	struct	GRid		*fitCs )	O  : Fit Cs Id             
*/

#omdef vl$plcsfit( 	drwBdr,
			pathCs,
			pathRgPt,
			elem,
			consume		= 0,
			asState		= 0,
			env,
			fitCsId		= NULL )

	VLplCsFit(	drwBdr,
			pathCs,
			pathRgPt,
			elem,
			consume,
			asState,
			env,
			fitCsId )
#endomdef

/* ------------------------------------------------------------	
Macro vl$plimage()

Abstract  
  Place a Image occurrence.

Arguments 
	struct	GRobj_env	*model,	    I  : Image model	
	struct	GRobj_env	*cs,	    I  : Image position	
	int			xftype,	    I  : Xform type	
	int			consume,    I  : Consume model
	char			asState,    I  : Assoc properties      
	struct	GRmd_env	*curMdEnv,  I  : Placement environment 
	struct	GRid		*image )    O  : Image  Id             
*/

#omdef vl$plimage( 	model,
			cs,
			xftype		= 0,
			consume		= 0,
			asState		= 0,
			env,
			image		= NULL )

	VLplImage(	model,
			cs,
			xftype,
			consume,
			asState,
			env,
			image )
#endomdef

/* ------------------------------------------------------------	
Macro vl$plmacro()

Abstract  
  Place a macro occurrence.

Arguments 
	char			*macName,	I  : Macro name            
	char			*name,		I  : occurrence name	      
	int			tplNb,		I  : number of template    
	struct	GRobj_env	*tplList, 	I  : list of template      
	struct	GRsymbology	*symb,		I  : symbology 	      
	struct	GRid		*occId,		I  : exemple occurence     
	GRclassid		classid,	I  : classid of macro      
	short			props,		I  : placement props	      
	short			rep,		I  : macro representation  
	char			asState,	I  : Assoc properties    
	struct	GRmd_env	*curMdEnv, 	I  : Placement environment 
	struct	GRid		*macId )	O  : Macro Id 	     
*/

#omdef vl$plmacro( 	macName,
			name		= NULL,
			tplNb,
			tplList,
			symb		= NULL,
			occId		= NULL,
			classid		= OPP_ACconst_class_id,
			props		= 0,
			rep		= 0,
			asState		= 0,
			env,
			macId		= NULL )

	VLplMacro( 	macName,
			name,
			tplNb,
			tplList,
			symb,
			occId,
			classid,
			props,
			rep,
			asState,
			env,
			macId )

#endomdef

/* ------------------------------------------------------------	
Macro vl$plpctext()

Abstract  
  Place a VLpcText occurrence.

Arguments 
	struct	GRobj_env	*drwBdr,    I  : Drawing border	   
	struct	GRobj_env	*support,   I  : Support Id for strudel 
	struct	GRmd_env	*curMdEnv,  I  : Placement environment  
	struct	GRid		*pcText )   O  : Profile card Text Id   
*/

#omdef vl$plpctext( 	support,
			drwBdr,
			env,
			pcText		= NULL )

	VLplPcText(	support,
			drwBdr,
			env,
			pcText )
#endomdef

/* ------------------------------------------------------------	
Macro vl$plcs()

Abstract  
  Place a CS occurrence.

Arguments 
	double		  *mat,		I  :	Cs matrix
	struct	GRmd_env  *curMdEnv,	I  : Placement environment
	struct	GRid	  *csId )	O  : Drawing border Id
*/

#omdef vl$plcs( 	mat,
			env		= NULL,
			csId		= NULL )

		VLplCs(	mat,
			env,
			csId )
#endomdef

/* ************************************************************************** */
#endif
