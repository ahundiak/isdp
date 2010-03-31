
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation Root;
 
#define CHECK_RETURN_CODES 1

#include <stdlib.h>

#include "igrtypedef.h"

#include "igetypedef.h"
#include "igrdef.h"

#include "msdef.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hssymbmacros.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "hstexmacros.h"

#include <stdio.h>
#include "OMminimum.h"
#include "igr.h"
#include "gr.h"
#include "hslight.h"
#include "HSdlist.h"

%safe
#include "HSpr_dpb_imp.h"
%endsafe

from GRgraphics import GRgethprops;
from GRvg       import GRchghprops;

#define MAX_FINISH 255
	
/*--- HSget_element_shading_symb -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSget_element_shading_symb( OM_S_OBJID objid,
					      OMuword osnum,
					       IGRint *style,
					       IGRint *finish,
					    IGRdouble *diff_refl,
					    IGRdouble *spec_refl,
					    IGRdouble *transparency,
					     IGRuchar *tex_orient,
				       unsigned short *tex_index,
				             IGRuchar *red,
				             IGRuchar *green,
				             IGRuchar *blue,
				        unsigned char *app_entry )
#else
	IGRint HSget_element_shading_symb( objid, osnum,
		                           style, finish, diff_refl, spec_refl, transparency,
		                           tex_orient, tex_index, red, green, blue,app_entry)

	OM_S_OBJID       objid;
	OMuword          osnum;
	IGRint           *style;              /* NULL, if not desired */
	IGRint           *finish;             /* NULL, if not desired */
	IGRdouble        *diff_refl;          /* NULL, if not desired */
	IGRdouble        *spec_refl;          /* NULL, if not desired */
	IGRdouble        *transparency;       /* NULL, if not desired */
	IGRuchar 	 *tex_orient;         /* NULL, if not desired */
	unsigned short   *tex_index;          /* NULL, if not desired */
	IGRuchar 	 *red;                /* NULL, if not desired */
	IGRuchar 	 *green;              /* NULL, if not desired */
	IGRuchar 	 *blue;               /* NULL, if not desired */
	unsigned char    *app_entry;          /* NULL, if not desired */
#endif
        

/*
DESCRIPTION
	This function gets the shading symbology of an element.  It can return
	any combination of the style, finish, diffuse reflectance, specular
	reflectance, transparency, texture orientation, texture index, RGB,
	refraction, pattern x offset, pattern y offset, pattern rot angle,
	pattern scale, special rendering flags and refraction.
	If a particular symbology is not desired, its corresponding parameter should
	be set to NULL.  Defines for style can be found in hsmacdef.h. Diffuse reflectance,
	specular reflectance, and transparency are returned as doubles between 0.0 and 1.0
	that indicate a percentage. Finish is an integer between 1 and MAX_FINISH.
	Defines for special rendering flags can be found in hsurf.h.

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	IGRlong                      sts;
	IGRlong                      msg;
	IGRuint	                     bundle_index;
        struct HSrender_bundle       entry;
	GRobjid                      modid;

	/* get the shading symbology bundle index of the element */
	sts = om$send( msg      = message GRgraphics.GRgethprops( &msg, &bundle_index ),
	               senderid = NULL_OBJID,
	               targetid = objid,
	               targetos = osnum );

	if ( ! (1 & sts & msg) )
	   {
	   /* message failed => return default parameters */
	   if ( style )
	      *style = HS_STYLE_SMOOTH;

	   if ( finish )
	      *finish = 11;

	   if ( diff_refl )
	      *diff_refl = 1.0;

	   if ( spec_refl )
	      *spec_refl = 0.5;

	   if ( transparency )
	      *transparency = 0.0;

	   if ( tex_orient )
	      *tex_orient = 0;

	   if ( tex_index )
	      *tex_index = 0;

	   if ( red )
	      *red = 0;

	   if ( green )
	      *green = 0;

	   if ( blue )
	      *blue = 0;

           return(1);
	   }
	else
	   {
	   /* get the rendering bundle associated with the index */
	   /* and return its data.                               */

	   ex$get_modid(mod_osnum = osnum, mod_id = &modid);
           
	   hs$retrieve_symb_entry(msg = &msg,
	                          index= bundle_index,
	                          entry = &entry,
	                          app_entry = app_entry,
	                          mod_id = modid,
	                          mod_osnum = osnum);
             
	   if ( style )
	      *style = entry.shad_style;

	   if ( finish )
	      *finish = entry.finish;

	   if ( diff_refl )
	      *diff_refl = entry.diff_refl / 255.0;

	   if ( spec_refl )
	      *spec_refl =  entry.spec_refl / 255.0;

	   if ( transparency )
	      *transparency = entry.trans / 255.0;

	   if ( tex_orient )
	      *tex_orient = entry.tex_orient;

	   if ( tex_index )
	      *tex_index = entry.tex_index;

	   if ( red )
	      *red =  entry.red;

	   if ( green )
	      *green =  entry.green;

	   if ( blue )
	      *blue =  entry.blue;



	   return( 0 );
	   }

	}  /* HSget_element_shading_symb */
	

