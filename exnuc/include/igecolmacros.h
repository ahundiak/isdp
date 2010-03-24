#ifndef igecolmacros_include

#define igecolmacros_include
/********************************************************************

  
	This macros is dependent on the following include files:

		"igrtypedef.h"
		"OMminimum.h"
		"igewindef.h"
		"igecoldef.h"
		"wl.h"

       The following standard is upheld for all of these macros.
          SUCCESS - Return code is TRUE  (where TRUE  is 1 (odd ))
          FAILURE - Return code is FALSE (where FALSE is 0 (even))

********************************************************************/


/**  UNCHANGED MACROS  **/

/* this macro is for connecting to APPcolor2 */
#omdef	ige$connect_app_table(	app_id = my_id,
				app_osnum = OM_Gw_current_OS,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEcnctclrtab(
	IGRint		type,
	GRobjid		app_id,
	GRspacenum	app_osnum,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEcnctclrtab(IGECOLAPP,app_id,app_osnum,mod_id,mod_osnum)
	
#endomdef

/* this macro is for connecting to IGEcolsup object for notification */
#omdef	ige$connect_color_notify(	app_id = my_id,
					app_osnum = OM_Gw_current_OS,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEcnctclrtab(
	IGRint		type,
	GRobjid		app_id,
	GRspacenum	app_osnum,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEcnctclrtab(IGECOLNOT,app_id,app_osnum,mod_id,mod_osnum)
	
#endomdef

/* This macro changes the logical color table. */
#omdef	ige$change_color_table(	num_colors,
				colors,
				flags = STRUCTURE_COLORS | IGE_CHANGE_BACKGROUND
					| IGE_CHANGE_HIGHLIGHT,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)
				
/*IGRint IGEchgclrtab(
	IGRshort	num_colors,
	void		*colors,
	IGRint		flags,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEchgclrtab(num_colors,colors,flags,mod_id,mod_osnum)
	
#endomdef

/* This macro changes a portion of the logical color table. */
/* if flags is IGE_CHANGE_BACKGROUND or IGE_CHANGE_HIGHLIGHT it
   will change those values too (bg is 0; hl is 
   num_bg_log_hl_colors-1) if start_color is appropriate to 
   change the values */
#omdef	ige$modify_color_table(	start_color = 0,
				num_colors,
				colors,
				flags = STRUCTURE_COLORS,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)
				
/*IGRint IGEmodclrtab(
	IGRshort	start_color,
	IGRshort	num_colors,
	void		*colors,
	IGRint		flags,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEmodclrtab(start_color,num_colors,colors,flags,mod_id,mod_osnum)
	
#endomdef

/* This macro changes hilite and background.  Hilite and fgcolor are now
   the same.  If hilite and grid are sent in, hilite is used for the value,
   but if only hilite OR fgcolor are sent in that is used to set hilite. */
