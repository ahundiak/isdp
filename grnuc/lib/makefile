# Build composite grnuc library
# And OMprodinit

objects = \
	$(GRNUC)/lib/AStext.o       \
	$(GRNUC)/lib/COcc.o         \
	$(GRNUC)/lib/DEso.o         \
	$(GRNUC)/lib/DEso_spec.o    \
	$(GRNUC)/lib/GRnb.o         \
	$(GRNUC)/lib/GRnbspec.o     \
	$(GRNUC)/lib/absg_graph.o   \
	$(GRNUC)/lib/adpco.o        \
	$(GRNUC)/lib/adpcosp.o      \
	$(GRNUC)/lib/arc.o          \
	$(GRNUC)/lib/attrco.o       \
	$(GRNUC)/lib/attrcosp.o     \
	$(GRNUC)/lib/attrib.o       \
	$(GRNUC)/lib/ci_executor.o  \
	$(GRNUC)/lib/cinotify.o     \
	$(GRNUC)/lib/cct.o          \
	$(GRNUC)/lib/cct_spec.o     \
	$(GRNUC)/lib/ceo_gslocate.o \
	$(GRNUC)/lib/ceo_locate.o   \
	$(GRNUC)/lib/ci.o           \
	$(GRNUC)/lib/cicom.o        \
	$(GRNUC)/lib/cisetup.o      \
	$(GRNUC)/lib/ci_macro.o     \
	$(GRNUC)/lib/co3414_I.o     \
	$(GRNUC)/lib/co3414_sp.o    \
	$(GRNUC)/lib/cob.o          \
	$(GRNUC)/lib/cob_sp.o       \
	$(GRNUC)/lib/coglobal.o     \
	$(GRNUC)/lib/condit.o       \
	$(GRNUC)/lib/copara.o       \
	$(GRNUC)/lib/cosup.o        \
	$(GRNUC)/lib/cr.o           \
	$(GRNUC)/lib/csco.o         \
	$(GRNUC)/lib/cscosp.o       \
	$(GRNUC)/lib/csgo.o         \
	$(GRNUC)/lib/csgosp.o       \
	$(GRNUC)/lib/detailco.o     \
	$(GRNUC)/lib/detailcosp.o   \
	$(GRNUC)/lib/detailgo.o     \
	$(GRNUC)/lib/detailgosp.o   \
	$(GRNUC)/lib/dim_angular.o  \
	$(GRNUC)/lib/dim_annot.o    \
	$(GRNUC)/lib/dim_cenline.o  \
	$(GRNUC)/lib/dim_co.o       \
	$(GRNUC)/lib/dim_coord.o    \
	$(GRNUC)/lib/dim_expr.o     \
	$(GRNUC)/lib/dim_linear.o   \
	$(GRNUC)/lib/dim_param.o    \
	$(GRNUC)/lib/dim_plan.o     \
	$(GRNUC)/lib/dim_radial.o   \
	$(GRNUC)/lib/dim_root.o     \
	$(GRNUC)/lib/dim_sgl.o      \
	$(GRNUC)/lib/dim_src.o      \
	$(GRNUC)/lib/dim_super.o    \
	$(GRNUC)/lib/dim_text.o     \
	$(GRNUC)/lib/dim_utils.o    \
	$(GRNUC)/lib/dl.o           \
	$(GRNUC)/lib/dlist.o        \
	$(GRNUC)/lib/dpbco.o        \
	$(GRNUC)/lib/dpbcosp.o      \
	$(GRNUC)/lib/dpvd.o         \
	$(GRNUC)/lib/dpvd_sp.o      \
	$(GRNUC)/lib/dsgo.o         \
	$(GRNUC)/lib/dsgosp.o       \
	$(GRNUC)/lib/event.o        \
	$(GRNUC)/lib/eventsco.o     \
	$(GRNUC)/lib/eventscosp.o   \
	$(GRNUC)/lib/exec_node.o    \
	$(GRNUC)/lib/expression.o   \
	$(GRNUC)/lib/expreval.o     \
	$(GRNUC)/lib/fenceco.o      \
	$(GRNUC)/lib/fencecosp.o    \
	$(GRNUC)/lib/fencego.o      \
	$(GRNUC)/lib/fencegosp.o    \
	$(GRNUC)/lib/fontco.o       \
	$(GRNUC)/lib/fontcosp.o     \
	$(GRNUC)/lib/fontmgr.o      \
	$(GRNUC)/lib/fontmgrsp.o    \
	$(GRNUC)/lib/fontutil.o     \
	$(GRNUC)/lib/forms.o        \
	$(GRNUC)/lib/getevent.o     \
	$(GRNUC)/lib/globalco.o     \
	$(GRNUC)/lib/globalgo.o     \
	$(GRNUC)/lib/go3d_I.o       \
	$(GRNUC)/lib/go3d_S.o       \
	$(GRNUC)/lib/go_I.o         \
	$(GRNUC)/lib/go_S.o         \
	$(GRNUC)/lib/gopara.o       \
	$(GRNUC)/lib/gosup.o        \
	$(GRNUC)/lib/graphics_I.o   \
	$(GRNUC)/lib/graphics_S.o   \
	$(GRNUC)/lib/grdglobal.o    \
	$(GRNUC)/lib/grdisplay.o    \
	$(GRNUC)/lib/grdisplaysp.o  \
	$(GRNUC)/lib/grdpb.o        \
	$(GRNUC)/lib/grdpbsp.o      \
	$(GRNUC)/lib/grgrpco.o      \
	$(GRNUC)/lib/grgrpcosp.o    \
	$(GRNUC)/lib/grgrpgo.o      \
	$(GRNUC)/lib/grgrpgosp.o    \
	$(GRNUC)/lib/grio_sp.o      \
	$(GRNUC)/lib/grmodule.o     \
	$(GRNUC)/lib/grmodulesp.o   \
	$(GRNUC)/lib/grsetgo.o      \
	$(GRNUC)/lib/grsetgosp.o    \
	$(GRNUC)/lib/grwindow.o     \
	$(GRNUC)/lib/grwindowsp.o   \
	$(GRNUC)/lib/gr_temp_stubs.o\
	$(GRNUC)/lib/lcobjgo.o      \
	$(GRNUC)/lib/lcobjgosp.o    \
	$(GRNUC)/lib/libcobdrafts.o \
	$(GRNUC)/lib/lineterm.o     \
	$(GRNUC)/lib/lineterm_sp.o  \
	$(GRNUC)/lib/ln.o           \
	$(GRNUC)/lib/locate.o       \
	$(GRNUC)/lib/locatesp.o     \
	$(GRNUC)/lib/macro.o        \
	$(GRNUC)/lib/macro_co.o     \
	$(GRNUC)/lib/manipco.o      \
	$(GRNUC)/lib/manipcosp.o    \
	$(GRNUC)/lib/meas.o         \
	$(GRNUC)/lib/misc.o         \
	$(GRNUC)/lib/misc_sp.o      \
	$(GRNUC)/lib/mod.o          \
	$(GRNUC)/lib/nmacro.o       \
	$(GRNUC)/lib/nmacro_co.o    \
	$(GRNUC)/lib/node.o         \
	$(GRNUC)/lib/nodein.o       \
	$(GRNUC)/lib/ownergo.o      \
	$(GRNUC)/lib/ownergosp.o    \
	$(GRNUC)/lib/palco.o        \
	$(GRNUC)/lib/palcosp.o      \
	$(GRNUC)/lib/palgo.o        \
	$(GRNUC)/lib/palgosp.o      \
	$(GRNUC)/lib/parse.o        \
	$(GRNUC)/lib/partco.o       \
	$(GRNUC)/lib/partcosp.o     \
	$(GRNUC)/lib/partgo.o       \
	$(GRNUC)/lib/partgosp.o     \
	$(GRNUC)/lib/plotco.o       \
	$(GRNUC)/lib/plotcosp.o     \
	$(GRNUC)/lib/poly.o         \
	$(GRNUC)/lib/popen.o        \
	$(GRNUC)/lib/projco.o       \
	$(GRNUC)/lib/projcosp.o     \
	$(GRNUC)/lib/pt.o           \
	$(GRNUC)/lib/ptnco.o        \
	$(GRNUC)/lib/ptncosp.o      \
	$(GRNUC)/lib/ptngo.o        \
	$(GRNUC)/lib/ptngosp.o      \
	$(GRNUC)/lib/rap.o          \
	$(GRNUC)/lib/rap_sp.o       \
	$(GRNUC)/lib/raststub.o     \
	$(GRNUC)/lib/rattrco.o      \
	$(GRNUC)/lib/rattrcosp.o    \
	$(GRNUC)/lib/ref_I.o        \
	$(GRNUC)/lib/ref_S.o        \
	$(GRNUC)/lib/refapi.o       \
	$(GRNUC)/lib/refco.o        \
	$(GRNUC)/lib/refcosp.o      \
	$(GRNUC)/lib/refsup.o       \
	$(GRNUC)/lib/retco.o        \
	$(GRNUC)/lib/retcosp.o      \
	$(GRNUC)/lib/sl.o           \
	$(GRNUC)/lib/smartco.o      \
	$(GRNUC)/lib/source.o       \
	$(GRNUC)/lib/sql.o          \
	$(GRNUC)/lib/srcI.o         \
	$(GRNUC)/lib/srcS.o         \
	$(GRNUC)/lib/super_para.o   \
	$(GRNUC)/lib/supfungo.o     \
	$(GRNUC)/lib/symb_mac.o     \
	$(GRNUC)/lib/symbco.o       \
	$(GRNUC)/lib/symbcosp.o     \
	$(GRNUC)/lib/symbgo.o       \
	$(GRNUC)/lib/symbgosp.o     \
	$(GRNUC)/lib/tablego.o      \
	$(GRNUC)/lib/tablegosp.o    \
	$(GRNUC)/lib/textco.o       \
	$(GRNUC)/lib/textcosp.o     \
	$(GRNUC)/lib/textgo.o       \
	$(GRNUC)/lib/textgosp.o     \
	$(GRNUC)/lib/toolco.o       \
	$(GRNUC)/lib/toolcosp.o     \
	$(GRNUC)/lib/tr.o           \
	$(GRNUC)/lib/trret.o        \
	$(GRNUC)/lib/trsav.o        \
	$(GRNUC)/lib/transco.o      \
	$(GRNUC)/lib/transcosp.o    \
	$(GRNUC)/lib/transgo.o      \
	$(GRNUC)/lib/units.o        \
	$(GRNUC)/lib/uom.o          \
	$(GRNUC)/lib/uomsp.o        \
	$(GRNUC)/lib/undogo.o       \
	$(GRNUC)/lib/undogosp.o     \
	$(GRNUC)/lib/utilmisc.o     \
	$(GRNUC)/lib/var.o          \
	$(GRNUC)/lib/vg_I.o         \
	$(GRNUC)/lib/vg_S.o         \
	$(GRNUC)/lib/xhatch.o       \
	$(GRNUC)/lib/xhatch_sp.o

target: $(GRNUC)/lib/grnuc.o

$(GRNUC)/lib/grnuc.o : $(objects)
	@ld -r -o $(GRNUC)/lib/grnuc.o $(objects)
	@ls    -l $(GRNUC)/lib/grnuc.o

clean:
	@rm -f grnuc.o
