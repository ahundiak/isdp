DATABASE training12

GLOBALS

  DEFINE	drawing_flag	SMALLINT,
		eq_unit_flag 	SMALLINT,
        	joker		CHAR(2),
		errorlog_msg    CHAR(132),
		nsts_err_msg	CHAR(80),
        	underline	CHAR(80),
		q_stmt		CHAR(10000),	# query string
		s_stmt		CHAR(2000),	# SELECT
		f_stmt		CHAR(2000),	# FROM
		w_stmt		CHAR(5000),	# WHERE
		g_stmt		CHAR(2000),	# GROUP BY
		o_stmt		CHAR(2000),	# ORDER BY
		w_reg		CHAR(5000),	# regular part of WHERE
		f_reg		CHAR(1000),	# regular part of FROM
		default_prj_no  SMALLINT        # default project number

  DEFINE p_vds 		RECORD prj_number    LIKE "nfmadmin".vds_project.prj_number,
			       prj_name      LIKE "nfmadmin".vds_project.prj_name,
                      	       prj_location  LIKE "nfmadmin".vds_project.prj_location,
                      	       prj_units_set LIKE "nfmadmin".vds_project.prj_units_set,
                      	       report_units  LIKE "nfmadmin".vds_project.report_units,
			       prj_no	     LIKE "nfmadmin".vds_project.prj_no
               		END RECORD

  DEFINE rpt_req        CHAR(3),
         rpt_dsc1       CHAR(40),
         rpt_dsc2       CHAR(40),
         def_vcog       FLOAT,
         def_lcog       FLOAT,
         def_tcog       FLOAT

##################### STRUCTURAL BEAMS #########################################
  DEFINE p_bm RECORD assembly_cat LIKE "nfmadmin".struct_bm_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".struct_bm_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".struct_bm_dynamic.assembly_ver,
                     zone_number  LIKE "nfmadmin".struct_bm_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".struct_bm_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".struct_bm_dynamic.constr_stat
              END RECORD

  DEFINE q_bm RECORD assembly_cat LIKE "nfmadmin".struct_bm_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".struct_bm_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".struct_bm_dynamic.assembly_ver,
                     zone_number  LIKE "nfmadmin".struct_bm_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".struct_bm_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".struct_bm_dynamic.constr_stat
              END RECORD

  DEFINE p_bmb RECORD  f_part_num    LIKE "nfmadmin".struct_bm_dynamic.f_part_num,
                       material      LIKE "nfmadmin".struct_bm_dynamic.material,
                       grade         LIKE "nfmadmin".struct_bm_dynamic.grade,
                       grp_num       INTEGER,
                       grp_len       LIKE "nfmadmin".struct_bm_dynamic.memb_cut_leng,
                       grp_srf       LIKE "nfmadmin".struct_bm_dynamic.surface_area,
                       grp_vol       LIKE "nfmadmin".struct_bm_dynamic.volume,
                       short_txt     LIKE "nfmadmin".struct_codelist.short_txt,
                       density       LIKE "nfmadmin".struct_grade.density,
                       cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
                       cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
                       rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr
                END RECORD

  DEFINE p_bmd1  ARRAY[5000] OF RECORD
                       assembly_cat  LIKE "nfmadmin".struct_bm_cit.assembly_cat,
                       assembly_nam  LIKE "nfmadmin".struct_bm_cit.assembly_nam,
                       assembly_rev  LIKE "nfmadmin".struct_bm_cit.assembly_rev,
                       item_no       LIKE "nfmadmin".struct_bm_cit.item_no,
                       comp_seqno    LIKE "nfmadmin".struct_bm_cit.comp_seqno
                END RECORD

  DEFINE p_bmd2 RECORD f_part_num    LIKE "nfmadmin".struct_bm_dynamic.f_part_num,
                       material      LIKE "nfmadmin".struct_bm_dynamic.material,
                       grade         LIKE "nfmadmin".struct_bm_dynamic.grade,
                       grp_num       INTEGER,
                       grp_len       LIKE "nfmadmin".struct_bm_dynamic.memb_cut_leng,
                       grp_srf       LIKE "nfmadmin".struct_bm_dynamic.surface_area,
                       grp_vol       LIKE "nfmadmin".struct_bm_dynamic.volume,
                       short_txt     LIKE "nfmadmin".struct_codelist.short_txt,
                       density       LIKE "nfmadmin".struct_grade.density,
                       cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
                       cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
                       rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr,
                       end0          LIKE "nfmadmin".struct_bm_dynamic.end_treatment0,
                       end1          LIKE "nfmadmin".struct_bm_dynamic.end_treatment1
                END RECORD

  DEFINE p_bmn RECORD material      LIKE "nfmadmin".struct_bm_dynamic.material,
                      grade         LIKE "nfmadmin".struct_bm_dynamic.grade,
                      volume        LIKE "nfmadmin".struct_bm_dynamic.volume,
                      f_part_num    LIKE "nfmadmin".struct_bm_dynamic.f_part_num,
                      constr_stat   LIKE "nfmadmin".struct_bm_dynamic.constr_stat,
                      chg_no        LIKE "nfmadmin".struct_bm_dynamic.chg_no,
                      long_txt      LIKE "nfmadmin".struct_codelist.long_txt,
                      density       LIKE "nfmadmin".struct_grade.density,
                      cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr
                 END RECORD

  DEFINE p_bmw RECORD chg_no        LIKE "nfmadmin".struct_bm_dynamic.chg_no,
                      comp_seqno    LIKE "nfmadmin".struct_bm_dynamic.comp_seqno,
                      weight_grp    LIKE "nfmadmin".struct_bm_dynamic.weight_grp,
                      f_part_num    LIKE "nfmadmin".struct_bm_dynamic.f_part_num,
                      bm_len        LIKE "nfmadmin".struct_bm_dynamic.memb_cut_leng,
                      bm_vol        LIKE "nfmadmin".struct_bm_dynamic.volume,
                      cog_x         LIKE "nfmadmin".struct_bm_dynamic.cog_x,
                      cog_y         LIKE "nfmadmin".struct_bm_dynamic.cog_y,
                      cog_z         LIKE "nfmadmin".struct_bm_dynamic.cog_z,
                      material      LIKE "nfmadmin".struct_bm_dynamic.material,
                      grade         LIKE "nfmadmin".struct_bm_dynamic.grade,
                      long_txt      LIKE "nfmadmin".struct_codelist.long_txt,
                      density       LIKE "nfmadmin".struct_grade.density,
                      cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr
                END RECORD
 
##################### EQUIPMENTS ###############################################
  DEFINE p_eq RECORD assembly_cat LIKE "nfmadmin".equip_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".equip_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".equip_dynamic.assembly_ver,
                     zone_number  LIKE "nfmadmin".equip_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".equip_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".equip_dynamic.constr_stat
              END RECORD

  DEFINE q_eq RECORD assembly_cat LIKE "nfmadmin".equip_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".equip_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".equip_dynamic.assembly_ver,
                     zone_number  LIKE "nfmadmin".equip_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".equip_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".equip_dynamic.constr_stat
              END RECORD

  DEFINE p_eqb  RECORD eqp_type      LIKE "nfmadmin".equip_dynamic.eqp_type,
                       eqp_number    LIKE "nfmadmin".equip_dynamic.eqp_number,
                       eqp_descr     LIKE "nfmadmin".equip_dynamic.eqp_descr,
                       eqp_partno    LIKE "nfmadmin".equip_dynamic.eqp_partno
                 END RECORD

  DEFINE p_eqn RECORD chg_no           LIKE "nfmadmin".equip_dynamic.chg_no,
                      eqp_number       LIKE "nfmadmin".equip_dynamic.eqp_number,
                      eqp_partno       LIKE "nfmadmin".equip_dynamic.eqp_partno,
                      eqp_descr        LIKE "nfmadmin".equip_dynamic.eqp_descr,
                      wet_weight       LIKE "nfmadmin".equip_dynamic.wet_weight,
                      long_txt         LIKE "nfmadmin".piping_codelist.long_txt
                END RECORD

  DEFINE p_eqw RECORD chg_no           LIKE "nfmadmin".equip_dynamic.chg_no,
                      weight_grp       LIKE "nfmadmin".equip_dynamic.weight_grp,
                      comp_seqno       LIKE "nfmadmin".equip_dynamic.comp_seqno,
                      eqp_number       LIKE "nfmadmin".equip_dynamic.eqp_number,
                      eqp_partno       LIKE "nfmadmin".equip_dynamic.eqp_partno,
                      eqp_descr        LIKE "nfmadmin".equip_dynamic.eqp_descr,
                      dry_weight       LIKE "nfmadmin".equip_dynamic.dry_weight,
                      wet_weight       LIKE "nfmadmin".equip_dynamic.wet_weight,
                      cog_x            LIKE "nfmadmin".equip_dynamic.cog_x,
                      cog_y            LIKE "nfmadmin".equip_dynamic.cog_y,
                      cog_z            LIKE "nfmadmin".equip_dynamic.cog_z,
                      long_txt         LIKE "nfmadmin".struct_codelist.long_txt
                END RECORD

