/* 
   override message declared in NDmacro
   Design jla 11 July 1988
*/

class implementation NDnodein;


#include "AS_status.h"
#include "OMminimum.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "nddef.h"
#include "macro.h"
#include "godef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "igrdp.h"
#include "madef.h"
#include "exmacros.h"
#include "grerr.h"
#define AS_DEBUG

from GRgraphics  import GRchgprops;
from GRgraphics  import GRgetprops;
from GRvg  import GRputsymb, GRgetsymb, GRchgdp, GRgetattr, GRputattr;
from GRgraphics  import GRcopy;
from GRtext import GRgettxattr, GRreplace_text;



/*
   Return if the object is used in a macro definitiono
*/

method ACin_macro_def(IGRint *in_def)
{
struct ACopen_struct
{
 int osnum;
 int name;
};

extern  IGRint                  ACopen_number;
extern  struct  ACopen_struct   *ACopen_info;

IGRint          i;
GRspacenum cur_os;

        *in_def = 0;

       /* if object in current module --> not in a macro */

       ex$get_cur_mod(osnum = &cur_os);
       if(cur_os == OM_Gw_current_OS) return OM_S_SUCCESS;

        /*| test if OM_Gw_current_OS is in def lib */

        /*" ACopen_number : %d\n", ACopen_number */

        for( i=0; i<ACopen_number; i++ )
                if( ACopen_info[i].osnum == OM_Gw_current_OS ){
                        /*" node in def osnum : %d\n", ACopen_info[i].osnum */
                        *in_def = 1;
                }



return(OM_S_SUCCESS);
}

/* ========================================================================= */

method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int status;

     status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
     as$status( );

  return (  OM_S_SUCCESS );
}



/* ========================================================================= */

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *md_env,*new_info;
  			 struct GRid *newobjid)
{
int status;
 status = om$send( msg = message NDnode.NDcopy_to_root(msg,cp_type,  
 		   md_env,new_info,newobjid),
                   targetid = my_id);
 as$status();
  return ( status  );
}


/* ========================================================================= */

/* ========================================================================= */

method   ACreturn_foot(IGRlong *msg;char *footname;     
		struct GRid *foot_GRid;IGRshort *mat_type;IGRdouble *matrix)
{
 int status;
  /*"ACreturn_foot %s, \n",footname */
  *msg=0;

  if('.'== footname[0]|| 0 == footname[0] )
  {
   status = om$send( msg = message 
		NDnode.ASreturn_go( foot_GRid,mat_type,matrix),
	      targetid = my_id);
   as$status(action = RET_STATUS);
   *msg=1;

   if(mat_type != NULL)  *mat_type = MAIDMX;
   if(matrix != NULL)  MAidmx(msg,matrix);
  }
  else
  {
   *msg = 0;
  }

  return( OM_S_SUCCESS );
}


/* ========================================================================= */