#omdef	ige$change_reserved_colors(	fgcolor = NULL,
					bgcolor = NULL,
					hilite_color = NULL,
					flags = STRUCTURE_COLORS,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEchgresclr(
	void		*fg_color,
	void		*bg_color,
	void		*hilite_color,
	IGRint		flags,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEchgresclr(fgcolor,bgcolor,hilite_color,flags,mod_id,mod_osnum)
	
#endomdef

/* this is used to change the logical color names */
#omdef	ige$change_color_names(		num_names,
					names,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint IGEchgclrnam(
	IGRshort		num_names,
	struct IGEcol_names	*names,
	IGRint			flags,
	GRobjid			mod_id,
	GRspacenum		mod_osnum)*/

	IGEchgclrnam(num_names,names,0,mod_id,mod_osnum)
	
#endomdef

/* this is used to modify a portion of the logical color names */
#omdef	ige$modify_color_names(		num_names,
					names,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint IGEchgclrnam(
	IGRshort		num_names,
	struct IGEcol_names	*names,
	IGRint			flags,
	GRobjid			mod_id,
	GRspacenum		mod_osnum)*/

	IGEchgclrnam(num_names,names,1,mod_id,mod_osnum)
	
#endomdef

/* this is used to delete the color names */
#omdef	ige$delete_color_names(		num_names,
					name_indexes,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint IGEdelclrnam(
	IGRshort	num_names,
	IGRint		*name_indexes,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEdelclrnam(num_names,name_indexes,mod_id,mod_osnum)
	
#endomdef

/* This macro reads the logical color table. */
#omdef	ige$read_color_table(	num_colors,
				colors,
				flags = STRUCTURE_COLORS,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)
/*IGRint IGEreadclrtab (
   IGRshort *num_colors, 
   void *colors, 
   IGRint flags, 
   GRobjid mod_id, 
   GRspacenum mod_osnum)*/
				
	IGEreadclrtab(num_colors,colors,flags,mod_id,mod_osnum)
	
#endomdef

/* This macro reads the reserved colors.  hilite and fgcolor are
   the same. */
#omdef	ige$read_reserved_colors(	fgcolor = NULL,
					bgcolor = NULL,
					hilite_color = NULL,
					flags = STRUCTURE_COLORS,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEreadresclr(
	void		*fg_color,
	void		*bg_color,
	void		*hilite_color,
	IGRint		flags,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEreadresclr(fgcolor,bgcolor,hilite_color,flags,mod_id,mod_osnum)
	
#endomdef

/* This macro reads the color names */
#omdef	ige$read_color_names(		num_names,
					names,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint IGEreadclrnam(
	   IGRshort		*num_names,
	   struct IGEcol_names	*names,
	   GRobjid		mod_id,
	   GRspacenum		mod_osnum)*/

	IGEreadclrnam(num_names,names,mod_id,mod_osnum)
	
#endomdef

/* this macro will get the name from a logical color */
#omdef	ige$get_name_from_color(	color,
					name,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEgetnmfrclr(
	IGRshort	color,
	IGRchar		*name,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEgetnmfrclr(color,name,mod_id,mod_osnum)
#endomdef

/* this macro will get the logical color from a name */
#omdef	ige$get_color_from_name(	name,
					color,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEgetclrfrnm(
	IGRchar		*name,
	IGRshort	*color,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEgetclrfrnm(name,color,mod_id,mod_osnum)
	
#endomdef

/* CHANGED MACROS */

/* This macro reads the physical color table.  The slots to be read should
   be in the slot field of every phys_slots structure. */
#omdef	ige$read_phys_vlt( context_no,
			   num_slots,
			   vlt_slots)

/*IGRint	IGErdphytab(
	WLuint32		context_no,
	IGRshort		*num_slots,
	struct WLcmap_entry	*phys_slots)*/

	IGErdphytab(context_no,num_slots,vlt_slots)

#endomdef

/* This macro returns the physical color index, given the logical color */
/* index.  This macro will be meaningless for shading.  The logical     */
/* color will be stored as an rgb value, and it will be reproduced from */
/* the dithering of the color cube colors.  In wireframe, however,      */
/* there will be a physical slot associated with every logical color.   */
#omdef	ige$get_abs_color_index(	context_no,
					log_color,
					abs_color)

/*IGRint	IGEgetabsclrindx(
	WLuint32	context_no,
	IGRshort	log_color,
	IGRshort	*abs_color)*/

	IGEgetabsclrindx(context_no,log_color,abs_color)
	
#endomdef

/* this macro will get the uncompensated logical rgb value of a logical color    */ 
/* i.e. not the physical value if closest match.  If that is needed you can      */
/* query the slot mapped to and query the physical table.                        */
/* if log_color is IGE_LOGICAL_BACKGROUND or IGE_LOGICAL_HILITE it will get those*/
/* values too (or bg is 0; hl is num_bg_log_hl_colors-1)                         */
#omdef	ige$get_rgb_value(		log_color,
					rgb_value,
					flags = PACKED_COLORS,
					mod_id = NULL_OBJID,
					mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEgetrgbvalue(
	IGRshort	log_color,
	void		*rgb_value,
	IGRint		flags,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEgetrgbvalue(log_color,rgb_value,flags,mod_id,mod_osnum)
	
#endomdef

/* This macro will get the number of active logical colors (not  */
/* including background and hilight).  The default context will  */
/* query the last context loaded internaly.  This will be fine   */
/* since all contexts will have the same number of logical colors*/
/* the paramater to function will be left for possible future use*/
#omdef	ige$get_num_active_colors(	num_colors )

/*IGRint	IGEgetnumactcol(
	WLuint32	context_no,
	IGRshort	*num_colors)*/

	IGEgetnumactcol(WL_DEFAULT_CONTEXT, num_colors)
	
#endomdef

/* This macro initiates the color table configuration process. */
/* the WL_DEFAULT_CONTEXT configures every context with        */
/* the IGEcolor2 objid (all of them for ems)                   */
#omdef	ige$configure_color_table(  mod_id = NULL_OBJID,
				    mod_osnum = OM_Gw_current_OS,
				    context_no = WL_DEFAULT_CONTEXT )

/*IGRint	IGEconclrtab(
	GRobjid		mod_id,
	GRspacenum	mod_osnum,
	WLuint32	context_no)*/

	IGEconclrtab(mod_id,mod_osnum,context_no)

#endomdef

/**  NEW MACROS  **/

/*set_inq_special_slots will be used to set and inquire the special slots*/
/*with the rgb values.  When you inquire, the start_slot will return the*/
/*first special area slot.  If *num_slots==0, it will return the*/
/*special_size in num_slots and the phys_table will return the entire*/
/*special_area.  If *num_slots>0 it will return *num_slots slots up to the*/
/*end of the special area (*num_slots will be set to the number of colors*/
/*actually returned).  When setting, the first slot set is start_slot and it*/
/*sets *num_slots slots up until end of special area.  *num_slots will*/
/*return the number of slots actualy set.  This macro can't be used to*/
/*change the number of special area slots.*/
#omdef	ige$set_inq_special_slots( inq0_set1 = 0,
                                   context_no,
                                   phys_subtable,
                                   num_slots,
                                   start_slot)

/*IGRint IGEsetinqspecslots(
	IGRint			inq0_set1,
	WLuint32		context_no,
	struct WLcmap_entry	*phys_subtable,
	IGRint			*num_slots,
	IGRint			*start_slot)*/

	IGEsetinqspecslots(inq0_set1,context_no,phys_subtable,
                num_slots,start_slot)				
#endomdef

/* this macro is for setting and inquiring tolerance for matching
   in the cube and the gamma correction values (1.0,1.0,1.0) for 
   no compensate */
#omdef	ige$set_inq_colortable_parameters( inq0_set1 = 0,
                                           tolerance_pct = NULL,
                                           gamma_correction = NULL,
                                           num_ramp_colors = NULL,
                                           user_cube_size = NULL,
					   mod_id = NULL_OBJID,
					   mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEsetinqclrobjparam(
	IGRint		inq0_set1,
	IGRdouble	*tolerance_pct,
	IGRdouble	*gamma_correction,
        IGRint          *num_ramp_colors,
        IGRint          *user_cube_size,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEsetinqclrobjparam(inq0_set1,tolerance_pct,gamma_correction,num_ramp_colors,user_cube_size,mod_id,mod_osnum)
#endomdef

/* This macro inquires the size of cube, window manager, and intergraph
   reserved colors */
#omdef	ige$inq_colortable_size_parms( context_no,
                                       cube_size = NULL,
                                       wmgr_size = NULL,
                                       ingr_menu_size = NULL )

/*IGRint IGEinqclrtblparam(
	WLuint32	context_no,
	IGRint		*cube_size,
	IGRint		*wmgr_size,
	IGRint		*ingr_menu_size)*/

	IGEinqclrtblparam(context_no,cube_size,wmgr_size,
                ingr_menu_size)
#endomdef

/* This macro is used primarily to assign logical colors for reference planes,*/
/* dimension text, etc.  The best way for applications to make such color     */
/* choices now is for the "reference plane creator", for example, to ask for  */
/* the logical index that corresponds most closely to the rgb value for green */
/* using the macro above instead of requesting a specific logical index for   */
/* green at the time the reference plane is created.  This macro will return  */
/* the logical values for bg and hilight if they are closest match            */
#omdef  ige$rgb_to_logical( context_no,
                            color,
                            logical_index,
                            flags = 0 )

