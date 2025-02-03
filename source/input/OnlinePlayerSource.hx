package input;

class OnlinePlayerSource extends ModifiableInputSource
{
	public var attackJustPressedTwo = false;
	public var jumpJustPressedTwo = false;
	public var dashJustPressedTwo = false;
	public var backslotJustPressedTwo = false;
	public var altFireJustPressedTwo = false;
	public var interactJustPressedTwo = false;

	public var ui_acceptTwo = false;
	public var ui_denyTwo = false;
	public var ui_menuTwo = false;

	override public function new()
	{
		super();
		hiddenFromMenus = true;
		translationKey = "input.online";
	}

	override function update()
	{
		if (ui_denyTwo)
		{
			ui_denyTwo = false;
			ui_deny = true;
		}
		else
		{
			ui_deny = false;
		}
		if (ui_menuTwo)
		{
			ui_menuTwo = false;
			ui_menu = true;
		}
		else
		{
			ui_menu = false;
		}
		if (ui_acceptTwo)
		{
			ui_acceptTwo = false;
			ui_accept = true;
		}
		else
		{
			ui_accept = false;
		}
		if (interactJustPressedTwo)
		{
			interactJustPressedTwo = false;
			interactJustPressed = true;
		}
		else
		{
			interactJustPressed = false;
		}
		if (altFireJustPressedTwo)
		{
			altFireJustPressedTwo = false;
			altFireJustPressed = true;
		}
		else
		{
			altFireJustPressed = false;
		}
		if (backslotJustPressedTwo)
		{
			backslotJustPressedTwo = false;
			backslotPressed = true;
		}
		else
		{
			backslotPressed = false;
		}
		if (dashJustPressedTwo)
		{
			dashJustPressedTwo = false;
			dashJustPressed = true;
		}
		else
		{
			dashJustPressed = false;
		}
		if (jumpJustPressedTwo)
		{
			jumpJustPressedTwo = false;
			jumpJustPressed = true;
		}
		else
		{
			jumpJustPressed = false;
		}
		if (attackJustPressedTwo)
		{
			attackJustPressedTwo = false;
			attackJustPressed = true;
		}
		else
		{
			attackJustPressed = false;
		}
		super.update();
	}
}