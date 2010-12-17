class implementation nci_macro;
/*--------------------------------------------------------------------------*/
/*
/*  nci_macroi.I
/*  robert patience
/*  5 sept 1989
/*
/* E BEEKER Feb '90
/* management of indexing converted in C
/*---------------------------------------------------------------------------
/* */

#define AS_DEBUG	/* debug pre-processor */

#include "ci_macro.h"

#include "memory.h"
#include "igrdef.h"    
#include "codef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "macro.h"
#include "DIdef.h"
#include "DIprims.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include <stdio.h>
#include "cierrordef.h" 
#include "ciexecmacros.h" 
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
from ACcpx_defn		import ACgive_feet_desc, ACintpt_foot,ACintpt_foot_dir,
			       ACgive_temp_desc, ACgive_name ;
from ACmacro_defn 	import ACgive_upscan;


extern GRclassid 	OPP_ASsource_class_id;
extern GRclassid    OPP_GRundo_class_id;

extern test_ci1();
extern run_ci();


/* ========================================================================= */


method user_func( 	char 		*entry;
 			struct GRmd_env *mod_env;
			char		*user_data)
{
  struct GRid		nci_macro_id;
  IGRint		status;

  status=om$send(msg = message nci_macro.ci_kl_user_func
		(entry,mod_env,user_data),
		      targetid = my_id  );
  if(status) return(status);


  if(test_ci1(entry, my_id,OM_Gw_current_OS,
	     &nci_macro_id, me->internal_buffer))
    {
    CIpushlist	arglist[2];
      		arglist[0].addr	= &mod_env		;
      		arglist[0].size = sizeof(mod_env)	;
      		arglist[1].addr = &user_data		;
      		arglist[1].size = sizeof(user_data )	;      
     ci$push( argc = 2, argv = arglist ) ;
     status=run_ci( entry,nci_macro_id );
    return(status);
    }
 
  return( 1 );
}

/* ========================================================================= */

method NDcopy ( IGRlong *msg;IGRint cp_type;
		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid )
{
  IGRint		status;
  struct GRid		nci_macro_id;

  if(test_ci1("NDcopy", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer ))
    {
    CIpushlist	arglist[5];
      		arglist[0].addr	= &msg		;
      		arglist[0].size = sizeof(msg)	;
      		arglist[1].addr	= &cp_type		;
      		arglist[1].size = sizeof(cp_type)	;
      		arglist[2].addr	= &fr_env		;
      		arglist[2].size = sizeof(fr_env)	;
      		arglist[3].addr	= &to_env		;
      		arglist[3].size = sizeof(to_env)	;
      		arglist[4].addr	= &newobjid		;
      		arglist[4].size = sizeof(newobjid)	;
    ci$push( argc = 5, argv = arglist ) ;
     status=run_ci("NDcopy" ,nci_macro_id );
    }
  else
   {
    /*|I am doing ov_ci_mac.NDcopy */
    status = om$send( mode = OM_e_wrt_message,
		      msg  = message ov_ci_mac.NDcopy
			(msg,cp_type,fr_env,to_env,newobjid),
		      targetid = my_id );
    as$status ( action = CONTINUE );
   }
/*^{ char *mac_name;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

     status = om$send(msg = message ACmacro_defn.ACgive_name(&mac_name),
                      targetid = mac_def.objid,
                      targetos = mac_def.osnum);
     printf("copy %d %d  macro name %s --> %d %d\n",my_id,OM_Gw_current_OS,
                newobjid->objid,newobjid->osnum,mac_name);
   }
*/



  return(status );
}

/* ========================================================================= */
method NDdelete( struct GRmd_env *md_env )
{
  IGRint		status;
  struct GRid		nci_macro_id;
  int     ret_mode;

  nd$mod_graph(request     = ND_INQ,
               p_ret_mode  = &ret_mode);

  if(test_ci1("NDdelete", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer ) && 
			(ret_mode & ND_NO_BROAD_DEL))
    {
    CIpushlist	arglist[1];
      		arglist[0].addr	= &md_env		;
      		arglist[0].size = sizeof(md_env)	;
    ci$push( argc = 1, argv = arglist ) ;
     status=run_ci("NDdelete" ,nci_macro_id );
    }
  else
   {
    /*|I am doing ov_ci_mac.NDdelete */
    status = om$send( mode = OM_e_wrt_message,
		      msg  = message ov_ci_mac.NDdelete(md_env),
		      targetid = my_id );
    as$status ( action = CONTINUE );
   }

  return(status );
}
/* ========================================================================= */

method NDgive_structure ( IGRlong *msg;struct ret_struct  *ptr_rst;
			  struct GRmd_env *md_env )
{
  IGRint		status;
  struct GRid		nci_macro_id;

