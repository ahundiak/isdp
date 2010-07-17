/* $Id: VRXaccpip.I,v 1.2 2002/04/15 20:01:45 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRXaccpip.I
 *
 * Description:
 *	Access VDS database for piping parameters             
 *       (replaces VRaccpip.c   )
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRXaccpip.I,v $
 *	Revision 1.2  2002/04/15 20:01:45  anand
 *	Removed version.h and associated dependencies. version.h is
 *	an include file in $EXNUC.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:28  pinnacle
# Created: vrpdu/VRXaccpip.I by hverstee for route
#
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

class implementation Root;

#include	<stdio.h>
#include        <stdlib.h>
#include        <ctype.h>

#include        "ACattrib.h"
#include        "msdef.h"
#include        "dberror.h"
#include        "VRDbParamDef.h"
#include        "VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include        "VRDbCache.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"

#include 	"vrpdu_pto.h"

/*
#define MY_DEBUG
*/

extern
struct VRPDB_project   VRGL_PROJ;
extern
IGRint                 VRGL_specunit;


/**************************************************************/

int access_piping (
  char		*name,       /*  spec name                          (I)   */
  char          *compname,   /*  AABBCC code of the component       (I)   */
  double        siz_1,       /*  Green diameter of component        (I)   */
  double        siz_2,       /*  Red diameter of component          (I)   */
  int           option,      /*  option code                        (I)   */
  char          *fam_name,   /*  family  or macro name              (O)   */
  char		*partnum,    /*  Part number of the component       (O)   */
  short         *topology,   /*  Component topology                 (O)   */
  short         *type,       /*  Component reporting category       (O)   */
  int           *comp_numcp, /*  Number of connect points           (O)   */
  int           *comp_seccp, /*  Red connect point identifier       (O)   */
  struct ACrg_coll mac_pm[], /*  macro parameters                   (O)   */
  int		*pm_no,	     /*  Number of params in mac_pm         (O)   */
  char          *err_ptr)    /*  error message buffer               (O)   */

