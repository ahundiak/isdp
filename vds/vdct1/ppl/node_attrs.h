/* $Id: node_attrs.h,v 1.1 2001/01/12 14:47:06 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/node_attrs.h
 *
 * Description: Break out node-attr mapping
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: node_attrs.h,v $
 *      Revision 1.1  2001/01/12 14:47:06  art
 *      sp merge
 *
 * Revision 1.2  2000/06/30  18:52:40  pinnacle
 * pn
 *
 * Revision 1.1  2000/06/06  15:29:22  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/10/00  pn      Set up to control PPL general functions not data dependent
 * 03/28/00  pn      Moved in getNodeAttrName() to allow visability to all PPLS in one
 *                   location with alteration of all locations at one time
 * 05/31/00  pn      set up some alterations of view of Outfit and Group
 * 06/06/00  ah      Chopped out of attribute.h
 * 06/30/00  pn      added some attributes
 ***************************************************************************/

/* ---------------------------------------------------------------
 * Returns attribute name for a particular node type as
 * I - NODE_TYPE 
 * I - ATTR_INDEX
 * O - ATTR_NAMEX
 */

IGRstat getNodeAttrName()
{ 
  IGRstat retFlag;
  
  // Init 
  retFlag = 1;
  *ATTR_NAMEX = 0;
  // PARTS_ASSY~
  if  (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_PARTS)) {
 
    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 16: strcpy(ATTR_NAMEX,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 17: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 18: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 19: strcpy(ATTR_NAMEX,VDCT1_ATTR_QTY);          goto wrapup;  
    case 20: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
    }    
  }
  // PALGROUP
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_PALGROUP)) {

    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_LABOR_CODE);   goto wrapup; 
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_SPECIAL_CODE); goto wrapup;
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_CODE);     goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_STAGE);    goto wrapup;
 
    }    
  }
 
  // PALLET~
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_PALLET)) {

    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_INDEX);   goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_COUNT);        goto wrapup;
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_WEIGHT);       goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_IN_COPICS);    goto wrapup;
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup; 
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_LABOR_CODE);   goto wrapup; 
    case 16: strcpy(ATTR_NAMEX,VDCT1_ATTR_SPECIAL_CODE); goto wrapup;
    case 17: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 18: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 19: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_CODE);     goto wrapup;
    case 20: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
    case 21: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_STAGE);    goto wrapup;
    case 22: strcpy(ATTR_NAMEX,VDCT1_ATTR_PALLET);       goto wrapup; 
    case 23: strcpy(ATTR_NAMEX,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 24: strcpy(ATTR_NAMEX,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 25: strcpy(ATTR_NAMEX,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 26: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 27: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REMARKS); goto wrapup; 
    }    
  }

  // ASSY[2]~
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_ASSY2)) {

    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 16: strcpy(ATTR_NAMEX,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 17: strcpy(ATTR_NAMEX,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 18: strcpy(ATTR_NAMEX,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 19: strcpy(ATTR_NAMEX,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 20: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 21: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 22: strcpy(ATTR_NAMEX,VDCT1_ATTR_QTY);          goto wrapup;  
    case 23: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
 

    }    
  }

  // ENG_ASSY[2]~
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {

    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 16: strcpy(ATTR_NAMEX,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 17: strcpy(ATTR_NAMEX,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 18: strcpy(ATTR_NAMEX,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 19: strcpy(ATTR_NAMEX,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 20: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 21: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 22: strcpy(ATTR_NAMEX,VDCT1_ATTR_QTY);          goto wrapup;  
    case 23: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
      
    }    
  }


  // ENG_ASSY[6]~
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_ENGASSY6)) {

    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 16: strcpy(ATTR_NAMEX,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 17: strcpy(ATTR_NAMEX,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 18: strcpy(ATTR_NAMEX,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 19: strcpy(ATTR_NAMEX,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 20: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 21: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 22: strcpy(ATTR_NAMEX,VDCT1_ATTR_QTY);          goto wrapup;  
    case 23: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
      
    }    
  }
  // Tree Parts Tree
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_PTTREE)) {
    
    switch(ATTR_INDEX) {

    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_NUM_NEXT);     goto wrapup;
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup; 
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_LABOR_CODE);   goto wrapup; 
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_SPECIAL_CODE); goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 16: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 17: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_CODE);     goto wrapup;
    case 18: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
    case 19: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_STAGE);    goto wrapup;
    case 20: strcpy(ATTR_NAMEX,VDCT1_ATTR_QTY);          goto wrapup;  
    case 21: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
    }
  }
 // tree PAL_ASSY~
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_PALASSYS)) {
    
    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_COUNT);        goto wrapup;
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup; 
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_LABOR_CODE);   goto wrapup; 
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_SPECIAL_CODE); goto wrapup;
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_CODE);     goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAL_STAGE);    goto wrapup;
  
    }
  }
