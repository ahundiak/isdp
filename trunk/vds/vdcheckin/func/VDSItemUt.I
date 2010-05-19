/* $Id: VDSItemUt.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / VDSItemUt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSItemUt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
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
# Revision 1.2  1996/05/03  15:43:50  pinnacle
# Replaced: vdcheckin/func/VDSItemUt.I for:  by sljenks for vds.240
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
 *	05/01/96	slj		changed free, malloc to _FREE, _MALLOC
 * -------------------------------------------------------------------*/

/*     

ABSTRACT : 

CHANGE HISTORY

Ch  31 Dec 1991  : Design date


*/

class implementation Root;


#include	"OMerrordef.h"
#include	"OMminimum.h"
#include	"OMmacros.h"
#include	"OMparameters.h"

#include	"igrtypedef.h"
#include	"igetypedef.h"
#include	"igr.h"
#include	"gr.h"
#include	"exdef.h"
#include	"exmacros.h"

#include 	"PDUerror.h"
#include 	"PDUstr.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"msdef.h"
#include	"msmacros.h"

#include	"ACdb_info.h"
#include	"ACattrib.h"

#include	"AS_status.h"
#include	"parametric.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"madef.h"

#include	"VDmem.h"
#include	"ACcheckin.h"
#include	"VDScheckdef.h"

#include	"VDSris_siz.h"
#include	"VDScheckin.h"

#include        "vdbmacros.h"

from NDmacro	import	ACgive_structure;


/*
/*  VDGetPartAttr:
/*
/*  Given an acii file describing the wanted attributes, retrieve the
/*  corresponding values. The ACgive_structure is used for dynamic
/*  attributes and a database query is used on static attributes.
/*
/*  The output array is allocated by the function and must be freed
/*  by the caller.
/* 
/*  If an attribute is not found it will be only skip.
/*
/*  Return TRUE if succesfull completion.
/*
/* */


VDGetPartAttr(file_name, part_id, catalog, partrev, partnum, nb_attr, attr_list)
char 			*file_name; /* ascii file name or NULL 	(I) */
struct GRid		*part_id;   /* drawing part id		(I) */
char			*catalog;   /* catalog name	       	(I) */
char			*partrev;   /* part revision		(I) */
char			*partnum;   /* part number		(I) */
int			*nb_attr;   /* number of attributes	(O) */
struct VDGRpart_attr   **attr_list; /* array of attributes	(O) */
{
 int 		    nb_part_attr, i, direct_index, msg, status; 
 struct VDpart_attr *part_attr;
 struct ret_struct  tmp_rts;
 char		    tmp[81];

 status = TRUE; 
 *nb_attr = 0;
 if(file_name == NULL) return 1;
    
 if(VDSReadPartInfo(file_name, &nb_part_attr, &part_attr) != 1)
   {
    printf("Error reading file: %s\n", file_name);
    return 0;
   }

 if(nb_part_attr == 0)
  {
   /* Nothing found */
   return 1;
  }
 
 /* allocated the attr_list structure */
 *attr_list = _MALLOC (nb_part_attr, struct VDGRpart_attr );
 _CheckAlloc (attr_list, "attr_list", status, FALSE, quit);
 
 /* Get the values 
 /* For the attribute which are defined into the data base, a query is done
 /* for each. It maybe seems slow but it allows to skip the one which are
 /* not found.
 /* If something wrong occurs for and attribute, just skip it and continue.
 /* */

