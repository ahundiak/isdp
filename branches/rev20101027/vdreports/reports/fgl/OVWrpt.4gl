DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

REPORT BMWreport ()
  DEFINE BMWlin_wgt     FLOAT,
         BMWcut_len     FLOAT

  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

  FORMAT
    ON EVERY ROW
      CALL BMWdescription ()
           RETURNING BMWlin_wgt, BMWcut_len, p_over.total_wgt,
                     p_over.vcg, p_over.lcg, p_over.tcg,
                     p_over.vmom, p_over.lmom, p_over.tmom

      LET p_over.prj_no     = p_vds.prj_number CLIPPED
      LET p_over.comp_seqno  = p_bmw.comp_seqno USING "<<<<&"
      LET p_over.weight_grp  = p_bmw.weight_grp USING "<<<<&"
      LET p_over.ship_alt    = p_bmw.long_txt CLIPPED
      LET p_over.discipline  = "BEAM" CLIPPED
      LET p_over.descript    = p_bmw.f_part_num CLIPPED

      PRINT COLUMN 1, p_over.prj_no CLIPPED, "|" CLIPPED,
                      p_over.comp_seqno USING "<<<<&", "|" CLIPPED,
                      p_over.weight_grp USING "<<<<&", "|" CLIPPED,
                      p_over.ship_alt CLIPPED, "|" CLIPPED,
                      p_over.discipline CLIPPED, "|" CLIPPED,
                      p_over.descript CLIPPED, "|" CLIPPED,
                      p_over.total_wgt USING "&&&&&&&.&&&", "|" CLIPPED,
                      p_over.vcg USING "------&.&&&", "|" CLIPPED,
                      p_over.lcg USING "------&.&&&", "|" CLIPPED,
                      p_over.tcg USING "------&.&&&", "|" CLIPPED,
                      p_over.vmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.lmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.tmom USING "----------&.&&&"
END REPORT


REPORT PLWreport ()
  DEFINE PLWdensity     FLOAT,
         PLWvolume      FLOAT

  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

  FORMAT
    ON EVERY ROW
      CALL PLWdescription ()
           RETURNING p_over.descript,
                     PLWdensity, PLWvolume, p_over.total_wgt,
                     p_over.vcg, p_over.lcg, p_over.tcg,
                     p_over.vmom, p_over.lmom, p_over.tmom

      LET p_over.prj_no    = p_vds.prj_number CLIPPED
      LET p_over.comp_seqno = p_plw.comp_seqno USING "<<<<<&"
      LET p_over.weight_grp = p_plw.weight_grp USING "<<<<&"
      LET p_over.ship_alt   = p_plw.long_txt CLIPPED
      LET p_over.discipline = "PLATE" CLIPPED

      PRINT COLUMN 1, p_over.prj_no CLIPPED, "|" CLIPPED,
                      p_over.comp_seqno USING "<<<<&", "|" CLIPPED,
                      p_over.weight_grp USING "<<<<&", "|" CLIPPED,
                      p_over.ship_alt CLIPPED, "|" CLIPPED,
                      p_over.discipline CLIPPED, "|" CLIPPED,
                      p_over.descript CLIPPED, "|" CLIPPED,
                      p_over.total_wgt USING "------&.&&&", "|" CLIPPED,
                      p_over.vcg USING "------&.&&&", "|" CLIPPED,
                      p_over.lcg USING "------&.&&&", "|" CLIPPED,
                      p_over.tcg USING "------&.&&&", "|" CLIPPED,
                      p_over.vmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.lmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.tmom USING "----------&.&&&"
END REPORT