method ACconsume(IGRlong *msg;char *footname;
	int cpy_req;struct GRid *cpy_GRid;struct GRmd_env *md_env)
{
int status;
short           action, mask;
struct GRid go;
char            old_ASbroad;
extern char     ASbroadcast_in_progress;

IGRmatrix     tmp_matrix;
short         tmp_matrix_type;
struct GRmd_env from_env,to_env;
short four;


  /* default consume for single foot objects */

  *msg=0;
  status = om$send(msg = message NDmacro.ACreturn_foot(msg,
                                     footname,&go,&tmp_matrix_type,tmp_matrix),
                targetid = my_id );
  as$status( );

  if(*msg !=0 && cpy_req)
   {
  /* Initialize md_env for copy */
  /* 18 march 93 correct initialization of md_id when the consumed object is */
  /* in a different object space					     */

    four = 4;
    MAmulmx(msg,&four,&four,&four,md_env->md_env.matrix,tmp_matrix,
                                from_env.md_env.matrix);
    MAtypemx(msg,from_env.md_env.matrix,
               &from_env.md_env.matrix_type);

    from_env.md_id.osnum = go.osnum;
    ex$get_modid(mod_osnum =  from_env.md_id.osnum,
  		 mod_id    = &from_env.md_id.objid);

    to_env.md_id = md_env->md_id;
    MAidmx(msg,to_env.md_env.matrix);
    to_env.md_env.matrix_type = MAIDMX;

    old_ASbroad = ASbroadcast_in_progress;
    ASbroadcast_in_progress = 1;
     {

/* NO LONGER NECESSARY 
/*     GRclassid 		target_cl;
/*     om$get_classid(objid = go.objid,
/*		    osnum = go.osnum,
/*		    p_classid = &target_cl);
/*     if(om$is_ancestry_valid(subclassid =target_cl ,
/*                          superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
/*      {
/*      status = om$send( msg = message NDnode.NDcopy_to_root(msg,0, 
/* 		   &from_env,&to_env,cpy_GRid),
/*                   targetid = go.objid  );
/*      as$status();
/*      }
/*     else
/*      {
/**********/
      status = om$send( msg = message GRgraphics.GRcopy
        (msg,&from_env,&to_env,&(cpy_GRid->objid)),
                targetid = go.objid,targetos = go.osnum );
      as$status( );
      cpy_GRid->osnum=to_env.md_id.osnum;

/* } */
     }
    /*" go.objid %d cpy.objid %d \n",go.objid,cpy_GRid->objid  */
    ASbroadcast_in_progress = old_ASbroad;

    action = 1;    
    mask   = GRIS_LOCATABLE|GRIS_DISPLAYABLE; 
    status = om$send( msg = message GRgraphics.GRchgprops( msg, &action, &mask),
               targetid = cpy_GRid->objid,targetos = cpy_GRid->osnum );
    as$status( );

   }
   action = 0;    
   mask   = GRIS_LOCATABLE|GRIS_DISPLAYABLE; 
   status = om$send( msg = message GRgraphics.GRchgprops( msg, &action, &mask),
                targetid = go.objid,targetos = go.osnum );
   as$status( );

  return (  OM_S_SUCCESS );
}


/* ========================================================================= */

method ACunconsume(IGRlong *msg;char *footname)
{
struct GRid go;
int status;
short           action, mask;
  *msg=0;

  /* default unconsume for single foot objects */
  status = om$send(msg = message NDmacro.ACreturn_foot (msg,
                                        footname,&go,NULL,NULL),
                     targetid = my_id );
  as$status( );

  if(*msg!=0)
   {
    action = 1;    
    mask   = GRIS_LOCATABLE|GRIS_DISPLAYABLE; 
    status = om$send( msg = message GRgraphics.GRchgprops( msg, &action, &mask),
                targetid = go.objid,targetos = go.osnum );
    as$status( );
    *msg=1;
   }
  return (  OM_S_SUCCESS );
}


/* ========================================================================= */