  if(test_ci1("NDgive_structure", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer ))
    {
    CIpushlist	arglist[3];
      		arglist[0].addr	= &msg		;
      		arglist[0].size = sizeof(msg)	;
      		arglist[1].addr	= &ptr_rst		;
      		arglist[1].size = sizeof(ptr_rst)	;
      		arglist[2].addr	= &md_env		;
      		arglist[2].size = sizeof(md_env)	;
    ci$push( argc = 3, argv = arglist ) ;
    status=run_ci("NDgive_structure" ,nci_macro_id );
    }
  else
   {
    /*|I am doing ov_ci_mac.NDgive_structure */
    status = om$send( mode = OM_e_wrt_message,
		      msg  = message ov_ci_mac.NDgive_structure
			(msg,ptr_rst,md_env),
		      targetid = my_id );
    as$status ( action = CONTINUE );
   }

  return(status );
}
/* ========================================================================= */

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid; 
		      struct GRmd_env *md_env )
{

  IGRint		status;
  struct GRid		nci_macro_id;

  if(test_ci1("NDmove_to_root", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer ))
    {
    CIpushlist	arglist[3];
      		arglist[0].addr	= &msg		;
      		arglist[0].size = sizeof(msg)	;
      		arglist[1].addr	= &src_grid		;
      		arglist[1].size = sizeof(src_grid)	;
      		arglist[2].addr	= &md_env		;
      		arglist[2].size = sizeof(md_env)	;
    ci$push( argc = 3, argv = arglist ) ;
     status=run_ci("NDmove_to_root" ,nci_macro_id );
    }
  else
   {
    /*| I am doing ov_ci_mac.NDmove_to_root */
    status = om$send( mode = OM_e_wrt_message,
		    msg = message ov_ci_mac.NDmove_to_root
		    (msg,src_grid,md_env),
            	    targetid = my_id );
   }
   return(status);
}

/* ========================================================================= */

method ACgive_structure( int *suc,*direct_index; char *feet_name;
			 struct ret_struct  *ptr_rst; struct GRmd_env *md_env )
{

  IGRint		status;
  struct GRid		nci_macro_id;
  int			pos, chan, type;
  struct GRid		mac_def;

  status = om$send(msg = message ACcpx.find_macro(&mac_def),
		      targetid = my_id );
  as$status( action = RET_STATUS );
  status = om$send(msg= message ACcpx_defn.ACintpt_foot(suc,feet_name,
					&chan,&pos, &type),
		      targetid = mac_def.objid ,targetos = mac_def.osnum);
  as$status( action = RET_STATUS );

  if( ( chan == feet_virtual) )
       {
       status=om$send(msg = message nci_macro.ci_kl_ACgive_structure
		(suc,direct_index,feet_name,ptr_rst,md_env),
		      targetid = my_id  );
	if(status) return(status);
       } 

  if(( chan == feet_virtual) && 
		test_ci1("ACgive_structure", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer))
    {
    CIpushlist	arglist[5];
      		arglist[0].addr	= &suc		;
      		arglist[0].size = sizeof(suc)	;
      		arglist[1].addr	= &direct_index		;
      		arglist[1].size = sizeof(direct_index)	;
      		arglist[2].addr	= &feet_name		;
      		arglist[2].size = sizeof(feet_name)	;
      		arglist[3].addr	= &ptr_rst		;
      		arglist[3].size = sizeof(ptr_rst)	;
      		arglist[4].addr	= &md_env		;
      		arglist[4].size = sizeof(md_env)	;
     ci$push( argc = 5, argv = arglist ) ;
     status=run_ci("ACgive_structure" ,nci_macro_id );
    }
  else
   {
    /*| I am doing ov_ci_mac.NDmove_to_root */
    status = om$send( mode = OM_e_wrt_message,
		    msg = message ov_ci_mac.ACgive_structure
		    (suc,direct_index,feet_name,ptr_rst,md_env),
            	    targetid = my_id );
   }
   return(status);
}

