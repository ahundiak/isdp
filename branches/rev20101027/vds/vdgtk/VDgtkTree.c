/* --------------------------------------------
 * This actually works pretty good
 * Still need details on freeing up memory
 */

/* example-start tree tree.c */
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctx.h"
#include "VDxdom.h"

#include "glib.h"
#include "xdom.h"
#include <gtk/gtk.h>


VDASSERT_FFN("VDgtkTree.c");

static void add_node_to_tree(GtkWidget *tree, xmlNodePtr xmlNode);


/* for all the GtkItem:: and GtkTreeItem:: signals */
static void cb_itemsignal_expand( GtkTreeItem *item,
                           gchar     *signame )
{

  gint      cnt = 0;
  gint      i;
  gchar     buf[256];
  
  GtkTree   *subtree;

  GtkWidget *atritems;
  GtkWidget *atritem;
  GtkWidget *atrtree;

  xmlNodePtr xmlNode;
  xmlNodePtr xmlNodeChild;

  xmlAttrPtr xmlAttr;
  
  gchar *val;
  gchar *p;
  
  // See if sub items have been added yet
  subtree = GTK_TREE(item->subtree);
  if (subtree == NULL)   goto wrapup;
  if (subtree->children) goto wrapup;

  // Get the dom node
  xmlNode = gtk_object_get_data(GTK_OBJECT(item),"tree_node");
  if (xmlNode == NULL) {
    printf("*** Cannot get the xmlNode\n");
    goto wrapup;
  }

  // Process attributes
  for(cnt = 0, xmlAttr = xmlNode->properties; xmlAttr; cnt++, xmlAttr = xmlAttr->next);
  if (cnt) {
    
    // Make an attributes item
    if (cnt > 9) {  
      atritems = gtk_tree_item_new_with_label("attributes");
      gtk_tree_append (subtree, atritems);
      gtk_widget_show (atritems);

      /* Create this item's subtree */
      atrtree = gtk_tree_new();
      gtk_tree_item_set_subtree (GTK_TREE_ITEM(atritems), atrtree);
    }
    else atrtree = GTK_WIDGET(subtree);
    
    // Items for each attribute
    for(xmlAttr = xmlNode->properties; xmlAttr; xmlAttr = xmlAttr->next) {

      val = (gchar*)xmlGetProp(xmlNode,xmlAttr->name);

      sprintf(buf,"%s = ",(gchar*)xmlAttr->name);
      if (val == NULL) strcat(buf,"*** NO VALUE ***");
      else {
	if (strlen(val) < 100) strcat(buf,val);
	else {
	  p = buf + strlen(buf);
	  memcpy(p,val,100);
	  *(p+100) = 0;
	}
	xmlFree(val);
      }      
      atritem = gtk_tree_item_new_with_label(buf);
      gtk_tree_append (GTK_TREE(atrtree), atritem);
      gtk_widget_show (atritem);

      //if (xmlAttr->last) printf("LAST Pointer is not NULL %s %x\n",xmlAttr->name,xmlAttr->last);
    }
  }

  // Add the kids
  for(xmlNodeChild = xmlNode->xmlChildrenNode; xmlNodeChild; xmlNodeChild = xmlNodeChild->next) {
    if (xmlNodeChild->type == XML_ELEMENT_NODE) {
      add_node_to_tree(GTK_WIDGET(subtree),xmlNodeChild);
    }
#if 0
    if (!xmlIsBlankNode(xmlNodeChild) && strcmp((IGRchar *)xmlNodeChild->name,"text")) { 
      add_node_to_tree(GTK_WIDGET(subtree),xmlNodeChild);
    }
#endif
  }  

  // 
 wrapup:
  return;
}

/* -----------------------------------------------
 * Adds an item to a tree based on the xmlNode pointer
 */
