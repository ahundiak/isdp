/* $Id: graph.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / graph.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: graph.I,v $
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

class implementation NDnode;

#include <alloca.h>
#include "igrtypedef.h"
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "AS_status.h"
#include "GMerrordef.h"
#include "GMmacros.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmessages.h"
#include "msmacros.h"

#define AS_DEBUG

extern  int    NDgm_send();             /* Function to send messages          */
extern  int    NDgm_update();           /* Function to update the nodes       */
extern  int    NDacrej();               /* Function to select the nodes       */
extern  int    NDancestor();            /* Function to get the ancestors      */
extern  int    NDsuccessor();           /* Function to get the successors     */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function NDupdate_graph                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDupdate_graph(cn_type, root_compute, p_env, p_graph )
int cn_type;
int root_compute;
struct GRmd_env *p_env;
struct GMgraph *p_graph;

/*.NDupdate_graph */
{
 long status,loc_msg;
  static int            s_lanc=0;    /* Size of the ancestor list             */
  static struct GRid    *l_anc=0;    /* List of ancestors                     */
  static int            *l_state=0;  /* List of status                        */
  int            nb_anc=0;    /* Number of ancestors                          */
  int            desc;        /* Description of the query                     */
  short          type;        /* Type of elements to select                   */
  extern int     GMsel_and(); /* Function to select internal types            */
  struct GRid    object;      /* Object to update                             */
  struct GRid    new_id;      /* New object id after update                   */
  int el_type, int_cn_type;
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean save_br;
  int j;
  struct GRid null_grid;
  int stopped = FALSE;
  long return_code;
  int to_compute = 0;

  save_br = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;
  null_grid.objid = NULL_OBJID;

/* Update elements of the dependent graph */

    return_code = MSSUCC;
    desc = GM_FROM_BEGIN;
    gm$list_access_init( p_graph = p_graph,p_desc = &desc);


    type=ND_BODY|ND_ROOT|ND_EXTERN; 
    while(gm$list_access_next
           (select_fct   = GMsel_and,
            p_sel_info   = &type,
            p_graph      = p_graph,
            p_desc       = &desc,
           p_object      = &object)== GM_S_SUCCESS)
      {
  
      /*
       * 03/18/92 - JSD - need to ignore NULL_OBJID objects
       */

      if ( object.objid == NULL_OBJID ) continue;

      nd$get_type(nb_obj   = 1,
	          p_object = &object,
		  p_type   = &el_type,
		  p_graph  = p_graph);

/* MOMO 11-05-92
/* begin of the modif.
/* the state for extern object was not initialized. It should be to have
/* dependent receive ND_COMP_SAME as state of parent which are extern.
/**/

      if(el_type == ND_EXTERN)
       {
        loc_msg = ND_COMP_SAME;
        status = NDset_comp_state(&object,1,&loc_msg,p_graph);
	continue;
       }

      /*" Get parents of %d.%d\n", object.objid,object.osnum*/

      status = om$send
		 (msg      = message NDnode.NDget_objects
                             (ND_ROOT,l_anc,s_lanc,NULL,0,OM_K_MAXINT,&nb_anc),
    	          senderid = NULL_OBJID,
		  targetid = object.objid,
		  targetos = object.osnum);
      if(!(status&1)) continue;

/*
 * 09/30/92 - JSD - This is for TR 119220065 at Henry's request
 *                  It has something to do with delay update of
 *                  associative elements being on and merging profiles.
 *                  This message can fail and still be in a valid state.
 *    as$status();
 */


      /* Save the buffer */

      if(nb_anc > s_lanc)
        {
        /* realloc the lists */
        s_lanc = 10*(1 + nb_anc/10);
        if(l_anc) { free(l_anc); free(l_state);}
        l_anc = (struct GRid *)malloc(s_lanc*sizeof(struct GRid));
        l_state = (int *)malloc(s_lanc*sizeof(int));
        if(!l_anc || !l_state){status=GM_E_NODYNMEM;as$status();}
  
        status = om$send
		   (msg      = message NDnode.NDget_objects
                    (ND_ROOT,l_anc,s_lanc,NULL,0,OM_K_MAXINT,&nb_anc),
    	            senderid = NULL_OBJID,
		    targetid = object.objid,
		    targetos = object.osnum);
        as$status();
        if(!(status&1)) continue;
          /*" Get state of the element %d %d\n",object.objid,object.osnum*/
	}

      /*| Get the corresponding states */

      int_cn_type = cn_type;
      if(el_type & ND_BODY)
       {
	 int_cn_type = cn_type;
	 to_compute = 1;
	 status = NDget_comp_state(l_anc,nb_anc,l_state,p_graph);
        }
      else
        {
	 if(root_compute & ND_DONT_UPT_ROOT) to_compute = 0;
	 else if(root_compute & ND_UPT_ROOT) to_compute = 1;
	 else if(root_compute & ND_VAR_UPT)
	  {
           status = NDget_comp_state(&object, 1, &el_type,p_graph);
	   if(el_type  == ND_COMP ||
	      el_type  == ND_COMP_XF) 
	    {
              to_compute = 1;
	      if(el_type == ND_COMP_XF) int_cn_type |= el_type;
	    }
	  }
	 if(to_compute)
	 for(j=0;j<nb_anc;j++) l_state[j] = ND_COMP_SUCC;
	}
      /* end if */

      if(!stopped)
       {
        stopped = IGEstop();
        if(stopped)
	         {int_cn_type = ND_COMP_STOPPED; return_code = ND_COMP_STOPPED;}
       }

      if(to_compute)
       {
/*^{ int ijla;
   printf("%d %d computed with cn_type %x\nHis parents and state\n",
         object.objid,object.osnum,cn_type);
   for(ijla=0;ijla<nb_anc;ijla++)
   printf("%d %d state %x\n",l_anc[ijla].objid,l_anc[ijla].osnum,l_state[ijla]);
  }
*/
        status=om$send(msg = message NDnode.NDupdate
                    ((IGRint *)&loc_msg,int_cn_type,nb_anc,l_anc,l_state,
				         &null_grid,&new_id,p_env),
                     senderid = NULL_OBJID,
	             targetid = object.objid,
                     targetos = object.osnum);
/*"ret stat %x msg %x new_id %d %d\n",status,loc_msg,new_id.objid,new_id.osnum*/
        if(loc_msg == ND_COMP_REST) { return_code = ND_COMP_REST; break;}
        else if(!(loc_msg &1 )) return_code = loc_msg;

        if(GMgridcmp(&new_id,&object))
         {
          /* Update the new grid in the graph */
          status = GMreplace_grid(&object, &new_id, p_graph);
          as$status();
         }
	}
      else
	{
	 /*" %d %d not computed\n",object.objid,object.osnum*/
	  loc_msg = MSSUCC;
	  new_id = object;
	}

      /*| Store the state in the graph */

      if((el_type&ND_ROOT) && (loc_msg == ND_COMP_SAME)) loc_msg = ND_COMP_SUCC;
      status = NDset_comp_state(&new_id,1,&loc_msg,p_graph);
      as$status();
    } /* end while */
   
    ASbroadcast_in_progress = save_br;
    return return_code;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation NDnode;