##################### HVAC ###############################################
  DEFINE p_hv RECORD assembly_cat LIKE "nfmadmin".hvac_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".hvac_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".hvac_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".hvac_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".hvac_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".hvac_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".hvac_dynamic.constr_stat
              END RECORD

  DEFINE q_hv RECORD assembly_cat LIKE "nfmadmin".hvac_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".hvac_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".hvac_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".hvac_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".hvac_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".hvac_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".hvac_dynamic.constr_stat
              END RECORD

  DEFINE p_hvb RECORD  comp_descr    LIKE      "nfmadmin".hvac_comp_type.comp_descr,
                       comp_rptcat   LIKE      "nfmadmin".hvac_comp_type.comp_rptcat,
                       comp_code     LIKE      "nfmadmin".hvac_dynamic.comp_code,
                       depth_g       LIKE      "nfmadmin".hvac_dynamic.depth_g,
                       depth_r       LIKE      "nfmadmin".hvac_dynamic.depth_r,
                       duct_length   LIKE      "nfmadmin".hvac_dynamic.duct_length,
                       material      LIKE      "nfmadmin".hvac_dynamic.material,
                       duct_thk      LIKE      "nfmadmin".hvac_dynamic.duct_thk,
                       width_g       LIKE      "nfmadmin".hvac_dynamic.width_g,
                       width_r       LIKE      "nfmadmin".hvac_dynamic.width_r,
                       shape_code    LIKE      "nfmadmin".hvac_dynamic.shape_code,
                       system_name   LIKE      "nfmadmin".hvac_dynamic.system_name,
                       category_desc LIKE      "nfmadmin".hvac_codelist.long_txt,
                       shape_desc    LIKE      "nfmadmin".hvac_codelist.long_txt,
                       item_num                INTEGER,
                       cnvr_fctr     LIKE      "nfmadmin".vds_convert.cnvr_fctr,
                       cnvr_offset   LIKE      "nfmadmin".vds_convert.cnvr_offset,
                       rndoff_fctr   LIKE      "nfmadmin".vds_convert.rndoff_fctr
               END RECORD

  DEFINE p_hve  RECORD spec_name     LIKE "nfmadmin".hvac_dynamic.spec_name,
                       system_name   LIKE "nfmadmin".hvac_dynamic.system_name,
                       comp_code     LIKE "nfmadmin".hvac_dynamic.comp_code,
                       width_g       LIKE "nfmadmin".hvac_dynamic.width_g,
                       depth_g       LIKE "nfmadmin".hvac_dynamic.depth_g,
                       width_r       LIKE "nfmadmin".hvac_dynamic.width_r,
                       depth_r       LIKE "nfmadmin".hvac_dynamic.depth_r,
                       shape_code    LIKE "nfmadmin".hvac_dynamic.shape_code,
                       loc_x         LIKE "nfmadmin".hvac_dynamic.loc_x,
                       loc_y         LIKE "nfmadmin".hvac_dynamic.loc_y,
                       loc_z         LIKE "nfmadmin".hvac_dynamic.loc_z,
                       err_cmp_flg   LIKE "nfmadmin".hvac_dynamic.err_cmp_flg,
                       cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
                       cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
                       rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr
                END RECORD

  DEFINE p_hvn RECORD ship_alt         like "nfmadmin".hvac_codelist.long_txt,
                      shape_desc       like "nfmadmin".hvac_codelist.long_txt,
                      short_code       like "nfmadmin".hvac_comps.short_code,
                      material         like "nfmadmin".hvac_dynamic.material,
                      constr_stat      like "nfmadmin".hvac_dynamic.constr_stat,
                      spec_name        like "nfmadmin".hvac_dynamic.spec_name,
                      chg_no           like "nfmadmin".hvac_dynamic.chg_no,
                      comp_code        like "nfmadmin".hvac_dynamic.comp_code,
                      comp_seqno       like "nfmadmin".hvac_dynamic.comp_seqno,
                      depth_g          like "nfmadmin".hvac_dynamic.depth_g,
                      depth_r          like "nfmadmin".hvac_dynamic.depth_r,
                      duct_thk         like "nfmadmin".hvac_dynamic.duct_thk,
                      insul_thk        like "nfmadmin".hvac_dynamic.insul_thk,
                      shape_code       like "nfmadmin".hvac_dynamic.shape_code,
                      surf_area        like "nfmadmin".hvac_dynamic.surf_area,
                      weight_grp       like "nfmadmin".hvac_dynamic.weight_grp,
                      width_g          like "nfmadmin".hvac_dynamic.width_g,
                      width_r          like "nfmadmin".hvac_dynamic.width_r,
                      d_thk            like "nfmadmin".hvac_spec.d_thk,
                      mtl_density      like "nfmadmin".hvac_spec.mtl_density,
                      weight_mult      like "nfmadmin".hvac_spec.weight_mult
               END RECORD

  DEFINE p_hvw RECORD ship_alt         LIKE "nfmadmin".hvac_codelist.long_txt,
                      shape_desc       LIKE "nfmadmin".hvac_codelist.long_txt,
                      short_code       LIKE "nfmadmin".hvac_comps.short_code,
                      chg_no           LIKE "nfmadmin".hvac_dynamic.chg_no,
                      comp_code        LIKE "nfmadmin".hvac_dynamic.comp_code,
                      comp_seqno       LIKE "nfmadmin".hvac_dynamic.comp_seqno,
                      depth_g          LIKE "nfmadmin".hvac_dynamic.depth_g,
                      depth_r          LIKE "nfmadmin".hvac_dynamic.depth_r,
                      duct_thk         LIKE "nfmadmin".hvac_dynamic.duct_thk,
                      insul_thk        LIKE "nfmadmin".hvac_dynamic.insul_thk,
                      loc_x            LIKE "nfmadmin".hvac_dynamic.loc_x,
                      loc_y            LIKE "nfmadmin".hvac_dynamic.loc_y,
                      loc_z            LIKE "nfmadmin".hvac_dynamic.loc_z,
                      shape_code       LIKE "nfmadmin".hvac_dynamic.shape_code,
                      surf_area        LIKE "nfmadmin".hvac_dynamic.surf_area,
                      weight_grp       LIKE "nfmadmin".hvac_dynamic.weight_grp,
                      width_g          LIKE "nfmadmin".hvac_dynamic.width_g,
                      width_r          LIKE "nfmadmin".hvac_dynamic.width_r,
                      d_thk            LIKE "nfmadmin".hvac_spec.d_thk,
                      mtl_density      LIKE "nfmadmin".hvac_spec.mtl_density,
                      weight_mult      LIKE "nfmadmin".hvac_spec.weight_mult,
                      cnvr_fctr        LIKE "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset      LIKE "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr      LIKE "nfmadmin".vds_convert.rndoff_fctr
               END RECORD

##################### PIPING NOZZLE ############################################
  DEFINE p_nz RECORD assembly_cat LIKE "nfmadmin".piping_noz_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".piping_noz_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".piping_noz_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".piping_noz_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".piping_noz_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".piping_noz_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".piping_noz_dynamic.constr_stat
              END RECORD

  DEFINE q_nz RECORD assembly_cat LIKE "nfmadmin".piping_noz_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".piping_noz_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".piping_noz_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".piping_noz_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".piping_noz_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".piping_noz_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".piping_noz_dynamic.constr_stat
              END RECORD

  DEFINE p_nzn  RECORD eqp_number    LIKE "nfmadmin".piping_noz_dynamic.eqp_number,
                       tag_number    LIKE "nfmadmin".piping_noz_dynamic.tag_number,
                       npd_g         LIKE "nfmadmin".piping_noz_dynamic.npd_g,
                       rating_g      LIKE "nfmadmin".piping_noz_dynamic.rating_g,
                       prep_g        LIKE "nfmadmin".piping_noz_dynamic.prep_g,
                       seq_number    LIKE "nfmadmin".piping_noz_dynamic.seq_number,
                       spec_name     LIKE "nfmadmin".piping_noz_dynamic.spec_name,
                       insul_type    LIKE "nfmadmin".piping_noz_dynamic.insul_type,
                       insul_thk     LIKE "nfmadmin".piping_noz_dynamic.insul_thk,
                       tracing_code  LIKE "nfmadmin".piping_noz_dynamic.tracing_code,
                       paint_code    LIKE "nfmadmin".piping_noz_dynamic.paint_code,
                       op_temp       LIKE "nfmadmin".piping_noz_dynamic.op_temp,
                       op_press      LIKE "nfmadmin".piping_noz_dynamic.op_press,
                       dgn_temp      LIKE "nfmadmin".piping_noz_dynamic.dgn_temp,
                       dgn_press     LIKE "nfmadmin".piping_noz_dynamic.dgn_press,
                       spec_grav     LIKE "nfmadmin".piping_noz_dynamic.spec_grav,
                       apprv_stat    LIKE "nfmadmin".piping_noz_dynamic.apprv_stat,
                       constr_stat   LIKE "nfmadmin".piping_noz_dynamic.constr_stat
                END RECORD

##################### STRUCTURAL PLATES ########################################
  DEFINE p_pl RECORD assembly_cat LIKE "nfmadmin".struct_pl_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".struct_pl_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".struct_pl_dynamic.assembly_ver,
                     zone_number  LIKE "nfmadmin".struct_pl_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".struct_pl_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".struct_pl_dynamic.constr_stat
              END RECORD

  DEFINE q_pl RECORD assembly_cat LIKE "nfmadmin".struct_pl_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".struct_pl_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".struct_pl_dynamic.assembly_ver,
                     zone_number  LIKE "nfmadmin".struct_pl_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".struct_pl_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".struct_pl_dynamic.constr_stat
              END RECORD

  DEFINE p_plb RECORD material    LIKE "nfmadmin".struct_pl_dynamic.material,
                      grade       LIKE "nfmadmin".struct_pl_dynamic.grade,
                      pl_vol      LIKE "nfmadmin".struct_pl_dynamic.volume,
                      pl_len      LIKE "nfmadmin".struct_pl_dynamic.plate_length,
                      pl_wid      LIKE "nfmadmin".struct_pl_dynamic.plate_width,
                      pl_thk      LIKE "nfmadmin".struct_pl_dynamic.plate_thk,
                      pl_srf      LIKE "nfmadmin".struct_pl_dynamic.surface_area,
                      sum_item    INTEGER,
                      sum_srf     LIKE "nfmadmin".struct_pl_dynamic.surface_area,
                      sum_vol     LIKE "nfmadmin".struct_pl_dynamic.volume,
                      short_txt   LIKE "nfmadmin".struct_codelist.short_txt,
                      density     LIKE "nfmadmin".struct_grade.density,
                      cnvr_fctr   LIKE "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset LIKE "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr LIKE "nfmadmin".vds_convert.rndoff_fctr
               END RECORD

  DEFINE p_pln RECORD material      LIKE "nfmadmin".struct_pl_dynamic.material,
                      grade         LIKE "nfmadmin".struct_pl_dynamic.grade,
                      pl_vol        LIKE "nfmadmin".struct_pl_dynamic.volume,
                      pl_len        LIKE "nfmadmin".struct_pl_dynamic.plate_length,
                      pl_wid        LIKE "nfmadmin".struct_pl_dynamic.plate_width,
                      pl_thk        LIKE "nfmadmin".struct_pl_dynamic.plate_thk,
                      constr_stat   LIKE "nfmadmin".struct_pl_dynamic.constr_stat,
                      chg_no        LIKE "nfmadmin".struct_pl_dynamic.chg_no,
                      long_txt      LIKE "nfmadmin".struct_codelist.long_txt,
                      density       LIKE "nfmadmin".struct_grade.density,
                      cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr
                 END RECORD

  DEFINE p_plw RECORD chg_no     LIKE "nfmadmin".struct_pl_dynamic.chg_no,
                      comp_seqno LIKE "nfmadmin".struct_pl_dynamic.comp_seqno,
                      weight_grp LIKE "nfmadmin".struct_pl_dynamic.weight_grp,
                      pl_thk     LIKE "nfmadmin".struct_pl_dynamic.plate_thk,
                      pl_srf     LIKE "nfmadmin".struct_pl_dynamic.surface_area,
                      pl_vol     LIKE "nfmadmin".struct_pl_dynamic.volume,
                      cog_x      LIKE "nfmadmin".struct_pl_dynamic.cog_x,
                      cog_y      LIKE "nfmadmin".struct_pl_dynamic.cog_y,
                      cog_z      LIKE "nfmadmin".struct_pl_dynamic.cog_z,
                      material   LIKE "nfmadmin".struct_pl_dynamic.material,
                      grade      LIKE "nfmadmin".struct_pl_dynamic.grade,
                      long_txt   LIKE "nfmadmin".struct_codelist.long_txt,
                      density    LIKE "nfmadmin".struct_grade.density,
                      cnvr_fctr   LIKE "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset LIKE "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr LIKE "nfmadmin".vds_convert.rndoff_fctr
                END RECORD

