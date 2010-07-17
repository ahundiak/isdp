#ifndef vsAPIwelddef_include
#	define vsAPIwelddef_include

/* WELD CODE */
#define	VS_WC_Fillet			 0	/* fillet weld		       */
#define	VS_WC_Plug_or_Slot		 1	/* plug or slot weld	       */
#define	VS_WC_Plug_or_Projection	 2	/* spot or projection weld     */
#define	VS_WC_Seam			 3	/* seam weld		       */
#define	VS_WC_Groove_square		 4	/* groove weld ( square )      */
#define	VS_WC_Groove_V			 5	/* groove weld ( V )	       */
#define	VS_WC_Groove_bevel		 6	/* groove weld ( bevel )       */
#define	VS_WC_Groove_U			 7	/* groove weld ( U )	       */
#define	VS_WC_Groove_J			 8	/* groove weld ( J )	       */
#define	VS_WC_Groove_flare_V		 9	/* groove weld ( flare-V )     */
#define	VS_WC_Groove_flare_bevel	10	/* groove weld ( flare-bevel ) */
#define	VS_WC_Backing			11	/* backing weld		       */
#define	VS_WC_Surfacing			12	/* surfacing weld	       */
#define	VS_WC_Flange_edge		13	/* flange weld ( edge )	       */
#define	VS_WC_Flange_corner		14	/* flange weld ( corner )      */

/* WELD PROCESS */
#define	VS_WP_Undefined			 0	/* Undefined process	      */
#define	VS_WP_Carbon_Arc_Weld		 1	/* Carbon-Arc Welding	      */
#define	VS_WP_Cold_Weld			 2	/* Cold Welding		      */
#define	VS_WP_Dip_Braze			 3	/* Dip Brazing		      */
#define	VS_WP_Diffusion_Weld		 4	/* Diffusion Welding	      */
#define	VS_WP_Electron_Beam_Weld	 5	/* Electron Beam Welding      */
#define	VS_WP_Electroslag_Weld		 6	/* Electroslag Welding	      */
#define	VS_WP_Explosion_Weld		 7	/* Explosion Welding	      */
#define	VS_WP_Furnace_Braze		 8	/* Furnace Brazing	      */
#define	VS_WP_Flux_Cored_Arc_Weld	 9	/* Flux Cored Arc Welding     */
#define	VS_WP_Forge_Weld		10	/* Forge Welding	      */
#define	VS_WP_Friction_Weld		11	/* Friction Welding	      */
#define	VS_WP_Flash_Weld		12	/* Flash Welding	      */
#define	VS_WP_Gas_Metal_Arc_Weld	13	/* Gas Metal-Arc Welding      */
#define	VS_WP_Gas_Tungsten_Arc_Weld	14	/* Gas Tungsten-Arc Welding   */
#define	VS_WP_Induction_Braze		15	/* Induction Brazing	      */
#define	VS_WP_Infrared_Braze		16	/* Infrared Brazing	      */
#define	VS_WP_Induction_Weld		17	/* Induction Welding	      */
#define	VS_WP_Laser_Beam_Weld		18	/* Laser Beam Welding	      */
#define	VS_WP_Oxyacetylene_Weld		19	/* Oxyacetylene Welding	      */
#define	VS_WP_Oxyhydrogen_Weld		20	/* Oxyhydrogen Welding	      */
#define	VS_WP_Plasma_Arc_Weld		21	/* Plasma-Arc Welding	      */
#define	VS_WP_Percussion_Weld		22	/* Percussion Welding	      */
#define	VS_WP_Pressure_Gas_Weld		23	/* Pressure Gas Welding	      */
#define	VS_WP_Resistance_Braze		24	/* Resistance Brazing	      */
#define	VS_WP_Projection_Weld		25	/* Projection Welding	      */
#define	VS_WP_Resistance_Seam_Weld	26	/* Resistance-Seam Welding    */
#define	VS_WP_Resistance_Spot_Weld	27	/* Resistance-Spot Welding    */
#define	VS_WP_Submerged_Arc_Weld	28	/* Submerged-Arc Welding      */
#define	VS_WP_Shielded_Metal_Arc_Weld	29	/* Shielded Metal-Arc Welding */
#define	VS_WP_Stud_Weld			30	/* Stud Welding		      */
#define	VS_WP_Torch_Braze		31	/* Torch Brazing	      */
#define	VS_WP_Thermal_Weld		32	/* Thermal Welding	      */
#define	VS_WP_Ultrasonic_Weld		33	/* Ultrasonic Welding	      */
#define	VS_WP_Upset_Weld		34	/* Upset Welding	      */

/* WELD INFO */
				/*	Field	Melt-	Weld all
					 weld	 thru	  around	*/
#define	VS_WI_No_No_No	 0	/*	  NO	  NO	  NO		*/
#define	VS_WI_Fw_No_No	 1	/*	  YES	  NO	  NO		*/
#define	VS_WI_No_Mt_No	 2	/*	  NO	  YES	  NO		*/
#define	VS_WI_Fw_Mt_No	 3	/*	  YES	  YES	  NO		*/
#define	VS_WI_No_No_Wa	 4	/*	  NO	  NO	  YES		*/
#define	VS_WI_Fw_No_Wa	 5	/*	  YES	  NO	  YES		*/
#define	VS_WI_No_Mt_Wa	 6	/*	  NO	  YES	  YES		*/
#define	VS_WI_Fw_Mt_Wa	 7	/*	  YES	  NO	  NO		*/

/* WELD CONTOUR */
#define	VS_WK_Flush	 0	/*	Flush 		*/
#define	VS_WK_Concave	 1	/*	Concave 	*/
#define	VS_WK_Convex	 2	/*	Convex 		*/

/* WELD SIDE */
#define	VS_WS_Arrow	 0	/*	Arrow side	*/
#define	VS_WS_Other	 1	/*	Other side	*/
#define	VS_WS_Both	 2	/*	Both side	*/

#endif
