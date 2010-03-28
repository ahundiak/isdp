/*
  ACcpx_defni.I
  robert patience
  21_jul_86
*/
class implementation ACcpx_defn;

#include "ctype.h"
#include "ASmacroi.h"
#include "macro.h"

#define AS_DEBUG

/* ========================================================================= */

method ACgive_temp_desc( int *temp_num;
		          struct stemp **xdtemp)
{
  *temp_num=me->tot_temp;
  *xdtemp=&me->xdtemp[0];  
  return( 1);
}

/* ========================================================================= */

method ACgive_feet_desc(int *feet_num;
			struct myfeet **v_myfeet) 
{
  *feet_num= me->feet_num;
  *v_myfeet= me->myfeet; 
  return( 1);
}

/* ========================================================================= */

method ACintpt_foot_dir(int *suc,*direct_index;char *foot_name;
			int *chan,*pos,*type,*index)
{
  int 	i;

  if(me->prop & ACsame_feet_in_set)
  {
    if(direct_index && *direct_index!=-1)
    {
      /*|ACmac.ACintpt_foot_dir using direct index */ 
      *chan=me->myfeet[ *direct_index].chan;
      *pos=me->myfeet[  *direct_index].pos;
      *type=me->myfeet[  *direct_index].prop;
      *index=*direct_index;
      *suc=1;
      return(1);
    }
  }

  *chan= -1;
/* old shit where the foot name use to be the index of the pretend. I don't
   know at all who used to depend on it.
   Just keep ot for "old macros" jla november 91
*/
  if( !(me->prop & ACcant_place_sym) && isdigit(foot_name[0]))
  {
   char *ch_end;

    /*|ACmac.ACintpt_foot_dir using numeric index */ 
    *chan=feet_numeric;
    *pos = strtol(foot_name,&ch_end,10);
    if(*ch_end == '\0') *suc = 1;
    /*"suc %d  pos %d\n",*suc,*pos */
    if (*suc) return(1);
  }

  for(i=0;i<me->feet_num;i++)
  {
    if(!strcmp(foot_name,me->myfeet[i].name))
    {
      *chan=me->myfeet[i].chan;
      *pos=me->myfeet[i].pos;
      *type=me->myfeet[i].prop;
      *index=i;
      *suc=1;
      if(me->prop & ACsame_feet_in_set && direct_index) *direct_index=i;
      return(1);
    }
  }
  as$status( sts = 0,
             string =
    ("intpt_footdir fail in macro %s for foot %s \n",me->macro_name,foot_name));
  *suc=0;
  return(1);
}

/* ========================================================================= */

method ACintpt_foot(int *suc;char *foot_name;int *chan,*pos, *type)
{
  int 	i;

  *chan= -1;
/* old shit where the foot name use to be the index of the pretend. I don't
   know at all who used to depend on it.
   Just keep ot for "old macros" jla november 91
*/
  if( !(me->prop & ACcant_place_sym) && isdigit(foot_name[0]))
  {
   char *ch_end;

    /*|ACmac.ACintpt_foot_dir using numeric index */ 
    *chan=feet_numeric;
    *pos = strtol(foot_name,&ch_end,10);
    if(*ch_end == '\0') *suc = 1;
    /*"suc %d  pos %d\n",*suc,*pos */
    if (*suc) return(1);
  }
/*"try to find >>%s<< in feet list\n", foot_name*/
  for(i=0;i<me->feet_num;i++)
  {
   /*"compare with >>%s<<\n",me->myfeet[i].name*/
    if(!strcmp(foot_name,me->myfeet[i].name))
    {
      *chan=me->myfeet[i].chan & 3;
      *pos=me->myfeet[i].pos;
      *type=me->myfeet[i].prop;
      *suc=1;
      return(1);
    }
  }

/*"intpt_footdir fail in macro %s for foot %s \n",me->macro_name,foot_name */

  *suc=0;
  return(1);
}
/* ========================================================================= */

method ACmax_graph_ft( int *max)
{
  int i;
  *max=0;
  for(i=0;i<me->feet_num;i++)
  {
    if((me->myfeet[i].chan & 3)== feet_in_graphic)
    {
    *max = *max + 1;
    }
  }
  return( 1);
}

/* ========================================================================= */

method ACgive_name(char **macro_name) 
{
  *macro_name = me->macro_name; 
  return( 1);
}

end implementation ACcpx_defn;
