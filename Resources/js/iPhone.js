function iPhone()
{
	var iPhone = $(".matrix");
	if (iPhone.hasClass("iphone"))
	{
		iPhone.replaceWith('<div class="matrix" style="display: table; height: 100%;"><div style="display: table-cell; vertical-align: middle;"><img src="images/nullplugin.png"/></div></div>');
		$("body").css("color", "black");
	}
}