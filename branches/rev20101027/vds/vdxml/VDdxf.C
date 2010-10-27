/* $Id: VDdxf.C,v 1.2 2001/01/11 21:30:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDdxf.C
 *
 * Description: Basic dxf functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdxf.C,v $
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
 * Revision 1.1  2000/04/25  16:20:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/18  16:26:44  pinnacle
 * sms
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/26/99  ah      Changed to .C for stand alone programs
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDcvg.h"
#include "VDdxf.h"

static int traceFlag;

/* -----------------------------------------------
 * Write a cvg curve
 */
IGRstat VDdxfWriteCvgCurve(TVDdxfFileInfo *dxf,
			   TVDdxfSymb     *symb,
			   IGRint          numVertexes,
			   TVDcvgVertex   *vertexes)
{
  IGRstat retFlag = 0;

  FILE *file;
  TVDcvgVertex *vertex;
  IGRint i;

  TVDdxfSymb ptSymb;
  
  IGRdouble pt[3];
  IGRint    ptOffset = 0;
  
  /* Arg check */
  if (dxf   == NULL) goto wrapup;
  file = dxf->file;
  if (file     == NULL) goto wrapup;
  if (symb     == NULL) goto wrapup;
  if (vertexes == NULL) goto wrapup;

  // Say hi
  if (traceFlag) {
    printf(">>> VDdxfWriteCvgCurve %s %d\n",symb->layer,numVertexes);
  }
  // Marker points for debugging
  memset(&ptSymb,0,sizeof(TVDdxfSymb));
  ptSymb.color = DXF_COLOR_RED;
  strcpy(ptSymb.layer,"PTS");
  strcpy(ptSymb.layer,"33");
  
  // Start
  fprintf(file,"%3u\n%s\n",0,"POLYLINE");
  fprintf(file,"%3u\n%s\n",8, symb->layer);
  fprintf(file,"%3u\n%u\n",62,symb->color);
  fprintf(file,"%3u\n%s\n",66,"1");   /* Entities Follow */

  // Loop through
  for(i = 0; i < numVertexes; i++) {

    // Get it
    vertex = &vertexes[i];
    
    /* Arc bulge applies to previous vertext */
    if (vertex->type == *XML_CVG_VERTEX_TYPE_CARC_TO) {  
      fprintf(file,"%3u\n%f\n",42,vertex->bulge);
    }
    
    // Regular stuff
    fprintf(file,"%3u\n%s\n", 0,"VERTEX");
    fprintf(file,"%3u\n%s\n", 8,symb->layer);
    fprintf(file,"%3u\n%u\n",62,symb->color);   
    fprintf(file,"%3u\n%f\n",10,vertex->endx - dxf->trn.x);        
    fprintf(file,"%3u\n%f\n",20,vertex->endy - dxf->trn.y);        
    fprintf(file,"%3u\n%f\n",30,0.0          - dxf->trn.z);
  }
  
  // Finish up the curve
  fprintf(file,"%3u\n%s\n", 0,"SEQEND");
  
  // For debugging, write out vertex points
  for(i = 0; i < numVertexes; i++) {

    // Get it
    vertex = &vertexes[i];
    
    /* Arc bulge applies to previous vertext */
    if (vertex->type == *XML_CVG_VERTEX_TYPE_CARC_TO) {  
      pt[0] = vertex->midx - dxf->trn.x + ptOffset;
      pt[1] = vertex->midy - dxf->trn.y + ptOffset;
      pt[2] = 0;
      VDdxfWritePoint(dxf,&ptSymb,pt);
    }

    // For debugging, put out the vertex point
    pt[0] = vertex->endx - dxf->trn.x + ptOffset;
    pt[1] = vertex->endy - dxf->trn.y + ptOffset;
    pt[2] = 0;
    VDdxfWritePoint(dxf,&ptSymb,pt);
  }

  // Done
  retFlag = 1;
  
wrapup:

  // Say bi
  if (traceFlag) {
    printf("<<< VDdxfWriteCvgCurve %d\n",retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Write a point
 */
IGRstat VDdxfWritePoint(TVDdxfFileInfo *dxf,
		       TVDdxfSymb      *symb,
		       IGRdouble       *pt)
{
  IGRstat retFlag = 0;

  FILE *file;
  
  /* Arg check */
  if (dxf   == NULL) goto wrapup;
  file = dxf->file;
  if (file == NULL) goto wrapup;
  if (symb == NULL) goto wrapup;
  if (pt   == NULL) goto wrapup;
  
  /* Do It */
  fprintf(file,"%3u\n%s\n",0,"POINT");
  fprintf(file,"%3u\n%s\n",8, symb->layer);
  fprintf(file,"%3u\n%u\n",62,symb->color);
  fprintf(file,"%3u\n%f\n",10,pt[0] - dxf->trn.x);
  fprintf(file,"%3u\n%f\n",20,pt[1] - dxf->trn.y);
  fprintf(file,"%3u\n%f\n",30,pt[2] - dxf->trn.z);
  
  /* Done */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write Text
 */
IGRstat VDdxfWriteText(TVDdxfFileInfo *dxf,
		       TVDdxfSymb     *symb,
		       IGRdouble      *pt,
		       IGRchar        *text)
{
  IGRstat retFlag = 0;

  FILE *file;
  
  /* Arg check */
  if (dxf   == NULL) goto wrapup;
  file = dxf->file;
  if (file == NULL) goto wrapup;
  if (symb == NULL) goto wrapup;
  if (pt   == NULL) goto wrapup;
  if (text == NULL) goto wrapup;
  
  /* Do It */
  fprintf(file,"%3u\n%s\n",0,"TEXT");
  fprintf(file,"%3u\n%s\n",8, symb->layer);
  fprintf(file,"%3u\n%u\n",62,symb->color);
  fprintf(file,"%3u\n%f\n",10,pt[0] - dxf->trn.x);
  fprintf(file,"%3u\n%f\n",20,pt[1] - dxf->trn.y);
  fprintf(file,"%3u\n%f\n",30,pt[2] - dxf->trn.z);

  /* Alignment Point */
  if (symb->text.justify != DXF_JUSTIFY_LEFT) {  
    fprintf(file,"%3u\n%f\n",11,pt[0] - dxf->trn.x);
    fprintf(file,"%3u\n%f\n",21,pt[1] - dxf->trn.y);
    fprintf(file,"%3u\n%f\n",31,pt[2] - dxf->trn.z);
  }
    
  fprintf(file,"%3u\n%f\n",40,symb->text.height);
  fprintf(file,"%3u\n%f\n",50,symb->text.angle);
  fprintf(file,"%3u\n%d\n",72,symb->text.justify);
  fprintf(file,"%3u\n%s\n",1, text);
  
  /* Done */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write Cvg Text
 */
IGRstat VDdxfWriteCvgText(TVDdxfFileInfo *dxf,
			  TVDdxfSymb     *symb,
			  TVDcvgText     *text)
{
  IGRstat retFlag = 0;

  FILE *file;
  
  IGRdouble pt[3];
  
  /* Arg check */
  if (dxf   == NULL) goto wrapup;
  file = dxf->file;
  if (file == NULL) goto wrapup;
  if (symb == NULL) goto wrapup;
  if (text == NULL) goto wrapup;
  
  // Convert the coords
  pt[0] = atof(text->x1);
  pt[1] = atof(text->y1);
  pt[2] = 0.0;
  
  /* Do It */
  fprintf(file,"%3u\n%s\n",0,"TEXT");
  fprintf(file,"%3u\n%s\n",8, symb->layer);
  fprintf(file,"%3u\n%u\n",62,symb->color);
  fprintf(file,"%3u\n%f\n",10,pt[0] - dxf->trn.x);
  fprintf(file,"%3u\n%f\n",20,pt[1] - dxf->trn.y);
  fprintf(file,"%3u\n%f\n",30,pt[2] - dxf->trn.z);

  /* Alignment Point */
#if 0
  if (symb->text.justify != DXF_JUSTIFY_LEFT) {  
    fprintf(file,"%3u\n%f\n",11,pt[0] - dxf->trn.x);
    fprintf(file,"%3u\n%f\n",21,pt[1] - dxf->trn.y);
    fprintf(file,"%3u\n%f\n",31,pt[2] - dxf->trn.z);
  }
#endif
  fprintf(file,"%3u\n%s\n",40,text->height);
  fprintf(file,"%3u\n%s\n",50,text->angle);
  //fprintf(file,"%3u\n%d\n",72,symb->text.justify);
  fprintf(file,"%3u\n%s\n",1, text->value);
  
  /* Done */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Open dxf file 
 */
IGRstat VDdxfOpenOutputFile(TVDdxfFileInfo *dxf, IGRchar *fileName)
{
  IGRstat retFlag = 0;

  // Arg check
  if (dxf == NULL) goto wrapup;
  memset(dxf,0,sizeof(TVDdxfFileInfo));
  if (fileName == NULL) goto wrapup;
  
  /* Open it */
  strcpy(dxf->fileName,fileName);
  dxf->file = fopen(dxf->fileName,"wt");
  if (dxf->file == NULL) {
    printf("Problem opening %s for writing\n",dxf->fileName);
    goto wrapup;
  }
  
  /* Put out dxf headers */
  fprintf(dxf->file,"%3u\n%s\n",0,"SECTION");
  fprintf(dxf->file,"%3u\n%s\n",2,"ENTITIES");
   
  /* Done */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Close dxf file 
 */
IGRstat VDdxfCloseOutputFile(TVDdxfFileInfo *dxf)
{
  IGRint  retFlag = 0;
  IGRchar cmd[256];
  
  /* Check it */
  if (dxf       == NULL) goto wrapup;
  if (dxf->file == NULL) goto wrapup;
  
  /* Out out dxf trailer */
  fprintf(dxf->file,"%3u\n%s\n",0,"ENDSEC");
  fprintf(dxf->file,"%3u\n%s\n",0,"EOF");

  /* Close It */
  fclose(dxf->file);
  dxf->file = NULL;
   
  // Adjust permissions
  sprintf(cmd,"chmod 777 %s",dxf->fileName);
  system (cmd);
  
  /* Done */
  retFlag = 1;
  
wrapup:
  return retFlag;
}