/*IGRint IGErgbtological(
	WLuint32	context_no,
	void		*color,
	IGRint		*logical_index,
	IGRint		flags)*/

        IGErgbtological(context_no,color,logical_index,flags)
#endomdef

/* this macros is for connecting to APPuserramp */
#omdef	ige$connect_app_userramp(	app_id = my_id,
				app_osnum = OM_Gw_current_OS,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)

/*IGRint	IGEcnctclrtab(
	IGRint		type,
	GRobjid		app_id,
	GRspacenum	app_osnum,
	GRobjid		mod_id,
	GRspacenum	mod_osnum)*/

	IGEcnctclrtab(IGEAPPUSR,app_id,app_osnum,mod_id,mod_osnum)
	
#endomdef

/* This macro returns the physical slots the cube maps to.  You must */
/* allocate mapping to atleast the size of cube_size^3.  Enter the size */
/* you allocated in num_entries and it will return size of mapping. */
#omdef  ige$get_cube_mapping( context_no,
                            num_entries,
                            mapping )

/*IGRint	IGEgetcubemapping(
	WLuint32		context_no,
	IGRshort		*num_entries,
	IGRshort		*mapping)*/

        IGEgetcubemapping(context_no, num_entries, mapping)
#endomdef

/*This macro returns the physical slot of a FI_COLOR define (like FI_RED,*/
/*FI_BLACK etc;).  The flag will return TRUE if there are 14 intergraph*/
/*reserved colors.  FALSE if there are not 14 intergraph colors.  This*/
/*information could be used to see if FI_BLUE is going to return a blue*/
/*(TRUE) or return what FI_BLUE matches to on a machine with only 5*/
/*intergraph reserved colors.*/
 
