/*f
	VLdFeaFunk.I contains all the set of functions to build the 
	constraints and make the user interface with the solver.

JLL 17 Jan 93 : creation date. In fact I splited the VLdevel.I in several
		files VLdev*.I, to make me the life easyer.
JLL 6  May 94 : set in VLcalculPrecont() dev->developpable = 3 or 4 when
		it used to be TRUE and FALSE
*/

class implementation VLabstract;


/*
# ifndef DEBUG
# define DEBUG 1
# endif
*/


#include <stdio.h>
#include "vlprototype.h"

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "gr.h"

#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "bserr.h"
#include "growner.h"
#include "igr.h"

/*
#include "igrdp.h"
#include "godef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"

#include "maerr.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "grmacros.h"
#include "dpezmac.h"

#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "nddef.h"
#include "asmacros.h"
#include "parametric.h"
*/

  

extern	IGRboolean	BScrossp();
extern	IGRdouble	BSdotp();
extern	IGRdouble	BSlenvec();
extern  IGRboolean	BSnorvec();
extern  IGRint		abs();
extern  IGRdouble	sqrt();
extern	IGRdouble	fabs();




/******************************************************************************/
/* VLprecontTria : calcul de precontarinte sur un triangle		      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/

IGRlong VLprecontTria (dev,indices)
struct  mise_a_plat	*dev;
	IGRint		*indices;

{

IGRdouble	I[3], J[3], K[3]; /*repere de l'element a plat */
IGRdouble 	*P, *P1, *P2, *P3;
IGRdouble	a, a1, c, c1, d, d1;
IGRvector	vect;
BSrc		rc;
IGRint		type;
IGRint		i;

 type = dev->type;
 
 /*  Construction de IJK */

 P = dev->P;
 P1= &(P[3*indices[0]]);
 P2= &(P[3*indices[1]]);
 P3= &(P[3*indices[2]]);

 /* v_sub(P2,P1,I);		 I= P1P2 */

 for(i=0;i<3;i++) I[i] = P2[i] - P1[i];
 BSnorvec(&rc,I);
 if (rc!=BSSUCC) {
	printf(" VLmaplatTria : BSnorvec I Fail\n");
	return MSFAIL;}

 /* v_sub(P3,P1,vect);		J= P1P3 */
 for(i=0;i<3;i++) vect[i] = P3[i] - P1[i];
 
 /* v_cross(I,vect,K); */
 BScrossp(&rc,I,vect,K);

 BSnorvec(&rc,K);
 if (rc!=BSSUCC) {
	printf(" VLmaplatTria : BSnorvec I Fail\n");
	return MSFAIL;}

 /* v_cross(K,I,J); */
 BScrossp(&rc,K,I,J);


 /* v_sub(P2,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P2[i] - P1[i];

/* v_dot(vect,I); */
 a = BSdotp(&rc,vect,I);
 
/* v_sub(P3,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P3[i] - P1[i];
/*
 c = v_dot(vect,I);
 d = v_dot(vect,J);
*/
 c = BSdotp(&rc,vect,I);
 d = BSdotp(&rc,vect,J);


 /*  Construction de ijk */
 P = dev->M;
 P1= &(P[3*indices[0]]);
 P2= &(P[3*indices[1]]);
 P3= &(P[3*indices[2]]);

/* v_sub(P2,P1,I);		I= P1P2 */
 for(i=0;i<3;i++) I[i] = P2[i] - P1[i];

 BSnorvec(&rc,I);
 if (rc!=BSSUCC) {
	printf(" VLmaplatTria : BSnorvec I = P1P2 Fail\n");
	return MSFAIL;}


/* v_sub(P3,P1,vect);		
 v_cross(I,vect,K);
 BSnorvec(&rc,K);
 if (rc!=BSSUCC) {printf(" VLmaplatTria : BSnorvec I Fail\n");
		return MSFAIL;}
*/

 K[0] = 0.0;
 K[1] = 0.0;
 K[2] = 1.0;

 /* v_cross(K,I,J); */
 BScrossp(&rc,K,I,J);

 /* v_sub(P2,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P2[i] - P1[i];

 /* a1=v_dot(vect,I); */
 a1 = BSdotp(&rc,vect,I);

 /* v_sub(P3,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P3[i] - P1[i];

/* 
 c1=v_dot(vect,I);
 d1=v_dot(vect,J);
*/
 c1 = BSdotp(&rc,vect,I);
 d1 = BSdotp(&rc,vect,J);