/* ========================================================================= */
method GRlocate_owner
  (
  IGRlong  *msg;                   /* OUT                                     */
  struct GRlc_cvl *cvl;            /* IN                                      */
  struct GRlc_path *path;          /* IN                                      */
  IGRint   *pos                    /* OUT                                     */
  )
  {
  IGRint		status;
  struct GRid	nci_macro_id;
  int			ret;

/* printf(" GRlocate_owner before test_ci clok = %d\n", clock()/1000 );
 */


  ret = test_ci1( "GRlocate_owner", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer );

/* printf(" GRlocate_owner after test_ci clok = %d\n", clock()/1000 );
 */

  if( ret )  {
    CIpushlist	arglist[4];
      		arglist[0].addr	= &msg		;
      		arglist[0].size = sizeof(msg )	;
      		arglist[1].addr = &cvl		;
      		arglist[1].size = sizeof(cvl )	;      
      		arglist[2].addr = &path		;
      		arglist[2].size = sizeof (path)	;      
      		arglist[3].addr = &pos		;
      		arglist[3].size = sizeof (pos)	;      
     ci$push( argc = 4, argv = arglist ) ;
     status=run_ci( "GRlocate_owner",nci_macro_id );
    }
   else
    {
    status = om$send(msg = message ov_ci_mac.GRlocate_owner(msg,cvl,path,pos),
	              mode = OM_e_wrt_message,
		      targetid = my_id 
		     );
    }
  return (status);
  }/* end method GRlocowner */

/* ========================================================================= */

method GRxform( IGRlong *msg; struct GRmd_env *md_env;
	 	IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid )
{
  struct GRid	nci_macro_id;
  int 		status;
  *newobjid=my_id;
  status=0;

  if(test_ci1( "GRxform", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer ))
    {
    CIpushlist	arglist[5];
      		arglist[0].addr	= &msg		;
      		arglist[0].size = sizeof(msg )	;
      		arglist[1].addr = &md_env		;
      		arglist[1].size = sizeof(md_env )	;      
      		arglist[2].addr = &matrix_type		;
      		arglist[2].size = sizeof (matrix_type)	;      
      		arglist[3].addr = &matrix		;
      		arglist[3].size = sizeof (double *)	;      
      		arglist[4].addr = &newobjid		;
      		arglist[4].size = sizeof (newobjid)	;      
     ci$push( argc = 5, argv = arglist ) ;
     status = run_ci( "GRxform",nci_macro_id );
   }
  else
   {
    /*| I am going to ov_ci_mac.GRxform */
    status=om$send(msg= message 
		ov_ci_mac.GRxform(msg,md_env,matrix_type,matrix,newobjid),
		targetid=my_id,
                mode = OM_e_wrt_message);
   }
  return(status  );
}


/* ========================================================================= */


method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
	        struct GRparms *parms; IGRpoint point;
		struct IGRline *boreline; GRobjid *newobjid)
{
  struct GRid	nci_macro_id;
  int 		status;
  *newobjid=my_id;
  status=0;
  if(test_ci1( "GRmodify", my_id, OM_Gw_current_OS,
		&nci_macro_id, me->internal_buffer ))
   {
    CIpushlist	arglist[6];
      		arglist[0].addr	= &msg		;
      		arglist[0].size = sizeof(msg )	;
      		arglist[1].addr = &md_env		;
      		arglist[1].size = sizeof(md_env )	;      
      		arglist[2].addr = &parms		;
      		arglist[2].size = sizeof (parms)	;      
      		arglist[3].addr = &point		;
      		arglist[3].size = sizeof (point)	;      
      		arglist[4].addr = &boreline		;
      		arglist[4].size = sizeof (boreline)	;      
      		arglist[5].addr = &newobjid		;
      		arglist[5].size = sizeof (newobjid)	;      
     ci$push( argc = 6, argv = arglist ) ;
     status = run_ci( "GRmodify",nci_macro_id );
   }
  else
  {
    /*| I am going to ov_ci_mac.GRxform */
    status=om$send(msg= message 
		ov_ci_mac.GRmodify(msg,md_env,parms,point,boreline,newobjid),
		targetid=my_id,
                mode = OM_e_wrt_message);
   }
  return(  status  );
}


/* ========================================================================= */
/* modifications EB
/* 19 feb '90
/* introducing indexing in C to speed up give_foot and give_path 
/* Correction M.T 22 Mar 90 Wrong count -->wrong malloc ....
/* ========================================================================= */



get_conn_surf(solid, surf_list_id, surf_list_os)
struct GRid solid;
OM_S_OBJID *surf_list_id;
short *surf_list_os;
/*
 * EB 8 dec new version:
 * - does mallocs
 * - if NULL passed in surf_list_id, only returns the size
 */
