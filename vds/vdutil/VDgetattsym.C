/* $Id: VDgetattsym.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	vdequip/funct/VDgetattsym.C
 *
 * Description:	
 *
 *      This file implements general functions to read some info in an ascii
 *	file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgetattsym.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.3  1997/03/07  13:31:12  pinnacle
 * Replaced: vdutil/VDgetattsym.C for:  by v241_int for vds.241
 *
 * Revision 1.2  1997/01/17  21:51:20  pinnacle
 * Replaced: vdutil/VDgetattsym.C for:  by yzhu for vds.241
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *	
 * History:
 *	04/01/94  P. Lacroix: Creation date.
 *      08/25/94  Y. Zhu: added new function.
 *	09/06/94  Y. Zhu: syntax correction.
 *	01/17/97  Y. Zhu: modify VDgetAttSymb to use 
 *                        VD_findFileInDirOrProductpath instead vd$openfile
 * -------------------------------------------------------------------------
 */

#include <ctype.h>
#include <coimport.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/param.h>  /* for MAXPATHLEN */

#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "wl.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "igecolor.h"                   /*  dependent by igecolmacros.h */ 
#include "igecolmacros.h"		/*  ige$get_color_from_name  */
#include "exmacros.h"  			/*  ex$get_cur_mod           */
#include "dpmacros.h"			/*  dp$level_name_to_number  */     
#include "msdef.h"
#include "msmacros.h"

#include "DIdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vdsmacros.h"                      	/* vd$openfile 		*/
#include "VDGadgDef.h"
#include "vdparmacros.h"			/* vd$query_on_attr 	*/
#include "v_dbgmacros.h"			
#include "v_drwproto.h"
#include "v_ioproto.h"				/* VD_openFile */	

#include "VDmsg.h"
#include "growner.h"                            /* GRobj_env            */

#include "vdpardef.h"                           /* attr def             */
/*
#define   DEBUG		1
*/


/*--------------------------------------------------------------------------*/
VDcvrt_operant_to_type( string, type )
IGRchar		*string;
IGRint		*type;
{
	*type	= VD_cnt_qry_NONE ;

	if( ! string ){
		/*
		 * something wrong
		 */
		return FALSE ;
	}

	if( strncmp( string, VD_str_qry_EQUAL, 2 ) == 0 ||
	    strncmp( string, VD_sym_qry_EQUAL, 2 ) == 0 ){

		*type   = VD_cnt_qry_EQUAL ;
		return TRUE ;
	} else if 
	(   strncmp( string, VD_str_qry_N_EQUAL, 2 ) == 0 ||
            strncmp( string, VD_sym_qry_N_EQUAL, 2 ) == 0 ){

                *type   = VD_cnt_qry_N_EQUAL ;
                return TRUE ;
        } else if
	(   strncmp( string, VD_str_qry_G_EQUAL, 2 ) == 0 ||
            strncmp( string, VD_sym_qry_G_EQUAL, 2 ) == 0 ){

                *type   = VD_cnt_qry_G_EQUAL ;
                return TRUE ;
        } else if
	(   strncmp( string, VD_str_qry_L_EQUAL, 2 ) == 0 ||
            strncmp( string, VD_sym_qry_L_EQUAL, 2 ) == 0 ){

                *type   = VD_cnt_qry_EQUAL ;
                return TRUE ;
        } else if
	(   strncmp( string, VD_str_qry_G_THAN, 2 ) == 0 ||
            strncmp( string, VD_sym_qry_G_THAN, 1 ) == 0 ){

                *type   = VD_cnt_qry_G_THAN ;
                return TRUE ;
        } else if
	(   strncmp( string, VD_str_qry_L_THAN, 2 ) == 0 ||
            strncmp( string, VD_sym_qry_L_THAN, 1 ) == 0 ){

                *type   = VD_cnt_qry_L_THAN ;
                return TRUE ;
        }
	return FALSE;
} /*  VDcvrt_operant_to_type */

/*--------------------------------------------------------------------------*/ 

