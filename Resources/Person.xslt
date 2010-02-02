<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml">

<xsl:output
	method="html"
	encoding="UTF-8"
	doctype-public="-//W3C//DTD XHTML 1.1//EN"
	doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
	indent="yes"
	cdata-section-elements="style script"/>

<xsl:template match="/root">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="css/main.css" media="all" charset="utf-8" type="text/css" />
		<script type="text/javascript" src="js/jquery.js" charset="utf-8"></script>
		<script type="text/javascript" src="js/main.js" charset="utf-8"></script>
		<script type="text/javascript" src="js/iPhone.js" charset="utf-8"></script>
		<script type="text/javascript">
$(Init);
$(iPhone);
		</script>
	</head>
	<body>
		
<!-- Uncomment the following line to include a spiffy background -->

		<!--<xsl:call-template name="background"/>-->
		
		
		<table class="topRow">
			<tr>
				<td class="face">
					<xsl:if test="count(@face)">
						<img src="{@face}"/>
					</xsl:if>
				</td>
				
				<td class="title">
					<xsl:choose>
						<xsl:when test="count(firstName) and count(lastName)">
							<div class="fullName">
								<xsl:value-of select="firstName"/> <xsl:value-of select="lastName"/>
								<xsl:if test="count(company)">
									<br/><span class="secondaryCompany"><xsl:value-of select="company"/></span>
								</xsl:if>
							</div>
						</xsl:when>
			
						<xsl:when test="count(firstName)">
							<div class="fullName">
								<xsl:value-of select="firstName"/> <span class="missing">(who apparently has no last name)</span>
								<xsl:if test="count(company)">
									<br/><span class="secondaryCompany"><xsl:value-of select="company"/></span>
								</xsl:if>
							</div>
						</xsl:when>
			
						<xsl:when test="count(lastName)">
							<div class="fullName">
								<span class="missing">(that one person with no first name)</span> <xsl:value-of select="lastName"/>
								<xsl:if test="count(company)">
									<br/><span class="secondaryCompany"><xsl:value-of select="company"/></span>
								</xsl:if>
							</div>
						</xsl:when>
			
						<xsl:otherwise>
							<div class="primaryCompany"><xsl:value-of select="company"/></div>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
			
			<xsl:apply-templates select="emails"/>
			<xsl:apply-templates select="urls"/>
			<xsl:apply-templates select="phones"/>
		</table>
	</body>
	</html>
</xsl:template>


<!-- URLs -->

<xsl:template match="urls">
	<tr class="urls">
		<td class="label">Webpages:</td>
		<td class="value">
			<ul>
				<xsl:apply-templates select="url"/>
			</ul>
		</td>
	</tr>
</xsl:template>

<xsl:template match="url">
	<li><xsl:value-of select="."/></li>
</xsl:template>


<!-- Emails -->

<xsl:template match="emails">
	<tr class="emails">
		<td class="label">Email Addresses:</td>
		<td class="value">
			<ul>
				<xsl:apply-templates select="email"/>
			</ul>
		</td>
	</tr>
</xsl:template>

<xsl:template match="email">
	<li><xsl:value-of select="."/></li>
</xsl:template>


<!-- Telephone Numbers -->

<xsl:template match="phones">
	<tr class="phones">
		<td class="label">Telephone Numbers:</td>
		<td class="value">
			<ul>
				<xsl:apply-templates select="phone"/>
			</ul>
		</td>
	</tr>
</xsl:template>

<xsl:template match="phone">
	<li class="phone"><xsl:value-of select="."/></li>
</xsl:template>


<!-- The Background -->

<xsl:template name="background">
	<style type="text/css">
		body {
			color: white;
		}
		.matrix {
			position: absolute;
			left: 0;
			top: 0;
			width: 100%;
			height: 100%;
			z-index: -1;
			text-align: center;
		}
		.hover {
			background-color: rgba(200,226,242,0.4);
		}
	</style>
	
<!-- Remove the "iphone" class to get rid of the "missing flash" image -->

	<object class="matrix iphone" classid="clsid:D27CDB6E-AE6D-11CF-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0">
		<param name="movie" value="images/matrix.swf" />
		<param name="play" value="true" />
		<param name="loop" value="false" />
		<param name="quality" value="high" />
		<param name="AllowScriptAccess" value="never" />
		<embed src="images/matrix.swf" AllowScriptAccess="never" play="true" loop="true" quality="high" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"></embed>
	</object>
</xsl:template>
</xsl:stylesheet>