 strcpy(tmp,"attrib:");
 for(i=0;i<nb_part_attr;i++)
  {
   strcpy((*attr_list)[*nb_attr].GRpart_column, part_attr[i].GRpart_column);
   (*attr_list)[*nb_attr].GRpart_type = part_attr[i].GRpart_type;

   if(part_attr[i].part_type == DYN)
    {
     /* ask the macro occurence (feet name is attrib:...) */
     direct_index = -1;
     strcpy(&tmp[7], part_attr[i].part_name);
     status = om$send(msg = message NDmacro.ACgive_structure(&msg, &direct_index, 
     				tmp, &tmp_rts, NULL),
     		senderid = NULL_OBJID,
		targetid = part_id->objid,     
		targetos = part_id->osnum);
     if(!(status&1) || !(msg&1))
      {
       printf("warning, dynamic attribute: %s not found\n", part_attr[i].part_name);
       continue;
      }
     (*attr_list)[*nb_attr].user = FALSE;

     if(!(tmp_rts.type & parameter_generic))
      {
       printf("The dynamic attribute:%s is not an expression, skip it\n",part_attr[i].part_name);
       continue;
      }
     if(tmp_rts.type == double_type)
      {
       (*attr_list)[*nb_attr].type = AC_ATTRIB_DOUBLE;
       (*attr_list)[*nb_attr].value.att_exp = tmp_rts.var.root_pm_st.value;
      }
     else if(tmp_rts.type == text_type)
      {
       (*attr_list)[*nb_attr].type = AC_ATTRIB_TEXT;
       strcpy((*attr_list)[*nb_attr].value.att_txt, tmp_rts.var.text_st.text_string);
      }
     *nb_attr += 1;
     continue;
    }
   else if(part_attr[i].part_type == STAT)
    {
     printf("Access to the database for: %s, not yet implemented\n", part_attr[i].part_name);
     continue;
    }
   else if(part_attr[i].part_type == USER)
    {
     /* The default value is used */
     (*attr_list)[*nb_attr].type = AC_ATTRIB_TEXT;
     (*attr_list)[*nb_attr].user = TRUE;
     strcpy((*attr_list)[*nb_attr].value.att_txt, part_attr[i].part_name);
     *nb_attr += 1;
     continue;
    }
   else
    {
     printf("Bad part type definition for: %s\n", part_attr[i].part_name);
     continue;
    }
  }

quit:

 _FREE(attr_list);

 return (status);
}


/************ Initialize *******************/
VDPlItem_init(cit_attr, partslist_name)
struct table_attr *cit_attr;
char		  *partslist_name;
 {
  int 				i, sts;
  char				part_dir[256];
  struct GRid			plist_id;
  extern struct PDUrefresh 	*refresh;

  if (VDSverify_login() != PDM_S_SUCCESS)
  {
     UI_status("User not logged in to Database");
     return DB_WARNING;
  }
   
  /* Init the structure gatering info on tables (cache buffer for attributes)
  /*  */
   for(i=0;i<MAX_TABLES_NB;i++) 
    {
     cit_attr[i].type          = 0; 
     cit_attr[i].feet_list     = NULL; 
     cit_attr[i].table_name[0] = '\0';
    }
   
  /* verify if there is an existing partslist def and get the name 
  /* the description. The default directory is:
  /*	- <file_name>:blocks:partslist:partslist#1
  /* */

  VDSget_filename(part_dir);
  strcat(part_dir,":blocks:partslist");

  sts = di$translate(objname = part_dir,
                   p_objid = &plist_id.objid,
                   p_osnum = &plist_id.osnum
                  );
  if(sts != DIR_S_SUCCESS) 
   {
    /* Not partslist defined */
    partslist_name[0] = '\0';
    plist_id.objid    = NULL_OBJID;
    return 1;
   }

  /* Get the partslist name ( */
  strcpy(partslist_name, "partslist");

  return 1;
 }

/* 
/* VDGetCitInfo:
/* 
/* Return info columns names of the corresponding cit table (given without
/* the _cit extension) */
/*
/* The cit_attr[x].feet_list array is allocated by the function and must 
/* be deallocated by the caller
/*
/* Return 0 if failed else 1
/*
/* */

VDGetCitInfo(cit_table, cit_attr_index, cit_attr)
char		  *cit_table;
int  		  *cit_attr_index;
struct table_attr *cit_attr;
{
 int i;
 int status;
 char  table_name[40];

 for(i=0;i<MAX_TABLES_NB;i++)
  {
   if(cit_attr[i].type == 0) continue;
   if(strcmp(cit_attr[i].table_name, cit_table) == 0)
    {
     /* the info are already got */
     *cit_attr_index = i;
     return 1;
    }
  }

 strcpy(table_name, cit_table);
 strcat(table_name, "_cit");
 
 for(i=0;i<MAX_TABLES_NB;i++)
  {
   if(cit_attr[i].type == 0) 
    {
     /* Free space found */

     /* CH 26 dec 1991.
     /* THIS WILL HAVE TO BE REPLACED BY USING RIS QUERY INSTEAD OF PDM QUERY
     /*  */
     cit_attr[i].nb_feet = 0;
     status = 
     vdb$RetrieveAttributes ( table_name      =   table_name,
			         p_num        =   &cit_attr[i].nb_feet, 
           		         p_attr       =   &cit_attr[i].feet_list,
           		         p_type       =   &cit_attr[i].format_list );
      if ( status != 1 ) 
      {
       printf("Unable to retrieve database schema for table %s\n", table_name);
       break;
      }
     cit_attr[i].type = 1;
     strcpy(cit_attr[i].table_name, cit_table);
     *cit_attr_index = i;
     return 1;
    }
  }
 return 0;
}

end implementation Root;


