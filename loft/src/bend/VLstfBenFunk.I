class implementation VLabstract;

#include        <stdio.h>
#include        <math.h>
#include        <string.h>
#include        <ctype.h>
#include        <stdlib.h>
#include        "vlprototype.h"
#include        "OMerrordef.h"
#include        "OMprimitives.h"
#include        "AS_status.h"
#include        "msdef.h"
#include        "bserr.h"
#include        "grdpbmacros.h"
#include        "gotextdef.h"
#include        "cotxmacros.h"
#include        "asmacros.h"
#include        "exmacros.h"
#include        "grmacros.h"
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "ACdyn_col.h"
#include        "bsparameters.h"
#include        "EMSssprops.h"
#include        "DItypedef.h"
#include        "DIdef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "msmacros.h"
#include        "DImacros.h"
#include        "cotxmacros.h"

#include	"vlstifbend.h"

#include        "bsdotp.h"
#include	"bsalloccv.h"
#include	"bsconstprcv.h"
#include	"bsdistptpt.h"
#include	"bsnorvec.h"
#include	"bssfeval.h"
#include	"bssfevaln.h"
#include	"bstst_plan.h"
#include	"vssectiondef.h"
#include	"vsbeamdef.h"
#include	"vsattr.h"
#include	"vsuattmacros.h"
#include	"vsmiscmacros.h"
#include	"vsoptdef.h"
#include	"vlmsg.h"

#include	"mainvmx.h"

extern	GRclassid	OPP_GR3dlineseg_class_id;
extern	GRclassid	OPP_GR3dlinestr_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;
extern	GRclassid	OPP_GRbcsubbc_class_id;

from	EMSsubbs	import	EMget_props;
from	VSfeature	import	VSgetUsrAttributes;

/*	#define	TRACE	*/

IGRlong VLopen_setup_file (char *name, FILE **ptfile)
{
char		complete_path[DI_PATH_MAX],path[DI_PATH_MAX];
IGRint		i;
IGRlong		sts;

  // search ratio_setup file in the current directory
  *ptfile = fopen(name,"r");
  if (*ptfile == NULL) {
     // get product path
    for( i=0; ; i++ ) {
      sts = ex$get_path(      index   = i,
                              path    = path,
                              len     = DI_PATH_MAX,
                              type    = EX_CONFIG_PATH );
      if( ! (sts&1))  break;
      // t(he first path could be the user path, search in it.
      if (i==0) {
        sprintf( complete_path, "%s%s", path,name);
        *ptfile = fopen( complete_path, "r" );
        if(*ptfile != NULL)      break;
      }
      sprintf( complete_path, "%sconfig/drawing/%s", path,name);
      *ptfile = fopen( complete_path, "r" );
      if(*ptfile != NULL)      break;
    }
  } 
  return 1;
}

