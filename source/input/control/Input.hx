package input.control;

interface Input {
    public function value():Dynamic;
	public function name():String;

	public var hiddenFromControls:Bool;
}