class implementation ACncpx;

#include "parametric.h"
#include "asbox.h"
#include "macro.h"
#include "AS_status.h"
#define AS_DEBUG

from ACmacro_defn import ACgive_upscan,ACgive_feet_desc,ACgive_name;
from ACpretend import ACgive_downscan;
from ACcomplex import ACget_other;

/*
   Find the real graphic corresponding to the template of a macro 
*/

/*
   For a macro occurence mac_grid, find  the real object corresponding to
   the template at index  
*/

extern OMuword  OPP_text_exp_class_id;

ACindex_template(mac_grid,index,downscan,real_temp)
struct GRid *mac_grid,*real_temp;
char *downscan;
int index;

/*.ACindex_template*/
{
  struct GRid parent,new_parent,mac_def,mac1_grid,def_obj;
  int status;
  long msg;
  OMuint index1, index3;
  int index2;
  int feet_num;
  struct myfeet *feet_desc;
  char new_down[160];
  char *macro_name;
  OMuword obj_class ;
IGRint	   nb_node;
OM_S_OBJID *node_list;
IGRint	nd_ind;

/* If the macro is not nested, get it directly */
/*"mac_grid %d %d index %d down_scan %s\n",mac_grid->objid,mac_grid->osnum,index,downscan */

   status = om$get_objid_at_index(objid = mac_grid->objid,
                                  osnum = mac_grid->osnum,
                                  p_chanselect = &ND_father,
                                  index = index,
                                  osnumaddr = &parent.osnum,
                                  objidaddr = &parent.objid);

   if(status&1)
    {
     /*" macro is not nested parent %d %d \n",parent.objid,parent.osnum */
     status = om$send(msg = message NDmacro.ACreturn_foot(&msg,downscan,
					                  real_temp,NULL,NULL),
		  senderid = NULL_OBJID,
		      targetid = parent.objid,
		      targetos = parent.osnum);
     /*"real temp %d %d \n",real_temp->objid,real_temp->osnum */
     if(!(status&1&msg)) {real_temp->objid = NULL_OBJID; return OM_W_ABORT;}
    }

   else
    {
     /*| macro is nested into another macro */
     /* Get this macro and its feet description, my index on its component
        channel, the object corresponding to me in the macro definition,
 	the object corresponding to my template in the macro definition
     */

     /* Get macro occurence that owned mac_grid */

     status = om$get_objid_at_index(objid = mac_grid->objid,
			            osnum = mac_grid->osnum,
			            p_chanselect = &AS_to_owner,
			            objidaddr = &mac1_grid.objid,
			            osnumaddr = &mac1_grid.osnum,
			   	    index = 0);
     as$status(action = RET_STATUS);
     /*"mac1_grid %d %d\n",mac1_grid.objid,mac1_grid.osnum */

     /* Get corresponding macro definition */

     status = om$send(msg = message ACcpx.find_macro(&mac_def),
		  senderid = NULL_OBJID,
		      targetid = mac1_grid.objid,
		      targetos = mac1_grid.osnum);
     as$status(action = RET_STATUS);
     /*"mac_def %d %d\n",mac_def.objid,mac_def.osnum */

    /* I_MOLD SPECIFIC FOR CI_MACRO PLACING SEVERAL SREWS MACROS */

    status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		     senderid = NULL_OBJID,
		     targetid = mac_def.objid,
		     targetos = mac_def.osnum);
     as$status(action = RET_STATUS);
     /*"macro name %s\n",macro_name */
     if(strcmp(macro_name,"MOscrarr") == 0 || strcmp(macro_name,"MOfeaarr") == 0)
       {
        return (ACindex_template(&mac1_grid,index+1,downscan,real_temp));
       }



     status = om$send(msg = message ACmacro_defn.ACgive_feet_desc
							(&feet_num,&feet_desc),
		  senderid = NULL_OBJID,
		      targetid = mac_def.objid,
		      targetos = mac_def.osnum);
     as$status(action = RET_STATUS);
			
     /* Get object corresponding to mac_grid in the macro definition */

     status = om$get_index(objid_c = mac1_grid.objid,
			   osnum_c = mac1_grid.osnum,
			   p_chanselect = &AS_to_comp,
			   objid = mac_grid->objid,
			   osnum2 = mac_grid->osnum,
			   indexaddr = &index1);
     as$status(action = RET_STATUS);
     /*"index1 %d \n",index1 */

     for(index2=0;index2<feet_num;index2++)
      {
       if(feet_desc[index2].pos == index1) break;
      }
     if(index2 > feet_num) {real_temp->objid = NULL_OBJID; return OM_W_ABORT;}

     index2 = feet_desc[index2].chan >>2;

     /*"index2 %d \n",index2 */

	status = om$send( msg = message ACcomplex.ACget_other(
					&msg,
					&nb_node,
					&node_list ),
			targetid = mac_def.objid,
			targetos = mac_def.osnum,
			senderid = NULL_OBJID );
	as$status( );

	if(nb_node<index2){ printf(" error in get other\n"); return 0; }

	def_obj.objid = node_list[index2];
	def_obj.osnum = mac_def.osnum;

/* MOD LU
     status = om$get_objid_at_index(objid = mac_def.objid,
                                    osnum = mac_def.osnum,
                                    p_chanselect = &AC_mother_chns,
                                    index = index2,
                                    osnumaddr = &def_obj.osnum,
                                    objidaddr = &def_obj.objid);
     as$status(action = RET_STATUS);
END MOD LU*/

     /*"def_obj %d %d\n",def_obj.objid,def_obj.osnum */

     /* Get object corresponding to the search parent in the macro definition */

     status = om$get_objid_at_index(objid = def_obj.objid,
                                    osnum = def_obj.osnum,
                                    p_chanselect = &ND_father,
                                    index = index,
                                    osnumaddr = &parent.osnum,
                                    objidaddr = &parent.objid);
     as$status(action = RET_STATUS);

     om$get_classid( objid = parent.objid,
                      osnum = parent.osnum,
                      p_classid = &obj_class);

     /*"obj_classs %d %d\n", obj_class, OPP_text_exp_class_id*/

     if(om$is_ancestry_valid(superclassid = OPP_text_exp_class_id,
			      subclassid = obj_class) == OM_S_SUCCESS)
        {
           real_temp -> objid = parent.objid ;
           real_temp -> osnum = parent.osnum ;
           return( 1 );
        }


     /*"parent %d %d\n",parent.objid,parent.osnum */

     /* Concatenate downscan if necessary */

     /*"Concatenate downscan if necessary\n"*/
     new_down[0] = '\0';
     while (1)
      {
       status = om$send(msg = message ACpretend.ACgive_downscan(new_down),
		        senderid = NULL_OBJID,
		        targetid = parent.objid,
		        targetos = parent.osnum);
       if(!(status&1)) break;

       /*"was pretend with downs_scan %s\n",new_down */
       status = om$get_objid_at_index(objid = parent.objid,
                                      osnum = parent.osnum,
                                      p_chanselect = &ND_father,
                                      index = 0,
                                      osnumaddr = &new_parent.osnum,
                                      objidaddr = &new_parent.objid);
       if(!(status&1)) {new_down[0] = '\0';}
       else parent = new_parent;
       if(new_down[0] != '\0')
	{
         if(downscan[0] != '\0')
	  {
	   strcat(new_down,":");
	   strcat(new_down,downscan);
	  }
	 strcpy(downscan,new_down);
        }
	 
       if(!(status&1)) break;
 
       /*" pretend with parent %d %d\n",parent.objid,parent.osnum */
      }
     /*"New downscan is %s\n",downscan */


     /* 2 possible case now either we have an object which belong to the
        same collection (created by the same macro) 
        or we have to get up one more level of nesting 
     */
     /*"get index %d %d and %d %d\n",def_obj.objid,def_obj.osnum,parent.objid,parent.osnum*/

	for( nd_ind=0; nd_ind<nb_node; nd_ind++ )
			if( parent.objid == node_list[nd_ind] ) break;
	/*" nd_ind : %d\n", nd_ind */
	if( nd_ind == nb_node )	status = 0;
	else	{ status = 1; index = nd_ind; }
/* MOD LU
     status = om$get_index(objid_c = mac_def.objid,
			   osnum_c = mac_def.osnum,
			   p_chanselect = &AC_mother_chns,
			   objid = parent.objid,
			   osnum2 = parent.osnum,
			   indexaddr = &index);
END MOD LU */
     if(!(status&1))
      {
       /*| We get up one level of nesting */
      
       status = om$get_index(objid_c = mac_def.objid,
			     osnum_c = mac_def.osnum,
			     p_chanselect = &ND_father,
			     objid = parent.objid,
			     osnum2 = parent.osnum,
			     indexaddr = &index3);
/* ANSI - changed index to index3*/
       index = index3;
       if(!(status&1)) {real_temp->objid = NULL_OBJID;return OM_W_ABORT;} 

       ACindex_template(&mac1_grid,index,downscan,real_temp);
      }
     else
      {
       /*| The object is in the same collection, retrieve it */
       
       for(index1 = 0; index1<feet_num ; index1++)
	{
	 index2 = feet_desc[index1].chan >> 2;
         if(index == index2)
           { index = feet_desc[index1].pos; break;}
	}
       if(index1 >= feet_num) {real_temp->objid=NULL_OBJID; return OM_W_ABORT;}
       /*" at index %d\n",index */

       status = om$get_objid_at_index(objid = mac1_grid.objid,
                             osnum = mac1_grid.osnum,
                             p_chanselect = &AS_to_comp,
                             index = index,
                             osnumaddr = &parent.osnum,
                             objidaddr = &parent.objid);

       if(!(status&1)){real_temp->objid = NULL_OBJID; return OM_W_ABORT;}
       /*" parent %d\n",parent.objid,parent.osnum*/

       if(downscan[0] != '\0')
        {
         status = om$send(msg = message NDmacro.ACreturn_foot(&msg,downscan,
							real_temp,NULL,NULL),
		  senderid = NULL_OBJID,
		        targetid = parent.objid,
			targetos = parent.osnum);
         if(!(status&1)) real_temp->objid = NULL_OBJID;
	}
       else
        {
	 *real_temp = parent;
        }
         /*" real_temp %d\n",real_temp->objid,real_temp->osnum*/

     }
    }
 return status;
}

