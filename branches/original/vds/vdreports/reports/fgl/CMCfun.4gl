DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION CMCquery()

   LET w_reg =
""

   LET f_reg =
"\"nfmadmin\".compart_dynamic"

##########################  Create CMC query ###################################
   LET s_stmt =
"\"nfmadmin\".compart_dynamic.name, ",
"\"nfmadmin\".compart_dynamic.descript, ",
"\"nfmadmin\".compart_dynamic.space_class, ",
"\"nfmadmin\".compart_dynamic.floor_area, ",
"\"nfmadmin\".compart_dynamic.volume, ",
"\"nfmadmin\".compart_dynamic.short_desc, ",
"\"nfmadmin\".compart_dynamic.cog_x, ",
"\"nfmadmin\".compart_dynamic.cog_y, ",
"\"nfmadmin\".compart_dynamic.cog_z"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "compart_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".compart_dynamic.space_class"

   CALL RPTquery ( 0, 1)
END FUNCTION

FUNCTION CMCconvert ()

#   LET p_cmb.floor_area = p_cmb.floor_area*.0254*.0254
#   LET p_cmb.volume = p_cmb.volume*.0254*.0254*.0254
#   LET p_cmb.cog_x = p_cmb.cog_x*.0254
#   LET p_cmb.cog_y = p_cmb.cog_y*.0254
#   LET p_cmb.cog_z = p_cmb.cog_z*.0254

   CALL length_unit_convert1 ( p_cmb.floor_area, 2, p_vds.prj_units_set, p_vds.report_units)
        RETURNING p_cmb.floor_area
   CALL length_unit_convert1 ( p_cmb.volume, 3, p_vds.prj_units_set, p_vds.report_units)
        RETURNING p_cmb.volume
   CALL length_unit_convert1 ( p_cmb.cog_x, 1, p_vds.prj_units_set, p_vds.report_units)
        RETURNING p_cmb.cog_x
   CALL length_unit_convert1 ( p_cmb.cog_y, 1, p_vds.prj_units_set, p_vds.report_units)
        RETURNING p_cmb.cog_y
   CALL length_unit_convert1 ( p_cmb.cog_z, 1, p_vds.prj_units_set, p_vds.report_units)
        RETURNING p_cmb.cog_z

   
END FUNCTION
