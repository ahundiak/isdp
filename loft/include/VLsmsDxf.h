/* $Id: VLsmsDxf.h,v 1.4 2002/04/09 14:44:09 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        include/VLsmsDxf.h
 *
 * Description: sms to dxf/spades translator
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLsmsDxf.h,v $
 * Revision 1.4  2002/04/09 14:44:09  ahundiak
 * ah
 *
 * Revision 1.3  2001/06/07 20:59:02  ahundiak
 * ah
 *
 * Revision 1.2  2001/01/16 18:12:03  ramarao
 * *** empty log message ***
 *
 * Revision 1.5  2000/11/27  20:22:12  pinnacle
 * ah
 *
 * Revision 1.4  2000/10/15  13:34:54  pinnacle
 * ah
 *
 * Revision 1.3  2000/06/28  17:01:44  pinnacle
 * ah
 *
 * Revision 1.2  2000/05/15  14:48:28  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/25  16:26:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/25  17:39:26  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/15/99  ah      Creation
 *
 ***************************************************************************/
#ifndef VLsmsDxf_include
#define VLsmsDxf_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#define CVG_VERTEX_MAX 1024

/* -----------------------------------------------
 * For storing the currrent cvg element
 */
typedef struct 
{
  TVDcvgPoint pt;
  TVDcvgText  text;
  TVDcvgRange range;
  TVDcvgCurve curve;
  IGRdouble   matrix[16];
} TVLsmsCvgInfo;

/* -----------------------------------------------
 * Standard SMS data
 */
#define SMS_PROD_MAX 128

typedef struct 
{
  IGRchar hull      [64];
  IGRchar block     [64];
  IGRchar assembly  [64];
  IGRchar piece_mark[64];
  IGRchar quantity  [64];
  IGRint  flag;
} TVLsmsProdInfo;

/* -----------------------------------------------
 * Bevel data
 */
#define SMS_BEVEL_MAX 128

typedef struct 
{
  IGRint  flag;
  IGRchar type[64];
  IGRchar process[128];

  IGRdouble stock;
  IGRdouble gap;
  IGRdouble thick1;
  IGRdouble thick2;

  TVDcvgPoint pt1;
  TVDcvgPoint pt2;
  
  IGRint  vertex1;
  IGRint  vertex2;

  struct 
  {
    IGRint    flag;
    IGRdouble angle,length;
  } a,b,c,d,e;
  
} TVLsmsBevelInfo;

/* -----------------------------------------------
 * Spades data section
 * Single tree node
 */
typedef struct 
{  
  IGRchar type       [64];
  IGRchar name       [64];
  IGRchar pcmk       [64];
  IGRchar stage      [64];
  IGRchar parent     [64];
  IGRchar path       [64];
  IGRchar qty        [64];
  IGRchar desc      [128];
  IGRchar notes     [128];
  IGRchar notes2    [128];
  IGRchar notes3    [128];
  IGRchar notes4    [128];
  IGRchar notes5    [128];
  IGRchar platen     [64];
  IGRchar sequence   [64];
  IGRchar destination[64];
  IGRint  flag;

  IGRchar family  [32];
  IGRchar part_num[32];
  IGRchar grade   [32];

  IGRdouble length;
  IGRchar   pri_process[128];
  IGRchar   sec_process[128];
  
} TVLsmsPdfTreeNode;

typedef struct 
{
  IGRchar internal_units[64];
  IGRchar date[64];
  IGRchar pdf_name [256];  
  IGRchar file_name[256];  
  IGRchar pdm_cat[64];  
  IGRchar pdm_part[64];  
  IGRchar pdm_rev[64];  
  IGRchar pdm_status[64];
  IGRchar pre_translate[16];
  IGRint  flag;
} TVLsmsPdfSetup;

