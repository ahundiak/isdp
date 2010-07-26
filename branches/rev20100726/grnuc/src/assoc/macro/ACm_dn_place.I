/*  
  ACm_dn_place.I
  robert patience
  21_jul_86
*/
class implementation ACmacro_defn;

#include "ASmacroi.h"
#include "macro.h"

#define AS_DEBUG

#define MAX_EXTERN_NB 200

extern IGRboolean ASbroadcast_in_progress;
extern struct GRid 	AC_construct_id;
extern char *strpbrk();


/* ========================================================================= */

method ACbuild_macro(		
	int *suc, prop;	char *macro_name;
	int tot_up;	struct GRid *tlist;	struct sup *xdup;
        int tot_temp;	struct stemp *xdtemp; 
	int feet_num;	struct myfeet *v_myfeet;	struct GRid *feet_list;
        struct GRid macro_hdr;			struct GRmd_env *md_env )
{
 long status;

  /* new ACbuild_macro, only written for internal graph option */
  status = om$send(msg = message ACmacro_defn.ACbuild_min_macro(
                 suc, prop, macro_name, tot_up, tlist, xdup, tot_temp,
                 xdtemp, feet_num, v_myfeet, feet_list, macro_hdr, md_env ),
                     targetid = my_id);
  return status;

}/* build_ACmacro_defn */

/* ========================================================================= */

method ACedit_template(int *suc,num_up,num_down;
		char **up_prompt,**up_scan,**temp_name,**dwnscan;
		int template_to_up[])
{
  struct sup 	*dup = NULL;
  struct stemp 	*dtemp = NULL;
  int 		found,i,j,status;

  *suc=1;
  me->tot_up=num_up;
  if(me->tot_temp!=num_down)
  {
    printf("ACedit_template template count wrong/n");*suc=0;
    return(1);
  }
  if(num_up) 
  {
    dup =(struct sup *) om$malloc(size=(num_up*sizeof(struct sup)));
    if(dup==NULL) { *suc=0; return(1); }
  }
  if(num_down) 
  {
    dtemp =(struct stemp *)  om$malloc(size=(num_down*sizeof(struct stemp)));
    if(dtemp==NULL) { *suc=0; return(1);}
  }

  for(i=0;i<num_up;i++)
  {
    strcpy(dup[i].prompt,up_prompt[i]);
    strcpy(dup[i].up_scan,up_scan[i]);
  }
  for(i=0;i<num_down;i++)
  {
    found=0;
    for (j=0;j<num_down;j++)
    {
      if(!strcmp(me->xdtemp[i].name,temp_name[j]))
      {
        /*"ACedit_template found i=%d,j=%d  \n",i,j */
    	found=1;
    	strcpy(dtemp[i].down_scan,dwnscan[j]);
    	strcpy(dtemp[i].name,temp_name[j]);
    	dtemp[i].back=template_to_up[j];
    	dtemp[i].type=me->xdtemp[i].type;
        if(dup[dtemp[i].back].up_scan[0]=='.')
          dup[dtemp[i].back].type=dtemp[i].type;
        else
         dup[dtemp[i].back].type=macro_generic;

    	if(template_to_up[j]>num_up)
     	{
     	  printf("ACedit_template range error upscan maping/n");*suc=0;
     	  return(1);
     	}
	/*"ACedit_template fin this one \n",i,j */
      }
    }
    if(!found)
    {
      printf("ACedit_template template name error\n");*suc=0;
      return(0);
    }
  }
  status = om$send(msg =  message ACmacro_defn.ACtake_template(num_up,dup,
                	                  num_down,dtemp),
		   targetid = my_id );
  as$status( action = CONTINUE );
  

  if(num_up && dup) om$dealloc(ptr=dup);
  if(num_down && dtemp ) om$dealloc(ptr=dtemp);

  return( 1 );
}

end implementation ACmacro_defn;