#ifdef DEBUG
	printf(" element %d  : %d %d %d\n",indices[3],
			indices[0],indices[1],indices[2] );
	printf(" a1 : %lf c1 : %lf d1: %lf\n",a1,c1,d1);
	printf(" a  : %lf c  : %lf d : %lf\n",a ,c ,d );
#endif

 dev->def[4*indices[3]] =    I[0]*(a1-a);
 dev->def[4*indices[3]+1] =  J[0]*(a1-a);
 dev->def[4*indices[3]+2] =  I[0]*(c1-c)+J[0]*(d1-d);
 dev->def[4*indices[3]+3] =  I[1]*(c1-c)+J[1]*(d1-d);
 return MSSUCC;
   
}

/******************************************************************************/
/* VLprecontRec : calcul de precontarinte sur un triangle		      */
/* alloue l'espace nescessaire au resultat				      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/
IGRlong VLprecontRec (dev,indices)
struct mise_a_plat	*dev;
IGRint			*indices;
{
IGRdouble	I[3],J[3],K[3]; /*repere de l'element a plat */
IGRdouble 	*P,*P1,*P2,*P3,*P4;
IGRdouble	x[4],y[4],X[4],Y[4];
IGRvector	vect;
BSrc		rc;
IGRint		type,ind;
IGRint		i;

 type = dev->type;
 
 /*  Construction de IJK */
 /*  Calcul de K */
 P = dev->norm;
 P1= &(P[3*indices[0]]);
 P2= &(P[3*indices[1]]);
 P3= &(P[3*indices[2]]);
 P4= &(P[3*indices[3]]);
 K[0] = (P1[0]+P2[0]+P3[0]+P4[0]);
 K[1] = (P1[1]+P2[1]+P3[1]+P4[1]);
 K[2] = (P1[2]+P2[2]+P3[2]+P4[2]);
 BSnorvec(&rc,K);
 if (rc!=BSSUCC) {
	printf(" VLmaplatRec : BSnorvec K Fail\n");
	return MSFAIL;}
 
 P = dev->P;
 P1= &(P[3*indices[0]]);
 P2= &(P[3*indices[1]]);
 P3= &(P[3*indices[2]]);
 P4= &(P[3*indices[3]]);

 /* v_sub(P2,P1,I);		I = P1P2 */
 for(i=0;i<3;i++) I[i] = P2[i] - P1[i];
 BSnorvec(&rc,I);
 if (rc!=BSSUCC) {
	printf(" VLmaplatRec : BSnorvec I Fail\n");
	return MSFAIL;}

 /*v_cross(K,I,J);*/
 BScrossp(&rc,K,I,J);
 

 /* v_sub(P2,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P2[i] - P1[i];
 X[0] = BSdotp(&rc,vect,I);

 /* v_sub(P3,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P3[i] - P1[i];
 X[1] = BSdotp(&rc,vect,I);
 Y[1] = BSdotp(&rc,vect,J);

 /*v_sub(P4,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P4[i] - P1[i]; 
 X[2] = BSdotp(&rc,vect,I);
 Y[2] = BSdotp(&rc,vect,J);


 /*  Construction de ijk */
 P = dev->M;
 P1= &(P[3*indices[0]]);
 P2= &(P[3*indices[1]]);
 P3= &(P[3*indices[2]]);
 P4= &(P[3*indices[3]]);

 /* v_sub(P2,P1,I);		I = P1P2 */
 for(i=0;i<3;i++) I[i] = P2[i] - P1[i]; 
  BSnorvec(&rc,I);
 if (rc!=BSSUCC) {
	printf(" VLmaplatRec : BSnorvec I P1P2 2 Fail\n");
	return MSFAIL;}

 K[0] = 0.0;
 K[1] = 0.0;
 K[2] = 1.0;

 /*v_cross(K,I,J);*/
 BScrossp(&rc,K,I,J);

 /* v_sub(P2,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P2[i] - P1[i];
 x[0] = BSdotp(&rc,vect,I);

 /*v_sub(P3,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P3[i] - P1[i];
 x[1] = BSdotp(&rc,vect,I);
 y[1] = BSdotp(&rc,vect,J);

 /*v_sub(P4,P1,vect);	*/
 for(i=0;i<3;i++) vect[i] = P4[i] - P1[i]; 
 x[2] = BSdotp(&rc,vect,I);
 y[2] = BSdotp(&rc,vect,J);


 ind = 6 * indices[4];
 dev->def[ind]   =  I[0]*(x[0]-X[0]);
 dev->def[ind+1] =  I[1]*(x[0]-X[0]);
 dev->def[ind+2] =  I[0]*(x[1]-X[1])+J[0]*(y[1]-Y[1]);
 dev->def[ind+3] =  I[1]*(x[1]-X[1])+J[1]*(y[1]-Y[1]);
 dev->def[ind+4] =  I[0]*(x[2]-X[2])+J[0]*(y[2]-Y[2]);
 dev->def[ind+5] =  I[1]*(x[2]-X[2])+J[1]*(y[2]-Y[2]);

 return MSSUCC;   
}