/*--- HSset_element_shading_symb -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_element_shading_symb( OM_S_OBJID objid,
					      OMuword osnum,
					       IGRint *style,
					       IGRint *finish,
					    IGRdouble *diff_refl,
					    IGRdouble *spec_refl,
					    IGRdouble *transparency,
					     IGRuchar *tex_orient,
				       unsigned short *tex_index,
					     IGRuchar *red,
					     IGRuchar *green,
					     IGRuchar *blue,
				        unsigned char *app_entry )
#else
	IGRint HSset_element_shading_symb( objid, osnum,
		                           style, finish, diff_refl, spec_refl, transparency,
		                           tex_orient, tex_index, red, green, blue,app_entry)

	OM_S_OBJID       objid;
	OMuword          osnum;
	IGRint           *style;              /* NULL, if not desired */
	IGRint           *finish;             /* NULL, if not desired */
	IGRdouble        *diff_refl;          /* NULL, if not desired */
	IGRdouble        *spec_refl;          /* NULL, if not desired */
	IGRdouble        *transparency;       /* NULL, if not desired */
	IGRuchar         *tex_orient;         /* NULL, if not desired */
	unsigned short   *tex_index;          /* NULL, if not desired */
	IGRuchar 	 *red;                /* NULL, if not desired */
	IGRuchar 	 *green;              /* NULL, if not desired */
	IGRuchar 	 *blue;               /* NULL, if not desired */
	unsigned char    *app_entry;          /* NULL, if not desired */
#endif

