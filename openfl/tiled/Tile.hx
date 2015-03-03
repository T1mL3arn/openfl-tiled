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

class Tile {
	
	/** The local tile ID within its tileset. */
	public var id(default, null):Int;
	
	/** All properties this Tile contains */
	public var properties(default, null):Map<String, String>;
	
	/** Single image associated with Tile. Each tile from image-based Tileset has this property. */
	public var image(default, null):TilesetImage;
	
	/** Object group that represent collision layer for this Tile. */
	public var objectGroup(default, null):TiledObjectGroup;
	
	/** Terrain information. */
	public var terrain(default, null):String;
	
	/** A percentage indicating the probability that this tile is chosen when it competes with others. */
	public var probability(default, null):String;

	private function new(id:Int, terrain:String, probability:String, properties:Map<String, String> = null, image:TilesetImage = null, objectGroup:TiledObjectGroup = null) 
	{
		this.id = id;
		this.terrain = terrain;
		this.image = image;
		this.properties = properties;
		this.objectGroup = objectGroup;
		this.probability = probability;
	}
	
	public static function fromGenericXml(xml:Xml, ?mapPrefix:String):Tile
	{
		var id:Int = Std.parseInt(xml.get('id'));
		var terrain:String = xml.get("terrain");
		var probability:String = xml.get('probability');
		var properties:Map<String, String> = new Map<String, String>();
		var image:TilesetImage = null;
		var objectGroup:TiledObjectGroup = null;
		
		for (child in xml) {
			if (Helper.isValidElement(child)) {
				if (child.nodeName == "properties" ) {
					for (property in child) {
						if (Helper.isValidElement(property)) {
							Helper.setProperty(property, properties);
						}
					}
				}
				
				if (child.nodeName == "image") {
					image = TilesetImage.fromGenericXml(child, mapPrefix);
				}
				
				if (child.nodeName == "objectgroup") {
					objectGroup = TiledObjectGroup.fromGenericXml(child);
				}
			}
		}
		
		return new Tile(id, terrain, probability, properties, image, objectGroup);
	}
}
