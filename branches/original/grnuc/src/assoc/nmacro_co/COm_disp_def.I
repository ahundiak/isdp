/*
  Functions used to display macro definition
*/

class implementation COm_place;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "dpdef.h"

#define AS_DEBUG

from GRgraphics import GRaddwrng,GRremwrng,GRdisplay;
from IGEgragad  import DPfit, gragad_cons, DProtate ;
from IGEgadget import	add_gadget, activate ;
from NDmacro import ACreturn_foot;

/* build identity md_env for a given osnum */

ACbuild_env(osnum,lib_env)
GRspacenum osnum;
struct GRmd_env *lib_env;
{
 long msg;

   lib_env->md_id.osnum = osnum;
   ex$get_modid( mod_osnum = lib_env->md_id.osnum,
                 mod_id    = &lib_env->md_id.objid ) ;

   lib_env->md_env.matrix_type = 2 ;
   MAidmx( &msg, lib_env->md_env.matrix ) ;

   return (OM_S_SUCCESS);
}


ACcreate_window(osnum,window,gragad,screen,xor,yor,xl,yl)
GRspacenum osnum;
struct GRid *window,*gragad;
int screen,xor,yor,xl,yl;
{
 long		status,msg ;
 struct GRmd_env lib_env;
 int flag_rotate;
%safe
 static double rotation[16] = {0.707107, 0.707107, 0., 0.,
			       -0.408248, 0.408248, 0.816497, 0.,
			        0.57735 , -0.57735, 0.57735,  0.,
				0., 0., 0., 1. };
%endsafe

	
 /* build md_env for macro lib */

 ACbuild_env(osnum,&lib_env);

	
	/*
	 * Create gragad gadget. A gragad gadget contains all software
	 * information about the window ( Coordinate system, rotation
	 * matrix ... ).
	 */

 status = om$construct( classname	= "ASgradMac",
			    osnum	= lib_env.md_id.osnum,
			    p_objid	= &gragad->objid,
			    msg 	= message IGEgragad.gragad_cons
			        (&msg, "macro definition", 0., 0., 1., 1. ) ) ;
 as$status(action = RET_STATUS);
 gragad->osnum = lib_env.md_id.osnum ;

/*"Gragad constructed : [%d,%d]\n", gragad->osnum, gragad->objid*/

/*
 * Create the graphic window. This window contains all hardware
 * informations about the window ( environ V informations ).
 */
  {
   short space = 3;

   double   min_x, min_y, max_x, max_y;

   min_x = xor; min_y = yor; max_x = min_x+xl; max_y=min_y+yl;

   /*
    * Commented out the win_type parameter.
    * If we create a window WITHOUT border, then we need special
    * routines to manipulate it in the display code. Since are not
    * available currently, we create a window WITH border, so that
    * it can be manipulated in the place macro command. 
    * This fixes TR TR-119417416. - Srikanth
    */
       
       
 	status = ige$construct_win( msg	       = &msg,
				 win_class     = "GRwindow",
				 win_objid     = &window->objid,
				 mod_id        = lib_env.md_id.objid,
				 mod_osnum     = lib_env.md_id.osnum,
				 name	       = "macro description",
	//			 win_type      = NO_BORDER ,
				 dep_indep     = IGE_DEPENDENT,
				 screen = screen,
				 min_x	       = min_x,
				 min_y	       = min_y,
				 max_x	       = max_x,
				 max_y	       = max_y,
				 right_space   = space,
				 left_space    = space,
				 top_space     = space,
				 bottom_space  = space,
				 icon_flags    =  IGE_WIN_TOP_ICON |
				 IGE_WIN_BOTTOM_ICON | IGE_WIN_COLLAPSE_ICON |
				 IGE_WIN_MODIFY_ICON) ;
	as$status(action = RET_STATUS);


	window->osnum = lib_env.md_id.osnum ;
       }

	/*"Window constructed : [%d,%d]\n", window->osnum, window->objid*/

	/*
	 * Add the gragad gadget to the graphic window.
	 */
	status = om$send( msg	= message IGEgadget.add_gadget( &msg,
							        &gragad->objid,
							        1 ),
			       senderid = NULL_OBJID,
			       targetid = window->objid,
		       	       targetos = window->osnum ) ;
	as$status(action = RET_STATUS);


	/*
	 * Activate the graphic window.
	 */
	status = om$send( msg	= message IGEgadget.activate( &msg,
							      0 ),
		       senderid = NULL_OBJID,
		       targetid = window->objid,
		       targetos = window->osnum ) ;

	/*
         *  The default is an iso window *
         */
        flag_rotate = ORIGIN_CENTER | REPLACE_MTX ;

        status = om$send( msg      = message IGEgragad.DProtate( &msg,
                                                              flag_rotate,
                                                              NULL,
                                                              rotation,
                                                              FALSE ),
                       senderid = NULL_OBJID,
                       targetid = gragad->objid,
                       targetos = gragad->osnum ) ;

	return status ;

} /* AScreateWindow */

