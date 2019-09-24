package clay.graphics.particles.modules;


import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.graphics.particles.components.ColorBySpeed;
import clay.graphics.particles.components.Color;
// import clay.render.Color;
import clay.utils.Mathf;


class ColorBySpeedModule extends ParticleModule {


	public var minColor	(default, null):Color;
	public var maxColor    	(default, null):Color;
	public var minColorMax:Color; // TODO: that name...
	public var maxColorMax:Color; // TODO: that name...

	public var minSpeed:Float;
	public var maxSpeed:Float;

	var _velocity:Components<Velocity>;
	var _color:Components<Color>;
	var _colorsBySpeed:Components<ColorBySpeed>;


	public function new(_options:ColorBySpeedModuleOptions) {

		super(_options);

		minColor = _options.minColor != null ? _options.minColor : new Color();
		minColorMax = _options.minColorMax;
		maxColor = _options.maxColor != null ? _options.maxColor : new Color();
		maxColorMax = _options.maxColorMax;
		minSpeed = _options.minSpeed != null ? _options.minSpeed : 0;
		maxSpeed = _options.maxSpeed != null ? _options.maxSpeed : 1;

	}

	override function init() {

		_velocity = emitter.components.get(Velocity);
		_color = emitter.components.get(Color);
		_colorsBySpeed = emitter.components.get(ColorBySpeed);
	    
	}

	override function onSpawn(p:Particle) {

		var vel = _velocity.get(p.id);
		var c = _color.get(p.id);
		var cbs = _colorsBySpeed.get(p.id);

		var c0 = cbs.minColor;
		var c1 = cbs.maxColor;

		if(minColorMax != null) {
			c0.r = emitter.randomFloat(minColor.r, minColorMax.r);
			c0.g = emitter.randomFloat(minColor.g, minColorMax.g);
			c0.b = emitter.randomFloat(minColor.b, minColorMax.b);
			c0.a = emitter.randomFloat(minColor.a, minColorMax.a);
		} else {
			c0.r = minColor.r;
			c0.g = minColor.g;
			c0.b = minColor.b;
			c0.a = minColor.a;
		}
		
		if(maxColorMax != null) {
			c1.r = emitter.randomFloat(maxColor.r, maxColorMax.r);
			c1.g = emitter.randomFloat(maxColor.g, maxColorMax.g);
			c1.b = emitter.randomFloat(maxColor.b, maxColorMax.b);
			c1.a = emitter.randomFloat(maxColor.a, maxColorMax.a);
		} else {
			c1.r = maxColor.r;
			c1.g = maxColor.g;
			c1.b = maxColor.b;
			c1.a = maxColor.a;
		}

		setColorFromVelocity(c, cbs, vel);

	}


	override function update(dt:Float) {

		var vel:Velocity;
		var cbs:ColorBySpeed;
		var c:Color;
		for (p in particles) {
			vel = _velocity.get(p.id);
			cbs = _colorsBySpeed.get(p.id);
			c = _color.get(p.id);
			setColorFromVelocity(c, cbs, vel);
		}

	}

	inline function setColorFromVelocity(c:Color, cbs:ColorBySpeed, vel:Velocity) {

		var lenSq = vel.lengthSq;
		var minSpeedSq = minSpeed * minSpeed;
		var maxSpeedSq = maxSpeed * maxSpeed;

		if(maxSpeed - minSpeedSq != 0) {
			var t = Mathf.inverseLerp(minSpeedSq, maxSpeedSq, lenSq);
			c.copyFrom(cbs.minColor).lerp(cbs.maxColor, t);
		}
		
	}

// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		minSpeed = d.minSpeed;
		maxSpeed = d.maxSpeed;

		if(d.minColor != null) {
			minColor.fromJson(d.minColor);
		}

		if(d.maxColor != null) {
			maxColor.fromJson(d.maxColor);
		}

		if(d.minColorMax != null) {
			if(minColorMax == null) {
				minColorMax = new Color();
			}
			minColorMax.fromJson(d.minColorMax);
		}
		
		if(d.maxColorMax != null) {
			if(maxColorMax == null) {
				maxColorMax = new Color();
			}
			maxColorMax.fromJson(d.maxColorMax);
		}

		return this;

	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.minSpeed = minSpeed;
		d.maxSpeed = maxSpeed;

		d.minColor = minColor.toJson();
		d.maxColor = maxColor.toJson();

		if(minColorMax != null) {
			d.minColorMax = minColorMax.toJson();
		}
		
		if(maxColorMax != null) {
			d.maxColorMax = maxColorMax.toJson();
		}

		return d;

	}


}

typedef ColorBySpeedModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var minColor:Color;
	@:optional var minColorMax:Color;
	@:optional var maxColor:Color;
	@:optional var maxColorMax:Color;
	@:optional var minSpeed:Float;
	@:optional var maxSpeed:Float;

}