##################### PIPING ###################################################
  DEFINE p_pp RECORD assembly_cat LIKE "nfmadmin".piping_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".piping_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".piping_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".piping_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".piping_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".piping_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".piping_dynamic.constr_stat
              END RECORD

  DEFINE q_pp RECORD assembly_cat LIKE "nfmadmin".piping_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".piping_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".piping_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".piping_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".piping_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".piping_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".piping_dynamic.constr_stat
              END RECORD

  DEFINE p_ppb RECORD bend_sweep       LIKE "nfmadmin".piping_dynamic.bend_sweep,
                      npd_g            LIKE "nfmadmin".piping_dynamic.npd_g,
                      npd_r            LIKE "nfmadmin".piping_dynamic.npd_r,
                      pipe_length      LIKE "nfmadmin".piping_dynamic.pipe_length,
                      sch_thk_ovr      LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                      seq_number       LIKE "nfmadmin".piping_dynamic.seq_number,
                      commodity        LIKE "nfmadmin".piping_comps.commodity,
                      comp_code        LIKE "nfmadmin".piping_comps.comp_code,
                      geom_std         LIKE "nfmadmin".piping_comps.geom_std,
                      material         LIKE "nfmadmin".piping_comps.material,
                      prep_g           LIKE "nfmadmin".piping_comps.prep_g,
                      prep_r           LIKE "nfmadmin".piping_comps.prep_r,
                      rating_g         LIKE "nfmadmin".piping_comps.rating_g,
                      sch_thk_g        LIKE "nfmadmin".piping_comps.sch_thk_g,
                      sch_thk_r        LIKE "nfmadmin".piping_comps.sch_thk_r,
                      spec_no          LIKE "nfmadmin".piping_comps.spec_no,
                      comp_cat         LIKE "nfmadmin".piping_comp_type.comp_cat,
                      comp_descr       LIKE "nfmadmin".piping_comp_type.comp_descr,
                      end_prep_desc    LIKE "nfmadmin".piping_codelist.long_txt,
                      material_desc    LIKE "nfmadmin".piping_codelist.long_txt,
                      geom_std_desc    LIKE "nfmadmin".piping_codelist.long_txt,
                      category_desc    LIKE "nfmadmin".piping_codelist.long_txt,
                      item_num         INTEGER
               END RECORD

  DEFINE p_ppd1 array[5000] OF RECORD
                      dgn_press       LIKE "nfmadmin".piping_dynamic.dgn_press,
                      dgn_temp        LIKE "nfmadmin".piping_dynamic.dgn_temp,
                      fluid_code      LIKE "nfmadmin".piping_dynamic.fluid_code,
                      insul_type      LIKE "nfmadmin".piping_dynamic.insul_type,
                      insul_thk       LIKE "nfmadmin".piping_dynamic.insul_thk,
                      op_press        LIKE "nfmadmin".piping_dynamic.op_press,
                      op_temp         LIKE "nfmadmin".piping_dynamic.op_temp,
                      paint_code      LIKE "nfmadmin".piping_dynamic.paint_code,
                      spec_grav       LIKE "nfmadmin".piping_dynamic.spec_grav,
                      spec_name       LIKE "nfmadmin".piping_dynamic.spec_name,
                      seq_number      LIKE "nfmadmin".piping_dynamic.seq_number,
                      tracing_code    LIKE "nfmadmin".piping_dynamic.tracing_code
               END RECORD

  DEFINE p_ppd2 RECORD comp_descr      LIKE "nfmadmin".piping_comp_type.comp_descr,
                       comp_code       LIKE "nfmadmin".piping_dynamic.comp_code,
                       comp_note       LIKE "nfmadmin".piping_dynamic.comp_note,
                       dgn_press       LIKE "nfmadmin".piping_dynamic.dgn_press,
                       dgn_temp        LIKE "nfmadmin".piping_dynamic.dgn_temp,
                       fluid_code      LIKE "nfmadmin".piping_dynamic.fluid_code,
                       insul_type      LIKE "nfmadmin".piping_dynamic.insul_type,
                       insul_thk       LIKE "nfmadmin".piping_dynamic.insul_thk,
                       loc_x           LIKE "nfmadmin".piping_dynamic.loc_x,
                       loc_y           LIKE "nfmadmin".piping_dynamic.loc_y,
                       loc_z           LIKE "nfmadmin".piping_dynamic.loc_z,
                       npd_g           LIKE "nfmadmin".piping_dynamic.npd_g,
                       npd_r           LIKE "nfmadmin".piping_dynamic.npd_r,
                       op_press        LIKE "nfmadmin".piping_dynamic.op_press,
                       op_temp         LIKE "nfmadmin".piping_dynamic.op_temp,
                       opt_code        LIKE "nfmadmin".piping_dynamic.opt_code,
                       paint_code      LIKE "nfmadmin".piping_dynamic.paint_code,
                       sch_thk_ovr     LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       spec_grav       LIKE "nfmadmin".piping_dynamic.spec_grav,
                       spec_name       LIKE "nfmadmin".piping_dynamic.spec_name,
                       seq_number      LIKE "nfmadmin".piping_dynamic.seq_number,
                       tag_number      LIKE "nfmadmin".piping_dynamic.tag_number,
                       tracing_code    LIKE "nfmadmin".piping_dynamic.tracing_code
               END RECORD

  DEFINE p_ppe  RECORD spec_name     LIKE "nfmadmin".piping_dynamic.spec_name,
                       seq_number    LIKE "nfmadmin".piping_dynamic.seq_number,
                       comp_code     LIKE "nfmadmin".piping_dynamic.comp_code,
                       npd_g         LIKE "nfmadmin".piping_dynamic.npd_g,
                       npd_r         LIKE "nfmadmin".piping_dynamic.npd_r,
                       opt_code      LIKE "nfmadmin".piping_dynamic.opt_code,
                       loc_x         LIKE "nfmadmin".piping_dynamic.loc_x,
                       loc_y         LIKE "nfmadmin".piping_dynamic.loc_y,
                       loc_z         LIKE "nfmadmin".piping_dynamic.loc_z,
                       err_cmp_flg   LIKE "nfmadmin".piping_dynamic.err_cmp_flg
                END RECORD

  DEFINE p_ppn RECORD ship_alt         LIKE "nfmadmin".piping_codelist.long_txt,
                      prep_desc_g      LIKE "nfmadmin".piping_codelist.long_txt,
                      prep_desc_r      LIKE "nfmadmin".piping_codelist.long_txt,
                      material         LIKE "nfmadmin".piping_comps.material,
                      family_name      LIKE "nfmadmin".piping_comps.family_name,
                      part_no_prfx     LIKE "nfmadmin".piping_comps.part_no_prfx,
                      prep_g           LIKE "nfmadmin".piping_comps.prep_g,
                      prep_r           LIKE "nfmadmin".piping_comps.prep_r,
                      sch_thk_g        LIKE "nfmadmin".piping_comps.sch_thk_g,
                      sch_thk_r        LIKE "nfmadmin".piping_comps.sch_thk_r,
                      short_code       LIKE "nfmadmin".piping_comps.short_code,
                      spec_no          LIKE "nfmadmin".piping_comps.spec_no,
                      comp_cat         LIKE "nfmadmin".piping_comp_type.comp_cat,
                      comp_numcp       LIKE "nfmadmin".piping_comp_type.comp_numcp,
                      constr_stat      LIKE "nfmadmin".piping_dynamic.constr_stat,
                      spec_name        LIKE "nfmadmin".piping_dynamic.spec_name,
                      bend_sweep       LIKE "nfmadmin".piping_dynamic.bend_sweep,
                      chg_no           LIKE "nfmadmin".piping_dynamic.chg_no,
                      comp_seqno       LIKE "nfmadmin".piping_dynamic.comp_seqno,
                      comp_code        LIKE "nfmadmin".piping_dynamic.comp_code,
                      insul_thk        LIKE "nfmadmin".piping_dynamic.insul_thk,
                      npd_g            LIKE "nfmadmin".piping_dynamic.npd_g,
                      npd_r            LIKE "nfmadmin".piping_dynamic.npd_r,
                      pipe_length      LIKE "nfmadmin".piping_dynamic.pipe_length,
                      sch_thk_ovr      LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                      spec_grav        LIKE "nfmadmin".piping_dynamic.spec_grav,
                      weight_grp       LIKE "nfmadmin".piping_dynamic.weight_grp,
                      tag_number       LIKE "nfmadmin".piping_sup_dynamic.tag_number,
                      weight           LIKE "nfmadmin".piping_sup_dynamic.weight
               END RECORD

  DEFINE p_ppv RECORD seq_number    LIKE "nfmadmin".piping_dynamic.seq_number,
                      npd_g         LIKE "nfmadmin".piping_dynamic.npd_g,
                      npd_r         LIKE "nfmadmin".piping_dynamic.npd_r,
                      comp_note     LIKE "nfmadmin".piping_dynamic.comp_note,
                      short_code    LIKE "nfmadmin".piping_comps.short_code,
                      prep_g        LIKE "nfmadmin".piping_comps.prep_g,
                      rating_g      LIKE "nfmadmin".piping_comps.rating_g,
                      commodity     LIKE "nfmadmin".piping_comps.commodity,
                      comp_code     LIKE "nfmadmin".piping_comps.comp_code,
                      comp_descr    LIKE "nfmadmin".piping_comp_type.comp_descr,
                      long_txt      LIKE "nfmadmin".piping_codelist.long_txt
               END RECORD

  DEFINE p_ppw RECORD ship_alt         LIKE "nfmadmin".piping_codelist.long_txt,
                      prep_desc_g      LIKE "nfmadmin".piping_codelist.long_txt,
                      prep_desc_r      LIKE "nfmadmin".piping_codelist.long_txt,
                      family_name      LIKE "nfmadmin".piping_comps.family_name,
                      part_no_prfx     LIKE "nfmadmin".piping_comps.part_no_prfx,
                      prep_g           LIKE "nfmadmin".piping_comps.prep_g,
                      prep_r           LIKE "nfmadmin".piping_comps.prep_r,
                      sch_thk_g        LIKE "nfmadmin".piping_comps.sch_thk_g,
                      sch_thk_r        LIKE "nfmadmin".piping_comps.sch_thk_r,
                      short_code       LIKE "nfmadmin".piping_comps.short_code,
                      spec_no          LIKE "nfmadmin".piping_comps.spec_no,
                      comp_cat         LIKE "nfmadmin".piping_comp_type.comp_cat,
                      comp_numcp       LIKE "nfmadmin".piping_comp_type.comp_numcp,
                      bend_sweep       LIKE "nfmadmin".piping_dynamic.bend_sweep,
                      chg_no           LIKE "nfmadmin".piping_dynamic.chg_no,
                      comp_seqno       LIKE "nfmadmin".piping_dynamic.comp_seqno,
                      comp_code        LIKE "nfmadmin".piping_dynamic.comp_code,
                      insul_thk        LIKE "nfmadmin".piping_dynamic.insul_thk,
                      loc_x            LIKE "nfmadmin".piping_dynamic.loc_x,
                      loc_y            LIKE "nfmadmin".piping_dynamic.loc_y,
                      loc_z            LIKE "nfmadmin".piping_dynamic.loc_z,
                      npd_g            LIKE "nfmadmin".piping_dynamic.npd_g,
                      npd_r            LIKE "nfmadmin".piping_dynamic.npd_r,
                      pipe_length      LIKE "nfmadmin".piping_dynamic.pipe_length,
                      sch_thk_ovr      LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                      spec_grav        LIKE "nfmadmin".piping_dynamic.spec_grav,
                      weight_grp       LIKE "nfmadmin".piping_dynamic.weight_grp,
                      tag_number       LIKE "nfmadmin".piping_sup_dynamic.tag_number,
                      weight           LIKE "nfmadmin".piping_sup_dynamic.weight
                END RECORD