// Tree OUTFIT~
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_OUTFIT)) {
    
    switch(ATTR_INDEX) { 
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_NUM_NEXT);     goto wrapup;
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup; 
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup; 
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
  
   }
  }

  // GROUP~
  if ( (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_GROUP)) ) {
    
    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;    
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup;
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;    
    }
  }
  // PART~
  if (!strcmp(NODE_TYPE,VDCT1_ENG_NODE_TYPE_PART)) {
    
    switch(ATTR_INDEX) {
    case  0: strcpy(ATTR_NAMEX,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(ATTR_NAMEX,VDCT1_ATTR_PART_NO);      goto wrapup;
    case  2: strcpy(ATTR_NAMEX,VDCT1_ATTR_PART_REV);     goto wrapup;
    case  3: strcpy(ATTR_NAMEX,VDCT1_ATTR_ISDP_PATH);    goto wrapup;
    case  4: strcpy(ATTR_NAMEX,VDCT1_ATTR_ISDP_NAME);    goto wrapup;
    case  5: strcpy(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  6: strcpy(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM);     goto wrapup;
    case  7: strcpy(ATTR_NAMEX,VDCT1_ATTR_COUNT);        goto wrapup; 
    case  8: strcpy(ATTR_NAMEX,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  9: strcpy(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL);    goto wrapup;   
    case 10: strcpy(ATTR_NAMEX,VDCT1_ATTR_ZONE);         goto wrapup;
    case 11: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT);         goto wrapup;
    case 12: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 13: strcpy(ATTR_NAMEX,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 14: strcpy(ATTR_NAMEX,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 15: strcpy(ATTR_NAMEX,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 16: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 17: strcpy(ATTR_NAMEX,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 18: strcpy(ATTR_NAMEX,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 19: strcpy(ATTR_NAMEX,VDCT1_ATTR_QTY);          goto wrapup;  
    case 20: strcpy(ATTR_NAMEX,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;  
    case 21: strcpy(ATTR_NAMEX,VDCT1_ATTR_SIZE);         goto wrapup; 
    case 22: strcpy(ATTR_NAMEX,VDCT1_ATTR_MATERIAL);     goto wrapup;     
    case 23: strcpy(ATTR_NAMEX,VDCT1_ISDP_ATTR_GRADE);   goto wrapup;
    case 24: strcpy(ATTR_NAMEX,VDCT1_ISDP_ATTR_PLATE_THK); goto wrapup;
    case 25: strcpy(ATTR_NAMEX,VDCT1_ISDP_ATTR_TREATMENT); goto wrapup;
    case 26: strcpy(ATTR_NAMEX,VDCT1_ATTR_PAINT_REF);    goto wrapup;
    case 27: strcpy(ATTR_NAMEX,VDCT1_ATTR_STOCK);        goto wrapup;
    case 28: strcpy(ATTR_NAMEX,VDCT1_ATTR_PCT_MINO);     goto wrapup;
    case 29: strcpy(ATTR_NAMEX,VDCT1_ATTR_MINO);         goto wrapup;
    case 30: strcpy(ATTR_NAMEX,VDCT1_ATTR_CAGE);         goto wrapup;
    case 31: strcpy(ATTR_NAMEX,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 32: strcpy(ATTR_NAMEX,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 33: strcpy(ATTR_NAMEX,VDCT1_ATTR_NOMENCLATURE); goto wrapup;
    case 34: strcpy(ATTR_NAMEX,VDCT1_ATTR_PART_DESCR);   goto wrapup;  
    case 35: strcpy(ATTR_NAMEX,VDCT1_ATTR_PART_REMARKS); goto wrapup;
     
    }
  }
  // Not found
  retFlag = 0;
    
wrapup:
  return retFlag;
}
/* -----------------------------------------------------------
 * control structure to hide a number of attributes from the 
 * edit section on the Attributes form as revised to have two sections
 * gives a count based upon baseInfo of the number of attributes to be
 * shifted to the protected section.  Place protected Attributes first
 * in getNodeAttrName above!
 * done to keep the Attributes from being messed up accidentally
 * I - BASE_INFO
 * 0 - ATTR_OFFSET
 * seen by all ppls that include Compute.h
 */
IGRstat getAttrOffset()
{
  IGRstat retFlag;
  IGRstat traceFlag;
  
  // inits 
  retFlag = 1;
  traceFlag = 0;
  ATTR_OFFSET = 0;

  // say hi 
  if (traceFlag) printf(">>> getAttrOffset()\n");

  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_PART)) { 
    ATTR_OFFSET = 7; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_ASSY)) {
    ATTR_OFFSET = 6; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_UNIT)) {
    ATTR_OFFSET = 9; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_ZONE)) {
    ATTR_OFFSET = 9; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {
    ATTR_OFFSET = 2; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_OUTFIT)) {
    ATTR_OFFSET = 3; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_PTTREE)) {
    ATTR_OFFSET = 1; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_ENGTREE)) {
    ATTR_OFFSET = 5; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) {
    ATTR_OFFSET = 3; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) {
    ATTR_OFFSET = 5; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {
    ATTR_OFFSET = 5; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) {
    ATTR_OFFSET = 5; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_PARTS)) {
    ATTR_OFFSET = 6; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_PALLET)) {
    ATTR_OFFSET = 7; 
    goto wrapup;
  }
  
  if (!strcmp(BASE_INFO.nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) {
    ATTR_OFFSET = 1; 
    goto wrapup;
  }
   
#if 0
  if (!strcmp(BASE_INFO.nodeType,)) {ATTR_OFFSET = 4; goto wrapup;
}

  // save this line to add more easily
#endif
  // failed
  ATTR_OFFSET = 0;
wrapup:
  // say bye
  
  if (traceFlag) {
    printf("<<< getAttrOffset(%d)\n",ATTR_OFFSET);
  }
  return ATTR_OFFSET;
  
}

