class implementation VLpcAbst;

#include "AS_status.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"


/* *********************** MSG ACconsume () ***************************	*/

method ACconsume(IGRlong *msg;char *footname;
	int cpy_req;struct GRid *cpy_GRid;struct GRmd_env *md_env)
{
long status;
char            old_ASbroad;
extern char     ASbroadcast_in_progress;

struct GRmd_env from_env;
enum GRdpmode mode;
long		sts;

  // consume pretend
  if('.'!= footname[0] &&  0!= footname[0])
  {
   status = om$send(msg = message ACncpx.ACindex_in
	(footname,message NDmacro.ACconsume(msg,"",cpy_req,cpy_GRid,md_env)),
		       targetid = my_id);
   as$status( );
   return(status);
  }

    /* Initialize md_env for copy and range */
    from_env.md_id.objid = md_env->md_id.objid;
    from_env.md_id.osnum = OM_Gw_current_OS;
    MAidmx(msg,from_env.md_env.matrix);
    from_env.md_env.matrix_type = MAIDMX;

  // copy element if necessary
  if(*msg !=0 && cpy_req)
   {
    old_ASbroad = ASbroadcast_in_progress;
    ASbroadcast_in_progress = 1;
     
      status = om$send( msg = message GRgraphics.GRcopy
        (msg,&from_env,md_env,&(cpy_GRid->objid)),
                targetid = my_id );
      as$status( );
      cpy_GRid->osnum= md_env->md_id.osnum;

    /*" cpy.objid %d \n",go.objid,cpy_GRid->objid  */
    ASbroadcast_in_progress = old_ASbroad;
   }

	// display off
	mode	= GRbehe;
	sts = om$send(	msg	 = message GRgraphics.GRdisplay(
					msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&mode,
					&from_env.md_id ),
			targetid = my_id );
	as$status( sts = sts );

	// place element out of range Tree
	sts = om$send(	msg	= message GRgraphics.GRremwrng
					 ( msg, &from_env ),
			targetid = my_id );
//	as$status( sts = sts ); 	I am not always in RT

	// set macro properties
  status = om$send(msg = message ACncpx.ACntf_consume(msg),
                targetid = my_id );
  as$status( );
  me->STATE = (me->STATE ) | (ncpx_consumed);

return	OM_S_SUCCESS;
}

method ACunconsume(IGRlong *msg;char *footname)
{

long status;
struct GRmd_env wk_env;
IGRlong 		S1,S2;
long			loc_msg;

  // unconsume pretend
  if('.'!= footname[0] &&  0!= footname[0])
  {
   status = om$send(msg = message ACncpx.ACindex_in
	(footname,message NDmacro.ACunconsume(msg,"")),
		       targetid = my_id);
   as$status( );
   return(status);
  }

  // unconsume myself
  S1 = sizeof (struct GRmd_env);
  status = gr$get_module_env(	msg    = &loc_msg,
                    		sizbuf = &S1,
                    		buffer = &wk_env,
                    		nret   = &S2 );
  as$status(action = RET_STATUS );

  wk_env.md_id.osnum	= OM_Gw_current_OS;

  // remove macro properties
  me->STATE &= (~ncpx_consumed);
  if(me->STATE & ncpx_missing)
   {
     status = om$send(msg =message NDnode.NDs_compute_node
		   (msg,ND_COMP,&wk_env),targetid =my_id);
     as$status( );
  
    me->STATE &= (~ncpx_missing);
   }

   // display on need to be done but not matrix is given.

  // place myself in range Tree
  om$send( msg = message GRgraphics.GRaddwrng( msg, &wk_env ),
	   targetid = my_id );

return	OM_S_SUCCESS;
}

/* *********************** MSG NDupdate () ****************************	*/

method NDupdate(int *msg, cn_type, count;
                struct GRid *parents;
                int *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
long	sts;
	
	if( me->STATE & ncpx_consumed )
		cn_type |=	ND_COMP_NO_DISPLAY |
				ND_COMP_NO_ADD_RT  |
				ND_COMP_NO_ERASE   |
				ND_COMP_NO_REM_RT;


	sts = om$send(	msg	 = message ACncpx.NDupdate(
						msg,
						cn_type,
						count, parents,
						parent_state,
						context, new_objid,
						md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
return	sts;
}

end implementation VLpcAbst;