##################### RACEWAY ##################################################
  DEFINE p_rw RECORD assembly_cat LIKE "nfmadmin".rway_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".rway_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".rway_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".rway_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".rway_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".rway_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".rway_dynamic.constr_stat
              END RECORD

  DEFINE q_rw RECORD assembly_cat LIKE "nfmadmin".rway_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".rway_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".rway_dynamic.assembly_ver,
                     system_name  LIKE "nfmadmin".rway_dynamic.system_name,
                     zone_number  LIKE "nfmadmin".rway_dynamic.zone_number,
                     apprv_stat   LIKE "nfmadmin".rway_dynamic.apprv_stat,
                     constr_stat  LIKE "nfmadmin".rway_dynamic.constr_stat
              END RECORD

  DEFINE p_rwb RECORD comp_descr    LIKE      "nfmadmin".rway_comp_type.comp_descr,
                      comp_rptcat   LIKE      "nfmadmin".rway_comp_type.comp_rptcat,
                      comp_code     LIKE      "nfmadmin".rway_dynamic.comp_code,
                      depth_g       LIKE      "nfmadmin".rway_dynamic.depth_g,
                      depth_r       LIKE      "nfmadmin".rway_dynamic.depth_r,
                      material      LIKE      "nfmadmin".rway_dynamic.material,
                      spec_name     LIKE      "nfmadmin".rway_dynamic.spec_name,
                      duct_length   LIKE      "nfmadmin".rway_dynamic.duct_length,
                      width_g       LIKE      "nfmadmin".rway_dynamic.width_g,
                      width_r       LIKE      "nfmadmin".rway_dynamic.width_r,
                      system_name   LIKE      "nfmadmin".rway_dynamic.system_name,
                      item_num                INTEGER,
                      category      LIKE      "nfmadmin".rway_codelist.long_txt,
                      cnvr_fctr     LIKE      "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset   LIKE      "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr   LIKE      "nfmadmin".vds_convert.rndoff_fctr
               END RECORD

  DEFINE p_rwe RECORD spec_name     LIKE      "nfmadmin".rway_dynamic.spec_name,
                      system_name   LIKE      "nfmadmin".rway_dynamic.system_name,
                      comp_code     LIKE      "nfmadmin".rway_dynamic.comp_code,
                      width_g       LIKE      "nfmadmin".rway_dynamic.width_g,
                      depth_g       LIKE      "nfmadmin".rway_dynamic.depth_g,
                      width_r       LIKE      "nfmadmin".rway_dynamic.width_r,
                      depth_r       LIKE      "nfmadmin".rway_dynamic.depth_r,
                      rway_type     LIKE      "nfmadmin".rway_dynamic.rway_type,
                      loc_x         LIKE      "nfmadmin".rway_dynamic.loc_x,
                      loc_y         LIKE      "nfmadmin".rway_dynamic.loc_y,
                      loc_z         LIKE      "nfmadmin".rway_dynamic.loc_z,
                      err_cmp_flg   LIKE      "nfmadmin".rway_dynamic.err_cmp_flg,
                      cnvr_fctr     LIKE      "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset   LIKE      "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr   LIKE      "nfmadmin".vds_convert.rndoff_fctr
               END RECORD

  DEFINE p_rwn RECORD comp_descr       LIKE "nfmadmin".rway_comp_type.comp_descr,
                      unit_wt          LIKE "nfmadmin".rway_comps.unit_wt,
                      d_material       LIKE "nfmadmin".rway_spec.d_material,
                      chg_no           LIKE "nfmadmin".rway_dynamic.chg_no,
                      comp_code        LIKE "nfmadmin".rway_dynamic.comp_code,
                      constr_stat      LIKE "nfmadmin".rway_dynamic.constr_stat,
                      depth_g          LIKE "nfmadmin".rway_dynamic.depth_g,
                      depth_r          LIKE "nfmadmin".rway_dynamic.depth_r,
                      duct_length      LIKE "nfmadmin".rway_dynamic.duct_length,
                      weight_grp       LIKE "nfmadmin".rway_dynamic.weight_grp,
                      width_g          LIKE "nfmadmin".rway_dynamic.width_g,
                      width_r          LIKE "nfmadmin".rway_dynamic.width_r,
                      ship_alt         LIKE "nfmadmin".rway_codelist.long_txt
               END RECORD

  DEFINE p_rww RECORD comp_descr       LIKE "nfmadmin".rway_comp_type.comp_descr,
                      short_code       LIKE "nfmadmin".rway_comps.short_code,
                      unit_wt          LIKE "nfmadmin".rway_comps.unit_wt,
                      addl_weight      LIKE "nfmadmin".rway_dynamic.addl_weight,
                      chg_no           LIKE "nfmadmin".rway_dynamic.chg_no,
                      comp_code        LIKE "nfmadmin".rway_dynamic.comp_code,
                      comp_seqno       LIKE "nfmadmin".rway_dynamic.comp_seqno,
                      depth_g          LIKE "nfmadmin".rway_dynamic.depth_g,
                      depth_r          LIKE "nfmadmin".rway_dynamic.depth_r,
                      loc_x            LIKE "nfmadmin".rway_dynamic.loc_x,
                      loc_y            LIKE "nfmadmin".rway_dynamic.loc_y,
                      loc_z            LIKE "nfmadmin".rway_dynamic.loc_z,
                      duct_length      LIKE "nfmadmin".rway_dynamic.duct_length,
                      weight_grp       LIKE "nfmadmin".rway_dynamic.weight_grp,
                      width_g          LIKE "nfmadmin".rway_dynamic.width_g,
                      width_r          LIKE "nfmadmin".rway_dynamic.width_r,
                      ship_alt         LIKE "nfmadmin".rway_codelist.long_txt,
                      cnvr_fctr        LIKE "nfmadmin".vds_convert.cnvr_fctr,
                      cnvr_offset      LIKE "nfmadmin".vds_convert.cnvr_offset,
                      rndoff_fctr      LIKE "nfmadmin".vds_convert.rndoff_fctr
               END RECORD

##################### COMPARTMENTS ###############################################
  DEFINE p_cm RECORD assembly_cat LIKE "nfmadmin".compart_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".compart_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".compart_dynamic.assembly_ver,
                     zone	  LIKE "nfmadmin".compart_dynamic.zone
              END RECORD

  DEFINE q_cm RECORD assembly_cat LIKE "nfmadmin".compart_dynamic.assembly_cat,
                     assembly_nam LIKE "nfmadmin".compart_dynamic.assembly_nam,
                     assembly_ver LIKE "nfmadmin".compart_dynamic.assembly_ver,
                     zone	  LIKE "nfmadmin".compart_dynamic.zone
              END RECORD

  DEFINE p_cmb  RECORD cmp_name     LIKE "nfmadmin".compart_dynamic.name,
#                       descript     LIKE "nfmadmin".compart_dynamic.descript,
                       descript     CHAR(52),
                       space_class  LIKE "nfmadmin".compart_dynamic.space_class,
                       floor_area   LIKE "nfmadmin".compart_dynamic.floor_area,
                       volume       LIKE "nfmadmin".compart_dynamic.volume,
                       short_desc   LIKE "nfmadmin".compart_dynamic.short_desc,
                       cog_x        LIKE "nfmadmin".compart_dynamic.cog_x,
                       cog_y        LIKE "nfmadmin".compart_dynamic.cog_y,
                       cog_z        LIKE "nfmadmin".compart_dynamic.cog_z
                 END RECORD

  DEFINE p_cmt1 array[5000] OF RECORD partno      LIKE "nfmadmin".compart_dynamic.partno,
                                      partrev     LIKE "nfmadmin".compart_dynamic.partrev,
                                      qnty        INTEGER
                               END RECORD

  DEFINE p_cmt2  RECORD assembly_cat  LIKE "nfmadmin".compart_dynamic.assembly_cat,
                        assembly_nam  LIKE "nfmadmin".compart_dynamic.assembly_nam,
                        assembly_ver  LIKE "nfmadmin".compart_dynamic.assembly_ver,
                        cmp_name      LIKE "nfmadmin".compart_dynamic.name,
                        descript      LIKE "nfmadmin".compart_dynamic.descript,
			partno	      LIKE "nfmadmin".compart_dynamic.partno,
			partrev	      LIKE "nfmadmin".compart_dynamic.partrev
                 END RECORD


##################### BEAMS & PLATES ###########################################
  DEFINE p_bp RECORD dwg_cat LIKE "nfmadmin".struct_bm_cit.dwg_cat,
                     dwg_nam LIKE "nfmadmin".struct_bm_cit.dwg_nam,
                     dwg_rev LIKE "nfmadmin".struct_bm_cit.dwg_rev
              END RECORD

  DEFINE q_bp RECORD dwg_cat LIKE "nfmadmin".struct_bm_cit.dwg_cat,
                     dwg_nam LIKE "nfmadmin".struct_bm_cit.dwg_nam,
                     dwg_rev LIKE "nfmadmin".struct_bm_cit.dwg_rev
              END RECORD