/*
DESCRIPTION
	This function sets the shading symbology of an element.  It can set
	any combination of the style, finish, diffuse reflectance, specular
	reflectance, transparency, texture orientation, texture index, RGB,
	refraction, pattern x offset, pattern y offset, pattern rot angle,
	pattern scale, special rendering flags and refraction.
	If a particular symbology is not to be set, its corresponding parameter
	should be set to NULL.  Defines for style can be found in hsmacdef.h.
	Diffuse reflectance, specular reflectance, and transparency should be
	doubles between 0.0 and 1.0 that indicate a percentage. Finish is an
	integer between 1 and MAX_FINISH.  Defines for special rendering flags
	can be found in hsurf.h.

	Return Values:

	   0 - success
	   1 - failure (bad objid,osnum or a symbology out of range)

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	IGRlong                      sts;
	IGRlong                      msg;
	IGRuint                      bundle_index;
        struct HSrender_bundle       entry;
	IGRshort                     action;
        IGRint                       new_index;
	GRobjid                      modid;
	IGRint                       int_reflectance,int_transparency;
	IGRint                       valid_index;
        



	/* get the rendering bundle index of the element */
	sts = om$send( msg      = message GRgraphics.GRgethprops( &msg, &bundle_index ),
	               senderid = NULL_OBJID,
	               targetid = objid,
	               targetos = osnum );

	if ( ! (1 & sts & msg) )
	   return( 1 );

	/* get the bundle associated with the bundle index and change it */
	ex$get_modid(mod_osnum = osnum, mod_id = &modid);
	hs$retrieve_symb_entry(msg = &msg,
                               index = bundle_index,
                               entry = &entry,
	                       app_entry = NULL,
                               mod_id = modid,
                               mod_osnum = osnum);


	if ( style )
           {
           if ( (*style == HS_STYLE_SMOOTH) ||
                (*style == HS_STYLE_CONSTANT) ||
                (*style == HS_STYLE_RASTER) ||
                (*style == HS_STYLE_FILLED_RASTER) ||
                (*style == HS_STYLE_AREAFILL) )
              entry.shad_style = *style; 
           else
              return( 1 ); 
            }

        if ( finish )
           {
           if ( (*finish < 0) || (*finish > MAX_FINISH) )
             return( 1 );
           else
              entry.finish = *finish;
           }

        if ( diff_refl )
           {
           int_reflectance = (*diff_refl * 255.0) + 0.5;
           if ( (int_reflectance < 0) || (int_reflectance > 255) )
              return( 1 ); 
           else
              entry.diff_refl = int_reflectance;
           }
	  if ( spec_refl )
           {
           int_reflectance = (*spec_refl * 255.0) + 0.5;
           if ( (int_reflectance < 0) || (int_reflectance > 255) )
              return( 1 );
           else
              entry.spec_refl = int_reflectance;
           }

        if ( transparency )
           {
           int_transparency = (*transparency * 255.0) + 0.5;
           if ( (int_transparency < 0) || (int_transparency > 255) )
              return( 1 );
           else
              entry.trans = int_transparency;
           }

        if ( tex_orient )
           entry.tex_orient = *tex_orient; 

        if ( tex_index )
	   {
	   hs$validate_texture_index(index = *tex_index,
	                             valid_index = &valid_index,
                                     mod_osnum = osnum);
	   if (valid_index)
	      entry.tex_index = *tex_index; 
	   else
	      entry.tex_index = 0;
	   }

        if ( red )
           entry.red = *red;

        if ( green )
           entry.green = *green;

        if ( blue )
           entry.blue = *blue;


        /* Notify the display lists of the change */
        if ( diff_refl && spec_refl && finish && transparency )
        {
           HSdlist_shading_parameter_notify( objid, osnum, entry.diff_refl, 
                                             entry.spec_refl, entry.finish, 
                                             entry.trans );
        }

	hs$change_symb_entry(msg= &msg,
                             old_index = bundle_index,
                             entry = &entry,
	                     app_entry = app_entry,
                             new_index = &new_index,
                             mod_id = modid,
                             mod_osnum = osnum);
        action = -1; 
	sts = om$send( msg      = message GRvg.GRchghprops( &msg,  &action, &new_index ),
	               senderid = NULL_OBJID,
	               targetid = objid,
	               targetos = osnum );

	return( (1 & sts & msg) ? 0 : 1 );

	}  /* HSset_element_shading_symb */


