/*
 * cisymb.C
 * Etienne BEKKER
 * INTERGRAPH FRANCE
 *
 * functions of the command language which have something to do
 * with graphic, displya, symbology
 */

#include "ci.h"
#include "fontdef.h"
#include "font.h"
#include "grdpbmacros.h"
/* -- For new struct implementation
   -- */
typedef struct {
	short	color;		
	char	weight;		
	char	style;		
	short	level;		
	char	locatable;	
	char	displayable;	
	short	font;		
	short	just;		
	double	width;		
	double	height;		
	short	num_char;	
	double	line_spac;	
	double	char_spac;	
	short	text_length;	
	char	*text_string;	
	char	*geometry;	
} CIcnst_list;

extern char			errmess[];

struct GRmd_env 		Ci_env_info;
struct IGRdisplay 		Ci_display;
struct IGResintx		Ci_text_attr;
struct IGRestx			Ci_estx;
struct GRvg_construct 		Ci_cnst_list;	/* construction list */


init_cnst_list()
/*
 * initialise la construction_list
 */
{    
    static IGRlong msg;
    IGRlong NumberOfBytes;
    IGRlong BytesReceived;
    struct  GRdpb_text_symb text_symb;
/*     static IGRboolean already_done = 0;
/* 
/*     /* init_cnst_list must be called only once */
/*     /* when a super_ci will exist, it will be done here */
/*     if( already_done )
/* 	return 1;
/*     else
/* 	already_done = 1;
/* */

    Ci_cnst_list.env_info = &Ci_env_info;
    Ci_cnst_list.display  = &Ci_display;

    /*
     *  get the data set env stuff from the DPB
     */

    NumberOfBytes = sizeof( Ci_env_info );
    gr$get_module_env(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
		buffer = Ci_cnst_list.env_info,
                nret   = &BytesReceived );

    if ( COERROR( msg ) )
    {
        erreur( "init_cnst_list - get_module_env" );
	om$report_error(sts = msg);
	return -1;
    }

    /* divers */
    if( !ci_get_gal_symb( Ci_cnst_list.display, &Ci_cnst_list.level) )
	return -1;

    Ci_cnst_list.msg        = &msg;
    Ci_cnst_list.newflag    = FALSE;
    Ci_cnst_list.properties = GRIS_PLANAR | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    Ci_cnst_list.name       = NULL;

    /* text_2symbology */
    Ci_text_attr.estx       = &Ci_estx;
    Ci_cnst_list.class_attr = (char *)&Ci_text_attr ;
    NumberOfBytes           = sizeof( text_symb );
    gr$get_text_symb(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
		buffer = &text_symb,
                nret   = &BytesReceived );

    if ( COERROR( msg ) )
    {
        erreur( "init_cnst_list -> get_text_symb" );
	om$report_error(sts = msg);
	return -1;
    }

    Ci_text_attr.font_id = -1 ;
    Ci_text_attr.text_string = "dummy";
    Ci_text_attr.estx->font = text_symb.Active_font;
    Ci_text_attr.estx->just = text_symb.Active_just;

    Ci_text_attr.estx->flag = 0;
    Ci_text_attr.estx->line_spac = text_symb.Active_linespac;
    Ci_text_attr.estx->char_spac = text_symb.Active_charspac;
    Ci_text_attr.estx->width = text_symb.Active_width;
    Ci_text_attr.estx->height = text_symb.Active_height;
/* modif JLA
/*
/*    Ci_text_attr.estx->x_scale = 1. ;
/*    Ci_text_attr.estx->y_scale = 1. ;
/* 
/* #ifdef CIASSOC
/*     {
/* 	struct addr_blk fontaddr;
/* 	GRtext_get_xy_scale( (int)text_symb.Active_font,
/* 			     text_symb.Active_width,
/* 			     text_symb.Active_height,
/* 			     &Ci_text_attr.estx->x_scale,
/* 			     &Ci_text_attr.estx->y_scale,
/* 			     &fontaddr );
/*     }
/* #endif
/*
/*******************/
    Ci_text_attr.estx->text_length = (IGRshort)strlen("dummy");
    Ci_text_attr.estx->num_char    = (IGRshort)strlen("dummy");
    Ci_cnst_list.geometry = NULL;
    return 1;
}

ciget_symb( L )
CIcnst_list *L ;
/*
 * converts the C cnst_list in the ci cnst_list
 * for display attributes
 */
{
	L->color	 = Ci_cnst_list.display->color;
	L->weight	 = Ci_cnst_list.display->weight;
	L->style	 = Ci_cnst_list.display->style;
	L->level	 = Ci_cnst_list.level;
	if( Ci_cnst_list.properties & GRIS_LOCATABLE )
		L->locatable = 1;
	else
		L->locatable = 0;
	if( Ci_cnst_list.properties & GRIS_DISPLAYABLE )
		L->displayable = 1;
	else
		L->displayable = 0;

	return ISUCCESS;
}