################################################################################
 
  DEFINE	p_pce		INTEGER,
		p_len		FLOAT,
		p_srf		FLOAT,
		p_vol		FLOAT,
		p_wgt		FLOAT,
		p_vmm		FLOAT,
		p_lmm		FLOAT,
		p_tmm		FLOAT

  DEFINE	g_pce  		INTEGER,
         	g_srf 		FLOAT,
		g_vol		FLOAT,
         	g_wgt		FLOAT,
		g_vmm		FLOAT,
		g_lmm		FLOAT,
		g_tmm		FLOAT

  DEFINE p_frm0 RECORD rpt_req         CHAR(3),
                       rpt_dsc1        CHAR(40),
                       rpt_dsc2        CHAR(40),
                       def_lcog        FLOAT,
                       def_tcog        FLOAT,
                       def_vcog        FLOAT
                 END RECORD

  DEFINE p_frm1 RECORD bm_cat LIKE "nfmadmin".struct_bm_dynamic.assembly_cat,
                       bm_nam LIKE "nfmadmin".struct_bm_dynamic.assembly_nam,
                       bm_ver LIKE "nfmadmin".struct_bm_dynamic.assembly_ver,
                       bm_zn  LIKE "nfmadmin".struct_bm_dynamic.zone_number,
                       bm_as  LIKE "nfmadmin".struct_bm_dynamic.apprv_stat,
                       bm_cs  LIKE "nfmadmin".struct_bm_dynamic.constr_stat,
                       pl_cat LIKE "nfmadmin".struct_pl_dynamic.assembly_cat,
                       pl_nam LIKE "nfmadmin".struct_pl_dynamic.assembly_nam,
                       pl_ver LIKE "nfmadmin".struct_pl_dynamic.assembly_ver,
                       pl_zn  LIKE "nfmadmin".struct_pl_dynamic.zone_number,
                       pl_as  LIKE "nfmadmin".struct_pl_dynamic.apprv_stat,
                       pl_cs  LIKE "nfmadmin".struct_pl_dynamic.constr_stat
                 END RECORD

  DEFINE p_frm2 RECORD hv_cat LIKE "nfmadmin".hvac_dynamic.assembly_cat,
                       hv_nam LIKE "nfmadmin".hvac_dynamic.assembly_nam,
                       hv_ver LIKE "nfmadmin".hvac_dynamic.assembly_ver,
                       hv_sn  LIKE "nfmadmin".hvac_dynamic.system_name,
                       hv_zn  LIKE "nfmadmin".hvac_dynamic.zone_number,
                       hv_as  LIKE "nfmadmin".hvac_dynamic.apprv_stat,
                       hv_cs  LIKE "nfmadmin".hvac_dynamic.constr_stat,
                       rw_cat LIKE "nfmadmin".rway_dynamic.assembly_cat,
                       rw_nam LIKE "nfmadmin".rway_dynamic.assembly_nam,
                       rw_ver LIKE "nfmadmin".rway_dynamic.assembly_ver,
                       rw_sn  LIKE "nfmadmin".rway_dynamic.system_name,
                       rw_zn  LIKE "nfmadmin".rway_dynamic.zone_number,
                       rw_as  LIKE "nfmadmin".rway_dynamic.apprv_stat,
                       rw_cs  LIKE "nfmadmin".rway_dynamic.constr_stat
                 END RECORD

  DEFINE p_frm3 RECORD pp_cat LIKE "nfmadmin".piping_dynamic.assembly_cat,
                       pp_nam LIKE "nfmadmin".piping_dynamic.assembly_nam,
                       pp_ver LIKE "nfmadmin".piping_dynamic.assembly_ver,
                       pp_sn  LIKE "nfmadmin".piping_dynamic.system_name,
                       pp_zn  LIKE "nfmadmin".piping_dynamic.zone_number,
                       pp_as  LIKE "nfmadmin".piping_dynamic.apprv_stat,
                       pp_cs  LIKE "nfmadmin".piping_dynamic.constr_stat,
                       eq_cat LIKE "nfmadmin".equip_dynamic.assembly_cat,
                       eq_nam LIKE "nfmadmin".equip_dynamic.assembly_nam,
                       eq_ver LIKE "nfmadmin".equip_dynamic.assembly_ver,
                       eq_zn  LIKE "nfmadmin".equip_dynamic.zone_number,
                       eq_as  LIKE "nfmadmin".equip_dynamic.apprv_stat,
                       eq_cs  LIKE "nfmadmin".equip_dynamic.constr_stat
                 END RECORD

  DEFINE p_over RECORD LIKE "nfmadmin".mftable.*

  DEFINE p_form3 RECORD spec_name LIKE "nfmadmin".piping_spec.spec_name,
                        comp_code LIKE "nfmadmin".piping_comps.comp_code,
                        opt_code  LIKE "nfmadmin".piping_comps.opt_code
                 END RECORD
  DEFINE compstr RECORD spec_name    LIKE "nfmadmin".piping_spec.spec_name,
                        s_spec_no    LIKE "nfmadmin".piping_spec.spec_no,
                        npd_tblno    LIKE "nfmadmin".piping_spec.npd_tblno,
                        c_spec_no    LIKE "nfmadmin".piping_comps.spec_no,
                        family_name  LIKE "nfmadmin".piping_comps.family_name,
                        part_no_prfx LIKE "nfmadmin".piping_comps.part_no_prfx,
                        comp_code    LIKE "nfmadmin".piping_comps.comp_code,
                        opt_code     LIKE "nfmadmin".piping_comps.opt_code,
                        short_code   LIKE "nfmadmin".piping_comps.short_code,
                        size_g_low   LIKE "nfmadmin".piping_comps.size_g_low,
                        size_g_high  LIKE "nfmadmin".piping_comps.size_g_high,
                        size_r_low   LIKE "nfmadmin".piping_comps.size_r_low,
                        size_r_high  LIKE "nfmadmin".piping_comps.size_r_high,
                        sch_thk_g    LIKE "nfmadmin".piping_comps.sch_thk_g,
                        sch_thk_r    LIKE "nfmadmin".piping_comps.sch_thk_r
                 END RECORD
   DEFINE npd_grn LIKE "nfmadmin".piping_npd_allowed.npd
   DEFINE npd_red LIKE "nfmadmin".piping_npd_allowed.npd
   DEFINE size1,size2,size3,size4 char(20)
   DEFINE msg char(300)

END GLOBALS

FUNCTION nsts_error ()
   LET nsts_err_msg = ">>> Database has to be set in imperial units <<<"
END FUNCTION


FUNCTION null_to_joker (str)
  DEFINE        str     CHAR(80)

  LET joker = "%"

  IF (str IS NULL or str = "" or str = " ") THEN RETURN joker
  ELSE						 RETURN str
  END IF

END FUNCTION


FUNCTION RPTform_input ( product, form_type)
  DEFINE product	SMALLINT,
         form_type	SMALLINT

  CLEAR SCREEN

  # Open the right form
  CASE product
     WHEN 0	# BEAM reports
        CASE form_type
           WHEN 0	OPEN FORM first_form FROM "BMB"
           WHEN 3	OPEN FORM first_form FROM "BMN"
           WHEN 5
#              IF p_vds.prj_units_set = 1 THEN
			OPEN FORM first_form FROM "BMWimp"
#              ELSE	OPEN FORM first_form FROM "BMWmet"
#              END IF
	   WHEN 6	OPEN FORM first_form FROM "BMG"
        END CASE
     WHEN 1	# EQUIPMENT reports
        CASE form_type
           WHEN 0	OPEN FORM first_form FROM "EQB"
           WHEN 3	OPEN FORM first_form FROM "EQN"
           WHEN 5
#              IF p_vds.prj_units_set = 1 THEN
			OPEN FORM first_form FROM "EQWimp"
#              ELSE	OPEN FORM first_form FROM "EQWmet"
#              END IF
        END CASE
     WHEN 2	# HVAC reports
        CASE form_type
           WHEN 0       OPEN FORM first_form FROM "HVB"
           WHEN 2       OPEN FORM first_form FROM "HVE"
           WHEN 3       OPEN FORM first_form FROM "HVN"
           WHEN 5
#              IF p_vds.prj_units_set = 1 THEN
                        OPEN FORM first_form FROM "HVWimp"
#              ELSE	OPEN FORM first_form FROM "HVWmet"
#              END IF
        END CASE
     WHEN 3	# NOZZLE reports
        CASE form_type
           WHEN 0       OPEN FORM first_form FROM "NZB"
        END CASE
     WHEN 5	# PLATE reports
        CASE form_type
           WHEN 0	OPEN FORM first_form FROM "PLB"
           WHEN 3	OPEN FORM first_form FROM "PLN"
           WHEN 5
#              IF p_vds.prj_units_set = 1 THEN
			OPEN FORM first_form FROM "PLWimp"
#              ELSE	OPEN FORM first_form FROM "PLWmet"
#              END IF
        END CASE
     WHEN 6	# PIPING reports
        CASE form_type
           WHEN 0       OPEN FORM first_form FROM "PPB"
           WHEN 1       OPEN FORM first_form FROM "PPD"
           WHEN 2       OPEN FORM first_form FROM "PPE"
           WHEN 3       OPEN FORM first_form FROM "PPN"
           WHEN 4       OPEN FORM first_form FROM "PPV"
           WHEN 5
#              IF p_vds.prj_units_set = 1 THEN
			OPEN FORM first_form FROM "PPWimp"
#              ELSE	OPEN FORM first_form FROM "PPWmet"
#              END IF
           WHEN 7       OPEN FORM first_form FROM "PPR"
        END CASE
     WHEN 7	# RACEWAY reports
        CASE form_type
           WHEN 0       OPEN FORM first_form FROM "RWB"
           WHEN 2       OPEN FORM first_form FROM "RWE"
           WHEN 3       OPEN FORM first_form FROM "RWN"
           WHEN 5
#              IF p_vds.prj_units_set = 1 THEN
                        OPEN FORM first_form FROM "RWWimp"
#              ELSE	OPEN FORM first_form FROM "RWWmet"
#              END IF
        END CASE
     WHEN 8     # BEAM & PLATE reports
        CASE form_type
           WHEN 6       OPEN FORM first_form FROM "BPG"
        END CASE
     WHEN 10    # COMPARTMENT reports
	CASE form_type
	   WHEN 0	OPEN FORM first_form FROM "CMB"
	   WHEN 9	OPEN FORM first_form FROM "CMT"
	   WHEN 10	OPEN FORM first_form FROM "CMC"
	END CASE
  END CASE

  # Display the right form
  DISPLAY FORM first_form

  # Get user key_in by form
  IF product = 6 AND form_type = 7 THEN
    # PPR is reporting PIPING data
    GOTO decadix
  ELSE
    INPUT rpt_req  FROM sc_form.rpt_request
    INPUT rpt_dsc1 FROM sc_form.rpt_descript1
    INPUT rpt_dsc2 FROM sc_form.rpt_descript2
  END IF

  CASE product
     WHEN 0
        INPUT BY NAME p_vds.prj_number, p_bm.* 
        CALL null_to_joker (p_bm.assembly_cat) RETURNING q_bm.assembly_cat
        CALL null_to_joker (p_bm.assembly_nam) RETURNING q_bm.assembly_nam
        CALL null_to_joker (p_bm.assembly_ver) RETURNING q_bm.assembly_ver
        CALL null_to_joker (p_bm.zone_number)  RETURNING q_bm.zone_number
        CALL null_to_joker (p_bm.apprv_stat)   RETURNING q_bm.apprv_stat
        CALL null_to_joker (p_bm.constr_stat)  RETURNING q_bm.constr_stat
     WHEN 1
        INPUT BY NAME p_vds.prj_number, p_eq.*
        CALL null_to_joker (p_eq.assembly_cat) RETURNING q_eq.assembly_cat
        CALL null_to_joker (p_eq.assembly_nam) RETURNING q_eq.assembly_nam
        CALL null_to_joker (p_eq.assembly_ver) RETURNING q_eq.assembly_ver
        CALL null_to_joker (p_eq.zone_number)  RETURNING q_eq.zone_number
        CALL null_to_joker (p_eq.apprv_stat)   RETURNING q_eq.apprv_stat
        CALL null_to_joker (p_eq.constr_stat)  RETURNING q_eq.constr_stat
     WHEN 2
        INPUT BY NAME p_vds.prj_number, p_hv.*
        CALL null_to_joker (p_hv.assembly_cat) RETURNING q_hv.assembly_cat
        CALL null_to_joker (p_hv.assembly_nam) RETURNING q_hv.assembly_nam
        CALL null_to_joker (p_hv.assembly_ver) RETURNING q_hv.assembly_ver
        CALL null_to_joker (p_hv.system_name)  RETURNING q_hv.system_name
        CALL null_to_joker (p_hv.zone_number)  RETURNING q_hv.zone_number
        CALL null_to_joker (p_hv.apprv_stat)   RETURNING q_hv.apprv_stat
        CALL null_to_joker (p_hv.constr_stat)  RETURNING q_hv.constr_stat
     WHEN 3
        INPUT BY NAME p_vds.prj_number, p_nz.*
        CALL null_to_joker (p_nz.assembly_cat) RETURNING q_nz.assembly_cat
        CALL null_to_joker (p_nz.assembly_nam) RETURNING q_nz.assembly_nam
        CALL null_to_joker (p_nz.assembly_ver) RETURNING q_nz.assembly_ver
        CALL null_to_joker (p_nz.system_name)  RETURNING q_nz.system_name
        CALL null_to_joker (p_nz.zone_number)  RETURNING q_nz.zone_number
        CALL null_to_joker (p_nz.apprv_stat)   RETURNING q_nz.apprv_stat
        CALL null_to_joker (p_nz.constr_stat)  RETURNING q_nz.constr_stat
     WHEN 5
        INPUT BY NAME p_vds.prj_number, p_pl.*
        CALL null_to_joker (p_pl.assembly_cat) RETURNING q_pl.assembly_cat
        CALL null_to_joker (p_pl.assembly_nam) RETURNING q_pl.assembly_nam
        CALL null_to_joker (p_pl.assembly_ver) RETURNING q_pl.assembly_ver
        CALL null_to_joker (p_pl.zone_number)  RETURNING q_pl.zone_number
        CALL null_to_joker (p_pl.apprv_stat)   RETURNING q_pl.apprv_stat
        CALL null_to_joker (p_pl.constr_stat)  RETURNING q_pl.constr_stat
     WHEN 6
        INPUT BY NAME p_vds.prj_number, p_pp.*
        CALL null_to_joker (p_pp.assembly_cat) RETURNING q_pp.assembly_cat
        CALL null_to_joker (p_pp.assembly_nam) RETURNING q_pp.assembly_nam
        CALL null_to_joker (p_pp.assembly_ver) RETURNING q_pp.assembly_ver
        CALL null_to_joker (p_pp.system_name)  RETURNING q_pp.system_name
        CALL null_to_joker (p_pp.zone_number)  RETURNING q_pp.zone_number
        CALL null_to_joker (p_pp.apprv_stat)   RETURNING q_pp.apprv_stat
        CALL null_to_joker (p_pp.constr_stat)  RETURNING q_pp.constr_stat
     WHEN 7
        INPUT BY NAME p_vds.prj_number, p_rw.*
        CALL null_to_joker (p_rw.assembly_cat) RETURNING q_rw.assembly_cat
        CALL null_to_joker (p_rw.assembly_nam) RETURNING q_rw.assembly_nam
        CALL null_to_joker (p_rw.assembly_ver) RETURNING q_rw.assembly_ver
        CALL null_to_joker (p_rw.system_name)  RETURNING q_rw.system_name
        CALL null_to_joker (p_rw.zone_number)  RETURNING q_rw.zone_number
        CALL null_to_joker (p_rw.apprv_stat)   RETURNING q_rw.apprv_stat
        CALL null_to_joker (p_rw.constr_stat)  RETURNING q_rw.constr_stat
     WHEN 8
        INPUT BY NAME p_vds.prj_number, p_bp.*
        CALL null_to_joker (p_bp.dwg_cat) RETURNING q_bp.dwg_cat
        CALL null_to_joker (p_bp.dwg_nam) RETURNING q_bp.dwg_nam
        CALL null_to_joker (p_bp.dwg_rev) RETURNING q_bp.dwg_rev
     WHEN 10
 	CASE form_type
           WHEN 0
              INPUT BY NAME p_vds.prj_number, p_cm.*
              CALL null_to_joker (p_cm.assembly_cat) RETURNING q_cm.assembly_cat
              CALL null_to_joker (p_cm.assembly_nam) RETURNING q_cm.assembly_nam
              CALL null_to_joker (p_cm.assembly_ver) RETURNING q_cm.assembly_ver
              CALL null_to_joker (p_cm.zone)  RETURNING q_cm.zone
           WHEN 9
              INPUT BY NAME p_vds.prj_number
           WHEN 10
              INPUT BY NAME p_vds.prj_number, p_cm.*
              CALL null_to_joker (p_cm.assembly_cat) RETURNING q_cm.assembly_cat
              CALL null_to_joker (p_cm.assembly_nam) RETURNING q_cm.assembly_nam
              CALL null_to_joker (p_cm.assembly_ver) RETURNING q_cm.assembly_ver
              CALL null_to_joker (p_cm.zone)  RETURNING q_cm.zone
        END CASE
  END CASE

  # Get project title data
  SELECT UNIQUE prj_number,
		prj_name,
		prj_location,
		prj_units_set,
		report_units,
		prj_no
  INTO  p_vds.*
  FROM  "nfmadmin".vds_project
  WHERE prj_number LIKE p_vds.prj_number


  IF form_type = 5 THEN
     INPUT def_lcog FROM sc_form.def_lcog
     INPUT def_tcog FROM sc_form.def_tcog
     INPUT def_vcog FROM sc_form.def_vcog