long VLgetWholeName (struct GRid *str,char *ff,char cc,int max_text,char *text)
{
long    	  msg,loc_msg,sts;
FILE		  *f_label;
int               i ,nb_usratt;
char              **p_names = NULL;
char              **p_syntaxes = NULL;
struct GRid       usratt;
char              word[50], attr_text[50];
int		  len=0, index=-1;
struct ret_struct rs;

  msg = MSFAIL;
  text[0] = '\0';
  VLopen_setup_file(ff,&f_label);
  if (f_label == NULL) {
    goto wrapup;
  }
  if (f_label) {
              // get the collection id containing user attributes
    sts = om$send (msg = message VSfeature.VSgetUsrAttributes
							( &loc_msg,&usratt),
			senderid = NULL_OBJID,
			targetid = str->objid,
			targetos = str->osnum );
    if (!(sts & 0x00000001 & (loc_msg))) {
      goto wrapup;
    }
    else {
      if (usratt.objid != NULL_OBJID) {
                   // get user attributes
          sts = vs$getUsrAttrContent (msg = &loc_msg,
                                    UAid = &usratt,
   	  	                    p_size = &nb_usratt,
			            p_names = &p_names,
			            p_syntaxes = &p_syntaxes);
          if (!(sts&(loc_msg)&1)) {
            goto wrapup;
          }
	}
        while (EOF != fscanf(f_label,"%s",word)) {
            if (word[0] == cc) {  // each attribute is predeced by %
              if (word[1] == '\0')  fscanf(f_label,"%s",word);
              else strcpy(word,&word[1]);

              sts = om$send( msg = message NDmacro.ACgive_structure(
                                                (int *)&loc_msg,
                                                &index,
                                                word,
                                                &rs,
                                                NULL ) ,
                        senderid = NULL_OBJID,
                        targetid = str->objid,
                        targetos = str->osnum );
	      if ( sts&(loc_msg)&1 ){
		  if( rs.type == text_type ) 
			strcpy( attr_text, rs.var.text_st.text_string );
		  else if( rs.type == double_type )
		  	sprintf ( attr_text, "%g", rs.var.root_pm_st.value );
		  else  continue;

                  len += strlen( attr_text );
                  if (len + 2 >= max_text) break;
                  strcat(text, attr_text );
                  strcat(text, "-");
                  continue;
              }
	      else if (usratt.objid != NULL_OBJID) {
              for (i=0;i<nb_usratt;i++)
              {
                if (!strcmp(word,p_names[i])) {
                  len += strlen(p_syntaxes[i]);
                  if (len + 2 >= max_text) break;
                  strcat(text, p_syntaxes[i]);
                  strcat(text, "-");
                }
              }
           }
          }
        }
    }
   }

  msg = MSSUCC;
 wrapup :
  if (p_names) { VSfreeList( nb_usratt, p_names ) ; p_names = NULL;}
  if (p_syntaxes) { VSfreeList( nb_usratt, p_syntaxes ) ; p_syntaxes = NULL;}
  fclose(f_label);
  return msg;
}
/* ************************************************************************** */
IGRlong	VLcreStifText ( Stfnr, Mat, Len, Wid, web_ratio, Txt, msg)

	struct	GRobj_env	*Stfnr;	/*I	Stiffener object	*/
		IGRdouble	*Mat;	/*I	CS matrix		*/
		IGRdouble	Len;	/*I	Stiffener length	*/
		IGRdouble	Wid;	/*I	Stiffener width		*/
		char		*web_ratio;/*I	web and ratio		*/
	struct	GRid		*Txt;	/*O	Output array		*/
		IGRlong		*msg;	/*O	Completion code		*/

