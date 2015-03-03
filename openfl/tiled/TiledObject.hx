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

enum FigureType
{
	RECTANGLE;
	ELLIPSE;
	POLYGON;
	POLYLINE;
	TILE;
	//CIRCLE;
	//BOX;
}

class TiledObject {

	/** The objectgroup this object belongs to */
	public var parent(default, null):TiledObjectGroup;
	
	/** Id */
	public var id(default, null):Int;
	
	/** A identification number, which represents a part of the tileset.
	 * This is actual only for Tile objects.  For others it will be 0. **/
	public var gid(default, null):Int;

	/** The name of this object */
	public var name(default, null):String;

	/** The type of this object */
	public var type(default, null):String;

	/** The x coordinate of this object (in pixels!) */
	public var x(default, null):Float;

	/** The y coordinate of this object (in pixels!) */
	public var y(default, null):Float;

	/** The width of this object in pixels. This is actual only for non-tile objects. */
	public var width(default, null):Float;

	/** The width of this object in pixels. This is actual only for non-tile objects. */
	public var height(default, null):Float;
	
	/** Contains all properties from this object */
	public var properties(default, null):Map<String, String>;
	
	/** Rotation of this object clockwise in degrees */
	public var rotation(default, null):Float;
	
	/** Points that represent polygon or polyline in local coordinate system */
	public var polyData(default, null):Array<Point>;
	
	/** Whether the object is shown `true` or hidden `false` */
	public var visible(default, null):Bool;
	
	/** The real type of figure from Tiled Editor */
	public var figureType(default, null):FigureType;
	
	/** Flipped or not horizontaly. Is matter only for Tiles. */
	public var flippedX(default, null):Bool;
	
	/** Flipped or not verticaly. Is matter only for Tiles. */
	public var flippedY(default, null):Bool;
	
	/** Flipped or not both horizontaly and verticaly. Is matter only for Tiles. */
	//public var flippedXY(default, null):Bool;
	
	/** */
	private function new(parent:TiledObjectGroup, id:Int, gid:Int, name:String, type:String, x:Float, y:Float,
			width:Float, height:Float, polyData:Array<Point>,
			properties:Map<String, String>, rotation:Float, figureType:FigureType, visible:Bool) {
		this.parent = parent;
		this.id = id;
		this.gid = gid;
		this.name = name;
		this.type = type;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.polyData = polyData;
		this.properties = properties;
		this.rotation = rotation;
		this.figureType = figureType;
		this.visible = visible;
		
		flippedX = (0x80000000 & gid) >>> 31 > 0 ? true : false;
		flippedY = (0x40000000 & gid) >>> 30 > 0 ? true : false;
		//flippedXY = (0x20000000 & gid) >>> 29 > 0 ? true : false;
		
		// mask flipped flag
		this.gid &= 0x1FFFFFFF;
	}

	/** Creates a new TiledObject-instance from the given Xml code. */
	public static function fromGenericXml(xml:Xml, parent:TiledObjectGroup):TiledObject {
		var id:Int = Std.parseInt(xml.get("id"));
		var gid:Int = Helper.avoidNullInt(Std.parseInt(xml.get("gid")));
		var name:String = xml.get("name");
		var type:String = xml.get("type");
		var x:Float = Std.parseInt(xml.get("x"));
		var y:Float = Std.parseInt(xml.get("y"));
		var width:Float = Helper.avoidNullFloat(Std.parseFloat(xml.get("width")));
		var height:Float = Helper.avoidNullFloat(Std.parseFloat(xml.get("height")));
		var rotation:Float = Helper.avoidNullFloat(Std.parseFloat(xml.get("rotation")));
		var visible:Bool = xml.get("visible") == "0" ? false : true;
		var properties:Map<String, String> = new Map<String, String>();
		var figureType:FigureType = null;
		var polyData:Array<Point> = null;
		
		if(0x1FFFFFFF & gid > 0)
			figureType = FigureType.TILE;											// image tile
		else		
			figureType = FigureType.RECTANGLE;										// and just rectangle
		
		for (child in xml) {
			if (Helper.isValidElement(child)) {
				if (child.nodeName == "properties") {
					for (property in child) {
						if (Helper.isValidElement(property)) {
							Helper.setProperty(property, properties);
						}
					}
				}
				
				if (child.nodeName == 'ellipse') {											// ellipse
					figureType = FigureType.ELLIPSE;
						
				} 
				else if (child.nodeName == "polygon" || child.nodeName == "polyline") {	// polygon or polyline
					
					polyData = new Array<Point>();

					var pointsAsStringArray:Array<String> = child.get("points").split(" ");

					for(p in pointsAsStringArray) {
						var coords:Array<String> = p.split(",");
						polyData.push(new Point(Std.parseFloat(coords[0]), Std.parseFloat(coords[1])));
					}

					if(child.nodeName == "polygon") 
						figureType = FigureType.POLYGON;
					else if(child.nodeName == "polyline")
						figureType = FigureType.POLYLINE;
				}									
			}
			
		}
		
		return new TiledObject(parent, id, gid, name, type, x, y, width,
			height, polyData, properties, rotation, figureType, visible);
	}
	
	/** Checks if this object is a polygon */
	public inline function isPolygon():Bool {return figureType == FigureType.POLYGON;}

	/** Checks if this object is a polyline */
	public inline function isPolyline():Bool { return figureType == FigureType.POLYLINE; }
	
	/** Checks if this object is a tile image */
	public inline function isTile():Bool {return figureType == FigureType.TILE;}
	
	/** Checks if this object is a circle (ellipse with width==height) */
	public inline function isCircle():Bool { return figureType == FigureType.ELLIPSE && width == height; }
	
	/** Checks if this object is a ellips. Note that any circle object is ellipse too! */
	public inline function isEllipse():Bool { return figureType == FigureType.ELLIPSE; }
	
	/** Checks if this object is a rectangle. Note that any box object is rectangle too! */
	public inline function isRectangle():Bool { return figureType == FigureType.RECTANGLE; }
	
	/** Checks if this object is a box (rectangle with width==height) */
	public inline function isBox():Bool { return figureType == FigureType.RECTANGLE && width == height; }
	
/*	private inline function get_isTile():Bool {return figureType == FigureType.TILE;}
	private inline function get_isPolygon():Bool {return figureType == FigureType.POLYGON;}
	private inline function get_isPolyline():Bool { return figureType == FigureType.POLYLINE; }
	private inline function get_isCircle():Bool { return figureType == FigureType.ELLIPSE && width == height; }
	private inline function get_isEllipse():Bool { return figureType == FigureType.ELLIPSE; }
	private inline function get_isRectangle():Bool { return figureType == FigureType.RECTANGLE; }
	private inline function get_isBox():Bool { return figureType == FigureType.RECTANGLE && width == height; }*/

}
