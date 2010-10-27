<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
     <table name="Inverse Bending Line Report"
            description="Inverse Bending Line Report">
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_BENDLINES/SMS_BENDLINE"
		order-by="STIF_NAME">
          <layout>
	    <column title="Step Value" column_no="1" />
	    <column title="Height" column_no="2" />
          </layout>
	  <row>
	    <cell column_no="1" value="" />
	    <cell column_no="2" value="Stiffener Name: {@STIF_NAME}" />
	  </row>
	  <row>
	    <cell column_no="1" value="" />
	    <cell column_no="2" value="Web Side: {@WEB_SIDE}" />
	  </row>
	  <row>
	    <cell column_no="1" value="" />
	    <cell column_no="2" value="Fiber Ratio: {@FIB_RATIO}" />
	  </row>
	  <xsl:for-each select="SMS_CRV_INFO" order-by="INDEX">
	    <row>
		<cell column_no="1" value="Curve Index: {@INDEX}" />
		<cell column_no="2" value=""/>
	    </row>
            <row>
		<cell column_no="1" value="Step Value"/>
		<cell column_no="2" value="Height"/>
	    </row>
            <xsl:for-each select="SMS_STEP_INFO"
				order-by="INDEX">
              <row>
		<cell column_no="1" value="{@STEP_VALUE}" />
		<cell column_no="2" value="{@BEND_HEIGHT}" />
	      </row>
            </xsl:for-each>
	  </xsl:for-each>
        </xsl:for-each>
     </table>
  </xsl:template>
</xsl:stylesheet>