{
		IGRint		sts = OM_S_SUCCESS, len, i, k;
		IGRchar		name[DI_PATH_MAX], dirname[DI_PATH_MAX];
		IGRchar		text[DI_PATH_MAX];
		IGRdouble	length;
		IGRpoint	cog;
		IGRmatrix	Tmp;
		BSrc		rc;
		IGRshort	four=4;

        sts = VLgetWholeName(&(Stfnr->obj_id),"label_setup",'%',
                             DI_PATH_MAX,text);
        if (!(sts&1)) text[0] = '\0';

	/* Retrieve the stiffener name */
	sts = om$send ( msg = message GRgraphics.GRgetname ( msg, name),
			senderid = NULL_OBJID,
			targetid = Stfnr->obj_id.objid,
			targetos = Stfnr->obj_id.osnum );
	if (!(sts & 0x00000001 & (*msg)))
		sprintf ( name, "elem_%d_%d",
			  Stfnr->obj_id.objid, Stfnr->obj_id.osnum);
	else 	sts = di$split ( pathname = name,
                                 dirname = dirname,
                                 name = name);

        if (text[0] != '\0') strcat(text, name);
        else strcpy(text, name);
        strcat(text, "           ");
        strcat(text, web_ratio); // add the web and ratio information.

	/* Placement point for text */

	len = strlen (text);
	if (Len < Wid)	length = Len / 5.0;
	else		length = Wid / 5.0;

	for ( i=0; i<3; i++) {
		k = 4 * i;
		cog[i] = Mat[k+3] + length * Mat[k] + length * Mat[k+1];
	}

	if ( (!MAinvmx ( &rc, &four, Mat, Tmp)) || (rc != MSSUCC) )
	{ printf( "Error in MAinvmx()\n"); *msg = MSFAIL; goto wrapup; }
	Tmp[3] = Tmp[7] = Tmp[11] = 0.0;
	/* Place text */
	sts = co$place_text ( msg	  = msg,
			      text_string = text,
			      text_length = &len,
			      rot_matrix  = Tmp,
			      origin	  = cog,
			      flags	  = 1,
			      buffer	  = Txt );
	as$status ( sts    = sts,
                    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
     return (sts);
}
/* ************************************************************************** */

IGRlong VLgetWords( IGRchar *buffer, IGRchar **word )
{
	IGRint i;

	/* Remove space characters at beginning if it exists */
	for(i=0; i<strlen(buffer); i++)
	   if(buffer[i] != ' ' && buffer[i] != '\t')
	   {
	      strcpy( buffer, &buffer[i] );
	      break;
	   }
	
	/* Replace the end of line character by a blank	*/
	buffer[strlen(buffer)-1] = ' ';	
	i=0;

	while(buffer[0] != '\0')
	   if(buffer[0] != '"')
		VDSGetNextWord(buffer, word[i++], 30, ' ', &buffer);
	   else
	   {	
		/*	Collect the words with in quotes  */
		IGRchar *temp; IGRint ii;
		temp = &buffer[1];
   		for(ii=2; i<strlen(buffer); ii++)
     		     if(buffer[ii] == '"') { buffer[ii] = '\0'; break; }
		strcpy( word[i++],temp );
		buffer = (buffer+ii+2) ;
	   }
	return(1);
}

/* ************************************************************************** */
IGRlong	VLcreStifBend ( Stfnr, Bsurf, cst, Mat, web, nout, Out, msg)

	struct	GRobj_env	*Stfnr;	/*I	Stiffener object	*/
	struct	GRobj_env	*Bsurf;	/*I	Base surface		*/
	struct	GRvg_construct	*cst;	/*I	Construction list	*/
		IGRdouble	*Mat;	/*I	CS matrix		*/
		char		*web;	/*I	web left or right	*/
		IGRint		*nout;	/*O	Output number		*/
	struct	GRid		Out[];	/*O	Output array		*/
		IGRlong		*msg;	/*O	Completion code		*/

{
		IGRint		i, j, k, ii, sts = OM_S_SUCCESS;
                IGRint		dim, num, i1, i2, jM3;
                struct GRobj_env bot_surf;
                struct IGRbsp_surface *sf=NULL;
                IGRlong		loc_msg;
	struct	IGRbsp_surface	*ruledSf;
	struct	IGRbsp_curve	*cv[4], *isoCrv, *CvSol;
		IGRdouble	*intPts, *u, *a, *b, *paPtSol, xAbs, yAbs;
		IGRboolean	tst_planar=FALSE, dispWant=FALSE;
		IGRpoint	org[1];
		IGRvector	nvec[2], xAxis, yAxis;
		IGRdouble	points[3], ratioCou, len[4], par1[2], par2[2];
		BSrc		rc, rcc;
	struct	IGRpolyline	poly;
		IGRuchar	props;
		IGRshort	option=2;
		IGRint		itCou;
                IGRdouble	tmp[7],disti1,disti2;
	        IGRchar         srfName[DI_PATH_MAX], **temp_words = NULL;
                IGRdouble	dot,dirPos[3],*high_point,*low_point;
		VSpartAttr 	attr;
		FILE		*f_ratio=NULL;
                int		found = 0;
                double		ratio;
                char		word[DI_PATH_MAX];
                int 		swap = FALSE;
                struct mise_a_plat	dev;

	/* Initialize */
	ruledSf = NULL;
	for ( i=0; i<4; i++)	cv[i] = NULL;
	isoCrv  = NULL;
	CvSol   = NULL;
	intPts  = NULL;
	u       = NULL;
	a       = NULL;
	b       = NULL;
	paPtSol = NULL;
        VLinitDev(&dev);


        VLopen_setup_file("ratio_setup",&f_ratio);
        if( f_ratio == NULL )    printf("no setup_ratio file\n");

	/* Retrieve base surface geometry (without boundaries) */
	sts = VLgetGeometry ( Bsurf, FALSE, NULL_OBJID,
			      (IGRchar **) &ruledSf, msg);
	as$status ( sts    = sts,
                    msg    = "VLgetGeometry(base surface)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Check if the base surface is planar */
	k = ruledSf->u_num_poles * ruledSf->v_num_poles;
	BStst_plan ( k, ruledSf->poles, ruledSf->weights, &ruledSf->planar,
		     nvec[0], &rc);
	if (rc != BSSUCC) {     printf( "Error in BStst_plan()\n");
                                *msg = MSFAIL; goto wrapup;     }
	
	if (  rc == BSSUCC && fabs( BSdotp(&rcc,nvec[0],nvec[0]) ) < 0.00001 )
        goto wrapup;

/*
	As proposed by JLL this algo will work for Nonplanar surfaces also.

	if it is not planar, unwrap it

	if (!(ruledSf->planar&1)) {

            ex$message (msgnumb = VL_E_NoPlanarSrf)
            dev.surf_id = *Bsurf;
            dev.res_id = dev.surf_id.obj_id;
            sts  = VLgetGeometry(&dev.surf_id, (IGRboolean) TRUE, NULL_OBJID,
                       (IGRchar ** )&dev.surface, msg );
            if (!(sts&(*msg)&1)) goto wrapup;
            dev.type = 4;
            sts = VLgetPtsNorms(&dev,0,0.);
            if (!(sts&1)) { *msg = MSFAIL; goto wrapup;}
            sts = VLmaplatNDevel(&dev);
            if (!(sts&1)) { *msg = MSFAIL; goto wrapup;}
            BSfreesf(&rc,ruledSf);
            ruledSf = dev.devsrf;
            dev.devsrf = NULL;    because we will call freeDev and we will
                                  free ruledSf. So we could free the same
                                  memory twice  
	}
*/
	BSsfevaln ( ruledSf, 0.5, 0.5, 1, &num, points, nvec, &rc);
	if (rc != BSSUCC) {     printf( "Error in BSsfevaln()\n");
                               	*msg = MSFAIL; goto wrapup;     }

	/* Check the surface orientation */
	sts = om$send ( msg = message EMSsubbs.EMget_props (msg,&props),
			senderid = NULL_OBJID,
			targetid = Bsurf->obj_id.objid,
			targetos = Bsurf->obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "EMSsubbs.EMget_props",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (!(props & EMSIS_NRML_REVERSED))
               for (i=0; i<3; i++) nvec[0][i] *= -1.0;


	BSnorvec ( &rc, nvec[0]);
	if (rc != BSSUCC) {     printf( "Error in BSnorvec()\n");
                               	*msg = MSFAIL; goto wrapup;     }

        /* Evaluate the isometric curve : v = 0 */
	BSalloccv ( ruledSf->u_order, ruledSf->u_num_poles, ruledSf->rational,
                    0, &(cv[0]), &rc );
	if (rc != BSSUCC) {     printf( "Error in BSalloccv(v=0)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	option    = 2;
	org[0][0] = 0.0;
	org[0][1] = 0.0;
	BSconstprcv ( &rc, ruledSf, &option, (IGRdouble *)org,
		      &tst_planar, cv[0]);
	if (rc != BSSUCC) {     printf( "Error in BSconstprcv(v=0)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	/* Evaluate the isometric curve : u = 0 */
	BSalloccv ( ruledSf->v_order, ruledSf->v_num_poles, ruledSf->rational,
                    0, &(cv[1]), &rc );
	if (rc != BSSUCC) {     printf( "Error in BSalloccv(u=0)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	option    = 1;
	org[0][0] = 0.0;
	org[0][1] = 0.0;
	BSconstprcv ( &rc, ruledSf, &option, (IGRdouble *)org,
		      &tst_planar, cv[1]);
	if (rc != BSSUCC) {     printf( "Error in BSconstprcv(u=0)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	/* Evaluate the isometric curve : v = 1 */
	BSalloccv ( ruledSf->u_order, ruledSf->u_num_poles, ruledSf->rational,
                    0, &(cv[2]), &rc );
	if (rc != BSSUCC) {     printf( "Error in BSalloccv(v=1)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	option    = 2;
	org[0][0] = 0.0;
	org[0][1] = 1.0;
	BSconstprcv ( &rc, ruledSf, &option, (IGRdouble *)org,
		      &tst_planar, cv[2]);
	if (rc != BSSUCC) {     printf( "Error in BSconstprcv(v=1)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	/* Evaluate the isometric curve : u = 1 */
	BSalloccv ( ruledSf->v_order, ruledSf->v_num_poles, ruledSf->rational,
                    0, &(cv[3]), &rc );
	if (rc != BSSUCC) {     printf( "Error in BSalloccv(u=0)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	option    = 1;
	org[0][0] = 1.0;
	org[0][1] = 1.0;
	BSconstprcv ( &rc, ruledSf, &option, (IGRdouble *)org,
		      &tst_planar, cv[3]);
	if (rc != BSSUCC) {     printf( "Error in BSconstprcv(u=1)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	/* Find the largest curve */
	i1 = 0;
	ratioCou = -1.0;
	for ( i=0; i<4; i++) {

		len[i] = 0.0;
		jM3 = 3 * (cv[i]->num_poles - 1);

		for ( j=0; j<jM3; j=j+3)
			len[i] += BSdistptpt( &rc,
                                              &(cv[i])->poles[j],
                                              &(cv[i])->poles[j+3] );
		if (rc != BSSUCC) {     printf( "Error in BSdistptpt\n");
	                               	*msg = MSFAIL; goto wrapup;     }

		if (len[i] > ratioCou) { i1=i;	ratioCou = len[i]; }
	}

	/*c Set curve index that will be used now */
	if (i1 < 2)	i2 = i1 + 2;
	else	{
 	  i2 = i1 - 2;
         /* swap i1 and i2 because we need cv[i1] to always be the zero 
            isocurve when we will choose between ratio and 1- ratio */
          k = i1;
          i1 = i2;
          i2 = k;
          swap = TRUE;
        }

	/*c Allocate memory for isocurve */
	BSalloccv ( cv[i1]->order, cv[i1]->num_poles, cv[i1]->rational,
		    0, &isoCrv, &rc );
	if (rc != BSSUCC) {     printf( "Error in BSalloccv(isoCrv)\n");
                               	*msg = MSFAIL; goto wrapup;     }

        /* find neutral fib ratio from the set up file */
        if (f_ratio) {
          // get stiffner attributes
          attr.Iwant = VS_m_MatGrade|VS_m_MatType|VS_m_PartFam|VS_m_PartNum;
	  sts = om$send ( msg = message GRvg.GRgetattr ( msg, (char *)&attr),
			senderid = NULL_OBJID,
			targetid = Stfnr->obj_id.objid,
			targetos = Stfnr->obj_id.osnum );
          if (!(sts&(*msg)&1)) {
             printf("Problems at getting attributes\n");
             ratio = 0.5;
          }
          else {
            while (!found && EOF != fscanf(f_ratio,"%s",word))
              if (word[0] == '%') {
                if (word[1] == '\0'){
			IGRchar	buffer[200];

			temp_words = _MALLOC( 6, IGRchar * );
			for(i=0; i<6; ++i)
	  		  temp_words[i] = _MALLOC( 30, IGRchar );

			if( fgets(buffer,199, f_ratio) != NULL )
			VLgetWords(buffer, temp_words );

			if ( (!(strcmp(temp_words[0],attr.info.family)))  &&
			     (!(strcmp(temp_words[1],attr.info.partNum))) &&
			     (!(strcmp(temp_words[2],attr.info.material)))&&
			     (!(strcmp(temp_words[3],attr.info.grade))) )
			{
				found = 1;
				break;
			}
 			for(ii=0; ii<6; ++ii) _FREE( temp_words[ii] );
			_FREE( temp_words );
              }
	    }
            if (found) {
		if      (!(strcmp(web,"web_____l"))) 
				strcpy(word, temp_words[4]);
		else if (!(strcmp(web,"web_____r"))) 
				strcpy(word, temp_words[5]);
                ii=0;

                while (word[ii] != '\0')  {
                  if (!isdigit(word[ii]) && !ispunct(word[ii])) {
                    strcpy(word,"0.5");
                    printf("setup ratio ignored, ratio is fixed to 0.5\n");
                    break;
                  }
                    ii++;
                }
                sscanf(word,"%lf",&ratio);
              }
              else ratio = 0.5;
            }
	}
        else ratio = 0.5;

        /* find which of cv[i1] or cv[i2] is nearest to the 
           the bottom side of lower surface */

	  sprintf ( srfName, "%s:%s:%s", VS_K_bmGrCmpName, VS_K_bmBody,
                          VS_K_nmFlgInfE );
          sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                       &loc_msg,
                                       srfName,
                                       &(bot_surf.obj_id),
                                       &(bot_surf.mod_env.md_env.matrix_type),
                                       bot_surf.mod_env.md_env.matrix),
                      targetid        = Stfnr->obj_id.objid,
                      targetos        = Stfnr->obj_id.osnum,
                      senderid        = NULL_OBJID );
          if (!(sts&loc_msg&1)) {
            printf("Problerms at NDmacro.ACreturn_foot\n");
            goto wrapup;
          }
          if (Stfnr->mod_env.md_env.matrix_type != MAIDMX) {
            dim = 4;
            MAmulmx(&loc_msg,&dim,&dim,&dim,Stfnr->mod_env.md_env.matrix,
                    bot_surf.mod_env.md_env.matrix,
                    bot_surf.mod_env.md_env.matrix);
            MAtypemx( &loc_msg, bot_surf.mod_env.md_env.matrix,
                                      &(bot_surf.mod_env.md_env.matrix_type));
          }
          sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &bot_surf.mod_env.md_env.matrix_type,
                                    bot_surf.mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = bot_surf.obj_id.objid,
                  targetos = bot_surf.obj_id.osnum );
          if (!(loc_msg&sts&1)) {
            printf("PROBLEMS GENABS\n");
          }
          BSptnorsf( sf, cv[i1]->poles , &itCou ,
                   &tmp[0], &tmp[0] ,
                   tmp , &disti1 , &rc ) ;
          if (rc != BSSUCC) printf("Problerms BSptnorsf\n");
          BSptnorsf( sf, cv[i2]->poles , &itCou ,
                   &tmp[0], &tmp[0] ,
                   tmp , &disti2 , &rc ) ;
          if (rc != BSSUCC) printf("Problerms BSptnorsf\n");

	/* Evaluate isocurve at parameter = ratio or 1-ratio.
           In fact, if cv[i1] (which is the zero isocurve) is not
           on the bottom of the stiffner, we must use (1-ratio),
           if it is on this bottom, we use ratio. */
           
	if ((!i1) || (i1==2)) {
          option = 2;
          org[0][0] = 0.0;  
          if (disti1 < disti2) {   // cv[i1] is on the bottom 
            org[0][1] =  ratio; 
            high_point=(cv[i2])->poles; /* the point at the top to 
                                           be used later */
            low_point=(cv[i1])->poles; /* the point at the bottom to
                                           be used later */
          }
          else {
            org[0][1] = 1 - ratio;  // cv[i1] is on the top
            high_point=(cv[i1])->poles;  /* the point at the top to
                                           be used later */
            low_point=(cv[i2])->poles;   /* the point at the bottom to
                                           be used later */ 
          }
        }
        else { 
          option = 1; 
          org[0][1] = 0.0;
          if (disti1 < disti2) {
            org[0][0] =  ratio;		// cv[i1] is on the bottom
            high_point=(cv[i2])->poles;  /* the point at the top to
                                           be used later */ 
            low_point=(cv[i1])->poles;   /* the point at the bottom to
                                           be used later */
          }
          else {
            org[0][0] = 1-ratio;	// cv[i1] is on the top
            high_point=(cv[i1])->poles;  /* the point at the top to
                                           be used later */
            low_point=(cv[i2])->poles;    /* the point at the bottom to
                                           be used later */
          }
        }
       /* swap again to make that cv[i1] be the largest curve,
          this is important for POfndOneFib */
        if (swap == TRUE) {
          k = i1;
          i1 = i2;
          i2 = k;
        }

	BSconstprcv ( &rc, ruledSf, &option, (IGRdouble *)org,
		      &tst_planar, isoCrv);
	if (rc != BSSUCC) {     printf( "Error in BSconstprcv(isoCrv)\n");
                               	*msg = MSFAIL; goto wrapup;     }

	/*c Allocate memory for arrays neede for POfndOneFib() */
	jM3 = 3 * (cv[i1]->num_poles - 1);
	k   = cv[i1]->num_poles;

	intPts  = om$calloc ( num = jM3, structure = IGRdouble);
	u       = om$calloc ( num = k,   structure = IGRdouble);
	a       = om$calloc ( num = k,   structure = IGRdouble);
	b       = om$calloc ( num = k,   structure = IGRdouble);
	k *= 8;
	paPtSol = om$calloc ( num = k,   structure = IGRdouble);

	/* Loop on POfndOneFib() */
	par1[0] = 0.0;
	par2[0] = 1.0;
	j       = 0;

	while (j < k) {

		POfndOneFib ( cv[i1], cv[i2], isoCrv, nvec, par1[0], par2[0],
                              &paPtSol[j], &paPtSol[j+2], intPts,
                              u, a, b, msg );

		if (j >= 8) {
			if ( ( fabs((paPtSol[j]  -paPtSol[j-8])) < 0.01 ) &&
                             ( fabs((paPtSol[j+1]-paPtSol[j-7])) < 0.01 ) )
				break;
		}

		par1[0] = paPtSol[j+1];
		j += 8;
		if (fabs( (paPtSol[j-7]-par2[0]) ) < 0.0000001)	break;
	}

	/* Total number of points to evaluate */
	POcvInsGreKt ( isoCrv, (IGRdouble) 1.005, (IGRint)200,
                       &CvSol, &itCou, &ratioCou, msg );

	/* Check if size of BendCrv is big enough */
	*nout = j / 8;
	if ((*nout + 1) > MACRO_SB_VFEET) {
		printf( "Error in VLcreStifBend() : too many curves\n");
	}
	itCou = CvSol->num_poles / (*nout) + 2;
	if (itCou > 31)	itCou = 31;
	else if ( itCou < 11 ) itCou = 11;

	/* Extract axis and origin from coordinate system matrix */
	for ( i=0; i<3; i++) {
		k = 4 * i;
		xAxis[i]  = Mat[k];
		yAxis[i]  = Mat[k+1];
		org[0][i] = Mat[k+3];
	}

	yAbs = 0.0;
	for ( i=0; i<3; i++) {
		ratioCou = isoCrv->poles[i] - low_point[i];
                yAbs += ratioCou * ratioCou;
	}
	yAbs = sqrt(yAbs);
	xAbs = 0.0;

         // find the normal = isoCrv X (down to up web).  
        
        // the isoCrv axis.
        tmp[0]= isoCrv->poles[3*(isoCrv->num_poles-1)]-isoCrv->poles[0];
        tmp[1]= isoCrv->poles[3*(isoCrv->num_poles-1)+1]-isoCrv->poles[1];
        tmp[2]= isoCrv->poles[3*(isoCrv->num_poles-1)+2]-isoCrv->poles[2];

        // the (down to up web) axis.
        tmp[3] = high_point[0] - isoCrv->poles[0];
        tmp[4] = high_point[1] - isoCrv->poles[1];
        tmp[5] = high_point[2] - isoCrv->poles[2];

         // the normal = isoCrv X (down to up web).  
        BScrossp( msg, &tmp[0], &tmp[3], dirPos );
        if( *msg != BSSUCC ) printf("error in BScrossp\n");
        BSnorvec( (BSrc *) msg, dirPos);
        if( *msg != BSSUCC ) printf("error in BSnorvec\n");
        /* (dot<0) means that the direction of the surface is up to 
           down */
        dot = BSdotp( msg, nvec[0], dirPos );
        if( *msg != BSSUCC ) printf("error in BSdotp\n");

	for ( i=0; i<j; i=i+8) {

		k = 2 + i / 8;

		sts = VLcnstOneFib(isoCrv, CvSol, nvec[0], org[0], xAxis,
				   yAxis, yAbs, &paPtSol[i], itCou, cst,
				   dispWant, &dot, &xAbs, 
                                   &Out[(*nout)+k], msg );
		as$status ( sts    = sts,
	                    msg    = "VLcnstOneFib()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		poly.num_points = 2;
		poly.points = &paPtSol[i+2];
		cst->geometry = (IGRchar *) &poly;

		Out[k].objid = NULL_OBJID;
		Out[k].osnum = cst->env_info->md_id.osnum;
#ifdef TRACE
printf( "Enter in om$construct(GR3dlineseg) :\n\tOut[%d] : (%d|%d), [%g,%g,%g] [%g,%g,%g]\n", k, Out[k].osnum, Out[k].objid, paPtSol[i+2], paPtSol[i+3], paPtSol[i+4], paPtSol[i+5], paPtSol[i+6], paPtSol[i+7]);
#endif
		sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
	                             osnum   = Out[k].osnum,
	                             p_objid = &Out[k].objid,
	                             msg = message GRgraphics.GRaltconstruct
							(cst) );
	        *msg = *(cst->msg);
	        as$status ( sts    = sts,
	                    msg    = "om$construct(OPP_GR3dlineseg_class_id)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		if (dispWant == TRUE)
			gr$display_object ( object_id = &Out[k], mode = GRbd );
	}

         /* if the surface's direction is up to down, we have
            put the feet in the negative zone in order to resolve 
            orientation problems, we will now translate it to the 
            positive zone */
        if (dot < 0) {
double mat[16];
short  matype;
struct GRid cop_obj;

          for (i=1;i<15;i++) mat[i] = 0;
          mat[0] = 1;mat[3] = xAbs*xAxis[0]; 
          mat[5] = 1;mat[7] = xAbs*xAxis[1]; 
          mat[10] = 1;mat[11] = xAbs*xAxis[2]; 
          mat[15] = 1;
          MAtypemx(msg,mat,&matype);
	  for ( i=0; i<j; i=i+8) {
	    k = 2 + i / 8;
            sts = om$send ( msg      = message GRgraphics.GRxform (
                                                msg,
                                                cst->env_info,
                                                &matype,
                                                mat,
                                                &cop_obj.objid ),
                                senderid = NULL_OBJID,
                                targetid = Out[(*nout)+k].objid,
                                targetos = Out[(*nout)+k].osnum );
            if (!((*msg)&sts&1)) {
              write ("Error GRgraphics.GRxform");
              goto wrapup;
           }
           cop_obj.osnum=2;
        }
      }

	/* Evaluate web height */
	yAbs = 0.0;
        for ( i=0; i<3; i++) {
                ratioCou = cv[i1]->poles[i] - cv[i2]->poles[i];
                yAbs += ratioCou * ratioCou;
        }
	yAbs = sqrt(yAbs);
	/* Create the contour foot */
	for ( i=0; i<3; i++) {
		paPtSol[i]    = org[0][i];
                paPtSol[i+3]  = paPtSol[i] + xAbs * xAxis[i];
                paPtSol[i+6]  = paPtSol[i+3] + yAbs * yAxis[i];
                paPtSol[i+9]  = org[0][i] +  yAbs * yAxis[i];
                paPtSol[i+12] = paPtSol[i];
	}
	(*nout) *= 2;

	poly.num_points = 5;
	poly.points     = paPtSol;

	Out[0].objid = NULL_OBJID;
	Out[0].osnum = cst->env_info->md_id.osnum;

	sts = om$construct ( classid = OPP_GR3dlinestr_class_id,
                             osnum   = Out[0].osnum,
                             p_objid = &Out[0].objid,
                             msg = message GRgraphics.GRaltconstruct (cst) );
        *msg = *(cst->msg);
        as$status ( sts    = sts,
                    msg    = "om$construct(OPP_GR3dlinestr_class_id)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if (dispWant == TRUE)
		gr$display_object ( object_id = &Out[0], mode = GRbd );

         if (!(strcmp(web,"web_____l"))) sprintf(word,"WL   %.2lf",ratio); 
         else sprintf(word,"WR   %.2lf",ratio);
	/* Create stiffener name text foot */
	sts = VLcreStifText ( Stfnr, Mat, xAbs, yAbs, word, &Out[1], msg);
        as$status ( sts    = sts,
                    msg    = "VLcreStifText",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*nout += 2;
/*
{
struct GRid surf;
        surf.objid =  NULL_OBJID;
        surf.osnum =  cst->env_info->md_id.osnum;
        cst->geometry = (char*) isoCrv;
        sts = om$construct( classid = OPP_GRbcsubbc_class_id,
                            osnum   = surf.osnum,
                            p_objid = &surf.objid );
        if (!(sts&1)) {
           printf("PROBLEMES dans construct\n"); 
        }
        sts = om$send( msg = message GRgraphics.GRconstruct(cst),
                           senderid = NULL_OBJID,
                           targetid  = surf.objid,
                           targetos  = surf.osnum);
        if (!(sts&1)) printf("PROBLEMS dans GRgraphics.GRconstruct\n");
printf("SURF=%d\n",surf.objid);
gr$display_object (object_id = &surf, mode = GRbd );
}
*/

wrapup:
	/* Free memory */
        fclose(f_ratio);
	if(temp_words)
	{
	   for(ii=0; ii<6; ++ii) _FREE( temp_words[ii] );
	   _FREE( temp_words );
	}

	for ( i=0; i<4; i++) {
		if (cv[i]) {	BSfreecv ( &rc, cv[i]);	cv[i]   = NULL;	}
	}
	if (isoCrv) {	BSfreecv ( &rc, isoCrv);	isoCrv  = NULL;	}
	if (intPts) {	om$dealloc (ptr = intPts);	intPts  = NULL;	}
	if (u) {	om$dealloc (ptr = u);		u       = NULL;	}
	if (a) {	om$dealloc (ptr = a);		a       = NULL;	}
	if (b) {	om$dealloc (ptr = b);		b       = NULL;	}
	if (paPtSol) {	om$dealloc (ptr = paPtSol);	paPtSol = NULL;	}
	if (CvSol) {	BSfreecv ( &rc, CvSol);		CvSol   = NULL;	}
	if (ruledSf) {om$dealloc (ptr = ruledSf);	ruledSf = NULL;}
        VLfreeDev(&dev);
        ex$message (msgnumb = VL_E_Blank);

	return (sts);
}
/* ************************************************************************** */
end implementation VLabstract;
