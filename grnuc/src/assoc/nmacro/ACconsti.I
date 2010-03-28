/*
  ACconsti.I
  robert patience
  2-sept-89
*/
class implementation ACconst;

#define AS_DEBUG

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"
#include "grownmacros.h"

extern IGRint ASgive_size_st();
extern char *strpbrk();



from ACmacro_defn import ACintpt_foot,	ACintpt_foot_dir, 	
		ACgive_feet_desc,	ACgive_upscan, 		
		ACgive_temp_desc,		
	 	ACgive_name,
		ACconstruct_feet,ACcontext_compute_feet;


/* ========================================================================= */

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *fcount; struct GRid  *feet_list)
{
int status;
struct GRid mygrid;
extern GRclassid	OPP_ci_macro_class_id;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);
  
 mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

 status = om$send(msg = message ACmacro_defn.ACconstruct_feet
	(msg,NULL,count,mygrid,list,fcount,feet_list,md_env),
		      targetid=mac_def.objid,targetos=mac_def.osnum); 
 as$status();

 return(status );
}

/* ========================================================================= */

method ACcontext_compute_feet(int count;
			struct GRid 	context_obj;
			struct GRid 	*feet_list;
			struct GRmd_env *md_env)
{
int status,compute_status;
struct GRid *tlist;
int size,real_size,i,ibis;
IGRlong msg;
struct GRmd_env	emp_env;
struct GRid mac_def;
struct myfeet *feet_desc;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

/*^{ char *mac_name;
     status = om$send(msg = message ACmacro_defn.ACgive_name(&mac_name),
		      targetid = mac_def.objid,
		      targetos = mac_def.osnum);
     printf(" macro name %s\n",mac_name);
   }
*/

  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;
  emp_env.md_id.osnum=mac_def.osnum;

  size=0;
  if(!IF_EQ_OBJID(context_obj.objid,NULL_OBJID))
   {

    /* If the context has no member take the context as member of my component
       It occurs with conditional with different depth in the ownership graph:
       For a condition value, a foot is a graphic object
       For another value, this foot is a construction
       It was done in ACncpx ... but forgotten in ACconst
    */

   status =om$get_channel_count( osnum =context_obj.osnum,
				 objid =context_obj.objid ,
				p_chanselect = &AC_mto_graf_chns,
				count = (OMuint *)&real_size );
   if(!(status&1)) real_size = 0;
   size = count>real_size ? count : real_size;
   if(size)
    tlist = (struct GRid *) om$malloc (size = (size) * sizeof( struct GRid ));
   if(real_size)
    ACread(context_obj, &AC_mto_graf_chns, tlist, real_size);
   else 
    {
     for(i=0;i<count;i++) tlist[i] = context_obj;
     real_size = count;
    }


    status = om$send( msg = message ACmacro_defn.ACgive_feet_desc(
                        &ibis, &feet_desc),
                      targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status( action = RET_STATUS );


   /* Afect missing feet */
   for(i=0;i<count;i++)
    {
     if(IF_EQ_OBJID(feet_list[i].objid,NULL_OBJID)) continue;
 
     /* If not found, try to find another another feet with matching name */
     if(i >= real_size || tlist[i].objid == NULL_OBJID || pl_hold(tlist[i]))
        {
         char *c;
         int feet_name_len;
         /*"try to find another context for %s\n",feet_desc[i].name */

	 tlist[i].objid = NULL_OBJID;
         feet_name_len = strlen(feet_desc[i].name);
         c = feet_desc[i].name + feet_name_len -1;
         while(feet_name_len > 0 && *c >= '0' && *c <= '9')
             {c--; feet_name_len--;}

/* jla jan 93. Does not work when the new computed macro has less feet     */
/* (count) than the previous occurence (real_size) and if the instanciated */
/* feet are something like X1 X2 Y2 --> Y1				   */
/* for(ibis=0; ibis<count &&  ibis<real_size ; ibis++)			   */

         for(ibis=0; ibis<real_size ; ibis++)
          {
	   if(i==ibis) continue;
	   /*"i %d ibis %d tlist %d %d\n",i,ibis,tlist[ibis].objid,tlist[ibis].osnum */ 
	   if(tlist[ibis].objid == NULL_OBJID) continue;
           if(pl_hold(tlist[ibis])) continue;
           if(strncmp(feet_desc[i].name,feet_desc[ibis].name,feet_name_len) == 0)
             {
/*"WARNING feet %s is context of %s\n",feet_desc[ibis].name,feet_desc[i].name*/
              tlist[i] = tlist[ibis]; break;
             }
          }
        }
     }
   }
  
/* compute for real the macro or just recursive transfer of symbology
   It happens when a ci_macro contains as feet a macro occurence 
   jla feb 93*/

if(!(me->STATE & ncpx_root))
{
  status = om$send(msg = message ACmacro_defn.ACcontext_compute_feet
			(NULL,count,size,feet_list,tlist,&emp_env),
		      targetid=mac_def.objid,targetos=mac_def.osnum); 
  if(!(status&1))
	     printf("failure when recomputing %d %d\n",my_id,OM_Gw_current_OS);
  compute_status = status;

  for(i=0;i<count;i++)
   {
   /*" feet is %d %d\n",feet_list[i].objid,feet_list[i].osnum */
   if(!IF_NULL_OBJID(feet_list[i].objid))
    {
    status = om$send(msg = message NDmacro.ACcopy_to_Groot(&msg,ND_COMP, 
			&emp_env,md_env,&(feet_list[i])),
		       targetid = feet_list[i].objid,
		       targetos = feet_list[i].osnum);
    as$status ();
    }
   }
}
else
{
 for(i=0;i<count;i++)
  {if(feet_list[i].objid != NULL_OBJID)
   ACcontext_compute_component(&msg,feet_list+i,tlist+i,feet_list+i,&emp_env);
  }
 compute_status = OM_S_SUCCESS;
}


  if(size) om$dealloc(ptr = tlist);
  
/*"count %d\n",count */
 return (  compute_status );
}
/* ========================================================================= */

method ACget_foot_in_mac (long *msg;struct GRid my_foot,*mac_foot)
{
  int 			status,count,feet_s;
  OMuint 		i;
  struct GRid		*list,*feet_list,mygrid;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);



 mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;
   

  status =om$get_channel_count( objid = my_id,
				  p_chanselect = &AC_mto_graf_chns,
				  count = (OMuint *)&feet_s );

  status = om$get_index (	objid_c 		= my_id,
                                  	p_chanselect 	= &AC_mto_graf_chns,
                                  	indexaddr		= &i,
                                  	objid	        = my_foot.objid);
  as$status( action = RET_STATUS );

  if(feet_s)
   {
   feet_list=(struct GRid *)om$malloc(size = (feet_s) * sizeof( struct GRid ));
   }
 
  status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_template_chns,
				count = (OMuint *)&count );
  as$status(  );

  if(count==0)
   {printf("ACconst has no parents\n");return(0);}
 
  if(count)
   {
   list = (struct GRid *) om$malloc (size = (count) * sizeof( struct GRid ));
   }
  ACmagic_read(my_id, &AC_template_chns, list,count);

  status = om$send(msg = message ACmacro_defn.ACconstruct_feet
	(msg,NULL,count,mygrid,list,&feet_s,feet_list,NULL),
		      targetid=mac_def.objid,targetos=mac_def.osnum); 
  as$status();

  *mac_foot=feet_list[i];

  if(count) om$dealloc(ptr = list);
  if(feet_s) om$dealloc(ptr =feet_list );

 return (  OM_S_SUCCESS );
}
end implementation ACconst;
