/* $Id: COm_place4.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/COm_place4.I
 *
 * Description:
 *		TR 179528394
 *		TR 179528392
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: COm_place4.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.1  1995/12/15  20:11:06  pinnacle
# Created: vdassoc/COm_place4.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/14/95	adz		creation date
 *
 ***************************************************************************/

class implementation COm_place;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include <limits.h>
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "FI.h"
#include "grclasses.h"
#include "grmsg.h"


#define AS_DEBUG

from expression   import list;
from IGRdir 	  import translate;
from ACmacro_defn import ACgive_upscan;
from GRvg	  import GRgetname;
from ACpretend    import ACfind_parent,ACgive_downscan;
from ACrg_collect import AClist_attribute;


COm_display_line(fp,gadget,num_col,i_row,
		 prompt,Temp_Type,Temp_Value,Temp_List,mytype)
char *fp;
int gadget,num_col,i_row;
char *prompt;
int Temp_Type;
struct ret_struct *Temp_Value;
struct GRid *Temp_List;
int mytype;
{
 char text[DI_PATH_MAX],text1[DI_PATH_MAX],text2[DI_PATH_MAX];
 char temp_text [DI_PATH_MAX];
 IGRlong status,msg;
 char *c,*strchr(),*strrchr();

 status = msg = OM_S_SUCCESS;

/* name */
 
     if(num_col > 1)
        FIfld_set_text(fp,gadget,i_row,0,prompt,FALSE);

     ex$message (msgnumb = AS_S_OthrType, buff = text);

     if(Temp_Type & macro_generic)
        {
          ex$message (msgnumb = AS_S_Const, buff = text);
	  strcat(text,Temp_Value->var.macro_st.name);
	}
     else if(Temp_Type & class_generic)
        {
          ex$message (msgnumb = AS_S_Class, buff = text);
	  strcat(text,Temp_Value->var.macro_st.name);
	}
     else
      {
       text[0] = '\0';
       if(Temp_Type & line_generic)  {
            ex$message (msgnumb = AS_S_Line, buff = text);
            strcat(text," | ");
       }
       if(Temp_Type & point_generic) {
            ex$message (msgnumb = GC_I_point, buff = text);
            strcat(text," | ");
       }
       if(Temp_Type & conic_generic) {

/*
 * TR 179528394
 *	Replace "circle" naming by "conic".
 *
 * 	    ex$message (msgnumb = GC_I_circle, buff = text);
 */
 	    strcat(text,"conic" );
            strcat(text," | ");
       }
       if(Temp_Type & curve_generic) {
            ex$message (msgnumb = GC_I_curve, buff = text);
            strcat(text," | ");
       }
       if(Temp_Type & parameter_generic)
        { if(Temp_Type == double_type)  {
              ex$message (msgnumb = AS_S_Double, buff = text);
              strcat(text," | ");
          }
          else if(Temp_Type == text_type)  {
              ex$message (msgnumb = GC_I_text, buff = text);
              strcat(text," | ");
          }
	  else {
             ex$message (msgnumb = AS_S_Double, buff = text);
             strcat(text," | ");
             ex$message (msgnumb = GC_I_text, buff = temp_text);
             strcat(text, temp_text);
             strcat(text," | ");
          }
	}
       if(Temp_Type & lbs_generic)  {
          ex$message (msgnumb = GC_I_text, buff = text);
          strcat(text," | ");
       }
       if(Temp_Type & ref_generic)  {
          ex$message (msgnumb = AS_S_CoordSys, buff = text);
          strcat(text," | ");
       }
       if(Temp_Type & debug_type)   {
          ex$message (msgnumb = GR_I_plane, buff = text);
          strcat(text," | ");
       }
       if(Temp_Type & other_generic) {
          ex$message (msgnumb = AS_S_OthrType, buff = text);
/*
 * TR 179528394
 * 	  strcat(text,"other type | ");
 */
          strcat(text," | ");
       }
       c = strrchr(text,'|');
       if(c) *c = '\0';
      }


/* Type in col 1 when there are 3 col */

     if(num_col == 3)
       {
        FIfld_set_text(fp,gadget,i_row,1,text,FALSE);
        if(Temp_List->objid == NULL_OBJID)
	 {
	  if(mytype){ ex$message(buff = text,msgnumb = AS_S_NotMod); }
	  else      { ex$message(buff = text,msgnumb = AS_S_NotDef); }
	 }
	else
	 {
	  if(mytype == 2){ ex$message(buff = text,msgnumb = AS_S_Modify); }
	  else      { ex$message(buff = text,msgnumb = AS_S_Def); }
	 }
       }

/* Type or value in the last column  */

     c = text;

     if((Temp_Value->type & parameter_generic)&& (Temp_Value->type!= ~0))
      {
       if(Temp_List->objid != NULL_OBJID)
        {
         status=om$send(msg = message expression.list(text),
			senderid = NULL_OBJID,
                        targetid = Temp_List->objid,
                        targetos = Temp_List->osnum);
	 if(!(status&1))Temp_List->objid = NULL_OBJID;
         else
          {
           char *b1,*b2;
           /*" remove the shit in %s\n",text */
           if(text[0] == '\\')
            {if( strchr(text,'=') != NULL) c = strchr(text,'=')+1;}

           for(; *c == ' ' ; c++);

           for(b1=c,b2=c;*b1 != '[' && *b1 != '\0';b1++)
            {if( *b1 != ' ') *b2++ = *b1;}
           *b2 = '\0';
           /*"result %s\n",c*/
          }
        }
       else status = 0;

       if(!(status&1) && !(mytype&2))
        { if(Temp_Value->type == double_type)
	    sprintf(text,"%g",Temp_Value->var.root_pm_st.value);
	  else
	    strcpy(text,Temp_Value->var.text_st.text_string);
        }
      }
     else
      {
       status = om$send(msg = message ACpretend.ACgive_downscan(text1),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
       if(status&1)
        {
         struct GRid mac;
	 status = om$send(msg = message ACpretend.ACfind_parent(&mac,NULL,NULL),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
         if(status&1)
           {
            status = om$send(msg = message GRvg.GRgetname(&msg,text2),
		      senderid = NULL_OBJID,
                      targetid = mac.objid,
                      targetos = mac.osnum);
 	    if(status&msg&1)
              { strcat(text2,":");strcat(text2,text1); c = text2; }
	   }
	}
      else
        {
         status = om$send(msg = message GRvg.GRgetname(&msg,text1),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
         if(status&msg&1) c = text1;
        }
     }

     /*"value %s\n",text */
     FIfld_set_text(fp,gadget,i_row,num_col-1,c,FALSE);
 return 1;
}

end implementation COm_place;
