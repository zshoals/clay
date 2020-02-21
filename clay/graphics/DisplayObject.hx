package clay.graphics;


import clay.math.Rectangle;
import clay.math.Transform;
import clay.math.VectorCallback;
import clay.render.SortKey;
import clay.render.Layer;
import clay.render.Shader;
import clay.render.Painter;
import clay.render.Camera;
import clay.utils.Log.*;


class DisplayObject {


	static var ID:Int = 0; // for debug

	public var name:String;

	public var transform:Transform;

	public var visible(default, set):Bool;
	public var renderable:Bool;
	
	public var layer(get, set):Layer;
	public var depth(default, set):Float;

	public var shader(default, set):Shader;
	public var clipRect(default, set):Rectangle;

	public var sortKey(default, null):SortKey;
	public var shaderDefault(default, null):Shader;

	public var pos(get, never):VectorCallback;
	public var scale(get, never):VectorCallback;
	public var rotation(get, set):Float;
	public var origin(get, never):VectorCallback;

	var _layer:Layer;
	

	public function new() {
		
		visible = true;
		renderable = true;
		name = 'displayObject.${ID++}';
		transform = new Transform();
		sortKey = new SortKey(0,0);
		depth = 0;
		shaderDefault = Clay.renderer.shaders.get('textured');

	}

	public function drop() {
		
		if(_layer != null) {
			_layer._removeUnsafe(this);
		}

	}

	public function update(dt:Float) {

		transform.update();

	}

	public function render(p:Painter) {}

	function onAdded(l:Layer) {}
	function onRemoved(l:Layer) {}

	function set_visible(v:Bool):Bool {

		return visible = v;

	}

	inline function get_layer():Layer {

		return _layer;

	}

	function set_layer(v:Layer):Layer {

		if(_layer != null) {
			_layer._removeUnsafe(this);
		}

		_layer = v;

		if(_layer != null) {
			_layer._addUnsafe(this);
		}

		return v;

	}

	function set_depth(v:Float):Float {

		sortKey.depth = v;

		dirtySort();

		return depth = v;

	}
	
	function set_shader(v:Shader):Shader {

		sortKey.shader = v != null ? v.id : shaderDefault.id;

		dirtySort();

		return shader = v;

	}

	function set_clipRect(v:Rectangle):Rectangle {

		sortKey.clip = v != null;

		if(clipRect == null && v != null || clipRect != null && v == null) {
			dirtySort();
		}

		return clipRect = v;

	}

	inline function get_pos():VectorCallback {

		return transform.pos;

	}

	inline function get_scale():VectorCallback {

		return transform.scale;

	}

	inline function get_rotation():Float {

		return transform.rotation;

	}

	inline function set_rotation(v:Float):Float {

		return transform.rotation = v;

	}

	inline function get_origin():VectorCallback {

		return transform.origin;

	}

	inline function dirtySort() {

		if(layer != null && layer.depthSort) {
			layer.dirtySort = true;
		}

	}
	

}