{
  /************************************************************************/
  /*                                                                      */
  /* This routine extracts family name, part number, topology and         */
  /* reporting category of the component from the Spec database           */
  /*                                                                      */
  /* Algoritm :                                                           */
  /*          1)Access PIPING_SPEC table with spec_name and prj_no        */
  /*            to extract SPEC_NO and GASK_SEP                           */ 
  /*          2)Access PIPING_COMPS table with spec_no, comp_name,        */
  /*            sizes and option code to extract a component record.      */
  /*          3)Access PIPING_COMMOD_CODE table with part no. prefix,     */
  /*            sizes and, optionally sch thk, to extract PDM_PART_NUM.   */
  /*          4)Access PIPING_COMP_TYPE table with comp_code to extract   */
  /*            COMP_TOPO and COMP_CAT.                                   */
  /*                                                                      */
  /************************************************************************/
  
  int	        sts;
  char		number[MAX_ATTR_LEN]; 
  char          thk1[MAX_ATTR_LEN];		/* sched thk */
  char          thk2[MAX_ATTR_LEN];
  char          thk_match[MAX_ATTR_LEN];        /* MATCH sched thk value */
  char          short_code[MAX_ATTR_LEN];       /* Short code */
  int           flag;                           /* Flag */
  char          tmp1[MAX_ATTR_LEN];
  int           spec_no, prep_g, prep_r, end_std_g, end_std_r;
  int 		thick_units;
  double        range_1, range_2, gask_sep;                          
  double	SIZE_1, SIZE_2;
  char          disp_err[100];
  int           proj_no;
  int           iLENN1,iLENN2;

       IGRlong   retmsg;
       IGRshort  NN;
       IGRdouble dd1, dd2;
       struct VRPDB_comps_key  YY;
       struct VRPDB_comps  XX[100];
       struct  VRPDB_ct_key    CtK;
       struct  VRPDB_ct        CtR;

  /************************************************/

#ifdef MY_DEBUG
  printf (" ACCPIP sizes %f %f \n",siz_1,siz_2);
#endif

  /************************************************/

  /* security init, get rid of warnings  */

  proj_no = VRPDB_UNDEF;
  spec_no = VRPDB_UNDEF;
  range_1 = range_2 = gask_sep = 0.0;

  sts = VRenq_proj_units();
  sts = Get_piping_spec_units (proj_no, name, disp_err);

  /* Convert the npd_units so that the access is dictated by the SPEC units */


  if( VRGL_PROJ.prj_units != VRGL_specunit ) 
  {
    SIZE_1 = get_allowed_npd( VRGL_PROJ.prj_units,VRGL_specunit,siz_1,name,
                                  proj_no,err_ptr);
    SIZE_2 = get_allowed_npd( VRGL_PROJ.prj_units,VRGL_specunit, siz_2,name,
                                  proj_no,err_ptr);
  }
  else
  {
    SIZE_1 = siz_1;
    SIZE_2 = siz_2;
  }

  /* Copy gasket seperation into the mac_pm structure */

  strcpy(mac_pm[*pm_no].name,VR_N_GASK_SEP_DB);
  mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;

  if( VRGL_PROJ.prj_units != VRGL_specunit )
    mac_pm[*pm_no].desc.value.att_exp =
        converted_to_vds(mac_pm[*pm_no].name,
                         VRGL_specunit,VRGL_PROJ.prj_units,gask_sep,err_ptr); 
  else
    mac_pm[*pm_no].desc.value.att_exp = gask_sep;
  *pm_no += 1;     
    

    /* ACCESS PIPING COMPS TABLE */
    /*---------------------------*/

       dd1 = SIZE_1;
       dd2 = SIZE_2;
       if (dd1 == dd2) dd2 = 0.0;

       strcpy (YY.comp_code, compname);
       YY.option = option;

       VR$PDB_COMP (p_msg = &retmsg,
                    spec  = spec_no,
                    keyin = &YY,
                    dia1  = dd1,
                    dia2  = dd2,
                    p_num = &NN,
                    p_rec = XX);

       if ((NN == 0) || (retmsg != MSSUCC)) return( ACC_E_PIPING_COMPS );

    strcpy (fam_name, XX[0].data.famnam);
    strcpy (number,XX[0].data.part_pfx);
    strcpy (short_code, XX[0].data.sh_code);

    /* Copy spec param values in to the structures */
    /*---------------------------------------------*/

     /* Macro or family name */

     strcpy(mac_pm[*pm_no].name,VR_N_MACRO_NAME_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy(mac_pm[*pm_no].desc.value.att_txt, fam_name);
     *pm_no += 1;     

     /* Short code */
     strcpy(mac_pm[*pm_no].name,VR_N_SHORT_CODE_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy(mac_pm[*pm_no].desc.value.att_txt, short_code);
     *pm_no += 1;     

     /* Max temp */
     strcpy(mac_pm[*pm_no].name,VR_N_MAX_TEMP_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     if(( VRGL_PROJ.prj_units != VRGL_specunit ) &&
        ( XX[0].data.maxtemp    != -9999.0 ))
	mac_pm[*pm_no].desc.value.att_exp =
            converted_to_vds(mac_pm[*pm_no].name,
			      VRGL_specunit,VRGL_PROJ.prj_units,
                              XX[0].data.maxtemp, err_ptr);
     else
     	mac_pm[*pm_no].desc.value.att_exp = XX[0].data.maxtemp;
     *pm_no += 1;     

     /* Prep G */

     strcpy(mac_pm[*pm_no].name,VR_N_PREP_G_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.0;
     prep_g = 0;
     if (XX[0].data.prep_g > 0) 
     {
        mac_pm[*pm_no].desc.value.att_exp = (double) XX[0].data.prep_g;
        prep_g = XX[0].data.prep_g;
     }
     *pm_no += 1;

     /* Prep R */

     strcpy(mac_pm[*pm_no].name,VR_N_PREP_R_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     /* if prep_r is undefined or zero */
     if (XX[0].data.prep_r == 0) 
     {
        mac_pm[*pm_no].desc.value.att_exp = mac_pm[*pm_no-1].desc.value.att_exp;
        prep_r = prep_g;
     }
     else
     {
        mac_pm[*pm_no].desc.value.att_exp =(double) XX[0].data.prep_r;
        prep_r = XX[0].data.prep_r;
     }
     *pm_no += 1;

     /* Rating G */

     strcpy(mac_pm[*pm_no].name,VR_N_RATING_G_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     /* Change the rating strings into doubles */
     mac_pm[*pm_no].desc.value.att_exp = 0.;
     if (strlen(XX[0].data.rating_g) > 0)
     {
       sts = extract_num( XX[0].data.rating_g, tmp1);
       if (sts ==  1)
       {
         mac_pm[*pm_no].desc.value.att_exp = VRDBdbl(tmp1);
       }
     }
     *pm_no += 1;

     /* Rating R */

     strcpy(mac_pm[*pm_no].name,VR_N_RATING_R_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.;
     if (strlen(XX[0].data.rating_r) == 0 || 
        (strcmp(XX[0].data.rating_r,"0") == 0)) 
     {
        mac_pm[*pm_no].desc.value.att_exp = mac_pm[*pm_no-1].desc.value.att_exp;
     }
     else
     {
       sts = extract_num(XX[0].data.rating_r,tmp1);
       if (sts ==  1)
       {
          mac_pm[*pm_no].desc.value.att_exp = VRDBdbl(tmp1);
       }
     }
     *pm_no += 1;

     /* Sch thk G */

     strcpy(mac_pm[*pm_no].name,VR_N_SCH_THK_G_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy (mac_pm[*pm_no].desc.value.att_txt, XX[0].data.sch_thk_g);
#ifdef MY_DEBUG
     printf ("SCH THK1 spec %s\n",XX[0].data.sch_thk_g);
#endif

     if (strcmp(XX[0].data.sch_thk_g,"NREQD") == 0)
     {
       strcpy (mac_pm[*pm_no].desc.value.att_txt,"");
     }

     flag = 0;
     if (strcmp(XX[0].data.sch_thk_g,"MATCH") == 0)
     { /* Reaccess piping comps with comp code set to PIPING */
       IGRshort     nPip;
       struct VRPDB_comps_key  PipK;
       struct VRPDB_comps      PipC;

       strcpy (PipK.comp_code, "PIPING");
       PipK.option = 1;

       VR$PDB_COMP (p_msg = &retmsg,
                    spec  = spec_no,
                    keyin = &PipK,
                    dia1  = dd1,
                    dia2  = 0.0,
                    p_num = &nPip,
                    p_rec = &PipC);

       /* Set flag for sched thk MATCH */
       flag = 1;

       strcpy(mac_pm[*pm_no].desc.value.att_txt, PipC.data.sch_thk_g);
       strcpy(thk_match,mac_pm[*pm_no].desc.value.att_txt);
       range_1 = PipC.dia.dia1_h;
       range_2 = PipC.dia.dia1_l;
     }
     strcpy(thk1, mac_pm[*pm_no].desc.value.att_txt); /* save thickness 1 */
     *pm_no += 1;

     /* Sch thk R*/

     strcpy(mac_pm[*pm_no].name,VR_N_SCH_THK_R_AN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy (mac_pm[*pm_no].desc.value.att_txt, XX[0].data.sch_thk_r);
#ifdef MY_DEBUG
     printf ("SCH THK2 spec %s\n",XX[0].data.sch_thk_r);
#endif
     strcpy (thk2, XX[0].data.sch_thk_r);

     if (strcmp(thk2,"NREQD") == 0)
     {
       strcpy (mac_pm[*pm_no].desc.value.att_txt,"");

     }
     else if (strlen(thk2) == 0)
     {
       strcpy (mac_pm[*pm_no].desc.value.att_txt,
               mac_pm[*pm_no-1].desc.value.att_txt);
     }
     else if (strcmp(thk2,"MATCH") == 0)
     {
       if((range_1 <= SIZE_2 && range_2 >= SIZE_2) && (flag == 1))
       {
         strcpy(mac_pm[*pm_no].desc.value.att_txt,thk_match);
         strcpy(thk2,thk_match);
       }
       else
       {
         /* Reaccess piping comps with comp code PIPING */
         IGRshort     nPip;
         struct VRPDB_comps_key  PipK;
         struct VRPDB_comps      PipC;

         strcpy (PipK.comp_code, "PIPING");
         PipK.option = 1;

         VR$PDB_COMP (p_msg = &retmsg,
                      spec  = spec_no,
                      keyin = &PipK,
                      dia1  = SIZE_2,
                      dia2  = 0.0,
                      p_num = &nPip,
                      p_rec = &PipC);

         strcpy(thk2, PipC.data.sch_thk_g);
         strcpy(mac_pm[*pm_no].desc.value.att_txt, thk2);
       }

     }
     *pm_no += 1;

     /* Geom std */

     strcpy(mac_pm[*pm_no].name,VR_N_GEOM_STD_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.0;
     if (XX[0].data.geom_std > 0)
     {
        mac_pm[*pm_no].desc.value.att_exp = (double) XX[0].data.geom_std;
     }
     *pm_no += 1;

     /* End std G */

     strcpy(mac_pm[*pm_no].name,VR_N_END_STD_G_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = 0.0;
     end_std_g = 0;
     if (XX[0].data.end_std_g > 0)
     {
        end_std_g = XX[0].data.end_std_g;
     }
     mac_pm[*pm_no].desc.value.att_exp = (double) end_std_g;
     *pm_no += 1;

     /* End std R */

     strcpy(mac_pm[*pm_no].name,VR_N_END_STD_R_IN);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     if (XX[0].data.end_std_r == 0 )
     {
        end_std_r = end_std_g;
     }
     else
     {
        end_std_r = XX[0].data.end_std_r;
     }

     mac_pm[*pm_no].desc.value.att_exp = end_std_r;
     *pm_no += 1;

     /* Thk G */
     
     strcpy(mac_pm[*pm_no].name,VR_N_THK_G_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = VRDBdbl(thk1);
     if((!VRDBdbl(thk1)) && (thk1[0] != 0))
     {
       get_gtt(prep_g, &flag);
       if ( flag == 2 )       /* If prep g is male */     
       {
         IGRlong   retmsg;
         IGRshort  nUnits;
         IGRdouble dThick;

         VR$PDB_SCH (p_msg  = &retmsg,
                     nend   = end_std_g,
                     Sched  = thk1,
                     npd    = SIZE_1,
                     dThk   = &dThick,
                     nUnits = &nUnits);

         /* Access PIPING SCH THK  */
         thick_units = nUnits;
	 if( VRGL_PROJ.prj_units != VRGL_specunit )
	    mac_pm[*pm_no].desc.value.att_exp =
                   converted_to_vds("thickness", thick_units,
                   VRGL_PROJ.prj_units, dThick ,err_ptr);
	   else
           	mac_pm[*pm_no].desc.value.att_exp = dThick;
       }
     }
     *pm_no += 1;

     /* Thk R */
     strcpy(mac_pm[*pm_no].name,VR_N_THK_R_DB);
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = VRDBdbl(thk2);
     if(thk2[0] == 0) 
     {
       mac_pm[*pm_no].desc.value.att_exp = mac_pm[*pm_no -1].desc.value.att_exp;
     }

     if((strcmp(thk2, "NREQD") == 0) || (thk2[0] ==' '))
     {
       strcpy(thk2, "");
     }

     if((!VRDBdbl(thk2)) && (thk2[0] != 0))
     {
       get_gtt(prep_r, &flag);
       if ( flag == 2 )       /* If prep r is male */     
       {

         IGRlong   retmsg;
         IGRshort  nUnits;
         IGRdouble dThick;

         VR$PDB_SCH (p_msg  = &retmsg,
                     nend   = end_std_r,
                     Sched  = thk2,
                     npd    = SIZE_2,
                     dThk   = &dThick,
                     nUnits = &nUnits);

         /* Access PIPING SCH THK  */
         thick_units = nUnits;
         if( VRGL_PROJ.prj_units != VRGL_specunit )
            mac_pm[*pm_no].desc.value.att_exp =
                   converted_to_vds("thickness", thick_units,
                   VRGL_PROJ.prj_units, dThick ,err_ptr);
           else
                mac_pm[*pm_no].desc.value.att_exp = dThick;
       }
     }
     *pm_no += 1;

/**************************************************************************/
/*          MISCELLANEOUS                                                 */

     strcpy(mac_pm[*pm_no].name,"modifier");
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = XX[0].data.modifier;
     *pm_no += 1;

     strcpy(mac_pm[*pm_no].name,"material");
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = (double) XX[0].data.material;
     *pm_no += 1;

     strcpy(mac_pm[*pm_no].name,"commodity");
     mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
     strcpy (mac_pm[*pm_no].desc.value.att_txt, XX[0].data.commodity);
     *pm_no += 1;

     strcpy(mac_pm[*pm_no].name,"fabcat");
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = (double) XX[0].data.fabcat;
     *pm_no += 1;

     strcpy(mac_pm[*pm_no].name,"wt_fctr");
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = (double) XX[0].data.wt_fctr;
     *pm_no += 1;

     strcpy(mac_pm[*pm_no].name,"note_a");
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = (double) XX[0].data.note_a;
     *pm_no += 1;

     strcpy(mac_pm[*pm_no].name,"note_b");
     mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
     mac_pm[*pm_no].desc.value.att_exp = (double) XX[0].data.note_b;
     *pm_no += 1;

/**************************************************************************/

    /* ACCESS PIPING COMM CODE TABLE FOR PDM PART NUM */
    /*------------------------------------------------*/

    iLENN1 = strlen(thk1);
    iLENN2 = strlen(thk2);

    if (thk1[0] == 0 ) strcpy(thk1," ");
    if (thk2[0] == 0 ) strcpy(thk2," ");

    VR$PDB_COMM (p_msg   = &retmsg,
                 si_comm = number,
                 dia1    = dd1,
                 dia2    = dd2,
                 st1     = thk1,
                 st2     = thk2,
                 pdmpart = partnum);

    strcpy(mac_pm[*pm_no].name,VR_N_PDM_PART_NUM_AN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
    strcpy(mac_pm[*pm_no].desc.value.att_txt, partnum);
    *pm_no += 1;

     /* ACCESS THE PIPING COMP TYPE TABLE */
     /*-----------------------------------*/
 
    strcpy (CtK.comp_code, compname);
    strcpy (CtK.sh_code, short_code);

    VR$PDB_CT (p_msg = &retmsg,
               keyin = &CtK,
               p_num = &NN,
               p_rec = &CtR);

    sprintf( number,"");

    *topology = CtR.data.ct_topo;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_TOPO_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp = (double) CtR.data.ct_topo;
    *pm_no += 1;

    *type =  CtR.data.ct_cat;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_TYPE_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp = (double)CtR.data.ct_cat;
    *pm_no += 1;

    strcpy(mac_pm[*pm_no].name,VR_N_COMP_RPTCAT_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp = (double)CtR.data.ct_rptc;
    *pm_no += 1;

    *comp_numcp = CtR.data.ct_nmcp;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_NUMCP_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp =(double) CtR.data.ct_nmcp;
    *pm_no += 1;

    *comp_seccp = CtR.data.ct_2_cp;
    strcpy(mac_pm[*pm_no].name,VR_N_COMP_2ND_CP_IN);
    mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[*pm_no].desc.value.att_exp =(double)CtR.data.ct_2_cp;
    *pm_no += 1;

#ifdef MY_DEBUG
  printf (" ACCPIP end\n");
#endif

  return(1);
}



int extract_num (str1,str2)
char *str1;
char *str2;
{
  int i, k=0;

  str2[0] = 0;
  for(i=0;i<strlen(str1);++i)
  {
    if(isdigit(str1[i]) || str1[i] == '.')
    {
        str2[k]=str1[i];
        k = k+1;
    }
  }
  str2[k]= 0;
  return 1;
}


end implementation Root;
 