ciget_text_attr( L )
CIcnst_list *L ;
/*
 * converts the C cnst_list in the ci cnst_list
 * for text attributes
 */
{

/* modif jla
/*	struct addr_blk	addr_block;	/* for GRtext_get_... */
/**********/
	Ci_cnst_list.class_attr = (char *)&Ci_text_attr ;

	L->font		 = Ci_text_attr.estx->font;
	L->just		 = Ci_text_attr.estx->just;
	L->num_char	 = Ci_text_attr.estx->num_char;
	L->line_spac	 = Ci_text_attr.estx->line_spac;
	L->char_spac	 = Ci_text_attr.estx->char_spac;
	L->text_length	 = Ci_text_attr.estx->text_length;
	L->text_string	 = Ci_text_attr.text_string;
	L->geometry	 = Ci_cnst_list.geometry;

/* modif jla
/* #ifdef CIASSOC	
/* 	GRtext_get_width_height (
/* 		(int)Ci_text_attr.estx->font,
/* 		Ci_text_attr.estx->x_scale,
/* 		Ci_text_attr.estx->y_scale,
/* 		&L->width,
/* 		&L->height,
/* 		&addr_block );
/* #endif
/*
/**************/
   L->width  = Ci_text_attr.estx->width;
   L->height = Ci_text_attr.estx->height;


	return ISUCCESS;
}

ciset_symb(L)
CIcnst_list *L ;
/*
 * converts the ci cnst_list in the C cnst_list
 * for display attributes
 */
{
	short color;
	short weight;
	short style;
	short level;
	
	color = L->color ;
/*        if( color < 0 || color > 15 )
/*        {
/*            sprintf(errmess,"set_symb: color out of range:%d, default set",color);
/*            erreur(errmess);
/*	    L->color = color = 0;
/*        }
/* */
	Ci_cnst_list.display->color = color;

	weight = L->weight;
/*        if( weight < 0 || weight > 31 )
/*        {
/*            sprintf(errmess,"set_symb: weight out of range:%d, default set",weight);
/*            erreur(errmess);
/*	    L->weight = weight = 0;
/*        }
/* */
	Ci_cnst_list.display->weight = weight;

	style = L->style; 
/*        if( style < 0 || style >= 8 )
/*        {
/*            sprintf(errmess,"set_symb: style out of range:%d, default set",style);
/*            erreur(errmess);
/*	    L->style = style = 0;
/*        }
/* */
	Ci_cnst_list.display->style = style;

	level = L->level;
/*        if( level < 1 || level >= 64 )
/*        {
/*            sprintf(errmess,"set_symb: level out of range:%d, default set",level);
/*            erreur(errmess);
/*	    L->level = level = 0;
/*        }
/* */
	Ci_cnst_list.level = level;

	if( L->locatable )
		Ci_cnst_list.properties |= GRIS_LOCATABLE;
	else
		Ci_cnst_list.properties &= (~GRIS_LOCATABLE);
	if( L->displayable )
		Ci_cnst_list.properties |= GRIS_DISPLAYABLE;
	else
		Ci_cnst_list.properties &= (~GRIS_DISPLAYABLE);

	/* sets the general active symbology */
        /* suppression de la modification du DPB pour un set_symb normal
	/* ca foutait trop la m.... avec les commandes ecrites en ci existante
	/* (en particulier changement de l'active level vers un level declare
	/* non displayable)      jla 17-10-87 
	/* ci_set_gal_symb( Ci_cnst_list.display,  &Ci_cnst_list.level);
        /******************************/

	
	return ISUCCESS;
}


ciset_gal_symb(L)
CIcnst_list *L ;
/*
 * point d'entree ajoute si le changement de la symbologie dans le DPB
 * est necessaire (c'est sans doute le cas pour les ci_node
 * jla 17-10-87
 * converts the ci cnst_list in the C cnst_list
 * for display attributes
 */
{
	short color;
	short weight;
	short style;
	short level;

	color = L->color ;
/*        if( color < 0 || color > 15 )
/*        {
/*            sprintf(errmess,"set_symb: color out of range:%d, default set",color);
/*            erreur(errmess);
/*	      L->color = color = 0;
/*        }
/* */
	Ci_cnst_list.display->color = color;

	weight = L->weight ;
/*        if( weight < 0 || weight > 100 )
/*        {
/*            sprintf(errmess,"set_symb: weight out of range:%d, default set",weight);
/*            erreur(errmess);
/*	    L->weight = weight = 0;
/*        }
/* */
	Ci_cnst_list.display->weight = weight;

	style = L->style ; 
/*        if( style < 0 || style >= 8 )
/*        {
/*            sprintf(errmess,"set_symb: style out of range:%d, default set",style);
/*            erreur(errmess);
/*	     L->style = style = 0;
/*        }
/* */
	Ci_cnst_list.display->style = style;

	level = L->level ;
/*        if( level < 0 || level >= 64 )
/*        {
/*            sprintf(errmess,"set_symb: level out of range:%d, default set",level);
/*            erreur(errmess);
/*	    L->level = level = 0;
/*        }
/* */
	Ci_cnst_list.level = level;

	if( L->locatable )
		Ci_cnst_list.properties |= GRIS_LOCATABLE;
	else
		Ci_cnst_list.properties &= (~GRIS_LOCATABLE);
	if( L->displayable )
		Ci_cnst_list.properties |= GRIS_DISPLAYABLE;
	else
		Ci_cnst_list.properties &= (~GRIS_DISPLAYABLE);

	/* sets the general active symbology */
	ci_set_gal_symb( Ci_cnst_list.display,  &Ci_cnst_list.level);
	
	return ISUCCESS;
}

