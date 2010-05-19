/*$Id: VDqrytable.C,v 1.2 2001/02/15 00:51:45 ramarao Exp $  */

/* I/VDS
 *
 *
 * File:        vdpocket/func/VDqrytable.C
 *
 * Description:
 *
 *      This file include array MacClsStr[] which list the macroname and class
 *      name pairs.
 *      Function VDqry_macroclassname is used to get class name from the macro
 *      name which is listed in the MacClsStr[]
 *
 * Dependencies:
 *
 *
 * HISTORY :
 *  -------
 *
 *	09/08/94	yzhu            Modify.
 ***************************************************************************/

#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>		/* FILE type */

#include "wl.h"
#include "OMminimum.h"
#include "OMerrordef.h"                 /* OM_E_ABORT */
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"

#include "VDQYdef.h"

/* #define DEBUG	1  */ 

/*--List of Macro and Class name ---------------------------------------------*/
/*
 * macro and class name paire can be added before the end_of_list line.
 */
static  struct VD_macclsstr MacClsStr[] = {

/*  	macroname		classname                         */
/*	=========               =========                         */
/*
 *  Section of I/Struct beam
 */
{   	"VSbeam", 		"VSbeam"             }, 
                       /* VSbeam isn't macro, add it for use more easy  */
{   	"VSsrcBeam", 		"VSsrcBeam"          },
{   	"VSbooBeam", 		"VSbooBeam"          },
{   	"VSornBeam", 		"VSornBeam"          },
{   	"VSxtrBeam", 		"VSxtrBeam"          },
{   	"VSsplBeam", 		"VSsplBeam"          },
{   	"VSpntBeam", 		"VSpntBeam"          },
{   	"VSsubBeam", 		"VSsubBeam"          },
{   	"VSstfBeam", 		"VSstfBeam"          },
{   	"VSfrzBeam", 		"VSfrzBeam"          },
{   	"VSrflBeam", 		"VSrflBeam"          },
{   	"VSrfsBeam", 		"VSrfsBeam"          },
/*
 *  Section of I/Struct plate
 */
{   	"VSplate", 		"VSplate"             }, 
                       /* VSplate isn't macro, add it for use more easy  */
{       "VSsrcPlate",            "VSsrcPlate"             },
{       "VSholPlate",            "VSholPlate"		  },
{       "VSmrkPlate",            "VSmrkPlate"             },
{       "VSsplPlate",            "VSsplPlate"             },
{       "VSsubPlate",            "VSsubPlate"             },
{       "VSvarPlate",            "VSvarPlate"             },
{       "VSbooPlate",            "VSbooPlate"             },
{       "VSgapPlate",            "VSgapPlate"             },
{       "VSfrzPlate",            "VSfrzPlate"             },
{       "VSrflPlate",            "VSrflPlate"             },
{       "VSrfvPlate",            "VSrfvPlate"             },
/*
 *  Section of I/Struct joint
 */
{   	"VSjoint", 		"VSjoint"             }, 
                       /* VSplate isn't macro, add it for use more easy  */
{       "VSsrcJoint",            "VSsrcJoint"             },
{       "VSmodJoint",            "VSmodJoint"		  },
{       "VSdivJoint",            "VSdivJoint"             },
{       "VSsubJoint",            "VSsubJoint"             },

{       "VSprjCrsSctn",          "VSprjCrsSctn"           },
{       "VSintCrsSctn",          "VSintCrsSctn"           },

{       "VSbeamAxis",            "VSbeamAxis"             },
{       "VSbmEndPnts",           "VSbmEndPnts"            },
{       "VSsurfOfProj",          "VSsurfOfProj"           },
{       "VSselector",            "VSselector"             },
{       "VSbeamCS",              "VSbeamCS"               },
{       "VSproffrplts",          "VSproffrplts"           },
{       "VSshellExp",            "VSshellExp"             },
{       "VSexpandedCv",          "VSexpandedCv"           },
{       "VSgapDtector",          "VSgapDtector"           },
{       "VSmergeShExp",          "VSmergeShExp"           },
{       "VSmergeExpCv",          "VSmergeExpCv"           },

/********** unknown classname                                      
{       "Light Rep Of Beam"                               },
{       "jointGroup"                                      },
{       "Mnt Of Inertia"                                  },
{       "VSps_plt"                                        },
***************/

/*
 *      I/Route 
 *	macroname		classname
 *	=========		=========
 */
{	"PPccdef",	         "VRPComp"      	  },/*1 macr - 2 cla */	
{	"PPccdef",	         "VRPCorentity"      	  },	
{	"HVccdef",	         "VRHComp"      	  },/*1 macr - 2 cla */	
{	"HVccdef",	         "VRHCorentity"      	  },	
{	"RWccdef",	         "VRRComp"      	  },/*1 macr - 2 cla */
{	"RWccdef",	         "VRRCorentity"      	  },	
{	"PPcndef",	         "VRPCComp"      	  },	
{	"HVcndef",	         "VRHCComp"      	  },	
{	"RWcndef",	         "VRRCComp"      	  },	
{	"VRCptIn",	         "VRCptIn"     	  	  },	

/************ unkown 
{	"VRcpt"						  },	
{	"Pp_supp"	                         	  },	
{	"VRcable"	                         	  },	
{	"ConnectDef"	                         	  },	
{	"CableDef"	                         	  },	
{	"r_sec"	                         	          },	
*********/

/*
 *      I/VDS
 *	macroname		classname
 *	=========		=========
 */
{	"VDequidef",		"VDequipment"		  },	
{	"VDdrwTblHdr",		"VDdrwTblHdr"		  },
{	"VDdrwTblRow",		"VDdrwTblRow"		  },
{	"VDdrw2d",		"VDdrw2d",		  },
{	"VDdrw3d",		"VDdrw3d",		  },
{	"VDdrw2dVw",		"VDdrw2dVw",		  },
{	"VDdrw3dVw",		"VDdrw3dVw",		  },
{	"VDgeomdef",		"VDgeom",		  },


/*
 *      I/VDS SMPrivMac
 */
{	"SMcomp", 		"SMcomp"		  },	
{	"SMCcCamber", 		"SMCcCamber"		  },	
{	"SMCsPp", 		"SMCsPp"		  },	
{	"SMFrPln", 		"SMFrPln"		  },	
{	"SMInfPlane", 		"SMInfPlane"		  },	
{	"SMglob", 		"SMglob"		  },	
{	"SMLgCrgtBk", 		"SMLgCrgtBk"		  },	
{	"SMLongBk", 		"SMLongBk"		  },	
{	"SMLtdVol", 		"SMLtdVol"		  },	
{	"SMMainSf", 		"SMMainSf"		  },	
{	"SMPtCamber", 		"SMPtCamber"		  },	
{	"SMPtSheer", 		"SMPtSheer"		  },	
{	"SMrpt", 		"SMrpt" 		  },	
{	"SMsection", 		"SMsection" 		  },	
{	"SMSfBnd", 		"SMSfBnd" 		  },	
{	"SMSketchVol", 		"SMSketchVol" 		  },	
{	"SMSlCamber", 		"SMSlCamber"		  },	
{	"SMSlSheel", 		"SMSlSheel"		  },	
{	"SMSpltSrf", 		"SMSpltSrf"		  },	
{	"SMTransBk", 		"SMTransBk"		  },	
{	"SMTrCrgtBk", 		"SMTrCrgtBk"		  },	
{	"SMVolBySplt", 		"SMVolBySplt"		  },	
{	"SMVolBnd", 		"SMVolBnd"		  },	
{	"SMCpTxt", 		"SMCpTxt"		  },	

/***
{	"compartwalls", 	"compartwalls"		  },	
***/

{   	NULL, 			NULL			} /* End of list */
}; 

