/* $Id: VDship.c,v 1.1 2004/03/29 15:21:15 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdah/c/VDship.c
 *
 * Description: Access ship specific information
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDship.c,v $
 * Revision 1.1  2004/03/29 15:21:15  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/13/04  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDval.h"
#include "VDsys.h"
#include "VDdom2.h"
#include "VDship.h"

static domNode sShipClassNode;

static domNode getShipClassNode()
{
  char path[128];

  /* Use cache */
  if (sShipClassNode) return sShipClassNode;

  /* Find the file */
  VDsysFindFile("config/xml","ship_class.xml",path);
  if (*path == 0) goto wrapup;
  
  /* Create it */
  sShipClassNode = domCreateDocFromFile(path);

wrapup:
  return sShipClassNode;
}
int VDshipGetClassName(char *className)
{
  int retFlag = 0;
  domNode shipClassNode;

  /* Init */
  strcpy(className,"lpd");

  /* get the node */
  shipClassNode = getShipClassNode();
  if (shipClassNode == NULL) goto wrapup;

  /* The class */
  domGetNodeProp(shipClassNode,"ship_class_name",className);
  retFlag = 1;

wrapup:
  return retFlag;
}
int VDshipGetMaxHullNum(int *a_maxHullNum)
{
  int  retFlag = 0;
  int  maxHullNum = 0;
  int  hullNum;
  int  i;
  char buf[32];

  domNode shipClassNode;
  domNode hullNode;

  /* Get the ship node */
  shipClassNode = getShipClassNode();
  if (shipClassNode == NULL) {
    maxHullNum = 28;
    goto wrapup;
  }

  /* Cycle through */
  for(i = 0; 
      hullNode = domGetNthChildNodeForName(shipClassNode,"ship_hull",i); 
      i++) {
    domGetNodeProp(hullNode,"hull_num",buf);
    hullNum = atoi(buf);
    if (hullNum > maxHullNum) {
      maxHullNum = hullNum;
    }
  }
  retFlag = 1;

wrapup:
  *a_maxHullNum = maxHullNum;
  return retFlag;
}
int VDshipGetMinHullNum(int *a_minHullNum)
{
  int  retFlag = 0;
  int  minHullNum = 9999;
  int  hullNum;
  int  i;
  char buf[32];

  domNode shipClassNode;
  domNode hullNode;

  /* Get the ship node */
  shipClassNode = getShipClassNode();
  if (shipClassNode == NULL) {
    minHullNum = 17;
    goto wrapup;
  }

  /* Cycle through */
  for(i = 0; 
      hullNode = domGetNthChildNodeForName(shipClassNode,"ship_hull",i); 
      i++) {
    domGetNodeProp(hullNode,"hull_num",buf);
    hullNum = atoi(buf);
    if (hullNum < minHullNum) {
      minHullNum = hullNum;
    }
  }
  retFlag = 1;

wrapup:
  *a_minHullNum = minHullNum;
  return retFlag;
}

/* ----------------------------------------------
 * Often want to know the first full hull number
 */
int VDshipGetFirstHull(char *hull)
{
  int retFlag = 0;

  char shipClassName[32];
  int  hullNumMin;

  *hull = 0;

  VDshipGetClassName(shipClassName);
  if (*shipClassName == 0) goto wrapup;
  VDshipGetMinHullNum(&hullNumMin);
  sprintf(hull,"%s%d",shipClassName,hullNumMin);

  retFlag = 1;

wrapup:
  return retFlag;
}  
/* ----------------------------------------------
 * return a comma delimited list of hull names
 * suitable for use in a sql query
 */
int VDshipGetHulls(char *hulls)
{
  int retFlag = 0;

  char hull[32];
  char shipClassName[32];
  int  hullNumMin;
  int  hullNumMax;
  int  i;

  /* Init */
  *hulls = 0;

  /* Build select clause */
  VDshipGetClassName(shipClassName);
  VDshipGetMinHullNum(&hullNumMin);
  VDshipGetMaxHullNum(&hullNumMax);

  for(i = hullNumMin; i <= hullNumMax; i++) {
    if (*hulls) strcat(hulls,",");
    sprintf(hull,"%s%d",shipClassName,i);
    strcat (hulls,hull);
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * This is probably not the best spot to put
 * this in but need to control if diagrams are posted
 * based on what class is being worked
 */
int VDshipDoDiagrams()
{
  domNode shipClassNode;
  char diagrams[32];

  /* get the node */
  shipClassNode = getShipClassNode();
  if (shipClassNode == NULL) return 0;

  /* The class */
  domGetNodeProp(shipClassNode,"diagrams",diagrams);
  if (*diagrams == '1') return 1;

  return 0;
}
/* ----------------------------------------------
 * Default Cage Code 
 */
void VDshipGetCageCode(char *code)
{
  domNode shipClassNode;

  /* Init */
  strcpy(code,"1CC97");

  /* get the node */
  shipClassNode = getShipClassNode();
  if (shipClassNode == NULL) return;

  /* The class */
  domGetNodeProp(shipClassNode,"cage_code",code);

  return;
}
/* ----------------------------------------------
 * Default Proj Code 
 */
void VDshipGetProjCode(char *code)
{
  domNode shipClassNode;

  /* Init */
  strcpy(code,"LPOFA");

  /* get the node */
  shipClassNode = getShipClassNode();
  if (shipClassNode == NULL) return;

  /* The class */
  domGetNodeProp(shipClassNode,"proj_code",code);

  return;
}