static void add_node_to_tree(GtkWidget *tree, xmlNodePtr xmlNode)
{
  IGRchar buf [4096];
  IGRchar bufx[4096];
  IGRchar *p;
  
  IGRchar *content;
  
  GtkWidget *item,*subtree;
   
  // TGRid *nodeIDx;
  
  // Get the node name and type
  // VDctxGetDisplayName(nodeID,buf);
  // content = (IGRchar*)xmlNodeGetContent(xmlNode);

  content = (IGRchar *)xmlNodeListGetString(xmlNode->doc,xmlNode->xmlChildrenNode,1);

  if (content) {
    for(p = content; (*p) && (*p <= ' '); p++);
    strcpy(bufx,p);
    for(p = bufx + strlen(bufx) - 1; (p >= bufx) && (*p <= ' '); p--);
    *(p+1) = 0;
    xmlFree(content);
  }
  else *bufx = 0;
  
  // if (content) printf("Content '%s'\n'%s'\n-----------------\n",xmlNode->name,content);
  
  if (*bufx) sprintf(buf,"%s '%s'",xmlNode->name,bufx);
  else       sprintf(buf,"%s",     xmlNode->name);
  
  /* Create a tree item */
  item = gtk_tree_item_new_with_label(buf);

  /* Copy the node id and attach it */
  // nodeIDx = g_new(TGRid,1);
  //*nodeIDx = *nodeID;
  gtk_object_set_data(GTK_OBJECT(item),"tree_node",xmlNode);
  

  /* Connect all GtkItem:: and GtkTreeItem:: signals */
  gtk_signal_connect (GTK_OBJECT(item), "expand",
		      GTK_SIGNAL_FUNC(cb_itemsignal_expand), "expand");

  /* Add it to the parent tree */
  gtk_tree_append (GTK_TREE(tree), item);

  /* Show it - this can be done at any time */
  gtk_widget_show (item);

  /* Create this item's subtree */
  subtree = gtk_tree_new();
  gtk_tree_item_set_subtree (GTK_TREE_ITEM(item), subtree);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Init the gtk system, can be called multiple times
 */
static gint gtk_initialized;

void VDgtkInitSystem(gint flag)
{
  int    argc = 1;
  char **argv;
  char  *argx[2];
  
  // Arg check
  if (gtk_initialized) return;
  
  // Init with fake arguments
  // argv = g_new(char *,2);
  argv = argx;
  argv[0] = "isdp";
  gtk_init(&argc,&argv);

  gtk_initialized = 1;
  
  return;
}

static void g_log_my_handler(const gchar    *log_domain,
			     GLogLevelFlags  log_level,
			     const gchar    *message,
			     gpointer	     unused_data)
{
  printf("My Handler '%s'\n",message);
}


/* -----------------------------------------------
 * Pop up tree form
 * Only works with xdom trees?
 */
int VDgtkShowTreeID(TGRid *treeID)
{
  GtkWidget *window, *scrolled_win, *tree;
  gint i;
  guint g_log_handler;

  xmlNodePtr xmlNode;
  
  // g_log_handler = g_log_set_handler(G_LOG_DOMAIN,G_LOG_LEVEL_MESSAGE,g_log_my_handler,NULL);
  
  // Say hi
  // g_message(">>> VDgtkShowTreeID");
  
  // Arg check
  xmlNode = xdom_nodeid_get_node(treeID);
  if (xmlNode == NULL) return 0;
  
  // Init gtk
  VDgtkInitSystem(0);
  
  /* a generic toplevel window */
  window = gtk_window_new (GTK_WINDOW_TOPLEVEL);


  gtk_signal_connect (GTK_OBJECT(window), "delete_event",
		      GTK_SIGNAL_FUNC (gtk_main_quit), NULL);

  gtk_container_set_border_width (GTK_CONTAINER(window), 5);

  /* A generic scrolled window */
  scrolled_win = gtk_scrolled_window_new (NULL, NULL);
  gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scrolled_win),
				  GTK_POLICY_AUTOMATIC,
				  GTK_POLICY_AUTOMATIC);
  gtk_widget_set_usize (scrolled_win, 400, 300);
  gtk_container_add (GTK_CONTAINER(window), scrolled_win);
  gtk_widget_show (scrolled_win);
  
  /* Create the root tree */
  tree = gtk_tree_new();

  /* Add it to the scrolled window */
  gtk_scrolled_window_add_with_viewport (GTK_SCROLLED_WINDOW(scrolled_win),tree);

  /* Set the selection mode */
  gtk_tree_set_selection_mode (GTK_TREE(tree),GTK_SELECTION_MULTIPLE);

  /* Show it */
  gtk_widget_show (tree);

  /* Add Item to tree */
  add_node_to_tree(tree,xmlNode);
  
  /* Show the window and loop endlessly */
  gtk_widget_show (window);  
  gtk_main();

  /* Need a way to intercept each widget being destroyed
   * in order to free the GRid data
   */

  /* Destroy it, the flush makes it actually disappear */
  gtk_widget_destroy(window);
  gdk_flush();


  // g_log_remove_handler(G_LOG_DOMAIN,g_log_handler);

  return 0;
}