int VDNestCond(
FILE		 *pf,           /*[I] pointer for input file 	*/
struct GRobj_env ObjEnv,         /*[I] object envirment          */
IGRint		 *cur_line
)
{
char                    buffer[DI_PATH_MAX], *ptr = NULL;
int                     i, sts;
IGRchar			op1[80], op2[80], oprStr[80], nest[80];
IGRint			nbword, opr;
IGRlong                 loc_msg;
short			blank_line;

        /*
         * This function is used to check nested conditions
        */  

  
   /* read characters into buffer from input file */
   while(fgets(buffer,DI_PATH_MAX-1,pf) != NULL){ 

	(*cur_line) ++ ;

        /*| Get away the comment line (starting by #) and
            blank lines with \n or \0 as first character*/

        if(buffer[0] == '#' || buffer[0] == '\n' || buffer[0] == '\0')
            continue;

        /* Get away the blank line which include nothing       */
        if(strlen(buffer) < 1)
            continue;

        buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */

        /* Get away the blank line which only include tabs and blanks       */
        blank_line = 1;
        for(i=0;i<strlen(buffer);i++) {
               if(buffer[i] != ' ' && buffer[i] != '\t') 
               {
                   ptr = &buffer[i]; 
                   break;
               }
        }
        /* test the nest condition */
	   op1[0] = '\0';
	   oprStr[0] = '\0';
	   op2[0] = '\0';
	   nest[0] = '\0';

	   nbword = sscanf(ptr,"%s %s %s %s ", op1, oprStr,op2,nest) ;

#ifdef	DEBUG
           printf("nest =%s nbword = %d \n", nest, nbword );
#endif

	   if( nbword != 3 && nbword != 4 ){
		printf("LINE: %d -> syntax error \n", *cur_line );
	   	goto wrapup;
	   }

           if((strcmp(nest, "AND") != 0)&&(strcmp(nest, "") != 0)
                                        &&(strcmp(nest, "OR")!= 0))
             {
               printf("LINE: %d -> Only AND / OR / blank allowed.\n",*cur_line);
               goto wrapup;
             }

	   VDcvrt_operant_to_type( oprStr, &opr ); 
           sts = vd$query_on_attr(      msg      = &loc_msg,
                                        object   = &ObjEnv,
                                        operant1 = op1,
                                        operator = opr,
                                        operant2 = op2);
           if(sts == OM_S_SUCCESS){
                        if(nbword == 3){
                                return 1;
                        }
                        else if((nbword == 4)&&(strcmp(nest ,"AND"))){
                            /* test nested condition, if nested cond is
                            * true, return 1, else 0 
                            */
                            if(VDNestCond(pf, ObjEnv, cur_line) == 1){
                                 return 1;
                            } else
                            {
                                 return 0; 
                            }
                        }
                        else if((nbword == 4)&&(strcmp(nest ,"OR"))){
                                 return 1;
                        }
                        else {
                                 return 0;
                        }
           }
           else if(strcmp(nest, "OR") == 0){
                            if(VDNestCond(pf, ObjEnv, cur_line) == 1){
                                 return 1;
                            } else
                            {
                                 return 0; 
                            }
           }
           else {
               return 0;
           } /* end if */
	} /* end while  */
wrapup:
  return 0;
} /* VDNestCond */

/*-------------------------------------------------------------------------
  Internal Function  VDGetAttSymb

  Abstract


 	The Function reads in the given ascii file the attribute and 
        symbology to set to the given object.

	The ascii file describes the symbology for some conditions on
	attributes.

	If the object passes the condition then it will have the corresponding
	symbology (symbology driven by attributes.


 Algorithm

	- look for the file in the current directory, or in the directory
	config or in config/"path".

	- Take the description of the condition (COND).
	- If the object verifies it, read the line of the symbology (SYMB)
	and returns it.
	- Else, Read the next condition (next COND) and so on.

 Remarks
	If the object does not verify any condition then *msg= MSFAIL
	and the return symbology is set to the active one.
	Else *msg = MSSUCC,
	
  Rmeeturns
  	 1 if success
	 0 if fails
 -------------------------------------------------------------------------*/
int VDGetAttSymb(	msg, path, file_name, obj, obj_env, symbology )
IGRlong		 *msg;		/*[O] Completion code */
IGRchar		 *path;		/*[I] Path under config */
IGRchar		 *file_name;    /*[I] Name of the file to read */
struct GRid	 *obj;		/*[I] object to get symbology */
struct GRmd_env  *obj_env;	/*[I] module env of the object */
struct GRsymbology *symbology;  /*[O] output symbology */