/*--- HSget_active_shading_symb -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSget_active_shading_symb( IGRint *style,
					  IGRint *finish,
				       IGRdouble *diff_refl,
				       IGRdouble *spec_refl,
				       IGRdouble *transparency,
				        IGRuchar *tex_orient,
				  unsigned short *tex_index,
				        IGRuchar *red,
				        IGRuchar *green,
				        IGRuchar *blue,
				   unsigned char *app_entry )
#else
	IGRint HSget_active_shading_symb( style, finish, diff_refl, spec_refl, transparency,
		                          tex_orient, tex_index, red, green, blue,app_entry)

	IGRint           *style;              /* NULL, if not desired */
	IGRint           *finish;             /* NULL, if not desired */
	IGRdouble        *diff_refl;          /* NULL, if not desired */
	IGRdouble        *spec_refl;          /* NULL, if not desired */
	IGRdouble        *transparency;       /* NULL, if not desired */
	IGRuchar         *tex_orient;         /* NULL, if not desired */
	unsigned short   *tex_index;          /* NULL, if not desired */
	IGRuchar         *red;                /* NULL, if not desired */
	IGRuchar         *green;              /* NULL, if not desired */
	IGRuchar         *blue;               /* NULL, if not desired */
	unsigned char    *app_entry;          /* NULL, if not desired */
#endif

/*
DESCRIPTION
	This function gets the active shading symbology.  It can return any
	combination of the style, finish, diffuse reflectance, specular
	reflectance, transparency, texture orientation, texture index, RGB,
	refraction, pattern x offset, pattern y offset, pattern rot angle,
	pattern scale, special rendering flags and refraction.
	If a particular symbology is not desired, its corresponding parameter
	should be set to NULL.  Defines for style can be found in hsmacdef.h.
	Diffuse reflectance, specular reflectance, and transparency are returned
	as doubles between 0.0 and 1.0 that indicate a percentage. Finish is an
	integer between 1 and MAX_FINISH.  Defines for special rendering flags
	can be found in hsurf.h.

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	struct HSrender_bundle       rend_bundle;
        struct HSextra_render_bundle *app_bundle;

        app_bundle = NULL; /* Till we initialize I/Design bundles 
                              Later call hs$get_app_entry_size to allocate the
                              memory */
	hs$get_rendering_bundles( rend_bundle = &rend_bundle,
	                          extra_rend_bundle = app_bundle );

	if ( style )
	   *style = rend_bundle.shad_style;

	if ( finish )
	   *finish = rend_bundle.finish;

	if ( diff_refl )
	   *diff_refl = rend_bundle.diff_refl / 255.0;

	if ( spec_refl )
	   *spec_refl = rend_bundle.spec_refl / 255.0;

	if ( transparency )
	   *transparency = rend_bundle.trans / 255.0;

	if ( tex_orient )
	   *tex_orient = rend_bundle.tex_orient;

	if ( tex_index )
	   *tex_index = rend_bundle.tex_index;

	if ( red )
	   *red = rend_bundle.red;

	if ( green )
	   *green = rend_bundle.green;

	if ( blue )
	   *blue = rend_bundle.blue;

/* Once we start initializing I/Design bundles in DPB (ie app_bundle) return
 app_bundle  */
        

	return( 0 );

	}  /* HSget_active_shading_symb */
	

/*--- HSset_active_shading_symb -------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_active_shading_symb( IGRint *style,
					  IGRint *finish,
				       IGRdouble *diff_refl,
				       IGRdouble *spec_refl,
				       IGRdouble *transparency,
					IGRuchar *tex_orient,
				  unsigned short *tex_index,
					IGRuchar *red,
					IGRuchar *green,
					IGRuchar *blue,
				   unsigned char *app_entry )
#else
	IGRint HSset_active_shading_symb( style, finish, diff_refl, spec_refl, transparency,
		                          tex_orient, tex_index, red, green, blue, app_entry)

	IGRint           *style;              /* NULL, if not desired */
	IGRint           *finish;             /* NULL, if not desired */
	IGRdouble        *diff_refl;          /* NULL, if not desired */
	IGRdouble        *spec_refl;          /* NULL, if not desired */
	IGRdouble        *transparency;       /* NULL, if not desired */
	IGRuchar         *tex_orient;         /* NULL, if not desired */
	unsigned short   *tex_index;          /* NULL, if not desired */
	IGRuchar         *red;                /* NULL, if not desired */
	IGRuchar         *green;              /* NULL, if not desired */
	IGRuchar         *blue;               /* NULL, if not desired */
	unsigned char    *app_entry;          /* NULL, if not desired */
