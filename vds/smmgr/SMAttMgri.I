/* $Id: SMAttMgri.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smmgr / SMAttMgri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMAttMgri.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  08:59:18  pinnacle
# Replaced: smmgr/SMAttMgri.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 13 April 92  creation date.
/*      rmn : 1 Aug '94    modified SMGetAttType method, to handle more than
/*                         SM_MAX_ATT_LST no of attributes.
/*
/* */

class implementation SMAttMgr;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "msdef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include "VDmem.h"


#include "AS_status.h"

#define AS_DEBUG

from 	ACrg_collect	import  ACget_named_attribute, ACmod_list_attribute;
from 	ACrg_collect	import  ACadd_list_attribute, AClist_attribute;
from 	ACrg_collect	import  ACset_list_attribute;
from 	ACdyn_col	import	ACset_att_prop, ACget_att_prop;

/* ******************* MSG  SMGetAtt() ************************	*/

method SMGetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; IGRshort *type)
{
 IGRlong		status, loc_msg;
 IGRint                 i;
 IGRint                 direct_ind;
 struct ret_struct      str;
 IGRshort		int_prop, user_prop;

 *msg = MSFAIL;

 for(i=0;i<nb_att;i++)
  {
   /* Try the rg collection and see what type is it */
   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg,
				&att[i]),
                                p_chanselect = &ND_father,
                                from    = 0,
                                to      = 0 );
   as$status(action = RET_STATUS);
   if(loc_msg & 1)
    {
     if(type == NULL) continue;
     status = om$send(msg = message ACdyn_col.ACget_att_prop(&loc_msg,att[i].name,
   							&int_prop, &user_prop),
                                p_chanselect = &ND_father,
                                from    = 0,
                             	to      = 0 );
     if(!(status & loc_msg & 1)) 
      {
       /* Regular behaviour for objects which are sub-class of ACrg_collect */
       if(type != NULL) type[i] = SM_STATIC_ATT | SM_UNKNOWN_ATT;
       continue;
      }

     /* if(int_prop == 0 || user_prop ==0) 
     /*      printf("Warning, properties of attribute: %s not defined\n", att[i].name);
     /* */

     /* Set default (DYNAMIC | SYSTEM) when not def */
     if(user_prop == 0) user_prop = SM_SYST_ATT;
     
     type[i] = 0;
     type[i] = user_prop & AC_ATTRIB_MASK_USER;
     if(int_prop & AC_ATTRIB_LOCK)   type[i] |= SM_STATIC_ATT;
     else                            type[i] |= SM_DYNAMIC_ATT;
     continue;
    }

   /* Not found so try a foot */

   direct_ind = -1;
   status = om$send(msg = message ACncpx.ACgive_structure((int *) &loc_msg, 
   				&direct_ind, att[i].name, &str, NULL),
			/* mode 	 = OM_e_wrt_message, */
			targetid = my_id);
   as$status(action = RET_STATUS );
   if(!(loc_msg & 1))
    {
     /* Not found */
     return OM_S_SUCCESS;
    }
   /* It is a foot, is it and expression */
   if(!(str.type & parameter_generic))
    {
     /* It is not an expression, go to hell ... */
     return OM_S_SUCCESS;
    }
   if(str.type == double_type)
    {
     att[i].desc.type = AC_ATTRIB_DOUBLE;
     att[i].desc.value.att_exp = str.var.root_pm_st.value;
    }
  else if(str.type == text_type)
    {
     att[i].desc.type = AC_ATTRIB_TEXT;
     strcpy(att[i].desc.value.att_txt, str.var.text_st.text_string);
    }
   else
    {
     return OM_S_SUCCESS;
    }
  if(type != NULL) type[i] = SM_SYST_ATT | SM_DYNAMIC_ATT;
 }

*msg = MSSUCC;
return OM_S_SUCCESS;
}


/* ******************* MSG  SMListAtt() *********************** */