/*==========================================================================*/
/* VLcalculPrecont : calcul de precontarinte sur toute la surface	    */
/* alloue l'espace nescessaire au resultat pour dev->def  	            */
/* rend MSSUCC si ok , MSFAIL sinon   					    */
/*==========================================================================*/


IGRlong VLcalculPrecont( dev )
struct mise_a_plat	*dev;

{

IGRint		ret,i,j,indice[5], k;
IGRint		type;
IGRdouble 	prec_max[8],norme=0.0;

 
 type = dev->type;
 dev->def = NULL;

 switch (type){

case 3 :{

 	dev->def = (IGRdouble *) malloc (
			(dev->Nb_u-1)*(dev->Nb_v-1)*8*sizeof(IGRdouble) );
 	if (dev->def==NULL) {
		printf("VLcalculPrecont_tirangles  : alloc dev->def : FAIL \n");
		return MSFAIL;
	}

 	for(i=0;i<dev->Nb_v-1;i++) 
 	  for(j=0;j<dev->Nb_u-1;j++) {
		indice[0]=i*dev->Nb_u+j;
		indice[1]=1+i*dev->Nb_u+j;
		indice[2]=(i+1)*dev->Nb_u+j;
		indice[3]=2*i*(dev->Nb_u-1)+j;
 		ret = VLprecontTria (dev,indice);
 		if (ret!=MSSUCC) {
 			printf(" calcul_VLprecontTrias 1  : FAIL \n");
			return MSFAIL;}
	}

 	for(i=0;i<dev->Nb_v-1;i++) 
 	  for(j=0;j<dev->Nb_u-1;j++) {
		indice[0]=1+(i+1)*dev->Nb_u+j;
		indice[1]=(i+1)*dev->Nb_u+j;
		indice[2]=1+i*dev->Nb_u+j;
		indice[3]=(2*i+1)*(dev->Nb_u-1)+j;
		ret =VLprecontTria (dev,indice);
 		if (ret!=MSSUCC) {
 			printf(" calcul_VLprecontTrias 1 : FAIL \n");
			return MSFAIL;}
 	}

 	for(i=0;i<8;i++) prec_max[i]	= 0.0;
	k = 8 * (dev->Nb_u-1)*(dev->Nb_v-1);
 	for(i=0;i<k;i+=8){ 
 	for(j=0;j<8;j++)  prec_max[j] +=  dev->def[i+j]; 
	}

 	norme = 0.0;
 	for(i=0;i<8;i++) norme	+= prec_max[i] * prec_max[i];

 	break;

      }

case 4 :{

 	dev->def = (IGRdouble *) malloc 
		   ((dev->Nb_u-1)*(dev->Nb_v-1)*6*sizeof(IGRdouble));
 	if (dev->def==NULL) {
		printf("VLcalculPrecontQuad  : alloc def->dev : FAIL \n");
		return MSFAIL;
	}

 	for(i=0;i<dev->Nb_v-1;i++) 
 	  for(j=0;j<dev->Nb_u-1;j++) {
		indice[0]=i*dev->Nb_u+j;
		indice[1]=1+i*dev->Nb_u+j;
		indice[2]=1+(i+1)*dev->Nb_u+j;
		indice[3]=(i+1)*dev->Nb_u+j;
		indice[4]=i*(dev->Nb_u-1)+j;
 		ret = VLprecontRec (dev,indice);
 		if (ret!=MSSUCC) {
 			printf(" VLcalculPrecontQuad 1 : FAIL \n");
			return MSFAIL;}
	  }

	 k = 6 * (dev->Nb_u-1)*(dev->Nb_v-1);

	 for(i=0;i<6;i++) prec_max[i] = 0.0;
	 for(i=0;i<k;i+=6){
	 for(j=0;j<6;j++)  prec_max[j] += dev->def[i+j]; 
	 }
 	 norme = 0.0;
 	 for(i=0;i<6;i++) norme	+= prec_max[i] * prec_max[i];

	 break;
     }

 }

   
 norme = sqrt(norme);
 if ( norme < 0.00001 ) dev->developpable = 3; /* used to be TRUE */
 else 		        dev->developpable = 4; /* used to be FALSE */