/*.get_conn_surf*/
{
	int			  count, i, j, status;
	int			  size1, size2, maxsize;
	OM_S_CHANSELECT           cmp_chan;
	OM_S_OBJECT_LINKAGE       *ls_list1, *ls_list2;

        ls_list2 = NULL;
	size1 =0;
	status = om$make_chanselect (
               channame = "GRcmpowner.to_components",
               p_chanselect = &cmp_chan);
	as$status();

	status = om$get_channel_count (
	       osnum		= solid.osnum,
	       objid		= solid.objid,
               p_chanselect	= &cmp_chan,
               count		= (OMuint *)&size1);
	/* no status */

	if( size1 <= 0 || !(1&status ) )
		return -1;

	ls_list1 = ( OM_S_OBJECT_LINKAGE *)
				malloc(size1*sizeof(OM_S_OBJECT_LINKAGE ));
	status = om$get_channel_objects
             (
	      osnum		= solid.osnum,
	      objid		= solid.objid,
              p_chanselect	= &cmp_chan,
              list		= ls_list1,
	      size		= size1, 
	      count		= (OMuint *)&j);
	as$status();

	/*"get_conn_surf after get_channel_objects j = %d\n", j*/

	if( j != size1 || !(1&status ) )
		return -1;

	/*| get the max size for malloc */
	maxsize = 0;
        count=0;
	for(i=0; i<size1; i=i+1){
		j = 0;
		status = om$get_channel_count (
		       osnum		= ls_list1[i].osnum,
 		       objid		= ls_list1[i].S_objid,
        	       p_chanselect	= &cmp_chan,
	               count		= (OMuint *)&j);

	/*"get_conn_surf after get_channel_count %d  size=%d\n",i, j */

		if( j <= 0  || !(1&status ) ){
                        count=count+1;
			continue;
                }
                count=count+j;
		if( maxsize < j )
			maxsize = j;
	}
        if( surf_list_id == NULL ){
                free(ls_list1);
		return count;
        }

	if( maxsize > 0 )
		ls_list2 = ( OM_S_OBJECT_LINKAGE *)
				malloc(maxsize*sizeof( OM_S_OBJECT_LINKAGE ));

	/*| see if we must go down one more level */
	count = 0;
	for(i=0; i<size1; i=i+1){
		size2 = 0;
		status = om$get_channel_count (
		       osnum		= ls_list1[i].osnum,
 		       objid		= ls_list1[i].S_objid,
        	       p_chanselect	= &cmp_chan,
	               count		= (OMuint *)&size2);

		if( size2 > 0  && (1&status ) ){
		  status = om$get_channel_objects
        	     (
		      osnum		= ls_list1[i].osnum,
		      objid		= ls_list1[i].S_objid,
	              p_chanselect	= &cmp_chan,
        	      list		= ls_list2,
		      size		= size2, 
		      count		= (OMuint *)&j);

		  if( j != size2 || !(1&status ) )
			size2 = 0;
		} else
			size2 = 0;

		if( !size2 ){
			/* take the object itself */
			if( surf_list_id != NULL ){
			   surf_list_id[count] = ls_list1[i].S_objid;
			   surf_list_os[count] = ls_list1[i].osnum;
			}
			count = count+1;
		} else for(j=0; j<size2; j=j+1){
			if( surf_list_id != NULL ){
			   surf_list_os[count] = ls_list2[j].osnum;
			   surf_list_id[count] = ls_list2[j].S_objid;
			}
			count = count+1;
		}
	}

	if(ls_list1 != NULL) free( ls_list1 );
	if( maxsize > 0 )
		free( ls_list2 );

	return count;
}

get_surf_at_index(solid, ix, surf_id )
struct GRid solid, *surf_id;
int ix;
/*
 * returns the surface id given its index in a solid
 * on error return 0 and NULL_OBJID
 * uses get_conn_surf
 */
/*.get_surf_at_index*/
{
	int		size;
	OM_S_OBJID	*surf_list_id;
	short		*surf_list_os;

	surf_list_id = NULL;
	surf_list_os = NULL;
	size = get_conn_surf(solid, surf_list_id, surf_list_os);

	if( ix < 0 || ix >= size || size < 0 /* error */ ){
		surf_id->objid =  NULL_OBJID;
		return 0;
	}

	surf_list_id = ( OM_S_OBJID *)malloc( size * sizeof(OM_S_OBJID));
	surf_list_os = ( short *)malloc( size * sizeof(short));

	get_conn_surf(solid, surf_list_id, surf_list_os);

	surf_id->objid =  surf_list_id[ix];
	surf_id->osnum =  surf_list_os[ix];

	if(surf_list_id != NULL) free( surf_list_id );
	if(surf_list_os != NULL) free( surf_list_os );

	return 1;
}

get_index_of_surf(solid, ix, surf_id )
struct GRid solid, surf_id;
int *ix;
/*
 * returns the index of a given surface in a solid
 * if not found returns -1
 * uses get_conn_surf
 */
