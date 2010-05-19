DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BPGmain ()
  DEFINE p_cit RECORD  assembly_cat  LIKE "nfmadmin".struct_pl_cit.assembly_cat,
                       assembly_nam  LIKE "nfmadmin".struct_pl_cit.assembly_nam,
                       assembly_rev  LIKE "nfmadmin".struct_pl_cit.assembly_rev,
                       comp_seqno    LIKE "nfmadmin".struct_pl_cit.comp_seqno,
                       item_no       LIKE "nfmadmin".struct_pl_cit.item_no,
                       quantity      LIKE "nfmadmin".struct_pl_cit.quantity
                END RECORD

  DEFINE p_part RECORD f_part_num    LIKE "nfmadmin".struct_pl_dynamic.f_part_num,
                       family_name   LIKE "nfmadmin".struct_pl_dynamic.family_name,
                       volume        LIKE "nfmadmin".struct_pl_dynamic.volume,
                       grade         LIKE "nfmadmin".struct_pl_dynamic.grade,
                       length        LIKE "nfmadmin".struct_pl_dynamic.plate_length,
                       width         LIKE "nfmadmin".struct_pl_dynamic.plate_width,
                       thickness     LIKE "nfmadmin".struct_pl_dynamic.plate_thk,
                       density       LIKE "nfmadmin".struct_grade.density,
		       cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
		       cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
		       rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr
                END RECORD

   DEFINE p_val RECORD name_of_element     CHAR(5),
                       element_mass        FLOAT,
                       total_mass          FLOAT,
                       dimensions          CHAR(80),
                       standard            CHAR(5),
                       notes               CHAR(25)
                END RECORD

   DEFINE g_tot_mass FLOAT

  CALL ERRORLOG("Enter in Beams & Plates Drawing report")
  MESSAGE "Beams & Plates Drawing report in progress... please wait"

  IF drawing_flag = 0 THEN
     CALL ERRORLOG ( "No drawing beams & plates found")
     MESSAGE "No beams or plates checked in for specified drawing"
     SLEEP 3
     
  ELSE
     CALL ERRORLOG ( "Reporting from drawing checkin")
     START REPORT BPGform TO "BPGform"
        OUTPUT TO REPORT BPGform ()
     FINISH REPORT BPGform

     START REPORT BPGheader TO "BPGheader"
       OUTPUT TO REPORT BPGheader ()
     FINISH REPORT BPGheader

     START REPORT BPGreport TO PIPE "BPG.sh"
     DECLARE q_curs0 CURSOR FOR
        SELECT "nfmadmin".struct_pl_cit.assembly_cat, 
               "nfmadmin".struct_pl_cit.assembly_nam,
               "nfmadmin".struct_pl_cit.assembly_rev,
               "nfmadmin".struct_pl_cit.comp_seqno,
               "nfmadmin".struct_pl_cit.item_no,
               "nfmadmin".struct_pl_cit.quantity

        FROM "nfmadmin".struct_pl_cit

        WHERE "nfmadmin".struct_pl_cit.dwg_cat LIKE q_bp.dwg_cat
        AND   "nfmadmin".struct_pl_cit.dwg_nam LIKE q_bp.dwg_nam
        AND   "nfmadmin".struct_pl_cit.dwg_rev LIKE q_bp.dwg_rev
        AND   "nfmadmin".struct_pl_cit.item_no != 666

        ORDER BY "nfmadmin".struct_pl_cit.item_no


     FOREACH q_curs0 INTO p_cit.*
        IF STATUS < 0 THEN
           CALL ERRORLOG("No rows found in group query")
           MESSAGE "No rows found in group query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           DECLARE q_curs1 CURSOR FOR
              SELECT UNIQUE struct_pl_dynamic.f_part_num,
                     "nfmadmin".struct_pl_dynamic.family_name,
                     "nfmadmin".struct_pl_dynamic.volume,
                     "nfmadmin".struct_pl_dynamic.grade,
                     "nfmadmin".struct_pl_dynamic.plate_length,
                     "nfmadmin".struct_pl_dynamic.plate_width,
                     "nfmadmin".struct_pl_dynamic.plate_thk,
                     "nfmadmin".struct_grade.density,
	             "nfmadmin".vds_convert.cnvr_fctr,
                     "nfmadmin".vds_convert.cnvr_offset,
                     "nfmadmin".vds_convert.rndoff_fctr

              FROM "nfmadmin".struct_pl_dynamic,
                   "nfmadmin".struct_grade,
                   OUTER ("nfmadmin".vds_convert),
                   "nfmadmin".vds_units

              WHERE "nfmadmin".struct_pl_dynamic.assembly_cat LIKE p_cit.assembly_cat
              AND   "nfmadmin".struct_pl_dynamic.assembly_nam LIKE p_cit.assembly_nam
              AND   "nfmadmin".struct_pl_dynamic.assembly_ver LIKE p_cit.assembly_rev
              AND   "nfmadmin".struct_pl_dynamic.comp_seqno   =    p_cit.comp_seqno
              AND   ("nfmadmin".vds_units.param_name          = 'density'
              AND   "nfmadmin".vds_units.units_set            = p_vds.prj_units_set)
              AND   ("nfmadmin".struct_grade.material         = "nfmadmin".struct_pl_dynamic.material
              AND   "nfmadmin".struct_grade.grade             = "nfmadmin".struct_pl_dynamic.grade)
              AND   ("nfmadmin".vds_convert.units_in          = "nfmadmin".struct_grade.density_units
              AND   "nfmadmin".vds_convert.units_out          = "nfmadmin".vds_units.units_code)
          

           FOREACH q_curs1 INTO p_part.*
              IF STATUS < 0 THEN
                 CALL ERRORLOG ("No rows found in the query")
                 SLEEP 3
                 EXIT FOREACH
              ELSE
                 # Convert length values 
                 CALL unit_convert ( p_part.cnvr_fctr,
                                     p_part.cnvr_offset,
                                     p_part.rndoff_fctr,
                                     p_part.density) RETURNING p_part.density
                 # Convert length values 
                 CALL length_unit_convert ( p_part.volume,
                                            3,
                                            p_vds.prj_units_set)
                      RETURNING p_part.volume

                  LET p_val.name_of_element="plate"
                  LET p_val.element_mass=p_part.volume * p_part.density
                  LET p_val.total_mass=p_val.element_mass * p_cit.quantity
                  LET g_tot_mass=g_tot_mass+p_val.total_mass
                  LET p_val.dimensions=p_part.thickness USING "<<<<<<<<<<" CLIPPED,
                                  "x",p_part.length USING "<<<<<<<<<<" CLIPPED,
                                       "x",p_part.width USING "<<<<<<<<<<"
                  LET p_val.standard=""
                  LET p_val.notes=""

                 OUTPUT TO REPORT BPGreport ( p_cit.*, p_part.*, p_val.*)
              END IF
           END FOREACH
        END IF
     END FOREACH

     DECLARE q_curs2 CURSOR FOR
        SELECT "nfmadmin".struct_bm_cit.assembly_cat, 
               "nfmadmin".struct_bm_cit.assembly_nam,
               "nfmadmin".struct_bm_cit.assembly_rev,
               "nfmadmin".struct_bm_cit.comp_seqno,
               "nfmadmin".struct_bm_cit.item_no,
               "nfmadmin".struct_bm_cit.quantity

        FROM "nfmadmin".struct_bm_cit

        WHERE "nfmadmin".struct_bm_cit.dwg_cat LIKE q_bp.dwg_cat
        AND   "nfmadmin".struct_bm_cit.dwg_nam LIKE q_bp.dwg_nam
        AND   "nfmadmin".struct_bm_cit.dwg_rev LIKE q_bp.dwg_rev
        AND   "nfmadmin".struct_bm_cit.item_no != 666

        ORDER BY "nfmadmin".struct_bm_cit.item_no


     FOREACH q_curs2 INTO p_cit.*
        IF STATUS < 0 THEN
           CALL ERRORLOG("No rows found in group query")
           MESSAGE "No rows found in group query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           DECLARE q_curs3 CURSOR FOR
              SELECT UNIQUE "nfmadmin".struct_bm_dynamic.f_part_num,
                     "nfmadmin".struct_bm_dynamic.family_name,
                     "nfmadmin".struct_bm_dynamic.volume,
                     "nfmadmin".struct_bm_dynamic.grade,
                     "nfmadmin".struct_bm_dynamic.memb_cut_leng,
                     "nfmadmin".struct_bm_dynamic.surface_area,
                     "nfmadmin".struct_bm_dynamic.fp_thick,
                     "nfmadmin".struct_grade.density,
	             "nfmadmin".vds_convert.cnvr_fctr,
                     "nfmadmin".vds_convert.cnvr_offset,
                     "nfmadmin".vds_convert.rndoff_fctr

              FROM "nfmadmin".struct_bm_dynamic,
                   "nfmadmin".struct_grade,
                   OUTER ("nfmadmin".vds_convert),
                   "nfmadmin".vds_units

              WHERE "nfmadmin".struct_bm_dynamic.assembly_cat LIKE p_cit.assembly_cat
              AND   "nfmadmin".struct_bm_dynamic.assembly_nam LIKE p_cit.assembly_nam
              AND   "nfmadmin".struct_bm_dynamic.assembly_ver LIKE p_cit.assembly_rev
              AND   "nfmadmin".struct_bm_dynamic.comp_seqno   =    p_cit.comp_seqno
              AND   ("nfmadmin".vds_units.param_name          = 'density'
              AND   "nfmadmin".vds_units.units_set            = p_vds.prj_units_set)
              AND   ("nfmadmin".struct_grade.material         = struct_bm_dynamic.material
              AND   "nfmadmin".struct_grade.grade             = struct_bm_dynamic.grade)
              AND   ("nfmadmin".vds_convert.units_in          = struct_grade.density_units
              AND   "nfmadmin".vds_convert.units_out          = vds_units.units_code)
          

           FOREACH q_curs3 INTO p_part.*
              IF STATUS < 0 THEN
                 CALL ERRORLOG ("No rows found in the query")
                 SLEEP 3
                 EXIT FOREACH
              ELSE
                 # Convert length values 
                 CALL unit_convert ( p_part.cnvr_fctr,
                                     p_part.cnvr_offset,
                                     p_part.rndoff_fctr,
                                     p_part.density) RETURNING p_part.density
                 # Convert length values 
                 CALL length_unit_convert ( p_part.length,
                                            1,
                                            p_vds.prj_units_set)
                      RETURNING p_part.length
                 CALL length_unit_convert ( p_part.volume,
                                            3,
                                            p_vds.prj_units_set)
                      RETURNING p_part.volume

                  LET p_val.name_of_element="beam"
                  LET p_val.element_mass=p_part.volume * p_part.density
                  LET p_val.total_mass=p_val.element_mass * p_cit.quantity
                  LET g_tot_mass=g_tot_mass+p_val.total_mass
                  LET p_val.dimensions=p_part.f_part_num CLIPPED,
                                  ".",p_part.length USING "<<<<<<<<<<" CLIPPED
                  LET p_val.standard=""
                  LET p_val.notes=""

                 OUTPUT TO REPORT BPGreport ( p_cit.*, p_part.*, p_val.*)
              END IF
           END FOREACH
        END IF
     END FOREACH

     FINISH REPORT BPGreport

     START REPORT BPGend TO pipe "BPG.sh"
       OUTPUT TO REPORT BPGend (g_tot_mass)
     FINISH REPORT BPGend

  END IF

  MESSAGE "Beams & Plates Drawing report achieved"
  CALL ERRORLOG("Exit from Beams & Plates Drawing report")