 return MSSUCC;
}


/*==========================================================================*/
/* VLecritEntreeMef : ecriture du fichier d'entree pour mef		      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/

IGRlong VLecritEntreeMef(dev,filename)
struct mise_a_plat	*dev;		/* I/O */
IGRchar			*filename;	/* I */

{

FILE			*file;
IGRchar			name[40];
IGRint			i,j;
IGRdouble		*M;
IGRint			type;

 type=dev->type;
 M = dev->M;
 strcpy(name,filename);
 strcat(name,".inp");
 file = fopen(name,"w");

 if (file == NULL) {
		printf(" Impossible d ouvrir le fichier d'entree\n");
		return MSFAIL;}

 fprintf(file,"COOR 0\n");
 fprintf(file," %d   2 2 1 1 1\n",dev->Nb_u*dev->Nb_v);
 for(i=0;i<dev->Nb_u*dev->Nb_v;i++)  
 	fprintf(file,"%d %lf %lf %lf %d %lf %lf %lf 0 0\n",
		i+1,M[3*i],M[3*i+1],M[3*i+2],
		i+1,M[3*i],M[3*i+1],M[3*i+2]);

 fprintf(file,"0 0 0 0 0 0 0 0 0 0\n");

 fprintf(file,"COND 0\n");
 fprintf(file,"1 1  0 0\n");
// fprintf(file,"1 %d\n",VLindex(dev,dev->Nb_u/2-1,dev->Nb_v/2-1,0)/3+1);
 fprintf(file,"1 %d\n",VLindex(dev,0,0,0)/3+1);
 fprintf(file,"0 1  0 0\n");
// fprintf(file,"1 %d\n",VLindex(dev,dev->Nb_u/2,dev->Nb_v/2-1,0)/3+1);
 fprintf(file,"1 %d\n",VLindex(dev,dev->Nb_u-1,0,0)/3+1);
 fprintf(file,"0 0  0 0\n");

 fprintf(file,"PREL 0\n");
 fprintf(file,"2 4\n");
 fprintf(file,"    1    210.0e9    0.3       0.0       0\n");
 fprintf(file,"    2    210.0e7    0.3       0.0       0\n");
 fprintf(file," 0    0        0         0         0\n");

 switch(type) {

 case 3 :{ 
 	fprintf(file,"ELEM 0\n");
 	fprintf(file,"%d 3 3 1 0 0\n",2*(dev->Nb_u-1)*(dev->Nb_v-1));
 	for(i=0;i<dev->Nb_v-1;i++) {
		fprintf(file," %d %d 1 0 1 1 3 %d %d %d\n",
			1+2*i*(dev->Nb_u-1),dev->Nb_u-1,
				1+i*dev->Nb_u,2+i*dev->Nb_u,1+(i+1)*dev->Nb_u); 
	fprintf(file," %d %d 1 0 1 1 3 %d %d %d\n",
		1+(2*i+1)*(dev->Nb_u-1),dev->Nb_u-1,
			2+(i+1)*dev->Nb_u,1+(i+1)*dev->Nb_u,2+i*dev->Nb_u); 
 		}
 	fprintf(file,"0 0 0 0 0 0\n");
 	fprintf(file,"PREC 0\n");
 	for(i=0;i<2*(dev->Nb_u-1)*(dev->Nb_v-1);i++)
	  fprintf(file," %25.16e %25.16e %25.16e %25.16e\n",
	    -dev->def[4*i],-dev->def[4*i+1],-dev->def[4*i+2],-dev->def[4*i+3]);
 	break;
	}

 case 4 :{ 
 	fprintf(file,"ELEM 0\n");
 	fprintf(file,"%d 4 4 1 0 0\n",(dev->Nb_u-1)*(dev->Nb_v-1));
 	for(i=0;i<dev->Nb_v-1;i++) {
		fprintf(file," %d %d 1 0 1 1 4 %d %d %d %d\n",
			1+i*(dev->Nb_u-1),dev->Nb_u-1,
				1+i*dev->Nb_u,
				2+i*dev->Nb_u,
				2+(i+1)*dev->Nb_u,
				1+(i+1)*dev->Nb_u); 
 		}
	fprintf(file,"0 0 0 0 0 0\n");
 	fprintf(file,"PREC 0\n");
 	for(i=0;i<(dev->Nb_u-1)*(dev->Nb_v-1);i++) {
		for(j=0;j<6;j=j+1) fprintf(file," %25.16e",-dev->def[6*i+j]);
		fprintf(file,"\n"); 
	}

 	break;
	}
 }

 fprintf(file,"LINM 0\n");
 fprintf(file," 0 0\n");
 fprintf(file,"STOP\n");

 fclose(file); 
 return MSSUCC;

}

