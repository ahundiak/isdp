 /* $Id: VDpdmClass.c,v 1.3 2002/02/28 16:13:23 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmClass.c
 *
 * Description: Used to cycle through classifications to find catalog
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/02/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmClass.c");

/* Statics */
static TVDpdmClass  level;
static IGRstat      loop;
static Form         s_form;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* ------------------------------------------
 * Clear the nth gadget
 * ***/
static IGRstat clearNthGadget( IGRint  nth )
{
    VDASSERT_FN("clearNthGadget");

    IGRstat retFlag = 1;

    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // just a switch
    switch (nth) {
      case  0: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L1);
	  *level.l1 = 0;
	  goto wrapup;
      case  1: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L2);
	  *level.l2 = 0;
	  goto wrapup;
      case  2: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L3); 
	  *level.l3 = 0;
	  goto wrapup;
      case  3: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L4); 
	  *level.l4 = 0;
	  goto wrapup;
      case  4: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L5); 
	  *level.l5 = 0;
	  goto wrapup;
      case  5: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L6);
	  *level.l6 = 0;
	  goto wrapup;
      case  6: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L7); 
	  *level.l7 = 0;
	  goto wrapup;
      case  7: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L8); 
	  *level.l8 = 0;
	  goto wrapup;
      case  8: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L9); 
	  *level.l9 = 0;
	  goto wrapup;
      case  9: 
	  VDpdmClearGadgetList(s_form,VDPDM_CLASS_G_L10); 
	  *level.l10 = 0;
	  goto wrapup;
      default: return 0;

    } // end of switch

    // done
wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}


/* -------------------------------------------
 * Clear up all gadget levels below the current
 * gadget being selected, including catalog, part,
 * revision, filekey, hull appl, and hull appr
 * ***/