#     IF p_vds.prj_units_set = 1 THEN          Introduced Report units.
     IF p_vds.report_units = 1 THEN
        LET def_lcog = def_lcog / 12.0
        LET def_tcog = def_tcog / 12.0
        LET def_vcog = def_vcog / 12.0
     ELSE
        LET def_lcog = def_lcog / 1000.0
        LET def_tcog = def_tcog / 1000.0
        LET def_vcog = def_vcog / 1000.0
     END IF
  END IF

  CLEAR SCREEN

LABEL decadix:

  CASE product
     WHEN 2 CALL update_hvac ()
     WHEN 7 CALL update_rway ()
  END CASE

  IF (product = 1 AND form_type = 6)
  OR product = 4
  OR (product = 6 AND form_type = 7)
  OR product = 8 THEN
     LET drawing_flag = 1
  ELSE
     CALL RPTdrawing (product)
     CALL RPTwhere_begin (product)
  END IF

END FUNCTION


FUNCTION RPTdrawing (product)
  DEFINE product	SMALLINT

  # Structural beam
  DEFINE bm_draw RECORD family_name LIKE "nfmadmin".struct_bm_dynamic.family_name,
                        occ_num     INTEGER
                 END RECORD

  # Equipment
  DEFINE eq_draw RECORD eqp_family LIKE "nfmadmin".equip_dynamic.eqp_family,
                        occ_num    INTEGER
                 END RECORD

  # Hvac
  DEFINE hv_draw RECORD spec_name LIKE "nfmadmin".hvac_dynamic.spec_name,
                        occ_num   INTEGER
                 END RECORD

  # Piping nozzle
  DEFINE nz_draw RECORD spec_name LIKE "nfmadmin".piping_noz_dynamic.spec_name,
                        occ_num   INTEGER
                 END RECORD

  # Structural plate
  DEFINE pl_draw RECORD family_name LIKE "nfmadmin".struct_pl_dynamic.family_name,
                        occ_num     INTEGER
                 END RECORD

  # Piping
  DEFINE pp_draw RECORD spec_name LIKE "nfmadmin".piping_dynamic.spec_name,
                        occ_num     INTEGER
                 END RECORD

  # Rway
  DEFINE rw_draw RECORD spec_name LIKE "nfmadmin".rway_dynamic.spec_name,
                        occ_num   INTEGER
                 END RECORD


  # Structural beam
  DECLARE bm_curs CURSOR FOR
     SELECT "nfmadmin".struct_bm_dynamic.family_name,
            COUNT (*)

     FROM "nfmadmin".struct_bm_cit,
          "nfmadmin".struct_bm_dynamic

     WHERE "nfmadmin".struct_bm_cit.dwg_cat      = q_bm.assembly_cat
     AND   "nfmadmin".struct_bm_cit.dwg_nam      = q_bm.assembly_nam
     AND   "nfmadmin".struct_bm_cit.dwg_rev      = q_bm.assembly_ver
     AND   "nfmadmin".struct_bm_cit.assembly_cat = "nfmadmin".struct_bm_dynamic.assembly_cat
     AND   "nfmadmin".struct_bm_cit.assembly_nam = "nfmadmin".struct_bm_dynamic.assembly_nam
     AND   "nfmadmin".struct_bm_cit.assembly_rev = "nfmadmin".struct_bm_dynamic.assembly_ver
     AND   "nfmadmin".struct_bm_cit.comp_seqno   = "nfmadmin".struct_bm_dynamic.comp_seqno

     GROUP BY "nfmadmin".struct_bm_dynamic.family_name

  # Equipment
  DECLARE eq_curs CURSOR FOR
     SELECT "nfmadmin".equip_dynamic.eqp_family,
            COUNT (*)

     FROM "nfmadmin".equip_cit,
          "nfmadmin".equip_dynamic

     WHERE "nfmadmin".equip_cit.dwg_cat      = q_eq.assembly_cat
     AND   "nfmadmin".equip_cit.dwg_nam      = q_eq.assembly_nam
     AND   "nfmadmin".equip_cit.dwg_rev      = q_eq.assembly_ver
     AND   "nfmadmin".equip_cit.assembly_cat = "nfmadmin".equip_dynamic.assembly_cat
     AND   "nfmadmin".equip_cit.assembly_nam = "nfmadmin".equip_dynamic.assembly_nam
     AND   "nfmadmin".equip_cit.assembly_rev = "nfmadmin".equip_dynamic.assembly_ver
     AND   "nfmadmin".equip_cit.comp_seqno   = "nfmadmin".equip_dynamic.comp_seqno

     GROUP BY "nfmadmin".equip_dynamic.eqp_family

  # Hvac
  DECLARE hv_curs CURSOR FOR
     SELECT "nfmadmin".hvac_dynamic.spec_name,
            COUNT (*)

     FROM "nfmadmin".hvac_cit,
          "nfmadmin".hvac_dynamic

     WHERE "nfmadmin".hvac_cit.dwg_cat      = q_hv.assembly_cat
     AND   "nfmadmin".hvac_cit.dwg_nam      = q_hv.assembly_nam
     AND   "nfmadmin".hvac_cit.dwg_rev      = q_hv.assembly_ver
     AND   "nfmadmin".hvac_cit.assembly_cat = "nfmadmin".hvac_dynamic.assembly_cat
     AND   "nfmadmin".hvac_cit.assembly_nam = "nfmadmin".hvac_dynamic.assembly_nam
     AND   "nfmadmin".hvac_cit.assembly_rev = "nfmadmin".hvac_dynamic.assembly_ver
     AND   "nfmadmin".hvac_cit.comp_seqno   = "nfmadmin".hvac_dynamic.comp_seqno

     GROUP BY "nfmadmin".hvac_dynamic.spec_name

  # Piping nozzle
  DECLARE nz_curs CURSOR FOR
     SELECT "nfmadmin".piping_noz_dynamic.spec_name,
            COUNT (*)

     FROM "nfmadmin".piping_noz_cit,
          "nfmadmin".piping_noz_dynamic

     WHERE "nfmadmin".piping_noz_cit.dwg_cat      = q_nz.assembly_cat
     AND   "nfmadmin".piping_noz_cit.dwg_nam      = q_nz.assembly_nam
     AND   "nfmadmin".piping_noz_cit.dwg_rev      = q_nz.assembly_ver
     AND   "nfmadmin".piping_noz_cit.assembly_cat = "nfmadmin".piping_noz_dynamic.assembly_cat
     AND   "nfmadmin".piping_noz_cit.assembly_nam = "nfmadmin".piping_noz_dynamic.assembly_nam
     AND   "nfmadmin".piping_noz_cit.assembly_rev = "nfmadmin".piping_noz_dynamic.assembly_ver
     AND   "nfmadmin".piping_noz_cit.comp_seqno   = "nfmadmin".piping_noz_dynamic.comp_seqno

     GROUP BY "nfmadmin".piping_noz_dynamic.spec_name

  # Structural plate
  DECLARE pl_curs CURSOR FOR
     SELECT "nfmadmin".struct_pl_dynamic.family_name,
            COUNT (*)

     FROM "nfmadmin".struct_pl_cit,
          "nfmadmin".struct_pl_dynamic

     WHERE "nfmadmin".struct_pl_cit.dwg_cat      = q_pl.assembly_cat
     AND   "nfmadmin".struct_pl_cit.dwg_nam      = q_pl.assembly_nam
     AND   "nfmadmin".struct_pl_cit.dwg_rev      = q_pl.assembly_ver
     AND   "nfmadmin".struct_pl_cit.assembly_cat = "nfmadmin".struct_pl_dynamic.assembly_cat
     AND   "nfmadmin".struct_pl_cit.assembly_nam = "nfmadmin".struct_pl_dynamic.assembly_nam
     AND   "nfmadmin".struct_pl_cit.assembly_rev = "nfmadmin".struct_pl_dynamic.assembly_ver
     AND   "nfmadmin".struct_pl_cit.comp_seqno   = "nfmadmin".struct_pl_dynamic.comp_seqno

     GROUP BY "nfmadmin".struct_pl_dynamic.family_name

  # Piping
  DECLARE pp_curs CURSOR FOR
     SELECT "nfmadmin".piping_dynamic.spec_name,
            COUNT (*)

     FROM "nfmadmin".piping_cit,
          "nfmadmin".piping_dynamic

     WHERE "nfmadmin".piping_cit.dwg_cat      = q_pp.assembly_cat
     AND   "nfmadmin".piping_cit.dwg_nam      = q_pp.assembly_nam
     AND   "nfmadmin".piping_cit.dwg_rev      = q_pp.assembly_ver
     AND   "nfmadmin".piping_cit.assembly_cat = "nfmadmin".piping_dynamic.assembly_cat
     AND   "nfmadmin".piping_cit.assembly_nam = "nfmadmin".piping_dynamic.assembly_nam
     AND   "nfmadmin".piping_cit.assembly_rev = "nfmadmin".piping_dynamic.assembly_ver
     AND   "nfmadmin".piping_cit.comp_seqno   = "nfmadmin".piping_dynamic.comp_seqno

     GROUP BY "nfmadmin".piping_dynamic.spec_name

  # Rway
  DECLARE rw_curs CURSOR FOR
     SELECT "nfmadmin".rway_dynamic.spec_name,
            COUNT (*)

     FROM "nfmadmin".rway_cit,
          "nfmadmin".rway_dynamic

     WHERE "nfmadmin".rway_cit.dwg_cat      = q_rw.assembly_cat
     AND   "nfmadmin".rway_cit.dwg_nam      = q_rw.assembly_nam
     AND   "nfmadmin".rway_cit.dwg_rev      = q_rw.assembly_ver
     AND   "nfmadmin".rway_cit.assembly_cat = "nfmadmin".rway_dynamic.assembly_cat
     AND   "nfmadmin".rway_cit.assembly_nam = "nfmadmin".rway_dynamic.assembly_nam
     AND   "nfmadmin".rway_cit.assembly_rev = "nfmadmin".rway_dynamic.assembly_ver
     AND   "nfmadmin".rway_cit.comp_seqno   = "nfmadmin".rway_dynamic.comp_seqno

     GROUP BY "nfmadmin".rway_dynamic.spec_name


  CASE product
     WHEN 0
        # Structural beam
        IF (q_bm.assembly_cat = joker
        OR  q_bm.assembly_nam = joker
        OR  q_bm.assembly_ver = joker) THEN LET drawing_flag = 0
        ELSE
           LET drawing_flag   = 0
           FOREACH bm_curs INTO bm_draw.*
              IF (bm_draw.occ_num != 0) THEN LET drawing_flag = 1
              ELSE                           LET drawing_flag = 0
              END IF
           END FOREACH
        END IF

     WHEN 1
        # Equipment
        IF (q_eq.assembly_cat = joker
        OR  q_eq.assembly_nam = joker
        OR  q_eq.assembly_ver = joker) THEN LET drawing_flag = 0
        ELSE
           LET drawing_flag   = 0
           FOREACH eq_curs INTO eq_draw.*
              IF (eq_draw.occ_num != 0) THEN LET drawing_flag = 1
              ELSE                           LET drawing_flag = 0
              END IF
           END FOREACH
        END IF

     WHEN 2
        # Hvac