/******************************************************************************/
/* VLlitSortieMef : lecture du fichier de sortie pour mef		      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/

IGRlong VLlitSortieMef(dev,filename,efforts)
struct mise_a_plat	*dev;		/* I/O */
char			*filename;	/* I */
IGRint			efforts	;	/* I */

{

FILE		*file;
char		name[40],string[255];
IGRint		i;
IGRdouble 	*M,*fg,max,fx0,fy0,fy1;
IGRdouble	dx,dy,sumx=0.0,sumy=0.0;


	printf(" FCT  VLlitSortieMef \n");


if ( efforts == 1 ) {
	dev->fg = (IGRdouble *) malloc (
				dev->Nb_u*dev->Nb_v*2*sizeof(IGRdouble) );
 	if (dev->fg == NULL) {
		printf("VLlitSortieMef  : alloc fg : FAIL \n");
		return MSFAIL;}

 	file = fopen("SOL.INF","r");
 	if (file == NULL) {
		printf(" Impossible d ouvrir le fichier d'entree\n");
		return MSFAIL;}

 	max = 0.0;
	sumx =0.0;
	sumy =0.0;
	fg=dev->fg;

 	for(i=0;i<dev->Nb_u*dev->Nb_v;i++) { 
		fscanf(file,"%lf %lf\n",&(fg[2*i]),&(fg[2*i+1]));
		if (fg[2*i]*fg[2*i]+fg[2*i+1]*fg[2*i+1]>max)
			max=fg[2*i]*fg[2*i]+fg[2*i+1]*fg[2*i+1];
		sumx=sumx+fg[2*i];
		sumy=sumy+fg[2*i+1];
		}

 	fclose(file); 
	max = sqrt(max);
 	if (max <= 0.0000001 ) max = 1.0;
 	else for(i=0;i<2*dev->Nb_u*dev->Nb_v;i++) fg[i] = fg[i] / max;

 }

 M = dev->M;
 strcpy(name,filename);
 strcat(name,".res");
 file = fopen(name,"r");

 if (file == NULL) {
		printf(" Impossible d ouvrir le fichier d'entree\n");
		return MSFAIL;}

 while (strcmp(string,"SOLUTION")) fscanf(file,"%s",string);
 while (strcmp(string,"SOLUTION")) fscanf(file,"%s",string);
 while (strcmp(string,"IMPOSE)")) fscanf(file,"%s",string);

 for(i=0;i<dev->Nb_u*dev->Nb_v;i++) {
 
	fscanf(file,"%*d %*lf %*lf %*lf %lf %*c %lf %*c\n",&dx,&dy);
	M[3*i]		= M[3*i]	+dx;
	M[3*i+1]	= M[3*i+1]	+dy;

	#ifdef DEBUG
	printf(" u : %lf %lf\n",dx,dy);
	#endif
 }

 for(i=0;i<15;i++) fscanf(file,"%s",string);
 fscanf(file,"%*d %*lf %*lf %*lf %lf %*c %lf %*c\n",&fx0,&fy0);
 for(i=0;i<dev->Nb_u-2;i++)  
		fscanf(file,"%*d %*lf %*lf %*lf %*lf %*c %*lf %*c\n");
 fscanf(file,"%*d %*lf %*lf %*lf %*lf %*c %lf %*c\n",&fy1);

 fclose(file);
 
 if (efforts == 1 ) {
  	sumx=sumx+fx0;
  	sumy=sumy+fy0+fy1;
	printf(" Somme des efforts : %12.5e %12.5e\n",sumx,sumy); 
	printf(" effort 0 : %12.5e %12.5e\n",fx0,fy0); 
	printf(" effort 1 : %12.5e %12.5e\n",0,fy1); 
 }

return MSSUCC;

}

/*=========================================================================*/


end implementation VLabstract;