ACtrans_symb(context_go,my_go)
struct GRid context_go,my_go;
/*.ACtrans_symb*/
{
int status;
IGRlong 		msg,msg_layer,msg_symb;
struct GRsymbology 	symb;
IGRshort	 	props,my_props,set;
GRclassid		obj_class,obj_class1;

/*"transfer symb from %d %d to %d %d\n",context_go.objid,context_go.osnum,my_go.objid,my_go.osnum */
 

  if(!IF_EQ_OBJID(context_go.objid,NULL_OBJID))
   {
    status = om$send(msg = message GRgraphics.GRgetprops(&msg_layer,&props),
		      senderid = my_go.objid,
                      targetid = context_go.objid,
                      targetos = context_go.osnum);
    as$status(  );

    status = om$send(msg = message GRvg.GRgetsymb(&msg_symb,&symb),
		      senderid = my_go.objid,
                      targetid = context_go.objid,
                      targetos = context_go.osnum);
/*"layer %d color %d\n",symb.level,symb.display_attr.color*/
    as$status(  );
    if(status&msg_symb&1)
     { if(msg_layer&1)
         {status = om$send(msg = message GRgraphics.GRgetprops(&msg,&my_props),
		      senderid = my_go.objid,
	              targetid = my_go.objid,
                      targetos = my_go.osnum);
          as$status(  );
          props =(GRIS_LOCATABLE|GRIS_DISPLAYABLE) & props;
          my_props = (~(GRIS_LOCATABLE|GRIS_DISPLAYABLE)) & my_props;
          my_props = props|my_props;
          set = -1;   /*replace */
          status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set,
                                                           &my_props),
		      senderid = my_go.objid,
	              targetid = my_go.objid,
                      targetos = my_go.osnum);
          as$status(  );
         }

       if( msg_symb == MSSUCC || msg_symb == GR_I_NO_LAYER)
         {
          /*| transfer symbology */
          status = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
		      senderid = my_go.objid,
	              targetid = my_go.objid,
                      targetos = my_go.osnum);
          as$status(  );
         }
     }
       /* Transfer now specific attributes */
       status=om$get_classid(objid = context_go.objid,osnum = context_go.osnum,
                               p_classid = &obj_class);
       status=om$get_classid(objid = my_go.objid,osnum = my_go.osnum,
                               p_classid = &obj_class1);
       if(  (om$is_ancestry_valid(subclassid = obj_class,
                           superclassname = "GRbcsubbc") == OM_S_SUCCESS
          && om$is_ancestry_valid(subclassid = obj_class1,
                           superclassname = "GRbcsubbc") == OM_S_SUCCESS)

          ||
            (om$is_ancestry_valid(subclassid = obj_class,
                           superclassname = "EMSsubbs") == OM_S_SUCCESS
          && om$is_ancestry_valid(subclassid = obj_class1,
                           superclassname = "EMSsubbs") == OM_S_SUCCESS) )
 
         {char bc_attr[100];
          status = om$send(msg = message GRvg.GRgetattr(&msg,bc_attr),
                      senderid = NULL_OBJID,
                      targetid = context_go.objid,
                      targetos = context_go.osnum);

          if((status&1) && msg == MSSUCC)
           {
            status=om$send(msg = message GRvg.GRputattr(&msg,bc_attr),
                      senderid = my_go.objid,
                      targetid = my_go.objid,
                      targetos = my_go.osnum);
            as$status();
           }

        }
  }
 return 1;
}

ACtrans_text(context_go,my_go)
struct GRid context_go,my_go;
/*.ACtrans_text*/

{
 unsigned char *text_addr;
 short text_len;
 struct GRmd_env md_env;
 struct IGRestx text_attr;
 long msg,status;


  status = om$send(msg = message NDnode.ASreturn_go(&context_go,NULL,NULL),
		   senderid = NULL_OBJID,
		   targetid = context_go.objid,
		   targetos = context_go.osnum);

  status = om$send(msg = message NDnode.ASreturn_go(&my_go,NULL,NULL),
		   senderid = NULL_OBJID,
		   targetid = my_go.objid,
		   targetos = my_go.osnum);
   /* JLA test for CGEE */


  text_addr = NULL;
  text_len = 0;

    
    md_env.md_id.osnum = context_go.osnum;
    ex$get_modid(mod_osnum =  md_env.md_id.osnum,
  		 mod_id    = &md_env.md_id.objid);
    MAidmx(&msg,md_env.md_env.matrix);
    md_env.md_env.matrix_type = MAIDMX;


/*" Transfer text from %d to %d\n",context_go.objid,my_go.objid */
  status = om$send (msg = message GRtext.GRgettxattr
                         (&msg, &text_attr, &text_len,&text_addr),
		     senderid = my_go.objid,
                     targetid = context_go.objid,
                     targetos = context_go.osnum);

    if((status&1) && msg == MSSUCC) 
     {

      /*" text is %s len %d\n",text_addr,text_len */
      status = om$send(msg=message GRtext.GRreplace_text(&msg,&md_env,
                                                         text_len, text_addr),
		      senderid = my_go.objid,
	              targetid = my_go.objid,
                      targetos = my_go.osnum);
      as$status(  );
      if(text_addr != NULL) om$dealloc( ptr = text_addr);

     }
 return 1;
}
end implementation NDnodein;
