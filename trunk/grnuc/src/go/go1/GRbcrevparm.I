/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRrevparm

     Abstract: This method reverses the parameterization of a B-spline
	      based geometry object.

-----
%SC%    


-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     env	  GRmd_env	 environment information
     
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     
     Methods:
	     GRgenabsg	     
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	   
-----
%CH%

     CHANGE HISTORY:
	
	RDH     06/09/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This method gets the abstract geometry of the object and reverses
the parameterization of the object. Then it posts the object.

----*/
/*EH*/


class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcrevparm();

method GRrevparm(IGRlong *msg; struct GRmd_env *env)

{
  struct IGRbsp_curve *bc;		/* abstract geom pointer	      */
  struct GRpost_info  info;

  GRobjid new_id;			/* object id			      */

  IGRchar *ptr;				/* abstract geom pointer	      */


  IGRlong OMmsg;			/* OM return code		      */



  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;
					/* get abstract geometry  	      */
  GRgetabsg(msg,&env->md_env.matrix_type,env->md_env.matrix,&ptr,i);

  if( 1 & *msg )
    {
      bc = (struct IGRbsp_curve *)ptr;

      if( MAbcrevparm(msg,bc,bc) )
        {
	  info.construct_flag = FALSE;

	  OMmsg = om$send(mode = OM_e_wrt_object,
                          msg = message GRvg.GRpostabsg(msg, env,&info,ptr,&new_id),
                          senderid = my_id,
                          targetid = my_id);
	}

    }

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);
  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRbspline;