/*.get_index_of_surf*/
{
	int		size, i;
	OM_S_OBJID	*surf_list_id;
	short		*surf_list_os;

	surf_list_id = NULL;
	surf_list_os = NULL;
	/*"get_index_of_surf for sol %d %d  surf %d %d\n",solid.objid,solid.osnum,surf_id.objid,surf_id.osnum */
	size = get_conn_surf(solid, surf_list_id, surf_list_os);

	/*"get_index_of_surf, after get_conn_surf, size = %d\n", size */

	*ix = -1;	/* error returned value */
	if(  size < 0 /* error */ ){
		return 0;
	}

	surf_list_id = ( OM_S_OBJID *)malloc( size * sizeof(OM_S_OBJID));
	surf_list_os = ( short *)malloc( size * sizeof(short));
	get_conn_surf(solid, surf_list_id, surf_list_os);

	for(i=0; i<size; i=i+1 ){
	  /*"compare with surf %d %d\n",surf_list_id[i],surf_list_os[i]*/
		if( surf_id.objid ==  surf_list_id[i]
		 && surf_id.osnum ==  surf_list_os[i] ){
			*ix = i;
			break;
		}
	}
	if(surf_list_id != NULL) free( surf_list_id );
	if(surf_list_os != NULL) free( surf_list_os );

	/*"get_index_of_surf, returning ix = %d\n", *ix  */
}


method ACreturn_foot(long *suc;char *foot_name; struct GRid *foot_GRid;
		     IGRshort *mat_type; IGRdouble *matrix)
{
	int ix;		/* index */
	int sts,loc_msg;
	OM_S_CHANSELECT chansel;
	struct GRid pied;

        *suc = 0;

	if( foot_name[0] != '$' ){
		return om$send( msg = message ov_ci_mac.ACreturn_foot
					( suc, foot_name, foot_GRid,
					  mat_type, matrix),
		         targetid = my_id,
                         mode = OM_e_wrt_message);
	}

	chansel.type = OM_e_name;
	chansel.u_sel.name = "GRcmpowner.to_components";

	/**** must find real feet 
	/**** we assume this is the 1st one on the channel to_component
	/* */
	pied.objid = NULL_OBJID;
	sts = om$get_objid_at_index
			     ( object =		me,
                               p_chanselect =	&chansel,
                               index =		0,
                               objidaddr = 	&pied.objid,
                               osnumaddr = 	&pied.osnum);
	if(!(1&sts) )
		return sts;
	if( pied.objid == NULL_OBJID )
		return *suc = 0;

	ix = -1;
	sscanf(&foot_name[1],"%d", &ix );
	if( !get_surf_at_index(pied, ix, foot_GRid ) )
		return *suc = 0;


	/*"ci_mac_bib.ACgive_foot, foot:%d %d\n",foot_GRid->objid,
				foot_GRid->osnum */

	if(mat_type) *mat_type = MAIDMX;
	if(matrix) MAidmx(&loc_msg,matrix);

	*suc = 1; /*return real graphic object */

	return(sts);
}
/* ========================================================================= */

method ACgive_path(int *suc;struct GRid *go_obj;char *foot_name)
{
	int i,sts;
	struct GRid pied;
	OM_S_CHANSELECT chansel;

	chansel.type = OM_e_name;
	chansel.u_sel.name = "GRcmpowner.to_components";

	/**** must find pied see give_foot ****/
	pied.objid = NULL_OBJID;
	sts = om$get_objid_at_index
			     ( object =		me,
                               p_chanselect =	&chansel,
                               index =		0,
                               objidaddr = 	&pied.objid,
                               osnumaddr = 	&pied.osnum);
/*
	AF : BAD :
	if( 1&sts && pied.objid != NULL_OBJID )
	SHOULD BE :
	if( (1&sts) && pied.objid != NULL_OBJID )
*/
	if( (1&sts) && pied.objid != NULL_OBJID ){
	    /*| get the index of the object go_obj*/
	    get_index_of_surf(pied, &i, *go_obj );
	    if( i != -1 ){
	        sprintf(foot_name,"$%d", i );
	        /*"ACgivepath, foot_name created: %s\n ",foot_name */
	        return ( *suc =OM_S_SUCCESS );
	    }
	}

	/**"ACgivepath failed, call normal message \n"**/
	return om$send(msg= message ov_ci_mac.ACgive_path
						(suc,go_obj,foot_name),
			targetid=my_id,
                	mode = OM_e_wrt_message);
}



/* ========================================================================= */


