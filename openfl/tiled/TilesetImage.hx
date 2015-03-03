// Copyright (C) 2013 Christopher "Kasoki" Kaster
//
// This file is part of "openfl-tiled". <http://github.com/Kasoki/openfl-tiled>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
package openfl.tiled;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

class TilesetImage {

	/** The filepath where this image is */
	public var source(default, null):String;

	/** The filename with extension */
	public var fileName(default, null):String;

	/** The width of this image */
	public var width(default, null):Int;

	/** The height of this image */
	public var height(default, null):Int;
	
	/** File format of embeded `data` element. */
	public var format(default, null):String;
	
	/** The image as BitmapData */
	public var texture(default, null):BitmapData;

	public function new(source:String, trans:String, format:String, width:Int, height:Int, ?mapPrefix:String) {
		this.source = source;
		this.format = format;
		this.width = width;
		this.height = height;
		
		// get fileName from path
		this.fileName = source.substr(source.lastIndexOf("/") + 1, source.length);
		
		var useTransparentColor = false;
		var threshold:UInt = -1;
		var transparent:UInt = 0x00000000;

		if(trans != null) {
			useTransparentColor = true;

			// insert hex prefix and 255 alpha
			trans = "0xff" + trans;
			threshold = Std.parseInt(trans);
		}

		// load image
		//this.texture = Helper.getBitmapData(this.source, mapPrefix);
		var onComplete = function (image:BitmapData):Void
		{
			this.texture =  image;
			
			if (useTransparentColor && image != null) 
			{
				var rect = new Rectangle(0, 0, this.texture.width, this.texture.height);
				var point = new Point(0, 0);

				this.texture.threshold(this.texture, rect, point, "==", threshold, transparent, 0xFFFFFFFF, true);
			}
		};
		
		Assets.loadBitmapData(Helper.joinPath(mapPrefix, this.source), onComplete);
	}
	
	public static function fromGenericXml(xml:Xml, ?mapPrefix:String):TilesetImage
	{
		var source:String = xml.get('source');
		var format:String = xml.get('format');
		var trans:String = xml.get('trans');
		var width:Int = Std.parseInt(xml.get('width'));
		var height:Int = Std.parseInt(xml.get('height'));
		
		return new TilesetImage(source, trans, format, width, height, mapPrefix);
	}
}