#        IF (q_hv.assembly_cat = joker
#        OR  q_hv.assembly_nam = joker
#        OR  q_hv.assembly_ver = joker) THEN LET drawing_flag = 0
#        ELSE
#           LET drawing_flag   = 0
#           FOREACH hv_curs INTO hv_draw.*
#              IF (hv_draw.occ_num != 0) THEN LET drawing_flag = 1
#              ELSE                           LET drawing_flag = 0
#              END IF
#           END FOREACH
#        END IF
LET drawing_flag = 0

     WHEN 3
        # Piping nozzle
#        IF (q_nz.assembly_cat = joker
#        OR  q_nz.assembly_nam = joker
#        OR  q_nz.assembly_ver = joker) THEN LET drawing_flag = 0
#        ELSE
#           LET drawing_flag   = 0
#           FOREACH nz_curs INTO nz_draw.*
#              IF (nz_draw.occ_num != 0) THEN LET drawing_flag = 1
#              ELSE                           LET drawing_flag = 0
#              END IF
#           END FOREACH
#        END IF
LET drawing_flag = 0

     WHEN 5
        # Structural plate
        IF (q_pl.assembly_cat = joker
        OR  q_pl.assembly_nam = joker
        OR  q_pl.assembly_ver = joker) THEN LET drawing_flag = 0
        ELSE
           LET drawing_flag   = 0
           FOREACH pl_curs INTO pl_draw.*
              IF (pl_draw.occ_num != 0) THEN LET drawing_flag = 1
              ELSE                           LET drawing_flag = 0
              END IF
           END FOREACH
        END IF

     WHEN 6
        # Piping
#        IF (q_pp.assembly_cat = joker
#        OR  q_pp.assembly_nam = joker
#        OR  q_pp.assembly_ver = joker) THEN LET drawing_flag = 0
#        ELSE
#           LET drawing_flag   = 0
#           FOREACH pp_curs INTO pp_draw.*
#              IF (pp_draw.occ_num != 0) THEN LET drawing_flag = 1
#              ELSE                           LET drawing_flag = 0
#              END IF
#           END FOREACH
#        END IF
LET drawing_flag = 0

     WHEN 7
        # Rway
#        IF (q_rw.assembly_cat = joker
#        OR  q_rw.assembly_nam = joker
#        OR  q_rw.assembly_ver = joker) THEN LET drawing_flag = 0
#        ELSE
#           LET drawing_flag   = 0
#           FOREACH rw_curs INTO rw_draw.*
#              IF (rw_draw.occ_num != 0) THEN LET drawing_flag = 1
#              ELSE                           LET drawing_flag = 0
#              END IF
#           END FOREACH
#        END IF
LET drawing_flag = 0

  END CASE
END FUNCTION

FUNCTION RPTquery ( g_flag, o_flag)
  DEFINE	g_flag	SMALLINT,
		o_flag	SMALLINT

  LET q_stmt = "SELECT ", s_stmt CLIPPED,
	       " \nFROM ",  f_stmt CLIPPED,
	       " \nWHERE ", w_stmt CLIPPED

  IF g_flag = 1 THEN LET q_stmt = q_stmt CLIPPED, " \nGROUP BY ", g_stmt CLIPPED
  END IF

  IF o_flag = 1 THEN LET q_stmt = q_stmt CLIPPED, " \nORDER BY ", o_stmt CLIPPED
  END IF
END FUNCTION

FUNCTION RPTwhere_begin (product)
  DEFINE product SMALLINT

  IF drawing_flag = 0 THEN
     CASE product
        WHEN 0 LET w_stmt =
    "(\"nfmadmin\".struct_bm_dynamic.assembly_cat LIKE '", q_bm.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".struct_bm_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.assembly_nam LIKE '", q_bm.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".struct_bm_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.assembly_ver LIKE '", q_bm.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".struct_bm_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.zone_number  LIKE '", q_bm.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".struct_bm_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.apprv_stat   LIKE '", q_bm.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".struct_bm_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.constr_stat  LIKE '", q_bm.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".struct_bm_dynamic.constr_stat   IS NULL) "

        WHEN 1 LET w_stmt =
"    (\"nfmadmin\".equip_dynamic.assembly_cat LIKE '", q_eq.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".equip_dynamic.assembly_nam LIKE '", q_eq.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".equip_dynamic.assembly_ver LIKE '", q_eq.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".equip_dynamic.zone_number  LIKE '", q_eq.zone_number CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".equip_dynamic.apprv_stat   LIKE '", q_eq.apprv_stat CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".equip_dynamic.constr_stat  LIKE '", q_eq.constr_stat CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.constr_stat   IS NULL) "

        WHEN 2 LET w_stmt =
    "(\"nfmadmin\".hvac_dynamic.assembly_cat LIKE '", q_hv.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".hvac_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.assembly_nam LIKE '", q_hv.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".hvac_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.assembly_ver LIKE '", q_hv.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".hvac_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.system_name  LIKE '", q_hv.system_name CLIPPED,  "'",
" OR \"nfmadmin\".hvac_dynamic.system_name   IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.zone_number  LIKE '", q_hv.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".hvac_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.apprv_stat   LIKE '", q_hv.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".hvac_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.constr_stat  LIKE '", q_hv.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".hvac_dynamic.constr_stat   IS NULL) "

        WHEN 3 LET w_stmt =
    "(\"nfmadmin\".piping_noz_dynamic.assembly_cat LIKE '", q_nz.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".piping_noz_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.assembly_nam LIKE '", q_nz.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".piping_noz_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.assembly_ver LIKE '", q_nz.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".piping_noz_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.system_name  LIKE '", q_nz.system_name CLIPPED,  "'",
" OR \"nfmadmin\".piping_noz_dynamic.system_name   IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.zone_number  LIKE '", q_nz.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".piping_noz_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.apprv_stat   LIKE '", q_nz.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".piping_noz_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.constr_stat  LIKE '", q_nz.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".piping_noz_dynamic.constr_stat   IS NULL) "

        WHEN 5 LET w_stmt =
    "(\"nfmadmin\".struct_pl_dynamic.assembly_cat LIKE '", q_pl.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".struct_pl_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".struct_pl_dynamic.assembly_nam LIKE '", q_pl.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".struct_pl_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".struct_pl_dynamic.assembly_ver LIKE '", q_pl.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".struct_pl_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".struct_pl_dynamic.zone_number  LIKE '", q_pl.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".struct_pl_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".struct_pl_dynamic.apprv_stat   LIKE '", q_pl.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".struct_pl_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".struct_pl_dynamic.constr_stat  LIKE '", q_pl.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".struct_pl_dynamic.constr_stat   IS NULL) "

        WHEN 6 LET w_stmt =
    "(\"nfmadmin\".piping_dynamic.assembly_cat LIKE '", q_pp.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.assembly_nam LIKE '", q_pp.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.assembly_ver LIKE '", q_pp.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.system_name  LIKE '", q_pp.system_name CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.system_name   IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.zone_number  LIKE '", q_pp.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.apprv_stat   LIKE '", q_pp.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".piping_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.constr_stat  LIKE '", q_pp.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.constr_stat   IS NULL) "

        WHEN 7 LET w_stmt =
    "(\"nfmadmin\".rway_dynamic.assembly_cat LIKE '", q_rw.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".rway_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.assembly_nam LIKE '", q_rw.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".rway_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.assembly_ver LIKE '", q_rw.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".rway_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.system_name  LIKE '", q_rw.system_name CLIPPED,  "'",
" OR \"nfmadmin\".rway_dynamic.system_name   IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.zone_number  LIKE '", q_rw.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".rway_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.apprv_stat   LIKE '", q_rw.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".rway_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.constr_stat  LIKE '", q_rw.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".rway_dynamic.constr_stat   IS NULL) "
        WHEN 10 LET w_stmt =
    "(\"nfmadmin\".compart_dynamic.assembly_cat LIKE '", q_cm.assembly_cat CLIPPED, "'",