REPORT PPWreport ( r_calc, r_args, r_star)
  DEFINE r_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
  		       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
		       pdm_part_num	LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE r_args RECORD dry_wt           FLOAT,
                       wet_wt           FLOAT,
                       surf_area        FLOAT,
                       arg1             FLOAT,
                       arg2             FLOAT,
                       arg3             FLOAT,
                       arg4             FLOAT,
                       arg5             FLOAT,
                       arg6             FLOAT
                END RECORD
  DEFINE r_star RECORD dry_wgt          CHAR(1),
                       wetotal_wgt          CHAR(1),
                       ins_wgt          CHAR(1),
                       tototal_wgt          CHAR(1)
                END RECORD
  DEFINE PPWdesc     CHAR(20),
         PPWdry_wgt  FLOAT,
         PPWwetotal_wgt  FLOAT,
         PPWins_wgt  FLOAT

  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

  FORMAT
    ON EVERY ROW
      CALL PPWdescription ( r_calc.*, r_args.*, r_star.*)
           RETURNING p_over.descript,
                     PPWdry_wgt, PPWwetotal_wgt, PPWins_wgt, p_over.total_wgt,
                     p_over.vcg, p_over.lcg, p_over.tcg,
                     p_over.vmom, p_over.lmom, p_over.tmom,
                     r_star.dry_wgt, 
                     r_star.wetotal_wgt, 
                     r_star.ins_wgt,
                     r_star.tototal_wgt

      LET p_over.prj_no    = p_vds.prj_number CLIPPED
      LET p_over.comp_seqno = p_ppw.comp_seqno USING "<<<<&"
      LET p_over.weight_grp = p_ppw.weight_grp USING "<<<<&"
      LET p_over.ship_alt   = p_ppw.ship_alt CLIPPED
      LET p_over.discipline = "PIPING" CLIPPED

      PRINT COLUMN 1, p_over.prj_no CLIPPED, "|" CLIPPED,
                      p_over.comp_seqno USING "<<<<&", "|" CLIPPED,
                      p_over.weight_grp USING "<<<<&", "|" CLIPPED,
                      p_over.ship_alt CLIPPED, "|" CLIPPED,
                      p_over.discipline CLIPPED, "|" CLIPPED,
                      p_over.descript CLIPPED, "|" CLIPPED,
                      p_over.total_wgt USING "------&.&&&", "|" CLIPPED,
                      p_over.vcg USING "------&.&&&", "|" CLIPPED,
                      p_over.lcg USING "------&.&&&", "|" CLIPPED,
                      p_over.tcg USING "------&.&&&", "|" CLIPPED,
                      p_over.vmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.lmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.tmom USING "----------&.&&&"
END REPORT


REPORT HVWreport ()
 
  OUTPUT 
    LEFT MARGIN 0
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

  FORMAT
    ON EVERY ROW
      CALL HVWdescription () 
           RETURNING p_over.descript, 
		     p_over.total_wgt, 
                     p_over.vcg, p_over.lcg, p_over.tcg,
		     p_over.vmom, p_over.lmom, p_over.tmom

      LET p_over.prj_no    = p_vds.prj_number CLIPPED
      LET p_over.comp_seqno = p_hvw.comp_seqno USING "<<<<&"
      LET p_over.weight_grp = p_hvw.weight_grp USING "<<<<&"
      LET p_over.ship_alt   = p_hvw.ship_alt CLIPPED
      LET p_over.discipline = "HVAC" CLIPPED

      PRINT COLUMN 1, p_over.prj_no CLIPPED, "|" CLIPPED,
                      p_over.comp_seqno USING "<<<<&", "|" CLIPPED,
                      p_over.weight_grp USING "<<<<&", "|" CLIPPED,
                      p_over.ship_alt CLIPPED, "|" CLIPPED,
                      p_over.discipline CLIPPED, "|" CLIPPED,
                      p_over.descript CLIPPED, "|" CLIPPED,
                      p_over.total_wgt USING "------&.&&&", "|" CLIPPED,
                      p_over.vcg USING "------&.&&&", "|" CLIPPED,
                      p_over.lcg USING "------&.&&&", "|" CLIPPED,
                      p_over.tcg USING "------&.&&&", "|" CLIPPED,
                      p_over.vmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.lmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.tmom USING "----------&.&&&"
END REPORT


