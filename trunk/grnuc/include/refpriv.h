#ifndef RF_priv

#define RF_priv 1

#ifndef ex_include		
#	include "ex.h"
#endif

#ifndef exdef_include		
#	include "exdef.h"
#endif

#define  Get_invisible_objid(index,mod_id) \
	{ \
	   extern struct EX_invisible_module *invisible_table; \
 	   *(mod_id) = (GRobjid)invisible_table[(index)].module_my_id; \
	}

#define  Get_invisible_id_from_osnum(osnum,mod_id) \
	{ \
	   int ___x;	\
	   extern struct EX_invisible_module *invisible_table; \
	   for (___x = 0; ___x < EX_MAX_INVIS_MODULES; ++___x)   \
	   { \
	      if ( invisible_table[___x].obj_space_num == (int)(osnum)) \
	      { \
		*(mod_id) = invisible_table[___x].module_my_id; \
		___x = EX_MAX_INVIS_MODULES;  \
	      } \
	   } \
	}

#define  Get_invisible_osnum(index, osnum) \
	{ \
	   extern struct EX_invisible_module *invisible_table; \
	   *(osnum) = (GRspacenum)(invisible_table[(index)].obj_space_num); \
	}

#define  Get_invisible_index(osnum,index) \
	{ \
	   int ___x;	\
	   extern struct EX_invisible_module *invisible_table; \
	   index = -1;\
	   for (___x = 0; ___x < EX_MAX_INVIS_MODULES; ++___x)   \
	   { \
	      if ( invisible_table[___x].obj_space_num == (int)(osnum)) \
	      { \
		index = ___x; \
		___x = EX_MAX_INVIS_MODULES; \
	      } \
	   } \
	}

#define  Get_module_info(msg1,my_osname,osnum,mod_id) \
	{ \
	   int ___x;	\
	   int ___ommsg; \
	   extern struct EX_invisible_module *invisible_table; \
	   *msg1 = MSSUCC; \
	   ___ommsg=om$os_name_to_number(osname = my_osname,p_osnum = osnum);\
	   if (1 & ___ommsg) \
	   { \
	     for (___x = 0; ___x < EX_MAX_INVIS_MODULES; ++___x)   \
	     { \
	        if (invisible_table[___x].obj_space_num == (int)(*osnum)) \
	        { \
		  *(mod_id) = invisible_table[___x].module_my_id; \
		  ___x = EX_MAX_INVIS_MODULES; \
	        } \
	     } \
	   }\
	   else \
	   { \
	     *msg1 = MSFAIL; \
	   } \
	}

#define  Increment_num_opens(osnum) \
	{ \
	   int ___x;	\
	   extern struct EX_invisible_module *invisible_table; \
	   for (___x = 0; ___x < EX_MAX_INVIS_MODULES; ++___x)   \
	   { \
	      if ( invisible_table[___x].obj_space_num == (int)(osnum)) \
	      { \
		++(invisible_table[___x].numof_opens); \
		___x = EX_MAX_INVIS_MODULES; \
	      } \
	   } \
	}

#define  Decrement_num_opens(osnum) \
	{ \
	   int ___x;	\
	   extern struct EX_invisible_module *invisible_table; \
	   for (___x = 0; ___x < EX_MAX_INVIS_MODULES; ++___x)   \
	   { \
	      if ( invisible_table[___x].obj_space_num == (int)(osnum)) \
	      { \
		--(invisible_table[___x].numof_opens); \
		___x = EX_MAX_INVIS_MODULES; \
	      } \
	   } \
	}

#define  Reset_num_opens(index) \
	{ \
	   extern struct EX_invisible_module *invisible_table; \
	   invisible_table[index].numof_opens = 0; \
	}

#define  Test_invisible(my_osnum,invisible) \
	{ \
	   int ___x;	\
	   extern struct EX_invisible_module *invisible_table; \
	   *invisible = 0; \
	   for (___x = 0; (___x < EX_MAX_INVIS_MODULES) && (! (*invisible)); ++___x)\
	   { \
	      if ( invisible_table[___x].obj_space_num == (int)(my_osnum)) \
	      { \
		*invisible = 1; \
		___x=EX_MAX_INVIS_MODULES; \
	      } \
	   } \
	}

#define  Get_ref_flag(index,flag) \
	{ \
	   extern struct EX_invisible_module *invisible_table; \
 	   (flag) = (GRobjid)invisible_table[(index)].ref_flag; \
	}

#define GRget_num_opens(msg,osnum,num) \
	{ \
	   int ___x;	\
	   extern struct EX_invisible_module *invisible_table; \
	   msg = MSFAIL; \
	   for (___x = 0; ___x < EX_MAX_INVIS_MODULES; ++___x)   \
	   { \
	      if ( invisible_table[___x].obj_space_num == (int)(osnum)) \
	      { \
		msg = MSSUCC;	\
		num = invisible_table[___x].numof_opens; \
		___x=EX_MAX_INVIS_MODULES; \
	      } \
	   } \
	}

#define GRgetprism(msgcod, mx_type, mx, absgptr, i)			\
if (! GRabsg_test(msgcod,mx_type,mx,&OM_Gw_current_OS,&my_id,absgptr))	\
{				\
	*msgcod=MSFAIL; \
	om$send( mode = OM_e_wrt_object, \
		 msg  = message GRclippoly.GRgenprism(msgcod,mx_type,mx,absgptr),\
		 senderid = my_id, \
		 targetid = my_id); \
}

#define Clear_invisible_entry(osnum) \
        { \
	   int ___x;	\
	   extern struct EX_invisible_module *invisible_table; \
	   for (___x = 0; ___x < EX_MAX_INVIS_MODULES; ++___x)   \
	   { \
	      if ( invisible_table[___x].obj_space_num == (int)(osnum)) \
	      { \
                invisible_table[___x].obj_space_num = 0; \
		invisible_table[___x].module_my_id = NULL_OBJID; \
		invisible_table[___x].filed_id = (unsigned long int) ~0; \
		invisible_table[___x].permis_flag = 0; \
		invisible_table[___x].numof_opens = 0; \
		invisible_table[___x].ref_flag = 0; \
		___x=EX_MAX_INVIS_MODULES; \
	      } \
	   } \
	}
#endif

