/*

  Description

      This file contains the functions for Save Element to File 
      and SplitPart.

  History

      Gang   03/11/93   Creation.
      MILIND 11/27/97   TR#119424204 
      TR#119424204 To save detailing dimension
      correctly :
        Modifications :
	1   Get the components of GRcompcurve
	2   Pass it with assoc elements
	3   the copied GRcompcurve will be in split form
	4   connect the Grcompcurve
	--- Only ASMSsplitpart functions is
					modified
	I don't see any other way to tackle this problem
	If we also want to copy dimension/annotations atteched to
	3D objects we will have to do the same thing i.e split
	the object and send it for NDcopy (the source should go
	with the object). So we have to split till source level.

*/

class implementation EMSassoc;
#include <alloca.h>
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "exdef.h"
#include "exmacros.h"
#include "madef.h"
#include "coparamac.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "FI.h"
#include "dpmacros.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "griodef.h"
#include "griomacros.h"
#include "nddef.h"
#include "nd.h"
#include "ndmacros.h"
#include "macro.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "GM.h"
#include "GMdef.h"
#include "GMpriv.h"
#include "GMmacros.h"
#include "emsdef.h"
#include "asdef.h"
#include "AS_status.h"
#include "ASmessages.h"
#include "grmsg.h"
#include "refdef.h"
#include "refmacros.h"
#include "msmacros.h"
#include "EC_I.h"
#include "EC_M.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"


struct node_list {
  struct GRid nodeid;
  IGRint flag;
};

/* define constants */

#define ASM_DELETE 1
#define PARENT_IN_LIST 2
#define GET_GRAPH_AGAIN 3
#define HAVE_DEP 3
#define Null ((char *)NULL)
#define ASM_DEF_SIZE 50

/* define error codes */

#define ASM_INVALID_SEEDFILE 2

/* #define TRACE  */

#ifdef TRACE
#define trace(x) x
#else
#define trace(x)
#endif

/* extern variables */
extern char EX_seedfile[];

from GAcurve import GAis_msc;
from GRcompcurve import  EMmakecomp;

extern OMuword OPP_DMsrc_class_id;
extern OMuword OPP_ASsource_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_ASsource_class_id;


/*
   Name: 
         ASMdelete_graph

   Abstract:

     This function deletes the associative graph from the assembly file
     by maintaining the associativity of the non copied objects in the
     assembly file.

*/


IGRlong ASMdelete_graph(frm_nodes,to_nodes,nb_nodes)
struct node_list *frm_nodes;  /* I  list of original elements */
struct node_list *to_nodes;   /* I  list of copied elements */
IGRint nb_nodes;              /* I  number of elements in the list */
{
  IGRlong msg;
  IGRint i,j,k,sts,count;
  struct GRid *p_obj1;
  struct GRid dep_nodes[512];
  IGRint frm_child,to_child, num_dep;
  IGRint orig_child,msc_flag;
  IGRint grand_child,dep_flag;
  struct GRmd_env md_env;
  IGRint nbytes_in_buffer,nbytes_trans;
  OMuword classid1,classid2;
  GRobjid *display_ids;
  IGRint display_count,involk_count; 
  struct GRid *old_solid;
  IGRboolean gothist;
  extern OMuword OPP_EMSsfhist_class_id;

   /* Initialize the pointers. */

    num_dep = 0;
    msg = 0;
    sts = 0;
    old_solid = NULL;
    count = 0;
    display_count = 0;
    involk_count = 0;
    display_ids = NULL;
    gothist = FALSE;
    frm_child = 0;
    to_child = 0;
    grand_child = 0;
    dep_flag = 0;

   /* Get the active module environment */

   nbytes_in_buffer = sizeof(struct GRmd_env);

   gr$get_module_env(msg = &msg,
                     sizbuf = &nbytes_in_buffer,
                     buffer = &md_env,
                     nret= &nbytes_trans);

    for(i = nb_nodes - 1; i >= 0 ; i = i - 1)
     {

         frm_child = 0;
         to_child = 0;
         sts = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF,
                          NULL,0,&p_obj1,0,OM_K_MAXINT,&frm_child),
                       senderid = NULL_OBJID,
                       targetid = frm_nodes[i].nodeid.objid,
                       targetos = frm_nodes[i].nodeid.osnum);

         sts = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,
                             NULL,0,NULL,0,OM_K_MAXINT,&to_child),
                       senderid = NULL_OBJID,
                       targetid = to_nodes[i].nodeid.objid,
                       targetos = to_nodes[i].nodeid.osnum);

         om$get_classid(objid = frm_nodes[i].nodeid.objid,
                        osnum =  frm_nodes[i].nodeid.osnum,
                        p_classid = &classid1);

         om$get_classid(objid = to_nodes[i].nodeid.objid,
                        osnum =  to_nodes[i].nodeid.osnum,
                        p_classid = &classid2);

         /* Check the objects are of same class */

         if(classid1 == classid2)
          {

            trace(printf("frm_node: %d, frm_ch: %d, to_node: %d, to_ch: %d\n",
                 frm_nodes[i].nodeid.objid,frm_child,to_nodes[i].nodeid.objid,
                 to_child));

            /* If the original object has more children, check it has
               any model space counterpart objects or EMSpointer objects
               which are having no dependents. */
             
            orig_child = frm_child; 
            if(orig_child != to_child)
             {
               for(k=0; k < frm_child; k++)
                {
                  trace(printf("child: %d\n",p_obj1[k].objid));
                  om$get_classid(objid = p_obj1[k].objid,
                                 osnum =  p_obj1[k].osnum,
                                 p_classid = &classid1);

                  if((om$is_ancestry_valid(subclassid = classid1,
                          superclassname = "GAcurve") == OM_S_SUCCESS))
                   {
                      msc_flag = FALSE;
                      om$send(msg = message GAcurve.GAis_msc(&msg, 
                                                             &msc_flag),
                              senderid = NULL_OBJID,
                              targetid = p_obj1[k].objid,
                              targetos = p_obj1[k].osnum);
                      if(msc_flag)
                       {
                         orig_child --;
                       }
                   }
                  else
                   if((om$is_ancestry_valid(subclassid = classid1,
                          superclassname = "EMSpointer") == OM_S_SUCCESS))
                    {
                      grand_child = FALSE;

                      sts = om$send(msg = message NDnode.NDget_objects(
                                         ND_CHILDREN, NULL,0,NULL,
                                         0,OM_K_MAXINT,&grand_child),
                                    senderid = NULL_OBJID,
                                    targetid = p_obj1[k].objid,
                                    targetos = p_obj1[k].osnum);
 
                      if(!grand_child)
                       {
                         orig_child --;
                       }
                    }
                }

             }

            /* Is the copied object and the original object are having the
               same number of dependents */

            if(orig_child <= to_child)
             {
                /* Check any undeleted objects are dependents of this
                   object */

                if(num_dep == 0)
                  {
                     frm_nodes[i].flag = ASM_DELETE;
                  }
                else
                  {
                      sts = nd$dep_exist(l_root = &frm_nodes[i].nodeid,
                                         nb_root = 1,
                                         l_tip = dep_nodes,
                                         nb_tip = num_dep);
                      if(sts == FALSE)
                         frm_nodes[i].flag = ASM_DELETE;
                      else
                        {

                          trace(printf("dep1: %d\n",frm_nodes[i].nodeid.objid));

                          dep_nodes[num_dep] = frm_nodes[i].nodeid;
                          num_dep++;
                        }
                      
                  }
             }
            else
             {

              
             trace(printf("frm_ch: %d, to_ch: %d, fr_objid: %d, to_objid: %d\n",
                       frm_child,to_child, frm_nodes[i].nodeid.objid,
                       to_nodes[i].nodeid.objid));
            

               for(j = 0; j < frm_child; j++)
                 {
                   grand_child = FALSE;

                   sts = om$send(msg = message NDnode.NDget_objects(
                                       ND_CHILDREN, NULL,0,NULL,
                                       0,OM_K_MAXINT,&grand_child),
                                 senderid = NULL_OBJID,
                                 targetid = p_obj1[j].objid,
                                 targetos = p_obj1[j].osnum);
 
                   if(grand_child > 0)
                    {
                       dep_flag = TRUE;
                       break;
                    }
                 }
       
               if(dep_flag == TRUE)
                {
                  dep_nodes[num_dep] = frm_nodes[i].nodeid;
                  num_dep++;
                }
              else
                {
                  frm_nodes[i].flag = ASM_DELETE;
                }
             }
          }
        else
            frm_nodes[i].flag = ASM_DELETE;

     }

    for(i = 0; i < nb_nodes ; i++)
     {
         if(frm_nodes[i].flag == ASM_DELETE)
           {
               /* Don't delete reference planes and dimension supers */

               om$get_classid(objid = frm_nodes[i].nodeid.objid,
                              osnum =  frm_nodes[i].nodeid.osnum,
                              p_classid = &classid1);

               if((om$is_ancestry_valid(subclassid = classid1,
                         superclassname = "EMSdatpln") != OM_S_SUCCESS) &&
                  (om$is_ancestry_valid(subclassid = classid1,
                         superclassname = "DMproot") != OM_S_SUCCESS))
/*
                  (om$is_ancestry_valid(subclassid = classid1,
                         superclassname = "SKasptgrnd") != OM_S_SUCCESS))
*/
                 {
                        sts = om$send(msg = message NDnode.NDdelete(&md_env),
                                      senderid = NULL_OBJID,
                                      targetid = frm_nodes[i].nodeid.objid,
                                      targetos = frm_nodes[i].nodeid.osnum);

                 }
           }

     }
    return(1);
}



