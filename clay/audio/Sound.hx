package clay.audio;


import kha.audio2.ogg.vorbis.Reader;
import kha.arrays.Float32Array;
import clay.resources.AudioResource;
import clay.audio.AudioChannel;
import clay.audio.AudioEffect;
import clay.audio.AudioGroup;
import clay.utils.Mathf;
import clay.utils.Log.*;

class Sound extends AudioChannel {


	public var resource(default, set):AudioResource;

	public var pitch(default, set):Float;

	public var time(get, set):Float;
	public var duration(get, never):Float;
	public var position(default, set):Int;
	public var length(get, never):Int;

	public var paused(default, null):Bool;
	public var playing(get, never):Bool;
	public var finished(default, null):Bool;
	public var stream(default, set):Bool;
	public var channels(get, never):Int;

	public var loop:Bool;

	@:noCompletion public var added:Bool;

	#if (!kha_no_ogg)
	@:noCompletion public var reader:Reader;
	#end

	var _position:Float;
	var _cache:Float32Array;


	public function new(?resource:AudioResource, output:AudioGroup = null, maxEffects:Int = 8) {

		super(maxEffects);

		this.resource = resource;

		pitch = 1;

		stream = false;
		paused = false;
		loop = false;
		finished = false;
		position = 0;

		added = false;

		this.output = output != null ? output : Clay.audio;

		_position = 0;
		_cache = new Float32Array(512);
		
	}

	override function process(data:Float32Array, samples:Int) {

		if(resource == null) {
			return;
		}
	    
		if (_cache.length < samples) {
			_cache = new Float32Array(samples);
		}

		for (i in 0...samples) {
			_cache[i] = 0;
		}

		if(mute) {
			return;
		}

		if(finished) {
			output.remove(this);
			added = false;
			return;
		}

		if(!stream) {
			var soundData = resource.uncompressedData;
			var wPtr = 0;
			var chkPtr = 0;
			while (wPtr < samples) {
				// compute one chunk to render
				var addressableData = soundData.length - position;
				var nextChunk = addressableData < (samples - wPtr) ? addressableData : (samples - wPtr);
				while (chkPtr < nextChunk) {
					_cache[wPtr] = soundData[position];
					_position += pitch;
					position = Math.floor(_position);
					// ++position;
					++chkPtr;
					++wPtr;
				}
				// loop to next chunk if applicable
				if (!loop) {
					break;
				} else { 
					chkPtr = 0;
					if (position >= soundData.length) {
						position = 0;
						_position = 0;
					}
				}
			}
			// fill empty
			while (wPtr < samples) {
				_cache[wPtr] = 0;
				++wPtr;
			}

		} else {
			#if (!kha_no_ogg)
			var count = reader.read(_cache, Std.int(samples / 2), 2, Clay.audio.sampleRate, true) * 2; // todo: check channels
			if (count < samples) {
				if (loop) {
					position = 0;
				}
				for (i in count...samples) {
					_cache[i] = 0;
				}
			}
			position = reader.currentSample;
			#end
		}

		processEffects(_cache, samples);

		for (i in 0...Std.int(samples/2)) {
			data[i*2] += _cache[i*2] * volume * l;
			data[i*2+1] += _cache[i*2+1] * volume * r;
		}

		if (position >= length) {
			finished = true;
		}

	}

	public function play():Sound {

		paused = false;
		position = 0;

		if(resource != null) {
			if(output != null) {
				if(!added) {
					output.add(this);
					added = true;
				}
			} else {
				log("cant play: there is no output channel for sound");
			}
		} else {
			log("there is no audio resource to play");
		}
		
		return this;

	}

	public function stop():Sound {
		
		if(resource != null) {
			if(output != null) {
				if(!added) {
					output.remove(this);
					added = false;
				}
			} else {
				log("cant stop: there is no output channel for sound");
			}
		} else {
			log("there is no audio resource, nothing to stop");
		}

		return this;

	}

	public function pause():Sound {
		
		paused = true;

		return this;

	}

	public function unpause():Sound {

		paused = false;
		
		return this;

	}

	override function set_output(v:AudioGroup):AudioGroup {

		if(output != null) {
			output.remove(this);
		}

		output = v;

		return output;

	}

	function set_resource(v:AudioResource):AudioResource {

		resource = v;

		if(stream) {
			#if (!kha_no_ogg)
			reader = Reader.openFromBytes(resource.compressedData);
			#end
		}

		return resource;

	}

	function set_pitch(v:Float):Float {

		pitch = Mathf.clampBottom(v, 0.01); // todo: 0?

		return pitch;

	}

	function get_time():Float { // todo: check for stream

		return position / Clay.audio.sampleRate / channels;

	}

	function set_time(v:Float):Float { // todo: check for stream

		return position = Std.int(v * Clay.audio.sampleRate * channels);

	}

	inline function get_finished():Bool { 

		return position >= length;

	}

	inline function get_playing():Bool { 

		return added;

	}

	function set_position(v:Int):Int {

		if(stream) {	
			#if (kha_no_ogg) 
			return 0.0; 
			#else 
			return reader.currentSample = v; 
			#end
		}

		return position = v;

	}

	function set_stream(v:Bool):Bool {

		stream = v;

		if(stream && resource != null) {
			#if (!kha_no_ogg)
			reader = Reader.openFromBytes(resource.compressedData);
			#end
		}

		return v;

	}

	function get_length():Int {

		if(resource != null) {
			if(stream) {	
				#if (kha_no_ogg) 
				return 0; 
				#else 
				return reader.totalSample; 
				#end
			}
			return resource.uncompressedData.length;
		}

		return 0;


	}

	function get_channels():Int {

		if(resource != null) {
			if(stream) {	
				#if (kha_no_ogg) 
				return 0; 
				#else 
				return reader.header.channel; // todo: check this
				#end
			}
			return resource.channels;
		}

		return 0;

	}

	function get_duration():Float {

		if(resource != null) {
			if(stream) {	
				#if (kha_no_ogg) 
				return 0; 
				#else 
				return reader.totalMillisecond / 1000; 
				#end
			}
			return resource.uncompressedData.length / Clay.audio.sampleRate / channels;
		}

		return 0;

	}


}