typedef struct 
  {
    IGRchar name [64];
    IGRchar owner[64];
    IGRchar hull [64];
    IGRchar hull_app[64];
    IGRchar dimensions[64];
    IGRchar global_coord_system[64];
    IGRchar fwd_perpendicular[64];
    IGRint  flag;
  } TVLsmsPdfShip;

/* Spades production data */
typedef struct 
{ 
  TVDpdfFileInfo file;

  TVLsmsPdfSetup setup;
  TVLsmsPdfShip  ship;

  struct 
  {
    IGRchar name[64];
    IGRchar rev [64];
    IGRint  flag;
  } tree;
  
  struct 
  {
    IGRchar     material_direction[64];
    IGRchar     expand_major[64];
    IGRchar     expand_minor[64];
    TVDcvgPoint pt1,pt2,pt3,pt4;
    IGRchar     is_planar[64];
    IGRint      flag;
  } plate_3d;
  
  // Need to allow nesting
  TVLsmsPdfTreeNode treeNodes[32];
  IGRint            treeNodeIndex;
  
  // Allow translation
  TVDcvgPoint cen;
  
} TVLsmsPdfInfo;

typedef struct 
{
  struct 
  {
    IGRchar thickness  [64];
    IGRchar near_side  [64];
    IGRchar max_marking[64];
    IGRint  flag;
  } plate;

  struct 
  {
    IGRchar part_num      [64];
    IGRchar part_name    [128];
    IGRchar material_type [64];
    IGRchar material_grade[64];
    IGRchar prod_type     [64];
    
    TVDcvgRange range;
    IGRdouble   matrix[16];
    
    IGRint  flag;
  } partInfo;
  
  TVLsmsProdInfo prodInfos[SMS_PROD_MAX];
  IGRint         prodInfoIndex;

  TVDcvgPoint cen;

  TVLsmsBevelInfo bevelInfos[SMS_BEVEL_MAX];
  IGRint          bevelInfoIndex;
  
  // Assume marking lines are not nested
  struct 
  {
    IGRchar type[64];
    IGRchar marked_side[64];
    IGRchar marked_by[128];
    IGRint  wroteCurve;
    IGRint  wrotePoint;
    
    IGRint  flag;
  } marking;
  
  // Other Stuff
  TVLsmsCvgInfo cvg;
  TVLsmsPdfInfo pdf;

  TVDdxfFileInfo dxf1,dxf2;

  // Unit stuff
  IGRchar unitReal[128];
  IGRchar unitTest[128];
  
} TVLsmsDxfInfo;

extern IGRstat VLsmsDxfWritePlateBeg     __((TVLsmsDxfInfo   *info, 
					     TVDxmlParseInfo *parseInfo));

extern IGRstat VLsmsDxfGetTextSymbology  __((TVLsmsDxfInfo   *info, 
					     TVDxmlParseInfo *parseInfo,
					     TVDdxfSymb *symb));

extern IGRstat VLsmsDxfGetCurveSymbology __((TVLsmsDxfInfo   *info, 
					     TVDxmlParseInfo *parseInfo,
					     TVDdxfSymb *symb));

/* -----------------------------------------------
 * Bevel data routines
 */
extern IGRstat VLsmsMakeBevelDataStr    __((TVLsmsBevelInfo *bevel, IGRchar *data));
extern IGRstat VLsmsGetBevelKey         __((TVLsmsBevelInfo *bevel, IGRchar *key));
extern IGRstat VLsmsDumpBevelInfoTable  __(());
extern IGRstat VLsmsEmptyBevelInfoTable __(());
extern IGRstat VLsmsLoadBevelInfoTable  __(());

// Text file interface
extern IGRstat VLsmsGetBevelKeyFromStr  __((IGRchar *str, IGRchar *key));
extern IGRstat VLsmsAddBevelKey         __((IGRchar *key, IGRchar *str));
extern IGRstat VLsmsGetBevelKeyFromFile __((TVLsmsBevelInfo *bevel, IGRchar *key));

// -------------------------
#if defined(__cplusplus)
}
#endif

#endif






