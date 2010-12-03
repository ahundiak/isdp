/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDship.h
 *
 * Description: Ship specific information
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDship.h,v $
 *      Revision 1.1  2004/03/29 16:23:59  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/13/04  ah      Creation (Originally in AIM)
 ***************************************************************************/
#ifndef VDSHIP_H
#define VDSHIP_H

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

extern int VDshipGetClassName  __((char *className));
extern int VDshipGetMinHullNum __((int  *minHullNum));
extern int VDshipGetMaxHullNum __((int  *maxHullNum));

extern int VDshipGetFirstHull  __((char *hull));
extern int VDshipGetHulls      __((char *hulls));

extern int VDshipDoDiagrams __(());

extern void VDshipGetCageCode(char *code);
extern void VDshipGetProjCode(char *code);

#if defined(__cplusplus)
}
#endif
#endif
