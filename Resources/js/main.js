function Init()
{
	var phones = $(".phone");
	
	
	phones.hover(
		function()
		{
			var element = $(this);
			element.addClass("hover");
		}, 
		function()
		{
			var element = $(this);
			element.removeClass("hover");
		}
	);
	
	
	phones.click(
		function()
		{
			if (window.viewController)
				window.viewController.ShowPhoneNumber(this.innerText);
		}
	);
}