END FUNCTION


REPORT BPGform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "============================================"
      PRINT COLUMN 20, "| BEAMS & PLATES DRAWING STRUCTURAL REPORT |"
      PRINT COLUMN 20, "============================================"
      SKIP 4 LINES
      PRINT COLUMN 1 , "PROJECT NO",
            COLUMN 20, "[", COLUMN 22, p_vds.prj_number, COLUMN 39, "]"
      PRINT COLUMN 1 , "PROJECT NAME",
            COLUMN 20, "[", COLUMN 22, p_vds.prj_name, COLUMN 63, "]"
      PRINT COLUMN 1 , "PROJECT LOCATION",
            COLUMN 20, "[", COLUMN 22, p_vds.prj_location, COLUMN 63, "]"
      SKIP 2 LINES
      PRINT COLUMN 1 , "REPORT DATE",
            COLUMN 20, "[", COLUMN 22, TODAY USING "mm-dd-yyyy", COLUMN 34, "]"
      PRINT COLUMN 1 , "REQUEST BY",
            COLUMN 20, "[", COLUMN 22, rpt_req, COLUMN 26, "]"
      PRINT COLUMN 1 , "DESCRIPTION",
            COLUMN 20, "[", COLUMN 22, rpt_dsc1, COLUMN 63, "]"
      PRINT COLUMN 20, "[", COLUMN 22, rpt_dsc2, COLUMN 63, "]"
      SKIP 4 LINES
      PRINT COLUMN 23, "REPORTING CRITERIA"
      PRINT COLUMN 23, "=================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "DRAWING CATALOG",
            COLUMN 21, "[", COLUMN 23, p_bp.dwg_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "DRAWING NAME",
            COLUMN 21, "[", COLUMN 23, p_bp.dwg_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "DRAWING VERSION",
            COLUMN 21, "[", COLUMN 23, p_bp.dwg_rev CLIPPED, COLUMN 36, "]"