/* 
   Name : ASMtransfer_symb

   Abstract:

   This function copies the symbology of surfaces and solids from the
   original graph to the new graph. And also it copies the name of the
   elements frm the original graph to the new graph.If the delete is
   TRUE it will also deletes the original graph.

*/

IGRlong ASMtransfer_symb(frm_graph,to_graph,delete)
struct GMgraph *frm_graph; /* I original graph */
struct GMgraph *to_graph;  /* I copied graph */
IGRboolean *delete; /* I delete flag */
{
  struct GMhcode *frm_hcode, *to_hcode;
  IGRushort index0, index1, index2;
  IGRlong status,sts,i;
  IGRint  done, j;
  IGRint  frm_comp_count, to_comp_count;
  OMuword classid;
  OMuword classid2;
  struct GRid *frm_id, *to_id;
  struct GRid frm_compid, to_compid;
  struct node_list *frm_nodes, *to_nodes;
  OM_S_CHANSELECT to_comps;
  DIobjid old_objid;
  IGRchar obj_name[DI_PATH_MAX];
  IGRchar pathname[DI_PATH_MAX];
  IGRchar tmp_name[DI_PATH_MAX];
  IGRchar new_name[DI_PATH_MAX];

    /* Initialize the pointers */

    obj_name[0] = NULL;
    new_name[0] = NULL;
    pathname[0] = NULL;
    tmp_name[0] = NULL;
    sts = 0;
    status = 0;

    frm_hcode = frm_graph->p_hcode;
    to_hcode  = to_graph->p_hcode;

    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    
    trace(printf("number of nodes in original graph: %d\n",
                          frm_graph->nb_elmt));
    trace(printf("number of nodes in copied graph: %d\n",
                          to_graph->nb_elmt));
    frm_nodes = (struct node_list *)malloc(frm_graph->nb_elmt * sizeof(struct node_list));
    to_nodes = (struct node_list *)malloc(frm_graph->nb_elmt * sizeof(struct node_list));

    for (index0=0;index0<frm_graph->nb_elmt;index0++)
     {
        index1 = frm_graph->l_ord_elmt[index0];
        index2 = to_graph->l_ord_elmt[index0];
        frm_id = (struct GRid *)GMh_key(frm_hcode,index1);
        to_id = (struct GRid *)GMh_key(to_hcode,index2);
 
        trace(printf("frm_id: %d   to_id: %d\n",frm_id->objid,to_id->objid));


        frm_nodes[index0].nodeid = *frm_id;
        frm_nodes[index0].flag = HAVE_DEP;
        to_nodes[index0].nodeid = *to_id;

        om$get_classid(objid = to_id->objid,
                      osnum = to_id->osnum,
                      p_classid = &classid);

        om$get_classid(objid = frm_id->objid,
                      osnum = frm_id->osnum,
                      p_classid = &classid2);

/*
        if((om$is_ancestry_valid(subclassid = classid,
                         superclassname = "DMroot") != OM_S_SUCCESS) &&
          (om$is_ancestry_valid(subclassid = classid,
                         superclassname = "SKconstraint") != OM_S_SUCCESS))
*/
       if(classid == classid2)
        {

          /* get the name of the original object */

          obj_name[0] = NULL;
          sts = di$untranslate(objname = obj_name,
                               objid = frm_id->objid,
                               osnum = frm_id->osnum);
  
          if(obj_name[0])
           {
  
               /* get the name of copied object */
               new_name[0] = NULL; 
               sts = di$untranslate(objname = new_name,
                                    objid = to_id->objid,
                                    osnum = to_id->osnum);
  
               /* If there is a name remove that name from the directory */
  
               if(new_name[0])
                 {
                    sts = di$rm_name(regexp = new_name,
                               osnum = to_id->osnum);
                 }
  
               di$split(pathname = obj_name,
                        name = tmp_name);
  
               di$give_pathname(osnum = to_id->osnum,
                                pathname = pathname);
  
               strcat(pathname,":usr:");

               /* check wether there is an object with the same name
                  in the newfile. If not copy the name from the original
                  object to the new */

               sts = di$translate(objname = tmp_name,
                                  osnum = to_id->osnum,
                                  path = pathname,
                                  p_objid = &old_objid);
               if(sts == DIR_S_SUCCESS)
                { 
                    /* object exists with the same name, do auto-naming */

                    j = 1;
                    done = FALSE;
                    while(!done)
                      {
                         sprintf(new_name, "auto%d",j);
                         
                         sts = di$translate(objname = new_name,
                                            osnum = to_id->osnum,
                                            path = pathname,
                                            p_objid = &old_objid);
                         if(sts != DIR_S_SUCCESS)
                          {
                            sts = di$add_name(objname = new_name,
                                              path = pathname,
                                              osnum = to_id->osnum,
                                              objid = to_id->objid);
                            done = TRUE;
                          } 
                         else
                          {
                              j++;
                          }
                        
                      }
                }
               else                  
                { 
                  sts = di$add_name(objname = tmp_name,
                                    path = pathname,
                                    osnum = to_id->osnum,
                                    objid = to_id->objid);
                }
  
           }
        } 

        if(om$is_ancestry_valid(subclassid = classid,
                          superclassname = "EMSsurface") == OM_S_SUCCESS)
         {
            frm_comp_count = 0;
            to_comp_count = 0;
            sts = om$get_channel_count(p_chanselect = &to_comps,
                                       objid = frm_id->objid,
                                       osnum = frm_id->osnum,
                                       count = (OMuint *) &frm_comp_count);
            sts = om$get_channel_count(p_chanselect = &to_comps,
                                       objid = to_id->objid,
                                       osnum = to_id->osnum,
                                       count = (OMuint *) &to_comp_count);

            if(frm_comp_count != to_comp_count)
              continue;

            for(i=0; i < frm_comp_count ; i++)
             {
                frm_compid.objid = NULL_OBJID;
                to_compid.objid  = NULL_OBJID;
                sts = om$get_objid_at_index(objid = frm_id->objid,
                                            osnum = frm_id->osnum,
                                            p_chanselect = &to_comps,
                                            index = i,
                                            objidaddr = &frm_compid.objid,
                                            osnumaddr = &frm_compid.osnum);


                sts = om$get_objid_at_index(objid = to_id->objid,
                                            osnum = to_id->osnum,
                                            p_chanselect = &to_comps,
                                            index = i,
                                            objidaddr = &to_compid.objid,
                                            osnumaddr = &to_compid.osnum);

                om$get_classid(objid = frm_compid.objid,
                      osnum = frm_compid.osnum,
                      p_classid = &classid);
                om$get_classid(objid = to_compid.objid,
                      osnum = to_compid.osnum,
                      p_classid = &classid2);

                if((om$is_ancestry_valid(subclassid = classid,
                         superclassname = "EMSfeature") != OM_S_SUCCESS) &&
                   (om$is_ancestry_valid(subclassid = classid,
                         superclassname = "EMSsfboolean") != OM_S_SUCCESS)&&
                   (classid == classid2))
                {

                  ASMtrans_comp_symb(&frm_compid, &to_compid,&to_comps); 

                }
             }
         }

     }

    if(delete)
     if(*delete)
      {
        ASMdelete_graph(frm_nodes,to_nodes,frm_graph->nb_elmt);
      }


    if(frm_nodes)free(frm_nodes);
    if(to_nodes)free(to_nodes);
    return(1);
}