ACname_template(mac_grid,temp_name,real_parent)
struct GRid *mac_grid,*real_parent;
char *temp_name;
/*.ACname_template*/
{
 int index,temp_num,dummy;
 struct sup *temp_desc;
 struct GRid macro_grid;
 int status;
 char downscan[160];

/* printf("entree de name_template\n"); */

 /* Get macro definition and template index */

 status = om$send(msg = message ACcpx.find_macro(&macro_grid),
		  senderid = NULL_OBJID,
		  targetid = mac_grid->objid,
		  targetos = mac_grid->osnum);
 as$status(action = RET_STATUS);

 status = om$send(msg = message ACmacro_defn.ACgive_upscan
				(&temp_num,&dummy,&temp_desc),
		  senderid = NULL_OBJID,
		  targetid = macro_grid.objid,
		  targetos = macro_grid.osnum);
 as$status(action = RET_STATUS);

 for(index=0;index<temp_num;index++)
  { if(strcmp(temp_name,temp_desc[index].prompt) == 0) break; }

 if(index>=temp_num) { real_parent->objid = NULL_OBJID; return OM_W_ABORT; }
 
 downscan[0]='\0';
 /*"call index_template with index %d\n",index */
 return(ACindex_template(mac_grid,index,downscan,real_parent));

}

end implementation ACncpx;