method SMListAtt(IGRlong *msg; IGRint list_len;
		 IGRint *nb_att; struct ACrg_coll *att; IGRshort *type)
{
 IGRlong 	status, loc_msg;
 int 		i, Nb;
 IGRshort		int_prop, user_prop;

 *msg = MSFAIL;

 if(list_len == 0 && nb_att != NULL)
  {
    status = om$send(msg = message ACrg_collect.AClist_attribute
		   (&loc_msg,list_len,NULL,nb_att),
		   p_chanselect = &ND_father,
		   from    = 0,
		   to      = 0 );
    if(!(status & loc_msg & 1)) return OM_W_ABORT;
    else { *msg = MSSUCC; return OM_S_SUCCESS; }
  }

 if(list_len > 0 && att != NULL && nb_att != NULL)
  {
    status = om$send(msg = message ACrg_collect.AClist_attribute
		     (&loc_msg,list_len,att,nb_att),
		     p_chanselect = &ND_father,
		     from    = 0,
		     to      = 0 );

    as$status();

    if(!(status & loc_msg & 1)) return OM_W_ABORT;
  }
 else return OM_W_ABORT;

 Nb = *nb_att;
 if(Nb > list_len) Nb = list_len;

 if(type != NULL) 
  {
   for(i=0;i<Nb;i++)
    {
     type[i] = 0;
     status = om$send(msg = message ACdyn_col.ACget_att_prop(&loc_msg, att[i].name,
   							&int_prop, &user_prop),
                                p_chanselect = &ND_father,
                                from    = 0,
                             	to      = 0 );
     if(!(status & loc_msg & 1)) 
      {
       /* Regular behaviour for objects which are sub-class of ACrg_collect */
       if(type != NULL) type[i] = SM_STATIC_ATT | SM_UNKNOWN_ATT;
       continue;
      }

#if 0
     if(int_prop == 0 || user_prop ==0)
      {
	printf("int_prop = %d user_prop = %d\n",int_prop,user_prop);
	printf("Warning, properties of attribute: %s not defined\n", att[i].name);
      }
#endif

     /* Set default (DYNAMIC | SYSTEM) when not def */
     if(user_prop == 0) user_prop = SM_SYST_ATT;

     type[i] = 0;
     type[i] = user_prop & AC_ATTRIB_MASK_USER;
     if(int_prop & AC_ATTRIB_LOCK)   type[i] |= SM_STATIC_ATT;
     else                            type[i] |= SM_DYNAMIC_ATT;
    }
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG  SMSetAtt() ************************	*/

method SMSetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		 IGRshort *type)
{
 IGRlong 	status, loc_msg;
 int i;


 /* Resend it to the rg coll (first root) 	*/
 /* Do not modify the type 			*/
 
 for(i = 0; i < nb_att; i++)
  {
    /* Try to modify attributes */
    status = om$send(msg = message ACrg_collect.ACmod_list_attribute
		     (
		      &loc_msg,
		      1,
		      &att[i]),
		     p_chanselect = &ND_father,
		     from    = 0,
		     to      = 0 );
    /* If fail try to add */
    if(!(status & loc_msg & 1)) 
     {
       status = om$send(msg = message SMAttMgr.SMAddAtt
			(&loc_msg,
			 1,
			 &att[i],
			 &type[i]),
			targetid = my_id);
       
       if(!(status & loc_msg & 1)) {*msg = MSFAIL; return status; }
     }
  }
 
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG SMResetAtt() ************************      */

method SMResetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		 IGRshort *type)
{
 IGRlong 	status, loc_msg;
 IGRint		i;
 IGRshort	int_prop, user_prop;

 *msg = MSFAIL;

 /* resend it to the rg coll (first root) */
 status = om$send(msg = message ACrg_collect.ACset_list_attribute(
						&loc_msg,
						nb_att,
						att),
                                p_chanselect = &ND_father,
                                from    = 0,
                                to      = 0 );
 
 if(!(status & loc_msg & 1)) return OM_W_ABORT;

/*
 * Attribute should be sub-class of SMcoll which is sub-class of ACdyn_attr.
 * Set the type to what we want.
 */

 for(i=0;i<nb_att;i++)
  {
   int_prop  = 0; 
   user_prop = 0;

   if(type)
    {
     if(type[i] & SM_STATIC_ATT)  int_prop |= AC_ATTRIB_LOCK;

     user_prop = type[i] & AC_ATTRIB_MASK_USER;
    }
   else 
    {
     /* By default dynamic & system */ 
     int_prop = 0;

     user_prop = SM_SYST_ATT;
    }

    
   status = om$send(msg = message ACdyn_col.ACset_att_prop(&loc_msg, att[i].name,
   							int_prop, user_prop),
                                p_chanselect = &ND_father,
                                from    = 0,
                             	to      = 0 );
   /* If ACrg_collect it does not understand it */
   /* if(!(status & loc_msg & 1)) return OM_W_ABORT; */
  }  
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

#define SM_MAX_ATT_LST 50

/* ******************* MSG SMGetAttType() ************************	*/

method SMGetAttType(IGRlong *msg; IGRshort type; 
		     IGRint *nb_att; struct ACrg_coll **att)
{
 IGRlong		status, loc_msg;
 IGRint			i, Nb, list_len;
 IGRshort		my_type[SM_MAX_ATT_LST];
 struct ACrg_coll	my_att[SM_MAX_ATT_LST];
 IGRshort               *l_type;
 struct ACrg_coll	*l_att;
 IGRshort		t1, t2;

 *msg    = MSFAIL;
 *nb_att = 0;
    
 /* Get the total number of attributes */
 status = om$send(msg = message SMAttMgr.SMListAtt(&loc_msg, 0, 
 					&Nb, NULL, NULL),
				targetid = my_id);
 if(!(status & loc_msg & 1)) return OM_W_ABORT;

 if(Nb > SM_MAX_ATT_LST) 
 {
    l_type = _MALLOC( Nb, IGRshort );
    l_att  = _MALLOC( Nb, struct ACrg_coll) ;

    list_len = Nb;
    status = om$send(msg = message SMAttMgr.SMListAtt(&loc_msg, list_len, &Nb, 
                                                      l_att, l_type),
				targetid = my_id);
    if(!(status & loc_msg & 1)) return OM_W_ABORT;
  }
  else
  {
     status = om$send(msg = message SMAttMgr.SMListAtt(&loc_msg, SM_MAX_ATT_LST,
 					&Nb, my_att, my_type),
				targetid = my_id);
     if(!(status & loc_msg & 1)) return OM_W_ABORT;
     l_att = my_att;
     l_type = my_type;
  }

 /* Split it into two sub-types */
 t1 = type & 0xF000;
 t2 = type & 0x0F00;

 *nb_att = 0;
 for(i=0;i<Nb;i++) if((t1 & l_type[i]) && (t2  & l_type[i])) (*nb_att)++;
   
/* commented out : see no purpose - rmn
 if(type == l_type[i])  (*nb_att)++;
*/

 (*att) = _MALLOC( (*nb_att), struct ACrg_coll);

 *nb_att = 0;
 for(i=0;i<Nb;i++) 
  {
   if((t1 & l_type[i]) && (t2  & l_type[i]))
    {
     (*att)[*nb_att] = l_att[i];
     (*nb_att)++;
    }
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG SMAddAtt() ************************	*/

method SMAddAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		 IGRshort *type)
{
 IGRlong 	status, loc_msg;
 IGRint		i;
 IGRshort	int_prop, user_prop;

 *msg = MSFAIL;


 /* resend it to the rg coll (first root) */
 status = om$send(msg = message ACrg_collect.ACadd_list_attribute(
						&loc_msg,
						nb_att,
						att),
                                p_chanselect = &ND_father,
                                from    = 0,
                                to      = 0 );
 
 if(!(status & loc_msg & 1)) return OM_W_ABORT;

/*
 * Attribute should be sub-class of SMcoll which is sub-class of ACdyn_attr.
 * Set the type to what we want.
 */

 for(i=0;i<nb_att;i++)
  {
   int_prop  = 0; 
   user_prop = 0;

   if(type)
    {
     if(type[i] & SM_STATIC_ATT)  int_prop |= AC_ATTRIB_LOCK;

     user_prop = type[i] & AC_ATTRIB_MASK_USER;
    }
   else 
    {
     /* By default dynamic & system */ 
     int_prop = 0;

     user_prop = SM_SYST_ATT;
    }

    
   status = om$send(msg = message ACdyn_col.ACset_att_prop(&loc_msg, att[i].name,
   							int_prop, user_prop),
                                p_chanselect = &ND_father,
                                from    = 0,
                             	to      = 0 );
   /* If ACrg_collect it does not understand it */
   /* if(!(status & loc_msg & 1)) return OM_W_ABORT; */
  }  
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/* ********************* MSG ACgive_structure () *******************	*/

method	ACgive_structure( IGRint *rc; IGRint *direct_ind; IGRchar *foot_name;
				struct ret_struct *str; 
				struct GRmd_env *md_env )
{
 IGRlong 		status;
 struct	ret_struct	my_str;
 IGRint			dir_index, *pt_dir_ind;

 if(direct_ind != NULL) pt_dir_ind = direct_ind;
 else {			pt_dir_ind = &dir_index; *pt_dir_ind = -1;}

 status = om$send(msg = message ACncpx.ACgive_structure(rc, pt_dir_ind,
			foot_name, str, md_env ),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );
 as$status(action = RET_STATUS);
 if( *rc & 1 )	return	OM_S_SUCCESS;

 /* If it is not found send it to the firts root (ACrg_collect) */

 /* At drawing extraction, it is null !!! */
 if(direct_ind != NULL) pt_dir_ind = direct_ind;
 else			pt_dir_ind = &dir_index;
 *pt_dir_ind = -1;

 status = om$send(msg = message NDmacro.ACgive_structure(rc, pt_dir_ind,
			foot_name, str, md_env ),
		p_chanselect = &ND_father,
		from	= 0,
		to	= 0);
 as$status(action = RET_STATUS);
 if( *rc & 1 )	return	OM_S_SUCCESS;

  /* If the system ask for the center of gravity cog_x, cog_y, cog_z */
  if(strncmp(foot_name,"cog_",4) != 0) 
    {
     *rc = 0;
      return OM_S_SUCCESS;
     }

 /* Look for special named feet (cog_x, cog_y, cog_z) for checkin */
 if(direct_ind != NULL) pt_dir_ind = direct_ind;
 else			pt_dir_ind = &dir_index;
 *pt_dir_ind = -1;
 status = om$send(msg = message NDmacro.ACgive_structure(rc, pt_dir_ind,
				"cog", &my_str,	md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
  as$status( action = RET_STATUS );
  if(!( *rc & 1 )) return OM_S_SUCCESS;

  if( ! strcmp( foot_name, "cog_x" ))
   {
		str->type = double_type;
		str->var.root_pm_st.value = my_str.var.point_st.pt[0];
		*rc	= 1;
		return	OM_S_SUCCESS;
   }

  if( ! strcmp( foot_name, "cog_y" ))
   {
		str->type = double_type;
		str->var.root_pm_st.value = my_str.var.point_st.pt[1];
		*rc	= 1;
		return	OM_S_SUCCESS;
   }

  if( ! strcmp( foot_name, "cog_z" ) )
   {
		str->type = double_type;
		str->var.root_pm_st.value = my_str.var.point_st.pt[2];
		*rc	= 1;
		return	OM_S_SUCCESS;
   }

 return	OM_S_SUCCESS;	
}


end implementation SMAttMgr;
 