IGRlong ASMget_product_data(run_name,logo_ptr,module_class,srch_path,
                            config_path,product_path )
char *run_name;
char *logo_ptr;
char *module_class;
char *srch_path;
char *config_path;
char *product_path;
{
    char buffer[256];
    char runname[30];
    int numread;
    char *quot1, *quot2;
    int name_found;
    FILE *file_ptr;
    char prodfile[128];

    name_found = FALSE;
    prodfile[0] = NULL;
    
    strcpy(prodfile, getenv("INGRHOME"));
    if(prodfile[0] == NULL)
     {
       trace(printf("INGRHOME not defined\n"));
       return(0);
     }
    strcat(prodfile,"/product_data");   
    file_ptr=fopen(prodfile,"r");
    if (file_ptr!=0)
    {
        while( fgets(buffer,256,file_ptr) != 0)
        {
            if((buffer[0] == '#') || (buffer[0] == ' ') || (buffer[0] == '\t')
               || (buffer[0] == '\n'))
                continue;

            runname[0] = '\0';
            if( strchr( buffer, '"' ) )
            {
                /* get run name */
                quot1 = strchr(buffer,'"');
                quot2 = strchr(quot1+1,'"');
                if ( quot2 )    /* second '"' found */
                {
                    strncpy(runname,quot1+1, quot2 - quot1 - 1);
                }
                else
                {
                    trace(printf("missing double quote in product_data\n"));
                }
                *(runname+(quot2-quot1-1))='\0';
            }

            if(strcmp(runname, run_name) == 0 )
            {
                name_found = TRUE;
                if ( logo_ptr != NULL)
                {
                    sscanf(buffer,"%*s %s %*s %*s %*s",logo_ptr);
                }
                if ( module_class != NULL)
                {
                    sscanf(buffer,"%*s %*s %s %*s %*s",module_class);
                }
                if ( srch_path != NULL)
                {
                    sscanf(buffer,"%*s %*s %*s %s %*s",srch_path);
                }
                if ( config_path != NULL)
                {
                    sscanf(buffer,"%*s %*s %*s %*s %s",config_path);
                    if( config_path[strlen(config_path)-1] != '/')  strcat(config_path, "/");
                }
                if ( product_path != NULL)
                {
                    numread=sscanf(buffer,"%*s %*s %*s %*s %*s %s",product_path);
                    if (numread == -1 )
                    {
                        numread=sscanf(buffer,"%*s %*s %*s %*s %s %*s",product_path);
                        if( numread == -1 ) trace(printf("get_product_path: can not get product_path\n"));
                    }
                    if(( numread != -1 ) && ( product_path[strlen(product_path)-1] != '/'))
                        strcat(product_path, "/");
                }

                break;
            }                   /* if(run_name eq runname) */
        }                       /* while loop */
        fclose(file_ptr);
    }                           /* if (file_ptr!=0) */
    if(name_found)
      return( 1);
    else
      return(0);
}

/*
   
  Name

      ASMSplitPart

  Description

      This is the main fucntion for Save Element to File or Split Part.
      This function will save the objects in obj_list and all their
      parents to the given filename.If the seedfile is not specified
      default seedfile will be used.It will also deletes the objects
      from the original object space if the delete option is specified.
      If the objects have other dependents which are not copied then
      those objects won't be deleted even if the delete option is
      specified.

*/


IGRlong ASMSplitPart(msg,
                     mod_env,
                     obj_list,
                     nb_obj,
                     filename,
                     seedfile,
                     delete,
		     create_part)