END REPORT

REPORT BPGheader ()

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 7

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0
      LET g_wgt = 0.0
      LET g_srf = 0.0

      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------",
            COLUMN 121,"--------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 46 , "L I S T  O F  B E A M S  &  P L A T E S",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------",
            COLUMN 121,"--------"
      PRINT COLUMN 1,  "STANDARD", 
            COLUMN 10,  "ITEM", 
            COLUMN 17, "NAME OF ELEMENT", 
            COLUMN 33, "QUANTITY", 
            COLUMN 42, "FAMILY NAME",
            COLUMN 54, "ELEMENT MASS", 
            COLUMN 68, "TOTAL MASS",
            COLUMN 83, "GRADE",
            COLUMN 99, "DIMENSIONS",
            COLUMN 120, "NOTES"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 54, " (LB)",
               COLUMN 68, " (LB)",
               COLUMN 99, " (IN)"
      ELSE
         PRINT COLUMN 54, " (KG)",
               COLUMN 68, " (KG)",
               COLUMN 99, " (MM)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------",
            COLUMN 121,"--------"
END REPORT


REPORT BPGreport ( r_cit, r_part, r_val )
  DEFINE r_cit RECORD  assembly_cat  LIKE "nfmadmin".struct_pl_cit.assembly_cat,
                       assembly_nam  LIKE "nfmadmin".struct_pl_cit.assembly_nam,
                       assembly_rev  LIKE "nfmadmin".struct_pl_cit.assembly_rev,
                       comp_seqno    LIKE "nfmadmin".struct_pl_cit.comp_seqno,
                       item_no       LIKE "nfmadmin".struct_pl_cit.item_no,
                       quantity      LIKE "nfmadmin".struct_pl_cit.quantity
                END RECORD

  DEFINE r_part RECORD f_part_num    LIKE "nfmadmin".struct_pl_dynamic.f_part_num,
                       family_name   LIKE "nfmadmin".struct_pl_dynamic.family_name,
                       volume        LIKE "nfmadmin".struct_pl_dynamic.volume,
                       grade         LIKE "nfmadmin".struct_pl_dynamic.grade,
                       length        LIKE "nfmadmin".struct_pl_dynamic.plate_length,
                       width         LIKE "nfmadmin".struct_pl_dynamic.plate_width,
                       thickness     LIKE "nfmadmin".struct_pl_dynamic.plate_thk,
                       density       LIKE "nfmadmin".struct_grade.density,
		       cnvr_fctr     LIKE "nfmadmin".vds_convert.cnvr_fctr,
		       cnvr_offset   LIKE "nfmadmin".vds_convert.cnvr_offset,
		       rndoff_fctr   LIKE "nfmadmin".vds_convert.rndoff_fctr
                END RECORD

   DEFINE r_val RECORD name_of_element     CHAR(5),
                       element_mass        FLOAT,
                       total_mass          FLOAT,
                       dimensions          CHAR(80),
                       standard            CHAR(5),
                       notes               CHAR(25)
                END RECORD

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

    ORDER by r_cit.item_no,r_val.total_mass,r_part.grade,r_val.dimensions
    FORMAT

      ON EVERY ROW
            PRINT COLUMN 1,  r_val.standard CLIPPED,
                  COLUMN 9,  r_cit.item_no CLIPPED,
                  COLUMN 21, r_val.name_of_element CLIPPED,
                  COLUMN 34, r_cit.quantity,
                  COLUMN 41, r_part.family_name CLIPPED,
                  COLUMN 53, r_val.element_mass USING "#########.&&",
                  COLUMN 67, r_val.total_mass USING "#########.&&",
                  COLUMN 82, r_part.grade CLIPPED,
                  COLUMN 98, r_val.dimensions CLIPPED,
                  COLUMN 119,r_val.notes CLIPPED

END REPORT

REPORT BPGend (g_tot_mass)

  DEFINE g_tot_mass FLOAT

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "=================================="

      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 47, g_tot_mass USING "GRAND TOTAL WEIGHT: #########.&& LB"
      ELSE
         PRINT COLUMN 47, g_tot_mass USING "GRAND TOTAL WEIGHT: #########.&& KG"
      END IF
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "=================================="
END REPORT

