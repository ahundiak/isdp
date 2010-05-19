/* $Id: SMDwUtil.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdw/imp / SMDwUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMDwUtil.I,v $
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
# Revision 1.2  1996/04/29  08:55:46  pinnacle
# Replaced: smdw/imp/SMDwUtil.I for:  by ksundar for vds.240
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

#define MAX_DW_ATT 20  /* Maximun of attributes for a dead_weight */

/* 
/* SMCrtDw:
/*
/* Given an ascii file name and a top directory, create the corresponding
/* dead weight rg collection.
/*
/* If top_dir is NULL the default base is taken <file_name>:usr is taken.
/* 
/* The argument "over" allows to override existing dead weight.
/*
/* */

SMCrtDw(file, top_dir, over, cur_os)
char *file;		/* Ascii file name describing the dead weight 	(I) */
char *top_dir;		/* top dir path (under <file_name:usr:>		(I) */
int   over;		/* TRUE means override if already exist.	(I) */
GRspacenum cur_os;	/* current os to create collection		(I) */
{
 FILE 			*fp;
 char 			buffer[MAX_CHAR_LINE], *ptr = NULL, *next_ptr, word[41];
 char 			sep, dw_path[256];
 int 			dead_weight, nb_att, i, sts, len;
 struct ACrg_coll 	att[MAX_DW_ATT];
 struct GRid		dw_id, dir;

 struct SMObjList	list;
 IGRlong		rc;
 IGRshort		options;

 sep = ',';  /* It is the separator */

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
 dead_weight   = 0;
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
   if(ptr && ptr[0] == '#') continue;


   /* Get the next word */
   if(VDSGetNextWord(ptr, word, 41, sep, &next_ptr) == 0)
    {
     printf("Warning, syntax error for: \n");
     printf("=> %s\n", ptr);
     continue;
    }


   if(strncmp("DEAD_WEIGHT",ptr,11) == 0 || strncmp("END",ptr,3) == 0)
    {
     /* -- NEW DEAD_WEIGHT -- */
     dead_weight += 1;
     /* Write the previous one */
     if(nb_att < 2) continue;

     /* THE NAME MUST BE THE FIRST ATTRIBUTE */
     if(strcmp(att[0].name,"name") != 0 || att[0].desc.type != AC_ATTRIB_TEXT)
      {
       printf("The first attribute must be the name (text type)\n");
       nb_att = 0;
       continue;
      }

     /* verify if the dead weight already exist */
     /* should also verify the number */
     sts = SM$CritSel(   msg 	 = &rc, 
     			 options = 0,
			 type    = SM_DW,
			 nb_crit = 1,
			 crit 	 = att,   /* The first one is the name */
			 list	 = &list);
     if(!(sts & 1) || rc != MSSUCC) 
      {
       printf("Failed in getting existing dead weight\n");
       continue;
      }
     if(list.nb_objects == 1)
      {
       /* Dead weight found */
       if(over != TRUE)
        {
	 dw_id = list.list[0].obj_id;
	 /* Do nothing */
	}
       else
        {
	 /* Override */
         dw_id = list.list[0].obj_id;
         SMCrtDwGrpCol(&rc, &dw_id, dw_path, nb_att, att, SM_DW, cur_os);
         if(rc != MSSUCC)
          {
	   printf("Error updating dead weight: %s\n", att[0].desc.value.att_txt);
          }	 
	}
      }
     else
      {
       /* create a new rg collection */
       dw_id.objid = NULL_OBJID;
       SMCrtDwGrpCol(&rc, &dw_id, dw_path, nb_att, att, SM_DW, cur_os);
       if(rc != MSSUCC)
        {
	 printf("Error creating dead weight: %s\n", att[0].desc.value.att_txt);
        }	 
      }

     /* Reused the allocated list */
     list.nb_objects = 0;
     options 	     = SM_ADD_LIST;

     nb_att 	     = 0;
     continue;
    }
   else
    {
     /* It is not DEAD_WEIGHT */

     if(dead_weight <= 0) continue;
     if(nb_att > MAX_DW_ATT) continue;

     /* Save the info in the list */
     strcpy(att[nb_att].name, word);
     
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

/*
/* SMCrtDwGrpCol:
/*
/*  Create (modify) a dead weight/group rg collection.
/*
/*  If "dw_id" is NULL_OBJID => create else modify.
/*  The "top_dir" sepcifies the directory path where the name will be added. 
/*  if top_dir == NULL || top_dir[0] ='\0' => use the current dir
/* 
/*  */

SMCrtDwGrpCol(rc, dw_id, top_dir, nb_att, att, type, osnum)
IGRlong 	*rc;		/* Completion code (MSSUCC/MSFAIL) 	(O)  */
struct GRid	*dw_id;		/* Dead weight identifier	       (I/O) */
char 		*top_dir;	/* top dir path 			(I)  */
IGRint		nb_att;		/* Number of attributes			(I)  */
struct ACrg_coll *att;		/* attributes array			(I)  */
IGRint		type;		/* SM_DW or SM_GRP			(I)  */
GRspacenum 	osnum;		/* construct osnum			(I)  */
{
 IGRlong 		status, loc_msg;
 IGRchar 		cur_dir[DI_PATH_MAX];
 IGRint			restore_dir;
 extern	GRclassid	OPP_SMdw_class_id, OPP_SMgroup_class_id;
 
 *rc = MSFAIL;
 if(dw_id->objid == NULL_OBJID)
  {
   /* Create the SMrg_collection */
   dw_id->osnum = osnum;

   if(type & SM_DW)
    {
     status = om$construct(classid = OPP_SMdw_class_id,
                           osnum   = dw_id->osnum,
                           p_objid = &dw_id->objid );
     if(!(status&1)) return 0;
    }
   else if(type & SM_GRP)
    {
     status = om$construct(classid = OPP_SMgroup_class_id,
                           osnum   = dw_id->osnum,
                           p_objid = &dw_id->objid );
     if(!(status&1)) return 0;
    }
   else {printf("SMCrtDwGrpCol, bad type\n"); return 0;}

   /* set the state to new */
   status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
                  targetid = dw_id->objid,
                  targetos = dw_id->osnum,
                  senderid = dw_id->objid);
   if(!(status&1)) return 0;
  }
 else
  {
   /* set the state to modify */
   status = om$send(msg = message SMmgr.SMSetState(SM_MOD),
                  targetid = dw_id->objid,
                  targetos = dw_id->osnum,
                  senderid = dw_id->objid);
   if(!(status&1)) return 0;
  }
 
 /* store the attributes (execpt the firts one which is the name) */
 status = om$send(msg = message ACrg_collect.ACset_list_attribute(&loc_msg,
 			nb_att - 1, &att[1]),
		targetid = dw_id->objid,  
		targetos = dw_id->osnum,
		senderid = NULL_OBJID);
 if(!(status&loc_msg&1)) return 0;


 /* Change to right directory, set the name and restore the dir */
 if(top_dir != NULL && top_dir[0] != '\0')
  {
   di$pwd(dirname = cur_dir);
   if(strcmp(cur_dir, top_dir) == 0)  restore_dir = 0;
   else
    {
     restore_dir = 1;
     status      = di$cd(dirname = top_dir);
     if(status != DIR_S_SUCCESS)
      {
       printf("Impossible to change to the directory: %s\n", top_dir);
       restore_dir = 0;
      }
    }
  } 
 else restore_dir = 0;

 status = om$send(msg = message GRvg.GRputname(&loc_msg, att[0].desc.value.att_txt),
		targetid = dw_id->objid,  
		targetos = dw_id->osnum,
		senderid = NULL_OBJID);
 /* restore the directory */ 
 if(restore_dir) 
  {
   if(di$cd(dirname = cur_dir) != DIR_S_SUCCESS)
    {
     printf("Impossible to restore to the previous directory: %s\n", cur_dir);
    }
  }
 if(!(status&loc_msg&1)) return 0;

 *rc = MSSUCC;
 return 0;
}

/*
/*  SMCrtDwPath
/*
/*  This function create a path (dead weight name) using the color, weight
/*  style, layer and dir attribute name.
/*
/*  An attribute not defined means the active will be taken.
/*  No attribute defined means no path created.
/*
/*  The mod attribute means that it is a modification (not yet implemented).
/* 
/*  Only the attributes which are not used in the list are copied to att2.
/*  The same (att) structure can be used in input/output.
/* */

SMCrtDwPath(rc, nb_att, att, mod, nb_att2, att2)
IGRlong 	*rc;		/* Completion code (MSSUCC/MSFAIL) 	(O)  */
IGRint		 nb_att;	/* Number of attributes	                (I) */
struct ACrg_coll *att;		/* attributes array		        (I) */
IGRint		mod;		/* 1 => modification			(I)  */
IGRint		 *nb_att2;	/* Number of returned attributes        (O) */
struct ACrg_coll *att2;		/* retuned attributes array		(O) */
{
 IGRint 		i, dir, symb;
 struct ACrg_coll 	tmp_att[MAX_DW_ATT];

 *rc = MSFAIL;
 
 dir      = 0;
 symb     = 0;
 *nb_att2 = 0;
 for(i=1;i<nb_att;i++)
  {
   if(strncmp(att[i].name, "color",5) == 0) 
    {
     /* symbology.display_attr.color */
     symb++;
    }
   else if(strncmp(att[i].name, "layer",5) == 0) 
    {
     /* symbology.level */
     symb++;
    }
   else if(strncmp(att[i].name, "weight",5) == 0) 
    {
     /* symbology.display_attr.weight */
     symb++;
    }
   else if(strncmp(att[i].name, "style",5) == 0) 
    {
     /* symbology.display_attr.style */
     symb++;
    }
   else if(strncmp(att[i].name, "dir",5) == 0) 
    {
     dir++;
    }
   else
    {
     /* Nothing to do with the path */
     tmp_att[*nb_att2] = att[i];
     *nb_att2 = *nb_att2 + 1;
    }
  }
 
 if(dir+symb > 0)
  {
   /* At least one info, therefore a path is created */
   }

 /* Fill the output structure */
 for(i=0;i<*nb_att2;i++) att2[i+1] = tmp_att[i];
 att2[0] = att[0];
 *nb_att2 = *nb_att2 + 1; 

 *rc = MSSUCC;
 return 1;
}
end implementation Root;