/*-----------------------------------------------------------------------
  Function     VDqry_macroclassname            
  example to use this function:

  char               pat[80];
  IGRchar            **classname;
  IGRint             count;
  IGRint             status,i;
  IGRint             Maxword;

  count = 0;
  Maxword = 80;

  sts = MSSUCC;

  classname = NULL ;

  status =
  VDqry_macroclassname(pat, classname, &count);

  VDmalloc_str_list(&classname, count, Maxword);

  status =
  VDqry_macroclassname(pat, classname, &count);

  Note: user need to free classname
  VDfree_str_list(classname, count);
------------------------------------------------------------------------*/           
int VDqry_macroclassname(pat,classname,count)
IGRchar 	*pat                       /* in patten */;
IGRchar 	***classname               /* out fund class name */;
IGRint		*count			   /* in/out no. classname   */;
{
IGRint		i,ii,status;

#ifdef DEBUG
	printf(" Function VDqry_macroclassname count = %d\n",*count);
       	printf(" pat = %s\n", pat);
#endif

        i = 0;
        ii = 0;

        /* get num of matching macro names */
        if(!*count) {
          while(MacClsStr[i].mac_name != NULL) {
              status =
     	      VD_matchRE(pat,MacClsStr[i].mac_name);
     	      if(status) {
                   ii = ii + 1;
#ifdef DEBUG
       		   printf(" match macro name == %s\n", MacClsStr[i].mac_name);
#endif
     	       }
               i = i + 1;
          } 
        }
        /* fill classname */
        else {
          while(MacClsStr[i].mac_name != NULL) {
            status =
            VD_matchRE(pat,MacClsStr[i].mac_name);
            if(status) {
                   strcpy((*classname)[ii], MacClsStr[i].cls_name);
#ifdef DEBUG
                   printf(" classname == %s\n", (*classname)[ii]);
#endif
                   ii = ii + 1;
             }
             i = i + 1;
           }
         }

        *count = ii;
#ifdef DEBUG
                   printf(" count = %d\n", *count);
#endif

	return 1;
}