/* -----------------------------------------------
 * Show a tree from an xml file
 */
int VDgtkShowTreeFile(gchar *fileName)
{
  TGRid treeID;

  // Init
  treeID.objid = NULL_OBJID;
  
  // Easy enough
  VDxdomCreateTreeFromXmlFile(fileName,&treeID);
  if (treeID.objid == NULL_OBJID) return 0;
  VDgtkShowTreeID(&treeID);
  
 wrapup:
  VDctxDeleteNode(&treeID);
  return 1;
}
#if 0

/* -----------------------------------------------
 * Hold this in reserve, sometimes it's useful
 * to tweak the actual displayed data, sometimes not
 */

/* -----------------------------------------------
 * Display name is dependent on node type
 */
void VDctxGetDisplayName(TGRid *nodeID, IGRchar *displayName)
{
  VDASSERT_FN("VDcxtGetDisplayName");
  IGRchab nodeType;
  IGRchab buf1;
  IGRchab buf2;
  IGRchab buf3;
  
  // Arg check
  VDASSERTW(displayName); strcpy(displayName,"NULL_OBJID");
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Start with node type
  VDctxGetNodeType(nodeID,nodeType);
  VDASSERTW(*nodeType);
  strcpy(displayName,nodeType);

  // Plate
  if (!strcmp(nodeType,"PDF_OBJ_PLATE")) {
    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_PCMK",buf1);
    sprintf(displayName,"%s %s",nodeType,buf1);
    goto wrapup;
  }

  // Label
  if (!strcmp(nodeType,"PDF_OBJ_LABEL")) {
    VDctxGetTxtAtr(nodeID,"PDF_ATR_LABEL_TEXT",buf1);
    sprintf(displayName,"%s %s",nodeType,buf1);
    goto wrapup;
  }

  // Marking Line
  if (!strcmp(nodeType,"PDF_OBJ_MARKING_LINE")) {
    VDctxGetTxtAtr(nodeID,"PDF_ATR_MARKING_LINE_TYPE",buf1);
    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_PCMK",   buf2);
    sprintf(displayName,"%s %s %s",nodeType,buf1,buf2);
    goto wrapup;
  }

  // Tree Node
  if (!strcmp(nodeType,"PDF_OBJ_TREE_NODE")) {
    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_TYPE",buf1);
    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_PCMK",buf2);
    if (*buf2 == 0) {  
      VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_NAME",buf2);
    }
    sprintf(displayName,"%s %s",buf1,buf2);
    goto wrapup;
  }

  // Tree
  if (!strcmp(nodeType,"PDF_OBJ_TREE")) {
    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NAME",buf1);
    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_REV", buf2);
    sprintf(displayName,"%s UNIT %s, SPADES REV %s","STAGING TREE",buf1,buf2);
    goto wrapup;
  }

  // Setup
  if (!strcmp(nodeType,"PDF_OBJ_SETUP")) {
    VDctxGetTxtAtr(nodeID,"PDF_ATR_SETUP_FILE_NAME",buf1);
    sprintf(displayName,"%s %s",nodeType,buf1);
    goto wrapup;
  }

  // Ship
  if (!strcmp(nodeType,"PDF_OBJ_SHIP")) {
    VDctxGetTxtAtr(nodeID,"PDF_ATR_SHIP_HULL",    buf1);
    VDctxGetTxtAtr(nodeID,"PDF_ATR_SHIP_HULL_APP",buf2);
    sprintf(displayName,"%s %s%s",nodeType,buf1,buf2);
    goto wrapup;
  }

  // Staging tree PM
  if (!strcmp(nodeType,"PM")) {
    VDctxGetTxtAtr(nodeID,"pcmk",     buf1);
    VDctxGetTxtAtr(nodeID,"node_name",buf2);
    sprintf(displayName,"%s %s %s","PIECE",buf1,buf2);
    goto wrapup;
  }

  // Have a node_name
  VDctxGetTxtAtr(nodeID,"node_name",buf1);
  if (*buf1) {
    sprintf(displayName,"%s %s",nodeType,buf1);
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * The materials cache tree 
   */
  if (!strcmp(nodeType,"material")) {
    VDctxGetTxtAtr(nodeID,"material", buf1);
    sprintf(displayName,"%s %s",nodeType,buf1);
    goto wrapup;
  }
  if (!strcmp(nodeType,"grade")) {
    VDctxGetTxtAtr(nodeID,"grade", buf1);
    sprintf(displayName,"%s %s",nodeType,buf1);
    goto wrapup;
  }
  /* ---------------------------------------------
   * The familys cache tree 
   */
  if (!strcmp(nodeType,"family")) {
    VDctxGetTxtAtr(nodeID,"family",  buf1);
    VDctxGetTxtAtr(nodeID,"material",buf2);
    VDctxGetTxtAtr(nodeID,"type",    buf3);
    sprintf(displayName,"%s %s %s %s",nodeType,buf3,buf1,buf2);
    goto wrapup;
  }
  if (!strcmp(nodeType,"part")) {
    VDctxGetTxtAtr(nodeID,"part_num", buf1);
    VDctxGetTxtAtr(nodeID,"thickness",buf2);
    sprintf(displayName,"%s %s %s",nodeType,buf1,buf2);
    goto wrapup;
  }
  /* ---------------------------------------------
   * The tolerances cache tree 
   */
  if (!strcmp(nodeType,"tolerance")) {
    VDctxGetTxtAtr(nodeID,"name", buf1);
    VDctxGetTxtAtr(nodeID,"value",buf2);
    sprintf(displayName,"%s %s %s",nodeType,buf1,buf2);
    goto wrapup;
  }
  /* ---------------------------------------------
   * The staging cache tree 
   */
  if (!strcmp(nodeType,"stage")) {
    VDctxGetTxtAtr(nodeID,"type", buf1);
    sprintf(displayName,"%s %s",nodeType,buf1);
    goto wrapup;
  }
  if (!strcmp(nodeType,"stage_parent")) {
    VDctxGetTxtAtr(nodeID,"type",   buf1);
    VDctxGetTxtAtr(nodeID,"parent", buf2);
    sprintf(displayName,"%s %s feeds %s",nodeType,buf1,buf2);
    goto wrapup;
  }
  if (!strcmp(nodeType,"stage_platen")) {
    VDctxGetTxtAtr(nodeID,"type",   buf1);
    VDctxGetTxtAtr(nodeID,"platen", buf2);
    sprintf(displayName,"%s %s %s",nodeType,buf1,buf2);
    goto wrapup;
  }

 wrapup:
  return;
}
#endif