#omdef  ige$get_FI_COLOR_phys_slot( context_no,
                            FI_DEFINE,
                            phys_slot_num,
                            fixed_vlt = NULL )

/*IGRint	IGEgetFI_COLORphys(
	WLuint32		context_no,
	IGRshort                FI_DEFINE,
	IGRshort                *phys_slot_num,
        IGRshort                *fixed_vlt)*/

        IGEgetFI_COLORphys(context_no, FI_DEFINE, phys_slot_num, fixed_vlt)
#endomdef


/* DELETED MACROS */

/*
#omdef	ige$get_num_active_shades(	screen_no = IGE_RIGHT_SCREEN,
					num_shades)


	IGEgetnumactcol(screen_no,num_shades,1)
*/

#define	pack_colors(red,green,blue)  \
             ((IGRuint)(((IGRuint) red << 14) & 0xfff00000) | \
	     (((IGRuint) green << 4) & 0xfffffc00) | \
	     ((IGRuint) blue >> 6))

#define unpack_colors(color,red,green,blue)			\
				*red = (IGRushort) ( color >> 14) & \
							0x0000ffc0; \
				*green = (IGRushort)( color >> 4) & \
							0x0000ffc0; \
				*blue = (IGRushort) ( color << 6) & \
							0x0000ffc0

#define round_colors(dac_size,red,green,blue)   \
						\
	if ((IGRushort)((0xffff << (16 - dac_size)) & *red) != \
		(IGRushort) ( 0xffff << (16 - dac_size))) \
	 \
	   *red += (1 << (16 - (dac_size + 1))); \
	 \
		\
	if ((IGRushort)((0xffff << (16 - dac_size)) & *green) != \
		(IGRushort)(0xffff << (16 - dac_size))) \
	 \
	   *green += (1 << (16 - (dac_size + 1))); \
	 \
		\
	if ((IGRushort)((0xffff << (16 - dac_size)) & *blue) != \
		(IGRushort)(0xffff << (16 - dac_size))) \
	 \
	   *blue += (1 << (16 - (dac_size + 1)))

	
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* igecolmac.I */
extern IGRint IGEcnctclrtab __((IGRint type, GRobjid app_id, GRspacenum app_osnum, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEchgclrtab __((IGRshort num_colors, void *colors, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEmodclrtab __((IGRshort start_color, IGRshort num_colors, void *colors, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEchgresclr __((void *fg_color, void *bg_color, void *hilite_color, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEchgclrnam __((IGRshort num_names, struct IGEcol_names *names, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEdelclrnam __((IGRshort num_names, IGRint *name_indexes, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEreadclrtab __((IGRshort *num_colors, void *colors, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEreadresclr __((void *fg_color, void *bg_color, void *hilite_color, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEreadclrnam __((IGRshort *num_names, struct IGEcol_names *names, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGErdphytab __((WLuint32 context_no, IGRshort *num_slots, struct WLcmap_entry *phys_slots));
extern IGRint IGEgetcubemapping __((WLuint32 context_no, IGRshort *num_entries, IGRshort *mapping));
extern IGRint IGEgetnmfrclr __((IGRshort color, IGRchar *name, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetclrfrnm __((IGRchar *name, IGRshort *color, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetabsclrindx __((WLuint32 context_no, IGRshort log_color, IGRshort *abs_color));
extern IGRint IGEgetrgbvalue __((IGRshort log_color, void *rgb_value, IGRint flags, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEgetnumactcol __((WLuint32 context_no, IGRshort *num_colors));
extern IGRint IGEconclrtab __((GRobjid mod_id, GRspacenum mod_osnum, WLuint32 context_no));
extern IGRint IGEsetinqclrobjparam __((IGRint inq0_set1, IGRdouble *tolerance_pct, IGRdouble *gamma_correction, IGRint *num_ramp_colors, IGRint *user_cube_size, GRobjid mod_id, GRspacenum mod_osnum));
extern IGRint IGEsetinqspecslots __((IGRint inq0_set1, WLuint32 context_no, struct WLcmap_entry *phys_subtable, IGRint *num_slots, IGRint *start_slot));
extern IGRint IGEinqclrtblparam __((WLuint32 context_no, IGRint *cube_size, IGRint *wmgr_size, IGRint *ingr_menu_size));
extern IGRint IGErgbtological __((WLuint32 context_no, void *color, IGRint *logical_index, IGRint flags));
extern IGRint IGEget_col_id __((GRobjid modid, GRspacenum modos, GRobjid *clr_id));
extern IGRint IGEgetFI_COLORphys __(( WLuint32 context_no, IGRshort FI_DEFINE, IGRshort *phys_slot_num, IGRshort *fixed_vlt));
#if defined(__cplusplus)
}
#endif


#undef __
#endif
