/* $Id: VDgbl.h,v 1.3 2002/05/10 17:00:09 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDgbl.h
 *
 * Description: Global static pointers
 *              Designed for service packs,
 *              These pointers will not get cleared when a sp
 *              .so is loaded
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDgbl.h,v $
 * Revision 1.3  2002/05/10 17:00:09  ahundiak
 * ah
 *
 * Revision 1.2  2002/05/09 17:45:45  ahundiak
 * ah
 *
 * Revision 1.1  2001/03/11 18:33:11  ahundiak
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/11/01  ah      Creation
 * 05/10/02  ah      Add a few more
 ***************************************************************************/

#ifndef VDgbl_include
#define VDgbl_include

// -------------------------
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// Keep it real simple
extern void *vdGblStaticData00;  // VDlog
extern void *vdGblStaticData01;  // VDdom
extern void *vdGblStaticData02;  // VDctx
extern void *vdGblStaticData03;  // VDcty
extern void *vdGblStaticData04;  // VDct1
extern void *vdGblStaticData05;
extern void *vdGblStaticData06;
extern void *vdGblStaticData07;
extern void *vdGblStaticData08;
extern void *vdGblStaticData09;

extern void *vdGblStaticData10;  // VDvalRis Buffer
extern void *vdGblStaticData11;  // VDpdmChache Tree
extern void *vdGblStaticData12;
extern void *vdGblStaticData13;
extern void *vdGblStaticData14;
extern void *vdGblStaticData15;
extern void *vdGblStaticData16;
extern void *vdGblStaticData17;
extern void *vdGblStaticData18;
extern void *vdGblStaticData19;

extern void *vdGblStaticData20;  // VDvalRis Buffer
extern void *vdGblStaticData21;  // VDpdmChache Tree
extern void *vdGblStaticData22;
extern void *vdGblStaticData23;
extern void *vdGblStaticData24;
extern void *vdGblStaticData25;
extern void *vdGblStaticData26;
extern void *vdGblStaticData27;
extern void *vdGblStaticData28;
extern void *vdGblStaticData29;

#define VDGBL_NUM_STATIC_POINTERS 30

/* -----------------------------------------------
 * Just for grins, have an initializer
 */
extern int VDgblInitStaticData __((IGRint flag));

// -------------------------
#if defined(__cplusplus)
}
#endif
#endif
