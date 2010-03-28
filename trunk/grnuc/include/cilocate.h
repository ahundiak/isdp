 /*
 * OM macros for command files in CI
 * for locate and module info
 * E BEEKER sept '87
 *
 * File dependency: ciminimum.h
 */

#ifndef cilocate_include
#define cilocate_include


/********************************* module_info ******************************/
/*
   Gets the module environment.
  
   ARGUMENTS:
   struct GRmd_env *md_env	(OUT)
 	Buffer to receive the module environment.
	( "struct GRmd_env" defined in grio.h )

   GRobj *md_id			(OUT)
 	Object id of current module.
   short *md_os
 	Object space number of current module.
  
   NB: arguments are redundant for comodity.
 */
#omdef ci$get_module_info( 
			md_env	= CI_NULL,
			md_id	= CI_NULL,
			md_os	= CI_NULL )

	CIget_module_info( (md_env), (md_id), (md_os) )

#endomdef


/********************************** ci$locate *********************************/
/*
 ARGUMENTS:
 GRobj	*obj			(OUT)
	Returns the located object(s), only necessary argument.

 short	*osnum			(OUT)
 	Returns the object space number of the located object(s).
 
 char	*prompt			(IN)
 	Locate prompt. if CI_NULL, no prompt is issued.

 int	msgnum			(IN)
 	Alternative to prompt, using the message subsystem (NOT IMPLEMENTED)

 char	*acc_prompt		(IN)
 	Accept prompt

 char	*relocate_prompt	(IN)
 	Relocate prompt

 char	*classes		(IN)
 	Class name - only objects of this class or of subclasses of this class
 	will be located. The hierarchy of graphic classes is given at the end
 	of this file.

 struct GRmd_env *md_env	(OUT)
 	Module environment of the located object(s).
 	"struct GRmd_env" is defined in grio.h
 
 double	*data_point		(OUT)
 	Co-ordinates of the point on the object nearest to the accept point.

 double	*accept_point		(OUT)
 	Co-ordinates of the point where the located object was accepted.
 
 int	stackable		(IN)
  	TRUE : locate process may be interrupted by another command.
  	FALSE: locate process may not be interrupted by another command.

 GRobj	*window_id		(OUT)
 	Object id of window where locate was performed.
 short	*window_osnum
 	Object space number of window where locate was performed.

 int	owner_action		(IN)
 int	properties		(IN)
 	Two fields of the GRlc_locate structure, see documentation on locate.

 double	*snap_point		(OUT)
 	Co-ordinates of the projection of the accept point onto the located
 	object.
 	
 struct GR_lc_info *lc_info	(OUT)
 	Locate information, see documentation on locate.

 int	*response		(OUT)
 	Type of the event received by the locate process ( event response types
 	are defined in exdef.h ).
 
 int	*count			(IN/OUT)
 	INPUT : maximum number of elements to be returned when processing a
 	        fence content. If CI_NULL, only the fence id is returned.
	OUTPUT: number of processed elements.

 OM_p_CLASSLIST *eligible_classes (IN)
 	List of class ids. The object of these classes will be eligible for
 	locate.

 NOTE: "classes" and "eligible_classes" are mutually exclusive
 */

#omdef ci$locate (obj,
		  osnum 	  = CI_NULL,
                  prompt  	  = CI_NULL 
/*                  	^ msgnum  = -1	*/,
                  acc_prompt      = "Accept/Reject",
                  relocate_prompt = "Object not found",
                  classes	  = "GRgraphics",
		  md_env	  = CI_NULL,
		  data_point      = CI_NULL,
		  accept_point    = CI_NULL,
		  stackable 	  = 1,
		  window_id	  = CI_NULL,
		  window_osnum	  = CI_NULL,
		  owner_action	  = 0,
                  properties	  = LC_DP_ONLY | LC_LC_ONLY | LC_RW,
		  snap_point	  = CI_NULL,
		  lc_info	  = CI_NULL,
		  response	  = CI_NULL,
		  count		  = CI_NULL,
		  eligible_classes = CI_NULL )

#if om$specified(classes) && om$specified(eligible_classes)
#   omerror "`classes' and `eligible_classes' are mutually exclusive"
#endif

	CIlocate(	(obj),
			(osnum), 
			(prompt),
			(acc_prompt),
			(relocate_prompt),
			(classes),
			(md_env), 
			(data_point),
			(accept_point),
			(stackable),
			(window_id),
			(window_osnum),
			(owner_action),
			(properties),
			(snap_point),
			(lc_info),
			(response),
			(count),
			(eligible_classes) )
#endomdef


/*----- SUBCLASSES of GRgraphics ----------
/*
/*	GRgraphics
/*	     GRgrset
/*	          GRfcset
/*	          GRsvset
/*	     GRvg
/*	          GRcurve
/*	               GRbspline
/*	                    GRconic
/*	                         GRcirarc
/*	                              GR3dcirarc
/*	                         GRcircle
/*	                              GR3dcircle
/*	                         GRellarc
/*	                              GR3dellarc
/*	                         GRellipse
/*	                              GR3dellipse
/*	                    GRlinear
/*	                         GRinfline
/*	                              GR3dinfline
/*	                         GRlineseg
/*	                              GR3dlineseg
/*	                         GRlinestr
/*	                              GR3dlinestr
/*	                         GRplanar
/*	                              GRorthogonal
/*	                                   GRorthlnst
/*	                                        GR3dorthlnst
/*	                                   GRorthpoly
/*	                                        GR3dorthpoly
/*	                              GRpllnstr
/*	                                   GR3dpllnstr
/*	                              GRpolygon
/*	                                   GR3dpolygon
/*	                                        GRfence
/*	                         GRpoint
/*	                              GR3dpoint
/*	               GRclippoly
/*	               GRpa
/*	                    GRareaptn
/*	                    GRedgeptn
/*	          GRgrouping
/*	               GRflxgrp
/*	                    GRgrgrp
/*	                    GRsymhdr
/*	                         GR3dsymhdr
/*	               GRsymdfhdr
/*	                    GR3dsymdfhdr
/*	               GRsymrfhdr
/*	                    GR3dsymrfhdr
/*	          GRlbsys
/*	               GRcoords
/*	                    GRgencs
/*	                         GRcsbase
/*	               GRtext
/*	                    GR3dtext
/*	          GRrg
/*	               GRraster
/*	                    GRcomprast
/*	                    GRlocrast
/*	                         GRclrast
/*	
/*
/* */

#endif

