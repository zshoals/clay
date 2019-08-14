package clay.system.debug;


import clay.graphics.Text;
import clay.render.Color;
import clay.math.Vector;
import clay.system.Debug;


class TraceDebugView extends DebugView {


	var logged:Array<String>;
	var lines:Text;
	var max_lines:Int = 35;


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = "Log";

		clay.system.Debug.trace_callbacks.push(on_trace);

		logged = [];

		lines = new Text(Clay.renderer.font);
		lines.size = 14;
		lines.align = TextAlign.left;
		lines.align_vertical = TextAlign.bottom;
		lines.visible = false;
		lines.color = new Color().from_int(0x888888);
		lines.transform.pos.set(debug.padding.x+20, debug.padding.y+40);
		lines.width = Clay.screen.width-(debug.padding.x*2)-20;
		lines.height = Clay.screen.height-(debug.padding.y*2)-40;
		lines.layer = debug.layer;
		lines.depth = 999.3;

	}

	// override function onremoved() {

	// 	lines.destroy();
	// 	lines = null;

	// }

	override function onenabled() {

		lines.visible = true;
		refresh_lines();

	}

	override function ondisabled() {

		lines.visible = false;

	}

	public function add_line(_t:String) {

		if(logged.length >= max_lines) {
			logged.shift();
		}

		logged.push(_t);

		if(!active) {
			return;
		}

		refresh_lines();

	}

	function on_trace( v : Dynamic, ?inf : haxe.PosInfos ) {

		add_line( inf.fileName + ":" + inf.lineNumber + " " + v );

	}

	function refresh_lines() {

		var _final = new StringBuf();

		for (l in logged) {
			_final.add(l + " \n");
		}

		lines.text = _final.toString();

	}


}