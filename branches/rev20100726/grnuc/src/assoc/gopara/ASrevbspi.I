class implementation ASrevbsp;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "msdef.h"
#include "grerr.h"
#include "asbox.h"
#include "grownmacros.h"
#include "ASmsg.h"
#include "msmacros.h"

#define   AS_DEBUG   1           /* For debug preprocessor                    */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDplace                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace 
  (
  struct GRas *asso_lis;
  struct GRmd_env *md_env;
  IGRchar *go_cnst_lis 
  )

  {
IGRlong status,msg;
IGRlong index;
struct GRid my_grid,*parents;

/* This element is created for support only */

me->state = ND_SUP_ONLY;


my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;

parents = asso_lis->parents;

  status = ASrevbsp_evaluate(parents,md_env,my_grid,&asso_lis->go_objid);

  index = 0;
  status=om$send(msg=message GRconnector.GRrigidconn( &msg, &my_grid, &index ),
                    targetid = asso_lis->go_objid.objid,
                    targetos = asso_lis->go_objid.osnum );
  as$status(action = RET_STATUS);
 if(!msg&1)
   {
    if( msg == GRRIGIDEXISTS ) printf("Il existe deja un rigid owner\n");
    if( msg == GRNOCONNECT )   printf("Erreur du aux flexibles owners\n");
    if( msg == MSFAIL)            printf("error in the GRrigidconn\n");
   }


  status = om$send (msg      = message NDnode.NDconnect(asso_lis->num_parents,
                                 		    parents,NULL_GRID,ND_NEW),
              targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
 }


#argsused
ASrevbsp_evaluate(list,md_env,as_grid,go_grid)
struct GRid *list;
struct GRmd_env *md_env;
struct GRid as_grid,*go_grid;

/*.evaluate*/
{
struct GRmd_env sup_env;
OM_S_OBJID save_env;
struct GRid sup_go,active_owner;
extern IGRboolean ASbroadcast_in_progress;
IGRboolean old_broad;
IGRlong status,msg,actmsg;

  /* Copy the support */

  status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
						   &sup_env.md_env.matrix_type,
						    sup_env.md_env.matrix),
		  senderid = NULL_OBJID,
		  targetid = list[0].objid,
		  targetos = list[0].osnum);
  as$status(action = RET_STATUS);

  old_broad = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);

       
/* problem with GRcopy of composite */

  msg = MSSUCC;
  sup_env.md_id = md_env->md_id;
  
  save_env = md_env->md_id.objid;
  md_env->md_id.objid = NULL_OBJID;
 
  status = om$send(msg          = message GRgraphics.GRcopy(&msg,
                                  	      &sup_env,md_env, &go_grid->objid),
		   senderid = NULL_OBJID,
		   targetid = sup_go.objid,
		   targetos = sup_go.osnum);
  as$status(action = GOTO_VALUE,
	    value  = wrapup);
  go_grid->osnum=md_env->md_id.osnum;

  /* reverse the geometry */

  status = om$send(msg          = message GRcurve.GRrevparm(&msg, md_env),
		   senderid = NULL_OBJID,
		   targetid = go_grid->objid,
		   targetos = go_grid->osnum);
  as$status(action = GOTO_VALUE,
	    value  = wrapup);
 
  wrapup :
  md_env->md_id.objid = save_env;
  ASbroadcast_in_progress = old_broad;
  if(actmsg == MSSUCC) gr$put_active_owner ( msg=&actmsg,active_owner=&active_owner);


  return(status);
 }


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDcompute_node                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node
  (
  IGRlong *msg;IGRint cn_type;
  int count;                     /* IN     Number of parents of the modifier  */
  struct GRid list_par[];        /* IN     List of the parents of the modifier*/
  struct GRmd_env *md_env;      /* IN     Information about the environment  */
  )

  {
   struct GRid my_grid,go_grid,old_grid;
   IGRshort set,set_props;
   IGRlong status;

   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;


   /* evaluate and construct a new one */

   status = ASrevbsp_evaluate(list_par,md_env,my_grid,&go_grid);

   if(status&1)
    {

     set = 0;
     set_props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     status = om$send(msg = message GRgraphics.GRchgprops(msg,&set,
							   &set_props),
		      targetid = go_grid.objid,
		      targetos = go_grid.osnum);
     as$status();
   
      /*| delete previous go and connecte new one */

     status= om$get_objid_at_index(	objid 		= my_id,
				p_chanselect 	= &AS_to_comp,
				index 		= 0,
				objidaddr 	= &old_grid.objid,
				osnumaddr	= &old_grid.osnum );
     as$status();
     status= om$send( msg = message Root.move_chan( AS_to_owner,
			old_grid.objid, OM_Gw_current_OS, AS_to_owner ),
  	         targetid = go_grid.objid );
     as$status();
    
     status= om$send( msg = message GRgraphics.GRdelete(msg,md_env),
		    targetid = old_grid.objid );
     as$status();
    }

   return(OM_S_SUCCESS);
  }/* end of NDcompute_nod method */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 4                      /* Number maximum of parents       */
#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */

  /* Get the name of this object */
  as$printer_set_name(prefix="REV_BSP",name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and symbology */
  as$printer_print_parents(count=&count);
  /* as$printer_print_symb(); */
  
  fprintf(stream,"send ASrevbsp.place(%d,list,ptr) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end print */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRgetobjinfo                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo
  (
  IGRlong *msg;                  /* OUT    Message returned                   */
  struct GRobj_info *info        /* OUT    Information about the graph. obj   */
  )

  {
  *msg = MSSUCC;
  ex$message( buff=info->type,
	      msgnumb=AS_I_BspRvGmt);
  return(OM_S_SUCCESS);
}/* end method GRgetobjinfo */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASrevbsp;

