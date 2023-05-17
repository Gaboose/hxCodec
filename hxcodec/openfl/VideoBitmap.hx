package hxcodec.openfl;

import haxe.io.Bytes;
import hxcodec.vlc.VLCBitmap;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.events.Event;
import openfl.utils.ByteArray;

class VideoBitmap extends Bitmap
{
	// VLCBitmap
	public var video:VLCBitmap;

	// VLCBitmap variables and callbacks for backwards compatibility.
	public var videoWidth(get, null):cpp.UInt32;
	public var videoHeight(get, null):cpp.UInt32;

	public var time(get, set):Int;
	public var position(get, set):Float;
	public var length(get, never):Int;
	public var duration(get, never):Int;
	public var mrl(get, never):String;
	public var volume(get, set):Int;
	public var delay(get, set):Int;
	public var rate(get, set):Float;
	public var fps(get, never):Float;
	public var isPlaying(get, never):Bool;
	public var isSeekable(get, never):Bool;
	public var canPause(get, never):Bool;

	public var onOpening(get, set):Void->Void;
	public var onPlaying(get, set):Void->Void;
	public var onPaused(get, set):Void->Void;
	public var onStopped(get, set):Void->Void;
	public var onEndReached(get, set):Void->Void;
	public var onEncounteredError(get, set):String->Void;
	public var onForward(get, set):Void->Void;
	public var onBackward(get, set):Void->Void;

	// Internal variables
	private var texture:RectangleTexture;

	public function new():Void
	{
		super(bitmapData, AUTO, true);

		video = new VLCBitmap();

		if (stage != null)
			onAddedToStage();
		else
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	public function dispose():Void
	{
		if (stage.hasEventListener(Event.ENTER_FRAME))
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}

		if (bitmapData != null)
		{
			bitmapData.dispose();
			bitmapData = null;
		}

		video.dispose();
	}

	public function play(?location:String = null, loop:Bool = false):Int
	{
		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}

		if (bitmapData != null)
		{
			bitmapData.dispose();
			bitmapData = null;
		}

		return video.play(location, loop);
	}

	inline public function stop():Void { video.stop(); }
	inline public function pause():Void { video.pause(); }
	inline public function resume():Void { video.resume(); }

	// Internal Methods
	private function onAddedToStage(?e:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function onEnterFrame(?e:Event):Void
	{
		video.update(Lib.getTimer());
		if (video.frameBytes != null) {
			uploadBytes(video.frameBytes);
		}
	}

	private function uploadBytes(bytes:Bytes):Void
	{
		// Initialize the `texture` if necessary.
		if (texture == null)
			texture = Lib.current.stage.context3D.createRectangleTexture(video.videoWidth, video.videoHeight, BGRA, true);

		// Initialize the `bitmapData` if necessary.
		if (bitmapData == null)
			bitmapData = BitmapData.fromTexture(texture);

		if (texture != null && bytes != null && bytes.length > 0)
		{
			texture.uploadFromByteArray(ByteArray.fromBytes(bytes), 0);
			width++;
			width--;
		}
	}

	@:noCompletion private override function set_height(value:Float):Float
		{
			if (__bitmapData != null)
				scaleY = value / __bitmapData.height;
			else if (video.videoHeight != 0)
				scaleY = value / video.videoHeight;
			else
				scaleY = 1;

			return value;
		}

	@:noCompletion private override function set_width(value:Float):Float
	{
		if (__bitmapData != null)
			scaleX = value / __bitmapData.width;
		else if (video.videoWidth != 0)
			scaleX = value / video.videoWidth;
		else
			scaleX = 1;

		return value;
	}

	@:noCompletion private override function set_bitmapData(value:BitmapData):BitmapData
	{
		__bitmapData = value;
		__setRenderDirty();
		__imageVersion = -1;
		return __bitmapData;
	}

	@:noCompletion inline function get_videoWidth():cpp.UInt32 { return video.videoWidth; }
	@:noCompletion inline function get_videoHeight():cpp.UInt32 { return video.videoHeight; }
	@:noCompletion inline function set_time(v:Int):Int { return video.time = v; }
	@:noCompletion inline function get_time():Int { return video.time; }
	@:noCompletion inline function set_position(v:Float):Float { return video.position = v; }
	@:noCompletion inline function get_position():Float { return video.position; }
	@:noCompletion inline function get_length():Int { return video.length; }
	@:noCompletion inline function get_duration():Int { return video.duration; }
	@:noCompletion inline function get_mrl():String { return video.mrl; }
	@:noCompletion inline function set_volume(v:Int):Int { return video.volume = v; }
	@:noCompletion inline function get_volume():Int { return video.volume; }
	@:noCompletion inline function set_delay(v:Int):Int { return video.delay = v; }
	@:noCompletion inline function get_delay():Int { return video.delay; }
	@:noCompletion inline function set_rate(v:Float):Float { return video.rate = v; }
	@:noCompletion inline function get_rate():Float { return video.rate; }
	@:noCompletion inline function get_fps():Float { return video.fps; }
	@:noCompletion inline function get_isPlaying():Bool { return video.isPlaying; }
	@:noCompletion inline function get_isSeekable():Bool { return video.isSeekable; }
	@:noCompletion inline function get_canPause():Bool { return video.canPause; }
	@:noCompletion inline function set_onOpening(v:Void->Void):Void->Void { return video.onOpening = v; }
	@:noCompletion inline function get_onOpening():Void->Void { return video.onOpening; }
	@:noCompletion inline function set_onPlaying(v:Void->Void):Void->Void { return video.onPlaying = v; }
	@:noCompletion inline function get_onPlaying():Void->Void { return video.onPlaying; }
	@:noCompletion inline function set_onPaused(v:Void->Void):Void->Void { return video.onPaused = v; }
	@:noCompletion inline function get_onPaused():Void->Void { return video.onPaused; }
	@:noCompletion inline function set_onStopped(v:Void->Void):Void->Void { return video.onStopped = v; }
	@:noCompletion inline function get_onStopped():Void->Void { return video.onStopped; }
	@:noCompletion inline function set_onEndReached(v:Void->Void):Void->Void { return video.onEndReached = v; }
	@:noCompletion inline function get_onEndReached():Void->Void { return video.onEndReached; }
	@:noCompletion inline function set_onEncounteredError(v:String->Void):String->Void { return video.onEncounteredError = v; }
	@:noCompletion inline function get_onEncounteredError():String->Void { return video.onEncounteredError; }
	@:noCompletion inline function set_onForward(v:Void->Void):Void->Void { return video.onForward = v; }
	@:noCompletion inline function get_onForward():Void->Void { return video.onForward; }
	@:noCompletion inline function set_onBackward(v:Void->Void):Void->Void { return video.onBackward = v; }
	@:noCompletion inline function get_onBackward():Void->Void { return video.onBackward; }
}