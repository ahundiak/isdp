/*
/*---------------------------------------------------------------------------
/*
/*  ci_mac_defi.I
/*  Serge Frezefond ( ISDC Paris )
/*  21_jul_87
/*
/*---------------------------------------------------------------------------
/* */
class implementation ci_mac_def;

#define AS_DEBUG	

#include "igrdef.h"    
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "macro.h"
#include "acmacros.h"

/*--------------------------------------------------------------------------*/

method ACplace ( 
		IGRint   *suc;			
		IGRint prop;			IGRchar  *cpx_name;
                IGRchar  *int_name;		IGRint int_size;
		IGRint temp_num;	    	IGRchar **temp_names;
		IGRint *temp_types;
                IGRint temp_feet_num;     
                IGRint *temp_feet_index;   	IGRchar **temp_feet_names;
                IGRint intern_feet_num; 	IGRchar **intern_feet_names;
		IGRint *intern_feet_types;
                IGRint extern_feet_num; 	IGRchar **extern_feet_names;
                IGRint *extern_feet_types;
		IGRint *feet_order)
{
  IGRint     	i, status;
  struct GRid	macro;
  int extern_feet_real_num, temp_feet_real_num;
  
  ASsuper_construct();
/*** temp ***/
  me->prop = ACsame_feet_in_set|prop ;
  
  *suc = ac$find_macro_defn( action          = ACfind_no_load,
			     macro_name      = cpx_name,
		      	     p_macro_defn_id = &macro );
  if (*suc&1)
  {
    /*" the ci_mac_def for %s allready exist \n", cpx_name */
    *suc = 0;
  }
  else
  {
    *suc = 1;

    me->desc.int_size  = int_size;

    if(strlen(int_name)>= 16)
     {
        printf("ci_macro_definition, %s is a string too large\n",int_name);
        *suc=0;
     }
    else
     {
      strcpy ( me->desc.int_name, int_name );
     }

    if(strlen(cpx_name)>= 15)
     {
        printf("ci_macro_definition, %s is a string too large\n",cpx_name);
        *suc=0;
     }
    else
     {
      strcpy ( me->desc.ci_name, cpx_name );
     }

    if(strlen(cpx_name)>= macro_MAX_CHAR)
     {
        printf("ci_macro_definition, %s is a string too large\n",cpx_name);
        *suc=0;
     }
    else
     {
      strcpy ( me->macro_name, cpx_name );
     }

    me->tot_temp = temp_num;
    me->tot_up   = temp_num;
    me->feet_num = temp_feet_num + intern_feet_num + extern_feet_num;

    /*| allocating vla */

    status = om$vla_set_dimension( varray = me->xdtemp,
                                 size = me->tot_temp );
    as$status( action = RET_STATUS );

    status = om$vla_set_dimension( varray = me->xdup,
                                 size = me->tot_temp );
    as$status( action = RET_STATUS );


    /*| filling template structure */

    for(i = 0; i < temp_num; i++)
    {
      if(strlen(temp_names[i])>=macro_MAX_CHAR)
      {
        printf("ci_macro_definition, %s is a string too large\n",temp_names[i]);
        *suc=0;continue;
      }
      strcpy( me->xdup[i].prompt, temp_names[i] );
      strcpy( me->xdup[i].up_scan, "." );

      strcpy( me->xdtemp[i].name, temp_names[i] );
      strcpy( me->xdtemp[i].down_scan, "." );

      if(temp_types) 
      {
        me->xdup[i].type = temp_types[i] ;
        me->xdtemp[i].type = temp_types[i] ;
      }
      else
      {
        me->xdup[i].type = ~0;
        me->xdtemp[i].type = ~0;
      }

      me->xdtemp[i].back = i;
      me->xdtemp[i].direct_index = -1;
    }

    status = om$vla_set_dimension( varray = me->myfeet,
                                 size = me->feet_num );
    as$status( action = RET_STATUS );

    extern_feet_real_num = 0;
    temp_feet_real_num = 0;
    for(i = 0; i < temp_feet_num; i++)
    {
      if(strlen(temp_feet_names[i])>=macro_MAX_CHAR)
      {
       printf("ci_macro_definition, %s is a string too large\n",
							    temp_feet_names[i]);
        *suc=0;continue;
      }
      strcpy( me->myfeet[i].name, temp_feet_names[i] );
      if(temp_feet_index[i] >= 0)
       {
        me->myfeet[i].chan = feet_in_template;
        me->myfeet[i].pos = temp_feet_index[i];
        me->myfeet[i].prop = 0;
	temp_feet_real_num++;
       }
      else
       {
        me->myfeet[i].chan = feet_in_graphic;
        me->myfeet[i].pos = extern_feet_real_num++;
        me->myfeet[i].prop = 0;
       }
    }
    me->temp_feet_num = temp_feet_real_num;

     for(i = 0; i < intern_feet_num; i++)
    {
      if(strlen(intern_feet_names[i])>=macro_MAX_CHAR)
      {
       printf("ci_macro_definition, %s is a string too large\n",
							intern_feet_names[i]);
       *suc=0;continue;
      }
      strcpy( me->myfeet[temp_feet_num + i].name, intern_feet_names[i] );
      me->myfeet[temp_feet_num + i].chan = feet_virtual;
      me->myfeet[temp_feet_num + i].pos = i;
      if(intern_feet_types) 
        me->myfeet[temp_feet_num + i].prop = intern_feet_types[i];
      else
        me->myfeet[temp_feet_num + i].prop = 0;
    }
    me->intern_feet_num = intern_feet_num;

     for(i = 0; i < extern_feet_num; i++)
    {
      if(strlen(extern_feet_names[i])>=macro_MAX_CHAR)
      {
       printf("ci_macro_definition, %s is a string too large\n",
							extern_feet_names[i]);
       *suc=0;continue;
      }
      strcpy(   me->myfeet[temp_feet_num + intern_feet_num + i].name, 
		extern_feet_names[i] );
      me->myfeet[temp_feet_num + intern_feet_num + i].chan = feet_in_graphic;
      me->myfeet[temp_feet_num + intern_feet_num + i].pos =
						         extern_feet_real_num++;
      me->myfeet[temp_feet_num + intern_feet_num + i].prop = 0;
    }
    me->extern_feet_num = extern_feet_real_num;

    if(*suc)
     {
      *suc = ac$add_macro_name( osnum 		= OM_Gw_current_OS,
			      macro_name 	= cpx_name, 
			      macro_defn_id 	= my_id );
      if (!(*suc&1))
      {
        di$report_error ( sts = *suc );
        *suc = 0;
      }
     }
  }
  if(*suc) return OM_S_SUCCESS;
  else return OM_W_ABORT;
}

/*--------------------------------------------------------------------------*/

method ACgive_cim_desc( 
			IGRint  *suc;
                    	struct  ci_mac_st **p_desc;
			IGRint	*temp_feet_num, 
				*intern_feet_num, *extern_feet_num
                  )
{
  *p_desc 	   = &(me->desc);
  *temp_feet_num   = me->temp_feet_num;
  *intern_feet_num = me->intern_feet_num;
  *extern_feet_num = me->extern_feet_num;

  *suc = 1;
  return( OM_S_SUCCESS );
}

/*--------------------------------------------------------------------------*/

method ACunmap_hdr( struct GRid  sym )
{
  return( OM_S_SUCCESS );
}

/*--------------------------------------------------------------------------*/

method ACchange_ci_name ( 	IGRint  *status;
                       		IGRchar *new_ci_name )
{
  strcpy ( me->desc.ci_name, new_ci_name );
  *status = 1;

  return( OM_S_SUCCESS );
}


end implementation ci_mac_def;