/*---------------------------------------------------------------------------*/
static int VD_ClassCmp( CL1, CL2 )

const void      *CL1,
                *CL2 ; {

        return strcmp( ( (struct VD_macclsstr *) CL1 )->cls_name,
                       ( (struct VD_macclsstr *) CL2 )->cls_name ) ;

} /* VD_ClassCmp */

/*---------------------------------------------------------------------------*/

long	VDqry_GiveMacroFromClass( msg, class, macro )

IGRlong			*msg ;
IGRchar			*class ;
IGRchar			*macro ;
{

	IGRint			sts = OM_S_SUCCESS ;
	static	int		maxClass = -1 ;
	struct	VD_macclsstr	lookUp,
				*found ;

	/*
	 * Find the macro name based on the object class.
	 */

	*msg = MSFAIL ;

	if( ! macro || ! class ) return sts ;

        if( -1 == maxClass  ) {

                /*
                 * First time call : count keywords and alphabetically sort
                 * keyword list.
                 */
                struct VD_macclsstr   *cl ;
                for(	maxClass=0, cl=MacClsStr ;
			cl->cls_name ;
			cl++ )	maxClass++ ;

                qsort( (char *) MacClsStr, (unsigned) maxClass,
                        sizeof *cl, VD_ClassCmp ) ;
        }

	lookUp.cls_name = class ;

	found = (struct VD_macclsstr *) bsearch((char *) &lookUp,
						(char *) MacClsStr,
						(unsigned) maxClass,
						sizeof lookUp,
						VD_ClassCmp ) ;
	if( found ){

		strcpy( macro, found->mac_name );
		*msg = MSSUCC ;
	}
	else	*msg = MSFAIL ;

	return sts ;
}

/*---------------------------------------------------------------------------*/

