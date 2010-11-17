/* $Id: ACpretendi.I,v 1.4.4.1 2004/03/29 16:27:39 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/ACpretendi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACpretendi.I,v $
 *	Revision 1.4.4.1  2004/03/29 16:27:39  ahundiak
 *	ah
 *
 *	Revision 1.4  2001/04/03 15:22:09  ramarao
 *	Fixed TR# 4527
 *	
 *	Revision 1.3  2001/03/07 16:26:02  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/02/22 22:48:42  ahundiak
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  2000/03/08  18:16:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/08/00  ah	     Added Header
 *                   Added ACfind_parent with better error messages
 * 02/22/01  ah      Readded ASreturn_go with VDlog messages
 * 04/03/01  RR	     Fixed TR# 4527.
 * 03/03/04  ah      Suppressed warning message
 ***************************************************************************/
/*
  ACpretendi.I
  robert patience
  21_jul_86

  History :

	01/17/95	R. Manem	Suppress error message about
					bend_sweep
        02/08/99        ah              Better error message
*/
class implementation ACpretend;

#include "ASmacroi.h"

#include "macro.h"
#include "madef.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#include "VDlog.h"

/*
#define AS_DEBUG
*/

/* states of pretends bad implementation but to late now */

/* ========================================================================= */
/* Added objid to the error message */
method ACfind_parent(struct GRid *father;IGRshort *mat_type;IGRdouble *matrix)
{
int status,size,msg;

   status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_template_chns,
				count = (OMuint *)&size );
   as$status( action = RET_STATUS );

   if(size!=1)
   {
    printf("ACpretend %d,%d bad number of parents %d\n",
	   OM_Gw_current_OS,my_id,size);
    return(0);
   }
   ACmagic_read(my_id, &AC_template_chns,father, size);
  /*"oretend in design father %d\n",father->objid,father->osnum*/

  /* context now */

  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&msg,matrix);


return(1);
}

/* -----------------------------------------------------------
 * Get Attribute Values
 */
method NDgive_structure(IGRlong *msg; struct ret_struct  *x;
			struct GRmd_env *md_env )
{
  int 		suc, status;
  struct 	GRid father;
  struct GRmd_env local_env, myEnv;
  IGRmatrix     tmp_matrix;
  short four;

  /*"down_scan %s index %d \n",  me->down_scan,me->direct_index */

  /*
   * Shouldn't crash even if there is no module environment - TR# 4527.
   */
  if ( !md_env )
  {
        gr$get_module_env(buffer = &myEnv);

        myEnv.md_id.osnum = OM_Gw_current_OS;
        ex$get_modid(mod_osnum =  myEnv.md_id.osnum,
                     mod_id    = &myEnv.md_id.objid );
        md_env = &myEnv;
  }

  /* Get parent and matrix to use */

  local_env.md_id = md_env->md_id;
  status = om$send(msg = message ACpretend.ACfind_parent(&father,
					    &local_env.md_env.matrix_type,
					     tmp_matrix
					    ),
		       targetid = my_id);
  as$status( action = RET_STATUS );

  four = 4;
  MAmulmx(msg,&four,&four,&four,md_env->md_env.matrix,tmp_matrix,
			        local_env.md_env.matrix);
  MAtypemx(msg,local_env.md_env.matrix,
  	      &local_env.md_env.matrix_type);


  if('.'==me->down_scan[0])
   {
    status = om$send(msg = message NDnode.NDgive_structure(msg,x,&local_env),
		       targetid = father.objid,
		       targetos = father.osnum );
      as$status( action = RET_STATUS ); 
    }
    else
    {
      status = om$send(msg = message NDmacro.ACgive_structure ( &suc,
				&(me->direct_index),me->down_scan,x,&local_env),
        	       targetid = father.objid,
		       targetos = father.osnum );
      as$status( action = RET_STATUS ); 
      if(suc==0)
      {
        if( strcmp( me->down_scan, "bend_sweep" ) &&
            strcmp( me->down_scan, "memb_geom"  ) &&
            strcmp( me->down_scan, "equiv_dia") ) {
	  
	  printf("%d,%d %d,%d ACpretend.ACgive_structure downscan %s\n",
		 OM_Gw_current_OS,
		 my_id,
		 father.osnum,
		 father.objid,
		 me->down_scan);
	}
	
        return(0);
      }
    }
      /*"struct_type %#x \n",x->type */
  return(1);
} 

/* ========================================================================= */
method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)
{
  int 		i, status;
  IGRlong	msg;
  struct GRid 	target;
  struct GRid 	father;
  double mat1[16],mat2[16];
  short mat_typ1,mat_typ2;

  struct GRid 	myID;

  /*"down_scan %s index %d \n",  me->down_scan,me->direct_index */

  status = om$send(msg = message ACpretend.ACfind_parent(&father,
							 &mat_typ1,mat1),
		       targetid = my_id);
     as$status( action = RET_STATUS );

  if('.'==me->down_scan[0])
  {
    status = om$send(msg = message NDnode.ASreturn_go(go,&mat_typ2,mat2),
		       targetid = father.objid,
		       targetos = father.osnum);
    as$status( action = RET_STATUS ); 
  }
  else
  {
   status = om$send(msg = message NDmacro.ACreturn_foot
				(&msg,me->down_scan,&target,&mat_typ2,mat2),
      		     targetid = father.objid,
		     targetos = father.osnum );
   if(!msg || !(status&1))
    {
      myID.osnum = OM_Gw_current_OS;
      myID.objid = my_id;
      
      VDlogPrintFmt(VDLOG_WARN,1,"ACpretends.ASreturn_go %d,%d cannot find foot %s",
		    myID.osnum,
		    myID.objid,
		    me->down_scan);
      
#if 0
     VDlogPrintObject(VDLOG_WARN,1,NULL,NULL,&myID);
     printf("ACpretends %d %d return_go unable to find feet %s \n",
            my_id,OM_Gw_current_OS,me->down_scan);
#endif

     return(OM_W_ABORT);
    }
    *go=target; 
  }

 if(mat_typ1 == MAIDMX)
  {
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = mat2[i];
   if(mat_type != NULL) *mat_type = mat_typ2;
  }
 else if(mat_typ2 == MAIDMX)
  {
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = mat1[i];
   if(mat_type != NULL) *mat_type = mat_typ1;
  }
 else
  {
   short four = 4;
   double tmp_matrix[16];
   MAmulmx(&msg,&four,&four,&four,mat1,mat2, tmp_matrix);
   if(matrix != NULL)  for(i=0;i<16;i++) matrix[i] = tmp_matrix[i];
   if(mat_type != NULL) MAtypemx(&msg,tmp_matrix, mat_type);
  }

 /*^ 
 printf("go %d %d mat_type %d\n",go->objid,go->osnum,*mat_type);
 pr_mat("matrix",4,4,matrix);
 */
 return(OM_S_SUCCESS);
}

/* ========================================================================= */

end implementation ACpretend;