" OR \"nfmadmin\".compart_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".compart_dynamic.assembly_nam LIKE '", q_cm.assembly_nam CLIPPED, "'",
" OR \"nfmadmin\".compart_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".compart_dynamic.assembly_ver LIKE '", q_cm.assembly_ver CLIPPED, "'",
" OR \"nfmadmin\".compart_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".compart_dynamic.zone  LIKE '", q_cm.zone CLIPPED,  "'",
" OR \"nfmadmin\".compart_dynamic.zone  IS NULL) "

     END CASE
  ELSE
     CASE product
        WHEN 0 LET w_stmt =
    "\"nfmadmin\".struct_bm_cit.dwg_cat          LIKE '", q_bm.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".struct_bm_cit.dwg_nam          LIKE '", q_bm.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".struct_bm_cit.dwg_rev          LIKE '", q_bm.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".struct_bm_cit.assembly_cat     = \"nfmadmin\".struct_bm_dynamic.assembly_cat ",
"AND \"nfmadmin\".struct_bm_cit.assembly_nam     = \"nfmadmin\".struct_bm_dynamic.assembly_nam ",
"AND \"nfmadmin\".struct_bm_cit.assembly_rev     = \"nfmadmin\".struct_bm_dynamic.assembly_ver ",
"AND \"nfmadmin\".struct_bm_cit.comp_seqno       = \"nfmadmin\".struct_bm_dynamic.comp_seqno ",
"AND (\"nfmadmin\".struct_bm_dynamic.zone_number LIKE '", q_bm.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".struct_bm_dynamic.zone_number  IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.apprv_stat  LIKE '", q_bm.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".struct_bm_dynamic.apprv_stat   IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.constr_stat LIKE '", q_bm.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".struct_bm_dynamic.constr_stat  IS NULL) "

        WHEN 1 LET w_stmt =
"    \"nfmadmin\".equip_cit.dwg_cat          LIKE '", q_eq.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".equip_cit.dwg_nam          LIKE '", q_eq.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".equip_cit.dwg_rev          LIKE '", q_eq.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".equip_cit.assembly_cat     = \"nfmadmin\".equip_dynamic.assembly_cat ",
"AND \"nfmadmin\".equip_cit.assembly_nam     = \"nfmadmin\".equip_dynamic.assembly_nam ",
"AND \"nfmadmin\".equip_cit.assembly_rev     = \"nfmadmin\".equip_dynamic.assembly_ver ",
"AND \"nfmadmin\".equip_cit.comp_seqno       = \"nfmadmin\".equip_dynamic.comp_seqno ",
"AND (\"nfmadmin\".equip_dynamic.zone_number LIKE '", q_eq.zone_number CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.zone_number  IS NULL) ",
"AND (\"nfmadmin\".equip_dynamic.apprv_stat  LIKE '", q_eq.apprv_stat CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.apprv_stat   IS NULL) ",
"AND (\"nfmadmin\".equip_dynamic.constr_stat LIKE '", q_eq.constr_stat CLIPPED, "'",
" OR \"nfmadmin\".equip_dynamic.constr_stat  IS NULL) "

        WHEN 2 LET w_stmt =
    "\"nfmadmin\".hvac_cit.dwg_cat          LIKE '", q_hv.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".hvac_cit.dwg_nam          LIKE '", q_hv.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".hvac_cit.dwg_rev          LIKE '", q_hv.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".hvac_cit.assembly_cat     = \"nfmadmin\".hvac_dynamic.assembly_cat ",
"AND \"nfmadmin\".hvac_cit.assembly_nam     = \"nfmadmin\".hvac_dynamic.assembly_nam ",
"AND \"nfmadmin\".hvac_cit.assembly_rev     = \"nfmadmin\".hvac_dynamic.assembly_ver ",
"AND \"nfmadmin\".hvac_cit.comp_seqno       = \"nfmadmin\".hvac_dynamic.comp_seqno ",
"AND (\"nfmadmin\".hvac_dynamic.system_name LIKE '", q_hv.system_name CLIPPED, "'",
" OR \"nfmadmin\".hvac_dynamic.system_name  IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.zone_number LIKE '", q_hv.zone_number CLIPPED, "'",
" OR \"nfmadmin\".hvac_dynamic.zone_number  IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.apprv_stat  LIKE '", q_hv.apprv_stat CLIPPED,  "'",
" OR \"nfmadmin\".hvac_dynamic.apprv_stat   IS NULL) ",
"AND (\"nfmadmin\".hvac_dynamic.constr_stat LIKE '", q_hv.constr_stat CLIPPED, "'",
" OR \"nfmadmin\".hvac_dynamic.constr_stat  IS NULL) "

        WHEN 3 LET w_stmt =
    "\"nfmadmin\".piping_noz_cit.dwg_cat          LIKE '", q_nz.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".piping_noz_cit.dwg_nam          LIKE '", q_nz.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".piping_noz_cit.dwg_rev          LIKE '", q_nz.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".piping_noz_cit.assembly_cat     = \"nfmadmin\".piping_noz_dynamic.assembly_cat ",
"AND \"nfmadmin\".piping_noz_cit.assembly_nam     = \"nfmadmin\".piping_noz_dynamic.assembly_nam ",
"AND \"nfmadmin\".piping_noz_cit.assembly_rev     = \"nfmadmin\".piping_noz_dynamic.assembly_ver ",
"AND \"nfmadmin\".piping_noz_cit.comp_seqno       = \"nfmadmin\".piping_noz_dynamic.comp_seqno ",
"AND (\"nfmadmin\".piping_noz_dynamic.system_name LIKE '", q_nz.system_name CLIPPED, "'",
" OR \"nfmadmin\".piping_noz_dynamic.system_name  IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.zone_number LIKE '", q_nz.zone_number CLIPPED, "'",
" OR \"nfmadmin\".piping_noz_dynamic.zone_number  IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.apprv_stat  LIKE '", q_nz.apprv_stat CLIPPED,  "'",
" OR \"nfmadmin\".piping_noz_dynamic.apprv_stat   IS NULL) ",
"AND (\"nfmadmin\".piping_noz_dynamic.constr_stat LIKE '", q_nz.constr_stat CLIPPED, "'",
" OR \"nfmadmin\".piping_noz_dynamic.constr_stat  IS NULL) "

        WHEN 5 LET w_stmt =
    "\"nfmadmin\".struct_pl_cit.dwg_cat          LIKE '", q_pl.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".struct_pl_cit.dwg_nam          LIKE '", q_pl.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".struct_pl_cit.dwg_rev          LIKE '", q_pl.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".struct_pl_cit.assembly_cat     = \"nfmadmin\".struct_pl_dynamic.assembly_cat ",
"AND \"nfmadmin\".struct_pl_cit.assembly_nam     = \"nfmadmin\".struct_pl_dynamic.assembly_nam ",
"AND \"nfmadmin\".struct_pl_cit.assembly_rev     = \"nfmadmin\".struct_pl_dynamic.assembly_ver ",
"AND \"nfmadmin\".struct_pl_cit.comp_seqno       = \"nfmadmin\".struct_pl_dynamic.comp_seqno ",
"AND (\"nfmadmin\".struct_pl_dynamic.zone_number LIKE '", q_pl.zone_number CLIPPED, "'",
" OR \"nfmadmin\".struct_pl_dynamic.zone_number  IS NULL) ",
"AND (\"nfmadmin\".struct_pl_dynamic.apprv_stat  LIKE '", q_pl.apprv_stat CLIPPED,  "'",
" OR \"nfmadmin\".struct_pl_dynamic.apprv_stat   IS NULL) ",
"AND (\"nfmadmin\".struct_pl_dynamic.constr_stat LIKE '", q_pl.constr_stat CLIPPED, "'",
" OR \"nfmadmin\".struct_pl_dynamic.constr_stat  IS NULL) "

        WHEN 6 LET w_stmt =
    "\"nfmadmin\".piping_cit.dwg_cat          LIKE '", q_pp.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".piping_cit.dwg_nam          LIKE '", q_pp.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".piping_cit.dwg_rev          LIKE '", q_pp.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".piping_cit.assembly_cat     = \"nfmadmin\".piping_dynamic.assembly_cat ",
"AND \"nfmadmin\".piping_cit.assembly_nam     = \"nfmadmin\".piping_dynamic.assembly_nam ",
"AND \"nfmadmin\".piping_cit.assembly_rev     = \"nfmadmin\".piping_dynamic.assembly_ver ",
"AND \"nfmadmin\".piping_cit.comp_seqno       = \"nfmadmin\".piping_dynamic.comp_seqno ",
"AND (\"nfmadmin\".piping_dynamic.system_name LIKE '", q_pp.system_name CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.system_name  IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.zone_number LIKE '", q_pp.zone_number CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.zone_number  IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.apprv_stat  LIKE '", q_pp.apprv_stat CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.apprv_stat   IS NULL) ",
"AND (\"nfmadmin\".piping_dynamic.constr_stat LIKE '", q_pp.constr_stat CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.constr_stat  IS NULL) "

        WHEN 7 LET w_stmt =
    "\"nfmadmin\".rway_cit.dwg_cat          LIKE '", q_rw.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".rway_cit.dwg_nam          LIKE '", q_rw.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".rway_cit.dwg_rev          LIKE '", q_rw.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".rway_cit.assembly_cat     = \"nfmadmin\".rway_dynamic.assembly_cat ",
"AND \"nfmadmin\".rway_cit.assembly_nam     = \"nfmadmin\".rway_dynamic.assembly_nam ",
"AND \"nfmadmin\".rway_cit.assembly_rev     = \"nfmadmin\".rway_dynamic.assembly_ver ",
"AND \"nfmadmin\".rway_cit.comp_seqno       = \"nfmadmin\".rway_dynamic.comp_seqno ",
"AND (\"nfmadmin\".rway_dynamic.system_name LIKE '", q_rw.system_name CLIPPED, "'",
" OR \"nfmadmin\".rway_dynamic.system_name  IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.zone_number LIKE '", q_rw.zone_number CLIPPED, "'",
" OR \"nfmadmin\".rway_dynamic.zone_number  IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.apprv_stat  LIKE '", q_rw.apprv_stat CLIPPED,  "'",
" OR \"nfmadmin\".rway_dynamic.apprv_stat   IS NULL) ",
"AND (\"nfmadmin\".rway_dynamic.constr_stat LIKE '", q_rw.constr_stat CLIPPED, "'",
" OR \"nfmadmin\".rway_dynamic.constr_stat  IS NULL) "

        WHEN 10 LET w_stmt =
    "\"nfmadmin\".compart_cit.dwg_cat          LIKE '", q_cm.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".compart_cit.dwg_nam          LIKE '", q_cm.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".compart_cit.dwg_rev          LIKE '", q_cm.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".compart_cit.assembly_cat     = \"nfmadmin\".compart_dynamic.assembly_cat ",
"AND \"nfmadmin\".compart_cit.assembly_nam     = \"nfmadmin\".compart_dynamic.assembly_nam ",
"AND \"nfmadmin\".compart_cit.assembly_rev     = \"nfmadmin\".compart_dynamic.assembly_ver ",
"AND \"nfmadmin\".compart_cit.comp_seqno       = \"nfmadmin\".compart_dynamic.comp_seqno ",
"AND (\"nfmadmin\".compart_dynamic.zone LIKE '", q_cm.zone CLIPPED,  "'",
" OR \"nfmadmin\".compart_dynamic.zone IS NULL) "

     END CASE
  END IF
END FUNCTION
