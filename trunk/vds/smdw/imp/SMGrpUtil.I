/* $Id: SMGrpUtil.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdw/imp / SMGrpUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMGrpUtil.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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
# Revision 1.2  1996/04/29  08:56:30  pinnacle
# Replaced: smdw/imp/SMGrpUtil.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.2  1994/11/11  22:16:02  pinnacle
# Replaced:  smdw/imp/*.I r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*      CH  : 3 June 92   creation date.
/*
/*  Create dead weight by reading an ascii file
/*
/* */
class implementation Root;

#include <stdio.h>


#include "OMmacros.h"
#include "OMindex.h"
#include "OMprimitives.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "growner.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
/* */

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "asbox.h"

#include "vdsmacros.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "VDmem.h"

from ACrg_collect	import ACset_list_attribute;
from GRvg		import GRputname;
from SMmgr		import SMSetState;

/* 
/* SMCrtGrp:
/*
/* Given an ascii file name and a top directory, create the corresponding
/* group rg collection.
/*
/* If top_dir is NULL the default base is taken <file_name>:usr is taken.
/* 
/* The argument "over" allows to override existing groups
/*
/* */

SMCrtGrp(file, top_dir, over, cur_os)
char *file;		/* Ascii file name describing the groups 	(I) */
char *top_dir;		/* top dir path (under <file_name:usr:>		(I) */
int   over;		/* TRUE means override if already exist.	(I) */
GRspacenum cur_os;	/* current os to create collection		(I) */
{
 FILE 			*fp;
 char 			buffer[MAX_CHAR_LINE], *ptr, *next_ptr, word[41];
 char 			sep, dw_path[256];
 int 			group, sub_group, nb_att, i, sts, len;
 struct ACrg_coll 	att[SM_MAX_GRP_ATT];
 struct GRid		grp_id, dir;

 struct SMObjList	list;
 IGRlong		rc;
 IGRshort		options;

 sep = ',';  /* It is the separator */
 ptr = NULL;

 /* Have to look inside the config */
 vd$openfile(   file_name 	= file,
 	     	product_name 	= "Vds",
	     	sub_path	= "config",
	     	cur_dir	  	= TRUE,
	     	p_file	  	= &fp);
 if(fp == NULL)
  {
   printf("Error, cannot open the command file: %s\n",file);
   return 0;
  }
 
 /* Verify if the top dir */
 dw_path[0] = '\0';
 if(top_dir != NULL && top_dir[0] != '\0')
  {
   if(top_dir[0] != ':')
    {
     VDSget_filename(dw_path);
     strcat(dw_path,":usr:");
     strcat(dw_path,top_dir);
    }
   else 
    {
     strcpy(dw_path, top_dir);
    }
   sts = di$translate(objname = dw_path,
 		      p_objid = &dir.objid,
		      p_osnum = &dir.osnum);
   if(sts != DIR_S_SUCCESS)
    {
     /* directory not found, create it */
     sts = di$mkdir(dirname = dw_path);
     if(sts != DIR_S_SUCCESS)
      {
       /* Impossible to create the dir */
       return 0;
      }
    }
  }
   
 list.nb_alloc = 0;
 group         = 0;
 sub_group     = 0;
 nb_att        = 0;

 options = 0;
 while(fgets(buffer,MAX_CHAR_LINE-1, fp) != NULL)
  {
   short blank_line;

   /*"buffer line: <%s>, length: %d\n", buffer , strlen(buffer) */
   /*| Take out the blank line */
   if(strlen(buffer) < 1) continue;
   buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */

   blank_line = 1;
   for(i=0;i<strlen(buffer);i++)
     if(buffer[i] != ' ' && buffer[i] != '\t') { blank_line = 0; break; }
   if(blank_line) continue;

   /*| take out the first blanc charracters */
   for(i=0;i<strlen(buffer);i++)
    {
     if(buffer[i] != ' ' && buffer[i] != '\t') { ptr = &buffer[i]; break; }
    }

   /*| Take out the comment line (starting by #) */
   if(ptr[0] == '#') continue;


   /* Get the next word */
   if(VDSGetNextWord(ptr, word, 41, sep, &next_ptr) == 0)
    {
     printf("Warning, syntax error for: \n");
     printf("=> %s\n", ptr);
     continue;
    }


   if(strncmp("GROUP",ptr,5) == 0 || strncmp("END",ptr,3) == 0)
    {
     /* -- NEW GROUP -- */
     group += 1;
     /* Write the previous one */
     if(nb_att < 2) continue;

     /* THE NAME MUST BE THE FIRST ATTRIBUTE */
     if(strcmp(att[0].name,"name") != 0 || att[0].desc.type != AC_ATTRIB_TEXT)
      {
       printf("The first attribute must be the name (text type)\n");
       nb_att = 0;
       continue;
      }

     /* verify if the group already exist */
     /* should also verify the number */
     sts = SM$CritSel(   msg 	 = &rc, 
     			 options = 0,
			 type    = SM_GRP,
			 nb_crit = 1,
			 crit 	 = att,   /* The first one is the name */
			 list	 = &list);
     if(!(sts & 1) || rc != MSSUCC) 
      {
       printf("Failed in getting existing group\n");
       continue;
      }
     if(list.nb_objects == 1)
      {
       /* group found */
       if(over != TRUE)
        {
	 grp_id = list.list[0].obj_id;
	 /* Do nothing */
	}
       else
        {
	 /* Override (add the number of sub_groups )*/
	 strcpy(att[nb_att].name, "nb_sub_groups");
         att[nb_att].desc.type = AC_ATTRIB_DOUBLE;
	 att[nb_att++].desc.value.att_exp = sub_group;

         grp_id = list.list[0].obj_id;
         SMCrtDwGrpCol(&rc, &grp_id, dw_path, nb_att, att, SM_GRP, cur_os);
         if(rc != MSSUCC)
          {
	   printf("Error updating group: %s\n", att[0].desc.value.att_txt);
          }	 
	}
      }
     else
      {
       /* create a new rg collection */
       strcpy(att[nb_att].name, "nb_sub_groups");
       att[nb_att].desc.type = AC_ATTRIB_DOUBLE;
       att[nb_att++].desc.value.att_exp = sub_group;
       grp_id.objid = NULL_OBJID;
       SMCrtDwGrpCol(&rc, &grp_id, dw_path, nb_att, att, SM_GRP, cur_os);
       if(rc != MSSUCC)
        {
	 printf("Error creating group: %s\n", att[0].desc.value.att_txt);
        }	 
      }

     /* Reused the allocated list */
     list.nb_objects = 0;
     options 	     = SM_ADD_LIST;

     nb_att 	     = 0;
     sub_group	     = 0;
     continue;
    }
   else if(strncmp("S_GROUP",ptr,7) == 0)
    {
     sub_group++;
     /* Sub group definition */
    }
   else
    {
     /* Regular attributes */

     if(group <= 0) continue;
     if(nb_att + 1> SM_MAX_GRP_ATT)
      {
       /* +1 to take into account the added attribute nb_sub_group */
       printf("ERROR, too many sub groups defined\n");
       return 0;
      }

     /* Save the info in the list */
     if(sub_group > 0)
      {
       /* Sub group info, prefixe the name with the sub-group index */
       sprintf(att[nb_att].name,"%d_%s",sub_group,word);
      }
     else
      {
       /* group info */
       strcpy(att[nb_att].name, word);
      }
     
     /* Get the value */
     ptr = next_ptr;
     if(VDSGetNextWord(ptr, word, 41, sep, &next_ptr) == 0)
      {
       printf("Warning, syntax error for: \n");
       printf("=> %s\n", ptr);
       continue;
      }
     if(word[0] == '"')
      {
       /* TEXT */
       att[nb_att].desc.type = AC_ATTRIB_TEXT;
       /* take out the "" */
       len = strlen(word);
       if(len < 2) word[0] = '\0';
       word[len-1] = '\0';
       strcpy(att[nb_att].desc.value.att_txt, &word[1]);
      }
     else
      {
       /* DOUBLE */
       att[nb_att].desc.type = AC_ATTRIB_DOUBLE;
       if(sscanf(word,"%lf",&att[nb_att].desc.value.att_exp) == 0)
        {
	 /* Bad value, put 0 */
	 att[nb_att].desc.value.att_exp = 0;
	}
      }
     nb_att++;
    }
  } /* end while */

 if(list.nb_alloc > 0) _FREE(list.list);
 return 1;
}

end implementation Root;

