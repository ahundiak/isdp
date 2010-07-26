command_string  "qy n pt loc",1,2
class           QYnpt
product_name   "$PLATFORM"
spec_path      "$PLATFORM/co/spec"
super_class     CEO_GSLOCATE
super_class     COnpt
start_state     terminate

specification
#include "de.h"
#include "DIdef.h"
#include "DItypedef.h"

implementation
#include "codebug.h"
#include "grerr.h"
#include "codef.h"
#include "msdef.h"
#include "dedef.h"
#include "igrmacros.h"
#include "coniarray.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "comiscmac.h"
#include "lcmacros.h"
#include <tools.h>
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "referr.h"
#include "exmacros.h"

#include "DIglob.h"
#include "DIprims.h"
#include "DIquery.h"

from GRgraphics   import    GRdisplay;
from GRgrset      import    GSremove_member, GSadd;
from ACcpx        import    find_macro;

extern IGRint QYselect();  
extern IGRint QYlocact();  
%safe
static char   QYnpt_query [256] = { 0 };
%endsafe

instance
{
    char                dir_name [DI_PATH_MAX]	/* directory name	*/;
    struct GRid         ss_id;
    struct GRid         window_id;
    int                 query_state;
    int                 num_query_offsets;
    variable int        query_offsets[20];
}

/*----------------------------------------
 *    define actions
 *----------------------------------------
 */
action form_notification extern

action init_query()                             extern
action switch_query_state(int state; int reset) extern
action add_to_query(int label)                  extern
action back_up_query()                          extern

action display_object
{
  struct GRid          module_grid;
  OMuint               number_objects = 0;

  status = om$get_channel_count(objid = my_id,
			        p_chanselect = &me->located_chansel,
			        count = &number_objects);
  if(number_objects > 0)
  {
    status = ex$get_cur_mod(id = &module_grid.objid,
			    osnum = &module_grid.osnum );
	
    status = om$send(msg = message GRgraphics.GRdisplay(sts,
				    &me->ModuleInfo.md_env.matrix_type,
				     me->ModuleInfo.md_env.matrix,
				    &me->DisplayMode,
				    &module_grid ),
		     p_chanselect = &me->located_chansel);
  }

  *sts = MSSUCC;
}

action init
{

    status = om$send( mode = OM_e_wrt_message,
                      msg = message CEO_LOCATE.init( type, str_ptr ),
                      targetid = my_id );

  *me->event1.event.keyin = '\0';
}

action wakeup
{

    /*
     *  send to my grandparent
     */
    status = om$send( mode = OM_e_wrt_message,
                      msg = message COnpt.wakeup( pos ),
                      targetid = my_id );
}

action sleep
{

    status = om$send( mode = OM_e_wrt_message,
                      msg = message COnpt.sleep ( pos ),
                      targetid = my_id );
}

action filter
{
    IGRint     sts;

    /*
     *  initialize status to be good ( i am an optimist )
     */
    sts = OM_S_SUCCESS;
    status = OM_S_SUCCESS;


    switch ( filter )
    {
        case _gr_locate:
            me->select = (IGRchar (*)())QYselect;
            me->action_handler = (IGRchar (*)())QYlocact;

            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(_gr_locate,
                                                               response,
                                                               response_data),
                              targetid = my_id );


            break;

        case _gs_locate:
            me->select = (IGRchar (*)())QYselect;
            me->action_handler = (IGRchar (*)())QYlocact;

            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(_gs_locate,
                                                               response,
                                                               response_data),
                              targetid = my_id );

            break;

        case _get_event:
            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(_get_event,
                                                               response,
                                                               response_data),
                              targetid = my_id );

            break;

        default:
            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(filter,
                                                                response,
                                                                response_data),
                              targetid = my_id );
            break;

    } /* end switch */
}

