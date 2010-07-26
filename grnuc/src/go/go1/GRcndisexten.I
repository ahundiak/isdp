/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAME: GRdisextend

     Abstract: This routine extends one endpoint of a conic arc
	      by a specified arc length.

-----
%SC%    

	GRdisextend(msg,env,endpoint,dist,newend);


-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     env	  GRmd_env	 environment information
     endpoint	  IGRpoint	 endpoint to extend
     dist	  IGRdouble	 distance to extend

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - severe error
					MSINARG - arc was already 
				 closed or the point, ext_pt, does not
			 	 identify unique extension point

     newend	  IGRpoint	 new end point
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     MAptbcproj
	     BScncxtdst
	     MAbcueval
     Methods:
	     GRgetarc
	     GRgenabsg
	     GRpostabsg
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	RDH     05/02/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This method gets the IGR geometry of the object and checks to
see if the arc is open. If it is, the routine gets the abstract
data of the curve and calls a routine to find the extension of the
arc. Then it posts the extended arc.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "bserr.h"
#include "bsconic.h"
#include "godef.h"
#include "gocmacros.h"

method GRdisextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint;
		  IGRdouble *dist; IGRpoint newend)
{
  struct IGRbsp_curve bc_arc;			/* extended conic arc	     */
  struct IGRbsp_curve *bc;			/* abstract geometry pointer */
  struct IGRarc arc;				/* arc geometry		     */
  struct GRpost_info info;
 
  IGRpoint proj_pt;				/* project point	     */

  IGRdouble poles[60],knots[25],wts[20];	/* storage for bc_arc	     */
  IGRdouble upar;				/* u par of end to extend    */
  IGRdouble h;
  IGRdouble proj_u;
  IGRdouble tol = 0.000001;
  IGRdouble dis1,dis2;

  IGRshort option;

  IGRchar *ptr;					/* geometry pointer	     */
  GRobjid newid;				/* new object id	     */
 
  GRspacenum osnum;

  IGRlong mess;					/* return code		     */
  IGRlong OMmsg;				/* OM return code	     */

  IGRshort ctype;				/* conic type		     */

  extern IGRboolean MAptbcproj();
  extern IGRboolean MAbcueval();
  extern void BScncxtdst();

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRconic.GRgetarc(msg, &env->md_env.matrix_type,env->md_env.matrix, &arc),
                  senderid = my_id,
                  targetid = my_id);

  if( 1 & OMmsg & *msg )
  {
    GRgetabsg(msg,&env->md_env.matrix_type,env->md_env.matrix,&ptr,i);

    if( 1 & *msg )
    {
      bc = (struct IGRbsp_curve *)ptr;

      bc_arc.poles = poles;
      bc_arc.knots = knots;
      bc_arc.weights = wts;

      if( arc.prim_axis == arc.sec_axis )
      {
	ctype = BSCARCCIRCULAR;
      }
      else
      {
	ctype = BSCARCELLIPTIC;
      }

      if( MAptbcproj(msg,endpoint,bc,&tol,proj_pt,&proj_u) )
      {
	dis1 = proj_u - bc->knots[bc->order - 1];
	dis2 = bc->knots[bc->num_poles] - proj_u;

	if( dis1 <= dis2 )
	{
	  upar = bc->knots[bc->order - 1];
	}
	else
	{
	  upar = bc->knots[bc->num_poles];
	}

	bc->phy_closed = 0;

	BScncxtdst(ctype,bc,*dist,upar,&bc_arc,&mess);

	if( mess == BSSUCC )
	{
	  if( dis1 <= dis2 )
	  {
	    upar = bc_arc.knots[bc_arc.order - 1];
	  }
	  else
	  {
	    upar = bc_arc.knots[bc_arc.num_poles];
	  }

	  option = 0;

	  MAbcueval(&mess,&bc_arc,&option,&upar,newend,&h);

	  ptr = (IGRchar *)&bc_arc;
	  info.construct_flag = FALSE;
	
	  OMmsg = om$send(mode = OM_e_wrt_object,
                          msg = message GRvg.GRpostabsg(msg,env,&info,ptr,&newid),
                          senderid = my_id,
                          targetid = my_id);

	  osnum = OM_Gw_current_OS;
	  GRabsg_del_by_objid(&my_id,&osnum);
	}
	else
	{
	  *msg = MSFAIL;
	}
      }
    }
  }
  else
  {
    if( 1 & OMmsg )
    {
      OMmsg = OM_E_ABORT;			/* failed to get input	     */
    }
  }

  GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRconic;