ci_set_gal_symb( display,  level)
struct IGRdisplay  *display;
short *level;
{
    IGRlong msg;
    IGRlong NumberOfBytes;

    NumberOfBytes = sizeof( Ci_display );
    gr$put_active_display(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
		buffer = display );

    if ( COERROR( msg ) )
    {
        erreur( "ci_set_symb -> put_active_display" );
	om$report_error(sts = msg);
    }

    NumberOfBytes = sizeof( (Ci_cnst_list.level) );
    gr$put_active_level(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
		buffer = level );

    if ( COERROR( msg ) )
    {
        erreur( "ci_set_symb -> put_active_level" );
	om$report_error(sts = msg);
    }
}

ci_get_gal_symb( display,  level)
struct IGRdisplay  *display;
short *level;
{
	IGRlong msg;
	IGRlong NumberOfBytes;
	IGRlong BytesReceived;

	NumberOfBytes = sizeof( struct IGRdisplay);
	gr$get_active_display(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
		buffer = display,
                nret   = &BytesReceived );

	if ( COERROR( msg ) ){
	        erreur( "ci_get_gal_symb -> get_active_display" );
		om$report_error(sts = msg);
	}

	/* save the current active level */
	NumberOfBytes = sizeof( short);
	gr$get_active_level(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
		buffer = level,
                nret   = &BytesReceived );

	if ( COERROR( msg ) ){
	        erreur( "ci_get_gal_symb - get_active_level" );
		om$report_error(sts = msg);
		return 0;
	}
	return 1;
}


ciset_text_attr(L)
CIcnst_list *L ;
/*
 * converts the ci cnst_list in the C cnst_list
 * for text attributes
 */
{
/* modif jla
/*	struct addr_blk	addr_block;	/* for GRtext_get_... */
/********/
	Ci_cnst_list.class_attr = (char *)&Ci_text_attr ;

	Ci_text_attr.estx->font		= L->font	;
	Ci_text_attr.estx->just 	= L->just	;
	Ci_text_attr.estx->num_char 	= L->num_char	;
	Ci_text_attr.estx->line_spac 	= L->line_spac	;
	Ci_text_attr.estx->char_spac 	= L->char_spac	;
	Ci_text_attr.estx->text_length 	= L->text_length;
	Ci_text_attr.text_string 	= L->text_string;
	Ci_cnst_list.geometry 		= L->geometry	;

/* modif jla
/* #ifdef CIASSOC	
/* 	GRtext_get_xy_scale (
/* 		(int)Ci_text_attr.estx->font,
/* 		L->width,
/* 		L->height,
/* 		&Ci_text_attr.estx->x_scale,
/* 		&Ci_text_attr.estx->y_scale,
/* 		&addr_block );
/* #endif
/*
/*******/
	Ci_text_attr.estx->width 	= L->width;
	Ci_text_attr.estx->height 	= L->height;
     

	return ISUCCESS;
}


CI_SYMB(fname)
char *fname;
/*
 * general function inherited from cifcall
 */
{
	extern struct instance_ci	*ci_data;
	extern char			**ci_data_varvaltable;
	int icn = ci_data->i_cnst_list;

	if( icn == -1 )
		return 1;

	if(!strcmp("set_text_attr", fname))
		return ciset_text_attr((CIcnst_list *)cival(icn));

	if(!strcmp("get_text_attr", fname))
		return ciget_text_attr((CIcnst_list *)cival(icn));

	if(!strcmp("get_symb", fname))
		return ciget_symb((CIcnst_list *)cival(icn));

	if(!strcmp("set_symb", fname))
		return ciset_symb((CIcnst_list *)cival(icn));

	if(!strcmp("set_gal_symb", fname))
		return ciset_gal_symb((CIcnst_list *)cival(icn));
}