action store_locate_context
{
  struct GRobj_env      *object_list = 0;
  IGRint                 count;
  OM_S_OBJECT_LINKAGE   *chan_list = 0;

  status = gr$gsis_graphics_set(msg = sts,
				p_chanselect = &me->located_chansel);
  if((status&1) & (*sts&1))
     {
       gr$gsinqcount(msg = sts,
		     count = &count,
		     p_chanselect = &me->located_chansel);
       
       object_list = (struct GRobj_env *)om$malloc(
			   size = sizeof(struct GRobj_env) * count);
       
       gr$gsget_objects(msg = sts,
			array = object_list,
			size = (sizeof(struct GRobj_env) * count),
			count = &count,
			p_chanselect = &me->located_chansel);
       
{
  int                 i;
/*  char                class_name [80];
  GRspacenum          osnum;
  OM_S_OBJID          objid;
  OM_p_CHANSELECT     p_chanselect;
  IGRint              size;
  IGRint              env_properties;
*/
  OMuint              num;
  OMuint              chan_count;
  OM_S_CHANSELECT     MyChannelStruct;
  struct GRid         grid;
  struct GRid         grset_id;

  if (count)
  {
    /* get grid of active graphic set */
    status = gr$gsget_select_set (msg = sts, select_set_id = &grset_id);

    /* make channel connection to save set */
    status = om$make_chanselect(channame     = "GRgrset.to_sets",
                                p_chanselect = &MyChannelStruct );

    /* get grid of save set */
    status = om$get_objid_at_index ( objid = grset_id.objid,
                                     osnum = grset_id.osnum,
                                     p_chanselect = &MyChannelStruct,
                                     index = 0,
                                     objidaddr = &me->ss_id.objid,
                                     osnumaddr = &me->ss_id.osnum );

    /* make channel connection to the to_owners */
    status = om$make_chanselect(channame = "GRconnector.to_owners",
                                p_chanselect = &MyChannelStruct );
  }

  for (i = 0; i < count; i++)
  {
    /*
     * if the object is connected to an owner,
     * then remove the object from the save set,
     * and add all the owners to the save set.
     */
    status = om$get_channel_count( objid = object_list[i].obj_id.objid,
                                   osnum = object_list[i].obj_id.osnum,
                                   p_chanselect = &MyChannelStruct,
                                   count = &num);

    /* if only one owner (the save set) then do not replace the GO */
    if (num > 1)
    {
      /* if more than one owner, we remove the object from the save set*/
      status = om$send ( msg = message GRgrset.GSremove_member (
                               sts, &object_list [i].obj_id ),
 	                 targetid = me->ss_id.objid,
 	                 targetos = me->ss_id.osnum );

      num--;
      chan_list = (OM_S_OBJECT_LINKAGE *)om$malloc(
                       size = (sizeof(OM_S_OBJECT_LINKAGE)) * (num));

      status = om$get_channel_objects( objid =  object_list[i].obj_id.objid,
                                       osnum =  object_list[i].obj_id.osnum,
                                       p_chanselect = &MyChannelStruct,
                                       list  =  chan_list,
                                       size  =  num,
                                       count = &chan_count);

      /* and add all the parents of the object to the save set */
      {
        int j;

        for ( j=0; j<chan_count; j++ )
	{
	  grid.objid = chan_list[j].S_objid;
	  grid.osnum = chan_list[j].osnum;
/*
           * for each object, add it if it is a sub-class of IGRdir *
          status = om$get_classname( classname = class_name,
                                     objid = grid.objid,
                                     osnum = grid.osnum  );

           * check the classname *
          if (om$is_ancestry_valid( subclassname = class_name,
                                    superclassname = "IGRdir" ) == OM_S_SUCCESS)
          {
 */
            /* we add this parent to the save set */
            status = om$send (
                     msg = message GRgrset.GSadd (sts,
                     &grid,
                     NULL),
 	             targetid = me->ss_id.objid,
 	             targetos = me->ss_id.osnum );

/*
          }
 */
	}
      }
    }
/*
    else
    {
       * for each object, remove it if not a sub-class of IGRdir *
      status = om$get_classname( classname = class_name,
                                 objid = object_list [i].obj_id.objid,
                                 osnum = object_list [i].obj_id.osnum  );

       * check the classname *
      if (om$is_ancestry_valid( subclassname = class_name,
                                superclassname = "IGRdir" ) != OM_S_SUCCESS)
      {
         * we disconnect this guy *
        status = om$send ( msg = message GRgrset.GSremove_member ( sts, &object_list [i].obj_id ),
 	                   targetid = me->ss_id.objid,
 	                   targetos = me->ss_id.osnum );
      }
    }
 */
  }
}

       me->ModuleInfo = object_list[0].mod_env;
       om$dealloc(ptr = object_list);
       om$dealloc(ptr = chan_list);
     }
  else
    {
      status = om$send( mode = OM_e_wrt_message,
		       msg = message COnpt.store_locate_context(sts),
		       targetid = my_id );
    }
}

action store_query
{
  char tmp[160];

  *tmp ='\0';
  if (*me->event1.event.keyin && me->event1.response == EX_STRING)
  {
    /* check just the syntax of the new query */
    *sts = DIprocess_query ( me->event1.event.keyin,
                             NULL, NULL, 1 ) != QY_E_SYNTAX ? MSSUCC : MSFAIL;

    if (*sts == MSSUCC)
    {
      strcpy ( QYnpt_query, me->event1.event.keyin );
      sprintf ( tmp, "the current query is '%s'", QYnpt_query );
    }
    else
    {
      sprintf ( tmp, "syntax error in query : '%s'", me->event1.event.keyin );
    }
  }
  else
    if (*QYnpt_query)
      sprintf ( tmp, "the current query is '%s'", QYnpt_query );
    else
      *sts = MSFAIL;

  if (*tmp)
    UI_status ( tmp );
}

