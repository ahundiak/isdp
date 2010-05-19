/* $Id: VDgeomPrint.I,v 1.2 2001/01/11 18:41:18 art Exp $  */

/* Need here for 2.5.0 */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomPrint.I
 *
 * Description:	Geometry Printing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomPrint.I,v $
 *      Revision 1.2  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.1  2000/03/24  17:16:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/00  ah      Creation, Broke up geom routines
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDmem.h"

/* ----------------------------------------------------------
 * Print a matrix for debugging
 */
IGRstat VDgeomPrintMatrix2(FILE      *file,
			   IGRchar   *txt, 
			   IGRint     matrix_type, 
			   IGRdouble *matrix,
			   TGRmdenv_info *mat,
			   TGRmd_env     *env,
			   TGRobj_env    *objOE)
{
  IGRint i,j;
  IGRint needCRLF = 0;

  // Output
  if (file == NULL) file = stdout;
  
  // See what to print
  if (mat) {
    matrix_type = mat->matrix_type;
    matrix      = mat->matrix;
  }
  if (env) {
    matrix_type = env->md_env.matrix_type;
    matrix      = env->md_env.matrix;
  }
  if (objOE) {
    matrix_type = objOE->mod_env.md_env.matrix_type;
    matrix      = objOE->mod_env.md_env.matrix;
  }
  
  // Do It
  if (txt) {
    fprintf(file,"MATRIX %s, ",txt);
    needCRLF = 1;
  }
  if (matrix_type >= 0) {
    fprintf(file,"Type: %d",matrix_type);
    needCRLF = 1;
  }
  if (needCRLF) printf("\n");
  
  for(i = 0; i < 4; i++) {
    for(j = 0; j < 4; j++) {
      fprintf(file,"%8.2f ",matrix[(i*4)+j]);
    }
    fprintf(file,"\n");
  }
  return 1;
}
/* ----------------------------------------------------------
 * Print a matrix for debugging
 */
IGRstat VDgeomPrintMatrix(IGRchar *txt, TGRmdenv_info *mat)
{
  IGRint i,j;

  if (txt) {
    printf("MATRIX %s, ",txt);
  }
  printf("Type: %d\n",mat->matrix_type);

  for(i = 0; i < 4; i++) {
    for(j = 0; j < 4; j++) {
      printf("%8.2f ",mat->matrix[(i*4)+j]);
    }
    printf("\n");
  }
  return 1;
}

/* -----------------------------------------------------------
 * Debug out a curve with optional text header
 */
IGRstat VDgeomPrintCrv(IGRchar *txt,  TGRbsp_curve *bsp)
{

  IGRint  i, j, k;
  
  if (txt) {
    printf("%s\n",txt);
  }

  printf("      order = %d, num_poles = %d, num_knots = %d, ",
	  bsp->order,bsp->num_poles,bsp->num_knots);

  k = (IGRint) bsp->num_poles;
  if(!(bsp->rational)) {

    printf("Non-Rational\n");

    for(i=0;i<k;i++) {
      j = 3*i;
      printf( "      poles[%d] = %8.2f, %8.2f, %8.2f\n",i,
        bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2] );
    }
  }
  else{

    printf("Rational\n");

    for(i=0;i<k;i++){
      j = 3*i;
      printf("      poles[%d] = %8.2f, %8.2f, %8.2f, %8.2f\n",i,
        bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2],bsp->weights[i] );
    }
  }

  k = bsp->num_knots;

  for(i=0;i<k;i++) {

    //VDgeomIsCrvKnotSharp(bsp,bsp->knots[i],&change);
    printf("      knots[%d] = %12.10f %12.3f\n",i,bsp->knots[i]);
  }
  
  {
    IGRint    num;
    IGRdouble cusps[128];
    BSrc      rc;
    
    BSfndcvcsp(bsp,&num,cusps,&rc);
    
    for(i = 0; i < num; i++) {
      printf("      cusp %12.3f\n",cusps[i]);
    }
    
  }
  
  return 1;
}

/* -----------------------------------------------------------
 * Debug out a curve with optional text header
 */
IGRstat VDgeomPrintCrvFile(IGRchar *txt,  TGRbsp_curve *bsp, FILE *file)
{

  IGRint  i, j, k;
  
  if (file == NULL) file = stdout;
  
  if (txt) {
    fprintf(file,"%s\n",txt);
  }

  fprintf(file,"      order = %d, num_poles = %d, num_knots = %d, ",
	  bsp->order,bsp->num_poles,bsp->num_knots);

  k = (IGRint) bsp->num_poles;
  if(!(bsp->rational)) {

    fprintf(file,"Non-Rational\n");

    for(i=0;i<k;i++) {
      j = 3*i;
      fprintf(file,"      poles[%3d] = %12.4f, %12.4f, %12.4f\n",i,
        bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2] );
    }
  }
  else{

    fprintf(file,"Rational\n");

    for(i=0;i<k;i++){
      j = 3*i;
      fprintf(file,"      poles[%3d] = %12.4f, %12.4f, %12.4f, %12.4f\n",i,
        bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2],bsp->weights[i] );
    }
  }

  k = bsp->num_knots;

  for(i=0;i<k;i++) {

    //VDgeomIsCrvKnotSharp(bsp,bsp->knots[i],&change);
    fprintf(file,"      knots[%3d] = %12.4f\n",i,bsp->knots[i]);
  }
  
  {
    IGRint    num;
    IGRdouble cusps[128];
    BSrc      rc;
    
    BSfndcvcsp(bsp,&num,cusps,&rc);
    
    for(i = 0; i < num; i++) {
      fprintf(file,"    cusps[%2d] = %10.4f\n",i,cusps[i]);
    }
    
  }
  
  return 1;
}

/* -----------------------------------------------------------
 * Debug out a curve or surface with optional text header
 */
IGRstat VDgeomPrint(IGRchar        *txt,  
		    TGRbsp_curve   *crv,
		    TGRbsp_surface *srf,
		    TGRmdenv_info  *mat)
{
  if (crv) return VDgeomPrintCrv    (txt,crv);
  if (srf);//turn VDgeomPrintSrf    (txt,srf);
  if (mat) return VDgeomPrintMatrix2(stdout,txt,-1,NULL,mat,NULL,NULL);
  return 0;
}

end implementation Root;