IGRlong *msg;                   /* O  completion code */
struct GRmd_env *mod_env;       /* I  module environment */
struct GRid *obj_list;          /* I  list of objects  */
IGRlong *nb_obj;                /* I  number of objects in the list */
IGRchar *filename;              /* I  filename */
IGRchar *seedfile;              /* I  seedfile name */
IGRboolean *delete;             /* I  delete flag */
IGRboolean *create_part;        /* I  create part flag */
{
  IGRlong             	rotten_one; 
  IGRlong 		 msg1;
  struct GRid           compcv_id;
  struct GRid 		*obj_lst;
  IGRshort 		assoc_flg, NOTIFY_FLG;
  IGRuint 		jj, num_list, j2, flg, flg2, flg_AS, flg_DMS, flg_dmy;
  IGRuint 		j4, j5,j33, j44, n2, n3,n4, n1, n6, n7;
  struct GRlc_info 	*GRinfo;
  IGRint   		sts ,rc, num_indv_cur, i1;
  IGRlong  		ind;
  IGRint   		file_no, i,j,k,l,z,num_ori;
  IGRchar  		path[250];
  IGRchar  		obj_name[120],tmp_name[120];
  IGRchar  		cmd[128],pathname[DI_PATH_MAX];
  IGRchar  		copyos[DI_PATH_MAX];
  struct  GRid  	copy;
  struct  GRmd_env 	to_env;
  struct  GRmd_env 	md_env;
  IGRchar  		seed_file[DI_PATH_MAX];
  IGRshort 		obj_props;
  IGRshort 		correct_graph;
  IGRint   		num_comp,graph_mem;
  IGRint   		flag1,flag2,status, status_n, status_m;
  IGRint   		num_child;
  IGRint   		num_attrs,p_nbcop;
  struct   GRid 	*l_assoc , *cp_objects;
  struct   GRid 	*s_obj, null_grid,as_obj;
  struct   GRid 	*graph, *cp_graph, *p_obj;
  struct   GRid 	file_part;
  IGRint   		*info,nb_assoc, nb_parents,nb_cpobj;
  IGRint   		s_size, nb_selected,s_lassoc;
  IGRlong  		nbytes_in_buff, nbytes_trans;
  GRobjid  		modid;
  OMuword  		class_id, classid_n, classid_n2,classid_n4;
  OMuword               class_id_a, class_id_b;
  struct  NDcp_struct 	clone;
  struct  GMgraph 	frm_graph, to_graph ;
  struct  GMhcode 	*p_hcode,*to_hcode1;
  IGRshort 		position;
  IGRushort 		index0, index1,index2;
  struct   GRid 	ext_id;
  IGRint   		master_units;
  IGRint   		seed_units;
  OM_S_OBJECT_LINKAGE   *list_id =NULL, *list_src = NULL, *list_src4 = NULL;
  OM_S_OBJECT_LINKAGE   *list_noti =NULL,*list_asso =NULL,*list_comp = NULL; 
  OM_S_CHANSELECT  	list_chan, list_AS, list_AS4, list_NOT,list_ASS;
  OM_S_CHANSELECT       list_COMP;
  OMuint          	num_chans, num_chans2, num_chans4;
  OMuint                num_chans_not, num_chans_ass, num_chans_comp;
  IGRuint          	num_cur_obj, num_cur_obj2, num_cur_obj4;
  IGRuint               num_not_obj, num_ass_obj, num_comp_obj;
  struct GRid 		*frm_id, *to_id;
  struct GRid 		*gr_obj, *cp_gr_obj;


  /*  FILE     *fp; */
  /* Initialize the pointers */


	gr_obj = NULL;
	cp_gr_obj = NULL;
	num_ori =0;	
        num_comp = 0;
        obj_name[0] = NULL;
        tmp_name[0] = NULL;
        num_attrs = 0;
        s_lassoc = 0;
        nb_assoc = 0;
        graph_mem = 0;
        obj_props = 0;
        nb_cpobj = 0;
        p_nbcop = 0;
        l_assoc = NULL;
        cp_objects = NULL;
        graph = NULL;
        s_obj = NULL;
        p_obj = NULL;
        info = NULL;
        cp_graph = NULL;
        nb_parents = 0;
        null_grid.objid = NULL_OBJID;
        null_grid.osnum = 0;
        as_obj.objid = NULL_OBJID;
        as_obj.osnum = 0;
        copyos[0] = NULL;
        seed_file[0] = NULL;
        sts = 0;
        correct_graph = FALSE;
	obj_lst = NULL;
	assoc_flg = FALSE;

        status = om$make_chanselect( channame = "GRcmpowner.to_components",
					 p_chanselect = &list_chan);

	status = om$make_chanselect( channame = "ASsource.listeners",
					p_chanselect = &list_AS);
	
	status = om$make_chanselect( channame = "ASsource.listeners",
					p_chanselect = &list_AS4);
	status = om$make_chanselect( channame = "NDfather.father",
					p_chanselect = &list_NOT);
	status = om$make_chanselect( channame = "NDfather.father",
					p_chanselect = &list_ASS);
	status = om$make_chanselect( channame = "ASsource.listeners",
					p_chanselect = &list_COMP);
	num_list = 0;
	flg = 0;


/*    if GRcomp curve exist in copy elements split it into its components
      and put all the components into obj_lst.
      earlier we were not modifying obj_list
*/
	num_ori = *nb_obj;
	obj_lst = (struct GRid *) malloc(sizeof(struct GRid) * (*nb_obj));
	for(jj = 0; jj < *nb_obj; jj++)
	{
	obj_lst[jj].objid = obj_list[jj].objid;
	obj_lst[jj].osnum = obj_list[jj].osnum;
	status_n = om$get_classid(osnum = obj_list[jj].osnum,
				  objid = obj_list[jj].objid,
				  p_classid = &classid_n);
		if(classid_n == OPP_GRcompcurve_class_id)
		{
		flg++;
		}
	}
	num_indv_cur = 0;
	flg2 =0;
	for(jj = 0; jj < *nb_obj; jj++)
	{
	status_n = om$get_classid(osnum = obj_list[jj].osnum,
				  objid = obj_list[jj].objid,
				  p_classid = &classid_n);
	  if(classid_n == OPP_GRcompcurve_class_id)
	  {
	   num_list++;
	   num_chans =0;
	   status = om$get_channel_count( objid = obj_list[jj].objid,
					osnum = obj_list[jj].osnum ,
					p_chanselect = &list_chan,
					count = &num_chans);
	  num_indv_cur += num_chans;
	  list_id=(OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
							num_chans);
	  status = om$get_channel_objects(objid = obj_list[jj].objid,
					osnum = obj_list[jj].osnum ,
					p_chanselect = &list_chan,
					list = list_id,
					size = num_chans,
					count = &num_cur_obj);
	   for(j2=0;j2<num_chans;j2++)
	   {
	   flg2++;
	   obj_lst = (struct GRid *) realloc(obj_lst,sizeof
				( struct GRid) * (*nb_obj + flg2));
	   obj_lst[*nb_obj + flg2 -1].objid = list_id[j2].S_objid;
	   obj_lst[*nb_obj + flg2 -1].osnum = list_id[j2].osnum;
	   }
	 }   // if classid_n == OPP_GRcompcurve_class_id end's here
	}   // for jj loop end's here
	*nb_obj += flg2;

       if(mod_env == NULL)
        {
           /* get the current module environment */

           nbytes_in_buff = sizeof(struct GRmd_env);
           sts = gr$get_module_env(msg = msg,
                                   sizbuf = &nbytes_in_buff,
                                   buffer = &md_env,
                                   nret = &nbytes_trans);
           if(!(*msg & sts & 1))
            {
              goto quit;
            }
        }
       else
        {
           md_env = *mod_env;
        }

        ASMget_product_data("Exnuc",Null,Null,Null,Null,copyos);

        if(copyos[0] == NULL)
         {
           trace(printf("Failed to find Exnuc in product_data\n"));
           *msg = MSFAIL;
           sts = OM_E_ABORT;
           goto quit;
         }

        strcat(copyos,"bin/copyOS");

        if(seedfile[0] != NULL)
         {
           strcpy(seed_file,seedfile);
         }
        else
         {
            /* get the default seedfile */
            if(!EX_get_seed_file(EX_seedfile,seed_file))
             {
               trace(printf("Failed to find default seedfile\n"));
               *msg = MSFAIL;
               sts = OM_E_ABORT;
               goto quit;
             }
         }

        /* check for database units */
        sts = co$unit_database_type(osnum = md_env.md_id.osnum, 
                                    db_type = &master_units);
        if(sts == MSSUCC)
         {
            DIstmocpy ( path, "ref", seed_file, 0, md_env.md_id.osnum );
      
	    sts = ex$retrieve_module(
			msg = &rc,
			filename=seed_file,
			flag=EX_read_only,
			ftype = EX_invisible,
                        fstat=EX_old_module,
 			type = EX_ref,
                        mod_type = 2,
			mount_name = path,
			file_no=&file_no);
	    if (!( 1 & sts)) 
             {
              trace(printf("retrieve_module failed: sts = %d, msg = %d\n", sts, *msg));
              *msg = MSFAIL;
              goto quit;
             }

	    sts = ex$get_invis_info_by_index(
			index = file_no,
			mod_id = &to_env.md_id.objid,
			mod_osnum = &to_env.md_id.osnum);
	    if (!( 1 & sts))
                 trace(printf("Get ref info: sts = %d\n", sts));

            /* get the seedfile database units type */
            sts = co$unit_database_type(osnum = to_env.md_id.osnum,
                                        db_type = &seed_units);
            /* close the seedfile */
	    ex$close_module(ftype = EX_invisible, flag = 0,index = file_no);

            if(sts == MSSUCC)
             {
               if(master_units != seed_units)
                 {
                   *msg = ASM_INVALID_SEEDFILE;
                   sts = OM_E_ABORT;
                   goto quit;
                 }
             }
          }

        if(strcmp(seed_file,filename) != 0)
         {
            sprintf(cmd,"%s %s %s",copyos, seed_file, filename);

            /* Fork the copyOS command */
	    system(cmd);
         }

        DIstmocpy ( path, "ref", filename, 0, md_env.md_id.osnum );
      
	sts = ex$retrieve_module(
			msg = &rc,
			filename=filename,
			flag=EX_read_write,
			ftype = EX_invisible,
                        fstat=EX_old_module,
 			type = EX_ref,
                        mod_type = 2,
			mount_name = path,
			file_no=&file_no);
	if (!( 1 & sts)) 
           {
              trace(printf("retrieve_module failed: sts = %d, msg = %d\n", sts, *msg));
              *msg = MSFAIL;
              goto quit;
           }

        ex$message(field = ERROR_FIELD, msgnumb = EMS_M_SaveElemProgress);
	sts = ex$get_invis_info_by_index(
			index = file_no,
			mod_id = &to_env.md_id.objid,
			mod_osnum = &to_env.md_id.osnum);
	if (!( 1 & sts))
           trace(printf("Get ref info: sts = %d\n", sts));

	to_env.md_env.matrix_type = MAIDMX;
	MAidmx(msg, to_env.md_env.matrix);

	if(create_part)
	 if(*create_part)
	  {
	     file_part.objid = NULL_OBJID;
	     sts = asm$get_file_part(msg = msg,
				     mod_env = &to_env,
                                     part_id = &file_part);

             if(file_part.objid == NULL_OBJID)
	      {
		 /* create the default file part */
		 sts = asm$create_file_part(msg = msg,
					    mod_env = &to_env,
					    number = filename,
					    revision = "1");
	      }
	  }

        /* set static variable for split part operation */
        ASMset_splitpart();

        /* allocate memory for the non-associative objects */
        cp_objects = (struct GRid *)malloc(*nb_obj * sizeof(struct GRid));
	gr_obj = (struct GRid *)malloc(*nb_obj * sizeof(struct GRid));
	cp_gr_obj = (struct GRid *)malloc(*nb_obj * sizeof(struct GRid));

/*	First check if any dim/annot element exist - if YES confirm
	it that its source is also with it(Now source we can only
	getting it for 2D obj's. if source exist then don't make
	any source from dimension/annotation obj.
	Otherwise make a source so that it can be copied as a Graphics
	Group
*/
   for(ind=0; ind < *nb_obj; ind++)
   {
    /*| Test source objects */
    status = om$get_classid
    (objid = obj_lst[ind].objid,
	     osnum = obj_lst[ind].osnum,
	     p_classid = &class_id);
    NOTIFY_FLG = TRUE;
   if((om$is_ancestry_valid(subclassid = class_id,
   superclassname = "DMdim") == OM_S_SUCCESS)
   ||(om$is_ancestry_valid(subclassid = class_id,
   superclassname = "DMannot") == OM_S_SUCCESS))
    {
      NOTIFY_FLG = FALSE;
      num_chans_not =0;
      status = om$get_channel_count( objid = obj_lst[ind].objid ,
					osnum = md_env.md_id.osnum,
					p_chanselect = &list_NOT,
					count = &num_chans_not);
     if(num_chans_not > 0)
     { 
       list_noti=(OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE)
				* num_chans_not);
       status = om$get_channel_objects(objid = obj_lst[ind].objid ,
		 osnum = md_env.md_id.osnum,
		 p_chanselect = &list_NOT,
		 list = list_noti,
		 size = num_chans_not,
		 count = &num_not_obj);
	flg_DMS = 0;
	for( n7 = 0; n7 < num_chans_not; n7++)
	{
	class_id_a = NULL;
	status = om$get_classid
	(objid = list_noti[n7].S_objid,
	osnum = list_noti[n7].osnum,
	p_classid = &class_id_a);
	if( class_id_a = OPP_DMsrc_class_id)
	{
	flg_DMS++;
	}  //if( class_id_a
	}  //for( n7 = 0; n7 < num
	flg_dmy = 0;
       for( n1 = 0; n1 < num_chans_not; n1++)
       {
	 class_id_a = NULL;
	 status = om$get_classid
			(objid = list_noti[n1].S_objid,
			osnum = list_noti[n1].osnum,
			p_classid = &class_id_a);
	if( class_id_a = OPP_DMsrc_class_id)
	{
	flg_dmy++;
	num_chans_ass = 0;
	status = om$get_channel_count( objid = list_noti[n1].S_objid ,
				      osnum = list_noti[n1].osnum,
				      p_chanselect = &list_ASS,
				      count = &num_chans_ass);
        if(num_chans_ass > 0)
	{
	list_asso=(OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE)
				* num_chans_ass);
	
	status = om$get_channel_objects(objid = list_noti[n1].S_objid ,
					osnum = list_noti[n1].osnum,
					p_chanselect = &list_ASS,
					list = list_asso,
					size = num_chans_ass,
					count = &num_ass_obj);
	flg_AS=0;
	for(n6=0; n6 < num_chans_ass; n6++)
	{
	class_id_b = NULL;
	status = om$get_classid
		 ( objid = list_asso[n6].S_objid,
		  osnum = list_asso[n6].osnum,
		   p_classid = &class_id_b);
	if( class_id_b == OPP_ASsource_class_id)
	flg_AS++;

	}
	if(flg_AS == 0)
	{
	NOTIFY_FLG = TRUE;
	}
	else
	NOTIFY_FLG = FALSE;
	if((flg_dmy == flg_DMS) && (NOTIFY_FLG))
	{
	goto src_flg;
	}
	for( n3 = 0; n3 < num_chans_ass; n3++)
	{
	 class_id_b = NULL;
	 status = om$get_classid
		(objid = list_asso[n3].S_objid,
		osnum = list_asso[n3].osnum,
		p_classid = &class_id_b);
	if( class_id_b == OPP_ASsource_class_id)
	{ 
	num_chans_comp = 0;
	status = om$get_channel_count( objid = list_asso[n3].S_objid ,
				     osnum = list_asso[n3].osnum,
				     p_chanselect = &list_COMP,
				     count = &num_chans_comp);
	   if(num_chans_comp > 0)
	  {
	list_comp=(OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE)
					* num_chans_comp);
	status = om$get_channel_objects(objid = list_asso[n3].S_objid ,
					osnum = list_asso[n3].osnum,
					p_chanselect = &list_COMP,
					list = list_comp,
					size = num_chans_comp,
					count = &num_comp_obj);
	     for( n4 = 0; n4 < num_chans_comp; n4++)
	     {
		for( n2 = 0; n2 < *nb_obj; n2++)
		{
	  	if( list_comp[n4].S_objid == obj_lst[n2].objid)
		{
	   	NOTIFY_FLG = TRUE;
		goto src_flg;
		}
		}      // for( n2 = 0; n2 < *nb_obj; n2++)
	      }        //  for( n4 = 0; n4 < n 
	     }         // if(num_chans_comp > 0)
	    }          // if( class_id_b == OPP_ASsource_class_id)
	   }           // for( n3 = 0; n3 < num_ch
	  }            // if(num_chans_ass > 0)
	 }             // if( class_id_a
       }               //for( n1 = 0; n1 
     }                 // if(num_chans_not > 0)
   }                   // if((om$is_ancestry