action send_query
{
  struct GRobj_env        *object_list = 0;
  IGRint                  i, count;
  IGRint                  response;
  IGRlong                 size;
  struct GRevent          event;
  OM_S_CHANSELECT         MyChannelStruct;
  struct GRid             module_grid;

  gr$gsinqcount ( msg = sts,
                  count = &count,
		  p_chanselect = &me->located_chansel);
     
  object_list = (struct GRobj_env *)om$malloc ( size = sizeof(struct GRobj_env) * count );
     
  gr$gsget_objects ( msg = sts,
                     array = object_list,
                     size = (sizeof(struct GRobj_env) * count),
                     count = &count,
                     p_chanselect = &me->located_chansel);

  me->DisplayMode = GRbdhe;
  status = ex$get_cur_mod(id = &module_grid.objid,
                          osnum = &module_grid.osnum );
     
  for (i = 0; i < count; i++)
  {
    /* call the process query function */
    status = DIprocess_query ( QYnpt_query,
                               object_list [i].obj_id.osnum,
                               object_list [i].obj_id.objid,
			       NULL );

    if (status == OM_S_SUCCESS)
    {
      char        class_name [80];
      char        tmp_name [80];
      struct GRid tmp_grid;

      /*
       *  is the class/macro name in the select list?
       */

      /* get the class of the object */
      status = om$get_classname( classname = class_name,
                                 objid = object_list[i].obj_id.objid,
                                 osnum = object_list[i].obj_id.osnum  );

      /* is it a macro? */
      if (om$is_ancestry_valid( subclassname = class_name,
                                superclassname = "ACcpx" ) == OM_S_SUCCESS)
      {
        status = om$send(msg = message ACcpx.find_macro( &tmp_grid ),
		         targetid = object_list[i].obj_id.objid,
		         targetos = object_list[i].obj_id.osnum);

        if (di$untranslate ( osnum = (tmp_grid).osnum,
                             objid = (tmp_grid).objid,
                             objname = tmp_name ) != DIR_S_SUCCESS)
            di$report_error ( comment = "di$untranslate", sts = (DIint)sts );

	if (di$split( pathname = tmp_name,
		      name = class_name ) != DIR_S_SUCCESS )
            di$report_error ( comment = "di$split", sts = (DIint)sts );
      }
      else
      {
	/* if object is ACdiowner, then get the GO */
        if ( ! ( strcmp ( class_name, "ACdiowner" ) ) )
	{
	  /* make channel connection to GO */
          status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                      p_chanselect = &MyChannelStruct );

	  /* get the actual GO connected to the ACdiowner */
          status = om$get_objid_at_index ( objid = object_list[i].obj_id.objid,
                                           osnum = object_list[i].obj_id.osnum,
                                           p_chanselect = &MyChannelStruct,
                                           index = 0,
                                           objidaddr = &tmp_grid.objid,
                                           osnumaddr = &tmp_grid.osnum );

          /* get the class of the GO */
          status = om$get_classname( classname = class_name,
                                     objid = tmp_grid.objid,
                                     osnum = tmp_grid.osnum  );
	}
      }

      status = QYis_in_class_list ( class_name );
    }

    if (status != OM_S_SUCCESS)
    {
      /* we disconnect this guy from the save set */
      status = om$send ( msg = message GRgrset.GSremove_member ( sts, &object_list [i].obj_id ),
 	                   p_chanselect = &me->located_chansel );
	
      /* unhilite this object */
      status = om$send(msg = message GRgraphics.GRdisplay(sts,
				      &me->ModuleInfo.md_env.matrix_type,
				       me->ModuleInfo.md_env.matrix,
				      &me->DisplayMode,
				      &module_grid ),
		       targetid = object_list[i].obj_id.objid,
		       targetos = object_list[i].obj_id.osnum);
    }
  }
  
  /* if the save set is not empty, push it on the queue */
  gr$gsinqcount ( msg = sts,
                  count = &count,
		  p_chanselect = &me->located_chansel);

  if ( count )
  {
    /*
     *  Format response data.
     */

    co$build_button( msg = sts,
                     objid = me->window_id.objid,
                     osnum = me->window_id.osnum,
                     button = &event.event.button);

    event.num_id = 1;
    event.num_val = 0;
    event.response = EX_DATA;
    event.subtype = GRst_LOCATE;
    event.located_object[0].located_obj = me->ss_id;
    event.located_object[0].module_info = me->ModuleInfo;

    size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

    /*
     * Put EX_OBJID event on front of software queue
     */

    response = EX_OBJID;
    ex$putque( msg = sts,
               response = &response,
               byte     = &size,
               buffer   = (IGRchar *)&event.event.button );

  }
  else
    *sts = MSFAIL;

  om$dealloc ( ptr = object_list );
}