REPORT EQWreport ()
  DEFINE EQWdry_wgt     FLOAT
 
  OUTPUT 
    LEFT MARGIN 0
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

  FORMAT
    ON EVERY ROW
      CALL EQWdescription () 
           RETURNING p_over.descript, 
		     EQWdry_wgt, p_over.total_wgt,
                     p_over.vcg, p_over.lcg, p_over.tcg,
		     p_over.vmom, p_over.lmom, p_over.tmom

      LET p_over.prj_no    = p_vds.prj_number CLIPPED
      LET p_over.comp_seqno = p_eqw.comp_seqno USING "<<<<&"
      LET p_over.weight_grp = p_eqw.weight_grp USING "<<<<&"
      LET p_over.ship_alt   = p_eqw.long_txt CLIPPED
      LET p_over.discipline = "EQUP" CLIPPED

      PRINT COLUMN 1, p_over.prj_no CLIPPED, "|" CLIPPED,
                      p_over.comp_seqno USING "<<<<&", "|" CLIPPED,
                      p_over.weight_grp USING "<<<<&", "|" CLIPPED,
                      p_over.ship_alt CLIPPED, "|" CLIPPED,
                      p_over.discipline CLIPPED, "|" CLIPPED,
                      p_over.descript CLIPPED, "|" CLIPPED,
                      p_over.total_wgt USING "------&.&&&", "|" CLIPPED,
                      p_over.vcg USING "------&.&&&", "|" CLIPPED,
                      p_over.lcg USING "------&.&&&", "|" CLIPPED,
                      p_over.tcg USING "------&.&&&", "|" CLIPPED,
                      p_over.vmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.lmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.tmom USING "----------&.&&&"
END REPORT


REPORT RWWreport ()
  DEFINE RWWcom_wgt     FLOAT,
         RWWadd_wgt     FLOAT
 
  OUTPUT 
    LEFT MARGIN 0
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

  FORMAT
    ON EVERY ROW
      CALL RWWdescription () 
           RETURNING p_over.descript, 
		     RWWcom_wgt, RWWadd_wgt,
                     p_over.vcg, p_over.lcg, p_over.tcg,
		     p_over.vmom, p_over.lmom, p_over.tmom

      LET p_over.prj_no    = p_vds.prj_number CLIPPED
      LET p_over.comp_seqno = p_rww.comp_seqno USING "<<<<&"
      LET p_over.weight_grp = p_rww.weight_grp USING "<<<<&"
      LET p_over.ship_alt   = p_rww.ship_alt CLIPPED
      LET p_over.discipline = "RWAY" CLIPPED
      LET p_over.total_wgt  = RWWcom_wgt +  RWWadd_wgt

      PRINT COLUMN 1, p_over.prj_no CLIPPED, "|" CLIPPED,
                      p_over.comp_seqno USING "<<<<&", "|" CLIPPED,
                      p_over.weight_grp USING "<<<<&", "|" CLIPPED,
                      p_over.ship_alt CLIPPED, "|" CLIPPED,
                      p_over.discipline CLIPPED, "|" CLIPPED,
                      p_over.descript CLIPPED, "|" CLIPPED,
                      p_over.total_wgt USING "------&.&&&", "|" CLIPPED,
                      p_over.vcg USING "------&.&&&", "|" CLIPPED,
                      p_over.lcg USING "------&.&&&", "|" CLIPPED,
                      p_over.tcg USING "------&.&&&", "|" CLIPPED,
                      p_over.vmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.lmom USING "----------&.&&&", "|" CLIPPED,
                      p_over.tmom USING "----------&.&&&"
END REPORT