method NDmake_source(IGRlong *msg;
			struct GRid *located_obj,*context;char *path;
			GRspacenum as_osnum; struct GRid *as)
{
  struct GRid	nci_macro_id;
  int 		status;

  status=0;

  if(test_ci1( "NDmake_source", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer ))
    {
    CIpushlist	arglist[6];
      		arglist[0].addr	= &msg			;
      		arglist[0].size = sizeof(msg )		;
      		arglist[1].addr = &located_obj		;
      		arglist[1].size = sizeof(located_obj)	;      
      		arglist[2].addr = &context		;
      		arglist[2].size = sizeof (context)	;      
      		arglist[3].addr = &path			;
      		arglist[3].size = sizeof (path)		;      
      		arglist[4].addr = &as_osnum		;
      		arglist[4].size = sizeof (as_osnum)	;      
      		arglist[5].addr = &as			;
      		arglist[5].size = sizeof (as)		;      
     ci$push( argc = 6, argv = arglist ) ;
     status = run_ci( "NDmake_source",nci_macro_id );
   }
  else
   {
    /*| I am going to ov_ci_mac.NDmake_source */
    status=om$send(msg= message 
		ov_ci_mac.NDmake_source(msg, located_obj, context, path,
					as_osnum, as),
		targetid=my_id,
                mode = OM_e_wrt_message);
   }
  return(status  );
}

/* ========================================================================= */


method NDdrawing_copy_geom
                (struct GRid *selected_elements;
                 int    nb_elements;
                 struct GRid **drawing_elements;
                 int    *nb_drawing_elem;
                 double *vector,*point;
                 int *level; struct IGRlbsys *lbs;
                 struct GRmd_env *from_env,*to_env)

{
  IGRint		status;
  struct GRid		nci_macro_id;

  if(test_ci1("NDdrawing_copy_geom", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer ))
    {
    CIpushlist	arglist[10];
      		arglist[0].addr	= &selected_elements	;
      		arglist[0].size = sizeof(selected_elements);
      		arglist[1].addr	= &nb_elements		;
      		arglist[1].size = sizeof(nb_elements)	;
      		arglist[2].addr	= &drawing_elements		;
      		arglist[2].size = sizeof(drawing_elements)	;
      		arglist[3].addr	= &nb_drawing_elem;
      		arglist[3].size = sizeof(nb_drawing_elem)	;
      		arglist[4].addr	= &vector		;
      		arglist[4].size = sizeof(vector)	;
      		arglist[5].addr	= &point		;
      		arglist[5].size = sizeof(point)	;
      		arglist[6].addr	= &level		;
      		arglist[6].size = sizeof(level)	;
      		arglist[7].addr	= &lbs		;
      		arglist[7].size = sizeof(lbs)	;
      		arglist[8].addr	= &from_env		;
      		arglist[8].size = sizeof(from_env)	;
      		arglist[9].addr	= &to_env		;
      		arglist[9].size = sizeof(to_env)	;
    ci$push( argc = 10, argv = arglist ) ;
     status=run_ci("NDdrawing_copy_geom" ,nci_macro_id );
    }
  else
   {
    /*|I am doing ov_ci_mac.NDcopy */
    status = om$send( mode = OM_e_wrt_message,
		      msg  = message ov_ci_mac.NDdrawing_copy_geom
                			(selected_elements, nb_elements,
                 			drawing_elements, nb_drawing_elem,
                 			vector,point, level, lbs,
					from_env, to_env),
		      targetid = my_id );
    as$status ( action = CONTINUE );
   }
  return(status );
}

/* ========================================================================= */
/*
 * Method :
 *
 *      GRdrop
 *
 * Abstract :
 *
 *      This routine drops a macro and calls the PDM hooks.
 *
 * Arguments :
 *
 *      *msg        IGRlong         return code.
 *      *mod_env    struct GRmd_env module environment.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     10/15/93 Added override for PDM Delete Hooks.
 *
 */