src_flg:
	  if( !NOTIFY_FLG)
	  {
	  status = ASmake_source_from_go( msg ,&obj_lst[ind],&null_grid,
			obj_lst[ind].osnum, &as_obj);
	  }
	  else
	    status= ASget_source(&obj_lst[ind],&null_grid,&as_obj,
                                 obj_lst[ind].osnum);

	    if(as_obj.objid == NULL_OBJID)
	      {
	      /*| Test assoc objects */

	      status = om$get_classid
			 (objid = obj_lst[ind].objid,
			  osnum = obj_lst[ind].osnum,
			  p_classid = &class_id);


	      if(om$is_ancestry_valid(subclassid = class_id,
		      superclassname = "NDnode") == OM_S_SUCCESS)
                {
                  sts = om$send(msg = message GRgraphics.GRgetprops(msg,
                                                           &obj_props),
                                senderid = NULL_OBJID,
                                targetid = obj_lst[ind].objid,
                                targetos = obj_lst[ind].osnum);

                 if(obj_props & GRIS_ASSOCIATIVE || 
                             (om$is_ancestry_valid(subclassid = class_id,
                               superclassname = "DMdim") == OM_S_SUCCESS)
                            ||(om$is_ancestry_valid(subclassid = class_id,
                               superclassname = "DMannot") == OM_S_SUCCESS))
                    { 
		      status = om$get_classid
				 (objid = obj_lst[ind].objid,
				  osnum = obj_lst[ind].osnum,
				  p_classid = &class_id);
	
		      if(om$is_ancestry_valid(subclassid = class_id,
			      superclassname = "EMinstance") != OM_S_SUCCESS)
                	{     
		               as_obj.objid = obj_lst[ind].objid;
		               as_obj.osnum = obj_lst[ind].osnum;
                	}
                     }
  		  }
	      }

	    if(as_obj.objid != NULL_OBJID)
	      {

	      if(l_assoc == NULL)
	       {
		/*| Allocate the temporary list */

		s_lassoc = *nb_obj-ind;
		if(s_lassoc > GMH_DEF_SIZE) s_lassoc = GMH_DEF_SIZE;
		l_assoc  = (struct GRid *)malloc(s_lassoc*sizeof(struct GRid));
		if(l_assoc == NULL) 
                  {
                    ASMreset_splitpart();
                    *msg = MSFAIL;
                    sts = OM_E_ABORT;
                    goto quit;
                  }
 
	       }

	      if(nb_assoc >= s_lassoc)
	       {
		/*| Reallocate the temporary list */

		s_lassoc = s_lassoc + ASM_DEF_SIZE;
		l_assoc  = (struct GRid *)realloc(l_assoc,
                                              s_lassoc*sizeof(struct GRid));
		if(l_assoc == NULL) 
                  {
                     ASMreset_splitpart();
                     *msg = MSFAIL;
                     sts = OM_E_ABORT;
                     goto quit;
                  }
	       }

	      /* Put this object in the assoc list.*/

	       l_assoc[nb_assoc].objid = as_obj.objid;
	       l_assoc[nb_assoc].osnum = as_obj.osnum;
               nb_assoc++;
	      }
	    else
	      {
	      /*| Copy the graphic object */
	      status = om$get_classid
				(objid = obj_lst[ind].objid,
				 osnum = obj_lst[ind].osnum,
				 p_classid = &class_id);
	     

		if(class_id != OPP_GRcompcurve_class_id)
	     {
	      status = om$send(msg      = message GRgraphics.GRcopy
				    (msg, &md_env, &to_env, &copy.objid),
                         senderid = NULL_OBJID,
			 targetid = obj_lst[ind].objid,
			 targetos = obj_lst[ind].osnum);

              di$untranslate(objname = obj_name,
                             objid = obj_lst[ind].objid,
                             osnum = obj_lst[ind].osnum);
            
              if(obj_name[0])
               {
                   di$split(pathname = obj_name,
                            name = tmp_name); 

                   di$give_pathname(osnum = to_env.md_id.osnum,
                                    pathname = pathname);

	      if(om$is_ancestry_valid(subclassid = class_id,
		      superclassname = "GRreffile") == OM_S_SUCCESS)
                 {
                   strcat(pathname,":ref:refnames:");
                 }
              else
                 {
                   strcat(pathname,":usr:");
                 }

                   di$add_name(objname = tmp_name,
                               path = pathname,
                               osnum = to_env.md_id.osnum,
                               objid = copy.objid);
               }
	      cp_gr_obj[nb_cpobj].objid = copy.objid;
	      cp_gr_obj[nb_cpobj].osnum = to_env.md_id.osnum;
	      gr_obj[nb_cpobj].objid = obj_lst[ind].objid;
	      gr_obj[nb_cpobj].osnum = obj_lst[ind].osnum;
              cp_objects[nb_cpobj].objid = obj_lst[ind].objid;
              cp_objects[nb_cpobj].osnum = obj_lst[ind].osnum;
              nb_cpobj++;

	     }
	      }
	 }

         if(nb_assoc == 0)
         {
	  assoc_flg = TRUE;
         }
	 
   if(!assoc_flg)
   {
        graph = (struct GRid *)malloc(nb_assoc * sizeof(struct GRid) * 
                                      ASM_DEF_SIZE);
        
        if(graph == NULL)
         {
            trace(printf("malloc failed\n"));
            *msg = MSFAIL;
            sts = OM_E_ABORT;
            goto quit;
         }

        graph_mem = nb_assoc * ASM_DEF_SIZE;

        for(i = nb_assoc - 1; i >= 0 ; i = i-1)
           {

                flag1 = 0;

                for(j = 0; j < nb_parents; j++)
                   {
                       if((graph[j].objid == l_assoc[i].objid) &&
                          (graph[j].osnum == l_assoc[i].osnum))
                        {
                           flag1 = PARENT_IN_LIST;
                           break;
                        }
                   }

                if(flag1 != PARENT_IN_LIST)
                 {
                   nb_selected = 0;
                   sts = om$send(msg = message NDnode.NDselect_copy(msg,
                                                     0,NULL,NULL,0,
                                                     &nb_selected),
                                senderid = NULL_OBJID,
                                targetid = l_assoc[i].objid,
                                targetos = l_assoc[i].osnum);
                   
                   trace(printf("1node: %d\n",l_assoc[i].objid));
                   trace(printf("1num_parents: %d\n",nb_selected));
                   s_obj = (struct GRid *)malloc( nb_selected * 
                                                  sizeof(struct GRid));
                   if(s_obj == NULL)
                    {
                       trace(printf("malloc failed\n"));
                       *msg = MSFAIL;
                       sts = OM_E_ABORT;
                       goto quit;
                    }

                   info = (IGRint *)malloc(nb_selected * sizeof(IGRint));
                   if(info == NULL)
                    {
                       trace(printf("malloc failed\n"));
                       *msg = MSFAIL;
                       sts = OM_E_ABORT;
                       goto quit;
                    }
                    s_size = nb_selected;
                    for(j=0; j < s_size; j++)
                       info[j] = ND_ROOT|ND_BODY;

                    sts = om$send(msg = message NDnode.NDselect_copy(msg,
                                                     0,s_obj,info,s_size,
                                                     &nb_selected),
                                senderid = NULL_OBJID,
                                targetid = l_assoc[i].objid,
                                targetos = l_assoc[i].osnum);

                   for(j=0; j < nb_selected; j++)
                     {
                        flag2 = 0;
                        for(l=0; l < nb_parents; l++)
                          {
                            if((graph[l].objid == s_obj[j].objid) &&
                               (graph[l].osnum == s_obj[j].osnum))
                             {
                                flag2 = PARENT_IN_LIST;
                                break;
                             }
                          }
                        if(flag2 != PARENT_IN_LIST)
                         {
                           if(graph_mem <= nb_parents)
                            {
                             graph_mem = graph_mem + ASM_DEF_SIZE;
		             graph  = (struct GRid *)realloc(graph,
                                             graph_mem * sizeof(struct GRid));
		             if(graph == NULL) 
                              {
                                 ASMreset_splitpart();
                                 *msg = MSFAIL;
                                 sts = OM_E_ABORT;
                                 goto quit;
                              }
                            }
                           if((s_obj[j].objid > 0) && 
                              (s_obj[j].objid != NULL_OBJID))
                            {
                              graph[nb_parents].objid = s_obj[j].objid;
                              graph[nb_parents].osnum = s_obj[j].osnum;
                              nb_parents++;
                              trace(printf("1parents: %d\n",s_obj[j].objid));
                            }
                         }
                     }
                     if(s_obj) 
                      {
                        free(s_obj);
                        s_obj = NULL;
                      }
                     if(info)
                      {
                         free(info);
                         info = NULL;
                      }
                 }
           }
 
        gm$init_graph(nb_elmt = nb_parents,
                      inc_elmt = nb_parents,
                      p_graph = &frm_graph);

        status = nd$get_internal_graph(p_initial = graph,
                                       nb_initial = nb_parents,
                                       p_graph = &frm_graph);
      while(!correct_graph)
       {

        flag2 = 0;
        p_hcode = frm_graph.p_hcode;

        for(index0=0; index0 < frm_graph.nb_elmt; index0++)
         {
            index1 = frm_graph.l_ord_elmt[index0];
            position = ((struct GMelmt *)GMh_content(p_hcode,index1))->int_attr;
            if( (position & ND_EXTERN) && (!(position & (ND_TIP|ND_ROOT))))
             {
               ext_id.objid = ((struct GRid *)GMh_key(p_hcode,index1))->objid;
               ext_id.osnum = ((struct GRid *)GMh_key(p_hcode,index1))->osnum;
	       status = om$get_classid
	 		  (objid = ext_id.objid,
			   osnum = ext_id.osnum,
			   p_classid = &class_id);
	      if(om$is_ancestry_valid(subclassid = class_id,
		      superclassname = "dim_param") != OM_S_SUCCESS)
               {
                 num_child = 0;

                 sts = om$send(msg = message NDnode.NDget_objects(
                                      ND_CHILDREN|ND_IN_BUF,NULL,0,&p_obj,
                                      0,OM_K_MAXINT,&num_child),
                               senderid = NULL_OBJID,
                               targetid = ext_id.objid,
                               targetos = ext_id.osnum);
                 if(num_child != 0)
                  {
                  for(z=0; z<num_child; z++)
                   {
                     nb_selected = 0;
                     sts = om$send(msg = message NDnode.NDselect_copy(msg,
                                                       0,NULL,NULL,0,
                                                       &nb_selected),
                                  senderid = NULL_OBJID,
                                  targetid = p_obj[z].objid,
                                  targetos = p_obj[z].osnum);
                     trace(printf("2node: %d\n",p_obj[z].objid));
                     trace(printf("2num_parents: %d\n",nb_selected));
                     s_obj = (struct GRid *)malloc( nb_selected * 
                                                    sizeof(struct GRid));
                     if(s_obj == NULL)
                      {
                         trace(printf("malloc failed\n"));
                         *msg = MSFAIL;
                         sts = OM_E_ABORT;
                         goto quit;
                      }

                     info = (IGRint *)malloc(nb_selected * sizeof(IGRint));
                     if(info == NULL)
                      {
                         trace(printf("malloc failed\n"));
                         *msg = MSFAIL;
                         sts = OM_E_ABORT;
                         goto quit;
                      }
                     s_size = nb_selected;
                     for(j=0; j < s_size; j++)
                       info[j] = ND_ROOT|ND_BODY;

                     sts = om$send(msg = message NDnode.NDselect_copy(msg,
                                                       0,s_obj,info,s_size,
                                                       &nb_selected),
                                  senderid = NULL_OBJID,
                                  targetid = p_obj[z].objid,
                                  targetos = p_obj[z].osnum);
                     for(j=0; j < nb_selected; j++)
                      {
                        flag1 = 0;
                        for(l=0; l < nb_parents; l++)
                          {
                            if((graph[l].objid == s_obj[j].objid) &&
                               (graph[l].osnum == s_obj[j].osnum))
                             {
                                flag1 = PARENT_IN_LIST;
                                break;
                             }
                          }
                        if(flag1 != PARENT_IN_LIST)
                         {
                           if(graph_mem <= nb_parents)
                            {
                             graph_mem = graph_mem + ASM_DEF_SIZE;
		             graph  = (struct GRid *)realloc(graph,
                                              graph_mem *sizeof(struct GRid));
		             if(graph == NULL) 
                              {
                                 ASMreset_splitpart();
                                 *msg = MSFAIL;
                                 sts = OM_E_ABORT;
                                 goto quit;
                              }
                            }
                           if((s_obj[j].objid > 0) && 
                              (s_obj[j].objid != NULL_OBJID))
                            {
                              graph[nb_parents].objid = s_obj[j].objid;
                              graph[nb_parents].osnum = s_obj[j].osnum;
                              nb_parents++ ;
                              flag2 = GET_GRAPH_AGAIN;
                              trace(printf("2parents: %d\n",s_obj[j].objid));
                            }
                         }
                      }
                      if(s_obj)
                       {
                         free(s_obj);
                         s_obj = NULL;
                       }
                      if(info)
                       {
                         free(info);
                         info = NULL;
                       }
                    }
                   }
                }
             }
         }

        if(flag2 == GET_GRAPH_AGAIN)
         {
           gm$free_graph(p_graph = &frm_graph);

           gm$init_graph(nb_elmt = nb_parents,
                         inc_elmt = nb_parents,
                         p_graph = &frm_graph);

           status = nd$get_internal_graph(p_initial = graph,
                                          nb_initial = nb_parents,
                                          p_graph = &frm_graph);
         }
        else
         {
            correct_graph = TRUE;
         }

       }

        clone.list = NULL;
        modid = to_env.md_id.objid;
        to_env.md_id.objid = NULL_OBJID;

        status = nd$copy_graph( from_info = &md_env,
                                to_info = &to_env,
                                type_graph = ND_COPY_TIP,
                                p_graph = &frm_graph,
                                p_clone = &clone);
       if(!(status & 1))
        {
          gm$free_graph(p_graph = &frm_graph);
	  sts = ex$close_module(ftype = EX_invisible, flag = 1,index = file_no);
	  if (!(1 & sts)) trace(printf("save_module failed: sts = %d\n", sts));
          *msg = MSFAIL;
           sts = OM_E_ABORT;
           goto quit;
        }
        ex$message(field = ERROR_FIELD, msgnumb = EMS_M_SaveElemProgress);
        to_env.md_id.objid = modid;

        cp_graph = (struct GRid *)malloc(nb_parents * sizeof(struct GRid));

        if(cp_graph == NULL)
         {
          trace(printf("malloc failed\n"));
	  sts = ex$close_module(ftype = EX_invisible, flag = 1,index = file_no);
	  if (!(1 & sts)) trace(printf("save_module failed: sts = %d\n", sts));
          *msg = MSFAIL;
          sts = OM_E_ABORT;
          goto quit;
         }
        z = 0;

        for(j=0; j < nb_parents; j++)
          {
               for(k=0; k < clone.nb_obj; k++)
                {
                  if(graph[j].objid == clone.list[k].original)
                    {
                        cp_graph[z].objid = clone.list[k].clone;
                        cp_graph[z].osnum = to_env.md_id.osnum;
                        z++;
                        break;
                    }
                }
          }

        gm$init_graph(nb_elmt = z,
                      inc_elmt = z,
                      p_graph = &to_graph);

        status = nd$get_internal_graph(p_initial = cp_graph,
                                       nb_initial = z,
                                       p_graph = &to_graph);

        status = nd$update_graph(md_env = &to_env,
                                 cn_type = ND_COMP|ND_COMP_NO_REM_RT,
                                 root_compute = ND_UPT_ROOT,
                                 p_graph = &to_graph);

        ex$message(field = ERROR_FIELD, msgnumb = EMS_M_SaveElemProgress);
	
   }  // if(!asso