ACdisplay_macro(macro,default_opt,dup,Nb_Max_Temp,window)
struct GRid *macro,*default_opt,*window;
struct sup *dup;
int Nb_Max_Temp;
{
 struct GRmd_env lib_env;
 struct GRid template;
 long status,msg;
 int i;

 /* build md_env for macro lib */

 ACbuild_env(macro->osnum,&lib_env);

 /* Add element in the R-tree */

 status = om$send( msg      = message GRgraphics.GRaddwrng(&msg, &lib_env ),
                       senderid = NULL_OBJID,
                       targetid = macro->objid,
                       targetos = macro->osnum ) ;

 for(i=0;i<Nb_Max_Temp;i++)
  {
   status = om$send(msg = message NDmacro.ACreturn_foot (&msg,
                       dup[i].prompt,&template,NULL,NULL),
		    senderid = NULL_OBJID,
		    targetid = default_opt->objid,
                    targetos = default_opt->osnum);
   if(msg&status&1)
    {
     status = om$send( msg  = message GRgraphics.GRaddwrng(&msg, &lib_env ),
                       senderid = NULL_OBJID,
                       targetid = template.objid,
                       targetos = template.osnum ) ;
    }
  }
   


 /* Fit window */

 status = om$send( msg      = message IGEgragad.DPfit(&msg, 1 ),
                       senderid = NULL_OBJID,
                       targetid = window->objid,
                       targetos = window->osnum ) ;
 as$status(action = RET_STATUS);

 return OM_S_SUCCESS;
}
 

ACerase_macro(macro,default_opt,dup,Nb_Max_Temp,window)
struct GRid *macro,*default_opt,*window;
struct sup *dup;
int Nb_Max_Temp;
{
 struct GRmd_env lib_env;
 long status,msg;
 enum GRdpmode dpmode;
 struct GRid template;
 int i;


 /* build md_env for macro lib */

 ACbuild_env(macro->osnum,&lib_env);

/* erase macro from window of there is one */
   if(window->objid != NULL_OBJID)
    {
     dpmode = GRbe;
     status = om$send( msg      = message GRgraphics.GRdisplay(
                                                    &msg,
                                                    &lib_env.md_env.matrix_type,
                                                    lib_env.md_env.matrix,
                                                    &dpmode,
                                                    &lib_env.md_id ),
                       senderid = NULL_OBJID,
                       targetid = macro->objid,
                       targetos = macro->osnum ) ;
     as$status();
    }



/* remove macro from Rtree */

   status = om$send( msg      = message GRgraphics.GRremwrng( &msg, &lib_env ),
                       senderid = NULL_OBJID,
                       targetid = macro->objid,
                       targetos = macro->osnum ) ;


/* remove template from Rtree */

 for(i=0;i<Nb_Max_Temp;i++)
  {
   status = om$send(msg = message NDmacro.ACreturn_foot (&msg,
                       dup[i].prompt,&template,NULL,NULL),
                    senderid = NULL_OBJID,
                    targetid = default_opt->objid,
                    targetos = default_opt->osnum);
   if(msg&status&1)
    {
     status = om$send( msg      = message GRgraphics.GRdisplay(
                                                    &msg,
                                                    &lib_env.md_env.matrix_type,
                                                    lib_env.md_env.matrix,
                                                    &dpmode,
                                                    &lib_env.md_id ),
                       senderid = NULL_OBJID,
                       targetid = template.objid,
                       targetos = template.osnum ) ;
     as$status();

     status = om$send( msg  = message GRgraphics.GRremwrng(&msg, &lib_env ),
                       senderid = NULL_OBJID,
                       targetid = template.objid,
                       targetos = template.osnum ) ;
    }
  }
   return OM_S_SUCCESS;
}

end implementation  COm_place;

