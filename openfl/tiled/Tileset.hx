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

import flash.geom.Point;
import flash.display.BitmapData;
import flash.geom.Rectangle;

import haxe.io.Path;

import openfl.display.Tilesheet;

class Tileset {

	/** The TiledMap object this tileset belongs to */
	public var tiledMap(default, null):TiledMap_;

	/** The first GID this tileset has */
	public var firstGID(default, null):Int;

	/** The name of this tileset */
	public var name(default, null):String;

	/** The width of the tileset image */
	public var width(get_width, null):Int;

	/** The height of the tileset image */
	public var height(get_height, null):Int;

	/** The width of one tile */
	public var tileWidth(default, null):Int;

	/** The height of one tile */
	public var tileHeight(default, null):Int;

	/** The spacing between the tiles */
	public var spacing(default, null):Int;

	/** All properties this Tileset contains */
	public var properties(default, null):Map<String, String>;

	/** All terrain types */
	public var terrainTypes(default, null):Array<TerrainType>;
	
	/** All tiles this Tileset contains */
	public var tiles(default, null):Array<Tile>;

	/** The image of this Tileset */
	public var image(default, null):TilesetImage;

	/** The tile offset */
	public var offset(default, null):Point;

	private function new(tiledMap:TiledMap_, name:String, tileWidth:Int, tileHeight:Int, spacing:Int,
			properties:Map<String, String>, terrainTypes:Array<TerrainType>, image:TilesetImage, offset:Point, tiles:Array<Tile>) {
		this.tiledMap = tiledMap;
		this.name = name;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.spacing = spacing;
		this.properties = properties;
		this.terrainTypes = terrainTypes;
		this.image = image;
		this.offset = offset;
		this.tiles = tiles;
	}

	/** Sets the first GID. */
	public function setFirstGID(gid:Int) {
		this.firstGID = gid;
	}
	
	/** Generates a new Tileset from the given Xml code */
	public static function fromGenericXml(tiledMap:TiledMap_, content:String):Tileset {
		var xml = Xml.parse(content).firstElement();

		var name:String = xml.get("name");
		var tileWidth:Int = Std.parseInt(xml.get("tilewidth"));
		var tileHeight:Int = Std.parseInt(xml.get("tileheight"));
		var spacing:Int = xml.exists("spacing") ? Std.parseInt(xml.get("spacing")) : 0;
		var properties:Map<String, String> = new Map<String, String>();
		var terrainTypes:Array<TerrainType> = new Array<TerrainType>();
		var image:TilesetImage = null;
		var tileOffset:Point = new Point();
		var tiles:Array<Tile> = new Array<Tile>();
		var prefix = Path.directory(tiledMap.path) + "/";
		
		for (child in xml.elements()) {
			if(Helper.isValidElement(child)) {
				if (child.nodeName == "properties") {
					for (property in child)
						if (Helper.isValidElement(property))
							Helper.setProperty(property, properties);
				}

				if (child.nodeName == "tileoffset") {
					tileOffset.x = Std.parseInt(child.get("x"));
					tileOffset.y = Std.parseInt(child.get("y"));
				}

				if (child.nodeName == "image") {
					image = TilesetImage.fromGenericXml(child, prefix);
				}

				if (child.nodeName == "terraintypes") {
					for (element in child) {
						if(Helper.isValidElement(element)) {
							if (element.nodeName == "terrain") {
								terrainTypes.push(TerrainType.fromGenericXml(element));
							}
						}
					}
				}

				if (child.nodeName == "tile") {
					tiles.push(Tile.fromGenericXml(child, prefix));
				}
			}
		}

		return new Tileset(tiledMap, name, tileWidth, tileHeight, spacing, properties, terrainTypes,
			image, tileOffset, tiles);
	}
	
	/** Returns TilesetImage by GID */
	public inline function getImageByGID(gid:Int):TilesetImage {
			return tiles[gid - firstGID].image;
			//return tiles[0x1FFFFFFF & gid - this.firstGID].image;
	}
	
	/** Returns the BitmapData of the given GID */
	public function getTileRectByGID(gid:Int):Rectangle {
		var texturePositionX:Float = getTexturePositionByGID(gid).x;
		var texturePositionY:Float = getTexturePositionByGID(gid).y;

		var spacingX:Float = 0;
		var spacingY:Float = 0;

		if(spacing > 0) {
			spacingX = texturePositionX + spacing;
			spacingY = texturePositionY + spacing;
		}

		var rect:Rectangle = new Rectangle(
			(texturePositionX * this.tileWidth) + spacingX + offset.x,
			(texturePositionY * this.tileHeight) + spacingY + offset.y,
			this.tileWidth,
			this.tileHeight);

		return rect;
	}

	/** Returns a Point which specifies the position of the gid in this tileset (Not in pixels!) */
	public function getTexturePositionByGID(gid:Int):Point {
		var number = gid - this.firstGID;

		return new Point(getInnerTexturePositionX(number), getInnerTexturePositionY(number));
	}

	/** Returns the inner x-position of a texture with given tileNumber */
	private function getInnerTexturePositionX(tileNumber:Int):Int {
		return (tileNumber % Std.int(this.width / this.tileWidth));
	}

	/** Returns the inner y-position of a texture with given tileNumber */
	private function getInnerTexturePositionY(tileNumber:Int):Int {
		return Std.int(tileNumber / Std.int(this.width / this.tileWidth));
	}

	private function get_width():Int {
		return this.image.width;
	}

	private function get_height():Int {
		return this.image.height;
	}
}
