/* $Id: ACncpxi.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACncpxi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACncpxi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
  ACncpxi.I
  robert patience
  1 sept 1989
*/
class implementation ACncpx;

#define AS_DEBUG

#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "godef.h"
#include "grownerdef.h"
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "gocmacros.h"
#include "ASmsg.h"
#include "msmacros.h"
#include <alloca.h>


from ACcpx_defn import 	ACgive_name, ACgive_temp_desc, ACgive_feet_desc;
from ACcpx_defn import 	ACintpt_foot,ACmax_graph_ft;
from ACmacro_defn import 	ACgive_upscan;
from ACpretend  import 	ACfind_parent;
from ACpretend  import 	ACrebind;
from ACconst  import 	ACget_foot_in_mac;

extern GRclassid OPP_ACpl_hold_class_id, OPP_ASsource_class_id,
		 OPP_ACpretend_class_id, OPP_expression_class_id;

method ACgive_path(int *suc;struct GRid *go_obj;char *footname)
{
  int status,i,j,nb_template_feet;
  struct GRid mac_def;
  struct myfeet *feet;
  int feet_num,max_g_ft;

  footname[0]=0;
  *suc = 0;

/* Retrieve macro definition, feet definition, how many feet are output */

  status = om$send(msg = message ACcpx.find_macro(&mac_def),
 		     targetid = my_id );
  as$status(action = RET_STATUS );

  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc(&feet_num, &feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status();

  status = om$send(msg= message ACcpx_defn.ACmax_graph_ft(&max_g_ft),
		      targetid = mac_def.objid ,targetos =mac_def.osnum);
  as$status();

  
/* Find index of the object on the component channel */

  status = om$get_index( objid_c = my_id,
			 objid = go_obj->objid,
                         p_chanselect 	= &AC_mto_graf_chns,
                         indexaddr	=  (OMuint *) &i);
  if(!(status&1)) {return OM_S_SUCCESS;}


/* Find member name */

  nb_template_feet = 0;
  for(j=0;j<feet_num;j++)
    {
      if((feet[j].chan & 3)==feet_in_graphic && (feet[j].pos==i))
        {*suc=1; strcpy(footname,feet[j].name);break;}

      else if((feet[j].chan & 3)==feet_in_template)
	if(i==max_g_ft+nb_template_feet)
          {*suc=1; strcpy(footname,feet[j].name);break;}
 	else nb_template_feet++;
    }
  return(1);
}

method ACcontext_compute_feet(int count;
			struct GRid 	context_obj;
			struct GRid 	*feet_list;
			struct GRmd_env *md_env)
{
int status;
struct GRid *tlist = NULL;
int size,i,ibis;
IGRlong msg;
struct GRid ctx_ft,mac_def;
struct myfeet *feet_desc;

   /*"count entry %d\n",count */

   size=0;
   status = OM_S_SUCCESS;
   if(!IF_EQ_OBJID(context_obj.objid,NULL_OBJID))
   {
    /* Get feet of previous occurence */
    status =om$get_channel_count( osnum =context_obj.osnum,
				 objid =context_obj.objid ,
				p_chanselect = &AC_mto_graf_chns,
				count = (OMuint *) &size );

    /* If the context has no member take the context as member of my component
       It occurs with conditional with different depth in the ownership graph:
       For a condition value, a foot is a graphic object
       For another value, this foot is a construction 
    */
    if(status&1 && size)
    {
     tlist = (struct GRid *) om$malloc (size = (size) * sizeof( struct GRid ));
     ACread(context_obj, &AC_mto_graf_chns, tlist, size);
    }
    else
    {
     size = count;
     tlist = (struct GRid *) om$malloc (size = (size) * sizeof( struct GRid ));
     for(i=0;i<count;i++) tlist[i] = context_obj; 
    }
     

    /* get feet description used if missing templates */

    status = om$send(msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
    as$status(action = RET_STATUS);

    status = om$send( msg = message ACmacro_defn.ACgive_feet_desc(
                        &ibis, &feet_desc),
                      targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status( action = RET_STATUS );

    }


   for(i=0;i<count;i++)
    {
    if(!IF_EQ_OBJID(feet_list[i].objid,NULL_OBJID))
     {
     ctx_ft.objid=NULL_OBJID;
     if(i<size)
      {
      if(!pl_hold(tlist[i])) ctx_ft=tlist[i];
      }

     /* If not found, try to find another matching template */
      if(ctx_ft.objid == NULL_OBJID && size)
	{
	 char *c;
	 int feet_name_len;

	 feet_name_len = strlen(feet_desc[i].name); 
	 c = feet_desc[i].name + feet_name_len -1;
	 while(feet_name_len > 0 && *c >= '0' && *c <= '9') 
	     {c--; feet_name_len--;}
	   
	 for(ibis=0; /* ibis<count &&  */ ibis<size ; ibis++)
	  {
           if(i==ibis) continue;
	   if(pl_hold(tlist[ibis])) continue;
	   if(strncmp(feet_desc[i].name,feet_desc[ibis].name,feet_name_len) == 0)
	     {
/*"WARNING feet %s is context of %s\n",feet_desc[ibis].name,feet_desc[i].name*/
	      ctx_ft = tlist[ibis]; break;
	     } 
	  }
	}

       status = ACcontext_compute_component(&msg,feet_list+i,&ctx_ft,
					    feet_list+i,md_env);
       as$status( );
     }
    }

   if(size) om$dealloc(ptr = tlist);
  
  return (  status );
}
end implementation ACncpx;