REPORT OVWform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 100

  FORMAT
    FIRST PAGE HEADER
      SKIP 1 LINE
      PRINT COLUMN 20, "===================================="
      PRINT COLUMN 20, "| OVERALL WEIGHT CONTROL WORKSHEET |"
      PRINT COLUMN 20, "===================================="
      SKIP 2 LINES
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
      SKIP 2 LINES
      PRINT COLUMN 35, "REFERENCE COORDINATE"
      PRINT COLUMN 35, "===================="
      SKIP 1 LINE
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 34, "L [",
               COLUMN 38, def_lcog * 12.0 USING "-----&.&&&",
               COLUMN 49, "INCH ]"
         PRINT COLUMN 34, "T [",
               COLUMN 38, def_tcog * 12.0 USING "-----&.&&&",
               COLUMN 49, "INCH ]"
         PRINT COLUMN 34, "V [",
               COLUMN 38, def_vcog * 12.0 USING "-----&.&&&",
               COLUMN 49, "INCH ]"
      ELSE
         PRINT COLUMN 34, "L [",
               COLUMN 38, def_lcog * 1000.0 USING "-----&.&&&",
               COLUMN 49, "MM ]"
         PRINT COLUMN 34, "T [",
               COLUMN 38, def_tcog * 1000.0 USING "-----&.&&&",
               COLUMN 49, "MM ]"
         PRINT COLUMN 34, "V [",
               COLUMN 38, def_vcog * 1000.0 USING "-----&.&&&",
               COLUMN 49, "MM ]"
      END IF
      SKIP 2 LINES
      PRINT COLUMN 20, "STRUCTURAL BEAMS REPORTING CRITERIA"
      PRINT COLUMN 20, "==================================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_frm1.bm_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_frm1.bm_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_frm1.bm_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_frm1.bm_zn  CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm1.bm_as  CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm1.bm_cs  CLIPPED, COLUMN 32, "]"
      SKIP 2 LINES
      PRINT COLUMN 20, "STRUCTURAL PLATES REPORTING CRITERIA"
      PRINT COLUMN 20, "===================================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_frm1.pl_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_frm1.pl_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_frm1.pl_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_frm1.pl_zn  CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm1.pl_as  CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm1.pl_cs  CLIPPED, COLUMN 32, "]"
      SKIP 2 LINES
      PRINT COLUMN 20, "HVAC REPORTING CRITERIA"
      PRINT COLUMN 20, "======================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_frm2.hv_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_frm2.hv_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_frm2.hv_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_frm2.hv_sn  CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_frm2.hv_zn  CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm2.hv_as  CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm2.hv_cs  CLIPPED, COLUMN 32, "]"
      SKIP 2 LINES
      PRINT COLUMN 20, "RACEWAY REPORTING CRITERIA"
      PRINT COLUMN 20, "=========================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_frm2.rw_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_frm2.rw_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_frm2.rw_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_frm2.rw_sn  CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_frm2.rw_zn  CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm2.rw_as  CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm2.rw_cs  CLIPPED, COLUMN 32, "]"
      SKIP 2 LINES
      PRINT COLUMN 20, "PIPING REPORTING CRITERIA"
      PRINT COLUMN 20, "========================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_frm3.pp_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_frm3.pp_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_frm3.pp_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_frm3.pp_sn  CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_frm3.pp_zn  CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm3.pp_as  CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm3.pp_cs  CLIPPED, COLUMN 32, "]"
      SKIP 2 LINES
      PRINT COLUMN 20, "EQUIPMENT REPORTING CRITERIA"
      PRINT COLUMN 20, "============================"
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_frm3.eq_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_frm3.eq_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_frm3.eq_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_frm3.eq_zn  CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm3.eq_as  CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_frm3.eq_cs  CLIPPED, COLUMN 32, "]"
END REPORT