/*	if GRcompcurve exist in original graph, we have copied all of
	its element till not. So, now we will join it back to get
	GRcompcurve in new file.
*/
	compcv_id.objid = NULL;
	compcv_id.osnum = NULL;
	 compcv_id.osnum = to_env.md_id.osnum;
	for(j4=0;j4<num_ori;j4++)
	{
	status_n = om$get_classid(osnum = obj_list[j4].osnum,
				  objid = obj_list[j4].objid,
				  p_classid = &classid_n);
	if(classid_n == OPP_GRcompcurve_class_id)
	{
	struct GRvg_construct  construct_list;
	struct IGRdisplay     dis;
	num_chans = 0;
	status = om$get_channel_count( objid = obj_list[j4].objid,
				       osnum = obj_list[j4].osnum ,
				       p_chanselect = &list_chan,
				       count = &num_chans);
	list_id=(OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
							num_chans);
	GRinfo = (struct GRlc_info *) malloc
			(sizeof(struct GRlc_info) * num_chans);
	status = om$get_channel_objects(objid = obj_list[j4].objid,
					osnum = obj_list[j4].osnum ,
					p_chanselect = &list_chan,
					list = list_id,
					size = num_chans,
					count = &num_cur_obj);
	
	for(j2=0;j2<num_chans;j2++)
	{
	for(j5=0;j5<nb_cpobj;j5++)
	{
	if(gr_obj[j5].objid == list_id[j2].S_objid)
	{
	GRinfo[j2].located_obj.objid = cp_gr_obj[j5].objid;
	GRinfo[j2].located_obj.osnum = to_env.md_id.osnum;
	GRinfo[j2].module_info = to_env;
	}	
	}
	if(!assoc_flg)
	{
	for (index0=0;index0<frm_graph.nb_elmt;index0++)
	{
	num_chans2 = 0;
	to_hcode1  = to_graph.p_hcode;
	index1 = frm_graph.l_ord_elmt[index0];
	index2 = to_graph.l_ord_elmt[index0];
	frm_id = (struct GRid *)GMh_key(p_hcode,index1);
	to_id = (struct GRid *)GMh_key(to_hcode1,index2);
	
	status = om$get_channel_count( objid = frm_id->objid ,
				       osnum = md_env.md_id.osnum,
				       p_chanselect = &list_AS,
				       count = &num_chans2);
	if(num_chans2 > 0)
	{
	list_src=(OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
				num_chans2);
	
	status = om$get_channel_objects(objid = frm_id->objid,
					osnum = md_env.md_id.osnum,
					p_chanselect = &list_AS,
					list = list_src,
					size = num_chans2,
					count = &num_cur_obj2);
	
	for(j33=0;j33<num_chans2;j33++)
	{
	status_n = om$get_classid(osnum = list_src[j33].osnum,
				  objid = list_src[j33].S_objid,
				  p_classid = &classid_n2);

	if( list_src[j33].S_objid  == list_id[j2].S_objid )
	{
        status = om$get_channel_count( objid = to_id->objid ,
					       osnum = to_env.md_id.osnum,
					       p_chanselect = &list_AS4,
					       count = &num_chans4);
      list_src4=(OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
				num_chans4 );
        status = om$get_channel_objects(objid = to_id->objid,
					osnum = to_env.md_id.osnum,
					p_chanselect = &list_AS4,
					list = list_src4,
					size = num_chans4,
					count = &num_cur_obj4);
	for(j44=0;j44<num_chans4;j44++)
	{

        status_m = om$get_classid(osnum = list_src4[j44].osnum,
				  objid = list_src4[j44].S_objid, 
				  p_classid = &classid_n4);
	GRinfo[j2].located_obj.objid = list_src4[j44].S_objid;
	GRinfo[j2].located_obj.osnum = to_env.md_id.osnum;
	GRinfo[j2].module_info = to_env;
	}  // for(j33=0;j33<num_chans2;j33++)
	}  // end of if statment
	}  // for(j2=0;j2<num_chans2;j2+
	}  // if (num_chans 
	}  // end of for (index0=0; 
	}  // if ! assoc_flg
	}  // end of for(j2=0;j2<
	

	dis.color = 1;
	dis.style = 0;
	dis.weight =0;

	construct_list.msg        = (IGRlong *)&msg;
	construct_list.class_attr = NULL;
	construct_list.level      = 1;    // me->ActiveLevel;
	construct_list.display    = &dis;
	construct_list.env_info   = &to_env;
	construct_list.newflag    = FALSE;
	construct_list.name       = NULL;
	construct_list.properties = GRIS_NEW | GRIS_LOCATABLE
				    | GRIS_DISPLAYABLE;


	compcv_id.osnum = to_env.md_id.osnum;
	sts = om$construct(classid = OPP_GRcompcurve_class_id,
			   p_objid = &compcv_id.objid,
			   osnum = to_env.md_id.osnum, 
			   msg = message GRgraphics.GRconstruct(
			   &construct_list) );
	compcv_id.osnum = to_env.md_id.osnum;

	sts = om$send(msg = message GRcompcurve.EMmakecomp(&msg1,
			    &to_env, num_chans, GRinfo,
			    &rotten_one),
			    senderid = NULL_OBJID,
			    targetid = compcv_id.objid,
			    targetos = compcv_id.osnum);

	}
	}
	if(!assoc_flg)
	{
	ASMtransfer_symb(&frm_graph, &to_graph,delete);
        gm$free_graph(p_graph = &frm_graph);
        gm$free_graph(p_graph = &to_graph);
	}
	sts = ex$close_module(ftype = EX_invisible, flag = 1, index = file_no);
	if (!(1 & sts)) trace(printf("save_module failed: sts = %d\n", sts));
        if(assoc_flg) ASMreset_splitpart();	
        /* Delete the objects if the delete option is requested */
	if(delete)
         if(*delete)
          {
	   dp$update(msg = &msg);
	   for(i1=0;i1<num_ori;i1++)
	   {
	   classid_n = NULL;
	   status_n = om$get_classid(osnum = obj_list[i1].osnum,
				     objid = obj_list[i1].objid,
				     p_classid = &classid_n);

	if(classid_n == OPP_GRcompcurve_class_id)
	{
	    status=om$send( msg = message Root.delete(1),
			    senderid = NULL_OBJID,
			    targetid =  obj_list[i1].objid,
			    targetos =  obj_list[i1].osnum); 
	}  
	}
	dp$update(msg = &msg);
           for(i = 0; i < nb_cpobj; i++)
            {
	    if(cp_objects[i].objid != NULL_OBJID)
             sts = om$send(msg = message GRgraphics.GRdelete(&msg1,&md_env),
                             senderid = NULL_OBJID,
                             targetid = cp_objects[i].objid,
                             targetos = cp_objects[i].osnum);
	

            }    
         }


quit:
    
   /* reset the static varibles */
     ASMreset_splitpart();
   /* free the pointers */
   if(cp_objects) free(cp_objects);
   if(!assoc_flg)
   {
   if(s_obj) free(s_obj);
   if(info) free(info);
   if(l_assoc)   free(l_assoc);
   if(graph)     free(graph);
   if(cp_graph)  free(cp_graph);
   }

   return(sts);       

}


end implementation EMSassoc;