#endif


/*
DESCRIPTION
	This function sets the active shading symbology.  It can set any
	combination of the style, finish, diffuse reflectance, specular
	reflectance, transparency, texture orientation, texture index, RGB,
	refraction, pattern x offset, pattern y offset, pattern rot angle,
	pattern scale, special rendering flags and refraction.
	If a particular symbology is not to be set, its corresponding parameter
	should be set to NULL.  Defines for style can be found in hsmacdef.h. 
	Diffuse reflectance, specular reflectance, and transparency should be
	doubles between 0.0 and 1.0 that indicate a percentage. Finish is an
	integer between 1 and MAX_FINISH.  Defines for special rendering flags
	can be found in hsurf.h.

	Return Values:

	   0 - success
	   1 - failure (symbology out of range)

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	IGRint                       int_reflectance, int_transparency;
	IGRint                       valid_index;
	struct HSrender_bundle       rend_bundle;
	struct HSextra_render_bundle *app_bundle;
        GRspacenum       modos;
        GRobjid          mod_id;

        app_bundle = NULL; /* Till we initialize I/Design bundles 
                              Later call hs$get_app_entry_size to allocate the
                              memory */
	hs$get_rendering_bundles( rend_bundle       = &rend_bundle,
	                          extra_rend_bundle = app_bundle );

	if ( style )
	   {
	   if ( (*style == HS_STYLE_SMOOTH) ||
	        (*style == HS_STYLE_CONSTANT) ||
	        (*style == HS_STYLE_RASTER) ||
	        (*style == HS_STYLE_FILLED_RASTER) ||
	        (*style == HS_STYLE_AREAFILL) )
	      rend_bundle.shad_style = *style;
	   else
	      return( 1 );  /* invalid style */
	   }  /* end: if ( style ) */

	if ( finish )
	   {
	   if ( (*finish < 0) || (*finish > MAX_FINISH) )
	     return( 1 );  /* invalid finish */
	   else
	      rend_bundle.finish = *finish;
	   }

	if ( diff_refl )
	   {
	   int_reflectance = (*diff_refl * 255.0) + 0.5;
	   if ( (int_reflectance < 0) || (int_reflectance > 255) )
	      return( 1 );  /* invalid reflectance */
	   else
	      rend_bundle.diff_refl = int_reflectance;
	   }

	if ( spec_refl )
	   {
	   int_reflectance = (*spec_refl * 255.0) + 0.5;
	   if ( (int_reflectance < 0) || (int_reflectance > 255) )
	      return( 1 );  /* invalid reflectance */
	   else
	      rend_bundle.spec_refl = int_reflectance;
	   }

	if ( transparency )
	   {
	   int_transparency = (*transparency * 255.0) + 0.5;
	   if ( (int_transparency < 0) || (int_transparency > 255) )
	      return( 1 );  /* invalid transparency */
	   else
	      rend_bundle.trans = int_transparency;
	   }

	if ( tex_orient )
	   rend_bundle.tex_orient = *tex_orient;  /* needs to be validated */

	if ( tex_index )
	   {
	   ex$get_cur_mod(id = &mod_id,osnum = &modos);
	   hs$validate_texture_index(index = *tex_index, 
	                             valid_index = &valid_index,
                                     mod_osnum = modos);
	   if (valid_index)
	      rend_bundle.tex_index = *tex_index;  
	   else
	      rend_bundle.tex_index = 0;
           }

	if ( red )
	   rend_bundle.red = *red;

	if ( green )
	   rend_bundle.green = *green;

	if ( blue )
	   rend_bundle.blue = *blue;


	hs$set_rendering_bundles( rend_bundle       = &rend_bundle,
	                          extra_rend_bundle = app_bundle );

	return( 0 );

	}  /* HSset_active_shading_symb */

end implementation Root;