REPORT OVWreport (p_4gl)
  DEFINE p_4gl RECORD weight_grp LIKE "nfmadmin".mftable.weight_grp END RECORD

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0
      LET g_wgt = 0.0
      LET g_vmm = 0.0
      LET g_lmm = 0.0
      LET g_tmm = 0.0
      PRINT COLUMN 1  , "DATE:",
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 54 , "O V E R A L L",
            COLUMN 121, "Page - 1"
      PRINT COLUMN 47 , "W E I G H T    C O N T R O L"
      PRINT COLUMN 52 , "W O R K S H E E T"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      PRINT COLUMN 35 , "COMP WT",
            COLUMN 56 , "VCG",
            COLUMN 65 , "LCG",
            COLUMN 74 , "TCG",
            COLUMN 82 , "VERT MOMENT",
            COLUMN 97 , "LONG MOMENT",
            COLUMN 112, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "ITEM",
               COLUMN 7  , "DESCRIPTION",
               COLUMN 36 , "(LB)",
               COLUMN 56 , "(FT)",
               COLUMN 65 , "(FT)",
               COLUMN 74 , "(FT)",
               COLUMN 84 , "(FT-LB)",
               COLUMN 99 , "(FT-LB)",
               COLUMN 114, "(FT-LB)"
      ELSE
         PRINT COLUMN 1  , "ITEM",
               COLUMN 7  , "DESCRIPTION",
               COLUMN 36 , "(KG)",
               COLUMN 56 , "(M)",
               COLUMN 65 , "(M)",
               COLUMN 74 , "(M)",
               COLUMN 84 , "(M-KG)",
               COLUMN 99 , "(M-KG)",
               COLUMN 114, "(M-KG)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      PRINT COLUMN 35 , "COMP WT",
            COLUMN 56 , "VCG",
            COLUMN 65 , "LCG",
            COLUMN 74 , "TCG",
            COLUMN 82 , "VERT MOMENT",
            COLUMN 97 , "LONG MOMENT",
            COLUMN 112, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "ITEM",
               COLUMN 7  , "DESCRIPTION",
               COLUMN 36 , "(LB)",
               COLUMN 56 , "(FT)",
               COLUMN 65 , "(FT)",
               COLUMN 74 , "(FT)",
               COLUMN 84 , "(FT-LB)",
               COLUMN 99 , "(FT-LB)",
               COLUMN 114, "(FT-LB)"
      ELSE
         PRINT COLUMN 1  , "ITEM",
               COLUMN 7  , "DESCRIPTION",
               COLUMN 36 , "(KG)",
               COLUMN 56 , "(M)",
               COLUMN 65 , "(M)",
               COLUMN 74 , "(M)",
               COLUMN 84 , "(M-KG)",
               COLUMN 99 , "(M-KG)",
               COLUMN 114, "(M-KG)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"

      BEFORE GROUP OF p_4gl.weight_grp
      SKIP 1 LINE
      PRINT COLUMN 1 , "SHIP ALT #: ", p_over.ship_alt CLIPPED,
            COLUMN 31, "WT GROUP #:", p_over.weight_grp USING "&&&"
      SKIP 1 LINE

      ON EVERY ROW
      LET g_pce = g_pce + 1
      LET g_wgt = g_wgt + p_over.total_wgt
      LET g_vmm = g_vmm + ( p_over.total_wgt * p_over.vcg )
      LET g_lmm = g_lmm + ( p_over.total_wgt * p_over.lcg )
      LET g_tmm = g_tmm + ( p_over.total_wgt * p_over.tcg )
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  ,p_over.comp_seqno USING "<<<<&",
               COLUMN 7  ,p_over.descript CLIPPED,
               COLUMN 36 ,p_over.total_wgt USING "-----&.&",
               COLUMN 56 ,p_over.vcg USING "-----&.&",
               COLUMN 65 ,p_over.lcg USING "-----&.&",
               COLUMN 74 ,p_over.tcg USING "-----&.&",
               COLUMN 84 ,p_over.total_wgt * p_over.vcg USING "------------&.&",
               COLUMN 99 ,p_over.total_wgt * p_over.lcg USING "------------&.&",
               COLUMN 114,p_over.total_wgt * p_over.tcg USING "------------&.&"
      ELSE
         PRINT COLUMN 1  ,p_over.comp_seqno USING "<<<<&",
               COLUMN 7  ,p_over.descript CLIPPED,
               COLUMN 36 ,p_over.total_wgt USING "-----&.&",
               COLUMN 56 ,p_over.vcg USING "---&.&&",
               COLUMN 65 ,p_over.lcg USING "---&.&&",
               COLUMN 74 ,p_over.tcg USING "---&.&&",
               COLUMN 84 ,p_over.total_wgt * p_over.vcg USING "------------&.&",
               COLUMN 99 ,p_over.total_wgt * p_over.lcg USING "------------&.&",
               COLUMN 114,p_over.total_wgt * p_over.tcg USING "------------&.&"
      END IF

      ON LAST ROW
      SKIP 2 LINES
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "================================================"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 32,  g_wgt USING "GRAND TOTAL WEIGHT: ######&.& LB",
               COLUMN 71,  g_vmm / g_wgt USING "VCG: ----&.& FT",
               COLUMN 90,  g_lmm / g_wgt USING "LCG: ----&.& FT",
               COLUMN 109, g_tmm / g_wgt USING "TCG: ----&.& FT"
      ELSE
         PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 32,  g_wgt USING "GRAND TOTAL WEIGHT: ######&.& KG",
               COLUMN 71,  g_vmm / g_wgt USING "VCG: ---&.&& M",
               COLUMN 90,  g_lmm / g_wgt USING "LCG: ---&.&& M",
               COLUMN 109, g_tmm / g_wgt USING "TCG: ---&.&& M"
      END IF
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "================================================"
END REPORT
