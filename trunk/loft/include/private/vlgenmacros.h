/* $Id: vlgenmacros.h,v 1.1.1.1 2001/01/04 21:11:12 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/private/vlgenmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vlgenmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:12  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:05:56  pinnacle
 * Loft 250
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-paris		creation date
 *
 ***************************************************************************/

#ifndef	vlgen_incl_priv
#define	vlgen_incl_priv

/*- format in associative element the given root */
extern long
VLformatAsRoot __((		struct GRid *objId,
				struct GRmd_env *objEnv, 
				struct GRid *asRoot,
				short curOs,
				short plug,
				char *plugTxt ));

#omdef vl$format_as_root(	objId,
				objEnv	= NULL,
				asRoot,
				curOs,
				plug	= FALSE,
				plugTxt	= "Plug" )

	VLformatAsRoot(	(objId), (objEnv), (asRoot), (curOs), (plug), (plugTxt) )

#endomdef

/*- add or modify the an attribute into an attribute box */
extern long
VLadd_mod_attribute __((	struct GRid *attBoxId,
				char *attName,
				double *attExp,
				char *attTxt ));

#omdef vl$add_mod_attribute(	attBoxId,
				attName,
				attExp	= NULL,
				attTxt = NULL )

	VLadd_mod_attribute( (attBoxId), (attName), (attExp), (attTxt) )
#endomdef

#endif
