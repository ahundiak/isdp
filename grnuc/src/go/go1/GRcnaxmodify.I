/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAME: GRaxmodify

     Abstract: This routine modifies the length of one axis of a 
	      conic element as indicated by an input point that is
	      projected onto the axis to determine the length.

-----
%SC%    

	GRaxmodify(msg,env,axis_pt,end_pt,newid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     env	  GRmd_env	 environment information
     axis_pt	  IGRpoint	 point indicating axis to modify
     end_pt	  IGRpoint	 point to extend end of axis to

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - severe error

     newid	  GRobjid	 returned object id

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     MAbctoar
	     MAptln2dis
	     MAptlnproj
	     MA2ptdis
	     MAartobc
     Methods:
	     GRgetarc
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
 This routine gets the abstract geometry of the conic object and 
converts it to an IGRarc. Then two lines are constructed which 
represent the axes of the object and the distances from axis_pt to
each is computed. The axis to modify is the axis which is closest to 
axis_pt. Then end_pt is projected onto the axis to modify and the 
distance from the origin of the object to the projected point becomes
the modified axis length. Finally, the new conic element is converted 
to a B-spline curve and is posted.

----*/
/*EH*/

class implementation GRconic;


#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAptln2dis();
extern    IGRboolean    MAptlnproj();
extern    IGRboolean    MA2ptdis();

method GRaxmodify(IGRlong *msg; struct GRmd_env *env; IGRpoint axis_pt,
		  end_pt; GRobjid *newid)
{
  struct IGRarc arc;				/* arc geometry		     */
  struct IGRline prim,sec;			/* axes of object	     */
  struct GRpost_info info;

  GRspacenum osnum;				/* current space	     */

  IGRpoint p0,p1,p2,p3;				/* points for prim and sec   */
  IGRpoint proj_pt;				/* projected end_pt          */

  IGRdouble t;					/* t parameter of proj_pt    */
  IGRdouble dis1,dis2;				/* distances to axes	     */

  IGRlong i;					/* index		     */
  IGRlong mess;					/* return code		     */
  IGRlong OMmsg;				/* OM return code	     */


  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;
  *newid = my_id;

						/* get IGR geometry         */
  OMmsg = om$send(mode = OM_e_wrt_object,
      msg = message GRconic.GRgetarc
	(msg, &env->md_env.matrix_type,env->md_env.matrix,&arc),
      senderid = my_id,
      targetid = my_id);

  if( 1 & OMmsg & *msg )
    {
      prim.point1 = p0;			/* init axis lines	     */
      prim.point2 = p1;
      sec.point1  = p2;
      sec.point2  = p3;

      for(i = 0; i < 3; ++i)
         {
           prim.point1[i] = arc.origin[i];
           prim.point2[i] = arc.origin[i] + arc.rot_matrix[4 * i];

           sec.point1[i] = arc.origin[i];
           sec.point2[i] = arc.origin[i] + arc.rot_matrix[4 * i + 1];
         }

      MAptln2dis(&mess,axis_pt,&prim,&dis1);
      MAptln2dis(&mess,axis_pt,&sec,&dis2);

      if( dis1 <= dis2 )			/* modify prim axis length   */
   	{
	  MAptlnproj(&mess,end_pt,&prim,proj_pt,&t);
	  MA2ptdis(&mess,arc.origin,proj_pt,&arc.prim_axis);
	}
      else					/* modify sec axis length    */
	{
	  MAptlnproj(&mess,end_pt,&sec,proj_pt,&t);
	  MA2ptdis(&mess,arc.origin,proj_pt,&arc.sec_axis);
	}

      info.construct_flag = FALSE;

      OMmsg = om$send(mode = OM_e_wrt_object,
              msg = message GRconic.GRputarc(msg,env,&info,&arc,newid),
              senderid = my_id,
              targetid = my_id);

      osnum = OM_Gw_current_OS;			/* delete form cache	    */
      GRabsg_del_by_objid(&my_id,&osnum);
    }
    my_id = *newid;

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRconic;