static IGRstat clearGadgetLevels( IGRint gadget )
{
    VDASSERT_FN("clearGadgetLevels");

    IGRstat retFlag = 1;
    IGRstat sts;
    IGRint  i, lvl;
    IGRchar buf[1024];
    

    VDASSERTW(gadget != 0);
    
    // init
    buf[0] = '\0';
    lvl  = 0;
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // do it depending on the gadget
    switch (gadget) {

	// Level 1 gadget, clear level 2 and the rest
      case VDPDM_CLASS_G_L1:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L2, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L2
	  lvl = 1;
	  break;

      case VDPDM_CLASS_G_L2:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L3, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L3
	  lvl = 2;
	  break;
 
      case VDPDM_CLASS_G_L3:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L4, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L4
	  lvl = 3;
	  break;
 
      case VDPDM_CLASS_G_L4:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L5, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L5
	  lvl = 4;
	  break;
 
      case VDPDM_CLASS_G_L5:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L6, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L6
	  lvl = 5;
	  break;
 
      case VDPDM_CLASS_G_L6:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L7, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L7
	  lvl = 6;
	  break;
 
      case VDPDM_CLASS_G_L7:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L8, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L8
	  lvl = 7;
	  break;
 
      case VDPDM_CLASS_G_L8:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L9, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L9
	  lvl = 8;
	  break;
 
      case VDPDM_CLASS_G_L9:
	  // check if already cleared
	  VDfrmGetgText(s_form, VDPDM_CLASS_G_L10, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L10
	  lvl = 9;
	  break;
 
    } // end of switch (gadget)

clearLevels:
    // Now we know where to start the clearing, so do it
    if (lvl == 0) goto wrapup;
    for( i = lvl; clearNthGadget( i ); i++ ) {}

    // done
    
wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}


/* ---------------------------------------
 * Fourth level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel10()
{
    VDASSERT_FN("notifyLevel10");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Check other levels
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l2 == 0 ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l3 == 0 ) {
	strcpy(msg,"Select Classification L3 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l4 == 0 ) {
	strcpy(msg,"Select Classification L4 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l5 == 0 ) {
	strcpy(msg,"Select Classification L5 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l6 == 0 ) {
	strcpy(msg,"Select Classification L6 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l7 == 0 ) {
	strcpy(msg,"Select Classification L7 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l8 == 0 ) {
	strcpy(msg,"Select Classification L8 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get level 9
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L9, level.l9 );
    if ( *level.l9 == 0 ) {
	strcpy(msg,"Select Classification L9 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level10 from database
    sprintf(sql, "Select distinct p_level10 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' and p_level3='%s' and p_level4='%s' "
		 "and p_level5='%s' and p_level6='%s' and p_level7='%s' "
		 "and p_level8='%s' and p_level9='%s' order by p_level10;",
		 level.l1, level.l2, level.l3, level.l4, level.l5, 
		 level.l6, level.l7, level.l8, level.l9 );

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;

    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L10, &ris);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * Fourth level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel9()
{
    VDASSERT_FN("notifyLevel9");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Check other levels
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l2 == 0 ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l3 == 0 ) {
	strcpy(msg,"Select Classification L3 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l4 == 0 ) {
	strcpy(msg,"Select Classification L4 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l5 == 0 ) {
	strcpy(msg,"Select Classification L5 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l6 == 0 ) {
	strcpy(msg,"Select Classification L6 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l7 == 0 ) {
	strcpy(msg,"Select Classification L7 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get level 8
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L8, level.l8 );
    if ( *level.l8 == 0 ) {
	strcpy(msg,"Select Classification L8 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level9 from database
    sprintf(sql, "Select distinct p_level9 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' and p_level3='%s' and p_level4='%s' "
		 "and p_level5='%s' and p_level6='%s' and p_level7='%s' "
		 "and p_level8='%s' order by p_level9;",
		 level.l1, level.l2, level.l3, level.l4, level.l5, 
		 level.l6, level.l7, level.l8 );

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;

    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L9, &ris);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;


wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * Fourth level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel8()
{
    VDASSERT_FN("notifyLevel8");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Check other levels
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l2 == 0 ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l3 == 0 ) {
	strcpy(msg,"Select Classification L3 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l4 == 0 ) {
	strcpy(msg,"Select Classification L4 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l5 == 0 ) {
	strcpy(msg,"Select Classification L5 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l6 == 0 ) {
	strcpy(msg,"Select Classification L6 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get level 7
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L7, level.l7 );
    if ( *level.l7 == 0 ) {
	strcpy(msg,"Select Classification L7 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level8 from database
    sprintf(sql, "Select distinct p_level8 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' and p_level3='%s' and p_level4='%s' "
		 "and p_level5='%s' and p_level6='%s' and p_level7='%s' "
		 "order by p_level8;",
		 level.l1, level.l2, level.l3, level.l4,
		 level.l5, level.l6, level.l7 );

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;

    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L8, &ris);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * Seventh level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel7()
{
    VDASSERT_FN("notifyLevel7");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Check other levels
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l2 == 0 ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l3 == 0 ) {
	strcpy(msg,"Select Classification L3 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l4 == 0 ) {
	strcpy(msg,"Select Classification L4 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l5 == 0 ) {
	strcpy(msg,"Select Classification L5 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get level 6
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L6, level.l6 );
    if ( *level.l6 == 0 ) {
	strcpy(msg,"Select Classification L6 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level7 from database
    sprintf(sql, "Select distinct p_level7 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' and p_level3='%s' and p_level4='%s' "
		 "and p_level5='%s' and p_level6='%s' order by p_level7;",
		 level.l1, level.l2, level.l3, level.l4, level.l5, level.l6 );

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;

    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L7, &ris);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * Sixth level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel6()
{
    VDASSERT_FN("notifyLevel6");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    VDrisInitInfo( &ris );
    
    // Check other levels
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l2 == 0 ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l3 == 0 ) {
	strcpy(msg,"Select Classification L3 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    if ( *level.l4 == 0 ) {
	strcpy(msg,"Select Classification L4 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get level 5
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L5, level.l5 );
    if ( *level.l5 == 0 ) {
	strcpy(msg,"Select Classification L5 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level6 value from database
    sprintf(sql, "Select distinct p_level6 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' and p_level3='%s' and p_level4='%s' "
		 "and p_level5='%s' order by p_level6",
		 level.l1, level.l2, level.l3, level.l4, level.l5);

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;

    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L6, &ris);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * Fifth level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel5()
{
    VDASSERT_FN("notifyLevel5");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    VDASSERTW(s_form);

    // init
    VDrisInitInfo( &ris );
    
    // Check other levels
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l2 == 0 ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l3 == 0 ) {
	strcpy(msg,"Select Classification L3 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get level 4
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L4, level.l4 );
    if ( *level.l4 == 0 ) {
	strcpy(msg,"Select Classification L4 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level5 value from database
    sprintf(sql, "Select distinct p_level5 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' and p_level3='%s' and p_level4='%s' "
		 "order by p_level5;",
		 level.l1, level.l2, level.l3, level.l4);

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;

    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L5, &ris);
    if (!(sts & 1)) goto wrapup;
    
    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}



/* ---------------------------------------
 * Fourth level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel4()
{
    VDASSERT_FN("notifyLevel4");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // sayhi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    VDASSERTW(s_form);

    // init
    VDrisInitInfo( &ris );
    
    // Check other levels
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    if ( *level.l2 == 0 ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level3 value from form
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L3, level.l3 );
    if ( *level.l3 == 0 ) {
	strcpy(msg,"Select Classification L3 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }

    // get p_level4 value from database
    sprintf(sql, "Select distinct p_level4 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' and p_level3='%s' "
		 "order by p_level4;",
		 level.l1, level.l2, level.l3);

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;
    
    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L4, &ris);
    if (!(sts & 1)) goto wrapup;
    
    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * Third level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel3()
{
    VDASSERT_FN("notifyLevel3");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[40],
	    sql[1024];

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // Check level.l1
    if ( *level.l1 == 0) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    // get p_level2 value from form
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L2, level.l2 );
    if ( !strcmp(level.l2,"") ) {
	strcpy(msg,"Select Classification L2 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	goto wrapup;
    }
    
    // get p_level3 value from database
    sprintf(sql, "Select distinct p_level3 from pdmcatalogs where "
	         "p_level1='%s' and p_level2='%s' order by p_level3;",
		 level.l1, level.l2);

    VDrisQuery( &ris, sql );
    if( (ris.rows < 1) || (!strcmp(ris.buf[0],"")) ) goto wrapup;

    // fill the gadget list
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L3, &ris);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * Second level of classification from pdmcatalogs
 * Clear up any all other levels
 * ***/
static IGRstat notifyLevel2()
{
    VDASSERT_FN("notifyLevel2");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[80];

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    VDASSERTW(s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get p_level1 value from form
    VDfrmGetgText( s_form, VDPDM_CLASS_G_L1, msg );
    if (traceFlag) printf("###msg, l1 <%s>\n",msg);

    VDfrmGetgText( s_form, VDPDM_CLASS_G_L1, level.l1 );
    if ( *level.l1 == 0 ) {
	strcpy(msg,"Select Classification L1 first");
	VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	if (traceFlag) printf("%s\n",msg);
	goto wrapup;
    }
    
    // get p_level2 value from database
    sprintf(ris.sql, "Select distinct p_level2 from pdmcatalogs where p_level1 = '%s' "
	             "order by p_level2;",
		     level.l1);

    if (traceFlag) printf("### sql <%s>\n",ris.sql);
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // fill the gadget list
    if (traceFlag) printf("###Fill list\n");
    sts = VDpdmFillGadgetList( s_form, VDPDM_CLASS_G_L2, &ris);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    // say bye
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* ---------------------------------------
 * Set default text for level 1
 * ***/
static IGRstat setLevel1Text()
{
    VDASSERT_FN("setLevel1Text");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    IGRchar msg[80];

    TVDrisInfo ris;

    // init
    VDrisInitInfo( &ris );
    
    VDASSERTW(s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // set an initial status
    strcpy(msg,"Select Classifications");
    VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg);

        // get p_level1 values from database
    strcpy(ris.sql,"Select distinct p_level1 from pdmcatalogs order by p_level1;");

    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // fill the default text
    for (i = 0; i < ris.rows; i++) {
	VDfrmSetgListText( s_form, VDPDM_CLASS_G_L1, i, ris.buf[i] ); 	
    }

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* --------------------------------------------------
 * Initialize settings on form.
 * Need to set up the list for level 1.
 * ***/
static IGRstat initClassFormSettings()
{
    VDASSERT_FN("initClassFormSettings");
    
    IGRstat retFlag = 1;
    IGRstat sts;
    IGRint  state;
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // If there are any level info, then set them on the form
    if ( (*level.l1  != 0) ||
	 (*level.l2  != 0) ||
	 (*level.l3  != 0) ||
	 (*level.l4  != 0) ||
	 (*level.l5  != 0) ||
	 (*level.l6  != 0) ||
	 (*level.l7  != 0) ||
	 (*level.l8  != 0) ||
	 (*level.l9  != 0) ||
	 (*level.l10 != 0) )  {

	// set the form values
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L1,  level.l1  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L2,  level.l2  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L3,  level.l3  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L4,  level.l4  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L5,  level.l5  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L6,  level.l6  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L7,  level.l7  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L8,  level.l8  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L9,  level.l9  );
	VDfrmSetgText( s_form, VDPDM_CLASS_G_L10, level.l10 );

	// need some notifications to fill the lists
	if (*level.l1 != 0) notifyLevel2();
	if (*level.l2 != 0) notifyLevel3();
	if (*level.l3 != 0) notifyLevel4();
	if (*level.l4 != 0) notifyLevel5();
	if (*level.l5 != 0) notifyLevel6();
	if (*level.l6 != 0) notifyLevel7();
	if (*level.l7 != 0) notifyLevel8();
	if (*level.l8 != 0) notifyLevel9();
	if (*level.l9 != 0) notifyLevel10();

	// done
	//goto wrapup;
    }

    // no values have been set, so set the level 1 text
    setLevel1Text( s_form );

    // done


wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}


/* ----------------------------------------
 * form notification routine
 * ***/
static IGRint notifyForm(IGRint      f_label,
	                 IGRint      g_label,
			 IGRdouble   value,
			 Form        form)
{
    VDASSERT_FN("notifyForm");

    IGRstat retFlag = 1;
    IGRstat sts;
    IGRchar msg[80];

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);


    // switch on gadget
    switch(g_label) {
      
      case FI_CANCEL:
	  loop = 0;
	  VDfrmDeleteForm( s_form, 1 );
	  s_form = NULL;
	  break;

      case FI_RESET:
	  memset(&level,0,sizeof(TVDpdmClass));
	  initClassFormSettings( );
	  break;


      case VDPDM_CLASS_G_L1:
	  
	  clearGadgetLevels( g_label );
	  sts = notifyLevel2( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L2:
	 
	  clearGadgetLevels( g_label );
	  sts = notifyLevel3( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L3:
	  
	  clearGadgetLevels( g_label );
	  sts = notifyLevel4( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L4:
	  
	  clearGadgetLevels( g_label );
	  sts = notifyLevel5( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L5:
	  
	  clearGadgetLevels( g_label );
	  sts = notifyLevel6( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L6:
	  
	  clearGadgetLevels( g_label );
	  sts = notifyLevel7( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L7:
	  
	  clearGadgetLevels( g_label );
	  sts = notifyLevel8( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L8:

	  clearGadgetLevels( g_label );
	  sts = notifyLevel9( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;

      case VDPDM_CLASS_G_L9:
	  
	  clearGadgetLevels( g_label );
	  sts = notifyLevel10( );
	  if (!(sts & 1)) {
	      loop = 0;
	      strcpy(msg,"Select Catalog");
	      VDfrmSetgText( s_form, VDPDM_CLASS_STAT, msg );
	  }
	  
	  break;
	  
      case VDPDM_CLASS_G_L10:
	  VDfrmGetgText( s_form, VDPDM_CLASS_G_L10, level.l10 );
	  loop = 0;
	  
	  break;
      
    }

wrapup:
    return retFlag;
}
/* -----------------------------------------------
 * Loop on events
 */
static void loopClassForm()
{
  VDASSERT_FN("loopClassForm");
  IGRstat sts;

  XEvent event;
  
  // Should not be called recursivily
  VDASSERTW(s_form);
  
  // Loop until form told to break out
  loop = 1;
  while(loop) {
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
  }
  
 wrapup:
  return;
}

/* ---------------------------------------------
 * Called by the Main form gadget.
 * ***/
IGRstat VDpdmCmdGetClassLevels(TVDpdmClass *class)
{
    VDASSERT_FN("VDpdmCmdGetClassLevels");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;


    //traceFlag = traceFlagx = 0;

    // should not be called again
    VDASSERTW(!s_form);

    // set the static
    memset(&level,0,sizeof(TVDpdmClass));
    // store it locally
    level = *class;
    loop  = 1;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm(VDPDM_CLASS_F_NUM, VDPDM_CLASS_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // Initialize form settings
    sts = initClassFormSettings( );
   

    // loop
    loopClassForm();
    
    // done
    *class = level;
    

wrapup:
    if (s_form) {
	VDfrmDeleteForm(s_form,1);
	s_form = NULL;
    }
    return 0;

}
