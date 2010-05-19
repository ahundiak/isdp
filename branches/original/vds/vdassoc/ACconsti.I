/* $Id:*/

/***************************************************************************
* I/VDS
*
* File:        vdassoc/ACconsti.I
*
* Description:
*
* Dependencies:
*
* Revision History:
* $Log: ACconsti.I,v $
* Revision 1.3  2001/09/07 15:07:08  ramarao
* Implemented CR# 5346.
*
* Revision 1.2  2001/09/07 14:55:09  ramarao
* Implemented CR# 5346.
*
* Revision 1.1  2001/01/18 19:08:41  ramarao
* Merged Service Pack Files to 262 pload.
*
# Revision 1.1  2000/10/05  15:04:20  pinnacle
# Created: vds/vdassoc/ACconsti.I by jpulapar for Service Pack
#
* History:
* MM/DD/YY  AUTHOR    DESCRIPTION
* 10/02/00  Jayadev   abort if the compute fails inside 
*		      ACcontext_compute_feet() method 
*
***************************************************************************/
class implementation ACconst;

#define AS_DEBUG

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"
#include "grownmacros.h"

extern IGRint ASgive_size_st();
extern char *strpbrk();

from ACmacro_defn import ACgive_feet_desc, ACgive_name,
			 ACcontext_compute_feet;

/* ========================================================================= */

method ACcontext_compute_feet(int count;
			struct GRid 	context_obj;
			struct GRid 	*feet_list;
			struct GRmd_env *md_env)
{
int status,compute_status,ret;
struct GRid *tlist;
int size,real_size,i,ibis;
IGRlong msg;
struct GRmd_env	emp_env,cur_env;
struct GRid mac_def;
struct myfeet *feet_desc;
char *mac_name;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

     status = om$send(msg = message ACmacro_defn.ACgive_name(&mac_name),
		      targetid = mac_def.objid,
		      targetos = mac_def.osnum);

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
  compute_status = status;
  // abort on compute_feet failure 
  if(!(status&1))
    {
      ret = gr$get_module_env(  buffer = &cur_env );
      if(cur_env.md_id.osnum == OM_Gw_current_OS)
         printf("MACRO COMPUTE ERROR : %s - [%d,%d]\n", mac_name, OM_Gw_current_OS, my_id);
      else if( OM_Gf_verbose_warning )
	 printf("MACRO COMPUTE ERROR : %s - [%d,%d]\n", mac_name, OM_Gw_current_OS, my_id);
      goto end_loop;
    }
  

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

end_loop:

  if(size) om$dealloc(ptr = tlist);
  
/*"count %d\n",count */
 return (  compute_status );
}

end implementation ACconst;