{

char			buffer[DI_PATH_MAX], *ptr = NULL;
FILE			*pf;
int			i, sts;  
IGRchar			cond[20], op1[80],  op2[80], oprStr[80], nest[80];
IGRchar                 colorStr[80], levelStr[80],weightStr[80],styleStr[80];
IGRint			nbword, opr;
IGRlong			loc_msg;
struct GRobj_env	ObjEnv;
IGRboolean		NewCond, NextCond, FillSymb;
struct GRid		module;
IGRshort		sDummy;
IGRint			cur_line = 0;
char    	        absPathName[MAXPATHLEN];
char    	        relPathName[MAXPATHLEN];
char			firstDir[MAXPATHLEN] ;
char			thenDir[MAXPATHLEN] ;

 SetProc(VDGetAttSymb); Begin
 *msg = MSFAIL;

 pf = NULL;

 ObjEnv.obj_id = *obj;
 ObjEnv.mod_env = *obj_env;

 /* modify for tr179700088 */
 strcpy( firstDir,	"." ) ;
 strcpy( relPathName,	file_name);
 strcpy( thenDir,	path );

 VD_findFileInDirOrProductPaths( msg,
                                 relPathName,
                                 firstDir,
                                 thenDir,
                                 absPathName ) ;
 if( !( *msg & 1 ) ) {
        /*
         * no path name  found.
         */
        printf("no path name \n");
        return OM_E_ABORT;
 }
 __DBGpr_str( "absPathName", absPathName);
 
 /*
  * Now open that baby.
  */
 
 pf = VD_openFile( msg, absPathName, "r" );
 if( ! pf ){
	/*
	 * no support file found with name.
	 */
        printf("Can not open the file\n");
	*msg = MSFAIL ;
	return OM_E_ABORT;
 }
		
 NextCond = FillSymb = FALSE;
 NewCond = TRUE;

/*
 * input file layout description.
 *
 *	COND    	<attribute> <operator> <value> <AND/OR/"">
 *			<attribute> <operator> <value> <AND/OR/"">
 *	SYMB    	<color>	<weight> <style> <level>
 * 
 *	...
 *
 *	COND    	<attribute> <operator> <value> <AND/OR/"">
 *			<attribute> <operator> <value> <AND/OR/"">
 *	SYMB    	<color>	<weight> <style> <level>
 *
 * Note:
 * 1. when one condition satisfies, pick up relative symb and stop read file.  
 * 2. if user give following format:
 *	COND    	<attribute> <operator> <value> 
 *      COND		<attribute> <operator> <value> 
 *	SYMB    	<color>	<weight> <style> <level>
 *    error message will be given.
 * 3. On COND line:
 *    last argument must be AND/OR/"".
 */

