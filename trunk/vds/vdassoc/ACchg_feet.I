/* $Id: */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdassoc/ACchg_feet.I
 *
 * Description: This method attaches new feet to the complex, the new feet 
 *		are stripped of their parents.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: ACchg_feet.I,v $
 *      Revision 1.3  2001/08/14 19:21:32  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/28 19:51:21  ramarao
 *      Removed unnecessary SetProc and End.
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/06/11  20:44:34  pinnacle
# TR_179701509
#
 *
 * History:
 *	original author
 *      robert patience
 *      1 sept 1989
 *
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      06/10/98  ejm     TR_179701509: message, "GRrigidconn msg 8048373", is
 *			  displayed each time an assoc intersection is created
 *			  between deck surface and frame plane.
 *
 *			  Statement was being printed for informational 
 *			  messages. Changed (msg != MSSUCC) to ( !(msg&1) ). 
 *
 *      08/14/01  ah      Tweaked the error message again
 ***************************************************************************/

class implementation ACncpx;

#define AS_DEBUG
/*
#define vdsDEBUG
*/

#include "v_dbgmacros.h"
#include "ASmacroi.h"	  /* assoc/include_priv, includes several .h files */
#include "grerr.h"
#include "ASmsg.h"


extern GRclassid OPP_ASsource_class_id, OPP_ACpretend_class_id;



/* ========================================================================= */

method ACchange_feet(int count;
			struct GRid 	*feet_list;
			struct GRmd_env *mod_env 
			)
{
  int		status,i;
  struct GRid	graph_obj_new,work_obj,MY_GRID;
  GRclassid 	target_cl;
  IGRlong	msg = MSSUCC;


  MY_GRID.objid = my_id; MY_GRID.osnum = OM_Gw_current_OS;


/* only to support ACncpx that dont support context management */

/* Really necessary now since I have removed the GRdelete from
   get_context_s_compute in order to not delete the default macro 
   in the macro library jla 27-03-91 */

  status = om$send (msg = message GRgraphics.GRdelete ( &msg, mod_env ), 
		     	p_chanselect = &AC_mto_graf_chns );
  as$status (  );

  for ( i=0; i<count; i++)
  {
   if(!IF_NULL_OBJID(feet_list[count-1-i].objid))
    {count=count-i;break;}
  }

  for ( i=0; i<count; i++)
  {
    work_obj=feet_list[i];
/*"foot %d %d \n", work_obj.objid,work_obj.osnum*/
    if(IF_NULL_OBJID(work_obj.objid))
    {
     status = ACcreate_pl_hold(&work_obj,OM_Gw_current_OS);
     as$status(action = RET_STATUS);
    }
    om$get_classid(objid=work_obj.objid,
		   osnum=work_obj.osnum,
		    p_classid = &target_cl);

    if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
    {
      if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS
	 ||
         om$is_ancestry_valid(subclassid =target_cl ,
                         superclassid = OPP_ACpretend_class_id) == OM_S_SUCCESS)
      {
       status = om$send( msg = message NDnode.ASreturn_go( &graph_obj_new, 
				NULL,NULL),
		  targetid = work_obj.objid ,
		  targetos = work_obj.osnum);
       as$status ( action = RET_STATUS );
       work_obj=graph_obj_new;
      }
      else
      {
       status = om$send( msg = message NDmacro.ACbecome_foot
						(&msg,&work_obj,mod_env),
                    targetid=work_obj.objid,targetos=work_obj.osnum);
       as$status( );

      }
    }

    status = om$send(msg = message GRconnector.GRrigidconn( &msg,&MY_GRID,
							    (IGRlong *)&i),
	             targetid=work_obj.objid,targetos=work_obj.osnum );
    as$status ();

  /* TR_179701509 */

    if( !(msg&1) ) {
      printf(" ACncpxi.I, ACchange_feet: GRrigidconn msg  %x \n",msg);
      VDobjPrint2(NULL,&work_obj);
      VDobjPrint2(NULL,&MY_GRID);
      printf("\n");
    }
  }

  return ( OM_S_SUCCESS );
}

end implementation ACncpx;