method GRdrop(IGRlong *msg; struct GRmd_env *md_env)
{
    IGRlong om_msg = OM_S_SUCCESS;
    struct GRid macro_id;
 
    *msg = MSSUCC;
    
    macro_id.objid = my_id;
    macro_id.osnum = OM_Gw_current_OS;
 
    /*
     * If this isn't a NULL module environment...
     */
    if (md_env->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to drop the macro.
         */
        if (!PDMpre_delete (&macro_id, md_env))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & 1)
    {
        /*
         * Drop the macro.
         */
        om_msg = om$send (msg = message ov_ci_mac.GRdrop (msg, md_env),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
        
        /*
         * If this isn't a NULL module environment...
         */
        if ((om_msg & *msg & 1) && (md_env->md_id.objid != NULL_OBJID))
        {
            /*
             * Notify PDM that the macro has been dropped.
             */
            PDMpost_delete (&macro_id, md_env);
        }
    }
    
    return om_msg;
}

/* ========================================================================= */
 
/*
 * Method :
 *
 *      ACdrop
 *
 * Abstract :
 *
 *      This routine drops a macro. This override will call the
 *      PDM hooks for delete.
 *
 * Arguments :
 *
 *      *mod_env    struct GRmd_env module environment.
 *
 * History :
 *
 *      Jay Wallingford     10/15/93 Creation.
 *
 */
method ACdrop (struct GRmd_env * mod_env)
{
    IGRlong om_msg = OM_S_SUCCESS;
    struct GRid macro_id;

    /*
     * If this isn't a delete of a dynamic copy ...
     */
    if (mod_env->md_id.objid != NULL_OBJID)
    {
        macro_id.objid = my_id;
        macro_id.osnum = OM_Gw_current_OS;
        
        /*
         * Make sure it's ok with PDM to delete this macro.
         */
        if (!PDMpre_delete (&macro_id, mod_env))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & 1)
    {
        /*
         * Drop the macro.
         */
        om_msg = om$send (msg = message ACcpx.ACdrop (mod_env),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a delete of a dynamic copy ...
         */
        if (mod_env->md_id.objid != NULL_OBJID)
        {
            /*
             * Notify PDM that the macro has been deleted.
             */
            PDMpost_delete (&macro_id, mod_env);
        }
    }
    
    return om_msg;
}

/*
 * Method :
 *
 *      GRdelete
 *
 * Abstract :
 *
 *      This routine deletes a macro. This override will call the
 *      PDM hooks for delete.
 *
 * Arguments :
 *
 *      *msg        IGRlong         return code.
 *      *mod_env    struct GRmd_env module environment.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     10/15/93 Creation.
 *
 */
method GRdelete (IGRlong * msg; struct GRmd_env * mod_env)
{
    IGRlong om_msg = OM_S_SUCCESS;
    struct GRid macro_id;

    *msg = MSSUCC;
    
    /*
     * If this isn't a delete of a dynamic copy ...
     */
    if (mod_env->md_id.objid != NULL_OBJID)
    {
        macro_id.objid = my_id;
        macro_id.osnum = OM_Gw_current_OS;
        
        /*
         * Make sure it's ok with PDM to delete this macro.
         */
        if (!PDMpre_delete (&macro_id, mod_env))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & 1)
    {
        /*
         * Delete the macro.
         */
        om_msg = om$send (msg = message ASnode.GRdelete (msg, mod_env),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a delete of a dynamic copy ...
         */
        if (mod_env->md_id.objid != NULL_OBJID)
        {
            /*
             * Notify PDM that the macro has been deleted.
             */
            PDMpost_delete (&macro_id, mod_env);
        }
    }
    
    return om_msg;
}

/*
 * Method :
 *
 *      GRcopy
 *
 * Abstract :
 *
 *      This method copies a macro to the object space described
 *      in the structure new_dsenv. It will also call the PDM hooks
 *      for copy.
 *
 * Arguments :
 *
 *      *obj_dsenv  GRmd_env      struct describing object's environment
 *      *new_dsenv  GRmd_env      struct describing copy's environment
 *      msg         IGRlong       completion code
 *      *newobjid   GRobjid       objid of the copied object
 *
 * Return Values :
 *
 *      MSSUCC if successful
 *  MSFAIL (severe) if failure
 *
 * History :
 *
 *      Jay Wallingford     10/15/93  Creation data.
 *
 */
method GRcopy (IGRlong *msg;
               struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv;
               GRobjid * newobjid)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         macro_id;
    
    *msg = MSSUCC;

    macro_id.objid = my_id;
    macro_id.osnum = OM_Gw_current_OS;

    /*
     * If this isn't a dynamic copy ...
     */
    if (new_dsenv->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to copy the macro.
         */
        if (!PDMpre_copy (&macro_id, obj_dsenv, new_dsenv))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & *msg & 1)
    {
        /* 
         * Copy the macro.
         */
        om_msg = om$send (msg = message ACcpx.GRcopy (msg,
                                                      obj_dsenv,
                                                      new_dsenv,
                                                      newobjid),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a dynamic copy ...
         */
        if ((om_msg & *msg & 1) && (new_dsenv->md_id.objid != NULL_OBJID))
        {
            struct GRid new_macro_id;
            
            new_macro_id.objid = *newobjid;
            new_macro_id.osnum = new_dsenv->md_id.osnum;
            
            /*
             * Notify EDM that the macro has been copied.
             */
            PDMpost_copy (&macro_id, &new_macro_id, obj_dsenv, new_dsenv);
        }
    }

    return om_msg;
}

/*
 * Method :
 *
 *      GRcptform
 *
 * Abstract :
 *
 *      This method copies and transforms a macro to the object space described
 *      in the structure new_dsenv.
 *
 * Arguments :
 *
 *      msg         IGRlong       completion code
 *      *obj_dsenv  GRmd_env      struct describing object's environment
 *      *new_dsenv  GRmd_env      struct describing copy's environment
 *      matrix      IGRmatrix     transformation matrix
 *      *newobjid   GRobjid       objid of the copied object
 *
 * Return Values :
 *
 *      MSSUCC if successful
 *  MSFAIL (severe) if failure
 *
 * History :
 *
 *      Jay Wallingford     10/15/93  Creation data.
 *
 */
method GRcptform(IGRlong         * msg;
                 struct GRmd_env * obj_dsenv;
                 IGRmatrix         matrix;
                 struct GRmd_env * new_dsenv;
                 GRobjid         * newobjid)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         macro_id;
    
    *msg = MSSUCC;

    macro_id.objid = my_id;
    macro_id.osnum = OM_Gw_current_OS;

    /*
     * If this isn't a dynamic copy ...
     */
    if (new_dsenv->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to copy the macro.
         */
        if (!PDMpre_copy (&macro_id, obj_dsenv, new_dsenv))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & *msg & 1)
    {
        /* 
         * Copy and transform the macro.
         */
        om_msg = om$send (msg = message GRgraphics.GRcptform (msg,
                                                              obj_dsenv,
                                                              matrix,
                                                              new_dsenv,
                                                              newobjid),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a dynamic copy ...
         */
        if ((om_msg & *msg & 1) && (new_dsenv->md_id.objid != NULL_OBJID))
        {
            struct GRid new_macro_id;
            
            new_macro_id.objid = *newobjid;
            new_macro_id.osnum = new_dsenv->md_id.osnum;
            
            /*
             * Notify EDM that the macro has been copied.
             */
            PDMpost_copy (&macro_id, &new_macro_id, obj_dsenv, new_dsenv);
        }
    }

    return om_msg;
}

/*
 * Method :
 *
 *      GRchgname
 *
 * Abstract :
 *
 *      This method changes the name for the element in the current 
 *      directory. The override is intended to stop the object from
 *      being named during a delete for undo if it's a PDM part.
 *
 * Arguments :
 *
 *      *msg              IGRlong            Return code.
 *      name              GRname             Name of the object.
 *
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 *
 */
method GRchgname ( IGRlong * msg; 
                   struct GRmd_env * env;
                   IGRchar * name )
{
    IGRint  om_msg = OM_S_SUCCESS;
    struct GRid my_grid;
    
    *msg = MSSUCC;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    /*
     * If this is a PDM part and PDM isn't loaded and this is being done 
     * for undo delete don't allow the name to be changed.
     */
    if (!strncmp(name, ".deleted_", 9) && 
        PDMpart_check(&my_grid))
    {
        goto quit;
    }
    
    om_msg = om$send (msg = message ACncpx.GRchgname (msg, env, name),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

 quit:
    
    return om_msg;
}

/*
 * Method :
 *
 *      GRflexconn
 *
 * Abstract :
 *
 *      This method will connect this macro flexible to an owner.
 *      The override is intended to prevent a PDM macro part from
 *      being connected to the undo object.
 *
 * Arguments :
 *
 *      *msg              IGRlong           Return code
 *      *flag             IGRlong           Flag 
 *      *owners_id        struct GRid       The owners objid, osnum
 *      *owners_index     IGRlong           The index on the flexible
 *                                          owners channel
 *      *graphics_index   IGRlong           The index on the graphics
 *                                          object channel
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 */
method GRflexconn ( IGRlong *msg; 
                    IGRlong *flag; 
                    struct GRid *owners_id; 
                    IGRlong *owners_index; 
                    IGRlong *graphics_index )
{
    IGRlong           om_msg = OM_S_SUCCESS;
    struct GRid       macro;
    
    macro.objid = my_id;
    macro.osnum = OM_Gw_current_OS;
    
    /*
     * If this is a PDM part and PDM isn't loaded ...
     */
    if (PDMpart_check(&macro) && !PDMloaded())
    {
        OMuword classid;
        
        if (om$get_classid (objid = owners_id->objid,
                            osnum = owners_id->osnum,
                            p_classid = &classid) & 1)
        {
            /*
             * If this is being done for a delete undo, don't allow it ...
             */
            if (om$is_ancestry_valid (superclassid = OPP_GRundo_class_id,
                                      subclassid = classid) == OM_S_SUCCESS)
            {
                *msg = MSFAIL;
                goto quit;
            }
        }
    }
    
    om_msg = om$send (msg = message GRconnector.GRflexconn (msg, 
                                                            flag, 
                                                            owners_id,
                                                            owners_index,
                                                            graphics_index),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
 quit:
    
    return(om_msg);
}

end implementation nci_macro;