 /* read characters into buffer from input file */ 
 *msg = MSFAIL ;
 while (fgets(buffer,DI_PATH_MAX-1,pf) != NULL)
 {
	short blank_line;

	cur_line ++ ;

   	/*| Get away the comment line (starting by #) and 
            blank lines with \n or \0 as first character*/

   	if(buffer[0] == '#' || buffer[0] == '\n' || buffer[0] == '\0') 
            continue;

        /* Get away the blank line which include nothing       */

   	if(strlen(buffer) < 1)
           continue;

   	buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */
        
        /* Get away the blank line which only include tabs and blanks       */
  	blank_line = 1;
   	for(i=0;i<strlen(buffer);i++) {
         	if(buffer[i] != ' ' && buffer[i] != '\t') 
                     { blank_line = 0; break; }
        }

   	if(blank_line) continue;

   	/*| set pointer at the first non-blank character */

   	for(i=0;i<strlen(buffer);i++){
     		if(buffer[i] != ' ' && buffer[i] != '\t') { 
				ptr = &buffer[i]; break; 
		}
    	}

	if(NewCond == TRUE && strncmp("COND", ptr, 4) == 0){
	        	/* COND op1 oprStr op2 nest */
	   cond[0] = '\0';
	   op1[0] = '\0';
	   oprStr[0] = '\0';
	   op2[0] = '\0';
	   nest[0] = '\0';

	   nbword = sscanf(ptr,"%s %s %s %s %s", cond,op1,oprStr,op2,nest) ;

	   if( !(nbword >= 4 && nbword <= 5) ){
		printf("LINE: %d -> syntax error \n", cur_line );
	   	goto wrapup;
	   }

#ifdef	DEBUG
           printf("nest == %s %d\n", nest, nbword );
#endif
           if((strcmp(nest, "AND") != 0)&&(strcmp(nest, "") != 0)
                                        &&(strcmp(nest, "OR") != 0))
             {
               printf("LINE: %d -> Only AND / OR / blank allowed.\n",cur_line);
               goto wrapup;
             }

	   VDcvrt_operant_to_type( oprStr, &opr ); 

	   sts = vd$query_on_attr(	msg      = &loc_msg,
					object   = &ObjEnv,
					operant1 = op1, 
					operator = opr,
					operant2 = op2);

	   if(sts == OM_S_SUCCESS){
			if(nbword == 4){
				/* get symbology */
				FillSymb = TRUE;
				NewCond = FALSE;
			}			
			else if((nbword == 5) && (strcmp(nest, "AND") == 0) ){
           			if(VDNestCond(pf, ObjEnv, &cur_line ) == 1) {
                                 	FillSymb = TRUE; 
					NewCond = FALSE;
                                }
                                else{
                                      	FillSymb = FALSE;
					NewCond = TRUE;
			        }	
                        }
			else if((nbword == 5) && (strcmp(nest, "OR") == 0) ){
                                 	FillSymb = TRUE; 
					NewCond = FALSE;
                        }
                        else {
                                        FillSymb = FALSE;
					NewCond = TRUE;
                        } 
	   }
           else if (strcmp(nest, "OR") == 0){
           			if(VDNestCond(pf, ObjEnv, &cur_line ) == 1) {
                                 	FillSymb = TRUE; 
					NewCond = FALSE;
                                }
                                else{
                                      	FillSymb = FALSE;
					NewCond = TRUE;
			        }	
           }
           else{
                    FillSymb = FALSE;
		    NewCond = TRUE;
           } /* end if */
                        continue;
	}
	if(NewCond == FALSE && strncmp("COND", ptr, 4) == 0)
          {
             /* 
              * following format is wrong:
              *         COND ..... ..... ..... .....
              *         COND ..... ..... ..... .....
              */
             *msg = MSFAIL;
             printf("LINE: %d -> syntax error.\n",cur_line);
             goto wrapup;
          }

	if(FillSymb == TRUE && strncmp("SYMB", ptr, 4) == 0){

        /* Fill the symbology */
	colorStr[0] = '\0';
        weightStr[0] = '\0';
        styleStr[0]  = '\0';
        levelStr[0]  = '\0';
	cond[0]      = '\0';

	nbword = sscanf(ptr,"%s %s %s %s %s",cond, 
			     colorStr, weightStr, styleStr, levelStr);

	if( nbword != 5 ){
		sts = MSFAIL;
                printf("LINE: %d -> syntax error.\n",cur_line);
		goto wrapup;
	}

        /* find color from name */
        if ( !isdigit( *colorStr)){
           sts = ige$get_color_from_name(
               color = &sDummy,
               name  = colorStr );
		symbology->display_attr.color = sDummy;
        }
 	else{
		symbology->display_attr.color = atoi(colorStr);
        }

        /* find level from name */ 
        if ( !isdigit( *levelStr )){
		sts =
		ex$get_cur_mod( id    = &module.objid,
                                osnum = &module.osnum);  

		sts =
		dp$levels_name_to_number(
				msg   = msg,
				name  = levelStr,
             			number= symbology->level,
              			mod_objid = module.objid,
               			osnum     = module.osnum);
        }
	else {
		symbology->level = atoi(levelStr);
        }

        /* fill symbology structure */
        symbology->display_attr.weight = atoi(weightStr);
        symbology->display_attr.style  = atoi(styleStr);

        *msg = MSSUCC;
	break;

	} /* FillSymb == TRUE && strncmp("SYMB" */

 }/* while EOF */

wrapup:
	fclose(pf);
        End
	return ( *msg == MSSUCC ) ? 1 : 0 ;

} /* VDGetAttSymb */
/*--------------------------------------------------------------------------*/


